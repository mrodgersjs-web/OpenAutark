# The twenty, in one table

Generated from `catalog.json` on 2026-11-23. Stars and licenses read from the GitHub API that day;
`take` is the path in the repo we actually open. 7 packs are vendorable and 13 are
reference-only after the licensing review (see `docs/design/pack-system/resolution.md`).

| # | Pack | Repo | Stars | License | Mode | Take | Why it earns a place |
|---|---|---|---|---|---|---|---|
| 1 | anthropic-skills | anthropics/skills | 199425 | mixed-per-skill | reference | skills | The format we already follow: 19 skills with name/description front matter, including docx, pdf, pptx, xlsx and skill-creator. |
| 2 | superpowers | obra/superpowers | 324971 | MIT | vendor | skills | The strongest skill library for how work gets done rather than what it is about: brainstorming, writing plans, executing plans, requesting and receiving code review, subagent-driven development, finishing a branch. |
| 3 | wshobson-agents | wshobson/agents | 42844 | MIT | vendor | plugins | Plugins with agents, skills and commands in one installable shape: agent-orchestration, agent-teams, api-testing-observability, accessibility-compliance, avoid-ai-writing. |
| 4 | awesome-copilot | github/awesome-copilot | 41484 | mixed | reference | skills | GitHub's own community pack: 100+ skills plus instructions and hooks, including acquire-codebase-knowledge, acreadiness-* reviews and domain skills. |
| 5 | voltagent-subagents | VoltAgent/awesome-claude-code-subagents | 26746 | MIT | vendor | categories | 100+ subagents in ten categories (core development, quality and security, data and AI, business and product, meta-orchestration). |
| 6 | bmad-method | bmad-code-org/BMAD-METHOD | 55665 | NOASSERTION | reference | skills | The most complete role choreography for building software with agents: analyst, PM, architect, dev, QA, with handoffs and artifacts between them. |
| 7 | fabric-patterns | danielmiessler/Fabric | 44754 | MIT | vendor | data/patterns | Hundreds of single-purpose patterns (analyze_claims, extract_wisdom, create_summary, write_essay, analyze_answers) written as plain prompts with inputs. |
| 8 | context-engineering-prp | coleam00/context-engineering-intro | 13925 | MIT | vendor | PRPs | The PRP (product requirement prompt) pattern: a spec that gives an agent everything it needs to build a feature in one pass, plus the commands that generate and execute it. |
| 9 | twelve-factor-agents | humanlayer/12-factor-agents | 27382 | NOASSERTION | reference | . | Twelve principles for agents that survive production: own your prompts, own your context window, small focused agents, tools as structured outputs. |
| 10 | mcp-reference-servers | modelcontextprotocol/servers | 92194 | NOASSERTION | reference | src | The reference MCP servers (filesystem, git, fetch, memory, time, sequential thinking). |
| 11 | awesome-mcp-servers | punkpeye/awesome-mcp-servers | 98426 | MIT | reference | . | The discovery index for MCP: what already exists before we build it. |
| 12 | context7 | upstash/context7 | 65344 | MIT | reference | . | Live library documentation as an MCP tool. |
| 13 | mem0 | mem0ai/mem0 | 69384 | Apache-2.0 | reference | . | The reference implementation of memory extraction, deduplication and retrieval. |
| 14 | openhands-agents | OpenHands/OpenHands | 94163 | MIT | vendor | .agents/skills | Autark's nearest structural sibling, and its microagents are skills with triggers - the closest public prior art to what our router does with `when` clauses. |
| 15 | browser-use | browser-use/browser-use | 121860 | MIT | reference | . | How a browser agent actually drives a page: element extraction, action loops, failure recovery. |
| 16 | claude-cookbooks | anthropics/claude-cookbooks | 55116 | MIT | reference | . | Recipes for tool use, evaluations, RAG and classification. |
| 17 | agent-rules | steipete/agent-rules | 5666 | MIT | vendor | . | Small, sharp rule files for coding agents (how to edit, how to test, how to report). |
| 18 | awesome-claude-code | hesreallyhim/awesome-claude-code | 58675 | CC-BY-NC-ND-4.0 | reference | . | The index of commands, hooks, workflows and status lines that people actually use. |
| 19 | awesome-claude-skills | travisvn/awesome-claude-skills | 15921 | none-declared | reference | . | A curated index of individual skills with one-line descriptions - the fastest way to answer do we already have a skill for this before writing another one. |
| 20 | awesome-claude-prompts | langgptai/awesome-claude-prompts | 5593 | none-declared | reference | . | Prompt patterns collected by use case. |

## The five that change the most, in order

1. **superpowers** (MIT) - our doers have methods; these are the missing procedures for planning,
   review and delegation.
2. **wshobson/agents** (MIT) - agent-teams and agent-orchestration are exactly the routing problem
   our chief of staff solves by hand.
3. **fabric patterns** (MIT) - one-prompt, one-job analyses, which is what research and proof work
   actually is.
4. **context-engineering PRP** (MIT) - the bridge between our blueprint and a build that lands.
5. **voltagent-subagents** (MIT) - ten categories of specialist, including business and product,
   where our roster is thinnest.

## What the licensing review changed

- **awesome-copilot** moved from vendor to reference: its skills mix MIT with Apache-2.0 and carry
  their own NOTICE files, so it is promoted one named skill at a time, never as a pack.
- **anthropic-skills** is `mixed-per-skill` - four office skills are Apache-2.0, `doc-coauthoring`
  has no grant.
- **awesome-claude-code** is CC BY-NC-ND: links only, no excerpts.
- **bmad-method**, **12-factor-agents** and **mcp-reference-servers** are NOASSERTION: read, quote
  with attribution, copy nothing until someone reads the terms.
- **openhands-agents** was re-pointed at `.agents/skills` after `microagents` 404ed.

## What is deliberately not here

No autonomous-commit factories, no auto-merge bots, no "swarm that writes your whole app" repos. The
layer's value is the gate ladder; a pack that commits on its own is a hole in it. `architect-loop` is
read for its design vocabulary, never installed, for the same reason.
