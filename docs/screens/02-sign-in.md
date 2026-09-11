# Sign in

Route `/sign-in` · unauthenticated · Phase 0

Email and password against Firebase Auth, plus Google and Apple. The repo
already has `firebase_auth_repository.dart` and a `login_controller` — reuse
them; this spec is the visual and behavioural contract, not a rewrite.

## Layout

Single column, `Space.lg` side padding.

1. **Back button** — 44px tap target, chevron, `textSecondary`.
2. **Heading block**, `Space.lg` below:
   - `AppType.displayLarge`: *Welcome back*
   - `AppType.bodyMedium`, `textSecondary`: *Pick up where you left off.*
3. **Fields**, `Space.xl` below the heading, `Space.md` apart:
   - Label in `AppType.label`, `textSecondary`, then a 54px field.
   - Field: `raised` fill, `Radii.cardR`, 1px `line` border → `accent` 1.5px
     on focus. Placeholder `textTertiary`.
   - Email: keyboard `emailAddress`, autofill username, no autocorrect.
   - Password: obscured, with a show/hide eye on the right. **The eye needs
     a 44×44 tap target** even though the glyph is 20px.
   - *Forgot password?* right-aligned below, `accentInk`, 44px tall.
4. **Sign in** — 54px primary. Disabled (`raised` fill, `textTertiary`
   label) until email length > 3 and password length ≥ 6.
5. **Divider** — hairline, `lineSoft`, with "or" in `AppType.monoLabel`
   centred.
6. **Google** and **Apple** — 54px outlined, brand glyph then label. These
   are the only place in the app where off-palette brand colours are allowed.
7. **Footer** — *New here? Create an account*, 44px tall, the link portion
   in `accentInk` semibold.

## States

| State | Behaviour |
|---|---|
| Idle | CTA disabled |
| Ready | CTA enabled |
| Submitting | CTA shows a small spinner, fields read-only, no layout shift |
| Error | Message under the offending field in `caution` — **not** `alert` |

Error copy names what to do: *"That password doesn't match this email."*
Never "Invalid credentials". Never reveal whether the email exists.

## Data

`POST` nothing of our own — Firebase Auth SDK handles it. On success, the
router redirects: existing user → `/`, new user → `/onboarding/mode`.
