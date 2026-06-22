// Supabase Edge Function: create_monetization_transaction
// Creates a monetization transaction server-side using the service role.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS: Record<string, string> = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-max-age": "86400",
};

type CreateTxBody = {
  type: string;
  to_user_id: string;
  amount_usd: number;
  metadata?: Record<string, unknown> | null;
  // Optional: allow client to provide an id for idempotency, but server can generate.
  transaction_id?: string | null;
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS_HEADERS, "content-type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceRoleKey) {
      return json({ error: "Server misconfigured" }, 500);
    }

    // User-scoped client (to verify JWT)
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const authHeader = req.headers.get("authorization") ?? "";
    if (!anonKey || !authHeader) return json({ error: "Unauthorized" }, 401);

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: authData, error: authError } = await userClient.auth.getUser();
    if (authError || !authData?.user) return json({ error: "Unauthorized" }, 401);

    const fromUserId = authData.user.id;

    let body: CreateTxBody;
    try {
      body = (await req.json()) as CreateTxBody;
    } catch (_) {
      return json({ error: "Invalid JSON" }, 400);
    }

    const type = (body.type ?? "").trim();
    const toUserId = (body.to_user_id ?? "").trim();
    const amountUsd = typeof body.amount_usd === "number" ? body.amount_usd : NaN;

    const allowedTypes = new Set(["tip", "subscription_start", "subscription_cancel"]);
    if (!allowedTypes.has(type)) return json({ error: "Unsupported type" }, 400);
    if (!toUserId) return json({ error: "to_user_id is required" }, 400);
    if (!Number.isFinite(amountUsd) || amountUsd < 0) return json({ error: "Invalid amount_usd" }, 400);
    if (type !== "subscription_cancel" && amountUsd <= 0) return json({ error: "amount_usd must be > 0" }, 400);

    // Service role client (bypasses RLS)
    const adminClient = createClient(supabaseUrl, serviceRoleKey);

    const txId = (body.transaction_id && body.transaction_id.trim().length > 0)
      ? body.transaction_id.trim()
      : crypto.randomUUID();

    const nowIso = new Date().toISOString();

    const insertRow = {
      transaction_id: txId,
      type,
      from_user_id: fromUserId,
      to_user_id: toUserId,
      amount_usd: amountUsd,
      metadata: body.metadata ?? null,
      created_at: nowIso,
      updated_at: nowIso,
    };

    // Idempotent insert: if txId already exists, return existing row.
    const { data: existing, error: existingErr } = await adminClient
      .from("monetization_transactions")
      .select("transaction_id,type,from_user_id,to_user_id,amount_usd,metadata,created_at,updated_at")
      .eq("transaction_id", txId)
      .maybeSingle();

    if (existingErr) return json({ error: existingErr.message }, 500);
    if (existing) return json({ transaction: existing }, 200);

    const { data: inserted, error: insertErr } = await adminClient
      .from("monetization_transactions")
      .insert(insertRow)
      .select("transaction_id,type,from_user_id,to_user_id,amount_usd,metadata,created_at,updated_at")
      .single();

    if (insertErr) return json({ error: insertErr.message }, 500);

    return json({ transaction: inserted }, 200);
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
