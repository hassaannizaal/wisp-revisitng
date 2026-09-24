# WISP LIFE

A mental health app. Flutter frontend, Express 5 API, Firebase Auth.

Read this file before writing any UI. Screen specs are in `docs/screens/`.

---

## Non-negotiable design rules

These exist because the product is used by people in distress, sometimes by
minors under supervision. Breaking one is a correctness bug, not a style
preference.

**1. Coral (`alert`) means crisis and nothing else.**
Never form validation, never a destructive-action button, never decoration.
Form errors use `caution` (already wired into `inputDecorationTheme`). If a
red error trains people to ignore red, the one time it matters they will.

**2. Ember (`ember`) means a voice is speaking to the user.**
The AI therapist, and later a human counsellor. Nothing else — not headings,
not highlights, not a nice accent on a card.

**3. Amber (`caution`) is a privacy disclosure and always names who.**
Wherever amber appears, adjacent text must name the specific person or office
that can see the data — "Visible · Dr. Raza", never "Managed account".
Amber without a name is worse than no amber.

**4. Radius `Radii.live` (999) is reserved** for things that are alive or
urgent: the character orb, the panic button, the mode badge. Nothing static
gets it.

**5. Crisis surfaces never animate.** Use `Motion.none`. A person in crisis
should not watch a 620ms transition play at them. Everywhere else, wrap
durations in `Motion.respecting(context, ...)` so reduce-motion is honoured.

**6. No wellbeing score.** Mood is five named states — low, flat, okay, good,
bright. Never a 1–10 rating, never a composite "wellness number". A score
invites people to optimise it, which is the opposite of the point.

**7. Tap targets are 44px minimum.** Including chips, toggles and icon
buttons.

**8. No fake status bar and no fake keyboard.** The OS draws those.

---

## Design tokens

Never hardcode a colour, font or duration. Everything comes from
`lib/core/theme/`.

```dart
final c = context.wisp;        // WispColors — see app_colors.dart
Text('Save', style: AppType.label.copyWith(color: c.textPrimary))
Container(padding: EdgeInsets.all(Space.base), ...)
BorderRadius r = Radii.cardR;
```

**Colour roles** (`WispColors`, dark + light):

| Token | Means |
|---|---|
| `ground` `surface` `raised` | background planes, low to high |
| `line` `lineSoft` | borders, dividers |
| `textPrimary/Secondary/Tertiary` | text, descending emphasis |
| `accent` `accentInk` `accentDim` | the app's own voice; also "private" |
| `ember` `emberDim` | a voice speaking (rule 2) |
| `caution` `cautionDim` | observed by someone (rule 3) |
| `alert` `alertDim` | crisis (rule 1) |
| `positive` `positiveDim` | streaks, completion, improvement |

**Type** — three faces, three speakers:

- `AppType.display*` / `.voice` / `.voiceBody` — Newsreader. The therapist,
  and the user's own reflections. Nothing else uses the serif.
- `AppType.title*` / `.body*` / `.label` / `.caption` — Manrope. The app.
- `AppType.mono*` / `.numeric` — IBM Plex Mono. The system: timestamps,
  audit lines, admin and governance surfaces.

**Spacing** `Space.xs|sm|md|base|lg|xl|xxl|xxxl` (4/8/12/16/24/32/48/72).
**Radius** `Radii.chip|data|card|sheet|live` (6/10/12/20/999).
**Motion** `Motion.breath|settle|touch|none|cycle`.

Dark-first: `themeMode: ThemeMode.dark` until the user chooses otherwise.

---

## The mode badge

The single most important component. Independent mode and organization mode
are a privacy promise, and a promise the user can't see isn't one.

It appears on **every screen holding personal data** — not just settings.
Two states only:

- Independent: `accent` ring, dot, "Private · only you"
- Organization: `caution` ring, dot, "Visible · <named watcher>"

See `docs/screens/03-account-mode.md` and `04-home.md`.

---

## Architecture

```
frontend/lib/
  core/theme/       tokens — colours, type, spacing, motion (do not bypass)
  core/routing/     go_router
  core/services/    api_client
  core/storage/     local store + local-first sync base
  core/widgets/     shared widgets (mode badge, buttons, orb)
  features/<feature>/
    data/           repositories
    domain/         models
    presentation/   screens + Riverpod controllers
frontend/test/      mirrors lib/ (core/, features/), fakes in support/
backend/src/
  <feature>/        router.js, schema.js (zod), repository.js
  middleware/       auth.js verifies the Firebase ID token
```

Existing conventions worth keeping: the backend mediates every database write
(clients never write directly), every route validates with zod, and each
feature's data access lives in one repository file so the HTTP layer stays
free of database detail.

## Conventions

- Riverpod for state, go_router for navigation — both already in place.
- One feature folder per module; don't cross-import between features.
- Copy is written in the specs. Use it as written — it has been through
  several passes for tone. If something reads wrong, flag it rather than
  rewriting silently.
- Offline-first: IDs are client-generated UUIDs, so a write works with no
  signal and syncs later. Never rely on a server-assigned ID.

## Do not

- Add a package without saying why; the dependency list is deliberately short.
- Introduce a new colour, font or radius outside the token files.
- Build the AI therapist yet — it is deferred. Screens that reference it
  should link to a placeholder route.
- Port code from the older `WISP_MentalHealth_Mobile` repo. Its schema is a
  useful reference; its code is not.
