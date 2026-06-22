// Supabase Edge Function: missions_list
// Returns personalized missions + current objective + progression snapshot.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.45.4";

const CORS_HEADERS = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-max-age": "86400",
};

type MissionRow = {
  id: string;
  title: string;
  subtitle: string;
  description: string;
  mission_type: string;
  icon_key: string;
  target_metric: string;
  target_value: number;
  start_at: string | null;
  end_at: string | null;
  repeat_interval: string | null;
  campaign_id: string | null;
  status: string;
  requirements_json: Record<string, unknown>;
  reward_json: Record<string, unknown>;
  created_at: string;
  updated_at: string;
};

type UserMissionRow = {
  id: string;
  user_id: string;
  mission_id: string;
  status: string;
  progress_value: number;
  progress_target: number;
  started_at: string | null;
  completed_at: string | null;
  claimed_at: string | null;
  expires_at: string | null;
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...CORS_HEADERS, "content-type": "application/json" },
  });
}

function nowIso() {
  return new Date().toISOString();
}

function isoToDateOnly(iso: string) {
  const d = new Date(iso);
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate()));
}

function expiresAtForRepeat(repeat: string | null) {
  if (!repeat) return null;
  const now = new Date();
  if (repeat === "daily") {
    const d = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1));
    return d.toISOString();
  }
  if (repeat === "weekly") {
    // End of current ISO week (Mon..Sun) => next Monday 00:00Z
    const day = (now.getUTCDay() + 6) % 7; // Mon=0
    const nextMon = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - day + 7));
    return nextMon.toISOString();
  }
  return null;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

  const authHeader = req.headers.get("Authorization") ?? "";

  // User client for auth.getUser()
  const userClient = createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authHeader } } });
  const { data: userData, error: userErr } = await userClient.auth.getUser();
  if (userErr || !userData?.user) return json({ error: "Unauthorized" }, 401);
  const userId = userData.user.id;

  const svc = createClient(supabaseUrl, serviceKey);

  const body = await req.json().catch(() => ({}));
  const limit = typeof body.limit === "number" ? Math.min(Math.max(body.limit, 1), 100) : 40;
  const type = typeof body.type === "string" && body.type.length ? body.type : null;

  // Progress snapshot from existing rewards system
  const { data: acct } = await svc
    .from("reward_accounts")
    .select("id, points_balance, status_points, current_tier_id")
    .eq("user_id", userId)
    .maybeSingle();

  const points = acct?.points_balance ?? 0;
  const xp = acct?.status_points ?? 0;
  let tierName = "Starter";
  if (acct?.current_tier_id) {
    const { data: tier } = await svc.from("reward_tiers").select("name").eq("id", acct.current_tier_id).maybeSingle();
    if (tier?.name) tierName = tier.name;
  }

  // Mission definitions
  let q = svc
    .from("missions")
    .select("*")
    .neq("status", "archived")
    .order("created_at", { ascending: false })
    .limit(limit);
  if (type) q = q.eq("mission_type", type);

  const { data: missions, error: mErr } = await q;
  if (mErr) return json({ error: `Failed to load missions: ${mErr.message}` }, 500);

  const missionIds = (missions ?? []).map((m: MissionRow) => m.id);

  // User mission rows
  const { data: userMissions, error: umErr } = await svc
    .from("user_missions")
    .select("*")
    .eq("user_id", userId)
    .in("mission_id", missionIds);
  if (umErr) return json({ error: `Failed to load user missions: ${umErr.message}` }, 500);

  const byMissionId = new Map<string, UserMissionRow>();
  for (const um of userMissions ?? []) {
    // Keep newest per mission (daily repeats create multiple rows with expires_at)
    const prev = byMissionId.get(um.mission_id);
    if (!prev) {
      byMissionId.set(um.mission_id, um);
      continue;
    }
    const a = prev.expires_at ?? "";
    const b = um.expires_at ?? "";
    if (b > a) byMissionId.set(um.mission_id, um);
  }

  // Compute minimal progress for certain metrics using existing tables.
  // This is intentionally simple + deterministic for v1.
  async function computeProgress(m: MissionRow): Promise<{ value: number; target: number; status: string; cta: string }> {
    const target = m.target_value ?? 0;
    const metric = (m.target_metric ?? "").toLowerCase();

    // Default: rely on stored progress if exists
    const um = byMissionId.get(m.id);
    const storedValue = um?.progress_value ?? 0;
    const storedTarget = um?.progress_target ?? (target || 0);

    // If mission is locked/archived
    if (m.status === "archived") return { value: 0, target: storedTarget, status: "archived", cta: "" };

    // If already completed/claimable
    if (um?.claimed_at) return { value: storedTarget, target: storedTarget, status: "completed", cta: "Completed" };
    if (um?.status === "claimable") return { value: storedTarget, target: storedTarget, status: "claimable", cta: "Claim" };

    // Time window check
    const now = new Date();
    if (m.end_at && new Date(m.end_at) < now) return { value: storedValue, target: storedTarget, status: "expired", cta: "Expired" };
    if (m.start_at && new Date(m.start_at) > now) return { value: 0, target: storedTarget, status: "locked", cta: "Locked" };

    // Derive progress by metric
    try {
      if (metric === "posts_created") {
        const { count } = await svc.from("posts").select("id", { count: "exact", head: true }).eq("author_id", userId);
        const v = Math.min(count ?? 0, target);
        const done = target > 0 && v >= target;
        return { value: v, target, status: done ? "claimable" : (um ? "active" : "available"), cta: done ? "Claim" : (um ? "Continue" : "Start") };
      }

      if (metric === "comments_written") {
        const { count } = await svc.from("post_comments").select("id", { count: "exact", head: true }).eq("author_id", userId);
        const v = Math.min(count ?? 0, target);
        const done = target > 0 && v >= target;
        return { value: v, target, status: done ? "claimable" : (um ? "active" : "available"), cta: done ? "Claim" : (um ? "Continue" : "Start") };
      }

      if (metric === "campaign_join") {
        // Joined any campaign
        const { count } = await svc
          .from("campaign_participants")
          .select("id", { count: "exact", head: true })
          .eq("user_id", userId)
          .neq("status", "left");
        const v = Math.min(count ?? 0, target);
        const done = target > 0 && v >= target;
        return { value: v, target, status: done ? "claimable" : (um ? "active" : "available"), cta: done ? "Claim" : "Browse" };
      }

      if (metric === "profile_complete") {
        // Simple profile completion heuristic: has username + bio
        const { data: profile } = await svc.from("profiles").select("username, bio").eq("user_id", userId).maybeSingle();
        const score = (profile?.username ? 50 : 0) + (profile?.bio ? 50 : 0);
        const v = Math.min(score, 100);
        const done = v >= (target || 100);
        return { value: v, target: target || 100, status: done ? "claimable" : (um ? "active" : "available"), cta: done ? "Claim" : "Complete" };
      }
    } catch (_) {
      // fall through
    }

    // Fallback: stored progress
    const v = Math.min(storedValue, storedTarget);
    const done = storedTarget > 0 && v >= storedTarget;
    return { value: v, target: storedTarget, status: done ? "claimable" : (um ? "active" : "available"), cta: done ? "Claim" : (um ? "Continue" : "Start") };
  }

  const enriched: any[] = [];
  for (const m of missions ?? []) {
    const p = await computeProgress(m);
    const um = byMissionId.get(m.id);
    const expiresAt = um?.expires_at ?? expiresAtForRepeat(m.repeat_interval ?? null);

    enriched.push({
      mission: m,
      user_mission: um ?? null,
      computed: {
        progress_value: p.value,
        progress_target: p.target,
        status: p.status,
        cta: p.cta,
        expires_at: expiresAt,
      },
    });
  }

  // Current objective: first claimable else first active else first available
  const objective = enriched.find((x) => x.computed.status === "claimable")
    ?? enriched.find((x) => x.computed.status === "active")
    ?? enriched.find((x) => x.computed.status === "available")
    ?? null;

  return json({
    ok: true,
    generated_at: nowIso(),
    progression: { xp, points, tier_name: tierName },
    objective,
    items: enriched,
  });
});
