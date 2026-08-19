# Plan D — Tokens: correspondence, codeSyntax, density policy

> Read first: [`../00-mission-and-decisions.md`](../00-mission-and-decisions.md) (decisions
> D4/D12, evidence #4/#6/#13), [`../01-architecture.md`](../01-architecture.md) §1 (token
> authority rows) and §5 (no Tailwind label). Depends on Plan A (figma ingest + overrides
> merge). Independent of B/C — runs in a parallel pane.

**Goal.** One checked-in token table relating **Figma variable ↔ canonical `--md-*` token ↔
tailwind-m3e-web utility/theme key ↔ @m3e/web fallback value**, and from it: (1) a
codeSyntax stamping pass that makes ALL Figma-generated layout code speak our vocabulary
(the proven Tailwind-leg mechanism, evidence #6), (2) a mismatch report classifying every
cross-source disagreement as *naming discrepancy* (map it) or *spec failure* (file a
required-code-change), (3) an explicit, documented density/spacing policy.

**Why no Tailwind Code Connect label:** decision D4 — if the component models it, use the
attribute; Tailwind is layout scaffolding. The MCP already returns Tailwind classes for
frames (evidence #4); our job is to make the *names inside them* correct via codeSyntax
(evidence #6), not to publish per-component Tailwind snippets.

**The inputs (all checked in):**
- `research/figma-dumps/kit-variables.json` — 4 collections; `M3` (32 modes: Light/Dark ×
  default/Medium/High contrast + 13 hue LT/DT), `Font theme` (Baseline/Wireframe),
  `Typescale` (Baseline), `Shape` (Baseline). 304 variables: `Schemes/*` 49, `State Layers/*`
  147, `Static/*` 95, `Corner/*` 10, `Tracking/*` 2, `Add-ons` 1. **0 codeSyntax** shipped
  (evidence #13).
- `research/figma-dumps/kit-styles.json` — 727 paint / 30 text / 10 effect styles.
- `~/code/jackhp95/tailwind-m3e-web` — `src/theme.css` (the `@theme` mapping to Tailwind
  namespaces), `src/sys/*.css` (`--md-sys-color-*` via `light-dark()`, `--md-sys-typescale-*`,
  `--md-sys-shape-corner-*`, `--md-sys-state-*`, density), `generated/CSS_CUSTOM_PROPERTIES.md`
  (2,254 `--m3e-*` component vars). Uses `culori` — reuse it for color math.
- The CEM's token variable declarations (`src/core/shared/tokens/*.ts` in @m3e/web):
  `unsafeCSS("var(--md-sys-color-primary, #6750A4)")` — 106 `--md-sys-*` refs with baked
  fallbacks (the code side's expected values).

---

### Task D1: Normalize the kit token dump

**Files:** Create: `src/tokens/ingest.mjs`, `src/tokens/ingest.test.mjs`.

- [ ] **Step 1:** Probe the dump's exact field shape first
  (`jq '.collections[0], .variables[0]' research/figma-dumps/kit-variables.json`) — write
  the loader against what IS there (names observed 2026-07-10: `collections[].name`,
  `collections[].modes[].name`, `variables[].name/.resolvedType/.codeSyntax`, per-mode
  values). Validate with a small JSON Schema like Plan A's ingests.
- [ ] **Step 2:** Normalize to
  `{id, name, family, collection, type, valuesByModeName, aliasOf?, codeSyntax}` — family =
  first path segment (`Schemes`, `State Layers`, `Static`, `Corner`, `Tracking`); resolve
  alias chains to terminal values per mode (kit variables may alias other variables).
- [ ] **Step 3:** Modes of record: `Light` and `Dark` are required to resolve; the 13 hue
  themes + contrast tiers parse but are audit-only (see Task D5 Step 4).
- [ ] **Step 4:** Styles: load text styles (30) into the same model tagged `style:text`
  (typescale lives in BOTH variables (`Static/*`) and text styles — keep both, the table
  maps whichever the generated code references; evidence #4 showed `--static/body-large/*`
  slugs from variables).

**Verify:** `node --test src/tokens/ingest.test.mjs` → family counts equal the measured
49/147/95/10/2 split.
**Commit:** `feat(tokens): normalized ingest of kit variables + text styles`

### Task D2: The token correspondence table

**Files:** Create: `src/tokens/derive.mjs`, `profiles/m3-kit/tokens.json`,
`profiles/m3-kit/tokens-overrides.json`, `src/tokens/derive.test.mjs`.

Row shape:
```jsonc
{
  "figma": "Schemes/On Surface",              // variable name (or style: prefix)
  "md": "--md-sys-color-on-surface",          // canonical M3 custom property
  "tailwind": { "theme": "--color-on-surface", "utils": ["text-on-surface", "bg-on-surface"] },
  "m3eFallback": "#1D1B20",                   // from @m3e/web token declarations, if referenced
  "provenance": "auto | human",
  "status": "mapped | unmapped | policy",      // policy = intentionally not mapped (see D6)
  "note": "…"
}
```

- [ ] **Step 1 (auto-derivation):** `Schemes/<Role>` → kebab-case →
  `--md-sys-color-<role>` is mechanical (`On Surface Variant` →
  `on-surface-variant`); `Corner/<Size>` → `--md-sys-shape-corner-<size>`;
  `Static/<Scale>/<Prop>` → `--md-sys-typescale-<scale>-<prop>` (verify slug spelling
  against `tailwind-m3e-web/src/sys/typescale.css`, which is the naming source of truth on
  the code side). Emit `provenance: "auto"`.
- [ ] **Step 2 (tailwind join):** parse `tailwind-m3e-web/src/theme.css` `@theme` block to
  join each `--md-*` name to its Tailwind theme key and representative utilities. Missing
  joins are real findings (a sys token tailwind doesn't surface), not errors — mark
  `status: "unmapped"` with note.
- [ ] **Step 3 (fallback join):** grep the @m3e/web token declarations (the CEM copy pinned
  by the profile) for `var(--md-sys-…, <fallback>)`; attach fallbacks where the name
  matches.
- [ ] **Step 4 (human confirm):** rows the auto-pass can't derive confidently — the whole
  `State Layers/*` family, `Tracking/*`, `Add-ons`, any `Static/*` slug that didn't join —
  are emitted `status: "unmapped"` and listed in a review section. ⚑ HUMAN confirms/edits
  via `tokens-overrides.json` (same deep-merge + provenance semantics as Plan A overrides;
  the deriver never overwrites a human row).
- [ ] **Step 5:** Determinism: `node src/tokens/derive.mjs --check` regenerates and diffs
  (byte-stable, ground rule).

**Verify:** `node --test src/tokens/derive.test.mjs`; `derive.mjs --check` exits 0;
Schemes coverage 49/49 rows `mapped`.
**Commit:** `feat(tokens): auto-derived token table with override merge (m3-kit profile)`

### Task D3: codeSyntax stamping (the Tailwind-leg mechanism)

**Files:** Create: `src/tokens/stamp.mjs` (emits scripts), `profiles/m3-kit/stamp/`
(generated `use_figma` scripts, committed).

The proven mechanism (evidence #6, demonstrated live 2026-07-10 on the throwaway Copy):
`variable.setVariableCodeSyntax("WEB", "var(--md-sys-color-on-surface)")` via `use_figma`
→ `get_design_context` immediately emits
`var(--md-sys-color-on-surface,#1d1b20)` in generated layout code. **No custom plugin
needed** for this pass.

- [ ] **Step 1:** `stamp.mjs --profile m3-kit --out profiles/m3-kit/stamp/` generates the
  scripts from the token table (only `status: "mapped"` rows): for each variable,
  `setVariableCodeSyntax("WEB", "var(<md>)")`. **Portability mandate:** generated scripts
  locate variables **by name** (`figma.variables.getLocalVariablesAsync()` + name match),
  NEVER by baked-in variable id — ids re-mint across file copies (evidence #5), and the
  same script must run against the canonical copy, the throwaway Copy, and ADS.
  **Idempotent:** each script reads `v.codeSyntax.WEB` first and skips already-correct
  values; returns `{stamped, skipped, mutatedVariableIds}`.
- [ ] **Step 2:** Respect the `figma-use` skill's incremental rule: chunk ≤ ~40 variable
  writes per script (they're one logical loop, but keep scripts small enough to read
  errors); scripts are numbered `01-schemes.js`, `02-corner.js`, `03-static.js`.
- [ ] **Step 3:** Generate the inverse: `unstamp/` scripts restoring `codeSyntax` to `{}`
  (or to a recorded pre-state snapshot taken by script 00 — emit `00-snapshot.js` that
  returns current codeSyntax for all target ids; the runner saves it beside the run log).
- [ ] **Step 4:** `--dry-run` mode: emit a delta table (variable → current → intended) from
  the checked-in dump without any Figma call.
- [ ] **Step 5 ⚑ HUMAN:** stamping a FILE is a per-file authorization: the runbook says
  which fileKey (canonical copy `KujuFlfJSwHI6ua1b7RZvL` vs consumer copies vs ADS in Plan
  F) and requires the user's go per target. Execution is via the Figma MCP `use_figma`
  tool (an agent session) — document the exact invocation in
  `profiles/m3-kit/stamp/README.md`, including `skillNames: "resource:figma-use"`.

**Verify:** `stamp.mjs --dry-run` on the checked-in dump lists exactly the mapped rows;
re-running the generator is byte-stable; ⚑ HUMAN: applying `01-schemes.js` to the throwaway
Copy (`iPFL8MH2R1Xphe94j7g809`) then `get_design_context` on node `56576:34730` reproduces
evidence #6 (emits `--md-sys-color-*` names) — this exact check is the acceptance replay.
**Commit:** `feat(tokens): idempotent codeSyntax stamp/unstamp script generation`

### Task D4: Density & spacing policy (scoped down, with rationale)

**Files:** Create: `docs/density-and-spacing.md`. Modify: `profiles/m3-kit/tokens.json`
(spacing advisory table).

The brief (plans/BRIEF.md §9) demands density-sensitive spacing. **Measured reality (evidence #13, #4):**
the kit has NO spacing/density variables, and frame-level generated code hard-codes px
(`px-[24px]`, `gap-[8px]`). There is nothing on the Figma side to bind a density formula
to. Policy, recorded as a deliberate scope decision:

- [ ] **Step 1:** Document the split: **component-internal** spacing is the web component's
  runtime concern — consumers use tailwind-m3e-web's `density-0..3` scope utilities
  (each step trims 4px inside @m3e/web components; already shipped). The token table's
  job here is nothing — components read `--md-sys-density-*` themselves.
- [ ] **Step 2:** **Between-component** spacing in Figma-generated layout stays literal px
  in v1. Provide an advisory mapping table in the profile
  (`8 → gap-2 / m3e spacing token n/a`, `16 → gap-4`, …) surfaced in docs and available to
  agents adapting MCP output — but the tool does NOT rewrite px automatically (rewriting
  risks breaking visual parity with the design, which is authoritative — architecture §1).
- [ ] **Step 3:** Record the follow-up idea (explicitly out of v1): ADD spacing variables to
  the kit copy (they'd be ours, not Google's), bind example frames' auto-layout gaps to
  them, stamp codeSyntax → generated layout would emit named spacing. Park with rationale
  in `docs/density-and-spacing.md#future`.

**Verify:** doc exists, cross-linked from the profile README; advisory table renders in the
gap-report tooling (Plan A) without being applied automatically.
**Commit:** `docs(tokens): density/spacing policy — component-internal vs layout, v1 scope`

### Task D5: Cross-source mismatch report

**Files:** Create: `src/tokens/audit.mjs`, `src/tokens/audit.test.mjs`,
`profiles/m3-kit/token-audit.md` (generated).

Three sources of truth for each color role: kit variable per-mode hex (design intent),
tailwind-m3e-web's OKLCH-derived value (computed from seed via
`oklch(from var(--md-seed-*) …)` + calibrated tone table), and @m3e/web's baked fallback.

- [ ] **Step 1:** Resolve tailwind-m3e-web's computed Light/Dark values: reuse its own
  machinery — `culori` + its `_tone-table.css` + `palette.css` derivation (import the repo
  as a dev dependency of the profile workspace, or execute its calibrate/test path; do NOT
  reimplement the OKLCH math here).
- [ ] **Step 2:** Compare per role: kit `Light`/`Dark` hex vs computed vs fallback, deltaE
  (culori `differenceCiede2000`), tolerance configurable (start 2.0 — perceptibility
  threshold; calibrate on the known-identical roles).
- [ ] **Step 3:** Classify each row over tolerance: `naming-discrepancy` (values agree,
  names differ → fix the table mapping) vs `spec-failure` (values disagree → per §9 of the
  brief and architecture §1, Figma wins on design intent: emit a **required-code-change**
  entry naming the repo (tailwind-m3e-web seed/tone-table, or @m3e/web fallback) and the
  expected value). The generator never silently papers over a spec failure.
- [ ] **Step 4:** Modes: Light + Dark are gating; the 13 hue themes + contrast tiers run
  under `--audit-all-modes` and report only (the code side has no counterpart theme set —
  tailwind-m3e-web derives themes from seeds, a different mechanism; note this in the
  report preamble).
- [ ] **Step 5:** Typescale/shape numeric comparison: `Static/*` sizes/line-heights/tracking
  and `Corner/*` radii vs `tailwind-m3e-web/src/sys/{typescale,shape}.css` literals —
  exact-match required (px numbers, not colors).

**Verify:** `node src/tokens/audit.mjs --profile m3-kit` writes `token-audit.md`; test
fixture with a deliberate seed change produces a `spec-failure` row; on the real inputs the
spec-failure section is empty OR every row has a filed follow-up entry (acceptance
criterion — investigate each before checking the box).
**Commit:** `feat(tokens): three-source mismatch audit with naming-vs-spec classification`

### Task D6: Family coverage closure

**Files:** Modify: `profiles/m3-kit/tokens.json` + overrides; `profiles/m3-kit/README.md`.

- [ ] **Step 1:** `Static/*` (95) and `Corner/*` (10): 100% rows non-`unmapped` (mapped or
  policy) after the ⚑ HUMAN confirm pass of D2 Step 4.
- [ ] **Step 2:** `State Layers/*` (147): mark the whole family `status: "policy"` — they
  are Figma-side conveniences for painting hover/press overlays; on the code side @m3e/web
  consumes `--md-sys-state-*` internally and tailwind-m3e-web *intentionally* does not map
  state tokens (its documented design). Not gaps; document in the README.
- [ ] **Step 3:** `Tracking/*`, `Add-ons`: human-decided rows (likely `policy`).
- [ ] **Step 4:** Coverage assertion in CI: `derive.mjs --check` fails if any row is still
  `unmapped` without an override note.

**Verify:** coverage table in README: Schemes 49/49 mapped, Corner 10/10, Static 95/95
mapped-or-policy, State Layers 147 policy, 0 bare `unmapped`.
**Commit:** `feat(tokens): full family coverage — mapped or explicit policy, zero silent gaps`

### Task D7: Acceptance replay

- [ ] **Step 1 ⚑ HUMAN:** run the generated (not hand-written) `00-snapshot` + `01-schemes`
  stamp scripts against the throwaway Copy via `use_figma`; then `get_design_context` on
  `56576:34730` (fileKey `iPFL8MH2R1Xphe94j7g809`) → emitted classes use
  `var(--md-sys-color-…)` names for every stamped role (evidence #6 reproduced from
  generated artifacts).
- [ ] **Step 2:** Check the run log + snapshot into `research/evidence/` (small, curated).
- [ ] **Step 3:** Confirm `token-audit.md` committed and its spec-failure section is
  resolved per D5's acceptance.

**Verify:** all three boxes with artifacts referenced by path.
**Commit:** `test(tokens): acceptance replay of codeSyntax mechanism from generated scripts`
