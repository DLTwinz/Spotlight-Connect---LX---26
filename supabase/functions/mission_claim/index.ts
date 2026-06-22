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

function roleKeyFromActiveRole(activeRole: string | null | undefined) {
  const r = (activeRole ?? "").toLowerCase();
  if (r === "audience" || r === "supporter") return "supporter";
  if (r === "talent" || r === "creator") return "creator";
  if (r === "business" || r === "brand") return "brand";
  if (r === "admin") return "admin";
  return "unknown";
}

async function loadProgressionPolicyFlags(svc: any, roleKey: string) {
  // Prefer the stable RPC contract.
  try {
    const { data, error } = await svc.rpc("get_feature_policy", { role: roleKey });
    if (!error && data && typeof data === "object") {
      const rawFlags = (data as any).flags;
      const flags: Record<string, boolean> = {};
      if (rawFlags && typeof rawFlags === "object") {
        for (const [k, v] of Object.entries(rawFlags)) {
          if (typeof v === "boolean") flags[k] = v;
          else if (typeof v === "string") flags[k] = v.toLowerCase() === "true";
          else if (typeof v === "number") flags[k] = v !== 0;
        }
      }
      return flags;
    }
  } catch (_) {
    // Fall through to table reads.
  }

  const flags: Record<string, boolean> = {};

  const { data: policyRow } = await svc
    .from("feature_policies")
    .select("policy,is_enabled")
    .eq("role_key", roleKey)
    .maybeSingle();

  const policyEnabled = (policyRow?.is_enabled as boolean | undefined) ?? true;
  const rawPolicy = policyRow?.policy;
  if (policyEnabled && rawPolicy && typeof rawPolicy === "object") {
    for (const [k, v] of Object.entries(rawPolicy)) {
      if (typeof v === "boolean") flags[k] = v;
      else if (typeof v === "string") flags[k] = v.toLowerCase() === "true";
      else if (typeof v === "number") flags[k] = v !== 0;
    }
  }

  const { data: killRows } = await svc.from("kill_switches").select("key,is_enabled");
  if (Array.isArray(killRows)) {
    for (const row of killRows) {
      const key = row?.key?.toString?.();
      if (!key) continue;
      flags[key] = Boolean(row?.is_enabled);
    }
  }
  return flags;
}

async function assertMissionClaimAllowed(svc: any, userId: string) {
  // Safe-by-default: if anything goes wrong loading policy, we block writes.
  try {
    const { data: userRow } = await svc.from("users").select("active_role").eq("id", userId).maybeSingle();
    const roleKey = roleKeyFromActiveRole(userRow?.active_role);
    const flags = await loadProgressionPolicyFlags(svc, roleKey);

    const progressionEnabled = Boolean(flags["progression_enabled"]);
    const missionsEnabled = Boolean(flags["missions_enabled"]);
    const missionClaimsEnabled = Boolean(flags["mission_claims_enabled"]);
    const killAllWrites = Boolean(flags["kill_progression_write_paths"]);
    const killClaims = Boolean(flags["kill_mission_claims"]);
    if (!progressionEnabled) return { ok: false, reason: "Progression disabled" };
    if (!missionsEnabled) return { ok: false, reason: "Missions disabled" };
    if (!missionClaimsEnabled) return { ok: false, reason: "Mission claims disabled" };
    if (killAllWrites) return { ok: false, reason: "Progression writes temporarily disabled" };
    if (killClaims) return { ok: false, reason: "Mission claims temporarily disabled" };
    return { ok: true };
  } catch (_) {
    return { ok: false, reason: "Progression policy unavailable" };
  }
}

async function ensureRewardAccount(svc: any, userId: string) {
  const { data: existing } = await svc
    .from("reward_accounts")
    .select("id, points_balance, status_points, current_tier_id")
    .eq("user_id", userId)
    .maybeSingle();
  if (existing) return existing;

  const { data: created, error } = await svc
    .from("reward_accounts")
    .insert({ user_id: userId, points_balance: 0, status_points: 0 })
    .select("id, points_balance, status_points, current_tier_id")
    .single();
  if (error) throw new Error(error.message);
  return created;
}

