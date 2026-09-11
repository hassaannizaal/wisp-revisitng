# Home

Route `/` · authenticated · Phase 1

The hub. Everything reaches everything else from here.

## Layout

Fixed header, scrolling body, fixed tab bar.

### Header (fixed)

- Date in `AppType.monoLabel`, `textTertiary` — *Thursday · 11 Sep*
- Greeting in `AppType.displayMedium` — *Good evening, {firstName}*.
  Morning / afternoon / evening by local clock.
- **Mode badge**, left-aligned below. See `CLAUDE.md`. Independent:
  `accent`, "Private · only you". Organization: `caution`, "Visible ·
  {orgName}". This badge is not optional and does not scroll away.

### Body (scrolls), sections `Space.lg` apart

**Today** — `AppType.monoLabel` section key, then:

- A `raised` card, `Radii.cardR`: prompt in `AppType.voice`-weight display
  (*"How are you arriving today?"*), and an inline 5-across mood row.
  Each cell 62px tall, face icon + label. Tapping one logs the mood
  immediately and the prompt becomes *"Logged as {mood}. Want to write
  about it?"* — no confirm step, no modal.
- Two stat tiles side by side: **Water** `5 / 8`, **Streak** `14 days`
  (the number in `positive` when the streak is unbroken). Numerals in
  `AppType.numeric` or the display serif — never the UI sans.

**Talk it through** — the therapist card. `ember` border, `emberDim` fill,
a 46px ember orb, a title and one line of `AppType.voiceBody` in `ember`.
While the AI layer is deferred this routes to a placeholder; keep the card,
it is the product's centrepiece.

**Your practice** — a 2-column grid of module cards, `Space.sm` gap. Each:
20px `accent` stroke icon, name in `AppType.label` size 14 semibold, one
line of context in `textSecondary`. Minimum 96px tall.

Journal · Sedona · Mindfulness · Water · Dashboard · Music · Circles ·
Resources. Cards for unbuilt modules route to a placeholder — do not hide
them.

**Crisis** — last in the scroll, full width, 52px, `Radii.live`, `alert`
border on `alertDim`, shield icon, *"I need help now"*. Opens the crisis
sheet. No animation on the open (`Motion.none`).

### Tab bar (fixed)

`surface` background, `lineSoft` top border, four items, 48px each:
Home · WISP · Circles · You. Active in `accent` semibold, inactive
`textTertiary`.

## Crisis sheet

Full-screen scrim at 94% `ground`, sheet anchored to the bottom with
`Radii.sheetR` and a 2px `alert` top border. Renders on the same frame as
the tap.

- `AppType.displayMedium`: *You are not on your own*
- `textSecondary`: *"Pick whichever is easiest right now. Nothing here needs
  an explanation from you."*
- Three 58px rows: **call the regional crisis line** (`alert` fill, white
  text, number and hours as a subtitle), **message a counsellor** (`ember`),
  **breathe with me first** (outlined).
- A disclosure line above a `lineSoft` rule, and this is the important part:
  - Organization mode, `caution`: *"Because this is a {org} account, using
    this screen tells your counselling office that you did, and shares your
    location with them."*
  - Independent mode, `textTertiary`: *"Nothing on this screen is shared
    with anyone. Your location stays on your phone unless you choose to send
    it."*
- *Go back*, 50px, `textSecondary`.

**The crisis numbers and this sheet must render from local storage.** Cache
them at login. If this screen needs a network round trip it fails exactly
when it matters — bad signal, 2am, low battery. Logging the event and
notifying an admin are async and may retry; the help itself may not wait.

## Data

Reads: today's mood log, today's water total, current streak, org membership.
Writes: a mood log, from the inline row.
All reads hit the local store first and reconcile with the server behind it —
the user never waits on the network to see their own data.
