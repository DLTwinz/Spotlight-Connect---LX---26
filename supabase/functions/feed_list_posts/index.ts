// Supabase Edge Function: feed_list_posts
// Returns a minimal posts feed with author information.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS: Record<string, string> = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, x-client-info, apikey, content-type",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-max-age": "86400",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { headers: CORS_HEADERS });
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...CORS_HEADERS, "content-type": "application/json" },
    });
  }

  try {
    const { limit } = (await req.json().catch(() => ({}))) as { limit?: number };
    const safeLimit = Math.min(Math.max(Number(limit ?? 75), 1), 150);

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    // Minimal join to avoid recursive embeddings/policies.
    const { data, error } = await supabaseAdmin
      .from("posts")
      .select(
        "id, author_id, group_id, text, tags, repost_of_post_id, like_count, comment_count, repost_count, created_at, updated_at, author:users!posts_author_id_fkey(id, display_name, username, active_role, base_role)",
      )
      .order("created_at", { ascending: false })
      .limit(safeLimit);

    if (error) {
      return new Response(JSON.stringify({ error: error.message, code: error.code, details: error.details }), {
        status: 500,
        headers: { ...CORS_HEADERS, "content-type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ data: data ?? [] }), {
      status: 200,
      headers: { ...CORS_HEADERS, "content-type": "application/json" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...CORS_HEADERS, "content-type": "application/json" },
    });
  }
});
