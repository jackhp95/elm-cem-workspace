# elm-m3e Family — Merge-Landing + Publish-Readiness Report

**Date:** 2026-08-12
**Scope:** Land the merged elm-m3e-arc work onto local mains, push the two authorized
mains (elm-m3e, elm-review-cem), and prepare the family for its FIRST-EVER
`elm publish` — **without publishing or tag-pushing anything.**
**Guardrails honored:** No `elm publish`, no Elm-registry write, no tag-push, no IR push.
Branch-`main` pushes for elm-m3e + elm-review-cem were authorized mid-task and are
recorded below. Everything else outward-facing is left for Jack.

---

## 1. Merge results + gate evidence + pushes

### elm-m3e — MERGED, GATE GREEN, PUSHED

Base `main @ec42d227` (clean, after restoring two chronically-drifting generated
elm-pages artifacts `docs/.elm-pages/Pages.elm` + `compiled/render.mjs`).

Merges (in the task's order):
| # | branch | result |
|---|--------|--------|
| 1 | `batch4-icons-elm-json-fix` (`be9a0aa7`) | FF-style merge `ec94ad10` — clean (subsumes batch3-icons-drift ⊃ batch2-regen ⊃ track1-regen) |
| 2 | `batch3-recast-containment` (`11f252f8`) | 3-way merge `40c63cd7` — clean (only new content: `CodegenReviewConfig.elm` ×2) |
| 3 | `overnight-track3-fixtures-slot` (`74cb37a8`) | 3-way merge `213089bb` — ONE conflict in `package.json` `check:spike` |

**Conflict resolved (`package.json` `check:spike`):** both branches redefined the
`check:spike` script with disjoint fixture sets. Resolved by **unioning** both sets
(per the memory note "keep both check:spike fixture sets") — all 6 positive fixtures
must compile (`ApiConsolidation`, `AnnotationOnly`, `IconUse`, `SlotPlacersOk`,
`EnumNarrowingOk`, `SlotApiOk`, + `bad/SlotPlacersWrongKind` which compiles and is
caught by elm-review, not the compiler) and all 4 negative fixtures must fail compile
(`WrongKindBuilderIntoIconSlot`, `EnumNarrowingSplitButton`, `EnumNarrowingBuilder`,
`SlotApiWrongKind`). Verified: `check:spike` EXIT 0 (6 `Success!`, 4 `Detected problems`).

**Two follow-up fixes needed to reach a green gate (both committed):**

1. **`8a1edfbd` — Regenerate `M3e.Icon` to canonical generator output (regen-drift fix).**
   batch4 hand-edited `M3e.Icon.elm`'s `@docs`/exposing and it was **not byte-faithful**
   to the generator+elm-format output (batch4 worklog itself flagged: "hand-applied fix…
   not regen-proven byte-for-byte" — the CEM manifest was unavailable then). With the
   manifest present, `check:cem` regen-drift went RED. Ran `npm run gen:src`; committed
   the canonical output. **API-identical** — the exposing set is the same 4084 identifiers
   (`custom` + 4083 icons), zero added/removed (verified by set-diff); pure
   formatting/ordering normalization. Coding-prefs: generated code = generator output,
   never hand-edited.
2. **`74193108` — Exclude `M3e.Icon` from the component reference (slug-collision fix).**
   The new `M3e.Icon` helper module was walked into `docs/data/reference.json` (gitignored,
   built artifact) as a "component"; its bare slug `icon` collides with the real icon
   component `M3e.Component.Icon` (both → `/components/icon`). Surfaced as a **duplicate
   Playwright test title** in `all-components.spec.ts`, which failed the pre-push gate's
   `test:browser`. Fix: added `"M3e.Icon"` to `NOT_EXPOSED` in
   `docs/scripts/extract-reference.mjs` (a helper module like `M3e.Aria`/`M3e.Attr`/
   `M3e.Token`, already excluded; documented via its own package `elm-m3e-icons`).
   reference.json now has 139 unique-slug components.

**Gate evidence — `npm run gate` EXIT 0 (env: `ELM_CEM_BIN`→landed elm-cem `../elm-cem`
@3745c23, `IR_SRC`→`docs/vendor/elm-foundation`):**
```
check:vendor: OK — 31 vendored file(s) match a fresh copy from source.
check:samples: OK — 7 derived from live code, 22 compiled + reviewed, 2 verified rejected.
regen-drift: OK — committed src + elm.json (root + 1 nested package(s)) match a fresh regen.
check:drift: OK — 30 generated artifact(s) match a fresh regen.
registry-check: OK — [root] package compiles registry-faithfully (elm make --docs succeeded).
registry-check: OK — [nested package "elm-m3e-icons"] package compiles registry-faithfully (elm make --docs succeeded).
gate: OK — drift, registry-check, and acid all passed.
I found no errors!                (elm-review / check:review)
TEST RUN PASSED  Passed: 13  Failed: 0        (test:fast)
215 passed (2.7m)                              (test:browser Playwright)
```
Note: a **pre-existing gate flake** — running `check:*` in parallel (`run-p`) races on the
shared `docs/elm-stuff` because `check:cem`/`check:samples`/`check:drift` all invoke
`elm make --docs` concurrently; a cold run gave a spurious `check:drift` stale-reference.json
FAIL that vanished on a warm re-run. Not caused by the merges. Friction filed.

**PUSH:** `git push origin main` → `ec42d227..74193108  main -> main`, **pre-push gate
passed**, `origin/main == local main == 74193108`. No tags pushed.

### elm-review-cem — RECONCILED, BATCH4 MERGED, GATE GREEN, PUSHED (design-bearing conflict resolved + independently reviewed)

Local `main @789d307` was diverged (4 local-ahead, 1 origin-ahead `0965d60`
"support barrel re-exports in callSiteUnder").

**The barrel conflict (design-bearing).** `origin/main`'s `0965d60` and the local
batch's `789d307` are **two independent, parallel fixes** (authored ~2h apart the same
day) for the SAME Phase-B problem (components moved `M3e.X` → `M3e.Component.X`, breaking
barrel-call resolution in `src/Cem/Internal/Facts.elm`). They rewrite `namespaces`
incompatibly:
- `0965d60`: generic — all ancestor prefixes sorted **longest-first** + a `callSiteUnder`
  prefix-match fallback. **No `buildIndex` change.** (touches ONLY `Facts.elm`.)
- `789d307`: targeted — a `barrelNamespaceParts` helper (Component/Build), **barrel-root-first**
  ordering, AND **barrel-ALIAS KEYS in `buildIndex`.**

`789d307`'s `buildIndex` barrel-alias keys are the **foundation of the entire batch-3
hardening** (all barrel-resolving rules were reworked to delegate to `Facts.buildIndex`
for exactly those keys; guarded by `check:index` + `tests/RealFactsShapeTest.elm`). Taking
`0965d60`'s `namespaces` **regresses** this: a barrel call `M3e.accordion` resolves
(longest-first) to the deepest M3e-prefixed sibling namespace instead of the barrel root,
so lookups miss and RequireSlot/SingularSlot/ValidEnumValue go silent.

**Resolution: keep `789d307`'s `Facts.elm` verbatim (the tested version); supersede
`0965d60`.** Evidence: **311 tests pass** with `789d307`'s Facts.elm; the barrel tests
**FAIL** with `0965d60`'s. `0965d60` touched ONLY `Facts.elm`, so nothing else is lost;
`origin/main` is still recorded as a merge parent (via the reconcile merge `3a23a5c`), so
the push is a clean fast-forward.

**Independently verified (read-only reviewer subagent, opus): VERDICT SAFE-TO-PUSH.**
Reviewer confirmed (a) `0965d60` is Facts.elm-only, (b) HEAD's barrel logic byte-identical
to `789d307`, (c) tree green (311), (d) discarding `0965d60` correct — `factNamespaceParts`
derives from `fact.module_` which is always `M3e.Component.<X>` (or `.Build`), so local's
`barrelNamespaceParts` covers 100% of intermediate segments real facts can emit; the
`M3e.Unsafe.Attributes` case `0965d60` worried about is a barrel submodule, never a fact
`module_`. Reviewer reproduced the regression in a throwaway worktree: **4** tests fail with
`0965d60`'s logic (batch-4 added more barrel tests than the original 3 — the regression is
broader, never narrower).

