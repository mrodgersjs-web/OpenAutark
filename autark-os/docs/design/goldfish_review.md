# Goldfish review — three zero-context reviewers

Date: 2026-11-23. Method: three separate fresh-context processes (`codex exec`, one prompt each),
each given file paths and nothing else. Reviewers never saw each other's output. Findings are
reproduced as returned; the merge is by union, never by vote.

## Reviewer 1 — hostile design critic

```
blocker | README.md | The README claims runtime enforcement, but the design identifies no mechanism
          that checks a task's gate when an enabled tool executes. | Remove the enforcement claim
          until a live test shows an enabled send tool rejecting an unapproved action.
blocker | orchestrator/gates.md | Approving exact text leaves the recipient, sending account, and
          attachments open to substitution. | Bind approval to the full action.
high    | orchestrator/gates.md | G3 leaves uploads, webhook payloads and remote pushes without a gate.
high    | docs/design/design_draft.md | Uninstall is described as reversible, but a path-only
          manifest cannot distinguish untouched seed files from files the user edited.
high    | README.md | README says dropping --dry-run writes files; the draft says --write is required.
high    | docs/design/design_draft.md | "Cannot drift" is unsupported: naming checks after blueprint
          steps does not prove the app discovers the agents or routes a request.
medium  | ORCHESTRATOR.md | The WIP caps have no shared queue or atomic admission rule.
```

## Reviewer 2 — implementation readiness

```
critical | scripts/install.sh | --uninstall deletes files without --write.
high     | scripts/install.sh | Recursive deletion removes user additions and edits inside recorded
           directories; the path-prefix check does not establish ownership.
high     | scripts/install.sh | Each write run truncates the previous manifest; reruns can orphan
           skipped agents and memory; a failed copy can leave unrecorded files.
high     | scripts/install.sh | A skill collision redirects to an unchecked .autark-os folder.
high     | live agents folder | 429 ag_*/ folders exist; the installer drops new folders that the
           app skips without roster records (agent-core/service.ts:113).
high     | scripts/install.sh | AUTARK_DATA for a secondary company still sends skills to ~/Workforce.
medium   | README.md | The documented install command only previews; the preview omits collisions.
```

## Reviewer 3 — comprehension (partial)

The reviewer could not open `autark-os/ORCHESTRATOR.md` inside its own sandbox (the file is present:
4,609 bytes at that path) and answered from the upstream README instead. Its three questions are
still real user-facing gaps, so they are treated as findings:

```
1. Where do I connect my first AI provider, and what do I run to check it works?
2. How does a task get assigned to an agent, and where do I see its status or result?
3. Which approval rules actually apply on the first run, especially for public library sharing?
```

Its one-line answer to "what is this thing" was the upstream README's description of the app, not
this layer — itself the clearest evidence that our layer's first screen has to do more work.

## What the merge kept

The union has 17 findings. Seven were blockers or critical and all seven changed the design. Two
findings are contested rather than fixed (see `consolidated_review_report.md`), and one remains
open with a stated reason.
