# Plan F — Consumer: Avetta (ADS + the future avetta/ui stack)

**Goal (D12):** Figma integration for Avetta's future stack — `avetta/ui` main + Tailwind
v4 + elm-m3e + minor Material branding tweaks. Concretely: settle the "publish once"
question with a library-resolution experiment, build the ADS delta profile, express
Avetta's branding deviations in BOTH Figma (codeSyntax/variables) and code
(tailwind-m3e-web seed overrides), retire the abandoned `Ui.*` spike mappings, and leave
ADS carrying current-generation "Web Components" + "Elm" labels.

**Depends on:** Plan E complete (breadth pipeline proven on the M3 kit).

**⚠️ Standing rule for this whole plan:** ADS (`cbhz1J779WAI7gYkjCQwS0`) and anything
org-published is **Avetta's shared workspace**. Every write task below begins with its own
⚑ HUMAN approval checkbox naming exactly what will be written where — no write proceeds on
a stale or blanket authorization (mirror of how the 2026-07-10 planning session gated
writes). Reads are unrestricted.

**Key context an executor must know (evidence ledger + akg-synapse knowledge nodes):**
- ADS is a hard copy of an **older** kit version; it historically resolved Figma's managed
  MUI mappings while fresh drafts duplicates do not (evidence #5: duplication re-mints
  component keys). The published-library hypothesis (F1) explains both observations.
- ADS Colors collection is **single-mode (Light)**; dark theming is code-side via CSS
  `light-dark()` (akg node `knowledge/tools/vsd-figma-plugin.md`).
- The ADS catalog file `W1IBQUWis2VKLb726llMXu` carries **keyword-synonym descriptions** on
  4,208 components — a matching signal the M3 kit lacks; ADS variables carry **0
  codeSyntax** (akg node `knowledge/figma-files/elm-code-connect.md`).
- `avetta/ui@VOLT-2003` has 8 committed `code-connect/*.figma.ts` (the abandoned `Ui.*`
  spike) + a `figma:check` CI gate that must not break mid-plan.

---

### Task F1: The library-resolution experiment (settles "publish once")

**Files:** Create: `research/evidence/<date>-library-resolution.md`. No repo code.

