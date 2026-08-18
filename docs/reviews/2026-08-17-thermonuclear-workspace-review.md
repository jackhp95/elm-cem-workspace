# Thermonuclear Code Quality Review — elm-cem-workspace (whole family)

**Date:** 2026-08-17 · **HEAD:** `325d3b9`-era (`325b3d9`) · **Method:** 7 parallel
read-only reviewer agents (per-package internals ×5, workspace tooling ×1,
cross-package architecture ×1) + 2 supplemental deep-dives (elm-cem
tests/configs/templates/facts; elm-cem codegen pipeline core), synthesized and
deduplicated here. Generated output (elm-m3e `src/`/`dist-packages`/icons,
`generated/` dirs, ~190k lines) was audited via its generators and spot-checks,
not line-by-line. Every finding below carries file:line evidence from a
reviewer who read the code; nothing is speculative.

**Lenses requested:** redundancy · poorly-coded areas · needless grouping ·
missing orchestration/sequencing · over-coupling to M3E (maiden voyage) ·
missed cleaner patterns.

---

## Executive summary

The family's *core design* is in better shape than a review this hostile
usually finds: the phantom-type pipeline is well-typed end to end, the facts
bundle is a real single-source-of-truth with a schema-validated contract,
`tools/bump.mjs` is genuinely atomic-in-intent orchestration with a
byte-stable-no-op self-test, elm-review-cem's four-test-class discipline and
the IR package's documented trust boundary are exemplary. Phase 0 ("the
spine") verifiably happened.

The damage clusters into **six cross-cutting themes**, and the two biggest are
not code-shape problems at all:

1. **Nothing enforces the gates.** The verification machinery is excellent and
   almost none of it runs automatically — no root CI, hooks not installed
   (docs claim otherwise), three packages fighting over one `core.hooksPath`
   key, publish-with-no-gate-precondition, a state ledger that lives dirty in
   the working tree. The 2026-08-12→17 mirror-fork incident is the documented
   cost of exactly this gap, and the gap is still open.
2. **M3E leaked into the wrong layer of the generic packages** — not into the
   Elm codegen core (which is clean), but into `elm-cem/bin/`, the
   cem-figma-connect matcher, one core model type, and two review rules. The
   "brand-pluggable" identity claim is currently asserted, never demonstrated.
3. **One-script-wearing-N-costumes duplication** across tools/ and packages
   (~2,000+ lines of byte-identical or near-identical copies, several with
   documented divergence bugs already shipped).
4. **Two monster compilation units** in elm-cem (`Emit.elm` 7,169 lines;
   `resolveWith` a single 1,243-line function) whose decomposition plans are
   already written in their own section comments.
5. **Dead and divergent config surface** — elm-cem decodes ~11 config fields
   nothing reads (silent no-ops for config authors), with one latent
   build-abort divergence bug.
6. **Generic logic trapped in M3E-side packages** — four fully-generic modules
   that a second-brand voyage would have to re-copy.

Blast radius on the recommended moves is mostly moderate and mechanical; per
workspace policy it is listed as a cost, never a blocker.

---

## Theme 1 — Enforcement: the gates exist, nothing runs them (BLOCKER)

The single highest-severity cluster. Independent reviewers converged on it
from three different directions.

