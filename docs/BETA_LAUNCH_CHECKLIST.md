# SPOTLIGHT Connect — Beta Launch Checklist
Updated: 2026-08-01

## Brand & Visual
- [x] SpotlightTokens locked from DESIRED.WELCOME.PAGE.png
- [x] Landing page uses brand tokens
- [x] Admin dashboard mapped to SpotlightTokens
- [ ] Hero / feature card local assets fully wired (deferred — use Azure assets when ready)
- [ ] Admin dense layout spacing pass vs Figma (partial)

## Auth & Access
- [x] Supabase Auth login path working (credentials fixed)
- [x] Role-based shells: admin / talent / business / audience
- [ ] Role gates enforced at router for every protected route (verify remaining paths)
- [ ] Password reset + email confirm flows smoke-tested

## Admin Console
- [x] Multi-tab RoleDashboardShell with badges
- [x] Live Approvals fetch from `profiles` (pending role requests)
- [x] Approve / Reject optimistic UI + Supabase write (`approvals` table + profile update)
- [x] Badge count seeds from live fetch
- [x] Empty states for Approvals + Flagged
- [ ] Flagged content from real moderation table (still demo list)
- [ ] Shared list state so badge + empty never reset on parent rebuild

## Creator / Brand / Fan
- [x] ProfileTab shows real auth user
- [x] Opportunities / Campaigns from OpportunityService (Supabase)
- [x] FeedTab uses PostService + PostFeedView
- [ ] Discover / Studio / Reels smoke-tested against production data
- [ ] Apply-to-opportunity flow end-to-end

## Quality
- [x] flutter analyze clean (no errors) on changed surfaces
- [ ] Full `flutter analyze` on entire lib/ (optional before tag)
- [ ] Manual smoke: welcome → login → each role dashboard
- [ ] Manual smoke: admin approve/reject with a real pending profile

## Ops / Docs
- [ ] Notion Master Binder updated with this status
- [ ] Google Drive Master Binder copy updated
- [ ] Canva brand template finalized
- [ ] Beta feedback channel decided

## Known deferred
1. Landing local image assets (Azure share download blocked earlier)
2. Admin list state lift (needed for perfect badge sync while clearing rows)
3. Full moderation backend for flagged content
4. Pixel-perfect Figma spacing on every admin card
