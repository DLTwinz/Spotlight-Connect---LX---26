-- Idempotent grant: client needs this RPC to load feature flags/policies.
-- Safe because function is SECURITY INVOKER and returns only aggregated flags.

DO $$
BEGIN
  GRANT EXECUTE ON FUNCTION public.get_feature_policy(text) TO anon, authenticated;
EXCEPTION
  WHEN undefined_function THEN
    -- If the function doesn't exist in a given environment, skip.
    NULL;
END $$;
