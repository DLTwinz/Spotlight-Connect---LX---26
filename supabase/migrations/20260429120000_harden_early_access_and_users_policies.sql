-- Launch hardening: remove permissive RLS policies flagged by Supabase linter.

-- early_access_requests: constrain open inserts for waitlist submissions.
DROP POLICY IF EXISTS "early_access_insert_anyone" ON public.early_access_requests;
CREATE POLICY "early_access_insert_anyone" ON public.early_access_requests
  FOR INSERT TO anon, authenticated
  WITH CHECK (
    status = 'pending'
    AND COALESCE(review_note, '') = ''
    AND email IS NOT NULL
    AND length(trim(email)) BETWEEN 5 AND 320
    AND position('@' in email) > 1
    AND NOT EXISTS (
      SELECT 1 FROM public.early_access_requests r
      WHERE lower(r.email) = lower(early_access_requests.email)
    )
  );

-- users: clients may only create/update their own user row.
DROP POLICY IF EXISTS "users_insert_any" ON public.users;
CREATE POLICY "users_insert_any" ON public.users
  FOR INSERT TO authenticated
  WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS "users_update_any" ON public.users;
CREATE POLICY "users_update_any" ON public.users
  FOR UPDATE TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());
