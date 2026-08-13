# M6 deep clean — reviewable manifest

127 paths removed, 6 files corrected in place (one factually-wrong doc left as-is
would have been worse than the cruft it describes). This document is organized by
package. Every removal states which keep/remove rule it failed and why. A separate
section lists everything considered and **kept** because uniqueness was in doubt,
or because it turned out — on verification — to be load-bearing after all.

**Process note, stated up front because it shaped the outcome:** the initial pass
(parallel research agents per package) over-recommended removal. Re-verifying every
recommendation against actual `grep` hits for live code citations (not just
citations within the plans/docs corpus itself) surfaced **eight false-positive
"orphan" claims** — files the agents called dead that turned out to be imported by
running code, wired into a live profile config, or cited as an unresolved
dependency by a doc that is itself still load-bearing. Each is called out below,
because the wrongness of the initial claim is itself useful signal for a reviewer:
this corpus is far more densely cross-referenced than a first read suggests, and
the corrected, conservative result reflects re-verifying every single removal
against real citations (source code, configs, and other kept docs) rather than
trusting a summary.

---

## packages/elm-cem

### Removed

- `plans/2026-08-05-open-global-attributes.md`, `plans/2026-08-05-value-primitives-codegen.md`
  — **REMOVE, superseded plan.** Both end in an `## OUTCOME` section confirming the
  work landed; verified in current source (`Generate.Phantom.Model.elm:425` has
  `openGlobals`, `Emit.elm:4290-4407` has the enum helpers). Their paired **specs**
  (`specs/2026-08-05-*-design.md`) were kept — see below — because they carry
  rationale (the ARIA-hybrid precedent, the wire-string-vs-identifier argument)
  that a closed task-tracking plan doesn't.
- `native-manifest-gen/` (35 files: `BUILD-PLAN.md`, `COMPLETE-COVERAGE.md`,
  `PHASE-0-FINDINGS.md`, `RESULTS.md`, `gen.mjs`, 6 `spike-*.mjs` files, `src/*.mjs`,
  `data/whatwg-*.json`, `out/*.json`, lockfiles) — **REMOVE, not part of the
  pipeline (rule a fails).** `CONTRIBUTING.md` claimed this tool "produces
  `data/native-attrs.json`," the real pipeline input `bin/elm-cem.js` reads. Verified
  false: `data/native-attrs.json` is a 26-line hand-curated table; `gen.mjs` writes
  to `out/manifest.json`/`out/reports.json`/`out/universal-attrs.json`, a much
  larger WHATWG-scraped set that no script ever wires into the real input. It's an
  abandoned spike toward a broader auto-generation approach, not the tool that
  built the file the pipeline actually uses. Not wired into any `package.json`
  script. `CONTRIBUTING.md` corrected in place (see below) rather than left
  claiming a false provenance.
- 4 of 5 `skills/*/SKILL.md` maintainer skills (`extending-the-generator`,
  `debugging-generated-output`, `configuring-cem-overrides`, `generating-elm-bindings`,
  plus their `evals.json`/`reference/*.md`) — **REMOVE, factually wrong (worse than
  cruft) and now redundant.** These describe the pre-"phantom refactor" generator
  architecture: a `Top`/`Middle`/`Bottom`/`Barrel`/`Value`/`Action`/`Event`/`Native`/
  `Seam`/`Slots`/`BuildForm`/`RecordForm` family of `Generate/*.elm` modules, none of
  which exist — `codegen/Generate/` today holds only `Config.elm`, `Normalize.elm`,
  `Phantom/{Model,Emit}.elm`, `SharedAttrs.elm`, `Types.elm`. `configuring-cem-overrides`
  documented an entirely different, superseded config vocabulary (`slots`/`required`/
  `attrTypes`/`_baseSlots`/`_native`/...) — the current vocabulary
  (`kind`/`admits`/`parents`/`_sets`/`home`/`_coerce`/...) is accurately and
  comprehensively documented in `docs/config-primitives.md`, which stays. Rewriting
  these skills correctly would mean re-deriving the current architecture from
  scratch under this pass's time budget, which risks shipping a second wrong
  version; deletion plus the accurate existing docs (in-source module docstrings +
  `config-primitives.md`) is the safer choice. The 5th skill, `releasing-elm-cem`,
  was **kept** and corrected in place (see "Fixed in place" below) — it documents
  the release *process* (OIDC publish, the two-surfaces semver policy), which is
  still accurate; only two small internal citations were stale.

