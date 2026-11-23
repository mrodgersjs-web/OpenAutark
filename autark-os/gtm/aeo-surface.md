# Answer-engine surface

The question → page map. Written 2026-11-23; the twenty questions are the target, the pages are
the work.

| # | Question the buyer asks a model | Page that should answer it | Status |
|---|---|---|---|
| 1 | "how do I run an AI team on my own computer" | product page, first section | to write |
| 2 | "AI agents that remember between sessions" | memory page | to write |
| 3 | "local AI agents vs cloud agents, cost" | comparison page | to write |
| 4 | "how do I stop AI agents from spending money" | security page | to write |
| 5 | "what is an agent operating system" | explainer | to write |

Deliberately short. Adding rows we cannot answer makes the site worse, not bigger.

## The four machine-readable facts

1. Who we are (one sentence, same everywhere).
2. What we do, for whom, in which shape (desktop, own PC, own keys).
3. What it costs (band, with what is included).
4. The proof (a named result or an honest "not yet measured").

`llms.txt` at the root repeats those four facts and links the pages above. Structured data on each
page matches its visible text exactly.
