-- =============================================================================
-- Spotlight Connect — Attribution Summary Views
-- File: spotlight_connect_attribution_views.sql
-- =============================================================================

-- =============================================================================
-- SECTION 1 — RLS POLICIES
-- =============================================================================

DROP POLICY IF EXISTS brands_read_own_bookings ON public.bookings;
CREATE POLICY brands_read_own_bookings
  ON public.bookings
  FOR SELECT
  USING (brand_id = auth.uid() OR creator_id = auth.uid());

DROP POLICY IF EXISTS users_read_own_transactions ON public.transactions;
CREATE POLICY users_read_own_transactions
  ON public.transactions
  FOR SELECT
  USING (brand_id = auth.uid() OR creator_id = auth.uid());

DROP POLICY IF EXISTS users_read_own_reviews ON public.reviews;
CREATE POLICY users_read_own_reviews
  ON public.reviews
  FOR SELECT
  USING (reviewer_id = auth.uid() OR reviewee_id = auth.uid());

-- =============================================================================
-- SECTION 2 — brand_attribution_summary VIEW
-- =============================================================================

DROP VIEW IF EXISTS public.brand_attribution_summary;

CREATE OR REPLACE VIEW public.brand_attribution_summary
  WITH (security_invoker = true)
AS
WITH booking_stats AS (
  SELECT
    b.brand_id,
    COUNT(*) AS total_bookings,
    COUNT(*) FILTER (WHERE b.status = 'completed') AS completed_bookings,
    COUNT(*) FILTER (WHERE b.status = 'cancelled') AS cancelled_bookings,
    COUNT(*) FILTER (WHERE b.status = 'disputed') AS disputed_bookings,
    COUNT(*) FILTER (WHERE b.status IN ('pending','active')) AS active_bookings,
    COUNT(DISTINCT b.creator_id) AS unique_creators_worked_with,
    COALESCE(SUM(b.agreed_rate) FILTER (WHERE b.status = 'completed'), 0) AS total_spend,
    COALESCE(SUM(b.platform_fee) FILTER (WHERE b.status = 'completed'), 0) AS total_platform_fees_paid,
    COALESCE(AVG(b.agreed_rate) FILTER (WHERE b.status = 'completed'), 0) AS avg_deal_value,
    COALESCE(MAX(b.agreed_rate) FILTER (WHERE b.status = 'completed'), 0) AS highest_deal_value,
    COALESCE(MIN(b.agreed_rate) FILTER (WHERE b.status = 'completed'), 0) AS lowest_deal_value,
    MIN(b.created_at) AS first_booking_date,
    MAX(b.created_at) AS most_recent_booking_date,
    MAX(b.completed_at) AS last_completed_booking_date
  FROM public.bookings b
  GROUP BY b.brand_id
),
top_category AS (
  SELECT DISTINCT ON (b.brand_id)
    b.brand_id,
    p.primary_category AS top_category,
    COUNT(*) AS cat_count
  FROM public.bookings b
  JOIN public.profiles p ON p.id = b.creator_id
  WHERE b.status = 'completed'
  GROUP BY b.brand_id, p.primary_category
  ORDER BY b.brand_id, cat_count DESC
),
review_stats AS (
  SELECT
    b.brand_id,
    COALESCE(AVG(r.rating), 0) AS avg_rating_given_by_creators,
    COUNT(r.id) AS total_reviews_received
  FROM public.bookings b
  LEFT JOIN public.reviews r
    ON r.booking_id = b.id
   AND r.reviewee_id = b.brand_id
  GROUP BY b.brand_id
)
SELECT
  bs.brand_id,
  p.display_name AS brand_name,
  p.verified_tier AS brand_verification_tier,
  bs.total_bookings,
  bs.completed_bookings,
  bs.cancelled_bookings,
  bs.disputed_bookings,
  bs.active_bookings,
  bs.unique_creators_worked_with,
  bs.total_spend,
  bs.total_platform_fees_paid,
  ROUND(bs.avg_deal_value::NUMERIC, 2) AS avg_deal_value,
  bs.highest_deal_value,
  bs.lowest_deal_value,
  tc.top_category,
  ROUND(rs.avg_rating_given_by_creators::NUMERIC, 2) AS avg_rating_given_by_creators,
  rs.total_reviews_received,
  bs.first_booking_date,
  bs.most_recent_booking_date,
  bs.last_completed_booking_date,
  CASE
    WHEN bs.total_bookings = 0 THEN 0
    ELSE ROUND((bs.completed_bookings::NUMERIC / bs.total_bookings) * 100, 1)
  END AS completion_rate_pct,
  NOW() AS summary_generated_at
FROM booking_stats bs
JOIN public.profiles p ON p.id = bs.brand_id
LEFT JOIN top_category tc ON tc.brand_id = bs.brand_id
LEFT JOIN review_stats rs ON rs.brand_id = bs.brand_id;

