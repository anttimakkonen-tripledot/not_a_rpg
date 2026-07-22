# Reviewed Pipeline (Orchestrated, Independent Review)

This layers an orchestrator and an **independent** reviewer on top of the existing 8-step pipeline. Every step is reviewed twice — once at plan time, once at output time — by a reviewer subagent wearing the hat of the stages that will later consume the work.

It does not replace the stage skills. It drives them and gates them behind review.

---

## Why this exists

Your stages have expensive, one-way handoffs: the level schema freezes at 05a, the visual strategy locks at 06, shell-wiring bugs surface as port bugs much later. The cheapest place to catch those is before the consuming stage runs. A reviewer that shared the producer's context would inherit its rationalisations — so review runs as a subagent with its own fresh context window, seeing only the artifact, the downstream map, and `context/`. It raises only what a later step will care about, and cites that step.

The pipeline stays strictly sequential. Nothing is parallelised.

---

## Setup

```bash
# Skills
cp -R game-pipeline-orchestrator ~/.cursor/skills/
cp -R game-stage-review          ~/.cursor/skills/   # includes downstream-map.md + templates/

# Guardrail rule
cp rule-agent-orchestration.mdc .cursor/rules/

# Review handoff folder (per game project)
mkdir -p review
```

Restart Cursor. Run `game-pipeline-init` first on a new game, as before.

---

## How to drive it

| Intent | Say this in Cursor chat |
|---|---|
| See where things stand | `pipeline status` or `what's next` |
| Run the next step (with reviews) | `continue pipeline` or `orchestrate` |
| Confirm a manual/device gate | `gate confirmed 0X` |

---

## What happens per step

```
PLAN → PLAN REVIEW → EXECUTE → OUTPUT REVIEW → GATE → COMMIT
```

The producer writes a plan, executes on approval, and the orchestrator commits to `context/` only after the output review passes and any human gate clears. Each review returns **APPROVE**, **REVISE** (fix and resubmit, max 2 rounds), or **ESCALATE** (a real trade-off — handed to you, not looped).

---

## How the independent review runs

The orchestrator dispatches the review as a **subagent** — you don't open anything. A subagent runs in its own fresh context window with no access to the orchestrator's conversation, so the reviewer structurally can't see how the artifact was produced.

1. The orchestrator writes `review/REQUEST_<NN>_<plan|output>_r<round>.md` — the artifact and the exact allow-list the reviewer may read.
2. The orchestrator spawns a reviewer subagent whose only brief is "run `game-stage-review` on that request." It reads cold, evaluates, and writes `review/VERDICT_<NN>_<phase>_r<round>.md`, returning its verdict to the orchestrator.
3. The orchestrator reads the verdict and proceeds — APPROVE moves on, REVISE loops (max 2 rounds), ESCALATE stops for you.

The subagent is what makes the review honest: it has none of the producer's context, and the orchestrator passes **only** the request's allow-list into the dispatch — never the producer's output. A re-review is a brand-new subagent that never sees the previous verdict, so it can't rubber-stamp a claimed fix.

**Requirement:** Task-tool access must be enabled in the orchestrator's mode (hooks or tool policies can block subagent spawning). If a review never fires, check that first. If spawning is disabled, the fallback is to open a fresh Agents Window session on the request file yourself.

**Headless option:** for a fully unattended run there's a CLI driver (`run-pipeline.sh`), where each `agent -p` process is isolated the same way. For day-to-day work in the GUI, subagents are the simpler path.

---

## The reviewer's lens (examples, from your skills)

- Reviewing the **step 01 prototype** as the port agent: *"Nested arrays in this schema — I'll need Newtonsoft, not JsonUtility. And the RNG isn't seeded, so I can't hit parity at the 05a gate."*
- Reviewing the **step 04 shell** as the port agent: *"`livesEnabled` isn't 0 and this game has its own lose flow — the vanilla lives system will fight my retry."*
- Reviewing the **step 06 prefabs** as the clean-arch agent: *"SortingGroup on a UGUI element breaks Canvas batching, and the sprite-strategy decision isn't recorded — changing it later is a full rewire."*

Full map: `game-stage-review/downstream-map.md`.

---

## Hard human gates (orchestrator always stops)

| Step | What you do | Confirm with |
|---|---|---|
| 02 | Run plugin in Figma Desktop; read node IDs back | `gate confirmed 02` |
| 04 | Set FeatureFlags + AudioMixer param; confirm compile | `gate confirmed 04` |
| 05 P3 | Play in editor — win/lose flows | `gate confirmed 05` |
| 06 | **Device test** — build to device, verify flows, check logs | `gate confirmed 06` |
| 08 | Playtest after each layer, then full regression | `gate confirmed 08` |

Step 06's device gate is the strict one — don't confirm it from the editor.

---

## Rules worth knowing

- Producer ≠ reviewer: the review runs as a subagent with no producer context in its dispatch prompt.
- The reviewer reads only its request's allow-list and writes only its verdict file.
- Only the orchestrator writes `_INDEX.md` and `context_*.md`.
- A human gate is only ever cleared by you.
