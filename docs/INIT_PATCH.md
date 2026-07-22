# Patch: scaffold the review layer in `game-pipeline-init`

Apply these edits to your existing `game-pipeline-init` skill so every new game project comes up review-ready. The orchestrator and reviewer skills are **global** (installed once to `~/.cursor/skills/`), so init does not copy them — it only scaffolds the per-project pieces: the rule, the `review/` folder, and the two `_INDEX.md` ledgers.

---

## 1. One-time global install (document in the skill's setup notes)

```bash
cp -R game-pipeline-orchestrator ~/.cursor/skills/
cp -R game-stage-review          ~/.cursor/skills/
```

Per-project copy is wrong for these — they're not game-specific.

## 2. Add to "Step 2 — Create files" → Rules

Add one line to the always-apply rules written into `.cursor/rules/`:

```
- .cursor/rules/rule-agent-orchestration.mdc ← templates/rules/rule-agent-orchestration.md (write as .mdc)
```

## 3. Add a "Review handoff" creation step

After writing the context files, create the handoff folder so the orchestrator has somewhere to write requests:

```bash
mkdir -p review
: > review/.gitkeep
```

## 4. Append the two ledgers to `templates/context/_INDEX.md`

Paste this block at the end of the `_INDEX.md` template. The orchestrator reads and maintains it.

```markdown
---

## Gate ledger
Human gates. Only a human flips these to `confirmed: <date>` via `gate confirmed <NN>`.

- [02] figma-plugin: unmet      # plugin run in Figma Desktop; node IDs read back
- [04] vanilla-wiring: unmet    # FeatureFlags + AudioMixer param set; compiles
- [05] editor-playtest: unmet   # Phase 3 playable in editor
- [06] device-test: unmet       # built to physical device; flows verified
- [08] regression: unmet        # per-layer playtest + full regression

## Review ledger
Latest independent-review verdict per step. Orchestrator-owned.

| Step | Plan verdict | Output verdict | Rounds | Latest verdict file |
|------|--------------|----------------|--------|---------------------|
| 01   | —            | —              | 0      | —                   |
| 02   | —            | —              | 0      | —                   |
| 03   | —            | —              | 0      | —                   |
| 04   | —            | —              | 0      | —                   |
| 05   | —            | —              | 0      | —                   |
| 06   | —            | —              | 0      | —                   |
| 07   | —            | —              | 0      | —                   |
| 08   | —            | —              | 0      | —                   |
```

## 5. Add to the init summary table

When init prints its file-creation summary, include the `review/` folder and the new rule so the user can confirm the review layer scaffolded correctly.

---

## After patching

A fresh `game-pipeline-init` run now produces a project where `continue pipeline` works immediately: the ledgers exist, the `review/` folder exists, and the guardrail rule is active. The global orchestrator and reviewer skills are picked up by trigger phrase.
