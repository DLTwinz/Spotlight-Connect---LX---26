// supabase edge function: admin_review_role_application
// Admin-only: approves/rejects a user's role application and updates approved_roles.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const CORS_HEADERS = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-max-age": "86400",
};

type Body = {
  user_id?: string;
  requested_role?: string; // talent | business | admin
  decision?: string; // approve | reject
  note?: string;
  set_active?: boolean;
};

function formatError(e: unknown): string {
  if (typeof e === "string") return e;
  if (e instanceof Error) {
    const cause = (e as any)?.cause;
    return cause ? `${e.name}: ${e.message} | cause: ${formatError(cause)}` : `${e.name}: ${e.message}`;
  }

  const obj = e as any;
  try {
    if (obj && typeof obj === "object") {
      const maybeMessage = obj.message ?? obj.error_description ?? obj.error;
      const parts: string[] = [];
      if (maybeMessage) parts.push(String(maybeMessage));
      if (obj.details) parts.push(`details: ${String(obj.details)}`);
      if (obj.hint) parts.push(`hint: ${String(obj.hint)}`);
      if (obj.code) parts.push(`code: ${String(obj.code)}`);
      if (parts.length > 0) return parts.join(" | ");
    }

    return JSON.stringify(e, (_k, v) => (typeof v === "bigint" ? v.toString() : v));
  } catch {
    return String(e);
  }
}

