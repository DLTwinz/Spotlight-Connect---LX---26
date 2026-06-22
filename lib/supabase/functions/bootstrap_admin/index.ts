// Supabase Edge Function: bootstrap_admin
// Purpose: Permanently restore admin privileges for allowlisted owner/admin accounts.
// This function is SAFE to call on every login; it is idempotent.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-max-age": "86400",
};

// Hard-coded fallback allowlist (in addition to optional env var) to prevent accidental lockouts.
// Keep this list short and owner-controlled.
const FALLBACK_ADMIN_EMAILS = ["bakertwin9@gmail.com"];

function parseCsv(raw: string | undefined | null): string[] {
  if (!raw) return [];
  return raw
    .split(",")
    .map((s) => s.trim().toLowerCase())
    .filter((s) => s.length > 0);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: CORS_HEADERS });

  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader.toLowerCase().startsWith("bearer ")) {
      return new Response(JSON.stringify({ error: "Missing bearer token" }), {
        status: 401,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    const userClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    const { data: userData, error: userErr } = await userClient.auth.getUser();
    if (userErr || !userData?.user) {
      return new Response(JSON.stringify({ error: "Failed to resolve user", details: userErr?.message }), {
        status: 401,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    const user = userData.user;
    const email = (user.email ?? "").trim().toLowerCase();

    const envAllow = parseCsv(Deno.env.get("ADMIN_EMAILS_CSV"));
    const allowlist = new Set<string>([...FALLBACK_ADMIN_EMAILS, ...envAllow]);

    if (!email || !allowlist.has(email)) {
      return new Response(JSON.stringify({ ok: true, allowlisted: false }), {
        status: 200,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    const serviceClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Uses SECURITY DEFINER function (already in your DB) to set base_role/active_role/approved_roles.
    const { error: rpcErr } = await serviceClient.rpc("set_user_admin", {
      p_user_id: user.id,
      p_is_admin: true,
    });

    if (rpcErr) {
      return new Response(JSON.stringify({ ok: false, allowlisted: true, error: rpcErr.message }), {
        status: 500,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ ok: true, allowlisted: true, promoted: true }), {
      status: 200,
      headers: { ...CORS_HEADERS, "content-type": "application/json" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ ok: false, error: String(e) }), {
      status: 500,
      headers: { ...CORS_HEADERS, "content-type": "application/json" },
    });
  }
});
