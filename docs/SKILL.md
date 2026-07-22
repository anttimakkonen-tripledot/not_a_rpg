---
name: game-pipeline-orchestrator
description: Drive the full mobile game pipeline as a conductor — read _INDEX state, run each step through an INDEPENDENT cold review of its plan then its output, and stop at every human gate. Use when the user says 'orchestrate', 'run pipeline', 'what's next', 'continue pipeline', 'drive the pipeline', or 'pipeline status'.
---

# Pipeline Orchestrator

Single entry point for the 8-step game pipeline. Replaces manually typing `Step 0X`. Runs each step strictly in sequence, and gates every step behind an **independent** review: a separate cold agent session evaluates the plan and the output as the downstream stages that will consume them.

This skill does not do stage work, and does not perform reviews itself. It dispatches the stage skills, dispatches independent review sessions, reads their verdicts, and owns shared state.

## Core principle — independent review with future context

A reviewer that shares the producer's session inherits its rationalisations. So review runs as a **separate cold agent session** that sees only the artifact, the downstream-consumer map, and the named `context/` modules — never the producer's chat. It judges each plan/output as the future agent that will build on it. No step advances on the producer's say-so.

Invariants:
1. **Producer ≠ reviewer, and not the same session.** The orchestrator hands off via files; a fresh agent picks up the review cold.
2. **Never auto-advance across a human gate** (manual Unity work, device test, playtests).
3. **Only the orchestrator writes shared state** (`_INDEX.md`, `context/`). The reviewer writes only its verdict file.

## State — `context/_INDEX.md`

Read first, every invocation. Tokens: ✅ done · ⏭️ skipped · 🔲 pending · 🟡 in progress · 🔍 awaiting verdict · ⛔ blocked (human gate or ESCALATE).

Ledgers in `_INDEX.md` (scaffolded by the orchestration rule):
- **Gate ledger** — per gated step: `unmet` / `confirmed: <date>`
- **Review ledger** — per step+phase: latest verdict + round count + verdict-file path

## Review handoff protocol

The orchestrator never reviews inline. It dispatches the review as a **subagent** (the Task tool). A subagent runs in its own fresh context window with no access to this conversation, so the reviewer's independence is structural — it cannot inherit the producer's reasoning. For each review:

1. **Write the request.** From `~/.cursor/skills/game-stage-review/templates/REQUEST.md`, fill in stage, phase (`plan`|`output`), round, the artifact path(s), and the reading allow-list (downstream-map + the specific `context/` modules that step needs). Write to `review/REQUEST_<NN>_<phase>_r<round>.md`.
2. **Spawn the reviewer subagent.** Its entire brief is: *"Run `game-stage-review` on `review/REQUEST_<…>.md`, obey its cold-start contract."* Pass **nothing else** in the dispatch prompt — in particular never the producer's output, summary, rationale, or any prior-round verdict. The request's allow-list is all the reviewer gets. This is the only place independence could leak, so it is the one rule that must not bend.
3. **Collect.** Mark the step 🔍. The subagent writes `review/VERDICT_<NN>_<phase>_r<round>.md` and returns its verdict word (`APPROVE`|`REVISE`|`ESCALATE`) as its status. The orchestrator reads the verdict file and acts on it (below); it never edits a verdict file.

Requires Task-tool access in the orchestrator's mode — hooks or tool policies can block subagent spawning. If spawning is disabled, fall back to: write the request, ask the human to open a fresh Agents Window session on it.

A re-review (round 2+) is a brand-new subagent — fresh context, no prior verdict in scope — so it can't rubber-stamp "you said you fixed it."

## Per-step flow

```
1. PLAN          stage agent emits ./PLAN.md (files it will touch, decisions, contracts)
2. PLAN REVIEW   handoff → independent cold session → read verdict
                   APPROVE  → EXECUTE
                   REVISE   → stage agent revises PLAN.md; new cold request (round+1)
                   ESCALATE → ⛔ surface trade-off to human; wait
3. EXECUTE       stage skill runs
4. OUTPUT REVIEW handoff → independent cold session → read verdict
                   APPROVE  → GATE
                   REVISE   → stage agent fixes output; new cold request (round+1)
                   ESCALATE → ⛔ surface to human; wait
5. GATE          human gate → ⛔ print manual checklist, wait for `gate confirmed <NN>`.
                   Otherwise run the step's own validation checklist.
6. COMMIT        orchestrator updates context/ and _INDEX (✅); Active Focus → next step
```

Plan review is heavyweight at the three decide-first steps (01 schema, 04 pre-integration, 06 visual strategy), light elsewhere. Output review runs at every step.

## Review loop bounding

- Max **2 REVISE rounds** per phase. Still not APPROVE after round 2 → ⛔, hand open findings to the human; do not keep dispatching reviews.
- Record round counts and verdict-file paths in the Review ledger.
- ESCALATE never loops — straight to the human.

## Revision convention (on REVISE)

The reviewer stays cold, but the producer must stay anchored to what was flagged. So on a REVISE verdict:

1. The **producer** reads `review/VERDICT_<NN>_<phase>_r<round>.md` and addresses each finding.
2. The producer records a finding→change map: for a `plan` phase, fold it into the revised `./PLAN.md`; for an `output` phase, write `review/REVISION_<NN>_output_r<round+1>.md` (one line per finding: what changed). This is producer- and human-facing for audit — it is **not** in the next request's allow-list.
3. The orchestrator writes a fresh `REQUEST` for `round+1` pointing **only at the revised artifact** — no verdict, no revision note. The next cold reviewer re-evaluates from scratch; a genuinely-fixed 🔴 won't recur, an unfixed one will.

This keeps round 2 tethered to the findings without leaking anything to the independent reviewer.

## Stage map (all single-agent, sequential)

| Step | Skill | Plan review | Human gate |
|---|---|---|---|
| 01 Prototype | `game-prototype` | Heavy (schema freeze) | Schema frozen after approve |
| 02 Figma | `game-figma` | Light | Plugin run in Figma Desktop; node IDs read back |
| 03 Skin | `game-skin-prototype` | Light | Plays correctly after skin |
| 04 Vanilla | `game-prepare-vanilla` | Heavy (pre-integration) | FeatureFlags + AudioMixer set; compiles |
| 05 Port | `game-unity-port` | Light per phase | Phase 3 plays in editor |
| 06 Prefabs | `game-prefab-convert` | Heavy (visual strategy) | **Device test passed** |
| 07 Standards | `game-coding-standards` | Light | Game still plays; renames propagated |
| 08 Clean Arch | `game-clean-arch` | Light per layer | Playtest per layer; full regression |

## Human gates — hard stops

02 plugin run in Figma Desktop + node IDs read back · 04 FeatureFlags + AudioMixer param set, compiles · 05 P3 playable in editor · 06 **device test** (never confirm from editor) · 08 playtest per layer + full regression. Confirm via `gate confirmed <NN>`. An agent never confirms its own human gate.

## Status command

On `pipeline status` / `what's next`: print each step + token, Active Focus, latest review verdict per step (with round), any open REVISE round, any 🔍 awaiting verdict, any `unmet` gate with its checklist. Do not start work.

## Self-check before advancing

- [ ] Read `_INDEX.md` this turn
- [ ] Plan review verdict APPROVE (from an independent session) before EXECUTE
- [ ] Output review verdict APPROVE (from an independent session) before GATE
- [ ] Reviewer ran as a subagent (or fallback fresh session); no producer context in its dispatch prompt
- [ ] REVISE within 2 rounds, else escalated to human
- [ ] Human gate ahead → stopping, not advancing
