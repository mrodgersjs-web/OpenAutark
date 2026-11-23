# The gate ladder

Autark's Security settings close *capabilities* in the runtime (files, shell, web, apps,
messages, accounts, money). This ladder governs *work*: what a task may do once a capability
is open. Both apply. The stricter one wins.

| Gate | Name | What it allows | Who approves | Examples |
|---|---|---|---|---|
| G0 | read | Inspect files, pages, accounts, logs, databases | nobody — always allowed | reading a repo, a CRM list, a website |
| G1 | draft | Produce an artifact that has not left the company | nobody — always allowed | a post draft, a proposal draft, a plan, a patch |
| G2 | internal write | Change the company's own files, memory, boards, repos on a branch | logged, reversible, no approval | writing a skill, updating memory, committing to a branch |
| G3 | outward | Anything that leaves the machine for another person or a public place | the person, on the exact action (text + recipient + sending account + attachments) | email, DM, LinkedIn comment, post, job application, public PR, uploads, webhook payloads, pushes to a public remote |
| G4 | money / irreversible | Spend, sign, delete, change security, rotate keys | the person, every time | invoices, payments, deleting a company folder |

## Rules that follow from the ladder

1. **A draft is not an approval.** "Draft it" means stop at G1. Never read a standing "go ahead"
   as consent for a specific message that was written after it.
2. **Approval is action-shaped.** The person approves four things at once: the words, the
   recipient, the account it is sent from, and every attachment. Changing any one of them - a
   different address, another file, the other mailbox - voids the approval. Log the four values
   with the approval, and compare them immediately before the action runs, not after.
3. **Batch, do not drip.** Collect all G3 items for one channel into one approval request with
   the exact texts, in order, and the count stated up front.
4. **G4 is never delegated.** Not to an agent, not to a subagent, not to "the team".
5. **Blocked is a valid output.** A gate you cannot pass produces the draft plus the gate name.
   Silence, or a clever workaround, is a failure.
6. **Log the gate, not just the action.** Every completed item records its gate, the approver,
   the timestamp and the destination.

## Which skills stop where

| Skill | Highest gate it reaches on its own |
|---|---|
| `repo-architecture`, `code-review`, `research-report`, `competitive-benchmark` | G2 (branch, notes) |
| `gtm-icp`, `gtm-offer`, `gtm-signals`, `gtm-pipeline-forecast`, `gtm-metrics-scorecard` | G1 |
| `gtm-outbound-sequence`, `gtm-linkedin-post`, `gtm-council-review` | G1 — the sequence and the post exist as drafts |
| `gtm-draft-only` | G1, and it may stage into the send queue only with the approval attached |
| `memory-hygiene`, `skill-authoring`, `agent-team-hiring`, `orchestrator-routing` | G2 |
| `done-claim-verification`, `proof-packet`, `quality-gate` | G0 — it only reads and judges |

Nothing in this layer reaches G3 or G4 by itself. That is deliberate.

## What enforces what

Two different things, and confusing them is how trust gets lost:

| Layer | Enforced by | Applies to |
|---|---|---|
| Autark Security settings | the runtime (capabilities close for real) | files, shell, web, apps, messages, accounts, money |
| This gate ladder | the agent following it, plus the approval record and its audit | which *work* needs a word, and what the approval binds |

The runtime does not yet inspect which gate a task is on: the ApprovalRequest/ApprovalAnswer hooks
exist in the app's source and arrive in the installed build from 0.3.19 (installed here: 0.3.14,
2026-11-23). So the ladder is a policy with an audit trail, not a sandbox. Never describe it to the
person as a runtime control.
