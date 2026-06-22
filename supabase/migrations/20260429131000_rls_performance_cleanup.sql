
-- NOTE (Dreamflow): This migration previously used a PL/pgSQL `DO $$ ... $$;` block
-- with dynamic SQL (`EXECUTE format(...)`). Some execution environments (including
-- certain “run SQL query” utilities) split SQL by semicolons and execute fragments
-- individually, which breaks PL/pgSQL and causes:
--   ERROR: 26000: prepared statement "format" does not exist
--
-- This file is therefore intentionally a no-op in this repo.
--
-- If you still want these *optional* RLS policy performance optimizations, run the
-- original script manually via `psql` (or the Supabase CLI migration runner that
-- supports DO blocks) as a single statement.

select 1;