async function recomputeTier(svc: any, rewardAccountId: string, statusPoints: number) {
  const { data: tiers } = await svc
    .from("reward_tiers")
    .select("id, name, min_status_points")
    .order("min_status_points", { ascending: true });
  if (!tiers || tiers.length === 0) return null;

  let best = tiers[0];
  for (const t of tiers) {
    if ((t.min_status_points ?? 0) <= statusPoints) best = t;
  }

  await svc.from("reward_accounts").update({ current_tier_id: best.id, updated_at: new Date().toISOString() }).eq("id", rewardAccountId);
  return best;
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

  const body = await req.json().catch(() => ({}));
  const userMissionId = (body.user_mission_id ?? "").toString();
  if (!userMissionId) return json({ error: "user_mission_id is required" }, 400);

  const svc = createClient(supabaseUrl, serviceKey);

  const allow = await assertMissionClaimAllowed(svc, userId);
  if (!allow.ok) return json({ error: allow.reason }, 403);

  const { data: um, error: umErr } = await svc
    .from("user_missions")
    .select("id, user_id, mission_id, status, progress_value, progress_target, claimed_at")
    .eq("id", userMissionId)
    .maybeSingle();
  if (umErr) return json({ error: umErr.message }, 500);
  if (!um) return json({ error: "User mission not found" }, 404);
  if (um.user_id !== userId) return json({ error: "Forbidden" }, 403);
  if (um.claimed_at) return json({ ok: true, already_claimed: true });

  const { data: mission, error: mErr } = await svc
    .from("missions")
    .select("id, title, reward_json, target_value")
    .eq("id", um.mission_id)
    .maybeSingle();
  if (mErr) return json({ error: mErr.message }, 500);
  if (!mission) return json({ error: "Mission not found" }, 404);

  const target = um.progress_target ?? mission.target_value ?? 0;
  const progress = um.progress_value ?? 0;
  if (target > 0 && progress < target) return json({ error: "Mission not complete", progress, target }, 400);

  const reward = (mission.reward_json ?? {}) as Record<string, unknown>;
  const pointsAdd = Number(reward.points ?? 0) || 0;
  const xpAdd = Number(reward.status_points ?? 0) || 0;
  const badgeId = (reward.badge_id ?? "").toString();

  try {
    const acct = await ensureRewardAccount(svc, userId);

    const newPoints = (acct.points_balance ?? 0) + pointsAdd;
    const newXp = (acct.status_points ?? 0) + xpAdd;

    await svc
      .from("reward_accounts")
      .update({ points_balance: newPoints, status_points: newXp, updated_at: new Date().toISOString() })
      .eq("id", acct.id);

    if (pointsAdd !== 0) {
      await svc.from("reward_transactions").insert({
        reward_account_id: acct.id,
        user_id: userId,
        transaction_type: "points",
        source_type: "mission_claim",
        source_id: um.id,
        points_amount: pointsAdd,
      });
    }
    if (xpAdd !== 0) {
      await svc.from("reward_transactions").insert({
        reward_account_id: acct.id,
        user_id: userId,
        transaction_type: "xp",
        source_type: "mission_claim",
        source_id: um.id,
        points_amount: xpAdd,
      });
    }

    if (badgeId) {
      try {
        await svc.from("user_badges").insert({ user_id: userId, badge_id: badgeId });
      } catch (_) {
        // ignore badge conflicts/errors
      }
    }

    const tier = await recomputeTier(svc, acct.id, newXp);

    const { data: updatedUm, error: upErr } = await svc
      .from("user_missions")
      .update({ status: "completed", claimed_at: new Date().toISOString(), completed_at: new Date().toISOString(), updated_at: new Date().toISOString() })
      .eq("id", um.id)
      .select("*")
      .single();
    if (upErr) return json({ error: upErr.message }, 500);

    return json({
      ok: true,
      mission: { id: mission.id, title: mission.title },
      awarded: { points: pointsAdd, xp: xpAdd, badge_id: badgeId || null },
      balances: { points: newPoints, xp: newXp },
      tier: tier ? { id: tier.id, name: tier.name, min_status_points: tier.min_status_points } : null,
      user_mission: updatedUm,
    });
  } catch (e) {
    return json({ error: (e as Error).message ?? "Claim failed" }, 500);
  }
});
