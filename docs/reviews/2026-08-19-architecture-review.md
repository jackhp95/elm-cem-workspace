# Architecture Review — elm-cem-workspace (holistic), 2026-08-19

**Scope:** whole workspace at branch `arch/holistic-improvements` (HEAD `35c5aa30` = today's
core/brands reorg + enforcement hooks + cem-figma-connect publish fixes, merged).
**Method:** required-reading pass over VISION.md / README.md / GAUNTLET-LEDGER.md / the Phase-0
spine spec / all of `docs/plans/*` / `docs/reviews/*` / `docs/copy-fidelity-notes.md` /
`core/cem-figma-connect/plans/BRIEF.md` / recorded frictions / git archaeology, then six parallel
read-only exploration agents (elm-cem, cem-figma-connect, tools+hooks, brands/m3e+docs app, Elm
substrate, stale-path scan), then first-hand verification of every load-bearing claim (every
file:line below was checked in this worktree). A timed baseline `gate-all` run was captured at
`/tmp/arch-holistic-gate-baseline.log`.
**Audience:** planning committee → execution pipeline. Every candidate is self-contained:
problem/evidence, solution, benefits, blast radius (a cost, never a blocker), mechanical
migration, and the gate/test that verifies it.
**Vocabulary:** module / interface / implementation / depth / seam / adapter / leverage /
locality, per the codebase-design canon. Deletion test = delete the module; if complexity
vanishes it was a pass-through, if it reappears across callers it was earning its keep. "The
interface is the test surface." One adapter = hypothetical seam; two = real.

## Constraints honored (from the decision record — not re-litigated)

- `github.com/jackhp95/<name>` repos are **read-only published mirrors**; publish only via
  `tools/publish-mirror.mjs`. Nothing below edits a mirror.
- Elm `type: package` `elm.json`s stay **registry-faithful** (coexistence convention rule 3;
  ledger D-003). Nothing below adds monorepo paths to a package elm.json.
- The **core/ vs brands/ split is today's deliberate decision**
  (`docs/superpowers/specs/2026-08-18-core-brands-workspace-reorg-design.md`, status:
  implemented). Every candidate builds on it; none reverses it.
- The **agent-time enforcement philosophy** (fast, dependency-free hooks before pre-push/CI;
  `docs/plans/2026-08-19-durable-m3e-convention-enforcement.md`, D1–D4 all RESOLVED/IMPLEMENTED)
  is deepened, never removed.
- Prior remediation waves W1/W2/W3/W5/W6 (thermonuclear audit,
  `docs/plans/2026-08-18-thermonuclear-audit-remediation.md`) are **merged and verified** — not
  re-litigated. W4/W7/W8 + the brand-pluggability proof are the recorded open remainder; this
  review carries them forward with fresh evidence rather than rediscovering them.

## Baseline gate health (one-line verdict + detail)

The timed baseline run finished: **GATE-ALL RED in 150.7s wall** in this (unprovisioned)
worktree — the single FAIL is `workspace: check-mirror-drift` (exit 1), the **pre-existing,
verified-unrelated** direct commit to the standalone `jackhp95/elm-m3e` mirror recorded in
`docs/plans/2026-08-18-core-brands-workspace-reorg-plan.md:5-8`. The 150.7s figure understates
the real cost: `elm-m3e: check` and `elm-m3e: test` **SKIPped** (missing `data/reference.json` /
Playwright in a bare worktree), plus 3 copy-fidelity gates SKIPped (unfetched snapshots). The
honest provisioned number is the spec's measured **361.5s warm**, 64% of it
`elm-m3e: test:browser` at 231.9s
(`docs/superpowers/specs/2026-08-18-gate-all-parallelization-design.md:29-35`). Jack's remembered
"15–20 min" is the cold/unprovisioned + docs-build experience; the warm measured truth is 6 min —
still gating every push, still dominated by one step.

## What is genuinely good (keep doing this — the review's control group)

- **The facts-bundle contract**: one producer (`core/elm-cem`), schema-validated faces
  (`docs/facts-bundle/schema.json` + `core/elm-cem/bin/validate-facts-bundle.js`), consumers read
  the bundle through real projection layers (`core/cem-figma-connect/src/ingest/cem.mjs:80-110`
  presents a small stable shape to every downstream module). This is the deep-module pattern
  working.
- **`core/elm-cem/src/elm-shape.mjs`** — Phase 1's canonical html→elm grammar engine, extracted
  from two duplicating consumers, guarded by `tools/check-elm-shape-drift.mjs` (API surface +
  golden + anti-re-inlining). Deepening in action; candidate 11 finishes the job.
- **Acid probes + `expectInfoContains`** (`core/elm-cem/tests/phantom/`) — genuine correctness
  proofs (positive probes must compile, negative must fail), not just change detection; the
  authors even closed byte-diffing's blind spot with stdout assertions
  (`tests/phantom/gate.mjs:104-109`).
- **`core/elm-cem/bin/check-gates.js`** — a meta-gate proving no check is silently skippable,
  built in response to a real false-green incident.
- **The agent-time layout hook's drift discipline**
  (`tools/check-layout-only-classes.mjs:46-60`): the taxonomy is parsed at runtime from the real
  elm-review rule + `ReviewConfig.elm` + the committed `utilities.json` — a mirror that
  structurally cannot drift on the lists, only on ~15 lines of scaffolding, each pinned by test.
  The best "share, don't duplicate" example in `tools/`.
- **The publish gate-loop fixes** (`18beb3f0` defensive per-entry isolation +
  `dfdfdb7c` root-cause domain predicate `hasNoCapturedSetProperties`,
  `core/cem-figma-connect/src/visual/sample.mjs:178-191`) — two-layer error design with negative
  tests (`src/visual/sample.test.mjs:217` proves a mixed entry is NOT exempted). Not patched-on.
- **`tools/family.json` + `tools/copy-fidelity.mjs` + `tools/lib/consumer-output-drift.mjs`** —
  the W5 "manifest move" is real for the copy-fidelity/bundle-copy/mirror layer; candidate 3
  extends it to the layer it doesn't yet cover.
- **`core/elm-cem-compose/bin/check-headless.sh`** and the IR package's trust-boundary docs —
  still the family exemplars the 2026-08-17 review named.

## Live defects found during this review (fix regardless of any candidate)

These are not candidates; they are bugs the review surfaced. Candidate 3 prevents the class.

