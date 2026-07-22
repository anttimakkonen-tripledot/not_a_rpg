# Downstream Consumer Map

The reviewer's reference. For each stage, who consumes its output downstream, and the exact lens the reviewer adopts — phrased as the future agent that will have to build on this work. Findings cite the consuming step so feedback is always justified by future context, not taste.

Severity:
- 🔴 **Blocker** — will break a later validation/human gate
- 🟠 **Costly-later** — reversible now, expensive or rework-heavy to change after the consuming step
- 🟡 **Minor** — worth noting, low cost

---

## Step 01 — Prototype  →  consumed by 02, 03, 05a, 05b

**Reviewer wears: the step-05 Unity-port agent, then the step-02 Figma agent.**

As the port agent (05a/05b), I will extract every type, enum, constant, and the RNG from this `prototype.html` and treat it as the spec. So I check:
- 🔴 Level JSON schema completeness — it freezes at 05a and changing it later is expensive. Is every field present and typed unambiguously? Is the shape stable, or still in flux?
- 🔴 Nested arrays in the schema → I'll need Newtonsoft, not JsonUtility. Flag any structure JsonUtility can't handle so the DTO decision is made now.
- 🔴 Seeded RNG — is it deterministic and portable (mulberry32-style)? If randomness isn't seeded, RNG-parity at the 05a gate is impossible.
- 🟠 Win/lose conditions — unambiguous enough to port exactly? Any implicit timing or RNG-order dependence I'd have to reverse-engineer?
- 🟠 Single-object vs array level format — does the schema commit to one, or will the loader have to detect both?

As the Figma agent (02):
- 🟠 Is `CONFIG.colors` complete with no hardcoded hex anywhere outside CONFIG? My plugin copies colours from CONFIG exactly — strays will desync.
- 🟡 Are the three screens (gameplay/win/lose) and their DOM structure clean enough to translate to frames?

---

## Step 02 — Figma plugin + node IDs  →  consumed by 03

**Reviewer wears: the step-03 skin agent.**

I will read each screen via `get_design_context` and diff against CONFIG. So I check:
- 🔴 Node IDs recorded in API format (colons, not hyphens) in `context_pipeline_and_figma.md` — wrong format and my readback fails.
- 🟠 Layer naming follows the convention (`Screen_`, `Panel_`, `Button_*_Face`/`_Shadow`, `Text_`, `Image_`) — I map by name; off-convention layers I can't reliably patch.
- 🟠 Figma colours match `CONFIG.colors` exactly — if the plugin invented values, my diff produces noise instead of real changes.

---

## Step 03 — Skin  →  consumed by 06 (and the art pass)

**Reviewer wears: the step-06 prefab agent / art director.**

I will set the visual strategy and may discard work that won't survive the art pass. So I check:
- 🟠 Did the skin bake in runtime tinting? Tinting looks flat and typically gets replaced — prefer per-asset sprite thinking even at prototype.
- 🔴 Did the skin touch game logic, the Level Editor, or JSON export? It must not — visual/CSS/CONFIG layer only. Logic regressions here surface as port bugs much later.
- 🟡 Are new decorative elements CSS-only (not new DOM) so the structure I convert to prefabs stays stable?

---

## Step 04 — Vanilla shell wiring  →  consumed by 05, 06

**Reviewer wears: the step-05 port agent.**

Integration bugs with the host shell are the single most common source of back-and-forth. So I check, before any gameplay code exists:
- 🔴 `livesEnabled: 0` if the game has its own lose flow — otherwise the vanilla lives system silently fights my lose/retry and I'll chase a ghost bug.
- 🔴 All asmdef references present (`Game.Services`, `VContainer`, `TMPro`, Forge UI) and added to the gameplay assemblies — missing refs are the classic "won't compile after 04".
- 🔴 AudioMixer exposed-param name matches `AudioService.prefab` exactly (`SoundVolume` vs `SoundsVolume`) — silent sound-toggle failure otherwise.
- 🟠 `ReviveTrigger` wired if revive is used; two-tier installer split correct (`InstallCore` has only what `MenuState.HasNextLevel` needs).
- 🟠 `HasNextLevel()` strategy decided (finite vs modulo) — hardcoded false repeats the same level forever.

---

## Step 05 — Unity port  →  consumed by 06, 08

**Reviewer wears: the step-06 prefab agent and the step-08 clean-arch agent.**

I will convert these views to prefabs, then refactor the whole thing into clean layers. So I check:
- 🔴 Per-item event contract — every model mutation that affects visuals fires a per-item C# event, never a single "batch changed" event. Batch events break my view updates now and the clean-arch refactor later.
- 🟠 Is the model logic separable from Unity (heading toward zero Unity deps)? If gameplay is tangled into MonoBehaviours, step 08 becomes a rewrite, not a refactor.
- 🔴 RNG parity actually verified against the prototype at the 05a gate — not assumed.
- 🟠 `CloseTransitionScreen()` placed in `InitialGameplayState.Enter()` after `await UniTask.WhenAll` — wrong placement is the black-screen bug.
- 🟠 `Cleanup()` destroys the board on exit — otherwise boards stack on re-entry.

---

## Step 06 — Prefab conversion  →  consumed by 08

**Reviewer wears: the step-08 clean-arch agent.**

I will wire these prefabs through DI and the presenter pattern. So I check:
- 🔴 Visual-strategy decisions recorded in `context_decisions.md` — changing sprite strategy / draw order later requires full prefab rewiring.
- 🔴 No `SortingGroup` on any UGUI element — it breaks Canvas batching and adds draw calls; draw order must be hierarchy-driven.
- 🟠 Naming convention consistent (`Board_`, `View_`, `Entity_`, `Button_`, `Text_`) so DI wiring and my presenter refactor are predictable.
- 🔴 Device test passed (not editor-only) — platform bugs (IL2CPP races, render diffs) are far cheaper here than after my refactor.

---

## Step 07 — Coding standards  →  consumed by 08

**Reviewer wears: the step-08 clean-arch agent.**

- 🔴 `.SetLink(gameObject)` on every tween — unlinked tweens keep updating after the board is destroyed and crash on the next frame.
- 🟠 DTO fields PascalCase + `[JsonProperty("camelCaseKey")]` — preserves backward compat with existing level JSON.
- 🟠 Dictionary value-type default trap handled — `default(enum)` returns the first value and silently matches missing keys.
- 🔴 Public-symbol renames propagated to all callers (the serial pass) — half-applied renames won't compile.

---

## Step 08 — Clean architecture  →  consumed by art/sound/polish and future features

**Reviewer wears: the next feature author (tutorials, pause, power-ups).**

- 🟠 Model layer genuinely zero Unity deps (unit-testable with plain NUnit)?
- 🟠 FSM scaffolded (Initializing/Playing/Paused/Won/Lost/WaitingForRevive) so future features have a home?
- 🔴 Per-item events preserved through the refactor — the most common regression when extracting services.
