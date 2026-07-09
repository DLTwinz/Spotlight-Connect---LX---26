import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    // Parse the incoming request from the Flutter app
    const { admin_id, fan_id, creator_id, brand_id } = await req.json()

    // Strict 4-Pillar Validation
    if (!admin_id || !fan_id || !creator_id || !brand_id) {
      return new Response(
        JSON.stringify({ error: "Validation Failed: All four pillar IDs (Admin, Fan, Creator, Brand) must be present." }),
        { headers: { "Content-Type": "application/json" }, status: 400 }
      )
    }

    // Initialize the secure Supabase Client using backend environment variables
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )

    // Insert into the Attribution Ledger
    const { data, error } = await supabaseClient
      .from('attribution_ledger')
      .insert([{ admin_id, fan_id, creator_id, brand_id }])
      .select()
      .single()

    if (error) throw error

    // Return the successful entry to the mobile app
    return new Response(JSON.stringify(data), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 500,
    })
  }
})
