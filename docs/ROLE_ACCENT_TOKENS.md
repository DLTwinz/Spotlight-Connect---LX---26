# Role Accent Token Strategy (LOCKED)

**Source of truth:** `lib/theme/spotlight_tokens.dart`

| Role | Token | Hex | Intent |
|------|-------|-----|--------|
| Talent / Creator | `SpotlightTokens.roleTalent` | `#7CFFB2` | Creator OS / growth |
| Business | `SpotlightTokens.roleBusiness` | `#00E5FF` | Brand control (= cyan) |
| Audience | `SpotlightTokens.roleAudience` | `#38BDF8` | Fan / discovery |
| Admin | `SpotlightTokens.roleAdmin` | `#FF6B6B` | Trust / severity |

**Shell:** `shellBg` / `shellPanel` / `shellNav` — shared dark canvas.  
**API:** `context.roleAccent(role)`, `roleShellBackground`, `rolePanelBackground`, `roleNavBackground`.  
**Marketing:** `SpotlightAccents` only on public landing — do not replace role accents.
