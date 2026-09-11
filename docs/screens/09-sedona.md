# Sedona Method

Route `/sedona` · authenticated · Phase 2

A guided five-step release sequence. Structurally a stepper — the content is
fixed, so no AI is needed for the basic version.

## Layout

Centred, single column.

1. **Header row**: close × on the left (44px), progress pips on the right —
   five bars, 22×3px, `Radii.live`. Completed and current in `accent`,
   remaining in `lineSoft`.
2. **Ripple graphic**, centred, 150px. A 78px orb (same gradient as the
   Welcome orb) with three concentric `accent` rings expanding from 0.82 to
   1.5 and fading out, staggered 1.4s apart on a 4.2s cycle. Stops under
   reduce-motion.
3. **Step block**, centred, `Space.xxl` below the graphic:
   - Step key in `AppType.monoLabel` `textTertiary` — *Step 1 of 5 · Welcome it*
   - Question in `AppType.displayMedium`, centred
   - Note in `AppType.bodyMedium` `textSecondary`, max ~32 characters a line
4. **Answer row** — two 54px buttons side by side, outlined on the left,
   primary on the right. Both advance.
5. **Footer** — 44px text button, `textTertiary`. Step 1: *"Sedona Method ·
   about 4 minutes"*. After that: *Start over*.

## The five steps

| Key | Question | Note | Left | Right |
|---|---|---|---|---|
| Welcome it | What are you feeling right now? | Do not try to change it or explain it. Just let it be there and notice where you feel it. | Not sure yet | I have it |
| Could you | Could you let this feeling go? | Not will you, or should you. Only whether it would be possible. | No | Yes |
| Would you | Would you let it go? | Either answer is fine. Holding on is a choice too, and naming it is the point. | Not yet | Yes |
| When | When? | The honest answer is often not now. That is still an answer. | Later | Now |
| Again | How does it sit now? | If it is still heavy, the round can be repeated. Most people go round more than once. | Go again | Lighter |

Copy is from the method itself and has been through several passes. Use it as
written.

## Rules

- **Both answers advance.** There is no wrong answer and no branch that
  punishes "no" — that is the whole point of the technique. Record which was
  chosen; don't act on it.
- *Go again* on the final step returns to step 1 and starts a new round on
  the same log entry, incrementing `rounds`.
- Nothing is graded, scored or summarised at the end.

## Data

```
sedona_logs
  id          uuid   client-generated
  user_id     uuid
  answers     jsonb  [{step, choice}]
  rounds      int    default 1
  started_at  timestamptz
  finished_at timestamptz  nullable — null if abandoned
```

```
POST  /api/sedona          { id, startedAt }            → 201
PATCH /api/sedona/:id      { answers, rounds, finishedAt? }
```

Create on open, patch as it goes, so an abandoned session is still visible in
the data as an abandoned session. Signal class — an admin may see that a
session happened, never the answers.
