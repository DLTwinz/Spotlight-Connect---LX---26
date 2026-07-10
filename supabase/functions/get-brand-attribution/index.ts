// supabase/functions/get-creator-attribution/index.ts
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import type { Context } from "https://deno.land/x/supabase@v1/mod.ts";

export default async (req: Request, ctx: Context): Promise<Response> => {
  const url = new URL(req.url);
  const creatorIdParam = url.searchParams.get("creator_id");

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const supabase = createClient(supabaseUrl, supabaseKey);

  const authUser = ctx?.user;
  const creatorId = creatorIdParam ?? authUser?.id ?? null;

  if (!creatorId) {
    return new Response(
      JSON.stringify({ error: "creator_id required or authenticated user missing" }),
      { status: 400, headers: { "content-type": "application/json" } },
    );
  }

  const { data, error } = await supabase
    .from("creator_attribution_summary")
    .select("*")
    .eq("creator_id", creatorId)
    .limit(1)
    .single();

  if (error) {
    return new Response(
      JSON.stringify({ error: "Failed to fetch creator attribution", details: error.message }),
      { status: 500, headers: { "content-type": "application/json" } },
    );
  }

  if (!data) {
    return new Response(
      JSON.stringify({ error: "Creator attribution not found" }),
      { status: 404, headers: { "content-type": "application/json" } },
    );
  }

  return new Response(JSON.stringify(data), {
    status: 200,
    headers: { "content-type": "application/json" },
  });
};