### `.neutrality-allowlist` — 30 stale entries removed

Verified each of the ~31 entries the task flagged (R-003) against `test -e` on
disk; 30 pointed at paths that no longer exist (a pre-phantom-refactor `Generate/*.elm`
roster, several `tests/src/*.elm` files, and the entire `docs/release-audit/`
tree + `RELEASE-AUDIT-HANDOFF.md`, none of which exist anywhere in this repo).
Removing a stale entry is inert to the gate (`.github/neutrality-check.sh` does
exact path match against `git ls-files`), so this is pure dead-weight cleanup, not
a gate change. Also removed the two entries for `native-manifest-gen/*.md` (dir now
gone), the `skills/configuring-cem-overrides/SKILL.md` entry (file now gone), and
the plan/spec entries for the two removed plans files while keeping the two spec
entries (specs were kept). Verified green: `bash .github/neutrality-check.sh` → OK.

### Fixed in place (factually wrong, corrected rather than deleted)

- `CONTRIBUTING.md` — removed the false claim that `native-manifest-gen/` produces
  `data/native-attrs.json`; states plainly that the data file is hand-curated.
  Also dropped a reference to `tests/src/GoldenTest.elm`, which doesn't exist.
- `skills/releasing-elm-cem/SKILL.md` — two stale citations fixed: `GoldenTest.elm`
  → "the `elm-test-rs` suites under `tests/src/`"; removed the `native-manifest-gen/`
  npm-pack exclusion note (directory no longer exists) and reworded the `data/`
  packing note to say the table is hand-curated.

---

## packages/elm-m3e

### Removed

- `.claude-memory/` (9 files) — **REMOVE, orphaned agent session-memory scratch.**
  Zero references anywhere in the workspace outside the directory itself
  (verified by grep across every package). Branch-hygiene notes, a stale
  "NOT RELEASABLE" audit long superseded by M1–M5 completion, pointers to a
  `~/Documents/code/planning/` path outside this repo.
- `CAP-ACCOUNTING.md` — **REMOVE, superseded/factually stale.** Documents a
  release-blocker (missing doc comments) against a module path
  (`M3e.NavMenuItem.Build`) that has since moved (`M3e.Build.<Component>` today);
  the blocker itself is fixed in current source. Zero references anywhere.
- `TASK1-FINDING.md` — **REMOVE, superseded.** A one-off root-cause writeup for an
  `@m3e/web` bug workaround; not referenced from README/CHANGELOG/code, and the
  MutationObserver shim it recommends isn't findable in current `docs/index.ts`.
  Zero references anywhere.
- `docs-playbook/consumer-migration-playbook.md` — **REMOVE, superseded draft.**
  An earlier (2026-07-20) draft of the same migration `MIGRATION.md` already
  covers (2026-07-22), even more stale than `MIGRATION.md`'s own dated table; not
  wired into any build/doc pipeline. Zero references anywhere.
- `docs/plans/2026-08-09-theme-reel-design.md` — **REMOVE, superseded by its own
  follow-up audit** (`2026-08-11-theme-reel-m3e-audit.md`, kept — see below).
  Zero references anywhere.
- `docs/plans/theme-flash-and-dev-fouc.md` — **REMOVE, implemented and verified
  shipped.** `docs/elm-pages.config.mjs` has the exact `headTagsTemplate` inline
  script the plan specified. Zero references anywhere.