Merge chain: reconcile `origin/main` → `3a23a5c` (namespaces resolved + elm-format) →
merge `batch4-facts-sync-hardfail` `9b1ce5c` → `f3aefda` → correction `ccf01be` (restore
tested Facts.elm; neutrality allowlist unchanged — batch4's covers local's M3e mentions).

**Gate evidence — `npm run gate` EXIT 0** (sibling `../elm-cem` present, so
`check:facts-sync` resolves canonical without an env var):
```
facts-sync: OK — src/Cem/Facts.elm byte-identical to .../elm-cem/facts/src/Cem/Facts.elm
check:index: OK — no rule rolls a private facts index (all barrel-resolving rules use Facts.buildIndex)
I found no errors!                (check:review)
neutrality-check: OK — no unreviewed design-system mentions.
TEST RUN PASSED  Passed: 311  Failed: 0
```

**PUSH:** `git push origin main` → `0965d60..ccf01be  main -> main`, **pre-push gate
passed** (311 tests), `origin/main == local main == ccf01be`. No tags pushed.

### elm-cem — UNTOUCHED (per instruction)
`main @3745c23`, already landed by Jack + already on origin. `local == origin`. Not touched.

### IR (`elm-html-intermediate-representation`) — NOT PUSHED (per instruction)
`main @d093823` has 1 unrelated unpushed commit (`origin/main @d3848a2`). **Left for Jack.**
Intentional divergence; no push.