| # | Defect | Evidence |
|---|---|---|
| L1 | **Root CI is broken right now**: the "Install Playwright Chromium" step runs in `working-directory: packages/elm-m3e/docs`, which no longer exists (moved to `brands/m3e/outputs/elm-m3e/docs` in `e0cad429`). The next CI run fails at that step before gate-all ever runs. `07752291` edited this same file two hours *after* the reorg (added `REQUIRE_CLONE_GATES`) without fixing the stale line above its own edit. | `.github/workflows/ci.yml:74`; `packages/` contains only `_probe` (verified); commit timeline `40c868a9` → `e0cad429` → `07752291` |
| L2 | **`tools/tasks.mjs` is silently blind**: it still walks only `packages/` (`tools/tasks.mjs:28,74`), so the coexistence convention's rule-6 component ("the one component that knows the whole family graph", README.md:57-59) now reports `(none)` JS packages and only the two `_probe` Elm packages (verified by running it). `tools/gate.mjs` runs it and stays green — no fail-on-absence, the exact D-010 ledger lesson ("a deterministic gate must be able to FAIL ON ABSENCE") violated by the gate that predates it. | `node tools/tasks.mjs` output: `(none)`; `tools/gate.mjs:24` |
| L3 | **Stale provenance is being re-written into a committed fixture**: `core/cem-figma-connect/src/tokens/resolve-palette.mjs:257` stamps `vendoredFrom: "packages/tailwind-m3e-web/src/…"` into `test/fixtures/tailwind-computed-palette.json`, while the same file's `VENDORED_DIR` (lines 45-47, updated for the reorg) reads from `core/tailwind-md3/src`. Wrong prefix *and* wrong package; regenerating refreshes the lie. | file:lines as cited |
| L4 | **`tools/family.json:98` carries a now-false note**: it says m3e-okf's `package.json` name "is `m3e-docs`… not fixed by W5" — W6 renamed it to `m3e-okf` (verified: `brands/m3e/outputs/m3e-api-okf/package.json` name = `m3e-okf`). The `pnpmFilterName` indirection it justifies may now be vestigial. | `tools/family.json:97-98`; W6 item 6 in `docs/plans/2026-08-18-thermonuclear-audit-remediation.md:103-107` |
| L5 | **`core/elm-cem/CONTRIBUTING.md` 404s on its own walkthrough**: it instructs contributors to study `GoldenTest` (lines 49,57,102,174) and `SyntheticAttrTest.elm` (line 94); neither exists anywhere in the repo (retired with the legacy 5-form pipeline; superseded by `tests/phantom/`). A new contributor (or agent — see friction F-01's "agents keep re-diagnosing this repo from doc prose") dead-ends at step 2. | `core/elm-cem/CONTRIBUTING.md:49,57,94,102,174`; `tests/src/` listing |
| L6 | **README.md/VISION.md describe the pre-reorg layout as current**: README's Layout section (`README.md:13-16,27-36`) and convention rule 1 say the family lives under `packages/<name>/`; VISION points at `packages/cem-figma-connect/plans/BRIEF.md` (`VISION.md:8`) and "mirror of `packages/<name>/`" (`VISION.md:113`). The two north-star docs contradict the tree they describe, the day after the reorg. | file:lines as cited |

---

# Candidates

Index (ranked within strength tier by leverage):

| # | Candidate | Layer | Strength |
|---|---|---|---|
| 1 | One layout map: `tools/lib/family.mjs` resolver + discovery fail-on-absence + path-literal gate | tooling | **Strong** |
| 2 | Ship the gate-all step pool: per-step timing + tag-scheduled parallel dispatch | tooling | **Strong** |
| 3 | Untrack the built docs site: pick the deploy adapter, delete the committed-artifact family | structure/process | **Strong** |
| 4 | Gate trust: fix the drift-core test seam; make skip semantics a contract; test the high-blast tools | tooling | **Strong** |
| 5 | Brand #2 end-to-end: the reorg's own acceptance test + de-brand the tools layer | architecture/identity | **Strong** |
| 6 | cem-figma-connect `src/tokens/*`: finish the profile quarantine (W7, sharpened) | code | **Strong** |
| 7 | One prop-shape resolver behind the correspondence schema | code | Worth exploring |
| 8 | elm-cem internal locality: adopt `bin/shared.js`, curate `Emit/*` interfaces, own the bundle schema | code | Worth exploring |
| 9 | W4 carried forward: elm-review-cem internal seams | code | Worth exploring |
| 10 | `elm-cem-facts` to `core/elm-cem-facts` (W7, first half) | structure | Worth exploring |
| 11 | Finish Phase 1: migrate `to-elm.mjs` onto `elm-shape` and flip the PENDING flag | code | Worth exploring |
| 12 | Repackage the docs app out of the `elm-m3e` package directory | structure | Speculative |

---

## Candidate 1 — One layout map: `tools/lib/family.mjs` resolver, discovery fail-on-absence, and a path-literal gate

**Strength: Strong** · Layer: tooling · Fixes live defects L1, L2; prevents their class.

**Files:** `tools/family.json`, new `tools/lib/family.mjs`, `tools/gate-all.mjs`,
`tools/check-drift.mjs`, `tools/check-drift.test.mjs`, `tools/bump.mjs`, `tools/lib/regen.mjs`,
`tools/lib/gen-facts-runner.mjs`, `tools/ab-elm-cem.sh`, `tools/ab-elm-m3e-split.sh`,
`tools/check-cc-elm-refs.mjs`, `tools/check-elm-shape-drift.mjs`, `tools/measure-docs-size.mjs`,
`tools/gen-hooks.mjs`, `tools/gen-figma-config.mjs`, `tools/check-emit-determinism-cfc.mjs`,
`tools/check-single-cem-facts.mjs`, `tools/install-toolchains.mjs`, `tools/tasks.mjs`,
`tools/gate.mjs`, `tools/check-layout-only-classes.mjs`, `tools/nudge-m3e-skill.mjs`,
`.github/workflows/ci.yml`.

**Problem.** Workspace-layout knowledge is smeared across ~23 files that each hardcode
`core/…`/`brands/…`/`packages/…` literals, while `tools/family.json` — whose own header
(`family.json:2`) claims to be "the single source of truth for which packages exist, where" —
is read by only five scripts (`gate-all.mjs:48`, `check-drift.mjs:56`, `copy-fidelity.mjs:40`,
`publish-mirror.mjs:150`, `lib/consumer-output-drift.mjs:25`), each with its own `JSON.parse`.
The measured cost of that smear is tonight's history:

- The reorg's move commit `e0cad429` had to hand-edit **18 files under `tools/`**
  (82 insertions/65 deletions, `git show --stat e0cad429 -- tools/`), guided by a plan section
  that enumerated ~60 path references file-by-file
  (`docs/plans/2026-08-18-core-brands-workspace-reorg-plan.md:25-119`) — and the plan's own
  header still admits "several path-fix gaps not caught by this plan's own grep sweep were found
  and fixed during execution" (`…reorg-plan.md:8-11`).
- Two references escaped anyway and are live defects right now: **L1** (`ci.yml:74`, CI-breaking)
  and **L2** (`tasks.mjs` blind). A third, **L3**, is stale provenance re-written on every regen.
- `brands/m3e/outputs/elm-m3e` alone is independently hardcoded in **8+ places**
  (`gate-all.mjs:42`, `check-drift.mjs:55`, `check-drift.test.mjs:20`, `bump.mjs:34`,
  `lib/regen.mjs:37`, `lib/gen-facts-runner.mjs:35`, `ab-elm-cem.sh:26`, `ab-elm-m3e-split.sh:43`)
  — none reading `family.json.packages["elm-m3e"].srcDir`, which already holds that exact value
  (`family.json:9`).
- Deletion test on `family.json` today: `gate-all`'s copy-fidelity sweep dies instantly (good —
  load-bearing there), but `bump.mjs`, `lib/regen.mjs` and both A/B harnesses keep running
  unaffected — proof the manifest's real seam is narrower than its interface claims.
- `bump.mjs`'s `CONSUMERS` array (`tools/bump.mjs:39-55`) is a **fourth** hand-maintained copy of
  "which packages get a facts-bundle fan-out" — the same knowledge `family.json`'s `bundleCopy`
  blocks encode and `check-drift.mjs`'s `checkConsumers()` already derives dynamically. Adding a
  4th consumer today requires a data change *and* a silent code change one file away from the
  manifest that was built to prevent exactly that (thermonuclear Theme 3, "the manifest move").
- Package discovery ("what packages exist") is re-implemented as four independent walkers:
  `gate-all.mjs:139-174` (pnpm ls + fallback walk), `install-toolchains.mjs:54-56`,
  `check-single-cem-facts.mjs:87-89`, `tasks.mjs:28,74` — the reorg updated the first three and
  missed the fourth, which is precisely how L2 happened.

**Solution.** Make the layout map a deep module with one interface:

1. New `tools/lib/family.mjs` (zero-dep, ~60 lines): loads `family.json` once and exports
   `pkgDir(name)`, `pkgPath(name, ...segments)`, `allPackages()`, `bundleCopyConsumers()`,
   `copyFidelityPackages()`, `discoveryRoots()` (→ `core/`, `brands/*/inputs|outputs/*`,
   `packages/_probe/*`, derived from the same globs `pnpm-workspace.yaml` declares — or better,
   read the globs). Fail loud if a named package is missing or its `srcDir` doesn't exist —
   discovery gains the D-010 "fail on absence" property.
2. Migrate every `tools/*.mjs`, `tools/lib/*.mjs` and (via a tiny `node -p` shim or generated
   `.sh` prelude) both A/B harnesses to `pkgDir()`/`pkgPath()`. Replace `bump.mjs`'s `CONSUMERS`
   with `bundleCopyConsumers()`. Point `tasks.mjs`/`gate.mjs`/`install-toolchains.mjs`/
   `check-single-cem-facts.mjs` at `discoveryRoots()`.
3. Add `tools/check-layout-literals.mjs` to the gate: greps `tools/**` (and `.github/workflows/`)
   for `packages/|brands/|core/` path literals outside `family.json` + a tiny reasoned allowlist,
   and fails on any hit. New hardcoding becomes a red gate, not a review nit. CI YAML can't import
   JS, so the check *covers* it instead: assert every `working-directory:` in workflows exists on
   disk (that single assertion would have caught L1).
4. Mechanical doc sweep from Appendix A (categories A/B) — README/VISION layout sections, the
   handful of live comments.

