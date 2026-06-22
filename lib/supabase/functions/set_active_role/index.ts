// supabase edge function: set_active_role
// Sets the caller's active_role to a role they already have approved.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const CORS_HEADERS = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-max-age": "86400",
};

type Body = { role?: string };

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "method_not_allowed" }), { status: 405, headers: { ...CORS_HEADERS, "content-type": "application/json" } });

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const authHeader = req.headers.get("Authorization") ?? "";
    const userClient = createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authHeader } } });

    const { data: auth, error: authErr } = await userClient.auth.getUser();
    if (authErr || !auth?.user) {
      return new Response(JSON.stringify({ error: "not_authenticated" }), { status: 401, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
    }

    const body = (await req.json().catch(() => ({}))) as Body;
    const role = (body.role ?? "").trim();
    const allowed = new Set(["audience", "talent", "business"]);
    if (!allowed.has(role)) {
      return new Response(JSON.stringify({ error: "invalid_role" }), { status: 400, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    const { data: userRow, error: userErr } = await adminClient.from("users").select("id, approved_roles").eq("id", auth.user.id).maybeSingle();
    if (userErr) throw userErr;
    if (!userRow) {
      return new Response(JSON.stringify({ error: "user_profile_missing" }), { status: 409, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
    }

    const approved: string[] = Array.isArray(userRow.approved_roles) ? userRow.approved_roles : [];
    if (!approved.includes(role)) {
      return new Response(JSON.stringify({ error: "role_not_approved", approved_roles: approved }), { status: 403, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
    }

    const { data: updated, error: upErr } = await adminClient.from("users").update({ active_role: role }).eq("id", auth.user.id).select("id, active_role, approved_roles").single();
    if (upErr) throw upErr;

    return new Response(JSON.stringify({ ok: true, user: updated }), { status: 200, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
  } catch (e) {
    return new Response(JSON.stringify({ error: "internal_error", detail: String(e) }), { status: 500, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
  }
});
