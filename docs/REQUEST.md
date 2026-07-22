# Review Request — Step {{STAGE}} ({{PHASE}}) — round {{ROUND}}

> Written by the orchestrator. Read by an independent cold reviewer session.
> The reviewer reads ONLY the allow-list below. It must not read the producer
> session, prior-round verdicts, or any other file.

- stage: {{STAGE}}
- phase: {{PHASE}}          # plan | output
- round: {{ROUND}}

## Artifact to review
{{ARTIFACT_PATHS}}           # e.g. ./PLAN.md   or   ./prototype.html

## Reading allow-list (read nothing else)
- ~/.cursor/skills/game-stage-review/downstream-map.md
- {{CONTEXT_MODULES}}        # e.g. context/context_gameplay.md, context/context_common_pitfalls.md
- {{ARTIFACT_PATHS}}

## Output
Write your verdict to: review/VERDICT_{{STAGE}}_{{PHASE}}_r{{ROUND}}.md
Use the game-stage-review verdict format. Touch no other file.