**Benefits.**
- *Locality:* the next reorg (a `brands/carbon/` landing — candidate 5 — or W7's moves) is a
  one-file data change plus `git mv`, not an 18-file hand-enumerated sweep with friction
  write-ups for what the sweep missed.
- *Leverage:* every tool gets correct paths for free; `family.json`'s interface finally matches
  its implementation's promise.
- *Tests:* discovery becomes testable through one interface (`allPackages()` against a fixture
  tree); the literal-gate turns "did we miss a path?" from an audit question into a failing check;
  `tasks.mjs` gains an assertion that the graph is non-empty (fail-on-absence).

**Blast radius (cost).** ~20 tools files touched mechanically; both `.sh` harnesses need a shim;
one new gate item. No package source is touched; no generated output changes. Risk concentrates
in `gate-all.mjs` edits — mitigated by running the full gate before/after (it is its own
verification).

**Migration mechanics.** Write `family.mjs` + its `.test.mjs` first (red/green on a fixture
tree); migrate one consumer (`lib/regen.mjs`) and run `gate-all`; then sweep the rest in one
commit; land the literal-gate last so it certifies the sweep found everything.

**Verification.** `node tools/gate-all.mjs` green (or red only on the known mirror-drift item);
`node tools/tasks.mjs` lists 13 JS packages + all elm.jsons; new `check-layout-literals` and
`family.mjs` tests green; CI workflow passes the `working-directory`-exists assertion; a negative
test: temporarily rename a `srcDir` in a scratch copy and confirm loud failure.

---

## Candidate 2 — Ship the gate-all step pool: per-step timing + tag-scheduled parallel dispatch

**Strength: Strong** · Layer: tooling · This is Jack's explicitly recorded pain
("gate-all.mjs instrumented + parallelized; 15–20 min unacceptable" — memory
`feedback_gate_all_perf.md`).

**Files:** `tools/gate-all.mjs` (+ a new `tools/lib/step-pool.mjs`), guided by the already-written
spec `docs/superpowers/specs/2026-08-18-gate-all-parallelization-design.md` and its 1301-line TDD
implementation plan `docs/superpowers/plans/2026-08-18-gate-all-parallelization-plan.md`.

**Problem.** `gate-all.mjs` is entirely serial: `runItem()` is blocking `spawnSync`
(`tools/gate-all.mjs:114-116`), `main()` is two `for` loops plus ~20 sequential `runItem()` calls
(`gate-all.mjs:314-464`). Measured: **361.5s warm**, with `elm-m3e: test:browser` = 231.9s (64%)
and everything else ≈130s of embarrassingly-parallel work
(spec §1). There is **zero timing instrumentation** — `record()` (`gate-all.mjs:104-111`) stores
name/status/detail only; every number we have came from one manual measurement session, so the
next regression will be invisible until someone re-measures by hand. The fix is fully designed
and planned (spec status: DRAFT awaiting Jack's async review, five open questions in §7; commit
`7c5eb405` is docs-only — "tools/gate-all.mjs itself is untouched"). Nothing is implemented:
zero occurrences of `exclusiveWith`/`spawn(`/pool machinery in the current file (verified).

The deeper architectural point (the spec's §2, confirmed by the tools exploration): the four
mutual-exclusion hazards (tracked `docs/dist` written by `test:browser`; port 1239 singleton —
already patched around once by deriving a per-worktree port, commit `97039aeb`; shared
`ELM_HOME` written by `stage-facts-elm-home.mjs`; shared `.gate-out/probe.js`) exist because
**there is no seam between "declare a step" and "execute a step"** — steps are inline calls, so
their resource claims live nowhere. The step-descriptor model *is* that seam, and it doubles as
the single gate registry candidate 1's resolver plugs into.

**Solution.** Execute the existing plan, with two review adjustments:

1. **Instrument first** (new Tier 0, ~20 lines): add `startedAt/durationMs` to every `record()`
   call and print a duration-sorted summary + total. This lands tonight, independent of every
   open question, and turns future regressions into a visible diff. It also re-validates the
   361.5s/231.9s numbers on current HEAD before any scheduling change.
2. **Tier 1** per the plan: run the elephant (`test:browser`, tags `docs-dist`+`port-1239`)
   concurrently with the pool of everything else; `docs-dist`-tagged drift/fidelity steps queue
   behind it. Target ≤250s (spec acceptance §6.1).
3. Adopt the spec's own §7 correction: per-step `ELM_HOME` isolation is needed from Tier 1's
   first real concurrency (multiple packages' Elm-toolchain steps run in the pool), not Tier 3.
4. Move `CHRONIC_SKIPS` (`gate-all.mjs:73-82`) and `KNOWN_BROKEN_TOOL_TESTS` (`gate-all.mjs:102`)
   out of inline JS into data (`family.json` or a `tools/gate-skips.json`) as part of the
   step-descriptor refactor — the current shape is config-baked-into-code, the exact anti-pattern
   `family.json` was invented to kill, recurring inside the drift-discipline tool itself.
   (Overlaps candidate 4's skip contract.)
5. Note for sequencing: candidate 3 (untrack dist) **dissolves constraint #1 entirely** — if dist
   stops being tracked, `test:browser` mutating it stops being a drift hazard. Tier 1 does not
   need to wait for it (the tag handles it), but the scheduler gets simpler if 3 lands first.

**Benefits.**
- *Leverage:* one scheduler pays back on every push and every CI run forever; the step registry
  is also where a second brand's gates fan in (candidate 5) without new hardcoded `runItem`s.
- *Locality:* a step's resource claims (`exclusiveWith`, env) live on the step, not in the head of
  whoever last read the spec; failure attribution stays per-step via buffered output.
- *Tests:* the plan is TDD (scheduler unit tests: tag exclusion, pool width, buffered
  attribution); the no-silent-skip acceptance criterion (spec §4) is checked by comparing step
  membership before/after — gate-all itself finally gains tests (see candidate 4's coverage
  finding).

**Blast radius (cost).** One critical file rewritten around a new lib module; every developer's
push path changes behavior (timing, output ordering). Concurrency bugs here would be
trust-destroying — mitigated by the spec's constraint tags, the stress tests it demands
(§6.5), and landing Tier 0 (timing) + Tier 1 only, deferring Tiers 2–4. The spec's five §7
questions are flagged for Jack async; none block Tier 0/Tier 1 with adjustment (3) applied.

**Verification.** Acceptance criteria are already written (spec §6): wall-clock ≤250s warm
(re-measured the same way); step membership identical; `check-gates` still green; forced-conflict
stress test shows serialization; `ELM_HOME` isolation diff test. Tier 0's verification: summary
prints per-step durations totaling the wall time.

---

## Candidate 3 — Untrack the built docs site: pick the deploy adapter, delete the committed-artifact family

**Strength: Strong** (structure is Strong; the deploy-option pick is a one-question decision for
Jack) · Layer: structure/process.

**Files:** `brands/m3e/outputs/elm-m3e/docs/dist/` (377 tracked files, verified via
`git ls-files`), `brands/m3e/outputs/elm-m3e/docs/netlify.toml`,
`docs/vendor/tailwind-m3e-web/` + `docs/vendor/elm-foundation/` (46 tracked vendor files),
`tools/hooks/pre-push-elm-m3e-extra.sh`, `hooks/pre-push.d/` (extension point, currently empty),
`tools/family.json` (elm-m3e `sourceFilterExcludePrefixes`), `.gitignore`.

**Problem.** The docs site's **build output is a committed artifact with no freshness gate**, and
a small ecosystem of committed copies exists to keep it buildable outside the workspace:

- `netlify.toml` serves the committed tree with no build: `publish = "dist/"`,
  `command = "true"`, and its comments state the model outright — "Netlify now serves the
  committed prebuilt dist/… The pre-push hook builds + commits it locally before every push"
  (`brands/m3e/outputs/elm-m3e/docs/netlify.toml:20-24`).
- But that pre-push hook **does not run here**: it's the standalone-mirror hook
  (`tools/hooks/pre-push-elm-m3e-extra.sh:42-59`, generated by `gen-hooks.mjs` for the mirror
  repo), inert inside the monorepo because `core.hooksPath` points at the root hook; the
  workspace-side port was **deliberately deferred** pending a scoping decision
  (`hooks/pre-push.d/README.md:16-42` — "Deferred, not ported"). So in-workspace dist freshness
  is a *manual discipline*.
- The failure mode already shipped: `4b529858` "rebuild dist/ to fix **stale asset-hash mismatch
  breaking live site CSS**" — a stale committed dist served broken styles in production.
- No gate compares committed dist against a fresh build — deliberately, because it is not
  cold-reproducible: `family.json:15` excludes `docs/dist/`+`docs/vendor/` from copy-fidelity
  ("BUILT output… the workspace rebuilds with different hashes", D-041), and the enforcement
  plan's D2 notes a cold `pnpm gen`/`test:browser` run regenerates dist "with DIFFERENT content
  than what's currently committed… No existing gate compares committed docs/dist against a fresh
  build" (`docs/plans/2026-08-19-durable-m3e-convention-enforcement.md:354-365`).
- The tracked tree churns on every local test run: `test:browser` writes into tracked
  `docs/dist/` (parallelization spec §2.1, "~280 modified/deleted tracked files"), which is (a)
  the source of the permanent `git status` noise, (b) gate-all's mutual-exclusion constraint #1,
  and (c) a standing invitation to commit build bytes into feature diffs (this session's own
  starting `git status` shows exactly that: dozens of modified `docs/dist/**` files).
- Why it exists (the real constraint, from `docs/scripts/vendor-tailwind-m3e-web.mjs:5-17` and
  netlify.toml's comments): the deploy source is the **standalone `jackhp95/elm-m3e` mirror**,
  which has **no workspace siblings and no published packages** to resolve
  (`elm-review-cem`/`tailwind-m3e-web`/HtmlIr/TypedHtml are all unpublished — Phase 5 is
  deliberately held on O-1). Committed dist + vendored CSS + vendored Elm source are all
  adaptations to "deploy from a repo that can't build".

Apply the deletion test to the committed dist: deleting it doesn't concentrate complexity — it
*removes* a copy whose only consumer is Netlify's static server, provided some builder exists
where the graph is resolvable. The workspace **is** that place.

**Solution.** Move the deploy seam to where the dependency graph resolves, then untrack the
artifact:

- **Option A (recommended): deploy from the workspace.** Point the Netlify site (or a
  `netlify deploy --prod --dir` step) at this repo: root CI (or a deploy-scoped workflow) runs
  `build:ci` after gate-all green on `main` and publishes `dist/`. `docs/dist/` becomes
  gitignored everywhere; the mirror keeps serving until cutover, then its dist is dropped on the
  next `publish-mirror` run. The vendored CSS (`docs/vendor/tailwind-m3e-web/`) and vendored Elm
  foundation stay *only if* the mirror must remain independently buildable for consumers — that
  question detaches from deploys entirely.
- **Option B: keep mirror-deploy, build on Netlify.** `command = "pnpm run build:ci"` in the
  mirror. netlify.toml's own comments say `build:ci` was designed for exactly this (regenerates
  only gitignored `reference.json`, skips the rule-driven harness whose rules live in the absent
  sibling). History moved *away* from this once — the reason (build minutes? Elm-on-Netlify
  flakiness?) isn't recorded; if B is picked, record it this time.
- **Either way:** wire a freshness gate that candidate 2's runner can afford — with dist
  untracked, `check-data-drift`'s cold-reproducibility caveat stops applying to dist bytes and
  reduces to the (already-gated) generated inputs.
- Retire the deferred `pre-push.d` dist auto-commit design question (`hooks/pre-push.d/README.md`)
  as moot; delete `docs/scripts/fix`-adjacent churn from `family.json`'s exclusion list.

**Benefits.**
- *Locality:* "is the live site current?" becomes a property of the deploy pipeline, not of
  whether a human remembered to rebuild+commit 377 files; the `4b529858` failure class becomes
  structurally impossible rather than patrolled-by-nobody.
- *Leverage:* gate-all's constraint #1 dissolves (simplifies candidate 2); `git status` noise and
  accidental dist-in-diff commits end; the mirror publish shrinks by ~423 build/vendor files.
- *Tests:* the deploy build runs `build:ci` in CI where its inputs are gated — the site is built
  from a tree that just passed gate-all, i.e. the interface between "green tree" and "live site"
  becomes the pipeline itself.

**Blast radius (cost).** External-facing: the Netlify site's source/config changes (needs Jack's
account access and his A/B pick — this is the one genuinely Jack-gated step). The mirror's
observable content changes (dist removed) — mirror README should say where deploys come from.
`family.json` exclusions, `.gitignore`, and the enforcement plan's D2 notes need touch-ups.
No package source changes.

**Verification.** After cutover: live site serves a build whose hash matches CI's artifact;
`git ls-files brands/m3e/outputs/elm-m3e/docs/dist | wc -l` = 0; `test:browser` no longer dirties
tracked files (run it; `git status --short` empty); gate-all green with the `docs-dist` tag
removed from the scheduler.

---

## Candidate 4 — Gate trust: fix the drift-core test seam, make skip semantics a contract, test the high-blast tools

**Strength: Strong** · Layer: tooling.

**Files:** `tools/lib/check-drift-core.mjs`, `tools/check-drift.test.mjs`, `tools/gate-all.mjs`
(`CHRONIC_SKIPS`/`KNOWN_BROKEN_TOOL_TESTS`), `tools/fetch-snapshots.mjs`, `tools/snapshot-refs.json`,
`tools/copy-fidelity.mjs` + `tools/lib/snapshot-gate.sh`, new tests for `tools/bump.mjs` and
`tools/copy-fidelity.mjs`, `.github/workflows/ci.yml`.

**Problem.** The machinery that proves everything else honest is itself the least-verified layer:

1. **The drift engine's own negative tests are switched off by name.**
   `KNOWN_BROKEN_TOOL_TESTS` (`tools/gate-all.mjs:84-102`) excludes `tools/check-drift.test.mjs`
   because `checkConsumerBundleDrift` grew an `isGitTracked(committedPath)` precondition
   (`tools/lib/check-drift-core.mjs:230-231`, added in `1af8919e`) that rejects the test's
   scratch-copy `committedPath` before the comparison under test ever runs. This is a textbook
   "interface is the test surface" violation: the interface conflates *"verify this path is
   tracked"* (a policy about the real tree) with *"compare this content"* (the behavior the test
   needs to exercise). The result: the gate that polices every committed bundle copy currently has
   **no running proof that it bites**.
2. **The strongest correctness gates are chronically off.** All A/B byte-identity harnesses and
   `copy-fidelity elm-m3e` are in `CHRONIC_SKIPS` (`gate-all.mjs:73-82`) because
   `.cache/snapshots/*` is only materialized by `fetch-snapshots.mjs`, "which nothing calls
   automatically". So the family's byte-identity proofs run only when a human remembers.
   Meanwhile the baseline log shows **5 UNEXPECTED skips** in a fresh worktree (elm-m3e
   check/test + 3 copy-fidelity gates) — "unexpected" is machine-relative, so the summary's
   trust signal degrades exactly where it's most needed (fresh clones, agent worktrees — friction
   F-02's false-green mechanism). `material-okf` has **no snapshot/sync wiring at all yet**
   (deferred with a `$TODO` in `family.json:118` pending a real repo coordinate).
3. **Skip policy is duplicated across languages:** `tools/lib/snapshot-gate.sh` (bash) and
   `copy-fidelity.mjs`'s inline `requireSourceOrSkip()` (`copy-fidelity.mjs:59-71`) implement the
   same SKIP-vs-`REQUIRE_SNAPSHOT_GATES` policy twice with near-identical wording; a policy change
   propagates to one and not the other.
4. **Test coverage is inversely correlated with blast radius.** Zero tests for: `gate-all.mjs`
   (466 lines, gates every push), `bump.mjs` (401 lines — its rollback path shipped bugs twice,
   `eae35627` and `529449cf`, with nothing pinning either fix), `copy-fidelity.mjs` (the generic
   fidelity engine), `check-mirror-drift.mjs`, `check-single-cem-facts.mjs`, and 12 more —
   while low-stakes pure helpers (`gen-figma-config`, `okf-lib`) are well-tested.

**Solution.**
1. **Split the drift-core interface at its natural seam:** `checkConsumerBundleDrift({files})`
   compares content; a separate, explicitly named `assertTracked(paths)` (or an injectable
   `isTracked` dependency, defaulting to git) enforces the policy. The test injects a stub /
   calls the comparison directly; `check-drift.mjs` composes both. Delete the
   `KNOWN_BROKEN_TOOL_TESTS` entry — that set should be empty and its emptiness asserted.
2. **Make skip semantics a data contract:** move `CHRONIC_SKIPS` to data (per candidate 2's step
   registry); give every skippable step a declared provisioning requirement
   (`requires: ["snapshot:elm-m3e"]`) so the summary can say *"skipped: unprovisioned (expected
   here)"* vs *"skipped: should have run"* deterministically per environment. In CI, generalize
   D2's precedent: `REQUIRE_CLONE_GATES=1` already exists; add the snapshot lane —
   `fetch-snapshots.mjs` runs in a scheduled/CI job (network is acceptable there) so the A/B and
   copy-fidelity gates run for real somewhere on every mainline change, not never.
3. **Unify the skip policy implementation** (one JS implementation; the bash harnesses either
   call a `node -e` one-liner or get their skip decision passed in by the runner).
4. **Add the two highest-value test suites:** `bump.mjs` rollback (fault-inject after re-pin;
   assert byte-restoration — the D-022 idempotence property, "snapshot, run, compare") and
   `copy-fidelity.mjs` (green/red/allowlisted fixtures). Both are pure-logic-plus-git and
   testable with the same bare-repo plumbing `publish-mirror.test.mjs` already demonstrates.

**Benefits.** *Locality:* gate trust stops depending on tribal knowledge of which greens are
real. *Leverage:* one skip contract serves every current and future gate; the drift engine's
proof-it-bites runs again on every push. *Tests:* the two riskiest tools gain regression pins;
the "known broken" list trends to empty and is asserted empty.

**Blast radius (cost).** `check-drift-core.mjs` interface change touches its 3 callers
(`check-drift.mjs`, tests, `gate-all`'s E2E wiring); CI gains a snapshot-fetch step (network
dependency in CI only — the local gate's reliability profile is unchanged, honoring the
CHRONIC_SKIPS comment's own reasoning at `gate-all.mjs:64-72`).

**Verification.** `node --test tools/check-drift.test.mjs` green with the red-case actually
executing (prove by mutating a scratch copy); gate summary in CI shows the A/B + copy-fidelity
gates as PASS (not SKIP) on a scheduled run; `KNOWN_BROKEN_TOOL_TESTS` deleted and a check
asserts no such mechanism exists; new bump/copy-fidelity tests red→green on injected faults.

---

## Candidate 5 — Brand #2 end-to-end: the reorg's acceptance test, plus de-branding the tools layer

**Strength: Strong** (it is the recorded acceptance test of today's reorg; scope is a
mini-project, not a mechanical fix) · Layer: architecture/identity.

**Files:** new `brands/<second>/` (inputs: CEM + config; outputs: generated Elm package),
`core/elm-cem/family-configs/<second>.json`, `tools/family.json`, `tools/gate-all.mjs` (via
candidate 2's step registry), the `ELM_M3E`-constant call sites listed under candidate 1,
`tools/check-single-m3e-web-pin.mjs`, `tools/check-m3e-5pkg.mjs`, `tools/measure-docs-size.mjs`.

**Problem.** The workspace's identity claim — "nothing here is m3e-specific by design: new brands
and new outputs plug in" (VISION.md:22-23) — is still **asserted, not demonstrated**:

- The reorg design doc names the proof as its own acceptance test: "Standing up a second brand
  (Carbon) through the new layout is deferred to a follow-up phase, which will use this reorg as
  its starting point **and its acceptance test**"
  (`docs/superpowers/specs/2026-08-18-core-brands-workspace-reorg-design.md:22-24,132-134`).
- elm-cem's own docs concede the gap: "`bin`/`codegen` still don't read a component-manifest
  config for any brand but M3E… proving brand-pluggability end-to-end… is flagged in the audit as
  its own future wave" (`core/elm-cem/cem-configs/README.md`); `family-configs/` has exactly one
  entry (`m3e.json`). Analyzer configs for carbon/ionic/spectrum/material-web sit unused in
  `cem-configs/`.
- The thermonuclear audit ranked this move #2 and predicted it "flushes 2.1–2.3 as hard failures
  instead of latent ones"; W3 fixed the *known* leaks mechanically, but the audit's point stands:
  grep-based neutrality gates catch string mentions, not data-shape hardcoding — the
  eject/family-deps hardcoding was exactly that class and grep never saw it
  (`docs/reviews/2026-08-17-thermonuclear-workspace-review.md`, Theme 2).
- Today's reorg moved the *trees* into brand-shape, but the *tools layer is still single-brand in
  structure*: `ELM_M3E` is a singular constant in 8+ scripts, and brand-specific gates are
  hardcoded workspace `runItem`s by name (`check-single-m3e-web-pin`, `check-m3e-5pkg`,
  `measure-docs-size` targeting `elm-m3e-icons` — `gate-all.mjs:339,383-388`). A second brand
  today would need to fork tools, which is the vendored-copy failure mode reborn at the tooling
  layer.

**Solution.** One vertical slice, smallest honest scope:
1. Pick the brand with the best CEM hygiene (Carbon or Spectrum — configs already exist; note
   `spectrum.config.mjs` got its `exclude` block in W6). Stand up
   `brands/<b>/inputs/cem/` (pinned manifest + minimal config) and
   `brands/<b>/outputs/elm-<b>/` (generated package only — **no docs app, no okf, no tailwind**
   for the slice).
2. Generation + gates: `elm-cem` run in CI against the second CEM; `registry-check`; acid probes
   for one representative component; regen-drift. That is the entire slice — enough to flush
   icon-module/config assumptions as hard failures.
3. Mechanically de-brand the tools layer as the slice demands it (this is where candidates 1+2
   pay out): `ELM_M3E` constants become `pkgDir(brand.outputs.elm)` lookups; per-brand checks
   (`single-<lib>-pin`, package-shape, docs-size) become **data-declared gate steps** under
   `brands/<name>/` fanned in by the step registry — generic runners in `tools/`, brand opinions
   in brand data. (`check-m3e-5pkg` is 19 lines reading one JSON — the generic runner is nearly
   free.)
4. Update VISION.md's claim from asserted to demonstrated, or scope it honestly if the slice
   surfaces a wall.

**Benefits.** *Leverage:* every future brand (the stated product) inherits a proven path;
`elm-cem`'s genericity stops being "verified by grep" and becomes "verified by CI". *Locality:*
brand knowledge concentrates under `brands/<name>/`; tools stop being the hiding place for brand
opinion. *Tests:* the second brand IS the test — the one test that exercises the architecture's
central claim through its real interface (config in, package out).

**Blast radius (cost).** A mini-project (the audit's own words): new CI lane (+minutes), new
committed generated package (~like elm-m3e's src but smaller), tools refactor across the C1 file
set, and the risk that real walls surface (that's the point — better now than under a paying
second brand). Does not touch elm-m3e's outputs.

**Verification.** CI job "brand2-e2e" green: generation deterministic (A/B or double-run diff),
registry-check green, acid probes pass; `grep -rn "m3e" tools/*.mjs` reduced to data files +
allowlisted prose; the reorg design doc's acceptance line checked off.

---

## Candidate 6 — cem-figma-connect `src/tokens/*`: finish the profile quarantine (W7, sharpened)

**Strength: Strong** · Layer: code.

**Files:** `core/cem-figma-connect/src/tokens/{classify-delta,audit,derive,stamp,token-change-report,resolve-palette}.mjs`
(~3.4k lines), `core/cem-figma-connect/profiles/m3-kit/profile.json`, `tools/bump.mjs:27-28`.

**Problem.** The package's stated architecture rule — "Nothing m3e-specific in `src/`. The m3e
knowledge lives in `profiles/m3-kit/`" (`core/cem-figma-connect/plans/01-architecture.md:121`) —
is honored by `match/`/`correspond/`/`emit/`/`publish/`/`visual/` (the W3 fix moved matcher
vocabulary into `profiles/m3-kit/matcher.json`, threading `loadMatcherConfig(profileDir)` — done
properly), but **falsified by the token subsystem**, the one subtree added later that never got
the parameterization pass:

- `src/tokens/classify-delta.mjs:54` — a literal
  `import … from "../../../../brands/m3e/outputs/tailwind-m3e-web/bin/generate-component-utilities.mjs"`:
  a brand package's `bin/` imported by path from inside the generic engine. Layout coupling baked
  into an import statement (it broke depth-wise in the reorg and was hand-patched to 4×`../`).
- `src/tokens/audit.mjs:45-51` and `src/tokens/derive.mjs:80-87` — `DEFAULT_PATHS` hardcoding
  `brands/m3e/outputs/tailwind-m3e-web/src/sys/*.css` and `profiles/m3-kit/*`;
  `stamp.mjs:81-84,477` defaults `profile = "m3-kit"`; `token-change-report.mjs:34` hardcodes the
  m3-kit report path. None of the five loads profile-scoped config the way `matcher.mjs`/
  `merge.mjs` (`loadProfile`) do; the defaults are what `pnpm check:tokens`/`check:token-graph`/
  `check:token-change-report` actually run.
- The tier taxonomy (`seed→reference→system→component`) is re-derived as three parallel
  prefix-classifiers: `derive.mjs:417-424` (`tierForMd`), `classify-delta.mjs:196-212`
  (`tierOfNames`/`TIER_RANK`), plus audit.mjs's prose — none importing the others.
- The subtree reads sibling CSS as raw text with regexes (`derive.mjs:203-242`) — the one place
  the package's otherwise-excellent typed-ingest discipline (see `src/ingest/cem.mjs:80-110`) is
  skipped.
- Workspace tooling now depends on these internals across the package seam:
  `tools/bump.mjs:27-28` imports `classify-delta.mjs` and `token-change-report.mjs` directly from
  `src/tokens/` — engine internals as a cross-package API with no declared interface.
- The 2026-08-17 review already ordered this extraction (W7: "src/tokens/* … a
  `@m3e/web` ⋈ `tailwind-m3e-web` token-diff tool with a literal cross-package source import …
  absent from the package's own architecture diagram, never touched by its CLI"); it was HELD,
  not rejected. Plus live defect L3 (stale `vendoredFrom` provenance in `resolve-palette.mjs:257`).

**Solution.** Two moves, either or both:
1. **Parameterize (minimum):** give the token subsystem the same profile seam the matcher got in
   W3 — a `tokens` block in `profile.json` (css sources, tokens paths, report path), loaded via
   `loadProfile`; delete every `DEFAULT_PATHS` brand literal; collapse the three tier classifiers
   into one exported `tierOf` in a shared module. Fix L3's provenance string from the same config.
2. **Extract (the W7 shape):** the token bridge is a `tailwind-m3e-web ⋈ Figma-variables`
   diff/audit tool — move it to its own package (or into `brands/m3e/` tooling) with a declared
   interface; `bump.mjs` imports the package entry, not `src/tokens/…` file paths. The seam is
   already real by the two-adapter test: two distinct consumers exist today (the cfc `check:*`
   scripts and `bump.mjs`).

**Benefits.** *Locality:* the last "m3e in src/" cluster disappears; a second kit's token bridge
is a profile block, not a fork. *Leverage:* one tier classifier, one loader; bump's report
machinery gets a stable interface. *Tests:* the subsystem becomes testable against fixture
profiles like the matcher already is (toy/b4/evil profile pattern), instead of only against the
live m3-kit tree.

**Blast radius (cost).** ~6 files + profile schema + `bump.mjs` imports + the `check:token*`
scripts; the committed fixture regenerates once (provenance string corrected). No generated
Code-Connect output changes (tokens are outside the emit path).

**Verification.** `pnpm --filter cem-figma-connect run check` + `test` green; a grep gate:
`grep -rn "m3-kit\|brands/" core/cem-figma-connect/src/` returns only the documented default-profile
CLI plumbing (or nothing, post-extraction); `node tools/bump.mjs --help`-level smoke passes with
the new imports; L3's fixture regenerated with correct provenance.

---

## Candidate 7 — One prop-shape resolver behind the correspondence schema

**Strength: Worth exploring** (design-bearing; high payoff, real risk) · Layer: code.

**Files:** `core/cem-figma-connect/src/correspond/merge.mjs:109-146` (buildAxes/buildProps — the
taxonomy's one definition), `src/visual/drive.mjs:360-553`, `src/emit/html-label.mjs:520-681`,
`profiles/m3-kit/emitters/elm.mjs:569-891`, `src/correspond/schema.json`.

**Problem.** The axis/prop *shape* taxonomy (the ~6 kinds: text→content, text→slot, boolean→slot,
instanceSwap→slot default/named/visibility-gated, literalIcon→slot, multi-boolean axis) is
defined once in the correspondence model but **re-derived as three parallel case-switches** with
similar-but-not-identical logic and error prose, in the state-driver (`drive.mjs`), the
web-component emitter (`html-label.mjs`) and the Elm emitter (`elm.mjs`). Understanding "what
does a boolean-gated icon slot do" means reading the same decision three times; a new prop shape
means three synchronized edits (the 2026-08-17 review flagged the `emitEntry` shape-dispatch as
its stretch item and it was deliberately deferred as "real but riskier"). A second overload
compounds it: `figmaSets[].fixedAttrs` means *CEM fixed attribute* or *Figma axis pin* depending
on caller, and both `drive.mjs:282-294` and `html-label.mjs:743-747` carry a `figmaAxisNames`
exclusion set to tell the meanings apart at the point of use instead of the schema separating
them.

**Solution.** Introduce one deep module — `src/correspond/prop-shape.mjs` — owning shape
*classification* (`shapeOf(prop, entry) -> tagged union`) and the per-shape data each consumer
needs; drive/html-label/elm become adapters that switch on the returned tag (their rendering
stays theirs — the seam is classification, not rendering, so this passes the two-adapter test
with three real adapters on day one). Split `fixedAttrs` into two schema fields
(`fixedAttrs` vs `figmaAxisPins`) with a migration script over `correspondence.json` +
`manual-correspondence.json`.

**Benefits.** *Depth:* the shape taxonomy becomes one interface with three adapters instead of
three implementations. *Locality:* a new Figma prop pattern lands in one classifier + N small
renderers. *Tests:* classification gains direct unit tests (today it's only exercised through
each consumer's full path); emit determinism + the 757-test suite + `check-emit-determinism-cfc`
pin the refactor byte-identically.

**Blast radius (cost).** Three of the package's largest files change shape; the schema migration
touches the human-owned correspondence files (must preserve every human judgment byte —
mitigated by the merge machinery's own human-preserving discipline and a regen-diff proving
`generated/**` unchanged). This is the candidate where "prove a generator change is a no-op by
A/B" (VISION principles) is the whole verification story.

**Verification.** `gen:emit` byte-identical pre/post (the determinism check run on both);
`pnpm --filter cem-figma-connect run gate` green; new prop-shape unit tests; schema version bump
with `check` validating both fields.

---

## Candidate 8 — elm-cem internal locality: adopt `bin/shared.js`, curate `Emit/*` interfaces, own the bundle schema

**Strength: Worth exploring** · Layer: code.

**Files:** `core/elm-cem/bin/{shared,elm-cem,regen-drift,registry-check}.js`,
`core/elm-cem/tests/{phantom/suites.mjs,gates.test.mjs,enum-override.test.mjs,from-string.test.mjs,registry-check-nested-pkg.test.mjs}`,
`core/elm-cem/codegen/Generate/Phantom/Emit/*.elm` (17 modules), `docs/facts-bundle/schema.json`,
`core/elm-cem/CONTRIBUTING.md` (L5).

**Problem.** Three locality gaps inside the engine, all cheap to close:
1. **The shared resolver exists and never got adopted.** `bin/shared.js:1-8` declares itself the
   single home for binary/sibling-source resolution ("the whole point of issue #50"), yet only 2
   of 16 bin scripts use it; `bin/elm-cem.js:205-221`, `bin/regen-drift.js:94-110`, and
   `bin/registry-check.js:112-150` each re-implement the same walk (one comment even claims
   "kept identical" — true in effect, false in mechanism). Five test files hand-copy
   `irSrc = path.resolve(repo, "..", "elm-html-intermediate-representation", "src")` with **no
   env fallback**, making the test suite strictly less robust than the production resolver for
   the identical problem (`tests/phantom/suites.mjs:16` + 4 more).
2. **The W2 Emit split is a flat namespace, not 17 modules.** All 17 `Emit/*.elm` files use
   `exposing (..)` and share a byte-identical 13-line import preamble; cross-imports are also
   unrestricted (`Emit/Component.elm:14-15`). The split bought file-size/diff locality (real!)
   but no compiler-enforced boundaries — understanding one emission concept still requires
   knowing that `AttrsRow` + `Shared` + `Model.Brand` are one unit spread over three files. The
   repo's own history shows the pattern (grow one file → partition along comment banners) has
   happened twice; the next emission concern has no designed seam to land in.
3. **The producer's contract lives outside the producer.** `docs/facts-bundle/schema.json` — the
   schema for the bundle elm-cem itself emits — lives at the *workspace* root, reached from
   elm-cem's tests by `path.resolve(repo, "..", "..")`
   (`tests/facts-bundle-schema.test.mjs:12-16`). Package extraction (a scenario the neutrality
   gate explicitly anticipates) would strand the producer without its own format contract.

**Solution.** (1) Route the four resolver copies + five test constants through `bin/shared.js`
(tests import it directly — it's plain Node). (2) Narrow every `Emit/*.elm` exposing list to what
siblings actually use (mechanical: compiler-driven), designate `Emit.Shared`+`Emit.AttrsRow` as
the only intended cross-imports, and record the rule in the module docs — cheap now, and it
makes the *next* emitter land behind an interface. (3) `git mv` the schema (+ coverage map) into
`core/elm-cem/docs/facts-bundle/`, leave a workspace-level pointer, update the 3 reader paths
(`gate-all.mjs:243` area, `check-drift.mjs:90`, the test). Fix CONTRIBUTING (L5) in the same
pass.

**Benefits.** *Locality:* toolchain-resolution changes become one-file edits; the schema moves
with its producer. *Leverage:* `shared.js` finally pays back its extraction. *Tests:* the five
fragile test constants gain the production resolver's env overrides; narrowed exposings let the
Elm compiler enforce what the split only implied.

**Blast radius (cost).** Wide-but-shallow: ~10 JS files, 17 Elm exposing lines, 3 schema-path
readers. Regen output must be byte-identical (A/B proves it — exposing changes don't affect
emission).

**Verification.** `npm run gate` in elm-cem (0 failures); A/B harness byte-identical; `elm make`
across the workspace green (exposing narrowing is compile-checked); schema test passes from its
new path; gate-all green.

---

## Candidate 9 — W4 carried forward: elm-review-cem internal seams

**Strength: Worth exploring** (already-recognized debt; unblocked since W3 merged) · Layer: code.

**Files:** `core/elm-review-cem/src/Cem/*.elm` (25+ rule modules; existing internals at
`src/Cem/Internal/{Facts,ListExtra,Lookup,Translate}.elm`).

**Problem.** The 2026-08-17 review's W4 was held only for file-lock reasons and never started
(`docs/plans/2026-08-18-session-handoff.md:56-60`): the let-scope collector is still copied ~10×
(self-flagged TODO at `Cem/ValidSlotKind.elm:105-108` — still present, 3 occurrences in that file
alone), `isAllowed` ×5, the accessible-name rule pair ~85% identical, and the
`PreferBarrel`/`PreferComponentModules` inverse tables remain the documented-past-bug source.
These are pure-locality losses: a fix to the collector must be found and re-applied in ten rules.

**Solution.** As specified in the original review: hoist `Cem.Internal.Visitor` (collector),
`Cem.Internal.AccessibleName`, `Cem.Internal.Gate` (`isAllowed`), `Cem.Internal.BarrelMapping`
(single inverse-table source). Internal modules — no published-interface change (they stay out of
`exposed-modules`; internal seams used by the package's own tests are exactly what the
deep-module model allows).

**Benefits.** *Locality:* one collector, one gate predicate, one barrel map. *Tests:* the
package's exemplary four-test-class discipline now pins shared internals once instead of 10×;
add the facts-index meta-test here (W8's second half) so "must use `Facts.buildIndex`" stops
being convention-only.

**Blast radius (cost).** ~25 rule modules mechanically re-pointed; 418+ tests re-run; neutrality
allowlist entries for any doc examples. No consumer-facing interface change.

**Verification.** `pnpm --filter elm-review-cem run gate` (418 tests + neutrality + format +
review) green; a duplication grep (collector body) returns 1 hit.

---

## Candidate 10 — `elm-cem-facts` to `core/elm-cem-facts` (W7, first half)

**Strength: Worth exploring** · Layer: structure.

**Files:** `core/elm-cem/facts/` → `core/elm-cem-facts/`; `tools/family.json` (`elm-cem-facts.srcDir`,
currently `core/elm-cem/facts` at `family.json` elm-cem-facts entry); `core/elm-cem/bin/shared.js`
resolveFactsSrc candidates; `measure-docs-size.mjs:78`; consumer `source-directories`
(`core/elm-typed-html/verify/elm.json`, elm-m3e docs/samples review elm.jsons, elm-review-cem
test elm.jsons — the R-007/D-011 family).

**Problem.** Two publish targets share one directory tree: `jackhp95/elm-cem-facts` is an
independently-versioned, independently-mirrored Elm package physically nested inside
`core/elm-cem/facts/` — "already an independent unit everywhere except physical location"
(2026-08-17 review, Theme 6 verdict). Post-reorg it is the only family package whose `srcDir` is
a subdirectory of another package, which keeps `registry-check`'s staging, copy-fidelity, and
mirror publishing on special-cased paths.

**Solution.** `git mv core/elm-cem/facts core/elm-cem-facts`; update `family.json`, the
resolver-candidate lists in `bin/shared.js`/`bin/registry-check.js` (candidate 8 makes this one
place), the ~6 `source-directories` entries, and the mirror mapping. Registry-faithfulness is
untouched (the package elm.json doesn't change at all — constraint honored).

**Benefits.** *Locality:* one package = one directory = one mirror mapping; the D-011 class of
blast-radius miss (an app's `source-directories` not gaining the facts path) gets simpler to
audit because the path is uniform. *Leverage:* candidate 1's `pkgDir("elm-cem-facts")` stops
having an asterisk.

**Blast radius (cost).** ~10 path references + mirror publish of a tree-shape change; ledger
R-001/D-006 machinery (registry-check staging candidates) must be re-verified — the recorded
reason the current nesting worked "with ZERO path edits" (D-006) becomes one deliberate edit.

**Verification.** gate-all green, `registry-check` green for facts + every consumer,
`check-single-cem-facts` green (its reachability analysis is layout-independent), copy-fidelity
for elm-cem unaffected (facts paths leave its tree).

---

## Candidate 11 — Finish Phase 1: migrate `to-elm.mjs` onto `elm-shape` and flip the PENDING flag

**Strength: Worth exploring** · Layer: code.

**Files:** `brands/m3e/outputs/elm-m3e/docs/scripts/examples-gen/lib/to-elm.mjs` (imports
elm-shape already at line 52 for part of its work — verified by the reorg plan's depth-fix table
— but is still `migrated: false`), `tools/check-elm-shape-drift.mjs:143` (the PENDING entry).

**Problem.** VISION Phase 1 ("one canonical html↔elm engine") is "largely realized"; the drift
gate (`check-elm-shape-drift.mjs`) enforces the canonical engine for one consumer
(`profiles/m3-kit/emitters/elm.mjs`, `migrated: true` at line 134) and explicitly documents the
docs examples generator as **PENDING (L5)** (`migrated: false`, line 143) — the last private
re-implementation of the shape grammar the engine was built to kill. The session handoff notes
Phase 1's "original de-duplication to confirm… was never done"
(`docs/plans/2026-08-18-session-handoff.md:124-126`).

**Solution.** Complete L5 as designed: route `to-elm.mjs`'s remaining shape decisions through
`elm-cem/elm-shape` imports, flip `migrated: true`, and let the gate's re-inlining regexes
enforce it from then on.

**Benefits.** *Leverage:* one grammar, two consumers, gate-enforced (the seam graduates from
1-adapter-plus-a-promise to two real adapters). *Locality:* a grammar change is one edit +
regen. *Tests:* the examples-gen output is regen-drift-gated, so the migration is provable as a
byte-no-op or an enumerated improvement.

**Blast radius (cost).** One generator script + regenerated example artifacts if output shifts;
the docs examples pipeline's "not cold-reproducible" caveat means verify in a provisioned env.

**Verification.** `check-elm-shape-drift` green with both consumers `migrated: true`; elm-m3e
docs `check:drift` green; examples regen byte-diff reviewed.

---

## Candidate 12 — Repackage the docs app out of the `elm-m3e` package directory

**Strength: Speculative** (real forces, but it re-shapes a published mirror and depends on
candidate 3's outcome) · Layer: structure.

**Files:** `brands/m3e/outputs/elm-m3e/docs/` (the `m3e-builder-docs` pnpm package — an
application with its own vite/elm-pages/Playwright stack, vendor trees, port hack
`97039aeb`, and 64% of the whole gate's wall time).

**Problem.** An application lives inside a published package's directory: the mirror
`jackhp95/elm-m3e` ships a library *and* a full docs app (with its committed dist + vendor
trees), which is why the deploy constraint (candidate 3), the gate elephant (candidate 2), and
the biggest copy-fidelity allowlists (`family.json` elm-m3e block — by far the largest) all
concentrate on one package. The coexistence convention's application layer
(rule 4) is exactly where such an app belongs (`packages/_probe/elm-probe-app` is the pattern).

**Solution (if pursued).** Move the docs app to a first-class application location (e.g.
`brands/m3e/apps/docs/` — a new `apps/` bucket per brand), leaving `elm-m3e` as the pure package
set. The mirror then publishes a library; the docs app deploys per candidate 3-A.

**Why Speculative.** It changes the public mirror's shape (consumers may link into `docs/`);
the upstream standalone repo's history and Netlify wiring assume co-location; and candidate 3
removes most of the day-to-day pain without the move. Revisit after 3 lands and Phase-5
publishing decides what `jackhp95/elm-m3e` should contain.

**Verification (if pursued).** gate-all green; copy-fidelity re-baselined; mirror publish diff
reviewed by Jack (external-facing).

---

# Sequencing and top recommendation

**Do first — Candidate 1 (layout map), immediately.** It is small (a day), autonomous-safe,
fixes two live defects (CI is red-on-arrival at `ci.yml:74`; `tasks.mjs` is blind), and
structurally prevents tonight's merge-breakage class from recurring. Every other candidate's
migration story gets cheaper once paths come from one resolver.

**Then — Candidate 2 (gate step pool), the highest-leverage sustained win.** The measurement,
design, and TDD plan already exist; Tier 0 (per-step timing) + Tier 1 (elephant-vs-pool) deliver
361.5s → ≤250s on every push with bounded risk, and the step registry it introduces is the
mechanism candidates 4 and 5 plug into. The spec's §7 open questions go to Jack async; none
block Tier 0/1 with the ELM_HOME correction applied.

**Then — Candidate 3 (untrack dist)** once Jack picks deploy option A or B (one question), which
also simplifies 2's constraint set; **Candidate 6** (tokens quarantine) and **Candidate 4** (gate
trust) are parallel-safe after 1. **Candidate 5** (brand #2) is the strategic move of the next
phase — it is the acceptance test today's reorg explicitly deferred to, and candidates 1+2 are
its runway.

Rationale for the ordering: 1 is prevention for the failure class this very review tripped over
three times (L1/L2/L3); 2 is the user's loudest recorded pain with a decision record already
written; both are prerequisites that make every later structural move (3, 5, 6, 10, 12) cheaper
to execute and to verify.

---

# Appendix A — Stale-path enumeration (post-reorg `packages/<old>` references)

Old→new map (from the reorg plan): `packages/elm-cem→core/elm-cem`,
`packages/elm-cem-compose→core/elm-cem-compose`, `packages/elm-review-cem→core/elm-review-cem`,
`packages/elm-html-intermediate-representation→core/elm-html-intermediate-representation`,
`packages/elm-typed-html→core/elm-typed-html`, `packages/cem-figma-connect→core/cem-figma-connect`,
`packages/tonal-palette-oklch→core/tonal-palette-oklch`,
`packages/elm-m3e→brands/m3e/outputs/elm-m3e`,
`packages/m3e-okf→` split `brands/m3e/inputs/material-okf` + `brands/m3e/outputs/m3e-api-okf`,
`packages/tailwind-m3e-web→` fork `core/tailwind-md3` + `brands/m3e/outputs/tailwind-m3e-web`.
Only `packages/_probe` legitimately remains.

## A. LIVE-CODE STALE (breaks or misleads at runtime) — fix now (candidate 1 / L-defects)

| File:line | Stale reference | Correct value |
|---|---|---|
| `.github/workflows/ci.yml:74` | `working-directory: packages/elm-m3e/docs` | `brands/m3e/outputs/elm-m3e/docs` (verified nonexistent → CI step fails) |
| `tools/tasks.mjs:28,74` | walks `join(repoRoot, "packages")` only | walk `core/`, `brands/*/inputs|outputs/*`, `packages/_probe` (or candidate 1's `discoveryRoots()`) — currently reports `(none)` |
| `core/cem-figma-connect/src/tokens/resolve-palette.mjs:257` | writes `vendoredFrom: "packages/tailwind-m3e-web/src/…"` into committed fixture | `core/tailwind-md3/src/…` (+ the sys/color.css part still under `brands/m3e/outputs/tailwind-m3e-web`) — the same file's `VENDORED_DIR` (45-47) already knows the truth |
| `tools/family.json:97-98` | note claims package name is `m3e-docs`, "not fixed" | name is `m3e-okf` since W6 (verified); note stale, `pnpmFilterName` indirection possibly vestigial |

## B. DOC STALE (describes the old layout as current) — mechanical sweep

| File:line(s) | Stale content |
|---|---|
| `README.md:13-16,20-22,27-36,43-45,63-66` | Layout section + convention rule 1 + probe section all describe `packages/<name>/` as the family home; the layout diagram omits `core/`/`brands/` entirely |
| `VISION.md:8` | points to `packages/cem-figma-connect/plans/BRIEF.md` (now `core/…`) |
| `VISION.md:113-115` | "mirror of `packages/<name>/` here" |
| `docs/plans/2026-08-19-durable-m3e-convention-enforcement.md` (multiple, e.g. 27, 34, 47-49, 175, 179) | cites `packages/elm-m3e/review/...`, `packages/tailwind-m3e-web/generated/utilities.json`, `packages/m3e-okf` as current paths (doc is 1 day old but pre-reorg paths) — the *code* it describes was updated; the doc wasn't |
| `hooks/pre-push.d/README.md:18,32,35,37,41` | `packages/elm-m3e/hooks/pre-push`, `packages/elm-m3e/docs/dist/` as live paths in the deferred-extension design note |
| `brands/m3e/outputs/elm-m3e/plans/2026-08-12-publish-runbook.md` (13 refs) + `2026-08-12-publish-readiness.md` (2) | pre-reorg paths in the still-open publish runbook (O-3/O-6 live decisions read from here) |
| `brands/m3e/outputs/m3e-api-okf/templates/consumer-vendor/README.md` (3) | template text pointing consumers at `packages/…` |
| `brands/m3e/outputs/elm-m3e/editor/README.md`, `DESIGN-NOTES.md`, `docs/decisions.md`, `editor/stub/Cem/Facts.elm`, `docs/tests-browser/compose.spec.ts` (1 each) | stale path prose/comments |
| `brands/m3e/outputs/{tailwind-m3e-web,m3e-api-okf}/scripts/gen-facts.mjs:3,10` | header comments cite `packages/elm-cem` / `packages/elm-m3e` (code itself uses the shared runner — comments only) |
| `core/elm-cem/CONTRIBUTING.md:49,57,94,102,174` | references retired test files (`GoldenTest`, `SyntheticAttrTest.elm`) — L5 |
| `tools/snapshot-refs.json` `_comment_elm_cem` | prose mentions `packages/elm-cem` (flagged cosmetic in the reorg plan's Phase 6, still present) |
| `tools/lib/consumer-output-drift.mjs:100` | comment narrating the old `packages/tailwind-m3e-web/bin/` depth bug (historical explanation — borderline C) |

## C. HISTORICAL (legitimately describes past states — leave alone)

`GAUNTLET-LEDGER.md` (throughout), `docs/plans/2026-08-18-core-brands-workspace-reorg-plan.md`
(the enumeration IS the history), `docs/plans/2026-08-17-*` and earlier plan docs,
`docs/reviews/2026-08-17-thermonuclear-workspace-review.md`,
`docs/superpowers/specs/2026-08-13-compose-design.md` (24 refs),
`docs/superpowers/spikes/*` (30+17 refs), `docs/facts-bundle/{m6-deep-clean,m3-consumer-scorecard,m3c-generated-diff,coverage-audit}.md`,
`docs/superpowers/specs/2026-08-18-gate-all-parallelization-design.md` (7 refs — measured against
the pre-reorg tree; its path examples should be read through the old→new map when implementing,
worth a one-line erratum note when candidate 2 lands),
`docs/copy-fidelity-notes.md` (mixed: mostly updated to `brands/…`, a few historical mentions).

## D. LEGIT (not stale)

`packages/_probe/**` references (`tools/gate.mjs:26`, `tools/gate-all.mjs:172`,
`check-single-cem-facts.mjs:89`, `install-toolchains.mjs:56`, README probe section);
`docs/facts-bundle/coverage-map.json` (citations into the pre-move tree at recorded SHAs);
upstream-repo paths (`node_modules/@m3e/web/dist/custom-elements.json`).

## E. SELF-DESCRIBING / REGENERATED

Strings inside `brands/m3e/outputs/elm-m3e/docs/dist/**` (committed build output — regenerates;
also see candidate 3), `.cache/snapshots/**` (unfetched), generated `*.figma.ts` trees (URL/text
content, no repo paths found stale).

---

# Appendix B — Explicit non-recommendations (respecting the decision record)

- **Do not collapse `elm-html-intermediate-representation` into `elm-typed-html`** — the
  2026-08-17 cross-package reviewer verified a genuine two-consumer substrate (elm-m3e imports
  `HtmlIr.*` directly in 200+ files); the seam is real by the two-adapter test.
- **Do not rename `cem-figma-connect` / `tailwind-m3e-web` now** — the session handoff records
  both as open naming questions with low urgency; candidate 6 changes the substance the naming
  debate is about, so decide names after it.
- **Do not add path-based skip logic to gate-all** ("skip elm-m3e checks if the push didn't touch
  it") — the parallelization spec §4 already rules it out with reasons this review endorses
  (test:browser's inputs span the repo; silent-skip history).
- **Do not re-litigate the core/brands split, the mirror model, the enforcement hooks, or the
  Elm registry-faithfulness rule** — all are fresh, recorded decisions this review builds on.
- **⚠ One decision-record tension flagged, not re-litigated:** README.md's rule 6 says the root
  task runner (`tasks.mjs`) "is the one component that knows the whole family graph," while W5's
  `family.json` header claims the same title for itself, and `pnpm-workspace.yaml`'s globs are a
  third de-facto owner. Candidate 1 resolves the tension in family.json's favor (data over
  walker); if Jack intended `tasks.mjs` to stay the owner, candidate 1's resolver should be built
  *into* tasks.mjs instead — same work, different home. Flagged because it touches D-003's
  written convention text.

# Appendix C — Test-surface observations not tied to one candidate

- `core/cem-figma-connect/src/visual/diff.mjs:72-107` documents its pixel-diff thresholds as
  calibrated only on code-vs-code and Figma-vs-Figma pairs — never a real matched code-vs-Figma
  pair; the module itself says re-verification is needed before the visual gate is CI-trustworthy.
  Track as a small follow-up when the next kit refresh provides real pairs.
- `core/elm-cem`'s resolution/emission core (Model.resolve 3,143 lines; Emit 17 modules) is
  verified almost entirely through whole-CLI golden byte-diff + acid probes.
  `tests/src/SharedAtomVocabTest.elm` proves direct `M.resolve` unit tests are possible through
  the real interface — grow that seam's use (no new seam needed) for the next resolution bug
  instead of another golden.
- `cem-figma-connect`'s real `figma connect publish` exec (`src/publish/runner.mjs:222-224`) is
  never exercised by tests (fake execFn injected everywhere) — inherent boundary; note it in the
  publish runbook rather than pretending coverage.
- W8 remainder (`match --check` staleness gate for correspondence.json) remains open and small;
  fold into candidate 4's contract work or the next cfc pass.
