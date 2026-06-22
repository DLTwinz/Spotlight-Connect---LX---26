// Supabase Edge Function: admin_list_role_applications
// Returns role_applications joined with users profile basics for admin review.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS: Record<string, string> = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-max-age": "86400",
};

type RequestedRole = "audience" | "talent" | "business" | "admin" | string;

type Status = "pending" | "approved" | "rejected" | "cancelled" | "needs_more_info" | string;

function jsonResponse(status: number, body: unknown) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "content-type": "application/json; charset=utf-8" },
  });
}

function getJwt(req: Request): string | null {
  const auth = req.headers.get("authorization") || req.headers.get("Authorization");
  if (!auth) return null;
  const m = auth.match(/^Bearer\s+(.+)$/i);
  return m?.[1] ?? null;
}

function isAllowedRole(requested: string): boolean {
  const v = (requested || "").toLowerCase().trim();
  return v === "talent" || v === "business" || v === "admin" || v === "audience";
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: CORS_HEADERS });
  if (req.method !== "POST") return jsonResponse(405, { error: "method_not_allowed" });

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceRoleKey) return jsonResponse(500, { error: "missing_supabase_env" });

    const jwt = getJwt(req);
    if (!jwt) return jsonResponse(401, { error: "missing_jwt" });

    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false },
      global: { headers: { Authorization: `Bearer ${jwt}` } },
    });

    const { data: authData, error: authErr } = await adminClient.auth.getUser(jwt);
    if (authErr || !authData?.user) return jsonResponse(401, { error: "invalid_jwt" });
    const actorUserId = authData.user.id;

    // Admin check: users.active_role == 'admin' OR approved_roles contains 'admin'
    const { data: actorRow, error: actorErr } = await adminClient
      .from("users")
      .select("id, active_role, approved_roles")
      .eq("id", actorUserId)
      .maybeSingle();

    if (actorErr || !actorRow) return jsonResponse(403, { error: "actor_not_found" });
    const activeRole = (actorRow.active_role ?? "").toString().toLowerCase();

    const approvedRoles = Array.isArray(actorRow.approved_roles) ? actorRow.approved_roles : [];
    const isAdmin = activeRole === "admin" || approvedRoles.map((r: unknown) => `${r}`.toLowerCase()).includes("admin");
    if (!isAdmin) return jsonResponse(403, { error: "forbidden" });

    const body = await req.json().catch(() => ({}));
    const requestedRole = (body?.requested_role ?? "all").toString();
    const status = (body?.status ?? "all").toString();
    const limit = Math.min(200, Math.max(1, Number(body?.limit ?? 100)));

    let q = adminClient
      .from("role_applications")
      .select("id, user_id, requested_role, status, note, created_at, updated_at")
      .order("created_at", { ascending: false })
      .limit(limit);

    if (requestedRole !== "all") {
      if (!isAllowedRole(requestedRole)) return jsonResponse(400, { error: "invalid_requested_role" });
      q = q.eq("requested_role", requestedRole as RequestedRole);
    }

    if (status !== "all") q = q.eq("status", status as Status);

    const { data: apps, error: appsErr } = await q;
    if (appsErr) return jsonResponse(500, { error: "role_applications_query_failed", detail: appsErr.message });

    const userIds = [...new Set((apps ?? []).map((a) => a.user_id).filter(Boolean))];
    let usersById: Record<string, any> = {};

    if (userIds.length) {
      const { data: users, error: usersErr } = await adminClient
        .from("users")
        .select("id, email, display_name, username, active_role, base_role, approved_roles, updated_at")
        .in("id", userIds);

      if (!usersErr && Array.isArray(users)) {
        usersById = Object.fromEntries(users.map((u) => [u.id, u]));
      }
    }

    const items = (apps ?? []).map((a) => {
      const u = usersById[a.user_id] ?? null;
      return {
        application_id: a.id,
        user_id: a.user_id,
        requested_role: a.requested_role,
        status: a.status,
        note: a.note ?? null,
        created_at: a.created_at,
        updated_at: a.updated_at,
        user: u,
      };
    });

    return jsonResponse(200, { items });
  } catch (e) {
    return jsonResponse(500, { error: "unexpected_error", detail: `${e}` });
  }
});
