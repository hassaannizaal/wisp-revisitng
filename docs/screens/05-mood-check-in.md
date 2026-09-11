# Mood check-in

Route `/mood/new` · authenticated · Phase 1

**Build this one first, end to end** — screen, API, database, running on a
device. It is the smallest complete loop in the product, and every other
module is this same shape with a different table.

## Layout

1. Close button (×), 44px, `textSecondary`. This is a dismissible task, not
   a navigation destination — hence × rather than a back chevron.
2. `AppType.displayLarge`: *How are you arriving today?*
   After a selection it becomes *Noted. Anything behind it?*
3. Five option rows, `Space.md` apart, 66px each, `Radii.cardR`:
   - 28px face icon, then name in `AppType.titleMedium` and a hint in
     `AppType.caption` `textTertiary`.
   - Unselected: `line` border, transparent fill, icon and name in
     `textTertiary` / `textPrimary`.
   - Selected: `accent` border, `accentDim` fill, icon and name in
     `accent` / `accentInk`.

   | Value | Label | Hint |
   |---|---|---|
   | `low` | Low | Heavy, flat, hard to move |
   | `flat` | Flat | Neither here nor there |
   | `okay` | Okay | Getting through it |
   | `good` | Good | Steady, a bit of lift |
   | `bright` | Bright | Genuinely light today |

4. Caption, centred, `textTertiary`: *"Five states, not a score out of ten.
   Nothing here is being graded or ranked."*
5. **Continue** — 54px, disabled until a selection. Label becomes *Write
   about it* once chosen, routing to `/journal/new` with the mood attached.
6. **Skip today** — 44px text button, `textSecondary`. Always available.
   Skipping is a legitimate answer and must never be nagged.

## Rules

- Five named states, never a number. No intensity slider — the older repo had
  mood plus a 1–5 scale and the design drops it deliberately.
- Order runs low → bright, so the neutral option sits in the middle and the
  list does not read as a ranking with a "best" at the top.
- The check-in writes on selection, not on Continue. Continue only navigates.
  If the user closes the screen after picking, the mood is already saved.

## Data

```
mood_logs
  id          uuid   client-generated
  user_id     uuid
  mood        text   low | flat | okay | good | bright
  logged_at   timestamptz   when the user says it happened
  created_at  timestamptz

mood_notes                  -- separate table on purpose
  mood_log_id uuid  pk, fk → mood_logs
  body        text  ≤ 2000
```

The rating and the words live in different tables so access control is
structural. An admin query reads `mood_logs` and has no path to
`mood_notes`. Do not add a join that crosses them in any code path that
serves a watcher.

```
POST /api/moods   { id, mood, loggedAt, note? }  → 201
GET  /api/moods?from=&to=                        → caller's own logs
```

`POST` is idempotent on `id` — a retry after a dropped connection is a no-op,
not a duplicate. Write to the local store first, queue the sync, update the
UI immediately.
