import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const CORS_HEADERS = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-max-age": "86400",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), { status, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
}

function roleKeyFromActiveRole(activeRole: string | null | undefined) {
  const r = (activeRole ?? "").toLowerCase();
  if (r === "audience" || r === "supporter") return "supporter";
  if (r === "talent" || r === "creator") return "creator";
  if (r === "business" || r === "brand") return "brand";
  if (r === "admin") return "admin";
  return "unknown";
}

async function loadProgressionPolicyFlags(svc: any, roleKey: string) {
  // Prefer the stable RPC contract.
  try {
    const { data, error } = await svc.rpc("get_feature_policy", { role: roleKey });
    if (!error && data && typeof data === "object") {
      const rawFlags = (data as any).flags;
      const flags: Record<string, boolean> = {};
      if (rawFlags && typeof rawFlags === "object") {
        for (const [k, v] of Object.entries(rawFlags)) {
          if (typeof v === "boolean") flags[k] = v;
          else if (typeof v === "string") flags[k] = v.toLowerCase() === "true";
          else if (typeof v === "number") flags[k] = v !== 0;
        }
      }
      return flags;
    }
  } catch (_) {
    // Fall through to table reads.
  }

  const flags: Record<string, boolean> = {};

  const { data: policyRow } = await svc
    .from("feature_policies")
    .select("policy,is_enabled")
    .eq("role_key", roleKey)
    .maybeSingle();

  const policyEnabled = (policyRow?.is_enabled as boolean | undefined) ?? true;
  const rawPolicy = policyRow?.policy;
  if (policyEnabled && rawPolicy && typeof rawPolicy === "object") {
    for (const [k, v] of Object.entries(rawPolicy)) {
      if (typeof v === "boolean") flags[k] = v;
      else if (typeof v === "string") flags[k] = v.toLowerCase() === "true";
      else if (typeof v === "number") flags[k] = v !== 0;
    }
  }

  const { data: killRows } = await svc.from("kill_switches").select("key,is_enabled");
  if (Array.isArray(killRows)) {
    for (const row of killRows) {
      const key = row?.key?.toString?.();
      if (!key) continue;
      flags[key] = Boolean(row?.is_enabled);
    }
  }
  return flags;
}

async function assertCampaignJoinAllowed(svc: any, userId: string) {
  // Safe-by-default: if anything goes wrong loading policy, we block writes.
  try {
    const { data: userRow } = await svc.from("users").select("active_role").eq("id", userId).maybeSingle();
    const roleKey = roleKeyFromActiveRole(userRow?.active_role);
    const flags = await loadProgressionPolicyFlags(svc, roleKey);

    const progressionEnabled = Boolean(flags["progression_enabled"]);
    const campaignsEnabled = Boolean(flags["campaigns_enabled"]);
    const killAllWrites = Boolean(flags["kill_progression_write_paths"]);
    const killJoins = Boolean(flags["kill_campaign_joins"]);
    if (!progressionEnabled) return { ok: false, reason: "Progression disabled" };
    if (!campaignsEnabled) return { ok: false, reason: "Campaigns disabled" };
    if (killAllWrites) return { ok: false, reason: "Progression writes temporarily disabled" };
    if (killJoins) return { ok: false, reason: "Campaign joins temporarily disabled" };
    return { ok: true, participantRole: roleKey };
  } catch (_) {
    return { ok: false, reason: "Progression policy unavailable" };
  }
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

  const authHeader = req.headers.get("Authorization") ?? "";
  const userClient = createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authHeader } } });
  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData?.user) return json({ error: "Unauthorized" }, 401);
  const userId = userData.user.id;

  const body = await req.json().catch(() => ({}));
  const campaignId = (body.campaign_id ?? "").toString();
  if (!campaignId) return json({ error: "campaign_id is required" }, 400);

  const svc = createClient(supabaseUrl, serviceKey);

  const allow = await assertCampaignJoinAllowed(svc, userId);
  if (!allow.ok) return json({ error: allow.reason }, 403);

  const participantRole = (allow.participantRole ?? "unknown").toString();

  // Ensure campaign exists
  const { data: campaign, error: cErr } = await svc.from("campaigns").select("id, status").eq("id", campaignId).maybeSingle();
  if (cErr) return json({ error: cErr.message }, 500);
  if (!campaign) return json({ error: "Campaign not found" }, 404);
  if (campaign.status === "archived") return json({ error: "Campaign archived" }, 400);

  // Upsert participant row (campaign_participants is the existing join table)
  const existing = await svc
    .from("campaign_participants")
    .select("*")
    .eq("campaign_id", campaignId)
    .eq("user_id", userId)
    .maybeSingle();

  if (existing.data) {
    const { data: updated, error: uErr } = await svc
      .from("campaign_participants")
      .update({ status: "active", participant_role: participantRole, updated_at: new Date().toISOString() })
      .eq("id", existing.data.id)
      .select("*")
      .single();
    if (uErr) return json({ error: uErr.message }, 500);
    return json({ ok: true, participant: updated });
  }

  const { data: created, error: iErr } = await svc
    .from("campaign_participants")
    .insert({ campaign_id: campaignId, user_id: userId, participant_role: participantRole, status: "active" })
    .select("*")
    .single();
  if (iErr) return json({ error: iErr.message }, 500);

  return json({ ok: true, participant: created });
});