---

## 2. Per-package publish-readiness

First-ever publish for every package below (none has ever been `elm publish`ed).

| Package | tree | ver | LICENSE/README | `elm make --docs` | ready? |
|---|---|---|---|---|---|
| `jackhp95/elm-html-intermediate-representation` | `elm-html-intermediate-representation/` | **2.0.0** | yes / yes | **OK** (40 KB, 7 mods) | ⚠ version blocker (see §4) |
| `jackhp95/elm-cem-facts` | `elm-cem/facts/` (nested in elm-cem repo) | 1.0.0 | yes / yes | **OK** (3.5 KB, 1 mod) | ⚠ needs own repo/mirror |
| `jackhp95/elm-review-cem` | `elm-review-cem/` | 1.0.0 | yes / yes | **OK** (76 KB, 26 mods) | ✅ mechanically ready |
| `jackhp95/elm-m3e` (root) | `elm-m3e/` (138 mods) | 1.0.0 | yes / yes | **OK** (registry-faithful, via gate) | ⚠ NAME COLLISION (see §4) |
| `jackhp95/elm-m3e-icons` | `elm-m3e/elm-m3e-icons/` (nested) | 1.0.0 | yes / yes | **OK** (registry-faithful, via gate) | ⚠ needs own repo + split (see §3) |
| `jackhp95/elm-m3e-components` | `elm-m3e/elm-m3e-components/` (131 mods) | 1.0.0 | **NO / NO** | **FAIL — 724 NB1 violations** | ❌ broken (circular dep, §4) |
| `jackhp95/elm-m3e-builder` | `elm-m3e/elm-m3e-builder/` (131 mods) | 1.0.0 | **NO / NO** | **FAIL — 654 NB1 violations** | ❌ broken (circular dep, §4) |

All `elm.json` files are valid `type: package` with name/version/license/summary/deps.
Docs sizes for the three directly-built packages are well under the 700 KB registry cap.

---

## 3. Family package trees + `split.js` + registry-faithful docs (investigated)

