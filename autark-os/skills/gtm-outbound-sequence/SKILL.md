---
name: gtm-outbound-sequence
description: Design a multi-channel sequence where every touch earns the next one, and measure it in replies.
metadata:
  modes: [manager, social]
---

# Outbound sequence

I read this when a signal list exists and it is time to write the touches.

## The shape

| Touch | Channel | Job of the touch |
|---|---|---|
| 1 | the channel the signal came from | one specific observation + one relevant claim |
| 2 | email | the same idea, a different angle, one line shorter |
| 3 | a public, useful comment or a second angle | show the work, no ask |
| 4 | email | the smallest possible ask (a question, not a meeting) |
| 5 | close the loop | "I will stop here" + one useful artifact |

Five touches over 14-20 days. Fewer feels like a cold call; more is harassment.

## Writing rules

- One observation per touch, from the signal, that proves a human looked.
- No fake familiarity, no "loved your post", no invented mutual contacts.
- One ask total per sequence, and it is small.
- Plain text, short lines, no tracking pixels in the first touch, no attachments.
- Every message states who we are in one clause and why them in one clause.

## Steps

1. Write the observation bank first: five specific facts per prospect segment.
2. Write the sequence against the bank, not against a template with blanks.
3. Set the stop rules: any reply, any no, any unsubscribe ends the sequence immediately.
4. Load the drafts into the approval queue, batched, with the count and the channels named.
5. Measure: reply rate, positive reply rate, meeting rate, opt-out rate. Kill the variant that
   loses on positive replies after a meaningful sample, not after two sends.

## Output

`gtm/sequences/<name>.md` plus the staged drafts.

## Guardrails

- Nothing sends without exact-text approval per channel (G3).
- No sequence runs to someone who has asked us to stop, on any channel.
