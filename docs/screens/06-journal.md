# Journal composer

Route `/journal/new` · authenticated · Phase 1

Where the most personal text in the product gets written. The privacy state
is shown inline rather than left for the user to remember.

## Layout

1. **Header row**: back chevron (44px) on the left, timestamp on the right in
   `AppType.monoLabel` `textTertiary` — *Thursday · 21:04*.
2. **Prompt** — `AppType.voice` (Newsreader italic 300) in `ember`:
   *"What is sitting heaviest right now?"*
   The prompt is chosen by a rule, not by AI. See below.
3. **Text field** — fills available height. `AppType.bodyLarge` sizing, no
   border, no fill, transparent. Placeholder `textTertiary`: *"Start
   anywhere. Nothing here is graded."* Autofocus on open.
4. **Tag chips** — one row, wrapping, above the footer. 44px tall,
   `Radii.chipR`. Single-select, tappable off again.
   Work · Family · Sleep · Money · Health · Nothing in particular
5. **Footer**, above a `lineSoft` rule:
   - Mode badge on the left — "Private · only you" in independent mode.
     In organization mode this still reads **Private**, because journal text
     is never visible to an admin. Do not show amber here.
   - Character count on the right, `AppType.numeric` `textTertiary`.
     Turns `caution` past 1900.
   - **Save reflection** — 54px, disabled while empty.

## Prompts

A small rotating set, selected by rule against recent data. No AI.

| Condition | Prompt |
|---|---|
| Mood logged `low` or `flat` today | What is sitting heaviest right now? |
| Mood logged `good` or `bright` | What went right today? |
| No mood logged | How has today been? |
| Third entry in a week | Anything changed since you last wrote? |
| After 11pm | What is keeping you up? |

Keep the rules in one place so the AI layer can later replace the selector
behind the same interface without touching this screen.

## Rules

- Autosave the draft locally every few seconds. Losing a half-written entry
  at 2am is the worst failure this screen can have.
- Never summarise, score, or react to what was written. No sentiment badge,
  no "that sounds hard" toast. The user writes; the app keeps it.
- 2000 character cap, enforced in the field, not just validated on save.

## Data

```
journal_entries
  id          uuid   client-generated
  user_id     uuid
  body        text   ≤ 2000
  tag         text   nullable
  mood_log_id uuid   nullable — set when arriving from the check-in
  written_at  timestamptz
  created_at  timestamptz
```

```
POST /api/journal   { id, body, tag?, moodLogId?, writtenAt }  → 201
GET  /api/journal?limit=                                       → caller's own
```

This whole table is Content class. It is never readable by an org admin, at
any role. Enforce that in the repository layer, not only in the route.
