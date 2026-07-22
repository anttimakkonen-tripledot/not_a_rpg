#!/usr/bin/env bash
#
# run-pipeline.sh — drive the reviewed game pipeline via the Cursor headless CLI.
#
# Each `agent -p` call is a separate process, so the producer and the reviewer
# never share context — the independence is structural, not just promised.
#
# What it automates:  producer plan, independent review, execute, independent
#                     review, and the REVISE loop — chained across steps.
# What it can't:       human gates (Figma plugin run, Unity Editor, device test).
#                     It halts at each one and tells you how to resume.
#
# Requires: Cursor CLI (`curl https://cursor.com/install -fsS | bash`),
#           CURSOR_API_KEY exported, the orchestrator + review skills installed
#           globally, and a project scaffolded by game-pipeline-init.
#
# Usage:    ./run-pipeline.sh 01        # start at step 01, chain until a gate
#           ./run-pipeline.sh 05        # resume at step 05 after clearing a gate
#
set -euo pipefail

START_STEP="${1:?usage: ./run-pipeline.sh <NN>   (e.g. 01)}"
MAX_REVISE_ROUNDS=2
REVIEW_DIR="review"
mkdir -p "$REVIEW_DIR"

command -v agent >/dev/null || { echo "Cursor CLI 'agent' not found. Install: curl https://cursor.com/install -fsS | bash"; exit 1; }
: "${CURSOR_API_KEY:?export CURSOR_API_KEY first}"

# Steps that end at (or are immediately followed by) a hard human gate.
# The driver completes the agent work for the step, then stops here.
declare -A HUMAN_GATE=(
  [01]="Run the Figma plugin in step 02 next — that needs Figma Desktop."
  [02]="Run the plugin in Figma Desktop, confirm frames on canvas, then resume."
  [04]="Set FeatureFlags + AudioMixer param in Unity Editor; confirm it compiles."
  [05]="Press Play in Unity — verify win/lose flows in the editor."
  [06]="Build to a physical device and run the device-test checklist."
  [08]="Playtest after each layer, then full regression."
)

# Stage skill trigger phrase per step.
declare -A STAGE_SKILL=(
  [01]="game-prototype (Step 01)"     [02]="game-figma (Step 02)"
  [03]="game-skin-prototype (Step 03)" [04]="game-prepare-vanilla (Step 04)"
  [05]="game-unity-port (Step 05)"     [06]="game-prefab-convert (Step 06)"
  [07]="game-coding-standards (Step 07)" [08]="game-clean-arch (Step 08)"
)

ALL_STEPS=(01 02 03 04 05 06 07 08)

# --- helpers ---------------------------------------------------------------

# Producer writes/updates ./PLAN.md for the step (no implementation yet).
produce_plan () {
  local step="$1"
  agent -p --force \
    "Pipeline step ${step}. Write ./PLAN.md only: the files you will create or
     change, the contracts/decisions a downstream stage depends on, and any
     schema or visual-strategy choices. Do NOT implement yet."
}

# Independent COLD review. Separate process => no producer context.
# Returns the verdict word on stdout (APPROVE | REVISE | ESCALATE).
review () {
  local step="$1" phase="$2" round="$3"
  local req="${REVIEW_DIR}/REQUEST_${step}_${phase}_r${round}.md"

  # Orchestrator (this script) owns the request file.
  cat > "$req" <<REQ
# Review Request — Step ${step} (${phase}) — round ${round}
stage: ${step}
phase: ${phase}
round: ${round}

## Artifact
$( [[ "$phase" == "plan" ]] && echo "./PLAN.md" || echo "the files changed by step ${step}" )

## Reading allow-list (read NOTHING else; do not read prior verdicts or producer notes)
- ~/.cursor/skills/game-stage-review/downstream-map.md
- context/  (only the modules relevant to step ${step})
- the artifact above

## Output
End your final message with a single line:  VERDICT: APPROVE | REVISE | ESCALATE
Also write review/VERDICT_${step}_${phase}_r${round}.md in the standard format.
REQ

  # --output-format json so we can parse; --force lets it write the verdict file.
  local out
  out="$(agent -p --force --output-format json \
        "Use the game-stage-review skill on ${req}. Obey its cold-start contract." \
        | jq -r '.result')"

  echo "$out" | grep -oE 'VERDICT: (APPROVE|REVISE|ESCALATE)' | tail -1 | awk '{print $2}'
}

# Producer addresses the verdict, then re-emits the artifact for a fresh round.
revise () {
  local step="$1" phase="$2" prev_round="$3"
  local verdict_file="${REVIEW_DIR}/VERDICT_${step}_${phase}_r${prev_round}.md"
  agent -p --force \
    "Pipeline step ${step}. Read ${verdict_file}. Address every finding. Record a
     finding->change map ( $( [[ "$phase" == plan ]] && echo "in ./PLAN.md" || echo "in review/REVISION_${step}_output_r$((prev_round+1)).md" ) ).
     Then re-emit the $( [[ "$phase" == plan ]] && echo "plan" || echo "implementation" )."
}

execute_stage () {
  local step="$1"
  agent -p --force "Run the ${STAGE_SKILL[$step]} skill, implementing the approved PLAN.md."
}

# Runs plan-or-output review with the bounded REVISE loop.
# Exits the script on ESCALATE or exhausted rounds.
review_loop () {
  local step="$1" phase="$2"
  local round=1 verdict
  while :; do
    verdict="$(review "$step" "$phase" "$round")"
    echo "  step ${step} ${phase} review r${round}: ${verdict}"
    case "$verdict" in
      APPROVE)  return 0 ;;
      ESCALATE) echo ">> ESCALATE on step ${step} ${phase}. See review/VERDICT_${step}_${phase}_r${round}.md. Human call needed."; exit 2 ;;
      REVISE)
        if (( round >= MAX_REVISE_ROUNDS )); then
          echo ">> Still REVISE after ${MAX_REVISE_ROUNDS} rounds on step ${step} ${phase}. Open findings handed to you."; exit 3
        fi
        revise "$step" "$phase" "$round"
        round=$((round+1)) ;;
      *) echo ">> Could not parse a verdict for step ${step} ${phase}. Check the review session output."; exit 4 ;;
    esac
  done
}

# --- main loop -------------------------------------------------------------

started=0
for step in "${ALL_STEPS[@]}"; do
  [[ "$step" < "$START_STEP" ]] && continue
  started=1
  echo "=== Step ${step} ==========================================="

  produce_plan   "$step"
  review_loop    "$step" plan
  execute_stage  "$step"
  review_loop    "$step" output

  echo "  step ${step}: reviews passed."

  if [[ -n "${HUMAN_GATE[$step]:-}" ]]; then
    echo ""
    echo ">> HUMAN GATE after step ${step}:"
    echo "   ${HUMAN_GATE[$step]}"
    echo "   When done, confirm in _INDEX and resume:  ./run-pipeline.sh $(printf '%02d' $((10#$step + 1)))"
    exit 0
  fi
done

[[ "$started" == 1 ]] || { echo "No steps at/after ${START_STEP}."; exit 1; }
echo "=== Pipeline complete through step 08. ==="
