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
  const mission = body.mission ?? null;
  const reason = (body.reason ?? "").toString();
  if (!mission) return json({ error: "mission is required" }, 400);
  if (!reason) return json({ error: "reason is required" }, 400);

  // Back-compat + schema safety:
  // Some clients send `action_type` (DTO field) while the DB expects `mission_type`.
  // IMPORTANT: mission_type is often a DB enum, so do not invent defaults here.
  if (!mission.mission_type) mission.mission_type = mission.action_type;
  if (!mission.mission_type) return json({ error: "mission_type is required" }, 400);

  // Normalize common status synonyms (client uses UI-friendly names).
  if (mission.status === "in_progress") mission.status = "active";
  if (mission.status === "completed") mission.status = "claimable";

  let saved: any;
  if (mission.id) {
    const { data, error } = await svc.from("missions").update({ ...mission, updated_at: new Date().toISOString() }).eq("id", mission.id).select("*").single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  } else {
    const { data, error } = await svc.from("missions").insert(mission).select("*").single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  }

  await svc.from("admin_audit_log").insert({
    admin_user_id: adminId,
    action: "mission_upsert",
    target_type: "mission",
    target_id: saved.id,
    payload_json: { reason, mission: saved },
  });

  return json({ ok: true, mission: saved });
});
