---
name: game-stage-review
description: Independent cold-session reviewer for a pipeline stage's plan or output. Run in a NEW agent session with no producer context. Reads only the review request's allow-list, evaluates the artifact as the downstream stages that will consume it, and writes a verdict file. Use when opening a fresh agent on a review/REQUEST_*.md file, or when the user says 'run the review', 'review request', 'cold review'.
---

# Stage Review (Independent)

A reviewer role run as its own cold agent session. It has no memory of how the artifact was built. It evaluates the artifact as the future agent that will have to build on it, and asks one question: **"when I consume this downstream, what will hurt me?"**

It never edits the artifact. It writes exactly one file: the verdict.

## Cold-start contract (non-negotiable)

This skill is meaningless if run in the producer's session. When invoked:
- Your **only** inputs are the files listed in the `review/REQUEST_*.md` allow-list.
- You must **not** read the producer's chat, working notes, prior-round verdicts, or any rationale beyond the artifact itself. You come to the artifact fresh.
- If you find yourself with producer context in scope, stop — you are the wrong session. The review must be a separate agent.

A re-review (round 2+) is also cold. You do not see the previous verdict. You re-evaluate the current artifact against the downstream map; genuinely-fixed findings simply won't recur, and unfixed ones will surface again on their own.

## Process

1. Open the `review/REQUEST_*.md` you were pointed at. It gives you: `stage`, `phase` (plan|output), `round`, the artifact paths, and the exact reading allow-list.
2. Read **only** the allow-listed files: the artifact, `~/.cursor/skills/game-stage-review/downstream-map.md`, and the named `context/context_*.md` modules. Nothing else.
3. Find the `stage` entry in `downstream-map.md`. Adopt each downstream consumer's mindset in turn. For `plan` phase, focus on decisions expensive to reverse later (schema shape, visual strategy, shell config). For `output`, check the artifact against the consumer lens.
4. Write the verdict to `review/VERDICT_<stage>_<phase>_r<round>.md` using the format below. Cite the consuming step on every finding.
5. Stop. Do not touch the artifact, `context/`, `_INDEX.md`, or any other file.

## Verdict file format

```
## Review — Step <NN> (<plan|output>) — round <R>
Verdict: APPROVE | REVISE | ESCALATE

### Findings
| Sev | For step | Finding | Suggested fix |
|-----|----------|---------|---------------|
| 🔴  | 05a      | ...     | ...           |
| 🟠  | 06       | ...     | ...           |

### Rationale
<2–4 sentences: the downstream cost if REVISE/ESCALATE, or why it's clean if APPROVE>
```

Severity: 🔴 Blocker (breaks a later gate), 🟠 Costly-later (expensive to reverse after the consuming step), 🟡 Minor.

## Verdict rules

- **APPROVE** — no 🔴, and any 🟠 are acknowledged in the rationale. Stage may proceed to its gate.
- **REVISE** — one or more 🔴, or 🟠 cheap to fix now. The producer revises; the orchestrator issues a fresh request for a new cold round.
- **ESCALATE** — a finding is a genuine trade-off, not a defect (e.g. a Figma value that would break a gameplay calculation). State the options for the human. Never loop.

## Plan-review emphasis (decide-first stages)

Heavyweight at the stages whose decisions are expensive to unwind: **01** (level JSON schema, freezes at 05a), **04** (pre-integration checklist), **06** (visual strategy — sprite strategy, draw order, glow). Light sanity pass elsewhere.

## What review is not

- Not a correctness/lint pass on the current stage in isolation — that's the stage skill's own checklist. Review is purely forward-looking: only things a *later* stage will care about.
- Not authoritative over human gates. Sign-off is a soft gate; the device test and other human gates still stand.
