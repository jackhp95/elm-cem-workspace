# DAG rework — Task 5 (package-DAG assertion gate) + Task 6 (gate:all milestone)

Companion to `docs/plans/2026-08-21-dag-rework-plan.md`. Records the Task 5 gate,
its both-directions discrimination proof, and the Task 6 milestone gate-all with
a freshly-verified accounting of every red.

## Task 5 — `tools/check-package-dag.mjs`

A dedicated, brand-agnostic gate asserting the linear DAG. Three independent
conditions, checked per brand (m3e split + shoelace monolith):

- **(A) dep edge (split brands):** the Build package's emitted `elm.json`
  declares the Components package AND does NOT declare the Elements package.
- **(B) no cycle (split brands):** the Components package's `elm.json` does NOT
  declare the Build package.
- **(C) no Element shortcut (all brands):** no `<Ns>.Build.*` module imports
  `<Ns>.Element.*` directly — every element access routes through
  `<Ns>.Component.*`.

Wired into `tools/gate-all.mjs` as
`workspace: check-package-dag (Task 5 linear Build→Components DAG)`, alongside
`check-m3e-5pkg` (which asserts the packages.json SHAPE; this one asserts the DAG
EDGES + the source-level no-Element-shortcut, and additionally covers the
monolith shoelace brand that `check-m3e-5pkg` never looks at).
`gate-all-expected-steps.json` regenerated (one added step; membership +
constraint tests green).

### Both-directions discrimination proof (real evidence)

**GREEN on the current (NEW) shape:**

```
$ node tools/check-package-dag.mjs
  m3e: 132 M3e.Build.* module(s), 0 import M3e.Element.* (all route through M3e.Component.*)
  shoelace: 59 Sl.Build.* module(s), 0 import Sl.Element.* (all route through Sl.Component.*)
check-package-dag: OK — Build consumes Components (no Elements dep, no Components→Build cycle) and no Build module imports Elements directly. Linear DAG intact.
  → exit 0
```

**RED on the reconstructed pre-rework (OLD) shape** — the Task-0 base
`704ea440`'s m3e generated tree was reconstructed into a scratch dir
(`git archive 704ea440 brands/m3e/generated/package | tar -x`) and the gate's
m3e `packageRoot` repointed at it:

```
check-package-dag: the linear Build→Components→Elements→Core DAG is NOT intact:
  m3e: elm-m3e-build/elm.json must declare jackhp95/elm-m3e-components (Build consumes Components — the linear DAG)
  m3e: elm-m3e-build/elm.json must NOT declare jackhp95/elm-m3e-elements directly — Build reaches Elements through Components (no parallel-siblings shape)
  m3e: 130 M3e.Build.* module(s) import M3e.Element.* directly (must route through M3e.Component.*):
      …/elm-m3e-build/src/M3e/Build/Accordion.elm  … (+122 more)
  → exit 1
```

All three conditions (A dep-add, A/B elements-drop, C 130 Element imports) fire
on the OLD shape and none on the NEW — the gate genuinely discriminates.

**Second, complementary proof (condition C, live tree):** temporarily injecting
`import M3e.Element.Accordion as ElementDirect` into the live
`M3e/Build/Accordion.elm` made the gate red on exactly that one module
(`1 M3e.Build.* module(s) import M3e.Element.* directly`); reverting restored
green. Working tree left clean.

## Task 6 — gate:all milestone (`GATE_ALL_CONCURRENCY=1 node tools/gate-all.mjs`)

**Result: 54/58 passed, 0 skipped, 4 failed.** (58 vs Task-0's 57 = the one new
Task-5 step.) The new `check-package-dag` gate PASSES. Every red is a reserved
Task-7/Task-8 deferral — nothing spurious.

### Correction to the prior dispatch's report

The prior report listed 5 reds and called `elm-m3e: check` "pre-existing docs
data-drift, independent of codegen." **That was wrong.** `elm-m3e: check` was
RED *because of* the DAG rework and is now GREEN after four source-dir fixes that
complete Task 4's consumer migration (Step 4.7). At Task 0 it was PASS; the
rework moved `M3e.Build.*` / `M3e.Component.*` out of `elm-m3e/src` into sibling
packages, and four resolver/source-dir lists were not updated to match:

1. `brands/m3e/generated/docs/elm-m3e-docs/samples/elm.json` — added
   `elm-m3e-components/src` (the samples sandbox couldn't compile the reworked
   Build modules' new `import M3e.Component.*` → `check:samples` MODULE NOT
   FOUND).
2. `.../scripts/samples-gen/extract-samples.mjs` — `SRC_DIRS` now mirrors the
   split siblings, so `resolves()` finds `M3e.Build.Button` and keeps its
   (used, qualified) import instead of silently dropping it → `check:data-drift`
   stale-sample.
3. `.../scripts/check-data-drift.mjs` — its scratch regen now copies the split
   sibling packages so (2)'s resolver works inside the scratch too.
4. `pipeline/elm-cem/bin/acid.js` — the acid gate now stages sibling
   `<brand>-*/src` packages, so a positive probe importing across the split
   (`import M3e.Build.AppBar`) compiles → `check:cem` acid green. Brand-neutral
   comment (neutrality gate green); no-op for monolith brands.

None of these touch generated output (`ab-elm-m3e-split` byte-identity + both
`regen-drift`s stayed green; `samples/good/` unchanged — the committed samples
were always correct, only the resolvers were stale).

### The 4 remaining reds — freshly verified, all reserved deferrals

| red | root cause (verified this run) | owner |
|-----|-------------------------------|-------|
| `ab-elm-cem (Face A byte-identity)` | pristine snapshot still emits the OLD `M3e/Build` + `M3e/Build.elm` shape; workspace emits the NEW composed shape (`Only in out-pristine/M3e: Build`) | **Task 8** (Face-A bundle re-baseline) |
| `check-drift` | ONLY its `brand Face A (R-010)` sub-check fails — it runs `ab-elm-cem.sh` internally → identical root cause to the row above. All other sub-checks PASS; the okf `.cache/m3e` sub-check SKIPs as chronic-expected. | **Task 8** |
| `copy-fidelity elm-m3e` | published mirror (`source tracked=547`) still carries the old per-element `src/M3e/Build/*.elm`; workspace emits 394 → mirror bookkeeping delta | **Task 8 / publish** (mirror re-publish) |
| `elm-shoelace: check` | `check:validate` docs.json = 947,500 B (135.4% of the 700,000 cap), from the +58 degenerate `Sl.Component.*` facades on the monolith | **Task 7** (shoelace package split) |

> Note the *shift* from the prior report: `check-drift` was previously a SKIP
> (attributed only to the okf `.cache/m3e`); on this fresh run the pristine
> snapshot materialized, so its Face-A sub-check now genuinely FAILS on the same
> Build-shape drift as `ab-elm-cem` — a real red, not a skip. And the two
> `elm-cem-figma-connect` reds from the Task-0 baseline are now GREEN.

**Milestone verdict:** the linear `IR → Core → Elements → Components → Builders`
DAG is materialized and gate-enforced. Every remaining red is a reserved
Task-7/Task-8 rider; no red is unexplained or spurious.
