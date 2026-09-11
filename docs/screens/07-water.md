# Water

Route `/water` · authenticated · Phase 1

The simplest module. Good second build after mood — it proves the reminder
infrastructure without any new concepts.

## Layout

1. Back chevron, 44px.
2. **Heading** — `AppType.displayMedium`: *Water*. Below it, the count:
   the filled number at ~46px in the display serif, `accent`, then *"of 8
   today"* in `AppType.bodyLarge` `textTertiary`.
3. **Glass grid** — 4 columns, `Space.md` gap, each cell 78px, `Radii.dataR`.
   A 30px droplet glyph inside.
   - Filled: `accent` border, `accentDim` fill, droplet stroked and filled
     `accent`.
   - Empty: `line` border, transparent, droplet stroked `textTertiary`.
   - Tapping glass *n* sets the total to *n*. Tapping the currently-last
     filled glass sets it to *n−1*, so a mistake is undone with one tap.
4. **This week** — `AppType.monoLabel` key, then seven bars, 86px band.
   Today's bar in `accent`, the rest `lineSoft`. Day initials beneath in
   `AppType.monoLabel`.
5. **Reminders row** — `line` border, `Radii.dataR`. Title, a subtitle that
   states the actual schedule (*"Every 2 hours, 9am to 9pm"*) or, when off,
   *"Off — nothing will nudge you"*. Switch on the right: 50×30 track inside
   a 44px tap target.
6. **Log a glass** — 54px primary, plus icon. Increments by one, capped at
   the goal.

## Rules

- The goal is per-user (`users.water_goal_glasses`, default 8), not a
  constant.
- Reminder copy always offers a way out: *"Fourth of eight. Tap to log, or
  ignore this — it won't ask again today."* A nag that can't be dismissed
  gracefully is the fastest route to an uninstall.
- One reminder per interval, and none after the goal is met.

## Data

```
water_logs
  id         uuid   client-generated
  user_id    uuid
  glasses    int    the running total for that day
  logged_for date   local date, not a timestamp
  updated_at timestamptz
  unique (user_id, logged_for)
```

One row per user per day, updated in place — not one row per glass. It makes
the week query trivial and the "tap to undo" behaviour honest.

```
PUT  /api/water   { loggedFor, glasses }   → 200
GET  /api/water?from=&to=                  → caller's own
```

`PUT` rather than `POST` because the day's row is idempotent by
`(user, date)`. Local-first as everywhere else.

Signal and Rating class — an org admin may see that hydration is tracked and
the count. There is no Content here.
