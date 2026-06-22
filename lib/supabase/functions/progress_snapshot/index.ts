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

  const { data: acct } = await svc
    .from("reward_accounts")
    .select("id, points_balance, status_points, current_tier_id")
    .eq("user_id", userId)
    .maybeSingle();

  const points = acct?.points_balance ?? 0;
  const xp = acct?.status_points ?? 0;

  let tier = null as any;
  if (acct?.current_tier_id) {
    const { data: t } = await svc.from("reward_tiers").select("id, name, description, min_status_points, perks_summary").eq("id", acct.current_tier_id).maybeSingle();
    tier = t ?? null;
  }

  const { data: tiers } = await svc.from("reward_tiers").select("id, name, min_status_points").order("min_status_points", { ascending: true });
  let nextTier = null as any;
  if (tiers && tiers.length) {
    for (const t of tiers) {
      if ((t.min_status_points ?? 0) > xp) {
        nextTier = t;
        break;
      }
    }
  }

  // Mission completion count
  const { count: completedCount } = await svc
    .from("user_missions")
    .select("id", { head: true, count: "exact" })
    .eq("user_id", userId)
    .not("claimed_at", "is", null);

  // Active campaign count
  const { count: activeCampaignCount } = await svc
    .from("campaign_participants")
    .select("id", { head: true, count: "exact" })
    .eq("user_id", userId)
    .eq("status", "active");

  return json({
    ok: true,
    balances: { points, xp },
    tier,
    next_tier: nextTier,
    stats: { missions_completed: completedCount ?? 0, active_campaigns: activeCampaignCount ?? 0 },
  });
});
