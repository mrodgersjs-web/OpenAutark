---
name: gtm-aeo-surface
description: Make the company the answer a model or a search engine gives - machine-readable facts, citation-ready pages, and a measured visibility loop.
metadata:
  modes: [research, web]
---

# Answer-engine surface

I read this when search visibility, AI citations or an `llms.txt` is the job.

## What machines need

1. **One canonical statement per fact**: who we are, what we do, for whom, at what price band,
   with which proof, where the canonical page lives. Same wording everywhere.
2. `llms.txt` at the root: a short, honest map of the site - what each section is for, which
   pages matter, what is current.
3. **Structured data** on the pages that carry facts: organisation, offer, FAQ, article, with
   dates. Schema that matches the visible text, never a richer claim than the page makes.
4. **Answer-shaped pages**: the question in the buyer's words as the heading, the answer in the
   first two sentences, the detail after. One question per page.
5. **Freshness**: an owner and a date on every claim page. Stale pages are corrected or removed.

## Steps

1. Collect the twenty questions the buyer actually asks a model, from real conversations and
   from the site's own search log.
2. Map each question to one page (existing or to write). Gaps are the roadmap.
3. Write or fix the canonical statements first; nothing else works while the facts disagree.
4. Publish `llms.txt` and the schema, then fetch each one to confirm it is served.
5. Measure monthly: citations in AI answers, impressions, qualified visits, and the share that
   names the problem we solve. Record the method with the number.

## Output

`gtm/aeo-surface.md` (the map) plus the files themselves.

## Guardrails

- Never write a claim page for a claim we cannot source.
- No cloaking, no fake FAQs, no schema that exceeds the visible page.