async function bestEffortUpdateUser(
  // Supabase JS generics vary across versions; keep this helper unblocked.
  adminClient: any,
  userId: string,
  payload: Record<string, unknown>,
) {
  // Different installs may have different users columns. Attempt a full update,
  // then fall back to a minimal safe update.
  try {
    return await adminClient.from("users").update(payload).eq("id", userId).select("id").maybeSingle();
  } catch (_e) {
    const minimal: Record<string, unknown> = {};
    for (const k of ["approved_roles", "active_role"]) {
      if (k in payload) minimal[k] = payload[k];
    }
    return await adminClient.from("users").update(minimal).eq("id", userId).select("id").maybeSingle();
  }
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") return new Response(JSON.stringify({ error: "method_not_allowed" }), { status: 405, headers: { ...CORS_HEADERS, "content-type": "application/json" } });

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    // IMPORTANT:
    // - Many Supabase setups do NOT expose SUPABASE_SERVICE_ROLE_KEY by default.
    // - For safety, prefer a custom secret named SERVICE_ROLE_KEY (no SUPABASE_ prefix).
    //   Set it in Supabase Dashboard → Project Settings → Edge Functions → Secrets.
    const serviceRoleKey = Deno.env.get("SERVICE_ROLE_KEY") ?? Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    if (!supabaseUrl || !anonKey) {
      return new Response(JSON.stringify({ error: "missing_env", detail: "SUPABASE_URL or SUPABASE_ANON_KEY missing" }), {
        status: 500,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }
    if (!serviceRoleKey) {
      return new Response(JSON.stringify({ error: "missing_env", detail: "SERVICE_ROLE_KEY secret not set" }), {
        status: 500,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    const authHeader = req.headers.get("Authorization") ?? "";
    const userClient = createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authHeader } } });

    const { data: auth, error: authErr } = await userClient.auth.getUser();
    if (authErr || !auth?.user) {
      return new Response(JSON.stringify({ error: "not_authenticated" }), { status: 401, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
    }

    const body = (await req.json().catch(() => ({}))) as Body;
    const targetUserId = (body.user_id ?? "").trim();
    const requestedRole = (body.requested_role ?? "").trim();
    const decision = (body.decision ?? "").trim();
    const note = (body.note ?? "").trim();
    const setActive = body.set_active === true;

    const allowedRoles = new Set(["talent", "business", "admin"]);
    const allowedDecisions = new Set(["approve", "reject"]);

    if (!targetUserId) return new Response(JSON.stringify({ error: "missing_user_id" }), { status: 400, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
    if (!allowedRoles.has(requestedRole)) return new Response(JSON.stringify({ error: "invalid_requested_role" }), { status: 400, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
    if (!allowedDecisions.has(decision)) return new Response(JSON.stringify({ error: "invalid_decision" }), { status: 400, headers: { ...CORS_HEADERS, "content-type": "application/json" } });

    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    // Check caller is approved admin.
    const { data: caller, error: callerErr } = await adminClient.from("users").select("id, approved_roles").eq("id", auth.user.id).maybeSingle();
    if (callerErr) throw callerErr;
    const callerApproved: string[] = caller && Array.isArray((caller as any).approved_roles) ? (caller as any).approved_roles : [];
    if (!callerApproved.includes("admin")) {
      return new Response(JSON.stringify({ error: "not_admin" }), { status: 403, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
    }

    // Load target.
    const { data: target, error: targetErr } = await adminClient.from("users").select("id, approved_roles, active_role").eq("id", targetUserId).maybeSingle();
    if (targetErr) throw targetErr;
    if (!target) return new Response(JSON.stringify({ error: "target_user_missing" }), { status: 404, headers: { ...CORS_HEADERS, "content-type": "application/json" } });

    const approved: string[] = Array.isArray((target as any).approved_roles) ? (target as any).approved_roles : [];
    const ensured = new Set(approved);
    ensured.add("audience");

    let nextApproved = Array.from(ensured);
    let nextActive = (target as any).active_role as string | null;

    if (decision === "approve") {
      if (!nextApproved.includes(requestedRole)) nextApproved = [...nextApproved, requestedRole];
      if (setActive && (requestedRole === "talent" || requestedRole === "business")) nextActive = requestedRole;
    }

    // Update role_applications so the item leaves the pending queue.
    // Different installs use slightly different columns, so we attempt a full
    // metadata update first, and fall back to status-only if the schema doesn't
    // support reviewed_at/review_note/reviewed_by.
    try {
      const nextStatus = decision === "approve" ? "approved" : "rejected";
      try {
        await adminClient
          .from("role_applications")
          .update({
            status: nextStatus,
            reviewed_at: new Date().toISOString(),
            review_note: note || null,
            reviewed_by: auth.user.id,
          })
          .eq("user_id", targetUserId)
          .eq("requested_role", requestedRole)
          .throwOnError();
      } catch (_e) {
        await adminClient
          .from("role_applications")
          .update({ status: nextStatus })
          .eq("user_id", targetUserId)
          .eq("requested_role", requestedRole)
          .throwOnError();
      }
    } catch (_ignored) {
      // Best-effort: some installs may not have role_applications or may have
      // different naming. The user role update below is the primary action.
    }

    const { data: updated, error: upErr } = await adminClient
      .from("users")
      .update({ approved_roles: nextApproved, active_role: nextActive })
      .eq("id", targetUserId)
      .select("id, approved_roles, active_role")
      .single();
    if (upErr) {
      // Some schemas differ; try a best-effort update to avoid blocking launch.
      const nextStatus = decision === "approve" ? "approved" : "rejected";
      const { data: fallback, error: fallbackErr } = await bestEffortUpdateUser(adminClient, targetUserId, {
        approved_roles: nextApproved,
        active_role: nextActive,
        application_status_summary: nextStatus,
        requested_role_pending: null,
        updated_at: new Date().toISOString(),
      });
      if (fallbackErr) throw fallbackErr;
      return new Response(JSON.stringify({ ok: true, user: fallback }), { status: 200, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
    }

    // Best-effort: align with manual launch verification rules if these columns exist.
    try {
      const nextStatus = decision === "approve" ? "approved" : "rejected";
      await bestEffortUpdateUser(adminClient, targetUserId, {
        application_status_summary: nextStatus,
        requested_role_pending: null,
        updated_at: new Date().toISOString(),
      });
    } catch (_e) {
      // Best-effort.
    }

    // Server-side notification to the target user.
    try {
      const now = new Date();
      const notificationId = `n_${now.getTime()}_${Math.floor(Math.random() * 100000)}`;
      const approved = decision === "approve";
      const title = approved ? "Role approved" : "Role update";
      const bodyText = approved
        ? `Your ${requestedRole} role has been approved.`
        : `Your ${requestedRole} role request was rejected.`;

      await adminClient.from("notifications").insert({
        notification_id: notificationId,
        user_id: targetUserId,
        type: "role_application",
        title,
        body: note ? `${bodyText}\n\nAdmin note: ${note}` : bodyText,
        entity_id: requestedRole,
        read: false,
        created_at: now.toISOString(),
      });
    } catch (_e) {
      // Best-effort: do not block primary admin action.
    }

    return new Response(JSON.stringify({ ok: true, user: updated }), { status: 200, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
  } catch (e) {
    const detail = formatError(e);
    return new Response(JSON.stringify({ error: "internal_error", detail }), { status: 500, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
  }
});
