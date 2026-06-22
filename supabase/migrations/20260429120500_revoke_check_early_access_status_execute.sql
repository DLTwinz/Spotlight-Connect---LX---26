-- Launch hardening: prevent client roles from executing SECURITY DEFINER RPC.
-- Keep service_role/postgres for internal/admin usage.

REVOKE EXECUTE ON FUNCTION public.check_early_access_status(text) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.check_early_access_status(text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.check_early_access_status(text) FROM authenticated;

GRANT EXECUTE ON FUNCTION public.check_early_access_status(text) TO service_role;
GRANT EXECUTE ON FUNCTION public.check_early_access_status(text) TO postgres;