COMMENT ON VIEW public.brand_attribution_summary IS
  'Aggregated attribution metrics per brand. Uses security_invoker=true — RLS on underlying tables is automatically enforced.';

-- =============================================================================
-- SECTION 3 — creator_attribution_summary VIEW
-- =============================================================================

DROP VIEW IF EXISTS public.creator_attribution_summary;

CREATE OR REPLACE VIEW public.creator_attribution_summary
  WITH (security_invoker = true)
AS
WITH booking_stats AS (
  SELECT
    b.creator_id,
    COUNT(*) AS total_bookings,
    COUNT(*) FILTER (WHERE b.status = 'completed') AS completed_bookings,
    COUNT(*) FILTER (WHERE b.status = 'cancelled') AS cancelled_bookings,
    COUNT(*) FILTER (WHERE b.status = 'disputed') AS disputed_bookings,
    COUNT(*) FILTER (WHERE b.status IN ('pending','active')) AS active_bookings,
    COUNT(DISTINCT b.brand_id) AS unique_brands_worked_with,
    COALESCE(SUM(b.creator_payout) FILTER (WHERE b.status = 'completed'), 0) AS total_earnings,
    COALESCE(SUM(b.agreed_rate) FILTER (WHERE b.status = 'completed'), 0) AS total_gross_deal_value,
    COALESCE(AVG(b.creator_payout) FILTER (WHERE b.status = 'completed'), 0) AS avg_earnings_per_deal,
    COALESCE(MAX(b.creator_payout) FILTER (WHERE b.status = 'completed'), 0) AS highest_single_payout,
    COALESCE(SUM(b.agreed_rate) FILTER (WHERE b.status IN ('pending','active')), 0) AS pipeline_value,
    MIN(b.created_at) AS first_booking_date,
    MAX(b.created_at) AS most_recent_booking_date,
    MAX(b.completed_at) AS last_completed_booking_date
  FROM public.bookings b
  GROUP BY b.creator_id
),
top_category AS (
  SELECT DISTINCT ON (b.creator_id)
    b.creator_id,
    p.primary_category AS top_booked_category,
    COUNT(*) AS cat_count
  FROM public.bookings b
  JOIN public.profiles p ON p.id = b.brand_id
  WHERE b.status = 'completed'
  GROUP BY b.creator_id, p.primary_category
  ORDER BY b.creator_id, cat_count DESC
),
review_stats AS (
  SELECT
    b.creator_id,
    COALESCE(AVG(r.rating), 0) AS avg_rating_from_brands,
    COUNT(r.id) AS total_reviews_received
  FROM public.bookings b
  LEFT JOIN public.reviews r
    ON r.booking_id = b.id
   AND r.reviewee_id = b.creator_id
  GROUP BY b.creator_id
)
SELECT
  bs.creator_id,
  p.display_name AS creator_name,
  p.username AS creator_username,
  p.verified_tier AS creator_verification_tier,
  p.primary_category AS creator_category,
  bs.total_bookings,
  bs.completed_bookings,
  bs.cancelled_bookings,
  bs.disputed_bookings,
  bs.active_bookings,
  bs.unique_brands_worked_with,
  bs.total_earnings,
  bs.total_gross_deal_value,
  ROUND(bs.avg_earnings_per_deal::NUMERIC, 2) AS avg_earnings_per_deal,
  bs.highest_single_payout,
  tc.top_booked_category,
  ROUND(rs.avg_rating_from_brands::NUMERIC, 2) AS avg_rating_from_brands,
  rs.total_reviews_received,
  CASE
    WHEN bs.total_bookings = 0 THEN 0
    ELSE ROUND((bs.completed_bookings::NUMERIC / bs.total_bookings) * 100, 1)
  END AS completion_rate_pct,
  bs.first_booking_date,
  bs.most_recent_booking_date,
  bs.last_completed_booking_date,
  bs.pipeline_value,
  NOW() AS summary_generated_at
FROM booking_stats bs
JOIN public.profiles p ON p.id = bs.creator_id
LEFT JOIN top_category tc ON tc.creator_id = bs.creator_id
LEFT JOIN review_stats rs ON rs.creator_id = bs.creator_id;

COMMENT ON VIEW public.creator_attribution_summary IS
  'Aggregated attribution metrics per creator. Uses security_invoker=true — RLS on underlying tables is automatically enforced.';

-- =============================================================================
-- SECTION 4 — OPTIONAL GRANTS / SMOKE TESTS
-- =============================================================================

-- GRANT SELECT ON public.brand_attribution_summary TO authenticated;
-- GRANT SELECT ON public.creator_attribution_summary TO authenticated;

-- SELECT brand_id, brand_name, total_spend, completion_rate_pct, summary_generated_at
-- FROM public.brand_attribution_summary
-- LIMIT 5;

-- SELECT creator_id, creator_name, total_earnings, pipeline_value, completion_rate_pct
-- FROM public.creator_attribution_summary
-- LIMIT 5;