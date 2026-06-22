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

async function isAdmin(svc: any, userId: string) {
  const { data } = await svc.from("users").select("active_role, approved_roles").eq("id", userId).maybeSingle();
  if (!data) return false;
  if (data.active_role === "admin") return true;
  const roles = (data.approved_roles ?? []) as string[];
  return roles.includes("admin");
}

async function ensureRewardAccount(svc: any, userId: string) {
  const { data: existing } = await svc
    .from("reward_accounts")
    .select("id, points_balance, status_points")
    .eq("user_id", userId)
    .maybeSingle();
  if (existing) return existing;
  const { data: created, error } = await svc
    .from("reward_accounts")
    .insert({ user_id: userId, points_balance: 0, status_points: 0 })
    .select("id, points_balance, status_points")
    .single();
  if (error) throw new Error(error.message);
  return created;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: CORS_HEADERS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;

  const authHeader = req.headers.get("Authorization") ?? "";
  const userClient = createClient(supabaseUrl, anonKey, { global: { headers: { Authorization: authHeader } } });
  const { data: userData } = await userClient.auth.getUser();
  if (!userData?.user) return json({ error: "Unauthorized" }, 401);
  const adminId = userData.user.id;

  const svc = createClient(supabaseUrl, serviceKey);
  if (!(await isAdmin(svc, adminId))) return json({ error: "Forbidden" }, 403);

  const body = await req.json().catch(() => ({}));
  const targetUserId = (body.user_id ?? "").toString();
  const pointsAdd = Number(body.points ?? 0) || 0;
  const xpAdd = Number(body.status_points ?? 0) || 0;
  const reason = (body.reason ?? "").toString();
  if (!targetUserId) return json({ error: "user_id is required" }, 400);
  if (!reason) return json({ error: "reason is required" }, 400);

  try {
    const acct = await ensureRewardAccount(svc, targetUserId);
    const newPoints = (acct.points_balance ?? 0) + pointsAdd;
    const newXp = (acct.status_points ?? 0) + xpAdd;

    await svc.from("reward_accounts").update({ points_balance: newPoints, status_points: newXp, updated_at: new Date().toISOString() }).eq("id", acct.id);

    if (pointsAdd !== 0) {
      await svc.from("reward_transactions").insert({
        reward_account_id: acct.id,
        user_id: targetUserId,
        transaction_type: "points",
        source_type: "admin_grant",
        source_id: null,
        points_amount: pointsAdd,
      });
    }
    if (xpAdd !== 0) {
      await svc.from("reward_transactions").insert({
        reward_account_id: acct.id,
        user_id: targetUserId,
        transaction_type: "xp",
        source_type: "admin_grant",
        source_id: null,
        points_amount: xpAdd,
      });
    }

    await svc.from("admin_audit_log").insert({
      admin_user_id: adminId,
      action: "admin_grant_reward",
      target_type: "user",
      target_id: targetUserId,
      payload_json: { reason, points: pointsAdd, status_points: xpAdd },
    });

    return json({ ok: true, balances: { points: newPoints, xp: newXp } });
  } catch (e) {
    return json({ error: (e as Error).message ?? "Grant failed" }, 500);
  }
});
