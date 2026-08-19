# Plan C — Visual verification gate

> Read first: [`../00-mission-and-decisions.md`](../00-mission-and-decisions.md) (decisions
> D4/D7/D8, evidence #10/#12/#14), [`../01-architecture.md`](../01-architecture.md) §6.
> Depends on Plan A (correspondence schema + figma ingest + `extract/`). Plan B consumes
> this plan's gate status (Task C7 wires the refusal).

**Goal.** "Matched" must mean "pixel-proven" (decision D8). A correspondence binding
graduates to *publishable* only when its sampled renders — the code side (Playwright,
@m3e/web) vs the Figma side (`export-png`) — diff within a perceptual threshold, or a human
explicitly approves the flagged diff in the review webapp. Both sides are driven to the
SAME state from the SAME correspondence entry.

**Non-goals (documented follow-ups, not tasks):** interaction states (Hovered/Pressed/
Focused — need CDP `Input.forced-pseudo-states` forcing; the kit's `State` axis is marked
`unmapped` in correspondence anyway); cross-machine byte-equality (Linux CI rasterizes
differently — the perceptual threshold absorbs it, see Task C4).

**Proven starting point (evidence #14):** the 2026-07-10 spike rendered `m3e-button` and
`m3e-switch` headless with **byte-identical PNGs across 3 runs** on one machine, and
`export_node_as_image` produced per-variant kit PNGs at scale 2. The spike's knobs are the
law of this plan — do not re-derive them:

| Knob | Value | Why |
|---|---|---|
| Bundle | one esbuild call over `@m3e/web/all` (~1.9 MB) | dist has bare imports; `lit`/`tslib` are peerDeps; no prebuilt browser bundle exists |
| Serving | tiny `node:http` static server | `file://` CORS-blocks module scripts in Chromium |
| Font | local Roboto woff2 (@fontsource), `font-display: block`, `font-synthesis: none` | m3e uses `font-family: inherit` — the host page decides; no network fetch |
| Screenshot | element screenshot, `deviceScaleFactor: 2`, `scale: "device"`, `omitBackground: true` | matches Figma export scale 2; transparent background both sides |
| Motion | `reducedMotion: "reduce"` + `animations: "disabled"` + page CSS kill-switch | determinism |
| Waits | `customElements.whenDefined` → `document.fonts.ready` → `el.updateComplete` → double rAF | paint stability |
| Theme | none needed — @m3e/web tokens carry baked-in baseline fallbacks (`#6750A4` …) | matches the kit's baseline Light mode |

---

### Task C1: Land the harness as `src/visual/harness/`

**Files:** Create: `src/visual/harness/{page.html,page.mjs,static-server.mjs,bundle.mjs,capture.mjs,selfcheck.mjs,README.md}`,
`src/visual/harness/fonts/` (vendored Roboto woff2). Modify: `package.json` (devDeps:
`playwright`, `esbuild`, `@fontsource/roboto`; the consumer package `@m3e/web` is a
profile-declared peer, installed in the profile workspace).

- [ ] **Step 1:** Copy the spike files preserved in-repo at
  `research/spikes/07-render-harness/` (page, static server, playwright spec, fonts,
  bundle; `research/evidence/07-render-harness-notes.md` records every knob and gotcha).
  Strip test-runner specifics; keep page + server + bundling.
- [ ] **Step 2:** Generalize the mount contract. The page mounts ANY custom element from URL
  params — scheme (extend the spike's `?tag=&attrs=&text=`):
  `?tag=m3e-button&attr.variant=filled&attr.size=medium&text=Label&slot.icon=m3e-icon:star`
  — `attr.<name>=<value>` (repeatable), `text=<chars>` (default slot text),
  `slot.<slotname>=<tag>:<arg>` where `m3e-icon:<name>` renders
  `<m3e-icon slot="<slotname>" name="<name>">` (evidence #12: `name` = Material Symbols
  snake_case). Boolean attrs: `attr.disabled=` (empty = present).
- [ ] **Step 3:** Bundling per profile: `bundle.mjs` runs esbuild over the profile's declared
  entry (`profiles/m3-kit/harness.json` → `{"entry": "@m3e/web/all"}`) into a gitignored
  `render-cache/bundle/<hash>.js`; content-hash keyed so @m3e/web bumps invalidate.
- [ ] **Step 4:** `capture.mjs`: Playwright programmatic API (not test runner) —
  launch chromium once, `renderOne(urlParams) → PNG buffer` with the wait ladder above.
  Element screenshot of the mounted node only.
- [ ] **Step 5:** Determinism check: render `m3e-button` filled and `m3e-switch checked`
  (attr per evidence: the switch attribute is `checked`, NOT `selected`) 3× each in separate
  processes; sha256-compare.

**Verify:** `node src/visual/harness/selfcheck.mjs` → prints `button: stable (3/3)`,
`switch: stable (3/3)`, exits 0.
**Commit:** `feat(visual): deterministic headless render harness (from 2026-07-10 spike)`

### Task C2: The state driver — one entry, two renders

**Files:** Create: `src/visual/drive.mjs`, `src/visual/drive.test.mjs`.

The driver is the parity contract. Input: a correspondence entry (Plan A schema) + one
*state* (a chosen value per Figma axis + per component property). Output:
`{ harnessParams, figmaNodeQuery }`.

- [ ] **Step 1:** Axis translation: for each Figma VARIANT axis in the state, apply the
  entry's axis→attribute + value→value maps (evidence #2 shape: `XSmall → extra-small`,
  `Round → rounded`). Set-fusion entries (evidence #9) contribute their fixed attribute
  (`Button - tonal` ⇒ `variant=tonal`) from the set binding, not an axis.
- [ ] **Step 2:** Property translation (**the critical rule, evidence #14**): every
  componentProperty binding in the entry must be driven —
  TEXT (`Label text`) → `text=` param; BOOLEAN (`Show icon`) → presence/absence of the bound
  slot param; INSTANCE_SWAP (`Icon`) → `slot.icon=m3e-icon:<mapped-name>`. Default state =
  Figma's `defaultValue` from `componentPropertyDefinitions`
  (`research/figma-dumps/kit-props-button-main.json` is the reference fixture: TEXT
  `Label text`=`"Label"`, BOOLEAN `Show icon`=`true`, INSTANCE_SWAP `Icon`). A kit default
  `Show icon=true` therefore renders an icon on BOTH sides — never compare icon-vs-no-icon.
- [ ] **Step 3:** `figmaNodeQuery`: the variant node is found in the ingested dump by
  (set id, exact `Prop=Value, …` name match) with the fuzzy tier tolerating kit typos
  (`Presssed`) via the same normalizer as the matcher (Plan A).
- [ ] **Step 4:** Unmapped Figma axes (e.g. `Width`, `State`) pin to their default value in
  every generated state; assert the entry marks them `unmapped` (else the driver throws —
  a silent unmapped axis is a correspondence bug).
- [ ] **Step 5:** Unit tests against the button fixture: filled/medium/round default state
  produces `tag=m3e-button, attr.variant=filled, attr.size=medium, attr.shape=rounded,
  text=Label, slot.icon=…` and resolves node `57994:2322`'s sibling with icon default
  (assert exact node-id from the fixture dump).

**Verify:** `node --test src/visual/drive.test.mjs` → all pass.
**Commit:** `feat(visual): correspondence-driven state driver (axes + componentProperties)`

### Task C3: Figma-side batch exporter

**Files:** Create: `src/visual/figma-export.mjs`. Modify: `.gitignore` (`render-cache/`).

- [ ] **Step 1:** Input = list of `{entry, state}` from the sampling plan (Task C5); resolve
  node-ids via the driver; dedupe.
- [ ] **Step 2:** Export over the WS bridge (`extract/` client from Plan A; command
  `export_node_as_image`, scale 2 — proven 2026-07-10). Serial with progress log — the
  plugin executes on the UI thread; do NOT parallelize bridge calls.
- [ ] **Step 3:** Cache under `render-cache/figma/<fileKey>/<nodeId>@2x.png`, keyed with a
  manifest recording kit version pin + export date; `--refresh` to bust.
- [ ] **Step 4 ⚑ HUMAN:** exports need the kit copy open in Figma desktop, **Design mode**,
  bridge running (`extract/` runbook). The exporter preflights with the bridge-check ping
  and prints the runbook pointer when unreachable. Batch all pending exports per session.

**Verify:** with a live bridge: `node src/visual/figma-export.mjs --entry m3e-button --sample default`
→ writes ≥1 PNG to render-cache, second run prints `cached (0 exported)`.
**Commit:** `feat(visual): batched figma export-png with cache + human-session preflight`

### Task C4: Diff pipeline

**Files:** Create: `src/visual/diff.mjs`, `src/visual/diff.test.mjs`. Modify:
`package.json` (dep: `pixelmatch`, `pngjs`).

- [ ] **Step 1:** Use **pixelmatch** (+pngjs): plain JS, zero native deps, perceptual-ish
  (YIQ) per-pixel threshold + anti-aliasing detection — fits the "no native toolchain"
  constraint of a general npm tool. (odiff is faster but ships platform binaries; revisit
  only if E-scale wall-clock hurts.)
- [ ] **Step 2:** Alignment policy: code side is a tight element box; Figma export is node
  bounds (MEASURE first: diff the captured fixtures' dimensions —
  `research/spikes/07-render-harness/btn-57994-2322.png` vs the spike's `button-filled-run1.png` — and record
  actual padding behavior in the module docstring). Normalize: pad both to the union box,
  center, transparent background (both sides already omit background).
- [ ] **Step 3:** Result record per comparison:
  `{entryId, stateId, pass, diffRatio, threshold, artifacts: {code, figma, diff}}` appended
  to `render-cache/results/<run>.jsonl`; diff PNG written alongside.
- [ ] **Step 4 (calibration):** thresholds live in the profile
  (`profiles/m3-kit/visual.json`: `{maxDiffRatio, pixelThreshold}`). Calibrate against the
  2026-07-10 fixtures: same-component pairs must pass, cross-variant pairs (filled vs tonal,
  medium vs large) must fail. Record chosen numbers + the calibration table in the profile
  README. Start from `pixelThreshold: 0.1`, `maxDiffRatio: 0.02` and adjust by evidence.
- [ ] **Step 5:** Unit tests with the checked-in fixture PNGs (copy the handful of spike
  PNGs into `src/visual/fixtures/` — small, deterministic).

**Verify:** `node --test src/visual/diff.test.mjs` → same-pair passes, cross-pair fails.
**Commit:** `feat(visual): pixelmatch diff with union-box alignment + profile thresholds`

### Task C5: Sampling policy

**Files:** Create: `src/visual/sample.mjs`, `src/visual/sample.test.mjs`.

Full cartesian is intractable (5,354 drawn variants in the kit; the CEM space is larger).

- [ ] **Step 1:** Default plan per entry = **one-factor-at-a-time**: the all-defaults state,
  plus one state per non-default value of each mapped axis and each boolean/text property
  (vary that one, defaults elsewhere). For the fused-set button that is ≈ 1 + 4 (sizes) +
  1 (shape) + 1 (icon off) + 4 (sibling color sets' defaults) ≈ 11 comparisons, not 150.
- [ ] **Step 2:** `--audit` flag = full cartesian of *drawn* variants (Figma is the bound:
  only materialized variants have a Figma side to compare).
- [ ] **Step 3:** Exclusions by policy, asserted in code: `State` axis (interaction states,
  see non-goals), axes marked `unmapped`. `iconTable` entries (A6 schema) are **gate-exempt
  in v1** — the 141 glyph renders are font-identical by construction (same Material Symbols
  glyph both sides); the `--audit` flag spot-checks 5 icons instead of skipping entirely.
- [ ] **Step 4:** Tests: button fixture yields the expected state list, stable ordering
  (determinism — sampling feeds cache keys).

**Verify:** `node --test src/visual/sample.test.mjs`.
**Commit:** `feat(visual): one-factor-at-a-time sampling with full-cartesian audit flag`

### Task C6: Review webapp + decision persistence

**Files:** Create: `src/visual/review/{server.mjs,ui.html}`, `src/visual/review/README.md`.

- [ ] **Step 1:** `node src/visual/review/server.mjs --profile m3-kit` — `node:http`, no
  framework. Lists pending failures from the latest results run; per item: code PNG, Figma
  PNG, diff overlay (toggle), metadata (entry, state, diffRatio, rationale from
  correspondence).
- [ ] **Step 2:** Actions: **approve** (writes
  `{gate: "approved", provenance: "human", note}` into the profile's overrides file —
  the same file/merge semantics as Plan A's matcher overrides, so re-runs are
  deterministic); **reject** (writes `{gate: "rejected", note}` — binding stays blocked and
  the note lands in the entry's rationale); **retarget** (frees the binding back to
  `pending` after the human edits the mapping — link to the entry in the correspondence
  file).
- [ ] **Step 3:** Gate status derivation (pure function, `src/visual/status.mjs`):
  `pass` (all sampled comparisons under threshold) | `approved` (human) | `failed` |
  `rejected` | `pending` (missing renders). Status is DERIVED from results + overrides at
  read time — no third mutable store.
- [ ] **Step 4 ⚑ HUMAN:** review sessions are batched; the webapp prints a summary count on
  start and writes decisions immediately (no bulk-save to lose).

**Verify:** seed a fake failing result → approve in browser → overrides file contains the
decision → `node -e 'status(…)'` reports `approved`; re-run derivation → unchanged.
**Commit:** `feat(visual): human review webapp writing durable gate decisions`

### Task C7: Wire the gate into publish

**Files:** Modify: Plan B's publish runner (`src/publish/runner.mjs`), its tests
(`test/publish-check.test.mjs`).

- [ ] **Step 1:** Before emitting a binding into a publish unit, the runner asks
  `status(entry)`; only `pass`/`approved` publish. Others are listed in the run summary
  with their status and (for `failed`) the diff artifact path.
- [ ] **Step 2:** `--force-gate` escape hatch publishes anyway but logs a loud per-binding
  warning and stamps the run manifest `forced: true`. (Exists for demo/tracer moments;
  never used in CI.)
- [ ] **Step 3:** Runner test: fixture with one passing, one failing binding → publish set
  contains exactly the passing one; with `--force-gate` both, manifest flagged.

**Verify:** `node --test test/publish-check.test.mjs`.
**Commit:** `feat(publish): visual gate blocks unproven bindings (D8)`

### Task C8: Acceptance — sensitivity proven end-to-end

- [ ] **Step 1 ⚑ HUMAN (bridge session):** m3e-button, default sampling: harness renders +
  figma exports + diff → all under threshold (icon parity via C2 Step 2). Record the run
  id in `research/evidence/`.
- [ ] **Step 2:** Sabotage test: temporarily swap the size value map (`Medium → large`) in a
  scratch profile copy → the medium-state comparison **fails**. This proves the gate
  detects real mapping errors (not just noise). Revert.
- [ ] **Step 3:** Document the whole loop in `src/visual/README.md` (one page: harness →
  driver → export → diff → review → gate).

**Verify:** both runs' results JSONL checked into `research/evidence/` (small, curated);
sabotage run shows `pass: false` on exactly the sabotaged states.
**Commit:** `test(visual): end-to-end gate acceptance + sensitivity proof`
