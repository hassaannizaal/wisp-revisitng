# Dashboard

Route `/dashboard` · authenticated · Phase 1

Reads everything, writes nothing. Build it after mood, journal and water have
data to show — an empty dashboard teaches you nothing.

## Layout

Fixed header, scrolling body.

### Header

- Back chevron, then `AppType.displayMedium`: *Your patterns*
- **Range chips** — 7 / 14 / 30 days. 44px tall, `Radii.chipR`, mono label.
  Selected: `accent` border, `accentDim` fill, `accentInk` text.

### Body

**Mood chart** — `line` border, `Radii.dataR`.
- Key row: *Mood · {n} days* in `AppType.monoLabel`, and a plain-language
  verdict on the right in `positive` (*"steadier than last week"*) or
  `textSecondary` when flat.
- Line chart: single `accent` polyline, 2px, round caps and joins. A baseline
  rule in `lineSoft` at the bottom. The final point gets a 4px filled dot and
  a 9px ring at 35% opacity.
- No gridlines, no y-axis labels. Three x labels beneath in mono: *{n}d ago ·
  midpoint · Today*.

**Stat tiles** — 2×2 grid, `surface` on `line`, `Radii.dataR`. Key in mono
uppercase, value in the display serif ~27px, note beneath in `caption`.

| Key | Value | Note |
|---|---|---|
| Check-ins | 14 | days in a row |
| Most common | Okay | across {range} |
| Entries | 9 | written |
| Hydration | 6.2 | glasses a day |

**What we noticed** — a 2px `ember` left rule, mono key, then one sentence in
`AppType.voiceBody` `ember`. Rule-derived, not AI:

| Condition | Line |
|---|---|
| Same weekday holds the lowest moods 3+ times | Your lowest check-ins this fortnight were all on {day} evenings. |
| Mood improves on days with an entry | Days you write tend to land better than days you don't. |
| Hydration up week over week | You're drinking more than last week — that's held for {n} days. |
| Not enough data | *(omit the block entirely)* |

Omitting is correct when nothing is true. Never manufacture an observation.

**Recent entries** — list, `lineSoft` dividers. A 9px mood dot, the mood
name, a right-aligned relative date in mono, and one line of the entry
snippet in `textSecondary`. Tapping opens the entry.

## Rules

- **No composite score.** No "wellness index", no percentage, no grade. The
  tiles report things the user can verify — days, glasses, counts — and mood
  is named, never rated.
- Numerals use tabular figures (`AppType.numeric`) anywhere they sit in a
  column or update in place.
- Chart colours come from tokens so both themes work; never hardcode hex in
  the painter.
- Empty state: if there are fewer than three check-ins, show the check-in
  prompt instead of an empty chart.

## Data

Read-only across `mood_logs`, `journal_entries`, `water_logs`. Serve it from
one endpoint rather than three round trips:

```
GET /api/insights?range=7|14|30
  → { series, tiles, observation | null, recentEntries }
```

Compute server-side. `recentEntries` includes snippets, so this endpoint is
Content class and is never exposed to an admin role.
