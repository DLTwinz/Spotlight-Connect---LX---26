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

function expiresAtForRepeat(repeat: string | null) {
  if (!repeat) return null;
  const now = new Date();
  if (repeat === "daily") {
    const d = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1));
    return d.toISOString();
  }
  if (repeat === "weekly") {
    const day = (now.getUTCDay() + 6) % 7; // Mon=0
    const nextMon = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - day + 7));
    return nextMon.toISOString();
  }
  return null;
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

async function assertMissionStartAllowed(svc: any, userId: string) {
  // Safe-by-default: if anything goes wrong loading policy, we block writes.
  try {
    const { data: userRow } = await svc.from("users").select("active_role").eq("id", userId).maybeSingle();
    const roleKey = roleKeyFromActiveRole(userRow?.active_role);
    const flags = await loadProgressionPolicyFlags(svc, roleKey);

    const progressionEnabled = Boolean(flags["progression_enabled"]);
    const missionsEnabled = Boolean(flags["missions_enabled"]);
    const killAllWrites = Boolean(flags["kill_progression_write_paths"]);
    if (!progressionEnabled) return { ok: false, reason: "Progression disabled" };
    if (!missionsEnabled) return { ok: false, reason: "Missions disabled" };
    if (killAllWrites) return { ok: false, reason: "Progression writes temporarily disabled" };
    return { ok: true };
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
  const missionId = (body.mission_id ?? "").toString();
  if (!missionId) return json({ error: "mission_id is required" }, 400);

  const svc = createClient(supabaseUrl, serviceKey);

  const allow = await assertMissionStartAllowed(svc, userId);
  if (!allow.ok) return json({ error: allow.reason }, 403);

  const { data: mission, error: mErr } = await svc.from("missions").select("id, status, target_value, repeat_interval, start_at, end_at").eq("id", missionId).maybeSingle();
  if (mErr) return json({ error: mErr.message }, 500);
  if (!mission) return json({ error: "Mission not found" }, 404);
  if (mission.status === "archived") return json({ error: "Mission archived" }, 400);

  const now = new Date();
  if (mission.start_at && new Date(mission.start_at) > now) return json({ error: "Mission not started yet" }, 400);
  if (mission.end_at && new Date(mission.end_at) < now) return json({ error: "Mission expired" }, 400);

  const expiresAt = expiresAtForRepeat(mission.repeat_interval ?? null);

  // idempotent: reuse existing row for this window
  const { data: existing } = await svc
    .from("user_missions")
    .select("*")
    .eq("user_id", userId)
    .eq("mission_id", missionId)
    .eq("expires_at", expiresAt)
    .maybeSingle();

  if (existing) {
    // If already active/claimable/completed, just return it.
    return json({ ok: true, user_mission: existing });
  }

  const insert = {
    user_id: userId,
    mission_id: missionId,
    status: "active",
    progress_value: 0,
    progress_target: mission.target_value ?? 0,
    started_at: now.toISOString(),
    expires_at: expiresAt,
  };

  const { data: created, error: cErr } = await svc.from("user_missions").insert(insert).select("*").single();
  if (cErr) return json({ error: cErr.message }, 500);

  return json({ ok: true, user_mission: created });
});