- 9 of 12 `plans/*.md` files, and 2 of 10 `specs/*-design.md` files (full list
  below) — **REMOVE, completed feature plans/specs with no live citation.** For
  each, spot-checked that the described feature shipped (nav-rail in
  `docs/tests-browser/nav-rail.spec.ts`, welcome-page in
  `docs/app/Route/GettingStarted/Welcome.elm`, etc.) and confirmed **zero
  references** anywhere in the workspace, including cross-doc citations from other
  kept plans/specs (this last check is what caught the false positives described
  below — several of this package's specs/plans turned out to cite each other by
  filename as "Depends on" / "Supersedes" declarations, and those chains had to be
  walked out before any single file could be called safely dead):
  - `plans/2026-08-05-favicon-material-palette.md`
  - `plans/2026-08-05-icon-registry-seam.md`
  - `plans/2026-08-05-remove-raw-html-element.md`
  - `plans/2026-08-05-shared-elm-value-primitives.md`
  - `plans/2026-08-05-theme-host-view-restructure.md`
  - `plans/2026-08-06-nav-rail-layout.md`
  - `plans/2026-08-06-nav-rail-shell-tests.md`
  - `plans/2026-08-06-nav-rail-tree-toc.md`
  - `plans/2026-08-07-nav-rail-search.md`
  - `plans/2026-08-08-welcome-page-url-restructure.md`
  - `specs/2026-08-05-remove-raw-html-element-design.md`

  (`plans/2026-08-08-tangram-logo.md`, `specs/2026-08-08-tangram-logo-design.md`,
  `specs/2026-08-08-theme-editor-drawer-design.md`, `plans/2026-08-08-theme-editor-drawer.md`,
  `specs/2026-08-05-favicon-material-palette-design.md`,
  `specs/2026-08-05-icon-registry-seam-design.md`,
  `specs/2026-08-05-shared-elm-value-primitives-design.md`, and
  `specs/2026-08-05-theme-host-view-restructure-design.md` were all **initially
  removed by mistake** on the strength of a research agent's "no live citation"
  call, then **restored** on independent re-verification — see "False-positive
  orphan claims, corrected" below. They remain in the tree.)

### Fixed in place (R-009, factually wrong — corrected rather than deleted)

- `editor/README.md` and `editor/stub/Cem/Facts.elm` both stated the canonical
  `Cem.Facts` lives in `jackhp95/elm-review-cem`. Verified false: since M1.d it
  lives in `packages/elm-cem/facts/` (published as `jackhp95/elm-cem-facts`,
  confirmed via that package's `elm.json` name field and via
  `packages/elm-m3e/review/elm.json`'s `source-directories`, which lists
  `../../elm-cem/facts/src`, not an `elm-review-cem` path, for `Cem.Facts`). Both
  files corrected to name the real location and package. Verified post-fix via
  `node tools/check-single-cem-facts.mjs` → OK, exactly one `Cem.Facts` in every
  compiled graph.

### False-positive orphan claims, corrected

Three files were deleted on a research agent's claim of "zero references," then
restored after a workspace-wide re-grep found real citations:

- **`js/raw-html.js`** — claimed dead code (no callers found). Actually imported
  live at `docs/index.ts:27` (`import "../js/raw-html.js"`) and its `raw-html`
  custom element is queried directly in `docs/tests-browser/usage.spec.ts`. This
  was the first false positive found and is what triggered re-verifying every
  other claim in this pass rather than trusting the summaries.
- **`plans/2026-08-08-tangram-logo.md`, `specs/2026-08-08-tangram-logo-design.md`,
  `specs/2026-08-05-favicon-material-palette-design.md`,
  `specs/2026-08-05-icon-registry-seam-design.md`,
  `specs/2026-08-08-theme-editor-drawer-design.md`, `plans/2026-08-08-theme-editor-drawer.md`,
  `specs/2026-08-05-shared-elm-value-primitives-design.md`,
  `specs/2026-08-05-theme-host-view-restructure-design.md`** — claimed
  superseded/redundant. Actually: `docs/scripts/icons-gen/tangram-favicon.mjs`
  cites `theme-editor-drawer-design.md` live in a code comment;
  `specs/2026-08-08-tangram-logo-design.md` explicitly declares "Depends on: Spec
  E (`theme-editor-drawer-design.md`)" and "Supersedes:
  `favicon-material-palette-design.md`" — and states that Spec D's *other*
  content (an unfixed Open-Graph-image defect affecting 14 route modules)
  "remains valid and unfixed," i.e. still-open technical debt, not history.
  `favicon-material-palette-design.md` in turn declares "Depends on: Spec C
  (`icon-registry-seam-design.md`)". Two more of elm-cem's own specs
  (`specs/2026-08-05-value-primitives-codegen-design.md` and
  `specs/2026-08-05-open-global-attributes-design.md`) separately cite
  `shared-elm-value-primitives-design.md` and `theme-host-view-restructure-design.md`
  by name as the elm-m3e-side half of a cross-package change. Pulling on any one
  thread in this specs/ corpus surfaces a dependency chain; all eight are
  restored.

---

## packages/cem-figma-connect

### Removed

- `research/spikes/` (3 subdirs: `01-publish-gate/`, `02-elm-label/`,
  `07-render-harness/` with its assets/screenshots/tests, plus
  `inline-coverage.js`) — **REMOVE, research spike wired to nothing (per the
  task's own callout).** Every reference anywhere in `src/`, `test/`, `profiles/`
  is a comment-only provenance citation, never a `readFileSync`/`import`.
  `src/visual/diff.test.mjs:7` explicitly confirms the live fixtures were "copied
  from `research/spikes/07-render-harness/`" into `src/visual/fixtures/` — i.e.
  the spike's own output already lives on independently, making the spike itself
  safe to remove.
- `.claude-memory/cem-figma-connect-state.md` — **REMOVE, orphaned session
  scratch.** 231 lines of 2026-07-18–07-20 progress narration, fully superseded
  by `STATUS.md`; zero references anywhere.
- `plans/gate-tooling/` (`render-all.mjs`, `review-launch.mjs`,
  `overrides-snapshot.json`) — **REMOVE, dead scratch tooling.** Not in
  `package.json` scripts (`check:render` maps to `src/visual/harness/selfcheck.mjs`
  instead); both `.mjs` files hardcode a stale absolute path to a pre-monorepo
  checkout location. `overrides-snapshot.json` is a superseded point-in-time dump
  of the now-live `profiles/m3-kit/overrides.json`.
- 21 `plans/*.md` and `plans/plan/*.md` files — **REMOVE, stale handoffs /
  unshipped speculative plans / completed-and-shipped design docs with no live
  citation**, verified individually against both source-code grep and a
  workspace-wide cross-doc grep (see the false-positive section — this package's
  `plans/` turned out to be even more densely self-referential than elm-m3e's,
  so every file below was checked against every other *kept* file, not just
  source code):
  - `2026-07-15-comprehensive-figma-capture-plan.md` (paired design doc kept —
    cited live from `extract/plugin/code.js`)
  - `2026-07-18-qualifier-aware-matcher-plan.md` (paired design doc kept — cited
    live from `src/match/qualifier.mjs`)
  - `2026-07-18-representative-example-emission-plan.md` (paired design doc kept
    — cited live from `src/emit/example-content.mjs`)
  - `2026-07-19-append-sets-mechanism-design.md`
  - `2026-07-19-appendsets-bank-execution.md`
  - `2026-07-19-bridge-coverage-gap.md`
  - `2026-07-19-icon-emit-design.md`
  - `2026-07-19-manual-correspondence-tab-design.md`
  - `2026-07-19-progress-set-attrs-design.md`
  - `2026-07-20-elm-emit-gap-closure.md` — additionally factually wrong: describes
    teaching parsing logic to `profiles/m3-kit/emitters/elm-facts.build.mjs`,
    which M3.a deleted.
  - `AUTONOMOUS-SESSION-FRICTIONS.md`
  - `coverage-remediation-execution-prompt.md`
  - `gate-content-remediation.md`
  - `gate-remediation-round2.md`
  - `okf-friction-issues-DRAFT.md`, `okf-self-learning-loop-DESIGN.md` (unfiled
    draft proposals for a *different* package's tooling, nothing wired here)
  - `retarget-feedback-round3.md`

### False-positive orphan claims, corrected

This package's `plans/` and `research/` directories produced the most
false positives of the whole sweep — six files/dirs were deleted on the initial
recommendation, then restored:

- **`research/figma-dumps/`** (all 9 files, including
  `figma-export.m3-kit.json`, `figma-export.m3-kit-copy.json`, the two
  `kit-props-button-*.json` and `copy-components.json`) — claimed redundant with
  `profiles/m3-kit/facts/*.json`. Actually: `profiles/m3-kit/profile.json`'s
  **`figmaExportPath`** field points directly at
  `research/figma-dumps/figma-export.m3-kit.json` — this is the live Figma-side
  input to the whole m3-kit profile, not a superseded dump (rule a). Separately,
  `test/fixtures/build-m3-kit-fixture.mjs` reads six of the nine files
  (`m3-kit-components.json`, `kit-doc-info.json`, `kit-variables.json`,
  `kit-styles.json`, both `kit-props-button-*.json`) at runtime to construct the
  committed test fixture — it is the tool that (re)builds a checked-in fixture
  from this exact directory, so deleting the directory would sever fixture
  provenance even though nothing currently re-runs the build. And
  `figma-export.m3-kit-copy.json` is cited in `STATUS.md` as live evidence for an
  **open, unresolved release-blocker decision** (a 3-way file-key disagreement).
  All nine files restored/never deleted.
- **`research/evidence/*.md`** (4 files) — initially flagged KEEP-AND-FLAG for
  lack of a `readFileSync` hit. Re-checked: all four are cited by name from live
  source comments (`src/correspond/gap-report.mjs`, `src/ingest/dts-inline.mjs`,
  `src/visual/harness/*`, `src/publish/runner.mjs`, `test/fixtures/build-m3-kit-fixture.mjs`)
  as the record of a specific measurement the code's behavior depends on
  understanding. Upgraded from flag to plain KEEP.
- **`plans/BRIEF.md`** — claimed superseded ("`00-mission-and-decisions.md` says
  where the two disagree, this doc wins," read as "this doc is dead"). Actually:
  §7.4 and §9 are cited from *executable* code (`src/correspond/gap-report.mjs`,
  `src/tokens/audit.mjs`) — and §7.4's "completeness inversion" is quoted into a
  **runtime-generated report string** at `gap-report.mjs:329`. Restored.
- **`plans/plan/E-consumer-elm-m3e.md`, `plans/plan/F-consumer-avetta.md`** —
  claimed unstarted/speculative. Both are live markdown-linked table rows in
  `plans/plan/README.md` (itself kept, cited from `src/cli.mjs` and others);
  deleting the targets would leave broken links in a kept, actively-cited doc.
  Restored.
- **`plans/plan/E-breadth-triage.md`** — claimed shipped/superseded. Both
  `HANDOFF-2026-07-14*.md` files (themselves kept — see below) describe it as
  "THE working map" / "THE landscape" for ~20 still-open component fixes, present
  tense. Restored.
- **`plans/identical-views-handoff.md`, `plans/next-agent-handoff.md`,
  `plans/HANDOFF-2026-07-14.md`, `plans/HANDOFF-2026-07-14-jack-device.md`,
  `plans/coverage-remediation-prompt.md`** — claimed stale handoffs. `STATUS.md`
  (the live, current status doc) actively points readers at the first two ("see
  `plans/identical-views-handoff.md` for the method and session history"; "see
  `plans/next-agent-handoff.md`" for an open fix), and at the two HANDOFF files
  by name in its own history section. `coverage-remediation-prompt.md` is cited
  from `docs/coverage-remediation-plan.md` (kept) as the source of a
  still-referenced family classification. Restored.

### `01-architecture.md` — one-line correction (kept, factually wrong in one place)

Its package-shape sketch described `ingest/cem.mjs` as doing "CEM load + `.d.ts`
alias inlining (generalizes elm-cem's inliner)." Since M3.a, `.d.ts` alias
inlining moved upstream into elm-cem itself; `ingest/cem.mjs` now reads the shared
facts bundle. Corrected in place; the rest of the document (still cited live from
14+ source files) is accurate.

---

## packages/m3e-okf

### Removed

- `.claude-memory/m3e-disclosure-hook-design.md` — **REMOVE, orphaned agent
  session memory.** A design doc for an unimplemented hook system, referencing
  paths outside this repo (`planning/execution/...`) and a session that ended
  "NEXT: release plan → archive+squash (Jack-gated)" with no follow-through
  visible anywhere in the tree. Zero references anywhere in the workspace.

---

## Considered and explicitly REJECTED for removal (kept as-is)

Beyond the false-positive corrections above, these were seriously considered for
removal and kept because they satisfy a keep rule outright — not merely "flagged
for doubt":

- **`docs/facts-bundle/m4-bump-report.md`** — initially proposed for removal as a
  redundant one-time M4 report. Actually: `tools/bump.mjs`'s `REPORT_PATH` constant
  points at this exact file — it is the **live output path** the protected bump
  gate writes on every run, not a historical snapshot (rule a). Kept untouched.
- **`packages/elm-cem/skills/releasing-elm-cem/SKILL.md`** — could have been
  removed alongside its four siblings (all described superseded internals). Kept
  and corrected instead: it documents the release *process* (OIDC trusted
  publishing, the two-public-surfaces semver policy), which nothing else
  documents and which remains accurate; only two internal citations were stale.

## Considered and KEPT because uniqueness was in doubt (flag, not delete)

- `packages/elm-cem/specs/2026-08-05-open-global-attributes-design.md`,
  `specs/2026-08-05-value-primitives-codegen-design.md` — carry non-obvious
  rationale (the ARIA-hybrid precedent, the "why the row axis had to be
  brand-neutral" argument) that is *partially* restated in code comments now, so
  there's real redundancy — but not total. Flag for a future doc-consolidation
  pass rather than deleting now.
- `packages/elm-m3e/MIGRATION.md` — its module-path mapping table is stale twice
  over (predates even the intermediate `M3e.<Component>.Build` layout, itself
  since replaced by `M3e.Build.<Component>`), but several gotcha sections are
  unique and not restated anywhere else: the `onChange`/`onChangeWith` decoder
  trap, `Seam.recast` usage discipline, the Lamdera `elm/virtual-dom`
  direct-dependency caveat. Left as-is; a full rewrite of the path table was out
  of scope for this pass's confidence level given how much of this corpus turned
  out to be live.
- `packages/elm-m3e/specs/2026-08-06-nav-rail-migration-design.md` — the
  migration itself shipped, but the doc records Material 3's nav-drawer
  deprecation rationale plus a section/landing-page coverage audit not preserved
  elsewhere.
- `packages/elm-m3e/docs/plans/2026-08-11-theme-reel-m3e-audit.md` — a dense
  corpus of verified, non-obvious `@m3e/web` facts (no `interactive` attribute —
  it's `actionable`; no font-family design token exists at all; custom-property
  inheritance is by shadow-DOM tree proximity, not CSS specificity). Exactly the
  kind of unique mechanism explanation the rule exists to protect.
- `packages/cem-figma-connect/docs/coverage-remediation-plan.md` — the unique
  disposition record (BIND/APPEND/UPSTREAM/SKIP per figma-only component), still
  cited from `docs/upstream-requests.md`. `STATUS.md` says the remediation itself
  merged 2026-08-12; a maintainer should re-check whether the disposition record
  is now fully executed and safe to retire in a follow-up pass — not done here
  given the risk already demonstrated in this same directory.
- `packages/elm-review-cem/docs/decisions.md` — verified current and accurate
  (its one superseded section is explicitly marked `SUPERSEDED` in place with a
  reason, which is the doc doing its job, not staleness).
- `docs/facts-bundle/m3-consumer-scorecard.md`, `m3a-generated-diff.md`,
  `m3b-generated-diff.md`, `m3c-generated-diff.md` — each carries diff-level
  justification (exact field changes, why they're invisible today, per-component
  classification) not reproduced in `GAUNTLET-LEDGER.md`'s prose summary, and
  `m3a-generated-diff.md` is explicitly cited by the ledger "per R-005." The
  scorecard's own caveats (§3.1–3.5: the dead `dts-inline.mjs`, the diverged
  tailwind fixture) may since be partially stale given M5's fixture-divergence
  fix — worth a maintainer re-check, not resolved here.
- `packages/_probe/` — actively wired into `tools/gate.mjs`'s `gate:all`, and
  documented in the root `README.md` as a deliberate living regression test of
  the workspace's dependency convention. Not cruft.
- `packages/elm-m3e/specs/2026-08-08-keyed-nodes-handoff.md` — describes a still
  **unresolved** bug (VDOM patch silently stripping `m3e-*` self-written default
  attributes on route navigation); cited from
  `docs/tests-browser/soft-nav-attribute-ownership.spec.ts`. Not history — an
  open problem.

## Investigated and found already clean (no action needed)

- `packages/elm-typed-html/`, `packages/elm-html-intermediate-representation/`,
  `packages/tailwind-m3e-web/` — no stale plans/handoff/status docs found; no
  README claims describing deleted pre-migration mechanisms.
- `.gate-out/` — gitignored, untracked, correctly excluded already.
- `packages/elm-review-cem/skills/*/SKILL.md` — verified accurate against current
  source (`Cem.Facts` genuinely lives in the published `jackhp95/elm-cem-facts`
  dependency, matching what these skills describe).

---

## Reference bar — commands run and results

```
pnpm install                                       # exit 0
node tools/check-drift.mjs                         # 9/9 passed, exit 0
bash tools/ab-elm-cem.sh                            # 143 files, byte-identical, exit 0
node tools/check-single-cem-facts.mjs               # exactly one Cem.Facts, exit 0
node tools/check-single-m3e-web-pin.mjs             # exactly one @m3e/web (2.7.3), exit 0
bash tools/copy-fidelity-elm-m3e.sh                 # GREEN (31 authorized-absent), exit 0
pnpm --filter m3e-docs run check                    # all checks pass, exit 0
pnpm --filter tailwind-m3e-web run test             # 10 files / 44 tests passed, exit 0
git -C /Users/jhp/code/jackhp95/elm-m3e status --porcelain   # empty, exit 0
```

Also run, not in the required bar but touched by this pass's edits:

```
pnpm --filter elm-cem run test                      # phantom gate: ALL GREEN, exit 0
bash packages/elm-cem/.github/neutrality-check.sh   # OK, exit 0
pnpm --filter cem-figma-connect run test            # 698/698 passed, exit 0
```

`tools/copy-fidelity-elm-m3e.sh` required one change: 25 of the confirmed-safe
elm-m3e deletions are git-tracked in the read-only source checkout, so they were
added to that script's `AUTHORIZED_ABSENT` list with a comment pointing back to
this document — the gate itself was not weakened, only told about deletions this
document justifies.
