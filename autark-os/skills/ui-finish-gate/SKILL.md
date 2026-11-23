---
name: ui-finish-gate
description: Catch generic, interchangeable interface before it ships, by naming the tells and the replacement for each.
metadata:
  modes: [web, general]
---

# UI finish gate

I read this before any interface is called finished: a page, a screen, an app shell, a deck.

## The generic tells (each one is a finding)

| Tell | What it looks like | Replacement |
|---|---|---|
| The default gradient hero | purple-to-blue, centred headline, two buttons | a specific claim, one action, and a real image or a number |
| Interchangeable copy | "Empower your team with AI" | the job, the buyer, the outcome, in their words |
| Icon soup | three feature cards with generic icons | one screenshot that shows the thing working |
| Fake proof | invented logos, "trusted by thousands" | one named result, or no proof line at all |
| Eyeballed contrast | grey on grey | measured ratio, stated |
| One type size for everything | 16px everywhere | a scale: strong, body, small, with real hierarchy |
| No states | happy path only | empty, loading, error, long content, phone |
| Decoration as structure | boxes inside boxes | spacing and alignment doing the work |

## Steps

1. Screenshot the page at 1440 and at 390. Look at them before reading the code.
2. Answer three questions in order: what is this, who is it for, what do I do next. If any answer
   takes more than a glance, note where the eye went instead.
3. List every tell from the table that applies, with its location.
4. For each, write the replacement, not the complaint.
5. Measure contrast on text and interactive elements; state the ratio.
6. Check the four states and the phone layout. Name what is missing.

## Output

`docs/design/finish-gate-<slug>.md`: tells, locations, replacements, measured contrast, states.

## Guardrails

- No praise, no "looks great overall". The gate exists to find what is wrong.
- Do not restyle the author's concept; fix the generic parts and leave the intent alone.