Design: component keys re-mint on file duplication (evidence #5), but **instances of a
published library component reference the LIBRARY file's component keys** — if Code Connect
resolution walks instance → main component key → mapping, one publish against the library
file should resolve in every consumer file. This experiment proves or kills that.

- [ ] ⚑ HUMAN Approval: this task creates (a) an Avetta org copy of the M3 kit (or reuses
      an existing org copy), (b) publishes it as an org library, (c) creates one scratch
      consumer file, (d) publishes CC bindings against the library file. Name the team/
      project placement before proceeding; prefer a low-traffic team.
- [ ] ⚑ HUMAN Move/copy the kit into an org team project and **publish it as a library**
      (Figma UI: Assets → Publish). Record its fileKey as `<LIB>`.
- [ ] ⚑ HUMAN Create a scratch consumer file in the same team; enable the library; drop
      3 Button instances (different variants) + 1 Chip + 1 icon onto the canvas. Record
      fileKey `<CONSUMER>` and the instance node-ids.
- [ ] Publish the m3-kit profile's Button/Chip/icon bindings against `<LIB>`:
      `node src/cli.mjs publish --profile m3-kit --file-key <LIB>` (dry-run → real).
- [ ] Probe the CONSUMER file: `get_code_connect_map` on each instance node-id, both
      labels. Also `get_design_context` on a frame containing them (does
      `CodeConnectSnippet` appear for library instances?).
- [ ] Record the outcome in the evidence file:
      **Outcome A (resolves):** org consumption model = publish once against the org
      library; every org file using library instances inherits. Update
      `docs/ADOPT.md` + `plans/00-mission-and-decisions.md` consumption-model section.
      **Outcome B (does not resolve):** per-file republish stands (evidence #5); the tool
      already automates it; document that org rollout = republishing against each
      first-class file (ADS + any others), which is one CLI run each.
- [ ] Bonus probe while the library exists: does Figma's managed MUI layer light up on the
      org copy (it did on ADS, didn't on drafts duplicates)? One `get_code_connect_map`
      call on the library file's old-generation Button set if present; note result.
- [ ] ⚑ HUMAN Cleanup decision: keep the library (it becomes the F7 publish target under
      Outcome A) or unpublish/delete the scratch artifacts.

**Commit:** `docs(evidence): library-resolution experiment outcome`

### Task F2: ADS extraction + inventory diff

**Files:** Create: `research/figma-dumps/ads-components.json`,
`profiles/avetta-ads/inventory-diff.md`.

- [ ] ⚑ HUMAN Session: open ADS in Figma desktop **in Design mode**, start the WS bridge
      (read-only commands only in this task). Dev seat cannot edit ADS (`can_edit:false`
      per akg node) — Design-mode open may require a viewer arrangement; if the bridge
      rejects (Dev-mode-read-only friction), fall back to the REST API for
      components/component-sets and the existing catalog knowledge: the akg-synapse node
      `knowledge/figma-files/elm-code-connect.md` is the primary pointer — its underlying
      dump (`figma-plugin-dumps/elm-code-connect.json`) is gitignored and must be
      regenerated per that node's runbook.
- [ ] Extract ADS components + variables + styles into
      `research/figma-dumps/ads-components.json` (same schema as the kit dump — the
      `extract/` schema from Plan A).
- [ ] Diff against the m3-kit dump: per component set — present/absent, node-id drift
      (expected: ADS predates the Expressive rebuild, so Buttons etc. exist as OLD sets
      with different node-ids and axes), variant-axis differences, and Avetta-only sets.
      Write `inventory-diff.md` with three sections: re-anchor (same component, new
      node-id/axes), missing-from-ADS (Expressive-era components), Avetta-only.
- [ ] Exploit the keyword-synonym descriptions (Avetta-only matching signal): feed them to
      the matcher's fuzzy tier for the Avetta-only set proposals.

**Commit:** `feat(avetta-ads): extraction + inventory diff vs m3-kit pin`

### Task F3: ADS delta profile

**Files:** Create: `profiles/avetta-ads/profile.json` (extends `m3-kit`),
`profiles/avetta-ads/overrides.json`, `profiles/avetta-ads/gap-report.md`.

- [ ] Profile mechanics (architecture §3, delta overlay): `extends: "m3-kit"`, ADS fileKey,
      re-anchor map (node-id substitutions from F2), suppressions (components missing from
      ADS emit nothing — no dead URLs), additions (Avetta-only components with their own
      correspondence entries; snippet target per F5 policy).
- [ ] Run matcher + merge for the delta:
      `node src/cli.mjs match --profile avetta-ads` (A6: `match` re-merges through the
      human-preserving merge). Determinism verify:
      run twice, `git diff --exit-code profiles/avetta-ads/` clean.
- [ ] ⚑ HUMAN Review session over the ADS proposals (component+property level), same
      protocol as Task E2; decisions persist in `overrides.json`.

**Commit:** `feat(avetta-ads): delta profile over m3-kit`

### Task F4: Branding deviations — token delta table (Figma ↔ code)

**Files:** Create: `profiles/avetta-ads/tokens.json`, `profiles/avetta-ads/branding.md`.

The user's core ask: Avetta = stock Material + **minor branding tweaks**, expressed in both
worlds. tailwind-m3e-web derives its entire palette from seeds
(`--md-seed-primary`, `--md-seed-error`, + roles-extended) through a calibrated OKLCH
3-tier cascade — so the code-side delta should be a **seed override**, not 49 role
overrides.

- [ ] Extract ADS `Schemes/*` variable values (from F2 dump; single Light mode).
- [ ] Using Plan D's mismatch tooling (culori is already a tailwind-m3e-web devDep):
      solve for the seed values whose cascade output reproduces the ADS role palette;
      record per-role deltaE (OKLCH) in `branding.md`. Threshold: roles within the
      tolerance Plan D set for "naming discrepancy vs spec failure"; any role exceeding it
      is listed as a **spec divergence** with a recommendation (adjust seed vs per-role
      override vs flag ADS value as the error) — never silently absorbed (plans/BRIEF.md §9).
- [ ] Emit the code-side artifact: a documented `@theme`/seed override snippet for
      `tailwind-m3e-web` consumers (`branding.md` includes it verbatim) — e.g.
      `--md-seed-primary: <value>;` and any unavoidable per-role overrides.
- [ ] Visual parity check: reuse the Plan C harness with the seed overrides applied
      (harness already supports `--md-sys-*` overrides per its NOTES) — render Button
      filled/tonal/outlined against ADS `export-png`s of the same components; diff within
      Plan C threshold.
- [ ] Dark theme note: ADS Figma has no dark mode; dark remains code-side `light-dark()`
      (verified akg finding) — document that Figma parity is Light-only by construction.

**Commit:** `feat(avetta-ads): branding token delta (seed-derived) + parity evidence`

### Task F5: codeSyntax stamping on ADS

**Files:** Stamp scripts regenerated (Plan D's generator) from the avetta-ads token table
(F4) — not Plan D's canonical m3-kit scripts; log in `research/evidence/`.

- [ ] ⚑ HUMAN Approval: this writes `codeSyntax` (WEB) onto ADS variables — org-visible
      metadata (harmless to rendering, visible in Dev Mode/inspect). Name the exact
      variable set (the `Schemes/*` + typescale/shape variables in the token table) and get
      sign-off; coordinate with the design-team owner of ADS.
- [ ] Run the stamp scripts regenerated from the avetta-ads token table (F4) against ADS
      via `use_figma` (evidence #6 mechanism; scripts locate variables by name per D3's
      portability mandate); verify with a `get_design_context` probe on an ADS frame →
      emitted vars speak `--md-sys-*`.
- [ ] Record before/after in the evidence ledger (stamps are reversible — keep the inverse
      script alongside).

**Commit:** `docs(evidence): ADS codeSyntax stamping record`

### Task F6: Stale `Ui.*` mapping retirement

**Files (avetta/ui):** possibly delete `code-connect/*.figma.ts` + annotations; this repo:
`research/evidence/<date>-ads-cc-inventory.md`.

- [ ] Inventory published CC in ADS: scripted `get_code_connect_map` sweep over the known
      spike nodes (Avatar 70620-97, Badge 70622-99, Chip×4 70575-89/96/103/110, Progress
      58005-7997/8459) + the F2 dump's `Ui.*`-page sets; classify each mapping
      live/stale/dead-branch.
- [ ] ⚑ HUMAN Disposition per entry with the user (retire vs keep) — the spike is
      abandoned (D12 context) but `avetta/ui` owners must agree since VOLT-2003's
      `figma:check` CI enforces annotation↔file coherence: retiring means removing BOTH the
      `@figma-code-connect` annotations in `src/elm/Ui/*.elm` AND the committed
      `.figma.ts`, in one branch, keeping `npm run figma:check` green.
- [ ] ⚑ HUMAN Unpublish approved-stale mappings (`figma connect unpublish` per label
      against ADS); re-sweep to confirm zero stale `Ui.*` snippets remain.

**Commit (avetta/ui branch):** `chore: retire abandoned Ui.* Code Connect spike (superseded by elm-m3e bindings)`

### Task F7: Publish current-generation labels for Avetta

**Files:** none (remote state); evidence log.

- [ ] Target per F1 outcome: **Outcome A** → publish the avetta-ads profile against the
      org library `<LIB>` (+ ADS directly for its old-generation re-anchored sets);
      **Outcome B** → publish directly against ADS fileKey.
- [ ] ⚑ HUMAN Approval + token gate (org publish). Dry-run → real → MCP spot-matrix (both
      labels, sampled per page) → Dev Mode eyeball by the user.

**Commit:** `docs(evidence): Avetta publish verification matrix`

### Task F8: avetta/ui integration posture (non-blocking, D13)

**Files:** Create `docs/AVETTA.md` (this repo).

- [ ] Document the decoupling: snippets are strings — ADS shows `M3e.*` + `<m3e-*>` code
      before `avetta/ui` imports elm-m3e; that is the intended interim (user endgame:
      avetta/ui main + tw4 + elm-m3e). Note the switch point: once avetta/ui adopts
      elm-m3e + Tailwind v4 (migration workspace: `~/code/avetta/ui.tw4-pr4-wip`), snippets
      become directly pasteable; the branding seed overrides from F4 are the tw4 hook.
- [ ] List what avetta/ui does NOT need from this plan: no elm-review rule, no generator,
      no annotations — the VOLT-2003 machinery is superseded for `Ui.*`; Mercury/legacy
      components are out of scope here.

**Commit:** `docs: Avetta integration posture`

---

## Acceptance (Plan F done)

- [ ] Library-resolution question answered with recorded evidence; consumption model
      section updated to match reality.
- [ ] `profiles/avetta-ads/` publishes green (dry-run + real per F7); ADS carries
      current-generation "Web Components" + "Elm" labels on stock components; Avetta-only
      components covered or explicitly gapped.
- [ ] Branding delta: seed-override table committed; visual parity within threshold or
      divergences explicitly classified (naming vs spec failure); Figma-side codeSyntax
      stamped with sign-off.
- [ ] Zero stale `Ui.*` mappings in ADS; `avetta/ui` `npm run figma:check` green after the
      retirement branch.
- [ ] Every org write in the log has its ⚑ HUMAN approval recorded.
- [ ] Follow-up reminders emitted (upstream `matraic/m3e` PR per D11; token rotation;
      public-release IP/license review).
