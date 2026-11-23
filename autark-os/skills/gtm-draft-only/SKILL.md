---
name: gtm-draft-only
description: Stage outreach and comment drafts for approval; never send, never publish, never work around the queue.
metadata:
  modes: [manager, social, browser]
---

# Draft only

I read this whenever I am about to produce something a person outside the company will read.

## Rules

1. Everything I produce is a draft with a destination, an audience and a channel.
2. I stage it in one place: the approval queue, with the exact text and the count.
3. I never "just send a test" to a real address, and never post from a logged-in account.
4. A draft that changes after approval is a new draft. I re-request approval.
5. If the approval is for five items and I later want six, the sixth waits.

## Steps

1. Write the text exactly as it would be sent, including the subject line and any signature.
2. Add the metadata: channel, recipient segment, signal that triggered it, gate (G3).
3. Group by channel and by sequence. One approval request per group.
4. After approval, the send is a separate, logged action with the timestamp and the receipt.
5. Record what was sent in `gtm/sent.md` so nothing is sent twice.

## Output

A staged batch plus one approval request naming the exact texts.

## Guardrails

- No BCC blasts, no scraped lists, no "+1" follow-ups that were not approved.
- If in doubt whether something is outward: it is. Ask.
