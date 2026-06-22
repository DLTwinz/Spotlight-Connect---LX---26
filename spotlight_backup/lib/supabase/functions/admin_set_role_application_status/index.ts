// supabase edge function: admin_set_role_application_status
// Admin-only: sets a role application's status (e.g., needs_more_info) and review_note.

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
  status?: string; // pending | needs_more_info | approved | rejected
  note?: string;
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
  // Different installs may have different users columns. Attempt update; if the
  // schema doesn't support some columns, fall back to a minimal update.
  try {
    return await adminClient.from("users").update(payload).eq("id", userId).select("id").maybeSingle();
  } catch (_e) {
    const minimal: Record<string, unknown> = {};
    for (const k of ["updated_at"]) {
      if (k in payload) minimal[k] = payload[k];
    }
    return await adminClient.from("users").update(minimal).eq("id", userId).select("id").maybeSingle();
  }
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "method_not_allowed" }), {
      status: 405,
      headers: { ...CORS_HEADERS, "content-type": "application/json" },
    });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    // Prefer custom secret without SUPABASE_ prefix.
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
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: auth, error: authErr } = await userClient.auth.getUser();
    if (authErr || !auth?.user) {
      return new Response(JSON.stringify({ error: "not_authenticated" }), {
        status: 401,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    const body = (await req.json().catch(() => ({}))) as Body;
    const targetUserId = (body.user_id ?? "").trim();
    const requestedRole = (body.requested_role ?? "").trim();
    const status = (body.status ?? "").trim();
    const note = (body.note ?? "").trim();

    const allowedRoles = new Set(["talent", "business", "admin"]);
    const allowedStatuses = new Set(["pending", "needs_more_info", "approved", "rejected"]);

    if (!targetUserId) {
      return new Response(JSON.stringify({ error: "missing_user_id" }), {
        status: 400,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }
    if (!allowedRoles.has(requestedRole)) {
      return new Response(JSON.stringify({ error: "invalid_requested_role" }), {
        status: 400,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }
    if (!allowedStatuses.has(status)) {
      return new Response(JSON.stringify({ error: "invalid_status" }), {
        status: 400,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    // Check caller is approved admin.
    const { data: caller, error: callerErr } = await adminClient
      .from("users")
      .select("id, approved_roles")
      .eq("id", auth.user.id)
      .maybeSingle();
    if (callerErr) throw callerErr;

    const callerApproved: string[] = caller && Array.isArray((caller as any).approved_roles)
      ? (caller as any).approved_roles
      : [];

    if (!callerApproved.includes("admin")) {
      return new Response(JSON.stringify({ error: "not_admin" }), {
        status: 403,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    // Different installs use slightly different columns.
    // We first try to write review metadata; if the schema doesn't include these
    // columns, fall back to updating only the status so the item leaves the
    // pending queue.
    let updated: unknown = null;
    try {
      const fullUpdate = {
        status,
        reviewed_at: new Date().toISOString(),
        review_note: note || null,
        reviewed_by: auth.user.id,
      };

      const { data, error } = await adminClient
        .from("role_applications")
        .update(fullUpdate)
        .eq("user_id", targetUserId)
        .eq("requested_role", requestedRole)
        .select("user_id, requested_role, status")
        .maybeSingle();
      if (error) throw error;
      updated = data;
    } catch (_e) {
      const { data, error } = await adminClient
        .from("role_applications")
        .update({ status })
        .eq("user_id", targetUserId)
        .eq("requested_role", requestedRole)
        .select("user_id, requested_role, status")
        .maybeSingle();
      if (error) throw error;
      updated = data;
    }

    // Best-effort: keep the applicant's users row in sync for launch checks.
    // - needs_more_info/pending => treat as pending for summary
    // - approved/rejected are typically handled by admin_review_role_application,
    //   but we still attempt to reflect it if this function is used.
    try {
      const summary = status === "needs_more_info" || status === "pending" ? "pending" : status;
      await bestEffortUpdateUser(adminClient, targetUserId, {
        application_status_summary: summary,
        requested_role_pending: status === "approved" || status === "rejected" ? null : requestedRole,
        updated_at: new Date().toISOString(),
      });
    } catch (_e) {
      // Best-effort.
    }

    // Server-side notification to the target user.
    try {
      const now = new Date();
      const notificationId = `n_${now.getTime()}_${Math.floor(Math.random() * 100000)}`;

      let title = "Role application update";
      let bodyMsg = `Your ${requestedRole} role application status is now: ${status}.`;
      if (status === "needs_more_info") {
        title = "Action needed";
        bodyMsg = `Your ${requestedRole} role application needs more info.`;
      }

      await adminClient.from("notifications").insert({
        notification_id: notificationId,
        user_id: targetUserId,
        type: "role_application",
        title,
        body: note ? `${bodyMsg}\n\nAdmin note: ${note}` : bodyMsg,
        entity_id: requestedRole,
        read: false,
        created_at: now.toISOString(),
      });
    } catch (_e) {
      // Best-effort.
    }

    return new Response(JSON.stringify({ ok: true, application: updated }), {
      status: 200,
      headers: { ...CORS_HEADERS, "content-type": "application/json" },
    });
  } catch (e) {
    const detail = formatError(e);
    return new Response(JSON.stringify({ error: "internal_error", detail }), { status: 500, headers: { ...CORS_HEADERS, "content-type": "application/json" } });
  }
});
