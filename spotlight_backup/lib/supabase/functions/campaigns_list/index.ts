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

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

  const authHeader = req.headers.get("Authorization") ?? "";
  const userClient = createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authHeader } } });
  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData?.user) return json({ error: "Unauthorized" }, 401);
  const userId = userData.user.id;

  const svc = createClient(supabaseUrl, serviceKey);
  const body = await req.json().catch(() => ({}));
  const limit = typeof body.limit === "number" ? Math.min(Math.max(body.limit, 1), 50) : 30;

  const { data: campaigns, error: cErr } = await svc
    .from("campaigns")
    .select("id, title, description, status, start_date, end_date, start_at, end_at, featured_rank, eligibility_json, reward_json, business_user_id, budget_range, created_at, updated_at")
    .neq("status", "archived")
    .order("featured_rank", { ascending: true, nullsFirst: false })
    .order("created_at", { ascending: false })
    .limit(limit);
  if (cErr) return json({ error: cErr.message }, 500);

  const campaignIds = (campaigns ?? []).map((c: any) => c.id);

  const { data: mine } = await svc
    .from("campaign_participants")
    .select("campaign_id, status, participant_role, created_at, updated_at")
    .eq("user_id", userId)
    .in("campaign_id", campaignIds);

  const byId = new Map<string, any>();
  for (const row of mine ?? []) byId.set(row.campaign_id, row);

  const items = (campaigns ?? []).map((c: any) => ({
    campaign: c,
    me: byId.get(c.id) ?? null,
  }));

  return json({ ok: true, items });
});
