// Supabase Edge Function: create_livekit_token
// Mints a LiveKit access token for a given room.
//
// Secrets required (set in Supabase module):
// - LIVEKIT_API_KEY
// - LIVEKIT_API_SECRET
// Optional:
// - LIVEKIT_URL (can also be provided by the client via SPOTLIGHT_LIVEKIT_URL)

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { create, getNumericDate, Header, Payload } from "https://deno.land/x/djwt@v3.0.2/mod.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const CORS_HEADERS: Record<string, string> = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-max-age": "86400",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS_HEADERS, "content-type": "application/json" },
  });
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    if (!supabaseUrl || !anonKey || !serviceRoleKey) {
      return json({ error: "Missing Supabase environment (SUPABASE_URL/ANON_KEY/SERVICE_ROLE_KEY)" }, 500);
    }

    const apiKey = Deno.env.get("LIVEKIT_API_KEY") ?? "";
    const apiSecret = Deno.env.get("LIVEKIT_API_SECRET") ?? "";
    const livekitUrl = Deno.env.get("LIVEKIT_URL") ?? "";

    if (!apiKey || !apiSecret) {
      return json({ error: "Missing LIVEKIT_API_KEY/LIVEKIT_API_SECRET" }, 500);
    }

    // Require an authenticated caller.
    const authHeader = req.headers.get("Authorization") ?? "";
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: auth, error: authErr } = await userClient.auth.getUser();
    if (authErr || !auth?.user) return json({ error: "not_authenticated" }, 401);

    const body = await req.json().catch(() => ({}));
    const room = (body?.room ?? "").toString().trim();
    const identity = (body?.identity ?? "").toString().trim();
    const name = (body?.name ?? "").toString().trim();
    const canPublish = Boolean(body?.canPublish ?? false);
    const canSubscribe = Boolean(body?.canSubscribe ?? true);

    if (!room || !identity) {
      return json({ error: "room and identity are required" }, 400);
    }

    // Prevent minting tokens for another user.
    if (identity !== auth.user.id) {
      return json({ error: "identity_mismatch" }, 403);
    }

    // Publishing is restricted to approved roles (talent/business/admin).
    if (canPublish) {
      const adminClient = createClient(supabaseUrl, serviceRoleKey);
      const { data: userRow, error: userErr } = await adminClient
        .from("users")
        .select("id, approved_roles")
        .eq("id", auth.user.id)
        .maybeSingle();
      if (userErr) throw userErr;
      const approved: string[] = Array.isArray(userRow?.approved_roles)
        ? userRow!.approved_roles
        : [];
      const allowed = approved.includes("admin") || approved.includes("talent") || approved.includes("business");
      if (!allowed) {
        return json({ error: "publish_not_allowed", approved_roles: approved }, 403);
      }
    }

    // LiveKit access token is a JWT signed with API secret.
    // Docs: https://docs.livekit.io/home/get-started/authentication/
    const header: Header = { alg: "HS256", typ: "JWT" };

    const grants: Record<string, unknown> = {
      room,
      roomJoin: true,
      canPublish,
      canSubscribe,
      canPublishData: true,
    };

    const payload: Payload = {
      iss: apiKey,
      sub: identity,
      name,
      nbf: getNumericDate(0),
      exp: getNumericDate(60 * 60), // 1h
      video: grants,
    };

    const key = await crypto.subtle.importKey(
      "raw",
      new TextEncoder().encode(apiSecret),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"],
    );

    const token = await create(header, payload, key);

    return json({ token, url: livekitUrl || null, room, identity, name });
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
