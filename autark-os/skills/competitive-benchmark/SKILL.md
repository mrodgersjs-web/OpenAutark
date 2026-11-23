---
name: competitive-benchmark
description: Score a product against the category leaders on named dimensions, with screenshots as evidence and the gap turned into moves.
metadata:
  modes: [research, web]
---

# Competitive benchmark

I read this when someone asks "what does great look like" or "how do we compare".

## Method

1. **Pick the set**: three direct competitors, three category leaders that set expectations, and
   the product itself. Direct competitors tell you the floor; leaders tell you the ceiling.
2. **Fix the dimensions before you look**, so the scoring is not reverse-engineered from the
   screenshots. Twelve used here: first impression, one clear action, proof, specificity of copy,
   product visibility, design craft, motion and feedback, states and empty cases, speed feel,
   trust and safety surface, price clarity, and the "would I forward this" test.
3. **Capture the evidence**: viewport screenshot at 1440 wide, live URL, date, and one line
   quoting the headline verbatim. No screenshot, no score.
4. **Score 1-5 per dimension**, with the observation that decided it. Same ruler for everyone.
5. **Turn the gaps into moves**: each gap becomes one concrete change with an effort and an
   expected effect, ordered by effect per unit of work.

## Output

`research/<slug>/benchmark.md` plus `shots/` with the captures, and a table a human can scan.

## Guardrails

- Score what is on the page, not what the marketing claims elsewhere.
- A leader being wrong is not permission for us to be wrong; note it and move on.
- Date every capture. A benchmark without dates becomes a lie within a quarter.
