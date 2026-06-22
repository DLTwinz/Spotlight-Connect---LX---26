// Supabase Edge Function: qa_set_role
// Allows QA/dev to set a user's active role and ensure required approval flags.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-max-age": "86400",
};

type QaSetRoleBody = {
  user_id?: string;
  role?: string;
  set_active?: boolean;
  approve?: boolean;
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });

  try {
    if (req.method !== "POST") {
      return new Response(JSON.stringify({ error: "Method not allowed" }), {
        status: 405,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false },
    });

    // SECURITY: This function must be admin-only.
    // We authenticate the caller using the provided Authorization header, then verify
    // that the caller has `admin` in users.approved_roles.
    const authHeader = req.headers.get("authorization") ?? req.headers.get("Authorization") ?? "";
    const supabaseUser = createClient(supabaseUrl, anonKey, {
      auth: { persistSession: false },
      global: { headers: { Authorization: authHeader } },
    });

    const { data: authData, error: authErr } = await supabaseUser.auth.getUser();
    if (authErr || !authData?.user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }
    const callerUserId = authData.user.id;

    const { data: callerRow, error: callerErr } = await supabaseAdmin
      .from("users")
      .select("id, approved_roles")
      .eq("id", callerUserId)
      .maybeSingle();

    if (callerErr) {
      return new Response(JSON.stringify({ error: `Caller lookup failed: ${callerErr.message}` }), {
        status: 500,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    const callerApproved: string[] = Array.isArray((callerRow as any)?.approved_roles)
      ? ((callerRow as any).approved_roles as string[])
      : [];
    const callerIsAdmin = callerApproved.map((r) => String(r).toLowerCase()).includes("admin");
    if (!callerIsAdmin) {
      return new Response(JSON.stringify({ error: "Forbidden", detail: "Admin role required" }), {
        status: 403,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    const body = (await req.json().catch(() => ({}))) as QaSetRoleBody;

    const userId = body.user_id ?? callerUserId;
    const role = (body.role ?? "audience").toLowerCase();
    const setActive = body.set_active ?? true;
    const approve = body.approve ?? true;

    // Load current user row
    const { data: existing, error: fetchErr } = await supabaseAdmin
      .from("users")
      .select("id, approved_roles, active_role, application_status_summary")
      .eq("id", userId)
      .maybeSingle();

    if (fetchErr) {
      return new Response(JSON.stringify({ error: `Fetch failed: ${fetchErr.message}` }), {
        status: 500,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    const approvedRoles: string[] = Array.isArray(existing?.approved_roles)
      ? existing!.approved_roles
      : [];

    const desiredApproved = new Set<string>(approvedRoles.map((r) => String(r).toLowerCase()));
    desiredApproved.add("audience");
    if (approve) desiredApproved.add(role);

    const updatePayload: Record<string, unknown> = {
      approved_roles: Array.from(desiredApproved),
    };

    if (setActive) updatePayload.active_role = role;

    // Match the gating expectations in the Flutter app: ensure talent/business show approved.
    if (approve && (role === "talent" || role === "business")) {
      updatePayload.application_status_summary = "approved";
    }

    const { error: updateErr } = await supabaseAdmin.from("users").update(updatePayload).eq("id", userId);

    if (updateErr) {
      return new Response(JSON.stringify({ error: `Update failed: ${updateErr.message}` }), {
        status: 500,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    return new Response(
      JSON.stringify({ ok: true, user_id: userId, role, set_active: setActive, approve, applied: updatePayload }),
      { headers: { ...CORS_HEADERS, "content-type": "application/json" } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...CORS_HEADERS, "content-type": "application/json" },
    });
  }
});
