// Supabase Edge Function: check_early_access_status
// Purpose: Keep an anon-callable endpoint for legacy clients while
//          preventing any early-access status disclosure.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

const CORS_HEADERS = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-max-age": "86400",
};

type CheckEarlyAccessStatusRequest = {
  email?: string;
};

type CheckEarlyAccessStatusResponse = {
  found: boolean;
  status: string | null;
  review_note: string | null;
  updated_at: string | null;
  redacted: true;
};

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "method_not_allowed" }), {
      status: 405,
      headers: { ...CORS_HEADERS, "content-type": "application/json" },
    });
  }

  // Parse body but intentionally ignore the email.
  try {
    const _body = (await req.json().catch(() => ({}))) as CheckEarlyAccessStatusRequest;
    // You can keep this endpoint callable by anon for backwards compatibility,
    // but never disclose status. Always return a safe, redacted payload.
    const payload: CheckEarlyAccessStatusResponse = {
      found: false,
      status: null,
      review_note: null,
      updated_at: null,
      redacted: true,
    };

    return new Response(JSON.stringify(payload), {
      status: 200,
      headers: { ...CORS_HEADERS, "content-type": "application/json" },
    });
  } catch (_e) {
    // Even on parse errors, return the same redacted shape to avoid information leaks.
    const payload: CheckEarlyAccessStatusResponse = {
      found: false,
      status: null,
      review_note: null,
      updated_at: null,
      redacted: true,
    };

    return new Response(JSON.stringify(payload), {
      status: 200,
      headers: { ...CORS_HEADERS, "content-type": "application/json" },
    });
  }
});
