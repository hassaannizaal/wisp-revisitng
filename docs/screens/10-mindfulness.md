# Mindfulness

Route `/breathe` · authenticated · Phase 2

A guided breathing session. One large animated orb and almost nothing else —
the restraint is the design.

## Layout

1. **Header row**: close × (44px) on the left, remaining time on the right in
   `AppType.monoLabel` `textTertiary`, counting down — *5:00*.
2. **The orb**, centred, 250px. Radial gradient `accentInk` → `accent` at 40%
   → `accentDim` at 82%, with a 1px inner ring at ~45% `accentInk`. A soft
   440px `accent` wash at 10% opacity sits behind it, decorative only.
3. **Text block** below, centred, `Space.xxl` gap:
   - `AppType.displayMedium`: *Breathe with it*
   - `AppType.bodyMedium` `textSecondary`: *"In as it grows, out as it falls.
     Four counts in, seven out — do not force the rhythm to match."*
4. **Length chips** — 3 / 5 / 10 min, centred, 44px tall, `Radii.chipR`.
   Selected: `accent` border, `accentDim` fill.
5. **Pause / Resume** — 54px. Running: outlined with a pause glyph.
   Paused: `accent` filled with a play glyph.

## The breath cycle

11 seconds, looping, ease-in-out:

| Phase | Timing | Scale |
|---|---|---|
| Inhale | 0 → 35% | 0.66 → 1.0 |
| Hold | 35 → 50% | 1.0 |
| Exhale | 50 → 85% | 1.0 → 0.66 |
| Rest | 85 → 100% | 0.66 |

That is roughly 4 in, 2 hold, 4 out, 1 rest — a calming ratio without being
so long it becomes a challenge. Pausing freezes the animation where it is
rather than resetting.

Under reduce-motion the orb holds at 1.0 and the text carries the pacing
instead. Use `Motion.respecting`.

## States

| State | Orb | Title | Sub |
|---|---|---|---|
| Running | animating | Breathe with it | *(the four-seven line)* |
| Paused | frozen | Paused | Take as long as you need. The count starts again when you do. |
| Complete | settles to 1.0 | That's the five minutes | No streak, no score — just the fact it happened. |

## Rules

- Audio is optional and **off by default**. Someone opening this at 2am in a
  shared room should not have sound start unannounced.
- Changing the length mid-session restarts the timer, not the breath cycle.
- The completion state congratulates nothing. No confetti, no streak badge.

## Data

```
meditation_sessions
  id           uuid   client-generated
  user_id      uuid
  planned_secs int
  actual_secs  int
  started_at   timestamptz
  finished_at  timestamptz  nullable
```

```
POST  /api/breathe        { id, plannedSecs, startedAt }   → 201
PATCH /api/breathe/:id    { actualSecs, finishedAt }
```

Record the actual duration, not just the planned one — a person who stops at
40 seconds is data worth having, and is never shown to them as a failure.

Signal class.
