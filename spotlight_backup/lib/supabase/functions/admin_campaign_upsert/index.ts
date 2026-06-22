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
  const campaign = body.campaign ?? null;
  const reason = (body.reason ?? "").toString();
  if (!campaign) return json({ error: "campaign is required" }, 400);
  if (!reason) return json({ error: "reason is required" }, 400);

  // campaigns.business_user_id is NOT NULL in schema. Ensure it is always set on insert.
  // On update, never overwrite business_user_id to null if the client omitted it.
  const normalizedCampaign: Record<string, unknown> = { ...(campaign as Record<string, unknown>) };
  if (!normalizedCampaign["business_user_id"]) normalizedCampaign["business_user_id"] = adminId;

  // Avoid accidental nulling of required fields when editing.
  if (campaign.id) {
    for (const key of ["business_user_id"]) {
      if (normalizedCampaign[key] === null) delete normalizedCampaign[key];
    }
  }

  let saved: any;
  if (campaign.id) {
    const { data, error } = await svc.from("campaigns").update({ ...normalizedCampaign, updated_at: new Date().toISOString() }).eq("id", campaign.id).select("*").single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  } else {
    const { data, error } = await svc.from("campaigns").insert(normalizedCampaign).select("*").single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  }

  await svc.from("admin_audit_log").insert({
    admin_user_id: adminId,
    action: "campaign_upsert",
    target_type: "campaign",
    target_id: saved.id,
    payload_json: { reason, campaign: saved },
  });

  return json({ ok: true, campaign: saved });
});
