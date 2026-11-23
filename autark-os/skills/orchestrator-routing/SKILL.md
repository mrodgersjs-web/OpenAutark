---
name: orchestrator-routing
description: Route any request to exactly one owner, with the gate and the done-test fixed before work starts.
metadata:
  modes: [manager, general]
---

# Routing a request

I read this when a request arrives and it is not obviously mine to do. Routing is a decision,
not a hand-off: one owner, one gate, one done-test, written down.

## Steps

1. **Restate the request in one sentence**, in the person's words. If the sentence needs an
   "and", it is probably two pieces of work.
2. **Classify it**: question, decision, build, research, content, operation, incident. The class
   picks the route family in `orchestrator/router.json`.
3. **Match the route** by intent, not by noun. "Write a pricing page" is design + GTM content;
   "should we raise the price" is a decision for the council. When two routes match, the one
   with the harder gate wins.
4. **Name one owner.** Two owners is a bug. If two areas genuinely share the work, split it into
   two cards with a stated interface between them.
5. **Fix the gate**: G0 read, G1 draft, G2 internal write, G3 outward, G4 money. Write it on the
   card. A G3 item is not "sort of approved" because the owner is trusted.
6. **Write the done-test**: the observation that would make a stranger agree it is finished.
   A command, a file at a path, a URL that returns the new thing, a number that moved.
7. **Check capacity.** Three open pieces per owner. A fourth waits, and the card says behind what.
8. **Say it back** in one line: who owns it, the gate, the done-test, when it lands.

## Output

A card: `outcome / owner / gate / done-test / deadline / waits-behind`.

## Guardrails

- Never route to yourself because it is faster. The orchestrator that does the work stops
  routing it.
- Never start a card without a done-test. That is how "in progress" becomes permanent.
- An ambiguous request gets one question with a recommended default, not three questions.
