---
name: skill-authoring
description: Write a skill an agent can follow - one trigger, ordered steps, a stated output, a gate and a guardrail list.
metadata:
  modes: [manager, general]
---

# Writing a skill

I read this when a procedure proved itself twice and should stop living in a chat.

## Format (exactly what this app reads)

```markdown
---
name: <folder name, lowercase-with-dashes>
description: <one line: when to read me and what I produce>
metadata:
  modes: [manager, general]      # which modes may use it
---
# Title
<One paragraph: when I read this.>
## Steps
1. ...
## Output
<the artifact, and where it goes>
## Guardrails
- ...
```

## Steps

1. **One trigger.** A skill that fires on everything fires on nothing. Name the situation.
2. **Steps in order**, each starting with a verb, each checkable. If a step needs judgement,
   say what the judgement is between.
3. **State the output and the path.** A skill without an artifact is advice.
4. **Name the gate** it stops at.
5. **Guardrails**: the three ways this goes wrong, written as prohibitions.
6. **Cite the source** when the method is adapted: repo, file, licence.
7. **Test it**: run the skill on a real case, then delete every sentence that did not change
   the outcome.

## Guardrails

- No skill over 120 lines. Longer means it is two skills or a document.
- No secrets, no personal data, no customer names in a skill that leaves the machine.
- A skill that duplicates an existing one is an edit, not an addition.
