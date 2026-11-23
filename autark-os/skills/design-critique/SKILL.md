---
name: design-critique
description: Critique a design against its job - hierarchy, one action, density, type, colour, imagery - and return ordered fixes.
metadata:
  modes: [web, general]
---

# Design critique

I read this when a design exists and someone wants an honest read before it goes out.

## The seven questions

1. **What is this?** Answerable in two seconds without reading the body copy.
2. **What do I do next?** One action, visually dominant, unambiguous in verb.
3. **Where does the eye go?** Name the first three stops. If they are not the intended ones,
   the hierarchy is wrong.
4. **Does the density match the job?** A landing page is sparse; a dashboard is dense. Either can
   be wrong by being the other.
5. **Is the type doing work?** Scale, measure (45-75 characters per line), weight contrast.
6. **Is colour carrying meaning or decoration?** The accent should mark the action and nothing
   else.
7. **Does the imagery inform, or fill space?** A real screenshot beats a rendered abstraction.

## Steps

1. Screenshot desktop and phone. Critique the screenshots, not the intent.
2. Answer the seven questions in order, each with the location it comes from.
3. Rank fixes by what changes comprehension most per unit of work.
4. Name one thing to remove. Most designs improve by subtraction.
5. Benchmark against `research/what-great-looks-like/` when the category matters; cite the shot.

## Output

`docs/design/critique-<slug>.md`: the seven answers, ranked fixes, one removal.

## Guardrails

- Critique the artifact, never the author.
- "Make it pop" is not a finding. Say which element, and what should happen to the eye.
