# Screens

Ten designed screens. Build order runs top to bottom — each one only depends
on things above it.

| File | Screen | Route | Phase |
|---|---|---|---|
| `01-welcome.md` | Welcome | `/welcome` | 0 |
| `02-sign-in.md` | Sign in | `/sign-in` | 0 |
| `03-account-mode.md` | Account mode | `/onboarding/mode` | 0 |
| `04-home.md` | Home | `/` | 1 |
| `05-mood-check-in.md` | Mood check-in | `/mood/new` | 1 |
| `06-journal.md` | Journal composer | `/journal/new` | 1 |
| `07-water.md` | Water | `/water` | 1 |
| `08-dashboard.md` | Dashboard | `/dashboard` | 1 |
| `09-sedona.md` | Sedona Method | `/sedona` | 2 |
| `10-mindfulness.md` | Mindfulness | `/breathe` | 2 |

**Start with 05 (mood check-in) end to end** — screen, API, database, running
on a device — before building any other module. It is the smallest complete
loop in the product, and every other module is the same shape with a
different table. Getting one working proves the path; building ten screens
against mocked data does not.

Each spec gives layout, states, interactions and data. It does not give pixel
values — those come from the tokens in `lib/core/theme/`. If a spec and the
tokens disagree, the tokens win.

## Not yet designed

Crisis resources list, therapist onboarding, group circles, music therapy,
admin console, RBAC screens, the AI therapist. Don't invent them — ask.

## Reference

A live version of every screen below, with working controls, is published as
a design canvas. The specs are authoritative; the canvas is for seeing
intent, spacing and tone.
