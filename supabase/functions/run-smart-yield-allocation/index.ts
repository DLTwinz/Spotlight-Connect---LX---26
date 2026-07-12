// supabase/functions/run-smart-yield-allocation/index.ts+
import type { Context } from "https://deno.land/x/supabase@v1/mod.ts";

type ScoreInputs = {
  margin_efficiency_index: number;
  verified_supporter_density: number;
  retention_yield_score: number;
  dispute_adjusted_proof_confidence: number;
  campaign_fit_score: number;
  sovereign_concentration_index: number;
};

export default async (req: Request, _ctx: Context): Promise<Response> => {
  try {
    const body = (await req.json()) as ScoreInputs;

    const {
      margin_efficiency_index,
      verified_supporter_density,
      retention_yield_score,
      dispute_adjusted_proof_confidence,
      campaign_fit_score,
      sovereign_concentration_index,
    } = body;

    const creator_score =
      0.25 * margin_efficiency_index +
      0.20 * verified_supporter_density +
      0.15 * retention_yield_score +
      0.20 * dispute_adjusted_proof_confidence +
      0.10 * campaign_fit_score +
      0.10 * sovereign_concentration_index;

    return new Response(
      JSON.stringify({ creator_score }),
      { status: 200, headers: { "content-type": "application/json" } },
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: "Invalid payload", details: String(e) }),
      { status: 400, headers: { "content-type": "application/json" } },
    );
  }
};