| # | Finding | Evidence |
|---|---------|----------|
| 1.1 | **No root CI.** No `.github/workflows/` at the workspace root; `gate-all.mjs` calls itself "the ONE command that proves the whole workspace is green" (`tools/gate-all.mjs:2-3`) and has no automatic trigger anywhere. | `find .github -type f` → empty |
| 1.2 | **Pre-push hooks not installed.** `git config core.hooksPath` unset in this repo. `elm-typed-html`/`elm-html-intermediate-representation` `hooks/pre-push:8-9` claim "`postinstall` does it automatically" — false; their `package.json` `postinstall` only runs `elm-tooling install`. | `packages/elm-typed-html/package.json:9` |
| 1.3 | **`core.hooksPath` contention.** `m3e-okf` and `elm-m3e` both define `hooks:install` writing the same repo-global key — last writer wins, the other package's hook is never consulted. `tailwind-m3e-web` has no hook at all. | both `package.json` files |
| 1.4 | **False safety-net comment.** `tools/copy-fidelity-tailwind-m3e-web.sh:~45` asserts the workspace "already enforces" a root `core.hooksPath` — it doesn't. | verified live |
| 1.5 | **`publish-mirror.mjs` has no gate precondition** — nothing stops publishing a red/stale tree; `check-mirror-drift.mjs` only catches it after the fact, and only if `publish-mirror-state.json` was committed. That ledger is currently **dirty in the working tree** recording two real publishes. | `tools/publish-mirror.mjs:39` (`writeState`), live `git status` |
| 1.6 | **`bump.mjs` is non-atomic on failure.** It rewrites every package.json, regenerates every consumer bundle, *then* runs gate-all; a gate failure exits 1 leaving a half-applied migration in the working tree with no rollback. | `tools/bump.mjs:225-304` |
| 1.7 | **`tailwind-m3e-web` has no `check` script**, so gate-all's `pnpm ls -r` discovery silently never runs its real invariant `bin/check-privates.mjs` (136 lines). One-line fix. | `packages/tailwind-m3e-web/package.json` |
| 1.8 | **Per-package CI workflows are inert and stale.** GH Actions only reads root workflows, so `packages/*/.github/workflows/ci.yml` only ever run on the read-only mirrors. They also hardcode check subsets that have already drifted (elm-typed-html CI omits `check:whatwg` + `check:drift` — the two gates written as backstops for previously-shipped bugs; the IR package's omits `check:acid` + `test`). | both `ci.yml` files |
| 1.9 | **The mirror CI graph is a second, tribal regen DAG.** `elm-m3e`'s mirror CI clones four sibling repos via PAT at hardcoded relative paths, with the sibling-fetch step copy-pasted 3× inside one file; the dependency order exists only as YAML step ordering, never exercised from inside the monorepo. This is the exact seam where the 08-12→17 fork happened. | `packages/elm-m3e/.github/workflows/ci.yml` (~22-24, ~147-149, ~193-195) |
| 1.10 | **Chronically-skipped gate is invisible.** `copy-fidelity-elm-m3e.sh:37` defaults to a snapshot dir deleted at M6 — the gate has SKIPped forever; gate-all doesn't distinguish "chronically skipped" from "skipped this run". Similarly orphaned: `fetch-snapshots.mjs`, `measure-docs-size.mjs` (the registry doc-size cap that already bit `elm-m3e-icons` once), `check-m3e-5pkg.mjs` — none wired to anything. | `tools/` |
| 1.11 | **ELM_HOME cache contamination across worktrees.** `stage-facts-elm-home.mjs` validates the global `~/.elm/.../elm-cem-facts/1.0.0` cache slot by `elm.json` byte-equality only — two concurrent worktrees with different `Cem/Facts.elm` silently compile against whichever seeded first. This workspace runs 7+ concurrent agent worktrees. | both copies of the script |

**Remedies (ranked):** root `.github/workflows/ci.yml` running
`node tools/gate-all.mjs` on push/PR; single root-level `hooks:install` owning
`core.hooksPath` (package hooks become sourced extensions); `publish-mirror
--push` refuses unless gate-all passed and auto-commits its state ledger;
`bump.mjs` snapshots (stash/scratch-worktree) before mutating and restores on
failure; add `check` script to tailwind-m3e-web; hash `src/` into the ELM_HOME
staleness check; make gate-all track chronic SKIPs.

---

## Theme 2 — M3E coupling in the wrong layer

The good news first: **the generic cores are clean.** Zero functional M3E
coupling in `elm-cem/codegen/` (28 hits, all doc-comment examples — verified
none are runtime literals), `elm-cem/templates/` (0 hits), `cem-configs/`,
`facts/`, elm-typed-html `src/`, the IR package, and elm-cem-compose (which
*enforces* it via `bin/check-headless.sh` — best-in-family discipline, the
pattern to replicate).

The leaks, in severity order:

| # | Finding | Evidence |
|---|---------|----------|
| 2.1 | **`gen-icon-module.js` emits a hardcoded `"m3e-icon"` DOM tag and "Material Symbols" doc prose** in a generic, config-invitable feature (`_iconModule`). A non-M3E brand opting in gets silently *wrong generated output* (an element that doesn't exist in their DOM). Functional blocker, not a doc nit. | `packages/elm-cem/bin/gen-icon-module.js:231,148,166,183` |
| 2.2 | **`ActionsRoster.bottomSheetComp`/`dialogActionComp`** — Material Design pattern names as fields in the core `Brand` model, with bespoke emission branches. A second library's rich-payload wrapper concept requires patching `Model.elm` + `Emit.elm` by name. Remedy: generalize `ActionWrapper` with an optional payload-shape descriptor so both fields disappear. | `codegen/Generate/Phantom/Model.elm:525-528`, `Emit.elm:6344-6420` |
| 2.3 | **`bin/eject.js` "brand registry" has one hardcoded entry** (`BRANDS = { m3e: {...} }`) — the advertised-generic `eject` feature structurally works for exactly one vendor; `usage()` prints "Brands: m3e" as if intentional. `bin/family-deps.js:69-96` hardcodes the M3E family package list the same way. Root cause of the 104 `m3e` occurrences in `bin/` (vs ~0 in the layers documented as the vendor-specific home — the layering is inverted). | `packages/elm-cem/bin/eject.js:34-42` |
| 2.4 | **cem-figma-connect matcher quarantine breach.** `DESCRIPTION_UNTRUSTED = new Set(["m3e-menu-item","m3e-stepper-previous"])` plus Material-vocabulary tables (`BOOLEAN_OPTION_POLARITY`, `BOOLEAN_AXIS_SYNONYMS`, `MULTI_BOOLEAN_AFFINITY`) and an m3-kit-calibrated `FUZZY_ACCEPT_THRESHOLD` hardcoded in the generic matcher — directly contradicting the spine-design doc's written promise that m3e-specificity stays in `profiles/m3-kit/`. The profile mechanism already exists; these just don't use it. | `packages/cem-figma-connect/src/match/matcher.mjs:34,44,101-113,171-175` |
| 2.5 | **`RequireFabLabel`/`RequireFormFieldLabel` hardcode M3E nouns** (`fabNoun = "fab"`, `formFieldNoun = "formField"`) in violation of the package's own house rule #1 ("derive, never hardcode"). Semantic coupling the lexical neutrality gate (`grep material|m3e|md3`) is structurally blind to. Remedy: a generator-set `Fact` field (e.g. `requiresDiscoverableAccessibleName`). | `packages/elm-review-cem/src/Cem/RequireFabLabel.elm:157-159`, `RequireFormFieldLabel.elm:160-162` |
| 2.6 | **The "brand-pluggable" claim is unproven.** `cem-configs/README.md` states outright that nothing in `bin/` or `codegen/` reads the four vendor configs; no CI/test ever runs elm-cem against a second brand. The test suite's only generic fixture is named `nonm3e.cem.json` — M3E is the unmarked default, backwards for a generic forge. | `packages/elm-cem/cem-configs/README.md`, `tests/fixtures/` |

**Highest-leverage move for this theme:** run one real second brand (Carbon or
Spectrum — configs already sit there unused) end-to-end through codegen, gated
in CI. It flushes 2.1–2.3 as hard failures instead of latent ones, and turns
the VISION.md identity claim from asserted to demonstrated. Until then,
scope the claim honestly.

---

## Theme 3 — One script, N costumes (redundancy)

Confirmed byte-identical or near-identical copies, with divergence already
observed in several families:

| Family | Copies | Evidence / divergence |
|---|---|---|
| `check-bundle-provenance{,-m3e-okf,-tailwind}.mjs` | 3 (~430 lines) + a **third parallel implementation** inside `check-drift.mjs` (`checkConsumerBundleDrift`, already generic) | gate-all runs *both*, regenerating the bundle twice per run; the two impls check different things (git-trackedness, icon-names) and nothing proves they agree. **Delete the 3 standalone scripts; extend the generic engine.** |
| `copy-fidelity-*.sh` | 4 (822 lines) | features (`AUTHORIZED_ABSENT_PREFIX`) exist in 2 of 4 — already diverged |
| `hooks/pre-push` | 6 byte-identical (md5 `b71a...`) + **elm-m3e's silently diverged** (176-line variant with Netlify logic interleaved, no marker separating shared base) | fix to the shared 66 lines can't reach elm-m3e's copy cleanly |
| `stage-facts-elm-home.mjs` | 2 byte-identical (elm-cem-compose, elm-review-cem); commit `1fe7890` patched both by hand in one commit | proof the duplication is known and manually synced |
| `gen-facts.mjs` | 2 (tailwind-m3e-web, m3e-okf) identical mod comments | |
| elm-cem CLI test harness | ~12 of 15 `tests/*.test.mjs` re-declare identical `here`/`repo`/`check`/exit boilerplate; no `tests/lib/harness.mjs` (`tests/phantom/suites.mjs` already proves the right pattern) | |
| elm-review-cem `declarationEnterVisitor` let-scope collector | **10 identical copies**; `Cem/ValidSlotKind.elm:105-108` carries a standing comment saying it should be hoisted — the debt was flagged, then grew | |
| elm-review-cem `isAllowed` | 5 byte-identical; `NoInternalImportOutsideAllowed`/`NoUnsafeImportOutsideAllowed` are whole-module near-twins | |
| elm-review-cem accessible-name pair | `RequireFabLabel`/`RequireFormFieldLabel` ~85% identical (11 named functions byte-for-byte) | |
| `PreferBarrel`/`PreferComponentModules` inverse tables | duplicated literal inverse maps; `docs/decisions.md` documents past bugs from exactly this asymmetric hand-maintenance | |
| Misc | `capitalizeFirst` ×3 (canonical `Facts.capitalize` exists), `isCallTo` ×3, `countBy`/`dedupeByName` ×2, `listFilesRecursive` ×2, `bin/` direct-exec guard ×3 (has its own regression test — it already broke once), elm-m3e ReviewConfig ignore-path literals ×3 | |

**The manifest move (code judo):** `publish-mirror.mjs` already contains the
right shape (`FAMILY`, lines 56-70) and `tools/lib/consumer-output-drift.mjs:28-78`
independently invented a second one. Nothing else reads either.
`gate-all.mjs`'s own header (lines 6-9) says discovery must "never [be]
hardcoded" — then hardcodes the provenance/fidelity calls by package name
four lines later. **One `tools/family.json`** (srcDir, bundleFiles,
copy-fidelity allowlists, regen commands, check hooks) consumed by
publish-mirror + one provenance engine + one fidelity engine + gate-all
deletes an estimated 600–700 lines and makes "add a 4th consumer" a data
change.

---

## Theme 4 — Monster files / functions (elm-cem core)

| Target | Size | Verdict |
|---|---|---|
| `codegen/Generate/Phantom/Emit.elm` | **7,169 lines** | ~13-15 independent emitters concatenated; the file's own section comments (`FAIL-LOUD GUARD` 159-1232, `HTML MODULE`, `ATTRIBUTES MODULE`, …) already *are* the decomposition plan. Split into `Emit.Guards`, `Emit.Component`, `Emit.Attributes`, etc.; `Emit.elm` keeps its actual public contract (`files : Brand -> Result (List String) (List Elm.File)`, line 61) as a thin composer. Execution, not design work. |
| `Generate/Phantom/Model.elm` `resolveWith` | **one 1,243-line function** (1342-2585) | nested `let` helpers (`ctorIndex` 1422, `resolveSlot` 1492, `buildComp` 1558, …) untestable/unnavigable as closures. Lift to top-level functions threading an explicit `Ctx`. Highest-leverage, lowest-risk move in the package. |
| `bin/elm-cem.js` | 1,021 | 10-branch `if (rawArgs[0] === …)` chain → dispatch table; move inlined icon/family wiring (227-262) out. Drops under 1k. |
| `profiles/m3-kit/emitters/elm.mjs` | 1,009 | same prop-shape-dispatch disease as `html-label.mjs` (964) — see Theme 6.3 |
| `codegen/Attr.elm` | 1,061 (~55% load-bearing prose) | mechanical 3-way split available (`Attr` / `Attr.Kernel` / `Attr.Classify`); or just move the 125-line `kernelBlockedReason` doc block to docs/ |
| Waived | `HtmlIr/Internal.elm` 1,061 (~46% prose — the doc ratio *is* the safety mechanism for the audited trust boundary), `NoRedundantAttributeEscape.elm` 1,059 (~200 lines doc) | justified exceptions |
| Generator-output signal | `M3e/Icon.elm` **28,640 lines / one flat module** (~7k bindings); `TypedHtml/Values.elm` 2,870; `Text.elm` 2,221 | not fixable in consumers (drift-gated); feed back into elm-cem's emission strategy (chunking / per-family modules). The registry doc-size cap gate is already treating the symptom. |

---

## Theme 5 — Dead & divergent code (elm-cem pipeline)

The "legacy 5-form pipeline retired" cleanup (`Generate.elm:3-6`) was never
finished:

- **BLOCKER — dead config surface with silent no-ops.** `Generate/Config.elm:311-352`
  decodes ~11 per-component fields and 5 top-level fields the live pipeline
  never reads (`Model.resolve` re-decodes raw JSON itself). `idWiring`,
  `slots`, `group`, `staticAttrs`, `_native`, `_nativeAttrTable` etc. are
  **silent no-ops for config authors** — including the fully-documented
  `IdWiring` mechanism. Deleting the dead surface roughly halves Config.elm.
- **BLOCKER (latent bug) — divergent duplicate decoder.** Config.elm's dead
  `_actions` decoder requires `doc` (`Config.elm:396-403`); Model.elm's live
  one defaults it (`Model.elm:1004-1010`). Because the dead one is fail-loud
  (`optStrict`), a manifest omitting `doc` on any wrapper **aborts the whole
  build** even though the only decoder whose output is used accepts it. Same
  class as the documented `datetime`/SharedAttrs postmortem.
- **MAJOR — `Model.elm` reimplements `Util.deduplicateBy` as O(n²) `dedupBy`**
  (2757-2765, used 6× on manifest-scale data), reintroducing the exact
  quadratic bug `Util.deduplicateBy`'s own docstring says it fixed (issue #27).
  Model.elm doesn't import Util at all.
- **MAJOR — `"main" -> "main_"` hand-rolled at 6 sites** (Model.elm ×5,
  Emit.elm:1409) while `Naming.safeValue` — which handles all Elm keywords —
  sits with zero call sites.
- **MAJOR — `Docs.generateViewDocumentation`** (+`bulletedSection`, ~115 lines,
  the most prominent function in the file): zero call sites.
- **MAJOR — `tests/src/GenerationTest.elm` (511 lines)** tests reimplemented
  logic, never imports `Generate`; `IRTest.elm:6-8` names it a dead pattern in
  its own docstring. Delete/fold.
- **`tools/move2/`** — dead, hardcodes another machine's filesystem path
  (`/Users/jhp/...`), explicitly superseded per `measure-docs-size.mjs`'s
  docstring. Delete.
- **cem-figma-connect `dts-inline.mjs`/`classifyAttribute`** (~220 lines) —
  confirmed dead in production, kept only for its own tests (a twice-reaffirmed
  KEEP; either close the debate permanently in a comment or delete).
- Minor: `LibraryInfo` carries 4 inert fields whose doc comments reference a
  function (`generateFromManifest`) that no longer exists anywhere;
  `extractLibraryInfo` runs the full extract pipeline twice per generation;
  vestigial scrub-only keys (`_baseSlots`, `_seams`, `_runtime`, `_categories`).

---

## Theme 6 — Package boundaries & trapped generic logic

**Verdicts (cross-package reviewer, confirmed by internals reviewers):**

| Package | Verdict |
|---|---|
| elm-cem, elm-m3e, elm-review-cem, m3e-okf, tailwind-m3e-web | Keep |
| elm-html-intermediate-representation | **Keep separate from elm-typed-html** — verified genuine two-consumer substrate (elm-m3e imports `HtmlIr.*` directly, 200+ files); collapsing would force elm-m3e to depend on TypedHtml for nothing |
| elm-cem-compose | Weak keep — one consumer (`elm-m3e/docs`, unpinned relative path), functionally a module wearing package clothes; keep the (exemplary) headless discipline, don't imply multi-consumer reuse until a second consumer exists |
| **elm-cem-facts** | **Extract to top-level `packages/elm-cem-facts/`** — already an independent unit everywhere (own elm.json/version/mirror/fallback machinery) except physical location; two publish targets currently share one directory tree. Mechanical `git mv` + path-const updates ×~4 |
| **cem-figma-connect `src/tokens/*`** | **Extract out** (~3.4k lines, 8 files) — a `@m3e/web` ⋈ `tailwind-m3e-web` token-diff tool with a literal cross-package source import (`classify-delta.mjs:54` imports from `../../../tailwind-m3e-web/bin/...`), hardcoded sibling paths, absent from the package's own architecture diagram, never touched by its CLI. Move to its own package or into tailwind-m3e-web |

**Generic logic trapped in M3E-side packages** (a second voyage re-copies all
of this today):

1. `m3e-okf/scripts/lib/okf-lib.mjs` (140 lines) — 100% generic frontmatter/
   licensing-compliance toolkit, zero m3e references.
2. `tailwind-m3e-web/bin/generate-component-utilities.mjs` — generic Face-B →
   Tailwind-v4 generator; m3e only in comments/paths.
3. `tailwind-m3e-web/bin/calibrate-tones.mjs` — generic HCT→OKLCH math.
4. `m3e-okf/scripts/lib/validate-markup.mjs` — the load-bearing CEM
   ground-truth validator, generic except two `startsWith("m3e-")` literals
   (lines 76, 112). Same anti-pattern ("prefix-guess instead of the real
   generated list") as the already-tracked `NoProprietaryDsClasses` gap #2 —
   fix as one lesson, not two patches.
5. `elm-m3e/scripts/fetch-mdn-native-summaries.mjs` — native-HTML concern that
   belongs upstream; its `ATTR_OWNER` table is a hand-synced duplicate of the
   generator's `nativeAttrTable` per its own line-53 comment.
6. `m3e-okf` package.json is named **`m3e-docs`** while everything calls it
   m3e-okf — `pnpm --filter m3e-okf` silently fails.

**Other structural findings:**

- `m3e-okf/scripts/extract.mjs` (570 lines) bundles four concerns (Face-B
  projection / TS-import-graph+CSS scanner / Markdown-table parser / drift
  report); the Markdown parser inside is itself trapped-generic.
- cem-figma-connect `emitEntry` (`src/emit/html-label.mjs:541-699`): 7 parallel
  `.filter()` shape-classifiers + a hand-maintained consumed-props `Set` —
  replace with a `PROP_SHAPE_HANDLERS` dispatch table (same fix applies to the
  1,009-line profile Elm emitter); plus a 3× byte-identical icon-table block
  (240-254 / 300-311 / 449-460).
- cem-figma-connect gate gap: `publish` verifies `generated/**` against
  `correspondence.json` but nothing verifies correspondence is still *derived
  from current inputs* — a stale correspondence after a CEM/kit refresh passes
  every gate. Add `match --check` (the `--check` pattern already exists in
  derive/resolve-palette).
- elm-review-cem facts-index convention gap: the "MUST use `Facts.buildIndex`"
  rule exists only as a convention doc + a 2-rule spot-test after this exact
  bug class shipped once; nothing stops rule #25 from hand-rolling a dead
  index. Either make it structurally impossible (don't expose the raw fields)
  or meta-test every exposed rule against the real-shaped fixture.
- elm-cem test-harness mechanisms: 4 distinct (CLI mjs / phantom golden /
  enum-override / attr-property) where 2 would do — fold the two bespoke
  feature dirs into phantom fixtures.
- `spectrum.config.mjs` is the only analyzer config with no `exclude` block —
  will sweep Spectrum's test/story files into the manifest.
- cem-figma-connect tests: zero `describe()` blocks across 18 flat files
  (61-test files scanned linearly); `test/elm-emitter.test.mjs` tests a
  profile-local file from core `test/`, blurring the same boundary as 2.4.

---

## Consolidated top 10 moves (ranked by leverage)

1. **Wire enforcement** (Theme 1): root CI running gate-all; single root
   `hooks:install`; publish-mirror gate-precondition + auto-committed ledger;
   `check` script for tailwind-m3e-web; bump.mjs rollback. The family already
   paid for this gap once (the 5-day mirror fork).
2. **Prove or retract brand-pluggability** (2.6): one second-brand end-to-end
   codegen run in CI. Flushes the `m3e-icon` tag bug (2.1), `eject` BRANDS
   (2.3), and `actionModule` (2.2) as hard failures.
3. **Decompose `resolveWith` + split `Emit.elm`** along its own section
   comments (Theme 4). Pure mechanical extraction, no behavior change.
4. **One family manifest** (`tools/family.json`) consuming the provenance /
   copy-fidelity / gen-facts / gate-all hardcoding; delete the 3 standalone
   provenance scripts in favor of the already-generic `checkConsumerBundleDrift`
   (Theme 3). ~600-700 lines gone, double-regeneration gone.
5. **Delete the M3E specifics from generic layers** (2.1–2.5): parameterize
   gen-icon-module's tag/prose; generalize ActionWrapper; config-drive
   eject/family-deps; move matcher vocabulary into profile config; fact-field
   the FAB/FormField nouns.
6. **Finish the legacy-pipeline cleanup** (Theme 5): delete dead Config.elm
   decoders (kills the divergent `_actions` bug), dead Docs/Naming/
   GenerationTest/move2 code; swap `dedupBy` → `Util.deduplicateBy`; wire
   `Naming.safeValue` at the 6 hand-rolled sites.
7. **elm-review-cem shared-module extraction**: hoist the 10× let-scope
   collector (self-flagged TODO), extract `Cem.Internal.AccessibleName`
   (folds in the noun fix), `Cem.Internal.Gate` (5× `isAllowed`),
   `Cem.Internal.BarrelMapping` (documented bug source).
8. **Extract misplaced subsystems**: `src/tokens/*` out of cem-figma-connect;
   `elm-cem/facts` to top-level `packages/elm-cem-facts/`; dedupe
   `stage-facts-elm-home.mjs` into `tools/lib/` (+ hash `src/` for cache
   validity).
9. **Promote the four trapped generic modules** (okf-lib,
   generate-component-utilities, calibrate-tones, validate-markup) so the next
   voyage gets them free; fix both `startsWith("m3e-")` prefix-guesses as one
   lesson.
10. **Close the derived-artifact staleness gaps**: `match --check` in
    cem-figma-connect; facts-index meta-test in elm-review-cem; chronic-SKIP
    tracking in gate-all.

---

## What's genuinely good (keep doing this)

- `elm-cem-compose/bin/check-headless.sh` — enforced brand-agnosticism, the
  family exemplar.
- `docs/facts-bundle/schema.json` + coverage map — the one explicit, versioned,
  machine-checked cross-package contract. Replicate this pattern; it is
  currently singular.
- `tools/bump.mjs`'s byte-stable-no-op self-test; `tools/lib/regen.mjs`'s
  documented 8→2 consolidation; `tests/phantom/suites.mjs`'s single
  fixture-table shared by gate+bless.
- elm-review-cem's four-test-class discipline and tests-as-institutional-memory
  (`RealFactsShapeTest`, `RoundTripTest`); the three redundancy rules correctly
  sharing `Facts` primitives.
- `cem-figma-connect/src/publish/runner.mjs` running `check` before `publish`
  unconditionally.
- The IR package's trust-boundary documentation and cross-brand privacy proofs
  (`MiniM3e`/`MiniNative`).

## Reviewer-report provenance

Full per-package reports were produced by the seven reviewer agents (elm-cem
core; elm-cem tests/configs/templates/facts; elm-cem codegen pipeline core;
cem-figma-connect; elm-typed-html/IR/compose; elm-review-cem; m3e-side
packages; workspace tools; cross-package architecture). This document is the
deduplicated synthesis; where reviewers disagreed (e.g. the review brief
questioned the IR/typed-html split, the reviewer verified it should stay),
the evidence-backed verdict is recorded here.
