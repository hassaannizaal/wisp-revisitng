# Account mode

Route `/onboarding/mode` · first run only · Phase 0

**The most consequential screen in the product.** It decides who can ever see
this person's data. Treat every detail here as load-bearing.

## Layout

Header is fixed, options scroll, CTA is pinned to the bottom.

1. **Header** (fixed): back chevron, then
   - `AppType.displayLarge`: *Who is this account for?*
   - `AppType.bodyMedium`, `textSecondary`: *"This decides who can ever see
     what you write here. You can change it later, but we will tell you
     exactly what changes."*
2. **Two option cards** (scrolling), `Space.md` apart. Each: icon + title
   row, a radio on the right, a description, and a preview of the mode badge
   that account would carry.

   **Just me** — person icon. Selected: `accent` border, `accentDim` fill.
   > No admin above you. Nothing you write is visible to anyone else, and
   > your location is never shared — not even during a crisis, unless you
   > ask for it.

   Badge preview: `accent`, "Private · only you".

   **My university, workplace or family** — people icon. Selected: `caution`
   border, `cautionDim` fill.
   > You join with a code. Someone there will be able to see some of what you
   > do here — we will name exactly who, and exactly what, before you finish.

   Badge preview: `caution`, "Visible · to a named person".

3. **Disclosure panel** — appears only when the organization option is
   selected. `caution` border, `Radii.cardR`.

   Header in `AppType.monoLabel`, `caution`: *What an admin would see*

   Then four rows, tick or cross glyph + text:

   | | |
   |---|---|
   | tick, `caution` | That you checked in, and how you rated your mood |
   | tick, `caution` | Whether you used the panic button, and your location if you did |
   | cross, `positive` | Not the words in your journal entries |
   | cross, `positive` | Not anything you say to WISP in a session |

   Footer, `textTertiary`, above a `lineSoft` rule: *"Every time an admin
   opens your records, you see it in your own activity log."*

4. **CTA** (pinned, `lineSoft` top border). Disabled until a choice is made.
   - Just me → label *Continue*, `accent` fill → `/`
   - Organization → label *Enter your join code*, `caution` fill →
     `/onboarding/join-code`

## Why the disclosure is not optional

This is item 15 from the product notes — the one marked "to be properly
discussed". The design's position: a minor is told, in plain words, before
they write anything, exactly what an adult can see. If the policy later
changes what an admin can access, **this list changes with it**. The list is
generated from the actual grant, never hardcoded prose that can drift.

## Data

Writes `users.account_mode` (`independent` | `organization`). For
organization, the join-code screen creates the membership row. Do not let a
user reach `/` in organization mode without a completed membership.
