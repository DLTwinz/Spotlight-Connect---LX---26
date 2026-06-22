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

async function isAdmin(svc: any, userId: string) {
  const { data } = await svc.from("users").select("active_role, approved_roles").eq("id", userId).maybeSingle();
  if (!data) return false;
  if (data.active_role === "admin") return true;
  const roles = (data.approved_roles ?? []) as string[];
  return roles.includes("admin");
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

  const authHeader = req.headers.get("Authorization") ?? "";
  const userClient = createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authHeader } } });
  const { data: userData } = await userClient.auth.getUser();
  if (!userData?.user) return json({ error: "Unauthorized" }, 401);
  const adminId = userData.user.id;

  const svc = createClient(supabaseUrl, serviceKey);
  if (!(await isAdmin(svc, adminId))) return json({ error: "Forbidden" }, 403);

  const body = await req.json().catch(() => ({}));
  const campaignId = (body.campaign_id ?? body.campaignId ?? "").toString();
  const reason = (body.reason ?? "").toString();
  if (!campaignId) return json({ error: "campaign_id is required" }, 400);
  if (!reason) return json({ error: "reason is required" }, 400);

  // Detach missions rather than deleting them.
  const detach: Record<string, unknown> = {};
  try {
    const { error } = await svc.from("missions").update({ campaign_id: null, updated_at: new Date().toISOString() }).eq("campaign_id", campaignId);
    detach.missions = error ? { ok: false, error: error.message } : { ok: true };
  } catch (e) {
    detach.missions = { ok: false, error: String(e) };
  }

  // Best-effort cleanup for participation rows.
  for (const table of ["campaign_participants"]) {
    try {
      const { error } = await svc.from(table).delete().eq("campaign_id", campaignId);
      detach[table] = error ? { ok: false, error: error.message } : { ok: true };
    } catch (e) {
      detach[table] = { ok: false, error: String(e) };
    }
  }

  const { data: deleted, error: delErr } = await svc.from("campaigns").delete().eq("id", campaignId).select("*").maybeSingle();
  if (delErr) return json({ error: delErr.message, detach }, 500);

  await svc.from("admin_audit_log").insert({
    admin_user_id: adminId,
    action: "campaign_delete",
    target_type: "campaign",
    target_id: campaignId,
    payload_json: { reason, detach, campaign: deleted },
  });

  return json({ ok: true, campaign: deleted, detach });
});