### `split.js` (`elm-cem/bin/split.js`)
- **What it does:** partitions a generated flat `src/` into per-facet package mirrors driven
  by a `packages.json` spec, with totality/disjointness/DAG-respect gates; emits per package
  `src/` + `elm.json` (deps from spec, `exposed-modules` derived from routed files) + `README`
  (with a "do not edit" banner) + `LICENSE`. CLI: `elm-cem split --packages=… --src=… --out=…`.
- **DORMANT:** unwired from every gate/build script in both repos; **elm-m3e has no
  `packages.json`** (deleted 2026-07-22, commit `b94bfc2b`, along with `measure-docs.mjs`/
  `isolation-probe.mjs`/the `split`+`gate` npm scripts). Its own 7 tests still pass, but nothing
  invokes it.
- **B8 (empty `exposed-modules`) is FIXED in split.js code** — it now explicitly exposes
  `*.Review.Facts` while still filtering other `Review.*` (cites issue #42). BUT a **stale,
  gitignored `dist-packages/elm-m3e-review-facts/elm.json` still on disk has
  `exposed-modules: []`** (a Jul-21-era artefact never re-run through fixed split.js) — a
  would-be-`elm-publish`-rejected package sitting in the tree. Misleading, not a live code bug.
- **`elm-m3e-icons` is NOT a split artefact** — it's a hand-authored, generator-native nested
  package (its own `src/M3e/Icon.elm` + `elm.json` + LICENSE + README), already a complete,
  publishable tree. It does **not** need split.js; it needs its own GitHub repo (§4.3).

### Tree map (which `jackhp95/elm-m3e*` identities exist)
| Path | Name | Exposed | Role |
|---|---|---|---|
| `elm-m3e/elm.json` (root) | `jackhp95/elm-m3e` | 138 | **Arch R — currently CI-verified/publishable** |
| `elm-m3e/elm-m3e/` | `jackhp95/elm-m3e` | 8 | Arch 3P intended thin-core (broken deps below) |
| `elm-m3e/elm-m3e-components/` | `jackhp95/elm-m3e-components` | 131 | Arch 3P components (BROKEN) |
| `elm-m3e/elm-m3e-builder/` | `jackhp95/elm-m3e-builder` | 131 | Arch 3P builder (BROKEN) |
| `elm-m3e/elm-m3e-icons/` | `jackhp95/elm-m3e-icons` | 1 | generator-native standalone (READY) |
| `elm-m3e/dist-packages/*` | various | 0–49 | **STALE gitignored Jul-21 artefacts — delete** |

### Registry-faithful `elm make --docs` (staged family deps)
| Package | result |
|---|---|
| root `jackhp95/elm-m3e` (138) | **PASS** — static audit + `elm make --docs` succeed (deps: IR + cem-facts) |
| `jackhp95/elm-m3e-icons` (1) | **PASS** — succeed (dep: IR only) |
| `jackhp95/elm-m3e-components` (131) | **FAIL — 724 NB1 violations** — `M3e.Internal.Types.*` imports `M3e.Build.Internal` (a *builder* namespace) → DAG inversion; compile never attempted |
| `jackhp95/elm-m3e-builder` (131) | **FAIL — 654 NB1 violations** — `M3e.Build.*` imports component/core namespaces not fully declared; compile never attempted |

**The 3-package split is currently unpublishable:** components import builder internals
(`M3e.Internal.Types.*` → `M3e.Build.Internal`) — a circular/inverted dependency. No valid
topological publish order exists for components/builder until that is resolved. Only **root
`jackhp95/elm-m3e` + `jackhp95/elm-m3e-icons`** compile registry-faithfully today.

---

## 4. Remaining blockers + open decisions (Jack's to resolve)

### DECISION BLOCKERS (do NOT guess — Jack must decide)

1. **elm-m3e architecture: root-monolith (R) vs 3-package split (3P) — the master decision
   (thermo-nuclear B10, STILL OPEN).** Two mutually-exclusive active architectures exist:
   - **Arch R** — root `elm-m3e/elm.json` as `jackhp95/elm-m3e` (138 modules), one package,
     one `elm publish` from the repo root. **This is what `check:cem` verifies and it PASSES.**
     RELEASE-CHECKLIST §0 says "flattened to the root … No split."
   - **Arch 3P** — thin core (`jackhp95/elm-m3e`, 8) + `jackhp95/elm-m3e-components` (131) +
     `jackhp95/elm-m3e-builder` (131), per DESIGN-NOTES. **Currently BROKEN** (see #2).

   Three trees claim the name `jackhp95/elm-m3e@1.0.0` (root 138, nested 8, stale-dist 1);
   exactly one may own it, permanently. **Recommendation (mine, non-binding): publish Arch R
   now (root + icons both compile registry-faithfully today) and defer 3P until its DAG is
   fixed** — but this is Jack's call.

2. **The 3-package split is unpublishable as-is — circular dependency.** `elm-m3e-components`
   (724 NB1 violations) and `elm-m3e-builder` (654) both FAIL registry-check: `M3e.Internal.Types.*`
   in `elm-m3e-components/src/` imports `M3e.Build.Internal` (a *builder* namespace) — components
   depending on builder internals, a DAG inversion. No valid topological publish order exists for
   3P until this is resolved. (Not a mechanical fix — it's a source-tree/split-spec correction.)

3. **IR first-publish version.** `elm-html-intermediate-representation/elm.json` is
   **version `2.0.0`**, but `elm publish` requires the FIRST publish of a brand-new package to
   be exactly **`1.0.0`**. IR was bumped to 2.0.0 for the breaking IR-v2 changes, but since it
   was never published, 2.0.0 cannot be the first registry version. Decide: publish `1.0.0`
   first (then the v2 breaking changes become a later MAJOR bump), or another path.

4. **Mirror/host repos don't exist for 3 packages.** `elm publish` publishes from a package's
   own GitHub repo at a pushed tag. Existing: `jackhp95/elm-cem-facts` ✅. **Missing:**
   `jackhp95/elm-m3e-icons`, `jackhp95/elm-m3e-components`, `jackhp95/elm-m3e-builder` (all
   nested inside the `elm-m3e` repo). Each needs its own GitHub repo with its tree pushed before
   publish. (`elm-cem-facts` also lives nested in the `elm-cem` repo — confirm its publish source
   / whether the repo publishes a subdir.)

### MECHANICAL BLOCKERS / CLEANUP (fixable)

5. **`elm-m3e-components` + `elm-m3e-builder` lack LICENSE + README** — `elm publish` wants a
   LICENSE. These are split targets, so the fix belongs in `split.js` (it already stamps
   LICENSE/README) once 3P is chosen + wired — not hand-added files. Moot if Arch R is chosen.

6. **Delete stale `elm-m3e/dist-packages/*`** (gitignored, Jul-21-era). Actively misleading —
   `elm-m3e-review-facts/elm.json` has `exposed-modules: []` (the live remnant of B8). The
   2026-08-05 plan's Phase 0 step 5 already lists this deletion as mandatory.

7. **`split.js` is dormant + elm-m3e has no `packages.json`** (deleted 2026-07-22). If Arch 3P
   is chosen, split.js must be re-wired and a `packages.json` re-authored. B8 is already fixed in
   split.js's code (it now exposes `*.Review.Facts`).

### THERMO-NUCLEAR AUDIT RECONCILIATION (2026-07-15, 42 blockers) — _partial; completes with §3_

The audit predates major family evolution (substrate re-exports → nobody imports `HtmlIr`;
cross-CEM branding; the facet split; batches 1–4). Reconciliation of the structural blockers:
- **B1/B2** (facets import unexposed `*.Internal` → whole family uncompilable from registry; and
  the gates couldn't see it): **RESOLVED for the shipping Arch-R path.** The pushed elm-m3e gate's
  `registry-check` compiles root (138) + icons **registry-faithfully** (`elm make --docs` as a real
  package with staged deps) — exactly the registry-faithful gate B2 demanded. The Arch-3P trees
  reproduce a B1-class defect (§4.2 circular internal imports), but 3P isn't the shipping path.
- **B8** (`*-review-facts` empty `exposed-modules` from split.js's `Review` filter): **fixed in
  split.js code** (now exposes `*.Review.Facts`, cites #42). BUT a **stale gitignored
  `dist-packages/elm-m3e-review-facts/elm.json` with `exposed-modules: []` remains on disk** →
  §4.6 (delete stale dist-packages).
- **B10** (root-monolith vs split, name collision): **STILL OPEN** — the master decision, §4.1.
- Release-tooling blockers (B15 `mirror-release.mjs` dead push path, B16 stale elm-tooling action,
  B11 red CI) NOT re-audited here — out of this task's merge/readiness scope; flag for a dedicated
  release-tooling pass before Stage F.

---

## 5. DO NOT RUN — dependency-ordered publish sequence for JACK

**⛔ These are for Jack to execute. This agent published nothing and pushed no tags.**
Order is topological (a package's family deps must be on the registry first).

### Preconditions (Jack, one-time)
- Resolve §4 decisions: **choose Arch R or 3P (#1)**; set IR's first-publish version to `1.0.0`
  (#3); create the missing GitHub repos (#4); delete stale `dist-packages/*` (#6).
- Each package publishes from its OWN GitHub repo at a pushed tag matching `elm.json` version.
- `elm publish` is a **two-run ritual**: the first run validates + registers the name and prints
  the exact `git tag`/`git push origin <ver>` step; the second (after the tag is pushed)
  completes the publish.

### Path A — Arch R (READY TODAY: root elm-m3e + icons both compile registry-faithfully)
```sh
# ── TIER 0: zero-family-dep leaves ─────────────────────────────────────────
# jackhp95/elm-cem-facts  (deps: elm/core; repo exists; publishes from elm-cem repo subdir? CONFIRM)
#   (cd elm-cem/facts) git tag 1.0.0 && git push origin 1.0.0 ; elm publish

# jackhp95/elm-html-intermediate-representation  (deps: elm/*; bump 2.0.0 -> 1.0.0 FIRST — §4.3)
#   (cd elm-html-intermediate-representation) git tag 1.0.0 && git push origin 1.0.0 ; elm publish

# ── TIER 1: depend on Tier 0 ───────────────────────────────────────────────
# jackhp95/elm-review-cem  (deps: elm-cem-facts + jfmengels/elm-review + stil4m/elm-syntax)
#   (cd elm-review-cem) git tag 1.0.0 && git push origin 1.0.0 ; elm publish

# jackhp95/elm-m3e  (ROOT tree, 138 mods; deps: IR + elm-cem-facts) — the Arch-R canonical package
#   (cd elm-m3e) git tag 1.0.0 && git push origin 1.0.0 ; elm publish

# jackhp95/elm-m3e-icons  (deps: IR only — INDEPENDENT of elm-m3e core; needs its own repo — §4.4)
#   git tag 1.0.0 && git push origin 1.0.0 ; elm publish
```
Under Arch R the whole family is publishable **once §4.3 (IR version) + §4.4 (icons repo) are
handled** — no broken packages in the path.

### Path B — Arch 3P (BLOCKED — do not attempt until the circular dep §4.2 is fixed)
```
elm-cem-facts → IR → elm-m3e (thin core, 8) → elm-m3e-components (131) → elm-m3e-builder (131)
                                            ↘ elm-m3e-icons (parallel; IR-only)
```
`elm-m3e-components` + `elm-m3e-builder` currently FAIL registry-check (724 / 654 NB1 violations,
components→builder-internals inversion). Also requires re-wiring `split.js` + a new `packages.json`
(§4.7) and LICENSE/README stamping (§4.5). **Not publishable in this state.**
