# Plan E — Consumer: elm-m3e (full breadth on the M3 kit)

**Goal:** take the tracer-proven pipeline (Plans A–D) to full breadth for the first
consumer: every matched `@m3e/web` component — including Building-Block part elements and
the 141 icons — carries **both labels** ("Web Components" + "Elm") in the canonical kit copy
`KujuFlfJSwHI6ua1b7RZvL`, gate-passed, with committed artifacts and CI drift guards landing
in `~/code/jackhp95/elm-m3e`, and a third-party adoption protocol proven against the
throwaway Copy.

**Depends on:** Plan B (emitters + publish runner), Plan C (visual gate), Plan D (token
table feeding snippet vocabulary). Read `../00-mission-and-decisions.md` (decisions D4–D7,
evidence #2, #5, #9, #11, #12) and `../01-architecture.md` §3 first.

**Inputs:** `profiles/m3-kit/correspondence.json` (tracer state after Plan B),
`research/figma-dumps/m3-kit-components.json` (5,770 nodes),
`research/evidence/06a-expressive-delta.md` (name-level match tables, inline: 53 matched /
68 CEM-only / kit-only — the `.txt`/`.tsv` sidecars it mentions are not checked in; only
the `.md` is).

**elm-m3e state assumption (D10):** post-review-2026-07 — namespaces `M3e.Html`/`M3e.Raw`/
`M3e.Token`, forms Loose/Record/Build, examples-gen shared harness. Verify branch state
before Task E7; if review-2026-07 plans are still mid-flight in another pane, coordinate —
do not race its rebases.

---

### Task E1: Breadth matcher run → proposals table

**Files:** Regenerated: `profiles/m3-kit/correspondence.json` (breadth proposals land in it
as `status: "proposed"` entries — Plan A's `match` writes through the human-preserving
merge, so the confirmed tracer button survives untouched),
`profiles/m3-kit/gap-report.md` (generated, committed). Modify: nothing by hand.

- [ ] Run the Plan A matcher over the full inputs: all 121 unique CEM tags × 171 component
      sets + 245 standalone components (D7 — Building Blocks and icons included, dot-prefix
      and non-dot families both):
      `node src/cli.mjs match --profile m3-kit`
- [ ] Confirm the proposals cover every row of the 53-row name-level match table inline in
      `research/evidence/06a-expressive-delta.md` (Task 3a) at provenance `auto-exact` or
      `auto-fuzzy`. **Verify:**
      `jq '[.[] | select(.provenance=="auto-exact" or .provenance=="auto-fuzzy")] | length' profiles/m3-kit/correspondence.json`
      → ≥ 53.
- [ ] Confirm set-fusion detection fired for buttons (evidence #9): the `m3e-button` entry
      must list 5 sets (`Button`, `Button - text/elevated/outline/tonal`) each with a fixed
      `variant` value. **Verify:**
      `jq '.[] | select(.cemTag=="m3e-button") | .figmaSets | length' profiles/m3-kit/correspondence.json`
      → `5`.
- [ ] Confirm Building-Block proposals exist for part elements — spot-check
      `m3e-button-segment` ↔ `Building Blocks/Segmented button/…` and `m3e-nav-item`.
- [ ] Generate the gap report (D6): code-only (~68 tags incl. ~20 real gaps: select,
      autocomplete, breadcrumb, stepper, tree, paginator), figma-only (carousel, time
      pickers, side sheet, bottom app bar, XR sets), and valid-but-undrawn variant
      combinations per matched component (CEM cartesian space minus drawn variants).
      **Verify:** `grep -c "^| m3e-" profiles/m3-kit/gap-report.md` ≈ 68 code-only rows.

**Commit:** `feat(m3-kit): breadth matcher proposals + gap report`

### Task E2: ⚑ HUMAN — correspondence review session

**Files:** Modify: `profiles/m3-kit/overrides.json` (human decisions, committed),
regenerate `profiles/m3-kit/correspondence.json`.

- [ ] ⚑ HUMAN Present the proposals table grouped by kit page (30 pages), **component +
      property level only, never per-variant** (architecture §3.5). For each `auto-fuzzy` proposal
      and each unmapped Figma axis (e.g. `Width`, `State`): accept / correct / suppress.
      Batch into one sitting; record every decision in `overrides.json` with
      `provenance: "human"` and a one-line rationale.
- [ ] Re-run the merge: `node src/cli.mjs match --profile m3-kit` (A6: `match` re-merges
      proposals through the human-preserving merge). The matcher must not clobber any human
      row (Plan A invariant). **Verify:** re-run twice,
      `git diff --exit-code profiles/m3-kit/correspondence.json` → clean (deterministic).
- [ ] Kit typo handling check: `State=Presssed` variants must be absorbed by the fuzzy
      normalizer (A5's `Presssed → pressed` test), not dropped — and since `State` has no
      CEM counterpart, the axis must surface as explicitly `unmapped`, never silently
      missing. **Verify:**
      `jq '.[] | select(.cemTag=="m3e-button") | .axes[] | select(.figmaProp=="State") | .unmapped' profiles/m3-kit/correspondence.json`
      → non-null reason string.

**Commit:** `feat(m3-kit): human-reviewed correspondence (overrides persisted)`

### Task E3: Icons — 141 components from one name-map

**Files:** Create: `profiles/m3-kit/icons.json`, `src/emit/icons.mjs`. Generated:
`generated/m3-kit/<label-slug>/icons/*.figma.ts` (141 files per label, one per icon node —
Code Connect maps per node, so per-icon files are unavoidable; the SOURCE is one compact
map, never 141 hand-written files).

- [ ] Build `icons.json` from the dump: the 141 standalone components on the Icons page,
      `{ figmaNodeId, figmaName, symbolName }` where `symbolName` is the snake_case Material
      Symbols name (evidence #12 — kit icon names already match `m3e-icon[name]` input).
      `icons.json` is not a side channel: it IS the `iconTable` entry of
      `profiles/m3-kit/correspondence.json` (A6 schema), merged there so icons carry the
      same provenance/status as every other entry.
      **Verify:** `jq 'length' profiles/m3-kit/icons.json` → `141`.
- [ ] `src/emit/icons.mjs`: template-loop emitter producing per-icon `.figma.ts` for both
      labels. Web Components: `<m3e-icon name="${symbolName}"></m3e-icon>`. Elm: read the
      actual post-rename icon API from `~/code/jackhp95/elm-m3e/src/M3e/Icon.elm` at
      execution time (do NOT trust this plan's guess of the setter name) and emit the top
      `M3e.*` form accordingly.
- [ ] **Verify:** regenerate twice → byte-identical;
      `ls generated/m3-kit/*/icons/*.figma.ts | wc -l` → `282` (141 × 2 labels). Deferred
      to the next ⚑ HUMAN token session (like B4 — dry-run needs `FIGMA_ACCESS_TOKEN` and
      live node resolution): `npx figma connect publish --dry-run --skip-update-check`
      (icons config only) → all parse and resolve.

**Commit:** `feat(m3-kit): icon binding generation from compact name-map`

### Task E4: Family fan-out — per-page confirmation (orchestrator protocol)

**Files:** Generated snippets under `generated/m3-kit/<label-slug>/` (B2's tree);
per-family gate results under `render-cache/results/` (Plan C4).

This task is the breadth engine. The orchestrator (herdr) fans out **one subagent per kit
page** (30 pages: App bars, Badges, Buttons, Cards, Checkboxes, Chips, …), against the
frozen A–D core. Each family subagent:

- [ ] Emits both labels for every confirmed component in its page
      (`node src/cli.mjs emit --profile m3-kit --page "<Page>"` — B2's `--page` filter).
- [ ] Runs the Plan C gate for its components: harness render (variant axes AND
      componentProperties driven per evidence #14 — e.g. `Show icon=false` to match a
      code-side render without a slotted icon) vs `export-png`, perceptual threshold.
      Requires the bridge session live (⚑ HUMAN once per fan-out batch, not per family —
      batch export requests through the shared relay; see Plan C batching).
- [ ] Files any above-threshold diff into the review queue (Plan C webapp) instead of
      publishing; marks the component `gate: pending-review`.
- [ ] Lands exactly one commit: `feat(m3-kit): <page> family confirmed (N components, M gated)`.

Orchestrator rules:
- [ ] Max ~6 concurrent families (relay and Playwright are shared resources).
- [ ] A family that discovers a correspondence error does NOT edit `correspondence.json`
      directly — it appends to `profiles/m3-kit/review-queue.md` for a follow-up ⚑ HUMAN
      micro-session, then skips the affected component.
- [ ] After all families: run the integration checker (E5) before any publish.

**Commit:** (one per family, see above)

### Task E5: Integration checker

**Files:** Create: `src/check/integration.mjs`, wire into `npm run check`.

- [ ] Cross-family validation: no duplicate Code Connect `id`s; every `correspondence.json`
      entry with `status: confirmed` has emitted files for both labels (or an explicit
      `labels:` restriction); every emitted file's node-id exists in the dump; no
      `/branch/` URLs anywhere (VOLT-2003 footgun #1); drift check green
      (`node src/cli.mjs check` → byte-stable, no orphans).
- [ ] **Verify:** `npm run check` → exit 0; deliberately plant a duplicate id in a scratch
      file → exit ≠ 0 (checker actually bites), remove it.

**Commit:** `feat: cross-family integration checker`

### Task E6: ⚑ HUMAN — full publish + spot verification

**Files:** none (remote state); log to `research/evidence/<date>-full-publish.md`.

- [ ] ⚑ HUMAN Token gate: `FIGMA_ACCESS_TOKEN` present (rotate first if the 2026-07-10
      token is still active — see ledger cleanup note).
- [ ] Publish all gate-passed bindings, both labels, to `KujuFlfJSwHI6ua1b7RZvL`:
      `node src/cli.mjs publish --profile m3-kit --file-key KujuFlfJSwHI6ua1b7RZvL`
      (no `--label` = all labels in the profile manifest, per B4; wraps
      `figma connect publish` per label config; dry-run first, then real).
- [ ] MCP spot-verification (scripted): for 2 sampled node-ids per page, `get_code_connect_map`
      with `codeConnectLabel` "Web Components" then "Elm" → snippet non-empty, correct
      per-variant values (evidence #2). Record pass/fail matrix in the evidence file.
- [ ] ⚑ HUMAN Dev Mode eyeball: open the copy in Dev Mode, select a Button, a Chip, an
      icon → the label dropdown shows **both** labels; snippets look right.
- [ ] Components that fail spot-verification: unpublish that binding, file in review queue.

**Commit:** `docs(evidence): full-publish verification matrix`

### Task E7: elm-m3e repo integration

**Files (in `~/code/jackhp95/elm-m3e`):** Create: `code-connect/` (committed generated
artifacts, both labels), `scripts/figma-connect-regen.mjs` (thin wrapper calling this
repo's CLI via relative path or `npm link`), `docs/FIGMA-CODE-CONNECT.md` (pointer doc),
CI step. Modify: `.github/workflows/` (drift job).

- [ ] Branch `figma-code-connect` in elm-m3e. Copy emitted artifacts; restore a pointer
      doc at `docs/FIGMA-CODE-CONNECT.md` linking to the `jackhp95/cem-figma-connect` repo
      (private) as the implementation home — the original brief was deleted from elm-m3e
      during the review-2026-07 cleanup and now lives at `cem-figma-connect/plans/BRIEF.md`.
- [ ] Regeneration script: `node scripts/figma-connect-regen.mjs` re-runs emit from the
      pinned profile and diffs — mirror tailwind-m3e-web's pattern:
      `regen && git diff --exit-code -- code-connect/`.
- [ ] CI drift job runs the diff (needs cem-figma-connect checked out as a sibling — same
      pattern as elm-m3e CI cloning elm-review-cem; keep the private-repo checkout token
      scoped read-only).
- [ ] Prettier exclusion: add `code-connect/` to `.prettierignore` (VOLT-2003 footgun #3).
- [ ] **Verify (elm-m3e bars, D10):**
      `npx elm make src/M3e.elm --output=/dev/null` → Success;
      `npx elm-review --config review` → clean;
      `npx elm-test@0.19.1 --compiler node_modules/.bin/elm` → pass;
      `(cd docs && pnpm run check)` → green;
      `node scripts/figma-connect-regen.mjs` → no diff.

**Commit (elm-m3e):** `feat: Figma Code Connect artifacts + drift guard (generated by cem-figma-connect)`

### Task E8: ADOPT.md — the generic-tool protocol, proven on the throwaway Copy

**Files:** Create: `docs/ADOPT.md`.

- [ ] Write the third-party walkthrough (D9): (1) duplicate the kit (or use your own
      library file); (2) reuse the canonical dump if your duplicate is the same kit version
      (node-ids stable, evidence #5) else run `extract/`; (3)
      `node src/cli.mjs publish --profile m3-kit --file-key <yourFileKey>` — keys
      re-resolve per file, no correspondence edits needed; (4) optional: codeSyntax stamping (Plan D) and a delta
      profile for custom components (architecture §3 / Plan F pattern).
- [ ] ⚑ HUMAN Execute the walkthrough literally against the throwaway Copy
      `iPFL8MH2R1Xphe94j7g809` — publish, spot-verify via `get_code_connect_map` (this is
      the file where our tracer publish did NOT resolve pre-republish; it resolving now is
      the proof), then unpublish and note both in the doc's "validated on" footer.

**Commit:** `docs: third-party adoption protocol (validated on fresh copy)`

---

## Acceptance (Plan E done)

- [ ] Every `status: confirmed` component (target: all 53 name-matches + human-added
      Building-Block bindings + 141 icons) resolves in the canonical copy under BOTH labels
      via MCP spot-matrix; Dev Mode eyeball signed off.
- [ ] `profiles/m3-kit/gap-report.md` final and committed (code-only / figma-only /
      valid-but-undrawn all enumerated).
- [ ] elm-m3e CI green including the drift job; all five elm-m3e verification bars pass.
- [ ] ADOPT.md validated end-to-end on the throwaway Copy.
- [ ] Review queue empty or every remaining item has a human disposition recorded.
