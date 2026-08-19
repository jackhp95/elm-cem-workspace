# Repo Shape v2 — Wave 1 Execution Plan

**Status: ready to execute (not started).** Written 2026-08-19 on branch
`plan/repo-shape-v2-wave1` (off `spec/repo-shape-v2-research`, off `main`).

**Design of record:** `docs/superpowers/specs/2026-08-19-repo-shape-v2-design.md`
— specifically its **"Key decisions & rationale"** appendix (the Jack-confirmed
live-session record, numbered 1–11 + the two wave-1-session renames) and its
**"Net effect: what's actually in this wave"** summary, with the decided architecture
stated inline throughout §1–§7. This plan executes that wave-1 slice only; everything the
spec marks deferred is enumerated under "Out of scope" below. Decision references below use
the form **"spec decision #N"** (the appendix numbering).

**Methodology template:** `docs/plans/2026-08-18-core-brands-workspace-reorg-plan.md`
(implemented earlier today, 2026-08-19). That plan reshaped `packages/` → `core/` +
`brands/m3e/{inputs,outputs}/`. **This wave is the second pass on the same class of
files** — most `tools/*` scripts it edited need a SECOND round of edits here. Every
path fact below was **re-grepped from the current post-reorg state** on 2026-08-19,
NOT copied from that plan (its line numbers and `packages/…` strings are stale).

> **For agentic workers:** REQUIRED SUB-SKILL: use `superpowers:subagent-driven-development`
> (recommended) or `superpowers:executing-plans` to implement task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking. Every mutating step runs in a git worktree; every
> subagent prompt must include the friction-logging instruction (`~/.claude/frictions/`).

---

## Goal

Execute the **directory reshape** slice of Repo Shape v2 in `elm-cem-workspace`, keeping
`node tools/gate-all.mjs` green after every task:

1. `core/` → `pipeline/` (brand-agnostic machinery) — spec decision #5 — **including the
   `cem-figma-connect` → `elm-cem-figma-connect` rename** (spec, wave-1-session rename).
2. Extract the two truly-foundational libs to a new top-level `packages/` — spec decision #3 +
   the IR's dictated placement — **including the `elm-html-intermediate-representation` →
   `elm-virtual-dom-intermediate-representation` rename** (spec, wave-1-session rename).
3. `tailwind-md3` → `pipeline/elm-cem-tailwind` + `tailwind-m3e-web` →
   `brands/m3e/generated/style/elm-m3e-tailwind` (finish the split) — spec decision #1.
4. Extract the docs site to `brands/m3e/generated/docs/elm-m3e-docs` with an internal
   `generated/`/`authored/` labeling — spec decision #9.
5. `m3e-okf` → `elm-m3e-okf`, relocate to `brands/m3e/generated/okf/` — spec decision #10.
6. `brands/m3e/outputs/` → `brands/m3e/generated/{package,okf,style,docs}/` — the umbrella
   move (item 6 of scope).
7. Relocate the html brand: `elm-typed-html` → `brands/html/generated/package/`,
   `config/config.json` → `brands/html/inputs/config.json` — spec decision #8.

**Not in this wave** (spec decisions #4, #7, #9-partial, #8-partial): the 5-package explosion, the
`packages.json` rewrite, the `-elements`/`-components` naming inversion, the 3 docs codegen
wins, the guide-markdown migration, and every brand beyond m3e + html. See "Out of scope."

## Architecture

Seven sequential, independently-gated tasks (Task 0 is an additive no-op safety net).
Ordering is dependency-driven, not scope-list order:

- **Task 1 (foundation)** does the `core/`→`pipeline/` rename (including the
  `cem-figma-connect`→`elm-cem-figma-connect` package rename), the `packages/` extraction
  (including the `elm-html-intermediate-representation`→`elm-virtual-dom-intermediate-representation`
  rename), AND the html-brand relocation together — because `elm-typed-html`, `elm-cem`'s IR
  symlink, and `elm-cem`'s test `elm.json`s all reference the same IR/`elm-cem` dirs that move
  here. Splitting them would force provisional double-edits (move to `pipeline/`, then re-move).
  Doing them atomically means every cross-reference is edited **once, to its final value**.
  Folding the two renames into this same move-set means the new *names* are also applied once,
  to final value, rather than moved-then-renamed.
- **Tasks 2–5** handle the packages that need real surgery or relocation (tailwind split,
  `m3e-okf` rename, `elm-m3e` relocation, docs extraction).
- **Task 6** is cleanup + final verification + spec-status flip.

**Tech stack:** pnpm workspaces, Node ESM tooling under `tools/`, Elm packages,
Tailwind v4 CSS, elm-pages SSG (docs).

---

## Depth arithmetic reference (load-bearing — read before any relative-path edit)

`packages/<pkg>/` was depth-2 (`packages`, `<pkg>`); `core/<pkg>/` is also depth-2. The
2026-08-18 reorg therefore needed **zero** relative-`../`-depth fixes for `core/`-bound
packages. **This wave is different** — several moves change depth. Segment counts from repo
root:

| Move | From depth | To depth | Δ | Relative-`../` impact |
|---|---|---|---|---|
| `core/elm-cem` → `pipeline/elm-cem` | 2 | 2 | 0 | none (literal `core/`→`pipeline/` string only) |
| `core/elm-cem-compose` → `pipeline/elm-cem-compose` | 2 | 2 | 0 | none |
| `core/elm-review-cem` → `pipeline/elm-review-cem` | 2 | 2 | 0 | none |
| `core/cem-figma-connect` → `pipeline/elm-cem-figma-connect` | 2 | 2 | 0 | none for depth — literal `core/`→`pipeline/` + the `cem-figma-connect`→`elm-cem-figma-connect` **rename** (spec decision, confirmed). A rename does not change segment depth. |
| `core/elm-html-intermediate-representation` → `packages/elm-virtual-dom-intermediate-representation` | 2 | 2 | 0 | none for depth (rename does not change depth); its referrers change `core/`→`packages/` **and** the dir name `elm-html-…`→`elm-virtual-dom-…`. |
| `core/tonal-palette-oklch` → `packages/tonal-palette-oklch` | 2 | 2 | 0 | none (only consumer imports it by workspace name) |
| `core/tailwind-md3` → `pipeline/elm-cem-tailwind` | 2 | 2 | 0 | none for depth; rename + internal absorb (Task 2) |
| `core/elm-typed-html` → `brands/html/generated/package/elm-typed-html` | 2 | 5 | **+3** | every `../`-import to a sibling/`tools/` gains **+3** `../` |
| `brands/m3e/outputs/elm-m3e` → `brands/m3e/generated/package/elm-m3e` | 4 | 5 | **+1** | +1 `../` on out-of-package imports |
| `brands/m3e/outputs/tailwind-m3e-web` → `brands/m3e/generated/style/elm-m3e-tailwind` | 4 | 5 | **+1** | +1 `../` |
| `brands/m3e/outputs/m3e-api-okf` → `brands/m3e/generated/okf/elm-m3e-okf` | 4 | 5 | **+1** | +1 `../` |
| `brands/m3e/outputs/elm-m3e/docs` → `brands/m3e/generated/docs/elm-m3e-docs` | 5 | 5 | **0** | **depth unchanged** — breakage is *un-nesting from `elm-m3e`*, not depth (see Task 5) |

**Critical correction vs. an early sub-agent sweep:** the docs directory does NOT get
deeper. `brands/m3e/outputs/elm-m3e/docs` and `brands/m3e/generated/docs/elm-m3e-docs` are
both depth-5. Cross-refs that reach the workspace root (`../../../../../core/…`) keep the
**same** `../` count and only swap `core/`→`pipeline/`. What breaks is every ref that
reached *up into the parent `elm-m3e` package* (`../src`, `../config`, `../elm-m3e-families`,
`../data`, `../review`) — after extraction those must reach *sideways* into
`brands/m3e/generated/package/elm-m3e` (i.e. `../src` → `../../package/elm-m3e/src`).

Repo-root reach by depth: depth-2 pkg root → `../../`; depth-5 pkg root → `../../../../../`.
Add the in-package subdir depth for scripts nested under `scripts/`, `bin/`, `review/`, etc.

---

## Resolved open questions (grep sweep) — every hardcoded path reference, re-verified 2026-08-19

Verified against actual current file contents in this worktree
(`/Users/jack/.paseo/worktrees/3ov4grvm/plan-repo-shape-v2-wave1`). Organized by the file
that needs editing. Every entry marked **verified** was read directly this session.

### A. `tools/family.json` (verified — `srcDir` values, current)

| Key | Current `srcDir` | New `srcDir` | Task |
|---|---|---|---|
| `elm-cem` | `core/elm-cem` (L5) | `pipeline/elm-cem` | 1 |
| `elm-cem-compose` | `core/elm-cem-compose` (L81) | `pipeline/elm-cem-compose` | 1 |
| `elm-review-cem` | `core/elm-review-cem` (L89) | `pipeline/elm-review-cem` | 1 |
| `elm-cem-figma-connect` (was key `cem-figma-connect`) | `core/cem-figma-connect` (L148) | `pipeline/elm-cem-figma-connect` | 1 |
| `elm-cem-facts` | `core/elm-cem/facts` (L144) | `pipeline/elm-cem/facts` | 1 |
| `elm-virtual-dom-intermediate-representation` (was key `elm-html-intermediate-representation`) | `core/elm-html-intermediate-representation` (L85) | `packages/elm-virtual-dom-intermediate-representation` | 1 |
| `elm-typed-html` | `core/elm-typed-html` (L93) | `brands/html/generated/package/elm-typed-html` | 1 |
| `tailwind-m3e-web` | `brands/m3e/outputs/tailwind-m3e-web` (L122) | `brands/m3e/generated/style/elm-m3e-tailwind` | 2 |
| `elm-m3e-okf` (was key `m3e-okf`) | `brands/m3e/outputs/m3e-api-okf` (L97) | `brands/m3e/generated/okf/elm-m3e-okf` | 3 |
| `elm-m3e` | `brands/m3e/outputs/elm-m3e` (L9) | `brands/m3e/generated/package/elm-m3e` | 4 |

Notes:
- **Family.json table keys — rename policy: RENAME ALL THREE (resolved 2026-08-19, full local
  consistency).** The `cem-figma-connect`→`elm-cem-figma-connect` (Task 1), `elm-html-intermediate-representation`→`elm-virtual-dom-intermediate-representation` (Task 1),
  and `m3e-okf`→`elm-m3e-okf` (Task 3) table keys all rename to match their new package names — no
  key is left carrying an old name. Jack's directive (verbatim, this session): *"I want correctness…
  I don't want a whiff of the old names. That only makes things more confusing in the future,"* and
  *"fix it all. blast radius be damned."* This **reverses** an earlier draft that kept the cfc/IR keys
  to avoid an indexing cascade; the cascade is small and fully enumerated in **finding A3** (every
  literal `family.json`-key lookup, name comparison, and gate step-name assertion). The **one
  carve-out** is the mirror-facing side: keys/values that a gate reads to derive the *external* mirror
  repo (`jackhp95/${name}` in `check-mirror-drift.mjs:23,82` and `publish-mirror.mjs:238…345`) stay
  pointed at the real current mirror name — that is Jack's separately-confirmed mirror exception
  (renaming a live external mirror is its own explicit action), NOT covered by "blast radius be
  damned." See **finding A3** for the exact per-file split and the "Decisions log" for the resolution.
- **`m3e-okf`'s `pnpmFilterName: "m3e-docs"` (L98) is a pre-existing stale/false entry — fixed in
  Task 3.** Its `$pnpmFilterNameNote` (L99) claims the package's `package.json` `name` is
  `"m3e-docs"`; verified **false** — the actual current `name` is `m3e-okf` (no `package.json`
  anywhere is named `m3e-docs`, grepped workspace-wide). Task 3 renames the `name` to `elm-m3e-okf`
  and updates `pnpmFilterName` → `elm-m3e-okf`, deleting the stale note in the same edit (spec
  decision #10). (`pnpmFilterName` is at real L98, not the L117-118 an earlier draft cited.)
- `material-okf` (`brands/m3e/inputs/material-okf`) is **unchanged** this wave.
- `elm-m3e`'s `authorizedExtraPrefixes: ["elm-m3e-families/"]` (L76) is a relative-within-srcDir
  prefix and needs **no** change when `elm-m3e` relocates. There is **no `tonal-palette-oklch`
  or `tailwind-md3` entry** in `family.json` today (verified) — nothing to edit for those two.

### A2. Rename-specific `name`/dependency edits (verified — new cascade the relocate-only sweep didn't need)

The two Task-1 renames (`cem-figma-connect`→`elm-cem-figma-connect`,
`elm-html-intermediate-representation`→`elm-virtual-dom-intermediate-representation`) change
package **identity**, not just paths — so they touch `package.json`/`elm.json` `name` fields and
every dependent that references the old published name. These edits are **additional to** the
srcDir/relative-path edits in findings A/S/T:

- **`cem-figma-connect`→`elm-cem-figma-connect` (Task 1):** edit `core/cem-figma-connect/package.json`
  `"name": "cem-figma-connect"` → `"elm-cem-figma-connect"`. **No other `package.json` depends on it
  by workspace name** (verified: the only `"cem-figma-connect"` `package.json` occurrence is its own
  `name` field; `tools/bump.mjs` et al. reference it by *path*, already covered in findings E/F/…).
  So cfc's rename cascade is just its own `name` field + the path edits.
- **`elm-html-intermediate-representation`→`elm-virtual-dom-intermediate-representation` — Elm
  published-name cascade (5 `elm.json` edits, verified):**
  - `packages/…/elm.json` (the IR's own, currently `core/elm-html-intermediate-representation/elm.json:3`):
    `"name": "jackhp95/elm-html-intermediate-representation"` → `"jackhp95/elm-virtual-dom-intermediate-representation"` (**Task 1**).
  - `brands/html/generated/package/elm-typed-html/elm.json` (currently `core/elm-typed-html/elm.json:40`):
    dependency key `"jackhp95/elm-html-intermediate-representation"` → new name (**Task 1**, same task the html brand moves).
  - `brands/m3e/generated/package/elm-m3e/elm.json` (currently `brands/m3e/outputs/elm-m3e/elm.json:153`):
    dependency key → new name (**Task 4**, moves with `elm-m3e`).
  - `brands/m3e/generated/package/elm-m3e/elm-m3e-families/elm.json` (currently `…/elm-m3e-families/elm.json:36`): dependency key → new name (**Task 4**).
  - `brands/m3e/generated/package/elm-m3e/elm-m3e-icons/elm.json` (currently `…/elm-m3e-icons/elm.json:16`): dependency key → new name (**Task 4**).
  - The **module namespace `HtmlIr.*` is unaffected** by the package rename (Elm package name ≠
    module names) — do NOT touch `HtmlIr.` imports. Only the `elm.json` `name`/dependency strings
    and the dir-name paths change. **Re-grep the whole workspace for
    `jackhp95/elm-html-intermediate-representation` before committing each of Task 1 and Task 4** —
    any remaining hit is an un-migrated dependent.
  - **The elm-cem IR symlink alias name is ALSO RENAMED** (resolved 2026-08-19 — see finding S #1 and
    finding A3) from `elm-html-intermediate-representation` → `elm-virtual-dom-intermediate-representation`,
    so no old name survives anywhere local. **Re-verified this session:** *no* `elm.json`
    `source-directories` under `core/elm-cem` actually consumes the alias name (the only IR
    `source-directories` refs — `tests/phantom/native/acid/elm.json:7`, `tests/phantom/acid/elm.json:7` —
    reach the *sibling* `core/`→`packages/` path, already retargeted in finding T; and `elm-cem` has no
    root `elm.json`). So the earlier "renaming the alias would force `source-directories` edits" rationale
    is **not borne out** — the alias rename is a symlink-name + exclusion-glob change with no `elm.json`
    cascade. Grep `core/elm-cem` for the alias name at execution time to confirm zero remaining
    consumers before committing.

**A2 addendum — the complete `jackhp95/elm-html-intermediate-representation` published-name dependent set
(re-verified whole-workspace 2026-08-19; the finding-A2 `grep → zero` gate at Steps 1.7b/4.3b covers all
of these, but the earlier draft enumerated only the 5 `elm.json` files — the rest are spelled out here so
the sweep is mechanically complete, not gate-dependent).** All rename the key/string to
`jackhp95/elm-virtual-dom-intermediate-representation`; none is a mirror/URL (the GitHub-mirror carve-out
is the `.git` URL + `publish-mirror-state.json` key only — the **Elm published name** renames, decision #1):

- **Already in finding A2 (5 `elm.json`):** IR's own (`…/elm.json:3` name), `elm-typed-html/elm.json:40`
  (Task 1); `elm-m3e/elm.json:153`, `elm-m3e-families/elm.json:36`, `elm-m3e-icons/elm.json:16` (Task 4).
- **Already in finding K:** `tools/measure-docs-size.mjs:76` (Task 1).
- **NEW — `core/elm-cem/bin/*` string-literal special-cases (LOAD-BEARING; move with elm-cem, Task 1):**
  `bin/family-deps.js:37` (`package: "jackhp95/elm-html-intermediate-representation"`),
  `bin/registry-check.js:136` (`if (pkg === "jackhp95/elm-html-intermediate-representation")`),
  `bin/validate.js:89` (`delete externalDeps["jackhp95/elm-html-intermediate-representation"]`),
  `bin/validate.js:207,212` (vendored-IR `d === "jackhp95/…"` comparisons). These special-case the IR by
  its published name in registry/validation logic; an un-renamed string silently stops matching → the IR's
  vendored-dep handling breaks. **Add these to Step 1.7b's edit list.**
- **NEW — `core/elm-cem/tests/*` assertions (move with elm-cem, Task 1):** `tests/depstamp.test.mjs:31`,
  `tests/eject.test.mjs:26`, `tests/gates.test.mjs:25`, `tests/registry-check-nested-pkg.test.mjs:37`
  (each `const IR = "jackhp95/elm-html-intermediate-representation"`).
- **NEW — `brands/m3e/inputs/cem/config/slots.json:27,44` (LOAD-BEARING config-input TEMPLATE; edit
  in-place — this dir is NOT moved this wave).** `slots.json` is elm-cem's `_families` brand config, read
  by `core/elm-cem/bin/gen-family-package.js` (`Reads config _families … dependencies: pkg.deps`) to
  **generate** the family packages' `elm.json` dependency blocks — i.e. it is the SOURCE of the
  `elm-m3e-families/elm.json:36` + `elm-m3e-icons/elm.json:16` IR deps above. If `slots.json`'s IR dep key
  is not renamed, regenerating the family packages (Task 4 / any `regen`) **re-emits the OLD IR name**,
  silently undoing the finding-A2 `elm.json` edits. Rename both keys with **Task 4** (paired with the
  elm-m3e family regen it feeds), or at latest before the first post-rename family regen. (Its sibling keys
  `jackhp95/elm-m3e-core`/`elm-m3e-components` are the deferred 5-package names — out of scope; only the IR
  key renames.) **This is the one genuinely-mis-placed hit the earlier `grep → zero` caveat ("only Task-4
  dependents may still carry the old name") did not cleanly cover — it is neither Task-1-moved nor an
  elm-m3e-internal file. Flagged in the Rename-sweep verification.**
- **NEW — `brands/m3e/outputs/elm-m3e/packages.json:16,73,91,116` (Task 4):** the deferred 5-package-shape
  file (finding N moved only its *path* in `check-m3e-5pkg.mjs`; its four IR dep keys rename here too).
- **NEW — `brands/m3e/outputs/elm-m3e/measure-docs.cjs:96` (Task 4):** IR published name in a name array.
  Its `L8` hard-coded absolute path (`/Users/jack/.paseo/worktrees/04t0kwkn/elm-html-intermediate-representation/src`)
  is a **stale dead worktree path** — cosmetic; clean up or delete the file (unreferenced by any gate —
  verified) in Task 6.

### A3. Rename-identity: table keys, load-bearing name/step-name assertions, and the mirror carve-out (verified 2026-08-19 — new; supersedes the earlier "keep keys" flag)

Per the resolved rename-all-keys policy (finding A note + Decisions log), these are **every** local
spot that carries `cem-figma-connect` or `elm-html-intermediate-representation` as a lookup key, name
comparison, or asserted step-name — each must move to the new name in lockstep or a gate silently
mis-resolves. Re-grepped from current file contents this session (`grep -rn` across `tools/`).

**`cem-figma-connect` → `elm-cem-figma-connect` (Task 1):**

| File:line | Current | New | Why load-bearing |
|---|---|---|---|
| `tools/family.json:147` | key `"cem-figma-connect"` | `"elm-cem-figma-connect"` | table key; `gate-all.mjs:426` builds the `copy-fidelity <key>` step name straight from `Object.keys(family)` |
| `tools/family.json:158` | `.cache/snapshots/cem-figma-connect` | `.cache/snapshots/elm-cem-figma-connect` | local snapshot cache path; must track the `snapshot-refs.json` key (below) in lockstep |
| `tools/lib/consumer-output-drift.mjs:46` | `familySrcDir(repoRoot, "cem-figma-connect")` | `"elm-cem-figma-connect"` | **the arg is a literal `family.json`-key lookup** — must equal the new key or `pkgDir` resolves `undefined` |
| `tools/lib/consumer-output-drift.mjs:44,45` | descriptor `key: "cem-figma-connect"` + its `label` | `elm-cem-figma-connect` | descriptor key is looked up by literal in `check-drift.test.mjs:128` |
| `tools/check-drift.test.mjs:128` | `for (const key of ["cem-figma-connect", …])` | `"elm-cem-figma-connect"` | must equal the renamed descriptor key (`descriptorsByKey[key]` else `undefined`) |
| `tools/bump.mjs:41` | `pkgName: "cem-figma-connect"` | `"elm-cem-figma-connect"` | **`bump.mjs:336-337` runs `pnpm --filter ${pkgName} run gen:facts`** — the filter is the `package.json` `name`, which the base rename already changes; unchanged here → filter matches nothing |
| `tools/gate-all.mjs:434` | step label `"workspace: check-emit-determinism cem-figma-connect"` | `…elm-cem-figma-connect` | hardcoded step name asserted in `gate-all-expected-steps.json:33` |
| `tools/gate-all-expected-steps.json:10,11` | `"cem-figma-connect: check"`, `": test"` | `"elm-cem-figma-connect: check/test"` | **asserted by `check-gate-all-step-membership.test.mjs`** (the "no silent skip" invariant); step names derive from `package.json` `name` |
| `tools/gate-all-expected-steps.json:32` | `"workspace: copy-fidelity cem-figma-connect"` | `…elm-cem-figma-connect` | derives from the `family.json` key (gate-all.mjs:426) |
| `tools/gate-all-expected-steps.json:33` | `"workspace: check-emit-determinism cem-figma-connect"` | `…elm-cem-figma-connect` | matches the `gate-all.mjs:434` literal above |
| `tools/snapshot-refs.json:8` | key `"cem-figma-connect"` | `"elm-cem-figma-connect"` | **KEY only** — read by `fetch-snapshots.mjs` to materialize `.cache/snapshots/<key>` (local); its `repo` URL VALUE is a mirror → **keep unchanged** (see carve-out) |
| `tools/check-cc-elm-refs.mjs:46` | `"cem-figma-connect"` (a path segment in the `CC_ELM_DIR` list) | `"elm-cem-figma-connect"` | path built by joining segments; finding H's L45 `core`→`pipeline` swap is **not enough** — this sibling segment renames too |
| `tools/check-elm-shape-drift.mjs:132` | descriptor `name: "cem-figma-connect (elm emitter)"` | `"elm-cem-figma-connect (elm emitter)"` | descriptor identity label (path L133 already in finding G) |
| `tools/measure-docs-size.mjs` | (no cfc entry) | — | n/a |
| `tools/family.json:174` | `authorizedAbsentM6` `".claude-memory/cem-figma-connect-state.md"` | `".claude-memory/elm-cem-figma-connect-state.md"` | **RENAME (Step 1.7e) — MIRROR-COUPLED.** `authorizedAbsent*` describes an external-cfc-mirror file (`copy-fidelity.mjs:115` compares against the `snapshot-refs.json` mirror snapshot). Gate SKIPs when the snapshot is absent (normal gate-all) → safe to rename now; a materialized-snapshot run flags it `missing` until the mirror's file renames too. Paired-rename flag in Decisions log. |
| `tools/family.json:171` | `authorizedAbsentPrefixes` `"test/fixtures/tailwind-m3e-web-0.1.0/"` | `"test/fixtures/elm-m3e-tailwind-0.1.0/"` | **RENAME (Step 1.7e) — MIRROR-COUPLED**, same class as L174 (version `0.1.0` unchanged; sibling `"test/fixtures/m3e-web-2.7.0/"` = upstream `@m3e/web`, **unchanged**). |

**`elm-html-intermediate-representation` → `elm-virtual-dom-intermediate-representation` (Task 1):**

| File:line | Current | New | Why load-bearing |
|---|---|---|---|
| `tools/family.json:84` | key `"elm-html-intermediate-representation"` | `"elm-virtual-dom-intermediate-representation"` | table key (srcDir at L85 already in finding A) |
| `tools/gate-all-expected-steps.json:16,17` | `"elm-html-intermediate-representation: check/test"` | `"elm-virtual-dom-intermediate-representation: check/test"` | asserted by `check-gate-all-step-membership.test.mjs`; derives from `elm.json` `name` |
| `tools/measure-docs-size.mjs:76` | **key** `"jackhp95/elm-html-intermediate-representation":` | `"jackhp95/elm-virtual-dom-intermediate-representation":` | **published-name lookup key** (its value/path is finding K's L77) — the published name renames in finding A2, so this key must too |
| `core/elm-cem/elm-html-intermediate-representation` (symlink) | alias name `elm-html-intermediate-representation` | `elm-virtual-dom-intermediate-representation` | symlink NAME rename (finding S #1) + exclusion glob (finding R / Step 1.6) |

**The family.json key ↔ mirror-target coupling (important — determines what's safe):** the mirror repo
URL is derived by *convention* `https://github.com/jackhp95/${name}.git`, where `name` is:
- in the **manual** `publish-mirror.mjs` (L150–238) — the **`family.json` top-level key** (CLI arg,
  validated against `FAMILY[name]`); and
- in the **automated** `check-mirror-drift.mjs` (L37,58,82) — the **`publish-mirror-state.json` key**
  (`Object.keys(state)`), a *separate* store holding only 7 packages.

So renaming a `family.json` key is **safe for every automated gate in `gate-all`** — no automated gate
derives a mirror URL from the `family.json` key (copy-fidelity uses the key only for the *local*
`.cache/snapshots/<key>` compare + step name; `check-mirror-drift` reads `publish-mirror-state.json`, not
`family.json`). The *only* consumer of `jackhp95/${family-key}` is the **manual, gated** `publish-mirror.mjs`
— which is exactly the deliberate publishing action during which Jack renames the external mirror to match.
That makes the `family.json` key rename correct-by-construction: local gates go green now; the manual
mirror push targets the new name precisely when the external mirror is (explicitly) renamed. **This is the
resolution — rename the `family.json` keys.**

**Mirror carve-out — DO NOT rename (Jack's mirror exception; NOT "blast radius be damned"):**

- `tools/publish-mirror-state.json:28` — key `"elm-html-intermediate-representation"` **stays**. The
  briefing assumed this was "pure local bookkeeping, no URL to preserve"; **verified false this session** —
  `check-mirror-drift.mjs:37,82` reads `state[name]` and reports drift against `jackhp95/${name}`, and
  `check-mirror-drift.mjs:23` derives the *external* mirror repo as `jackhp95/${name}`. This gate runs in
  `gate-all` (against the 7 stateful packages), so renaming this key would point an **automated** gate at a
  **nonexistent** `jackhp95/elm-virtual-dom-intermediate-representation` and turn a currently-known state
  into a hard 404. It is a mirror-tracking identity → stays until the live external mirror is itself
  renamed (Jack's explicit per-mirror go, precedent: `m3e-okf`, Decisions log #3). Consequence: for IR,
  `family.json` key = **new**, `publish-mirror-state.json` key = **old**, until the mirror rename — each
  serves its correct master (local gates vs. automated mirror-drift). **Flag surfaced in Decisions log.**
  (No `cem-figma-connect` key exists in this file — verified; the 7 keys are elm-cem, elm-m3e,
  elm-cem-facts, elm-review-cem, elm-typed-html, elm-html-intermediate-representation, elm-cem-compose —
  so cfc/okf/tailwind have no `publish-mirror-state.json` entry and this carve-out only bites IR.)
- `tools/snapshot-refs.json:8` — the `repo` VALUE `https://github.com/jackhp95/cem-figma-connect.git`
  and its `sha` **stay** (mirror URL). Only the containing KEY renames (row above). The KEY is safe to
  rename because `snapshot-refs.json` is read *only* by `fetch-snapshots.mjs` (local `.cache/snapshots/<key>`
  materialization) — it does **not** feed any `jackhp95/${name}` derivation, unlike `publish-mirror-state.json`.
- `tools/family.json` `mirror`/`bundleCopy`/`copyFidelity` blocks — their repo coordinates stay (already
  out of scope per "Out of scope → Publishing/mirror rewiring").

**RESOLVED 2026-08-19 (was "flagged, does-not-cleanly-resolve"):** `tools/check-coverage-map.mjs:33-38`
`REQUIRED_CONSUMERS` (`"m3e-okf"`, `"tailwind-m3e-web"`, `"cem-figma-connect-matcher"`,
`"cem-figma-connect-elm-emitter"`) + the 146 matching `"consumer"` values (+ 10 prose spots) in
`docs/facts-bundle/coverage-map.json` all **rename** — see **Step 1.7d** for the exact array before/after
and the three-rule substring convention. Correction to the earlier flag: `check-coverage-map.mjs` **is**
gate-all-wired (`gate-all.mjs:403`), so the array ↔ JSON pair is load-bearing for automated gate-all and
must rename in lockstep — it is **not** "separate facts-bundle scope." No mirror/URL is involved, so no
carve-out. The audit *prose* (coverage-audit.md, scorecard, diffs, schema.json descriptions) is
non-gate-read → batched to Task 6 (finding V), same names.

### B. `tools/gate-all.mjs` (verified)

- L68: `const ELM_M3E = process.env.ELM_M3E || path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e");` → `"brands", "m3e", "generated", "package", "elm-m3e"` (**Task 4**).
- L195: discovery fallback walk `walk(path.join(repoRoot, "core"));` (+ `walk(repoRoot/"brands")`, `walk(repoRoot/"packages"/"_probe")` nearby) → replace `"core"` with `"pipeline"` and add a `walk(repoRoot/"packages")` (**Task 1**). `pnpm ls -r` is the primary discovery; this walk is the fallback — but keep it correct.
- L268: `require(path.join(repoRoot, "core", "elm-cem", "bin", "validate-facts-bundle.js"))` → `"pipeline", "elm-cem", …` (**Task 1**).

### C. `tools/check-drift.mjs` (verified)

- L55: `const ELM_M3E = … path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e");` → `generated/package/elm-m3e` (**Task 4**).
- L90: `require(path.join(repoRoot, "core", "elm-cem", "bin", "validate-facts-bundle.js"))` → `"pipeline", "elm-cem", …` (**Task 1**).
- L176: `const relPath = "brands/m3e/outputs/elm-m3e/docs/.elm-pages/Pages.elm";` → interim `brands/m3e/generated/package/elm-m3e/docs/.elm-pages/Pages.elm` (**Task 4**), then final `brands/m3e/generated/docs/elm-m3e-docs/.elm-pages/Pages.elm` (**Task 5**). Double-edit (docs un-nests in Task 5).

### D. `tools/check-drift.test.mjs` (verified)

- L20: `… path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e");` → `generated/package/elm-m3e` (**Task 4**).
- L21: `const realCommittedCemFacts = path.join(repoRoot, "brands", "m3e", "outputs", "m3e-api-okf", "data", "cem-facts.json");` → `"brands", "m3e", "generated", "okf", "elm-m3e-okf", "data", "cem-facts.json"` (**Task 3**).

### E. `tools/bump.mjs` (verified)

- L27–28: `import … from "../core/cem-figma-connect/src/tokens/{classify-delta,token-change-report}.mjs";` → `"../pipeline/elm-cem-figma-connect/…"` (**Task 1**).
- **L41: `pkgName: "cem-figma-connect"` → `"elm-cem-figma-connect"` (**Task 1**, finding A3).** Load-bearing:
  `bump.mjs:336-337` runs `pnpm --filter ${pkgName} run gen:facts`, so `pkgName` **is** the `package.json`
  `name` — the base rename changes the name, so an un-updated `pkgName` filters nothing. **Sibling
  `pkgName` entries in the same `CONSUMERS` array are the same class and were missed by the earlier
  sweep:** L48 `pkgName: "m3e-okf"` → `"elm-m3e-okf"` (**Task 3**), L52 `pkgName: "tailwind-m3e-web"` →
  `"elm-m3e-tailwind"` (**Task 2**) — fixed in their respective tasks, flagged in the final report.
- L34: `const ELM_M3E = path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e");` → `generated/package/elm-m3e` (**Task 4**).
- L35: `const PAGES_ELM_REL = "brands/m3e/outputs/elm-m3e/docs/.elm-pages/Pages.elm";` → interim `…/generated/package/elm-m3e/docs/…` (**Task 4**), then `…/generated/docs/elm-m3e-docs/.elm-pages/Pages.elm` (**Task 5**). Double-edit.
- L43–44: `path.join(repoRoot, "core", "cem-figma-connect", "profiles", …)` (×2) → `"pipeline", "elm-cem-figma-connect", …` (**Task 1**).
- L49: `path.join(repoRoot, "brands", "m3e", "outputs", "m3e-api-okf", "data", "cem-facts.json")` → `generated/okf/elm-m3e-okf/…` (**Task 3**).
- L53: `path.join(repoRoot, "brands", "m3e", "outputs", "tailwind-m3e-web", "data", "cem-facts.json")` → `generated/style/elm-m3e-tailwind/…` (**Task 2**).
- L318: `path.join(repoRoot, "brands", "m3e", "outputs", "tailwind-m3e-web", "package.json")` → `generated/style/elm-m3e-tailwind/package.json` (**Task 2**).

### F. `tools/gen-hooks.mjs` (verified — the 7-entry pre-push target list, L40–48)

- L40–41: `core/elm-cem/hooks/pre-push`, `core/elm-cem/templates/pre-push` → `pipeline/elm-cem/…` (**Task 1**).
- L42: `core/elm-html-intermediate-representation/hooks/pre-push` → `packages/elm-virtual-dom-intermediate-representation/hooks/pre-push` (**Task 1**).
- L43: `core/elm-review-cem/hooks/pre-push` → `pipeline/elm-review-cem/…` (**Task 1**).
- L44: `core/elm-typed-html/hooks/pre-push` → `brands/html/generated/package/elm-typed-html/hooks/pre-push` (**Task 1**).
- L45: `brands/m3e/outputs/m3e-api-okf/hooks/pre-push` → `brands/m3e/generated/okf/elm-m3e-okf/hooks/pre-push` (**Task 3**).
- L46: `core/cem-figma-connect/hooks/pre-push` → `pipeline/elm-cem-figma-connect/…` (**Task 1**).
- L48: `const ELM_M3E_TARGET = "brands/m3e/outputs/elm-m3e/hooks/pre-push";` → `generated/package/elm-m3e/hooks/pre-push` (**Task 4**).

### G. `tools/check-elm-shape-drift.mjs` (verified)

- L48: `} from "../core/elm-cem/src/elm-shape.mjs";` → `"../pipeline/elm-cem/src/elm-shape.mjs"` (**Task 1**).
- L132: descriptor `name: "cem-figma-connect (elm emitter)"` → `"elm-cem-figma-connect (elm emitter)"` (**Task 1**, finding A3 — identity label).
- L133: `file: "core/cem-figma-connect/profiles/m3-kit/emitters/elm.mjs",` → `"pipeline/elm-cem-figma-connect/…"` (**Task 1**).
- L142: `file: "brands/m3e/outputs/elm-m3e/docs/scripts/examples-gen/lib/to-elm.mjs",` → interim `…/generated/package/elm-m3e/docs/…` (**Task 4**), then `…/generated/docs/elm-m3e-docs/scripts/examples-gen/lib/to-elm.mjs` (**Task 5**). Double-edit.

### H. `tools/check-cc-elm-refs.mjs` (verified)

- L38: `path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e", "src")` → `generated/package/elm-m3e/src` (**Task 4**).
- L39: `path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e", "docs", "vendor", "elm-foundation")` → interim `generated/package/elm-m3e/docs/vendor/elm-foundation` (**Task 4**), then `generated/docs/elm-m3e-docs/vendor/elm-foundation` (**Task 5**). Double-edit.
- L45–46: the `CC_ELM_DIR` list builds `core/cem-figma-connect/generated/m3-kit/elm` from **two** literal
  segments — L45 `"core"` → `"pipeline"` **and L46 `"cem-figma-connect"` → `"elm-cem-figma-connect"`
  (finding A3)**. Read L44–49 in full and swap **both** segments (the earlier sweep noted only the
  `core`→`pipeline` one).

### I. `tools/gen-figma-config.mjs` (verified)

- L46: `const cfcDir = path.join(repoRoot, "core", "cem-figma-connect");` → `"pipeline", "elm-cem-figma-connect"` (**Task 1**).
- The `elm-m3e` config dir is resolved via the `elm-m3e` path; when `elm-m3e` relocates (Task 4) grep this file again for any `brands/m3e/outputs/elm-m3e` literal and swap to `generated/package/elm-m3e`. (Comment refs at L9, L23 are cosmetic — Task 6.)

### J. `tools/ab-elm-cem.sh` / `tools/ab-elm-m3e-split.sh` (verified)

- `ab-elm-cem.sh` L25: `WORKSPACE_ELM_CEM="$REPO_ROOT/core/elm-cem"` → `"$REPO_ROOT/pipeline/elm-cem"` (**Task 1**). L26: `ELM_M3E="${ELM_M3E:-$REPO_ROOT/brands/m3e/outputs/elm-m3e}"` → `generated/package/elm-m3e` (**Task 4**).
- `ab-elm-m3e-split.sh` L42: same `WORKSPACE_ELM_CEM` fix (**Task 1**). L43: same `ELM_M3E` fix (**Task 4**).

### K. `tools/measure-docs-size.mjs` (verified)

- L76: the **map key** `"jackhp95/elm-html-intermediate-representation":` → `"jackhp95/elm-virtual-dom-intermediate-representation":` (**Task 1**, finding A3 — this table is keyed by published Elm name, which renames in finding A2).
- L77: `process.env.IR_SRC || path.join(ROOT, "core/elm-html-intermediate-representation/src")` → `"packages/elm-virtual-dom-intermediate-representation/src"` (**Task 1**).
- L78: `process.env.FACTS_SRC || path.join(ROOT, "core/elm-cem/facts/src")` → `"pipeline/elm-cem/facts/src"` (**Task 1**).
- L81: `const DEFAULT_TARGETS = ["brands/m3e/outputs/elm-m3e/elm-m3e-icons"];` → `["brands/m3e/generated/package/elm-m3e/elm-m3e-icons"]` (**Task 4**).

### L. `tools/check-emit-determinism-cfc.mjs` (verified)

- L39: `const pkgDir = path.join(repoRoot, "core", "cem-figma-connect");` → `"pipeline", "elm-cem-figma-connect"` (**Task 1**).

### M. `tools/check-single-cem-facts.mjs` (verified — NOT in the old plan; new gap)

- L86–88: `SEARCH_ROOTS = [ join(repoRoot, "core"), join(repoRoot, "brands"), join(repoRoot, "packages", "_probe") ]` → replace `"core"` with `"pipeline"`; add `join(repoRoot, "packages")` so the new top-level `packages/` is walked (**Task 1**). (The IR/tonal packages have no `Cem/Facts.elm`, but the walk should be complete and future-proof.)

### N. `tools/check-m3e-5pkg.mjs` (verified — NOT in the old plan; new gap)

- L6: `readFileSync(new URL("../brands/m3e/outputs/elm-m3e/packages.json", import.meta.url))` → `"../brands/m3e/generated/package/elm-m3e/packages.json"` (**Task 4**). (This gate asserts the *deferred* 5-package `packages.json` shape — the assertion stays, only the path moves.)

### O. `tools/lib/gen-facts-runner.mjs` (verified)

- L35: `const elmM3e = process.env.ELM_M3E || path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e");` → `generated/package/elm-m3e` (**Task 4**).

### P. `tools/lib/regen.mjs` (verified)

- L34: `path.join(repoRoot, "core", "elm-cem", "bin", "elm-cem.js")` → `"pipeline", "elm-cem", …` (**Task 1**).
- L38: `process.env.ELM_M3E || path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e")` → `generated/package/elm-m3e` (**Task 4**).

### Q. `tools/install-toolchains.mjs` (verified)

- L54: `scanFor(path.join(repoRoot, "core"), 1);` → `scanFor(path.join(repoRoot, "pipeline"), 1);` and add `scanFor(path.join(repoRoot, "packages"), 1);`. The `scanFor(repoRoot/"brands", 3)` call already covers `brands/<brand>/<phase>/<pkg>` at depth 3 — but the new `generated/` layer nests packages one level **deeper** (`brands/m3e/generated/package/elm-m3e` = depth 3 *below `brands/`*: `generated`, `package`, `elm-m3e`). Verify the `depth` arg reaches `generated/*/*`; bump to `scanFor(repoRoot/"brands", 3)` covering `<brand>/generated/<phase>` → still 3 segments below `brands`, OK; but nested `elm-m3e-families` is 4 deep — the walk only needs `elm-tooling.json` holders, and only the top package dirs have those, so depth 3 suffices. **Confirm by inspection + the Task-1/Task-4 gate runs** (**Task 1** for the `core`→`pipeline`+`packages` part; re-verify in **Task 4** for `generated/`).

### R. `pnpm-workspace.yaml` (verified — current content)

Current globs: `packages/_probe/*`, `core/*`, `brands/*/inputs/*`, `brands/*/inputs/*/*`,
`brands/*/outputs/*`, `brands/*/outputs/*/*`, exclusions `!**/node_modules`, `!**/elm-stuff`,
`!core/*/elm-html-intermediate-representation`. Target end-state globs (reached additively in
Task 0, old ones dropped as dirs empty out):

```yaml
packages:
  - "packages/_probe/*"
  - "packages/*"                 # NEW — top-level foundational libs (IR, tonal)
  - "pipeline/*"                 # NEW — machinery (elm-cem, compose, review-cem, cfc, elm-cem-tailwind)
  - "brands/*/inputs/*"          # material-okf
  - "brands/*/generated/*/*"     # NEW — generated/{package,style,okf,docs}/<pkg>
  - "brands/*/generated/*/*/*"   # NEW — nested elm-m3e-families / elm-m3e-icons under generated/package/elm-m3e
  - "!**/node_modules"
  - "!**/elm-stuff"
  - "!pipeline/*/elm-virtual-dom-intermediate-representation"   # the elm-cem IR symlink, renamed alias (was !core/*/elm-html-intermediate-representation)
```

Note: `brands/*/outputs/*` today ALSO matches `brands/m3e/outputs/elm-m3e/docs` (via
`brands/*/outputs/*/*`) — that is how the docs package (`name: m3e-builder-docs`, verified)
is discovered today. The `brands/*/generated/*/*` glob covers `elm-m3e-docs` after Task 5.

### S. Symlinks (verified — 2 exist, both need retargeting)

1. `core/elm-cem/elm-html-intermediate-representation -> ../elm-html-intermediate-representation`
   → moves with `elm-cem` to `pipeline/elm-cem/…`; IR moves to `packages/` **and is renamed**.
   **Rename the symlink itself AND retarget** (resolved 2026-08-19 — no old name survives): new alias
   name `pipeline/elm-cem/elm-virtual-dom-intermediate-representation`, target
   `../../packages/elm-virtual-dom-intermediate-representation` (**Task 1**). **Verified this session:**
   *no* `elm.json` `source-directories` under `core/elm-cem` consumes the alias name (the earlier
   "renaming forces `source-directories` edits" concern is **not borne out** — the two IR test-elm.json
   refs use the sibling `core/`→`packages/` path, retargeted in finding T, not the alias; `elm-cem` has
   no root `elm.json`). So the alias rename is a symlink-name + exclusion-glob change only. The exclusion
   glob (item R) tracks the **new** alias: `!pipeline/*/elm-virtual-dom-intermediate-representation`.
   Grep `core/elm-cem` for the old alias at execution time to confirm zero remaining consumers.
2. `brands/m3e/outputs/elm-m3e/config -> ../../inputs/cem/config` → moves with `elm-m3e` to
   `brands/m3e/generated/package/elm-m3e/config`. Retarget `../../inputs/cem/config` →
   `../../../inputs/cem/config` (+1 segment; **Task 4**).

### T. Package-internal cross-boundary relative refs (verified)

**`core/elm-typed-html` (→ `brands/html/generated/package/elm-typed-html`, +3 depth) — Task 1:**
- `scripts/regen.sh` L7: `ELM_CEM_BIN="${ELM_CEM_BIN:-../elm-cem/bin/elm-cem.js}"` (resolves to `core/elm-cem` today) → `../../../../../pipeline/elm-cem/bin/elm-cem.js`. Also references `$REPO_ROOT/manifest/native.cem.json`, `$REPO_ROOT/config/config.json`, `$REPO_ROOT/src` — all package-internal (`REPO_ROOT` computed from `$0`), so they follow the package move automatically. **But `config/config.json` physically relocates to `brands/html/inputs/config.json`** — update the `--config-from` arg to point there (`$REPO_ROOT/../../../inputs/config.json` from `brands/html/generated/package/elm-typed-html`, i.e. 3 up to `brands/html`, then `inputs/config.json`). See Task 1 Step for exact value.
- `scripts/validate.mjs` L62: `path.resolve(repoRoot, "../elm-html-intermediate-representation/src")` → `path.resolve(repoRoot, "../../../../../packages/elm-virtual-dom-intermediate-representation/src")`. L75: `path.resolve(repoRoot, "../elm-cem/facts/src")` → `path.resolve(repoRoot, "../../../../../pipeline/elm-cem/facts/src")`.
- `package.json` L20: `"hooks:install": "node ../../tools/hooks-install.mjs"` → `"node ../../../../../tools/hooks-install.mjs"`.
- `review/elm.json` L5–8 (`source-directories`): `../src` (package-internal, keep), `../../elm-review-cem/src` → `../../../../../../pipeline/elm-review-cem/src`, `../../elm-cem/facts/src` → `../../../../../../pipeline/elm-cem/facts/src`, `../../elm-html-intermediate-representation/src` → `../../../../../../packages/elm-virtual-dom-intermediate-representation/src`. (From `review/` at depth 6: 6 `../` reaches root.)
- `verify/elm.json` L3 (`source-directories`): `[ "src", "bad", "../src", "../../elm-html-intermediate-representation/src", "../../elm-cem/facts/src" ]` → keep `src`/`bad`/`../src`; `../../elm-html-intermediate-representation/src` → `../../../../../../packages/elm-virtual-dom-intermediate-representation/src`; `../../elm-cem/facts/src` → `../../../../../../pipeline/elm-cem/facts/src`. (`verify/` at depth 6.)

**`core/elm-cem` (→ `pipeline/elm-cem`, depth unchanged) — Task 1** (IR leaves `core/` for `packages/`, so its sibling refs break):
- `tests/phantom/native/acid/elm.json` L7: `../../../../../elm-html-intermediate-representation/src` (5 `../` from that dir reaches `core/`) → `../../../../../../packages/elm-virtual-dom-intermediate-representation/src` (+1 `../` to reach root, then `packages/` + renamed dir). Dir `pipeline/elm-cem/tests/phantom/native/acid` is depth 6; 6 `../` reaches root.
- `tests/phantom/acid/elm.json` L7: `../../../../elm-html-intermediate-representation/src` (4 `../` reaches `core/`) → `../../../../../packages/elm-virtual-dom-intermediate-representation/src` (+1 + renamed dir). Dir depth 5.
- Grep `core/elm-cem` (now `pipeline/elm-cem`) for any other `elm-html-intermediate-representation` relative ref before committing; the two above are the ones that cross the `core/`→`packages/` boundary this session's sweep found. (Each such ref's target dir also picks up the `elm-html-…`→`elm-virtual-dom-…` rename.)

**`brands/m3e/outputs/tailwind-m3e-web` (→ `generated/style/elm-m3e-tailwind`, +1 depth) — Task 2:**
- `bin/generate-component-utilities.mjs` L40: `} from "../../../../../tools/lib/component-css-utilities.mjs";` — **this dependency moves INTO the package** (see Task 2, item 3b) → becomes a package-local import (e.g. `"../src/component-css-utilities.mjs"` or `"../lib/…"`, per where it lands). If for any reason it stays in `tools/lib`, the depth fix is +1 → `"../../../../../../tools/lib/…"`.
- `scripts/gen-facts.mjs` L16: `import { runGenFacts } from "../../../../../tools/lib/gen-facts-runner.mjs";` → **`gen-facts-runner.mjs` STAYS in `tools/lib` (shared, see finding U)** → +1 depth → `"../../../../../../tools/lib/gen-facts-runner.mjs"`.

**`brands/m3e/outputs/m3e-api-okf` (→ `generated/okf/elm-m3e-okf`, +1 depth) — Task 3:**
- `scripts/check-skills-meta.mjs` L19: `import … from "../../../../../tools/lib/okf-lib.mjs";` → `"../../../../../../tools/lib/okf-lib.mjs"` (+1).
- `scripts/gen-facts.mjs` L17: `import { runGenFacts } from "../../../../../tools/lib/gen-facts-runner.mjs";` → `"../../../../../../tools/lib/gen-facts-runner.mjs"` (+1).
- Re-grep the whole package for `../../../../../tools` and any `../../../../../` cross-package ref before committing — apply +1 uniformly.
- `package.json` `hooks:install` (`node ../../../../tools/hooks-install.mjs`, depth 4) → `node ../../../../../tools/hooks-install.mjs` (depth 5).

**`brands/m3e/outputs/elm-m3e` (→ `generated/package/elm-m3e`, +1 depth) — Task 4** (non-docs refs; the whole `docs/` subtree moves *with* elm-m3e here and is extracted separately in Task 5):
- `package.json` `hooks:install` and any `../../../../tools` refs → +1.
- `review/elm.json` `source-directories` (verified L8 has `../../../../../core/elm-html-intermediate-representation/src`): this is the elm-m3e package's own review project. `core/`→ split (`elm-cem`/`elm-review-cem`→`pipeline`, IR→`packages`) already happened in Task 1, so by Task 4 these literals read `pipeline/`/`packages/` — apply the **+1 depth** (`../../../../../` → `../../../../../../`) to each entry. **Re-read this file at Task 4 time** (its content will already reflect Task 1's `core`→`pipeline`/`packages` rename).
- The `config` symlink retarget (finding S #2).
- Re-grep `brands/m3e/outputs/elm-m3e` (excluding `docs/`) for every `../../../../../` and `pipeline/`/`packages/` relative ref; apply +1.

### U. `tools/lib/` absorption analysis (verified — finding, resolves item 3b)

Read `tools/lib/` in full. Two files are candidates to pull into `pipeline/elm-cem-tailwind`:

- **`component-css-utilities.mjs`** — the generic Face-B (CEM facts) → Tailwind utilities
  generator. **Only ONE consumer:** `tailwind-m3e-web/bin/generate-component-utilities.mjs:40`
  (verified via repo-wide grep). → **Move it into `pipeline/elm-cem-tailwind`** (Task 2). It
  is genuinely tailwind-exclusive agnostic codegen.
- **`gen-facts-runner.mjs`** — **THREE consumers** (verified): `tailwind-m3e-web/scripts/gen-facts.mjs:16`,
  `m3e-api-okf/scripts/gen-facts.mjs:17`, AND `core/cem-figma-connect/scripts/gen-facts.mjs:18`.
  It is a **shared** facts-generation runner, not tailwind-specific. → **Leave it in `tools/lib`.**
  Moving it into `elm-cem-tailwind` would break the m3e-okf and cem-figma-connect imports.
  (This is a mild divergence from item-3b's phrasing, which grouped "gen-facts-runner's
  tailwind-relevant path" with the absorb — the grep shows it is shared substrate. **Confirmed live**
  (Decisions log #4): leave it in `tools/lib` and add a deprecation comment there — Task 2 Step 2.3b.)

### V. Cosmetic-only prose/comment references (Task 6, non-blocking)

`tools/gen-hooks.mjs:8`, `tools/check-single-cem-facts.mjs:5,65`, `tools/install-toolchains.mjs:8`,
`tools/publish-mirror.mjs:274`, `tools/gen-figma-config.mjs:3,5,7,20,9,23`, `tools/check-cc-elm-refs.mjs:6`,
`tools/check-elm-shape-drift.mjs:5`, `tools/ab-elm-cem.sh:12`, `tools/ab-elm-m3e-split.sh:6,30`,
`tools/gate-all.mjs:44`, `tools/check-single-cem-facts.mjs:26,28`, `tools/check-drift.mjs:8,35`,
`tools/lib/check-drift-core.mjs:49,70,293`, `tools/lib/consumer-output-drift.mjs:72`,
`tools/check-drift.test.mjs:110`, `tools/lib/regen.mjs:9,10` — all mention old `core/…` or
`brands/m3e/outputs/…` paths **in comments only**. Batched to Task 6; anything functional
would already have failed a gate run.

**Cosmetic-comment spots carrying the renamed *names* (added 2026-08-19 final sweep — comment-only, not in
the earlier V list):** `tools/check-single-m3e-web-pin.mjs:7` (`// output (cem-figma-connect).`),
`tools/copy-fidelity.mjs:4` (`// tools/copy-fidelity-{cem-figma-connect,elm-m3e,m3e-okf,tailwind-m3e-web}.sh`),
`tools/lib/okf-lib.mjs:5` (`// depending on either m3e-okf half.`), `tools/publish-mirror.test.mjs:5`
(package-list comment incl. `elm-html-intermediate-representation`), `hooks/pre-push:6-9` (consolidated-hook
header comment listing all package names — this file is **regenerated** by `gen-hooks.mjs`, so it re-emits
from the renamed targets on the next `gen:hooks`; the checked-in comment is cosmetic), `hooks/pre-push.d/README.md:33`
(prose). Batched to Task 6.

**Facts-bundle audit *prose* (non-gate-read; Task 6 "no whiff" sweep — same three substring rules as Step
1.7d):** `docs/facts-bundle/coverage-audit.md` (46), `docs/facts-bundle/m3-consumer-scorecard.md` (35),
`docs/copy-fidelity-notes.md` (22), `docs/facts-bundle/m6-deep-clean.md` (7), `docs/facts-bundle/schema.json`
(6, all `"description"` fields — L116/162/194/242/253/401, **not** enum/property keys, so not load-bearing
for `check-coverage-map.mjs`), `docs/facts-bundle/m3c-generated-diff.md` (5),
`docs/facts-bundle/m3a-`/`m3b-generated-diff.md` (2 each). (The load-bearing `coverage-map.json` entries
+ `check-coverage-map.mjs` array are **not** here — they are Step 1.7d.)

### W. Verified NO-CHANGE

- `.github/workflows/ci.yml` — runs `node tools/gate-all.mjs`, no package paths.
- `tailwind-md3` → `elm-cem-tailwind` internal: `bin/calibrate-tones.mjs:20`
  `import { averageLPerTone } from "tonal-palette-oklch";` is a **bare workspace-name**
  import — depth-independent; survives `tonal-palette-oklch`'s move to `packages/` and
  `tailwind-md3`'s rename with zero edits.
- `tailwind-md3`/`elm-cem-tailwind` `hooks:install` (`node ../../tools/hooks-install.mjs`,
  depth 2) — rename keeps it depth-2, unchanged.
- `elm-m3e-families/elm.json` and `elm-m3e-icons/elm.json` — published-package `elm.json`s
  with dependency-by-name, **no relative `source-directories`** (verified) → move cleanly
  nested inside `elm-m3e` with zero path edits.

---

## Task 0: Baseline safety — additive `pnpm-workspace.yaml` globs

**Model tier (informational):** sonnet / low.

**Files:** Modify `pnpm-workspace.yaml`.

- [ ] **Step 0.1: Add new globs alongside the old ones (superset — new dirs don't exist yet, so a no-op)**

```yaml
packages:
  - "packages/_probe/*"
  - "packages/*"
  - "pipeline/*"
  - "core/*"
  - "brands/*/inputs/*"
  - "brands/*/inputs/*/*"
  - "brands/*/outputs/*"
  - "brands/*/outputs/*/*"
  - "brands/*/generated/*/*"
  - "brands/*/generated/*/*/*"
  - "!**/node_modules"
  - "!**/elm-stuff"
  - "!core/*/elm-html-intermediate-representation"

allowBuilds:
  '@parcel/watcher': true
  elm: true
  elm-format: true
  esbuild: true
  lamdera: true

minimumReleaseAgeExclude:
  - '@m3e/web@2.5.13'
```

- [ ] **Step 0.2: Verify no-op**

Run: `pnpm install && node tools/gate-all.mjs` → expect identical `GATE-ALL GREEN` (new globs
match nothing yet). Note the pre-existing baseline (per the old plan, `workspace:
check-mirror-drift` is a known-unrelated pre-existing failure — confirm the same set of
green/known-fail items before and after).

- [ ] **Step 0.3: Commit**

```bash
git add pnpm-workspace.yaml
git commit -m "chore(workspace): add pipeline/+packages/+generated/ globs ahead of repo-shape-v2 wave-1 moves"
```

---

## Task 1: Foundation — `core/`→`pipeline/` rename, `packages/` extraction, html brand relocation

**Model tier (informational):** opus / medium (large, cross-cutting, single atomic move-set).

**Rationale for combining:** `elm-typed-html`, `elm-cem`'s IR symlink, and `elm-cem`'s test
`elm.json`s all reference the IR + `elm-cem` dirs that move here. Doing the pipeline rename,
the IR/tonal extraction, and the html relocation in one move-set means every cross-reference
is edited **once to its final value** (see Architecture). `tailwind-md3` (renamed in Task 2)
and the m3e outputs (Tasks 2–5) do **not** reference these relatively and are left for later.

**Move-set (git mv):**
- `core/elm-cem` → `pipeline/elm-cem`
- `core/elm-cem-compose` → `pipeline/elm-cem-compose`
- `core/elm-review-cem` → `pipeline/elm-review-cem`
- `core/cem-figma-connect` → `pipeline/elm-cem-figma-connect` (**rename** — spec decision #2)
- `core/elm-html-intermediate-representation` → `packages/elm-virtual-dom-intermediate-representation` (**rename** — spec decision, IR)
- `core/tonal-palette-oklch` → `packages/tonal-palette-oklch`
- `core/elm-typed-html` → `brands/html/generated/package/elm-typed-html`
- `core/elm-typed-html/config/config.json` → `brands/html/inputs/config.json`

- [ ] **Step 1.1: Create parents + move machinery to `pipeline/`**

```bash
mkdir -p pipeline packages
git mv core/elm-cem pipeline/elm-cem
git mv core/elm-cem-compose pipeline/elm-cem-compose
git mv core/elm-review-cem pipeline/elm-review-cem
git mv core/cem-figma-connect pipeline/elm-cem-figma-connect   # move + rename (spec decision #2)
```

- [ ] **Step 1.2: Extract the two foundational libs to top-level `packages/`**

```bash
git mv core/elm-html-intermediate-representation packages/elm-virtual-dom-intermediate-representation   # move + rename (IR)
git mv core/tonal-palette-oklch packages/tonal-palette-oklch
```

- [ ] **Step 1.3: Rename + retarget the `elm-cem` IR symlink (finding S #1)**

The symlink is **renamed AND retargeted** (resolved 2026-08-19, full local rename — no old name
survives). Delete the old-named symlink, create the new-named one pointing at the renamed package dir.
Verified: no `elm.json` under `core/elm-cem` consumes the alias name, so there is no `source-directories`
edit to make here (finding S #1) — but grep to confirm before committing:

```bash
rm pipeline/elm-cem/elm-html-intermediate-representation
ln -s ../../packages/elm-virtual-dom-intermediate-representation pipeline/elm-cem/elm-virtual-dom-intermediate-representation
git add pipeline/elm-cem/elm-virtual-dom-intermediate-representation
# confirm nothing still references the old alias name from inside elm-cem:
grep -rn "elm-html-intermediate-representation" pipeline/elm-cem --include=elm.json && echo "FIX these" || echo "clean"
```

- [ ] **Step 1.4: Relocate the html brand**

```bash
mkdir -p brands/html/generated/package brands/html/inputs
git mv core/elm-typed-html brands/html/generated/package/elm-typed-html
git mv brands/html/generated/package/elm-typed-html/config/config.json brands/html/inputs/config.json
# remove the now-empty config/ dir inside the package if git leaves it
rmdir brands/html/generated/package/elm-typed-html/config 2>/dev/null || true
```

Note per spec decision #8 and the research spec §3: `elm-typed-html`'s CEM manifest is `manifest/native.cem.json`
(a committed file, moves with the package) — there is **no** live `custom-elements-manifest.json`
to place under `brands/html/inputs/`; do not invent one. `brands/html/inputs/` holds only
`config.json`.

- [ ] **Step 1.5: `core/` should now be empty except `tailwind-md3`**

```bash
ls core/   # expect only: tailwind-md3
```

Leave `tailwind-md3` in `core/` — Task 2 renames+moves it and removes the empty `core/`.

- [ ] **Step 1.6: `pnpm-workspace.yaml` — flip the IR-exclusion glob**

Change `!core/*/elm-html-intermediate-representation` → `!pipeline/*/elm-virtual-dom-intermediate-representation`
(both segments change: `core`→`pipeline` **and** the alias name, since the symlink is renamed in Step 1.3).
The glob must match the **renamed symlink alias**, not the renamed package dir. (Old `core/*`,
`brands/*/outputs/*` globs still stand — `tailwind-md3` + the m3e outputs still live under them until
Tasks 2–5.)

- [ ] **Step 1.7: Fix all `tools/*` files with `core/`→`pipeline/`/`packages/` refs**

Apply every **Task 1** entry from findings A–R above (and **finding A2** below, for the rename-identity
edits), file by file, using the exact current strings cited: `family.json` (elm-cem, elm-cem-compose,
elm-review-cem, cem-figma-connect→`pipeline/elm-cem-figma-connect`, elm-cem-facts,
IR→`packages/elm-virtual-dom-intermediate-representation`, elm-typed-html), `gate-all.mjs` (L195 walk,
L268), `check-drift.mjs` (L90), `bump.mjs` (L27–28, L43–44), `gen-hooks.mjs` (L40–44, L46),
`check-elm-shape-drift.mjs` (L48, L133), `check-cc-elm-refs.mjs` (L45), `gen-figma-config.mjs` (L46),
`ab-elm-cem.sh` (L25), `ab-elm-m3e-split.sh` (L42), `measure-docs-size.mjs` (L77–78),
`check-emit-determinism-cfc.mjs` (L39), `check-single-cem-facts.mjs` (L86–88), `lib/regen.mjs` (L34),
`install-toolchains.mjs` (L54).

- [ ] **Step 1.7b: Apply the rename-identity edits (finding A2)**

The two renames change package *identity*, not just paths:
- `core/cem-figma-connect/package.json` `"name": "cem-figma-connect"` → `"elm-cem-figma-connect"`
  (edit before or after the `git mv`; no other `package.json` depends on it by workspace name — verified).
- The IR's own `elm.json` `name` → `jackhp95/elm-virtual-dom-intermediate-representation`, plus the
  **Task-1 dependents' `elm.json` dependency keys** (`elm-typed-html/elm.json:40`). The **Task-4**
  dependents (`elm-m3e`, `elm-m3e-families`, `elm-m3e-icons`) are edited when they move (finding A2,
  Task 4). **Do NOT touch `HtmlIr.*` module imports** — the module namespace is unchanged by a package
  rename. `grep -rn "jackhp95/elm-html-intermediate-representation"` before committing Task 1 → **zero
  hits** should remain (the symlink alias is now renamed too, Step 1.3; only Task-4 dependents may still
  carry the old published name until Task 4).

- [ ] **Step 1.7c: Apply the rename-identity table-key + step-name edits (finding A3)**

Full-rename policy (resolved 2026-08-19 — no old name survives locally). Apply every **cfc** and **IR**
row from **finding A3**:
- `tools/family.json`: rename key L147 `"cem-figma-connect"` → `"elm-cem-figma-connect"`, key L84
  `"elm-html-intermediate-representation"` → `"elm-virtual-dom-intermediate-representation"`, and the
  local snapshot cache path L158 `.cache/snapshots/cem-figma-connect` → `…/elm-cem-figma-connect`
  (lockstep with the `snapshot-refs.json` key below).
- `tools/lib/consumer-output-drift.mjs`: L46 `familySrcDir(repoRoot, "cem-figma-connect")` arg → new key
  (**must equal `family.json`'s renamed key**); L44 descriptor `key` + L45 `label` → `elm-cem-figma-connect`.
- `tools/check-drift.test.mjs`: L128 loop literal `"cem-figma-connect"` → `"elm-cem-figma-connect"`
  (must equal the renamed descriptor key).
- `tools/bump.mjs`: L41 `pkgName: "cem-figma-connect"` → `"elm-cem-figma-connect"` (load-bearing
  `pnpm --filter`; see finding E).
- `tools/gate-all.mjs`: L434 step label `check-emit-determinism cem-figma-connect` → `…elm-cem-figma-connect`.
- `tools/check-cc-elm-refs.mjs`: L46 segment `"cem-figma-connect"` → `"elm-cem-figma-connect"` (finding H).
- `tools/check-elm-shape-drift.mjs`: L132 descriptor `name` label → `elm-cem-figma-connect (elm emitter)` (finding G).
- `tools/measure-docs-size.mjs`: L76 map key `"jackhp95/elm-html-intermediate-representation"` →
  `"jackhp95/elm-virtual-dom-intermediate-representation"` (finding K).
- `tools/snapshot-refs.json`: L8 **key** `"cem-figma-connect"` → `"elm-cem-figma-connect"` — **KEEP the
  `repo` URL + `sha` values unchanged** (mirror; finding A3 carve-out).
- `tools/gate-all-expected-steps.json`: L10–11 `cem-figma-connect: check/test` → `elm-cem-figma-connect: …`;
  L16–17 `elm-html-intermediate-representation: check/test` → `elm-virtual-dom-intermediate-representation: …`;
  L32 `copy-fidelity cem-figma-connect` → `…elm-cem-figma-connect`; L33 `check-emit-determinism cem-figma-connect`
  → `…elm-cem-figma-connect`. This file is **asserted by `check-gate-all-step-membership.test.mjs`** — the
  cleanest way to get it right is to regenerate it after the moves: `node tools/gate-all.mjs --list-steps-only`
  (per that test's own remediation hint), then diff to confirm only the renamed step-names changed.
- **DO NOT rename** `tools/publish-mirror-state.json:28` key (mirror identity → `jackhp95/${name}`;
  finding A3 carve-out) — it stays `elm-html-intermediate-representation` until the external mirror is
  itself renamed. The `tools/check-coverage-map.mjs:33-38` consumer identifiers + the two `family.json`
  cfc `copyFidelity` entries (L171, L174) are now **resolved renames** — see **Step 1.7d** (coverage-map,
  gate-all-wired, lockstep) and **Step 1.7e** (the mirror-coupled cfc bookkeeping entries).
- **Verify:** after these edits, `grep -rn 'cem-figma-connect\|elm-html-intermediate-representation' tools/`
  should return only (a) prose/comments (Task 6 cosmetic) and (b) the two deliberately-preserved mirror
  identities (`publish-mirror-state.json:28` key, `snapshot-refs.json:8` `repo` URL value). Anything else
  is a missed functional hit — fix before committing.

- [ ] **Step 1.7d: Rename the facts-bundle coverage-audit consumer identifiers (finding A3, resolved 2026-08-19 — was an open flag)**

`tools/check-coverage-map.mjs` is a **gate-all step** (`gate-all.mjs:403`, `gate-all-expected-steps.json:24`
`"workspace: check-coverage-map"`). Its `REQUIRED_CONSUMERS` array (L33–38) is the closed set every
`"consumer"` value in `docs/facts-bundle/coverage-map.json` must belong to, **and** every listed consumer
must have ≥1 entry (`check-coverage-map.mjs:219,275`). So the array and the JSON's consumer values
**must rename in lockstep, in one atomic edit** — rename one without the other and this gate fails
(`consumer must be one of …` or `consumer "…" has no entries`). Per the full-rename policy (Decisions log
#6), these logical face-role identifiers rename to match their renamed packages. **No mirror/URL is
involved** (coverage-map.json carries audit SHAs but no `github.com/jackhp95` URL), so no carve-out — pure
local rename. Confirmed this session: `check-coverage-map.mjs` is gate-all-wired, so this is load-bearing
for automated gate-all green, not the "separate facts-bundle scope" the earlier flag assumed.

**(i) `tools/check-coverage-map.mjs` L33–38 — the array (exact before/after):**

```js
const REQUIRED_CONSUMERS = [        const REQUIRED_CONSUMERS = [
    "m3e-okf",                          "elm-m3e-okf",
    "tailwind-m3e-web",         →       "elm-m3e-tailwind",
    "cem-figma-connect-matcher",        "elm-cem-figma-connect-matcher",
    "cem-figma-connect-elm-emitter",    "elm-cem-figma-connect-elm-emitter",
];                                  ];
```

**(ii) `docs/facts-bundle/coverage-map.json` — the entries. Mechanically executable as ONE whole-file
substring substitution (three rules; no overlap, no double-prefix risk because the new names appear
nowhere yet):**

| Old substring | New substring | `"consumer"` occurrences | Non-consumer (prose) occurrences |
|---|---|---|---|
| `cem-figma-connect` | `elm-cem-figma-connect` | 81 (`-matcher` 40 + `-elm-emitter` 41) | 2 — `$comment` L3, note L1412 |
| `m3e-okf` | `elm-m3e-okf` | 53 | 9 lines — `$comment` L3 + notes L121, L208, L218, L387, L427, L437, L466 (2 hits on that line), L835 |
| `tailwind-m3e-web` | `elm-m3e-tailwind` | 12 | 2 — `$comment` L3, note L387 |

- The `cem-figma-connect` → `elm-cem-figma-connect` rule transparently handles the two suffixed forms
  (`-matcher`, `-elm-emitter`) because they share the prefix — do **not** write separate rules for them.
- 146 `"consumer"` values total (81 + 53 + 12) — matches the four `REQUIRED_CONSUMERS` groups exactly.
- `m3e-okf` never appears as a substring of `m3e-api-okf` (that token is `m3e-`**api**`-okf`), and no
  `"sourceFile"` path carries any of the three names (they are each consumer's own repo-relative paths),
  so the blind substring pass touches only consumer values + the enumerated prose spots — verified.
- **Do NOT edit the facts-bundle files here mechanically as part of this doc-planning task** — this step
  is the executable spec; the real edit lands when Task 1 runs. Re-run `node tools/check-coverage-map.mjs`
  after: it prints the per-consumer table under the new names and must exit 0.

**(iii) facts-bundle *prose* carrying the old names (non-load-bearing — `check-coverage-map.mjs` reads
only coverage-map.json's `consumer` values + schema.json's *structure*, never these strings):**
`docs/facts-bundle/coverage-audit.md` (46), `docs/facts-bundle/m3-consumer-scorecard.md` (35),
`docs/copy-fidelity-notes.md` (22), `docs/facts-bundle/m6-deep-clean.md` (7), `docs/facts-bundle/schema.json`
(6 — all inside `"description"` fields, L116/162/194/242/253/401, not enum values or property keys),
`docs/facts-bundle/m3c-generated-diff.md` (5), `docs/facts-bundle/m3a-…`/`m3b-generated-diff.md` (2 each).
Same three substring rules; batched to **Task 6** (cosmetic "no whiff" sweep, finding V) — none are
gate-read, so they cannot break a gate, but they rename for consistency.

- [ ] **Step 1.7e: Rename the two cfc `copyFidelity` bookkeeping entries in `family.json` (finding A3 — resolved 2026-08-19, MIRROR-COUPLED, flag surfaced)**

Both entries live in `family.json`'s `cem-figma-connect`→`elm-cem-figma-connect` `copyFidelity` block and
describe **files in the external cfc mirror snapshot** (the source that `copy-fidelity.mjs:115,119`
compares the local package against — pinned by `snapshot-refs.json:8` → `jackhp95/cem-figma-connect.git`).
They are `authorizedAbsent*` = source-side (mirror) paths authorized to be absent locally.

- `family.json:174` `authorizedAbsentM6[0]` `".claude-memory/cem-figma-connect-state.md"` →
  `".claude-memory/elm-cem-figma-connect-state.md"`.
- `family.json:171` `authorizedAbsentPrefixes[1]` `"test/fixtures/tailwind-m3e-web-0.1.0/"` →
  `"test/fixtures/elm-m3e-tailwind-0.1.0/"` (version confirmed `0.1.0` — `tailwind-m3e-web/package.json`
  `"version": "0.1.0"` is unchanged this wave; only the package name renames, Task 2). Leave the sibling
  `authorizedAbsentPrefixes[0]` `"test/fixtures/m3e-web-2.7.0/"` **unchanged** — `m3e-web` is upstream
  `@m3e/web`, not a rename target.

**⚠ MIRROR-COUPLING FLAG (surfaced, not silently swept — parallels the IR `publish-mirror-state.json`
open-flag):** neither file exists in the local workspace (verified — no `.claude-memory/` in the cfc
package; no `test/fixtures/tailwind-m3e-web-0.1.0/` dir). They exist only in the **external cfc mirror
repo**, whose files keep the old names until the mirror is itself renamed (Jack's reserved per-mirror
action). Consequence: in a **normal gate-all run the cfc copy-fidelity gate SKIPs** (the
`.cache/snapshots/cem-figma-connect` snapshot is absent on any machine that didn't run the migration —
`copy-fidelity.mjs:59-70`), so **renaming these entries is safe for automated gate-all now**. But a run
**with the mirror snapshot materialized** (`REQUIRE_SNAPSHOT_GATES=1` or a mirror audit) would, after the
rename, flag the mirror's still-old-named `.claude-memory/cem-figma-connect-state.md` and
`test/fixtures/tailwind-m3e-web-0.1.0/*` as unauthorized `missing` files → RED, until the mirror content is
renamed too. **Whoever renames the external cfc mirror must, in the same action, rename these two paths'
physical counterparts in the mirror** (same lockstep discipline as the IR `publish-mirror-state.json` key).
This is the honest resolution of Jack's "rename everything local, no whiff" directive against the standing
mirror exception: the local family.json string renames now; the coupled external rename is paired.

- [ ] **Step 1.8: Fix `elm-typed-html` internal cross-boundary refs (finding T)**

`brands/html/generated/package/elm-typed-html/scripts/regen.sh` (L7 `ELM_CEM_BIN` default +
the `--config-from` arg now pointing at `brands/html/inputs/config.json`), `scripts/validate.mjs`
(L62 IR, L75 facts), `package.json` (L20 hooks:install), `review/elm.json` (L5–8),
`verify/elm.json` (L3). Use the exact new values in finding T. For `regen.sh`'s `--config-from`,
from the package root the arg becomes `--config-from="$REPO_ROOT/../../../inputs/config.json"`
(3 up from `brands/html/generated/package/elm-typed-html` to `brands/html`, then `inputs/config.json`).

- [ ] **Step 1.9: Fix `elm-cem`'s test `elm.json` IR refs (finding T)**

`pipeline/elm-cem/tests/phantom/native/acid/elm.json` L7 (+1 `../` → `packages/`),
`pipeline/elm-cem/tests/phantom/acid/elm.json` L7 (+1 `../` → `packages/`). Re-grep
`pipeline/elm-cem` for any other `elm-html-intermediate-representation` relative ref and fix.

- [ ] **Step 1.10: Reinstall + run the gate; iterate on failures**

```bash
pnpm install && node tools/gate-all.mjs
```

Primary safety net for anything the enumeration missed (computed paths, an overlooked
load-bearing comment). A wrong relative path throws `MODULE_NOT_FOUND`/`ENOENT` immediately.
Read `FAILED ITEMS`, patch forward, re-run until `GATE-ALL GREEN` (modulo the pre-existing
known-unrelated failure from Task 0's baseline).

- [ ] **Step 1.11: Commit**

```bash
git add -A
git commit -m "reorg(shape-v2): core/->pipeline/ (+ cem-figma-connect->elm-cem-figma-connect), extract IR (->elm-virtual-dom-intermediate-representation)+tonal to packages/, relocate html brand"
```

---

## Task 2: Finish the tailwind split — `pipeline/elm-cem-tailwind` + `brands/m3e/generated/style/elm-m3e-tailwind`

**Model tier (informational):** sonnet / high (surgery — package rename + absorb + relocate).

Second pass on the split the 2026-08-18 reorg started (`core/tailwind-md3` carved from
`tailwind-m3e-web`). This wave: (a) rename `core/tailwind-md3` → `pipeline/elm-cem-tailwind`,
(b) absorb `tools/lib/component-css-utilities.mjs` (single-consumer, finding U) into it,
(c) relocate `brands/m3e/outputs/tailwind-m3e-web` → `brands/m3e/generated/style/elm-m3e-tailwind`
and rename its package `name`.

**Files:**
- Move: `core/tailwind-md3` → `pipeline/elm-cem-tailwind`; `tools/lib/component-css-utilities.mjs`
  → into `pipeline/elm-cem-tailwind`; `brands/m3e/outputs/tailwind-m3e-web` →
  `brands/m3e/generated/style/elm-m3e-tailwind`.
- Modify: `pipeline/elm-cem-tailwind/package.json` (name), the moved brand package's
  `package.json` (name → `elm-m3e-tailwind`), `bin/generate-component-utilities.mjs` (import),
  `scripts/gen-facts.mjs` (+1 depth), `tools/family.json` (L122), `tools/bump.mjs` (L53, L318),
  `tools/gen-hooks.mjs` (if any tailwind hook target — re-grep).

- [ ] **Step 2.1: Rename the agnostic package**

```bash
git mv core/tailwind-md3 pipeline/elm-cem-tailwind
rmdir core 2>/dev/null || ls core   # core/ should now be gone
```

- [ ] **Step 2.2: Update `pipeline/elm-cem-tailwind/package.json`**

Change `"name": "tailwind-md3"` → `"name": "elm-cem-tailwind"`. Update the `description` to
note it now also hosts the component-utility generator. `hooks:install` stays
`node ../../tools/hooks-install.mjs` (depth unchanged). `tonal-palette-oklch: workspace:*`
stays (name-based). **Decide the `exports`/dependents question:** consumers reference
`tailwind-md3` as a workspace dep by name — re-grep `workspace:*` for `tailwind-md3` and
update those to `elm-cem-tailwind` (at minimum `brands/m3e/outputs/tailwind-m3e-web/package.json`
`"tailwind-md3": "workspace:*"` (verified L48) and its `src/index.css` `@import "tailwind-md3"`
+ `@import "tailwind-md3/roles-extended"`). Update all to `elm-cem-tailwind`.

- [ ] **Step 2.3: Absorb `component-css-utilities.mjs` (finding U)**

```bash
git mv tools/lib/component-css-utilities.mjs pipeline/elm-cem-tailwind/src/component-css-utilities.mjs
```
(Place under `src/` or `lib/` per the package's own convention — read the package layout
first.) **Leave `tools/lib/gen-facts-runner.mjs` where it is** (3 consumers, finding U).

- [ ] **Step 2.3b: Add the deprecation comment to `tools/lib/gen-facts-runner.mjs` (spec decision #4 / plan decision #4)**

`gen-facts-runner.mjs` stays in `tools/lib` because it has 3 genuinely non-tailwind-specific
consumers (tailwind, m3e-okf, cem-figma-connect — finding U). Add a short **code comment** at the top
of the file recording *why* it's still here and when it should die: it is scaffolding that exists only
because there is no real `elm-m3e-facts` package yet for those three to depend on directly — each keeps
a redundant private copy of the same facts bundle, fanned out via this shared runner. Once the deferred
5-package explosion (spec decision #7) produces a real `elm-m3e-facts` package, this runner should be
deleted/gutted and the 3 consumers switched to a `workspace:*` dependency on `elm-m3e-facts` instead of
a private copy. (Comment only — no behavior change.)

- [ ] **Step 2.4: Relocate the brand package + rename it**

```bash
mkdir -p brands/m3e/generated/style
git mv brands/m3e/outputs/tailwind-m3e-web brands/m3e/generated/style/elm-m3e-tailwind
```
In `brands/m3e/generated/style/elm-m3e-tailwind/package.json`: `"name": "tailwind-m3e-web"`
→ `"name": "elm-m3e-tailwind"`; re-grep the repo for `tailwind-m3e-web` as a workspace dep
name and update dependents (docs `vendor-tailwind-m3e-web.mjs`, any `@import "tailwind-m3e-web…"`)
— note the docs consumer is handled in Task 5, but if a non-docs consumer exists, fix here.

- [ ] **Step 2.5: Fix the relocated brand package's internal imports (+1 depth / absorb)**

- `bin/generate-component-utilities.mjs` L40: was `"../../../../../tools/lib/component-css-utilities.mjs"`
  → now imports from `elm-cem-tailwind` (moved in 2.3). Preferred: import by workspace name
  if the package exports it, else a relative path into `pipeline/elm-cem-tailwind/src/…`
  (from `brands/m3e/generated/style/elm-m3e-tailwind/bin`, depth 6 →
  `"../../../../../../pipeline/elm-cem-tailwind/src/component-css-utilities.mjs"`). Prefer a
  workspace-name export if clean; add the `elm-cem-tailwind` export + dep if so.
- `scripts/gen-facts.mjs` L16: `"../../../../../tools/lib/gen-facts-runner.mjs"` → +1 depth →
  `"../../../../../../tools/lib/gen-facts-runner.mjs"`.
- `hooks:install` (verified `node ../../../../tools/hooks-install.mjs`, depth 4) → +1 →
  `node ../../../../../tools/hooks-install.mjs`.
- Re-grep the whole package for `../../../../../` and apply +1 to any remaining cross-package ref.

- [ ] **Step 2.6: Update `tools/*` for the brand relocation**

`family.json` L122 srcDir → `brands/m3e/generated/style/elm-m3e-tailwind`; `bump.mjs` L53
(cem-facts.json path) + L318 (package.json path) → `generated/style/elm-m3e-tailwind`;
re-grep `tools/` for `tailwind-m3e-web` and `tailwind-md3` literals and update any remaining.
Update `tools/lib/consumer-output-drift.mjs` if it references `component-css-utilities.mjs`'s
old `tools/lib` location (verified comment L99 — check whether it's functional).

**Load-bearing name/key identity fixes for the `tailwind-m3e-web`→`elm-m3e-tailwind` rename
(separately-missed by the earlier sweep — same class as finding A3, apply full-rename policy):**
- `tools/family.json` **rename the table key** `"tailwind-m3e-web"` → `"elm-m3e-tailwind"` (not just its
  srcDir) — the `copy-fidelity <key>` step name derives from it (`gate-all.mjs:426`).
- `tools/lib/consumer-output-drift.mjs` L93 descriptor `key: "tailwind-m3e-web"` → `"elm-m3e-tailwind"`,
  L94 `label`, and L95 `familySrcDir(repoRoot, "tailwind-m3e-web")` arg → new key (must match `family.json`).
- `tools/check-drift.test.mjs` L128 loop literal `"tailwind-m3e-web"` → `"elm-m3e-tailwind"`.
- `tools/bump.mjs` L52 `pkgName: "tailwind-m3e-web"` → `"elm-m3e-tailwind"` (load-bearing `pnpm --filter`).
- `tools/gate-all-expected-steps.json` L8–9 `tailwind-m3e-web: check/test` → `elm-m3e-tailwind: …`, L31
  `copy-fidelity tailwind-m3e-web` → `…elm-m3e-tailwind`, **and L21–22 `tailwind-md3: check/test` →
  `elm-cem-tailwind: check/test`** (the agnostic-package rename from Step 2.1/2.2 — also a missed
  step-name assertion). Regenerate the whole file via `node tools/gate-all.mjs --list-steps-only` and diff.
- `tools/snapshot-refs.json` L7 **key** `"tailwind-m3e-web"` → `"elm-m3e-tailwind"` (keep `repo` URL + `sha`),
  and its `family.json` `.cache/snapshots/tailwind-m3e-web` path (L131) in lockstep. **Keep** the
  `publish-mirror-state.json`/mirror `jackhp95/${name}` identity pointed at the real mirror (carve-out).

- [ ] **Step 2.7: Reinstall + gate**

```bash
pnpm install && node tools/gate-all.mjs
```
Watch: `elm-cem-tailwind`'s `check` (tone-table regen byte-identical), `elm-m3e-tailwind`'s
`check`/`test`, the component-utilities generation (`generate:utilities`), and the E2E
facts-bundle proof (CSS-independent). Patch forward, re-run until green.

- [ ] **Step 2.8: Commit**

```bash
git add -A
git commit -m "reorg(shape-v2): tailwind-md3->pipeline/elm-cem-tailwind (absorb component-css-utilities), tailwind-m3e-web->brands/m3e/generated/style/elm-m3e-tailwind"
```

---

## Task 3: `m3e-okf` → `elm-m3e-okf` rename + relocate to `brands/m3e/generated/okf/`

**Model tier (informational):** sonnet / medium (mechanical rename + relocate, +1 depth).

Independent of the elm-m3e / docs work; sequenced early for a clean small win.

**Files:**
- Move: `brands/m3e/outputs/m3e-api-okf` → `brands/m3e/generated/okf/elm-m3e-okf`.
- Modify: the moved package's `package.json` `name`; its scripts (+1 depth, finding T);
  `tools/family.json` (L97 srcDir; the `mirror`/`bundleCopy`/`copyFidelity` blocks — see below),
  `tools/gen-hooks.mjs` (L45), `tools/bump.mjs` (L49), `tools/check-drift.test.mjs` (L21).

- [ ] **Step 3.1: Move + rename directory**

```bash
mkdir -p brands/m3e/generated/okf
git mv brands/m3e/outputs/m3e-api-okf brands/m3e/generated/okf/elm-m3e-okf
```

- [ ] **Step 3.2: Rename the package (full local consistency — spec decision #10)**

In `brands/m3e/generated/okf/elm-m3e-okf/package.json`, set the `name` field to `elm-m3e-okf`.
(The current on-disk `name` is `m3e-okf` — verified this session; the `family.json`
`$pnpmFilterNameNote` claim that it's `m3e-docs` is **stale/false**, fixed in Step 3.4.) Spec
decision #10 is **full local consistency**: the directory (Step 3.1), the `package.json` `name`
(here), AND the `family.json` table key (Step 3.4) all become `elm-m3e-okf`. The mirror repo
`jackhp95/m3e-okf` stays external (a separate, deliberate publishing action, not swept into this
structural commit).

- [ ] **Step 3.3: Fix the package's internal cross-boundary refs (+1 depth, finding T)**

`scripts/check-skills-meta.mjs` L19 (`okf-lib.mjs`), `scripts/gen-facts.mjs` L17
(`gen-facts-runner.mjs`), `package.json` `hooks:install`, and any other `../../../../../tools`
ref — apply +1 (`../../../../../` → `../../../../../../`). Re-grep the package for
`../../../../../` and fix uniformly.

- [ ] **Step 3.4: Update `tools/family.json` (rename key + fix the stale `pnpmFilterName`)**

- **Rename the table key** `"m3e-okf"` → `"elm-m3e-okf"` (spec decision #10, full local
  consistency) **and every literal that looks it up — these were separately missed by the earlier
  sweep (same class as finding A3), enumerate them, don't just "re-grep":**
  - `tools/lib/consumer-output-drift.mjs` L62 descriptor `key: "m3e-okf"` → `"elm-m3e-okf"`, L63 `label`,
    L64 `familySrcDir(repoRoot, "m3e-okf")` arg → `"elm-m3e-okf"` (must equal the renamed `family.json` key).
  - `tools/check-drift.test.mjs` L128 loop literal `"m3e-okf"` → `"elm-m3e-okf"`; also the human labels
    L54 `"m3e-okf (clean)"` / L76 `"m3e-okf (staled copy)"` (test-case names — rename for no-whiff).
  - `tools/bump.mjs` L48 `pkgName: "m3e-okf"` → `"elm-m3e-okf"` (load-bearing `pnpm --filter`; finding E).
  - `tools/gate-all-expected-steps.json` L6–7 `m3e-okf: check/test` → `elm-m3e-okf: …`, L30 `copy-fidelity
    m3e-okf` → `…elm-m3e-okf` (asserted by `check-gate-all-step-membership.test.mjs`; regenerate via
    `node tools/gate-all.mjs --list-steps-only`).
  - `tools/snapshot-refs.json` L6 **key** `"m3e-okf"` → `"elm-m3e-okf"` (keep `repo` URL + `sha`), and the
    `family.json` `.cache/snapshots/m3e-okf` path (L108) in lockstep.
  - **Mirror carve-out:** `m3e-okf` has **no** `publish-mirror-state.json` entry (verified), so no
    automated mirror gate breaks; the manual `publish-mirror.mjs elm-m3e-okf` → `jackhp95/elm-m3e-okf`
    target is correct-by-construction for the deferred external mirror rename (finding A3 coupling note).
    Keep the `family.json` `mirror`/`bundleCopy` repo coordinates (`jackhp95/m3e-okf`) unchanged.
- `srcDir` (L97) → `brands/m3e/generated/okf/elm-m3e-okf`.
- **Fix the stale `pnpmFilterName`** (L98): currently `"m3e-docs"` with a `$pnpmFilterNameNote`
  (L99) claiming that's the package's `name` — **verified false** (the actual current `name` is
  `m3e-okf`; no `package.json` anywhere is named `m3e-docs`). Set `pnpmFilterName` → `elm-m3e-okf`
  (matching the Step 3.2 `name`) and **delete the stale `$pnpmFilterNameNote`** in the same edit —
  don't leave a second known-broken mismatch next to the one being fixed. This is a pre-existing
  broken entry, unrelated to the rename, resolved opportunistically because Task 3 already edits this
  exact entry.
- **Keep** the `mirror`, `bundleCopy`, `copyFidelity` blocks and their repo coordinates
  (`jackhp95/m3e-okf`, the `.cache/snapshots/…` paths) — publishing/mirror config is out of scope.

- [ ] **Step 3.5: Update the other `tools/*` refs**

`gen-hooks.mjs` L45 → `brands/m3e/generated/okf/elm-m3e-okf/hooks/pre-push`; `bump.mjs` L49
→ `generated/okf/elm-m3e-okf/data/cem-facts.json`; `check-drift.test.mjs` L21 →
`generated/okf/elm-m3e-okf/data/cem-facts.json`.

- [ ] **Step 3.6: Reinstall + gate**

```bash
pnpm install && node tools/gate-all.mjs
```
Watch: `elm-m3e-okf`'s `check`/`test`, `workspace: copy-fidelity` for the okf package (now at
its new `srcDir`). Patch forward, re-run until green.

- [ ] **Step 3.7: Commit**

```bash
git add -A
git commit -m "reorg(shape-v2): m3e-okf->elm-m3e-okf, relocate to brands/m3e/generated/okf/"
```

---

## Task 4: Relocate `elm-m3e` to `brands/m3e/generated/package/`

**Model tier (informational):** sonnet / medium (+1 depth relocation; docs subtree rides along).

Pure relocation one level deeper under a `package/` folder — `elm-m3e` stays monolithic
(spec decision #7, the 5-package explosion is deferred). The `docs/` subtree moves **with** elm-m3e here
and is extracted in Task 5 (doing elm-m3e first means Task 5 computes docs' final cross-refs
against `generated/package/elm-m3e` once — see Architecture).

**Files:**
- Move: `brands/m3e/outputs/elm-m3e` → `brands/m3e/generated/package/elm-m3e` (with nested
  `elm-m3e-families`, `elm-m3e-icons`, `docs`).
- Modify: the `config` symlink (finding S #2); the package's non-docs internal refs (+1, finding T);
  `tools/*`: `gate-all.mjs` L68, `check-drift.mjs` L55 + L176(interim), `check-drift.test.mjs` L20,
  `bump.mjs` L34, L35(interim), `gen-hooks.mjs` L48, `check-cc-elm-refs.mjs` L38, L39(interim),
  `check-elm-shape-drift.mjs` L142(interim), `measure-docs-size.mjs` L81, `check-m3e-5pkg.mjs` L6,
  `ab-elm-cem.sh` L26, `ab-elm-m3e-split.sh` L43, `lib/gen-facts-runner.mjs` L35, `lib/regen.mjs` L38,
  `gen-figma-config.mjs` (any elm-m3e literal). Re-verify `install-toolchains.mjs`'s `brands` walk
  reaches `generated/*/*` (finding Q).

- [ ] **Step 4.1: Move**

```bash
mkdir -p brands/m3e/generated/package
git mv brands/m3e/outputs/elm-m3e brands/m3e/generated/package/elm-m3e
```

- [ ] **Step 4.2: Retarget the `config` symlink (finding S #2)**

```bash
rm brands/m3e/generated/package/elm-m3e/config
ln -s ../../../inputs/cem/config brands/m3e/generated/package/elm-m3e/config
git add brands/m3e/generated/package/elm-m3e/config
```

- [ ] **Step 4.3: Fix the package's non-docs internal refs (+1 depth, finding T)**

`review/elm.json` `source-directories` (re-read — by now the `core`→`pipeline`/`packages` rename
from Task 1 is reflected, **including the IR dir now being `packages/elm-virtual-dom-intermediate-representation`**;
apply +1 `../` to each cross-package entry), `package.json` `hooks:install` + any `../../../../tools`
ref, and re-grep the package **excluding `docs/`** for `../../../../../` cross-package refs; apply +1.
(The `docs/` subtree's own refs are handled in Task 5 — do not touch `docs/` here beyond letting it
ride along.)

- [ ] **Step 4.3b: Apply the IR published-name dependency edits (finding A2, Task-4 side)**

The IR rename (`jackhp95/elm-html-intermediate-representation` → `…/elm-virtual-dom-intermediate-representation`)
cascades into three `elm.json` dependency keys that move with `elm-m3e`:
`brands/m3e/generated/package/elm-m3e/elm.json` (was `brands/m3e/outputs/elm-m3e/elm.json:153`),
`…/elm-m3e/elm-m3e-families/elm.json` (was `…:36`), `…/elm-m3e/elm-m3e-icons/elm.json` (was `…:16`).
Update the dependency key in each. **Do NOT touch `HtmlIr.*` module imports** (namespace unchanged).
`grep -rn "jackhp95/elm-html-intermediate-representation"` after Task 4 → zero hits should remain
outside the elm-cem symlink alias + its exclusion glob.

- [ ] **Step 4.4: Update `tools/*` for the relocation**

Apply every **Task 4** entry from findings B–R: `gate-all.mjs` L68; `check-drift.mjs` L55 +
L176 (interim `generated/package/elm-m3e/docs/…`); `check-drift.test.mjs` L20; `bump.mjs` L34 +
L35 (interim); `gen-hooks.mjs` L48; `check-cc-elm-refs.mjs` L38 + L39 (interim); `check-elm-shape-drift.mjs`
L142 (interim); `measure-docs-size.mjs` L81; `check-m3e-5pkg.mjs` L6; `ab-elm-cem.sh` L26;
`ab-elm-m3e-split.sh` L43; `lib/gen-facts-runner.mjs` L35; `lib/regen.mjs` L38; `gen-figma-config.mjs`.
The "interim" entries point at `generated/package/elm-m3e/docs/…` now and get their **final**
`generated/docs/elm-m3e-docs/…` value in Task 5 (documented double-edit — see findings C, E, H).

- [ ] **Step 4.5: Reinstall + gate**

```bash
pnpm install && node tools/gate-all.mjs
```
Watch: `elm-m3e`'s `check`/`test:browser` (the dominant task; uses `ELM_M3E`), `check-m3e-5pkg`,
`check-cc-elm-refs`, the E2E facts-bundle proof (`--config-from=config/…` via the retargeted
symlink — an `ENOENT` here means the symlink is wrong). Patch forward, re-run until green.

- [ ] **Step 4.6: Commit**

```bash
git add -A
git commit -m "reorg(shape-v2): relocate elm-m3e to brands/m3e/generated/package/elm-m3e"
```

---

## Task 5: Extract the docs site to `brands/m3e/generated/docs/elm-m3e-docs` (+ internal generated/authored split)

**Model tier (informational):** opus / medium (highest path-risk item in the wave).

Extract `brands/m3e/generated/package/elm-m3e/docs` (now, after Task 4) → standalone
`brands/m3e/generated/docs/elm-m3e-docs`. Depth is unchanged (5→5); the breakage is that docs
is **no longer nested inside `elm-m3e`**, so every ref that reached *up into the parent
elm-m3e package* must reach *sideways* into `../../package/elm-m3e/…`, and every ref that
reached the workspace root keeps its `../` count but swaps `core/`→`pipeline/` (see the Depth
arithmetic correction). The docs package also gains its **own** `node_modules` (it is
independently installed), so scripts that resolved `@m3e/web`/`elm`/`elm-format` via
`<elm-m3e>/docs/node_modules` now resolve them locally.

Per spec decision #9, also reorganize the package internals into `generated/` (facts-sourced: reference
pages, examples, search index, `Compose/Attrs.elm`, family/token pages) vs `authored/` (the
guide chapters under today's `app/Route/Guide/`). **Physical boundary + top-level
`generated/`/`authored/` split only** — do NOT migrate the 9 still-inline-Elm guide chapters
to `.md`, and do NOT touch any chapter's content/format (spec decision #9 explicitly defers that).

**Files:**
- Move: `brands/m3e/generated/package/elm-m3e/docs` → `brands/m3e/generated/docs/elm-m3e-docs`.
- Rename: docs `package.json` `name` `m3e-builder-docs` → `elm-m3e-docs` (verified current name).
- Modify: `docs/elm.json` `source-directories`; ~10 `docs/scripts/*.mjs` (`REPO`/`M3E_ROOT`
  recomputation + node_modules localization); `docs/samples/review/elm.json`;
  `tools/family.json` (new `elm-m3e-docs` entry + the docs-related prefixes on the `elm-m3e`
  entry); the **final** value of the interim double-edits (findings C L176, E L35, H L142, H L39).
- Create: `tools/family.json` entry for `elm-m3e-docs`; internal `generated/`+`authored/` dirs.

> **Highest-risk task — budget the most grep-sweep effort here.** The inventory below is from
> a dedicated sub-agent sweep this session, re-verified for the depth-correction. Re-read each
> file at execution time; the `build:site` run is the ultimate safety net.

- [ ] **Step 5.1: Move + rename**

```bash
mkdir -p brands/m3e/generated/docs
git mv brands/m3e/generated/package/elm-m3e/docs brands/m3e/generated/docs/elm-m3e-docs
```
In `brands/m3e/generated/docs/elm-m3e-docs/package.json`: `"name": "m3e-builder-docs"` →
`"name": "elm-m3e-docs"`. (Note: unrelated to `elm-m3e-okf`'s `pnpmFilterName: "m3e-docs"`,
which is a different string — leave that alone.)

- [ ] **Step 5.2: Fix `docs/elm.json` `source-directories`** (verified current values)

- `"app"`, `"src"`, `".elm-pages"`, `"vendor/elm-foundation"` — package-local, **keep**.
- `"../src"` → `"../../package/elm-m3e/src"`.
- `"../elm-m3e-families/src"` → `"../../package/elm-m3e/elm-m3e-families/src"`.
- `"../../../../../core/elm-cem/facts/src"` → `"../../../../../pipeline/elm-cem/facts/src"` (same `../` count).
- `"../../../../../core/elm-cem-compose/src"` → `"../../../../../pipeline/elm-cem-compose/src"`.

- [ ] **Step 5.3: Fix `docs/scripts/*.mjs` — `REPO`/`M3E_ROOT` recomputation + node_modules localization**

Each script computes an elm-m3e-root anchor by walking up from its own location; that anchor
must now split into (a) the **docs package root** (for OUT dirs, `data/`, local `node_modules`,
`app/Compose/Attrs.elm`) and (b) the **elm-m3e package** at `../../package/elm-m3e` (for
`src/M3e`, `config/*.json`, `review/`). Per the sub-agent inventory, edit at minimum:
- `scripts/extract-reference.mjs` — `REPO` (`path.resolve(here,"../..")`): OUT/`node_modules`/`bin` anchor to docs root; `SRC_M3E`/`SRC_M3E_BARREL`/`config/categories.json`/CEM path anchor to `../../package/elm-m3e` (or the docs-local `node_modules/@m3e/web` for the CEM).
- `scripts/examples-gen/lib/to-elm.mjs` L52: `"../../../../../../../../core/elm-cem/src/elm-shape.mjs"` → `"../../../../../../../../pipeline/elm-cem/src/elm-shape.mjs"` (same 8× `../`, `core`→`pipeline`).
- `scripts/examples-gen/lib/facts.mjs` — `M3E_ROOT` + `ELM_CEM_CLI` (→ `pipeline/elm-cem/bin/elm-cem.js`) + cwd + PATH (docs-local node_modules).
- `scripts/examples-gen/lib/oracle.mjs` — `REPO_ROOT` → CEM path (docs-local node_modules), `config/slots.json` (→ `../../package/elm-m3e/config`), `src/M3e/*.elm` existence check (→ `../../package/elm-m3e/src`).
- `scripts/examples-gen/examples-to-elm.mjs`, `scripts/examples-gen/gen-record-build.mjs`, `scripts/examples-gen/gen-barrel.mjs`, `scripts/build-examples-data.mjs` — all recompute `REPO`/`REPO_ROOT` for `config/*` reads and `docs/node_modules/.bin/{elm,elm-review}`; the `config/*` files live in `../../package/elm-m3e/config`, the bins in docs-local `node_modules/.bin`. `gen-record-build.mjs` also passes `reviewSrcDir: <elm-m3e>/review/src` and `extraSourceDirs: [<elm-m3e>/src, <root>/pipeline/elm-review-cem/src]` — repoint both.
- `scripts/gen-compose-attrs.mjs` — `M3E_ROOT` (`src/M3e/Attributes.elm`, `src/M3e/Review/Facts.elm` → `../../package/elm-m3e/src/…`), `DOCS` OUTPUT (`app/Compose/Attrs.elm` → docs-local), `ELM_FORMAT` (docs-local node_modules).
- `scripts/samples-gen/extract-samples.mjs` — `DOCS`/`REPO`: `DOCS` = docs root (local), `REPO` was `elm-m3e` (docs's parent) → now `../../package/elm-m3e`; the `SRC_DIRS`, `REPO/review/elm.json`, `REPO/review/src/CodegenReviewConfig.elm`, and the L290–293 source-directory rewrite all repoint to `../../package/elm-m3e/*`.
- `scripts/search-index-gen/build-search-index.mjs` — verified all paths are `docs/dist`-local; **no change**.
- `scripts/vendor-foundation.mjs`, `scripts/vendor-tailwind-m3e-web.mjs` — vendor IR/typed-html/tailwind srcs via `../../../../../core/…`: IR → `packages/elm-virtual-dom-intermediate-representation`, typed-html → `brands/html/generated/package/elm-typed-html`, tailwind → `brands/m3e/generated/style/elm-m3e-tailwind`. Recompute from the docs root (depth 5 → 5 `../` to root). **`vendor-tailwind-m3e-web.mjs` likely also needs the `tailwind-m3e-web`→`elm-m3e-tailwind` rename from Task 2** — grep it.

- [ ] **Step 5.4: Fix `docs/samples/review/elm.json`** (verified current values)

- `"src"` — local, keep.
- `"../../../src"` (→ was `elm-m3e/src`) → `"../../../../package/elm-m3e/src"`. (From `elm-m3e-docs/samples/review`, `../../../` = docs root; need `../../../../package/elm-m3e/src`.)
- `"../../../../../../../core/elm-review-cem/src"` → `"../../../../../../../pipeline/elm-review-cem/src"` (same count, `core`→`pipeline`).
- `"../../../../../../../core/elm-cem/facts/src"` → `"../../../../../../../pipeline/elm-cem/facts/src"`.
- `"../../../../../../../core/elm-html-intermediate-representation/src"` → `"../../../../../../../packages/elm-virtual-dom-intermediate-representation/src"`.
- `"../../../../../../../core/elm-typed-html/src"` (if present) → `"../../../../../../../brands/html/generated/package/elm-typed-html/src"` (**re-verify** — typed-html moved to a deeper path; count `../` from `samples/review/` at docs depth 5 + 2 = 7 to root, then descend). **Read the file in full at execution time and recompute each entry.**

- [ ] **Step 5.5: Document the `generated/`/`authored/` correspondence — labeling only, no move**
  (resolved live with Jack, 2026-08-19: documentation-only correspondence, neither a physical split
  nor a deferral — see "Decisions log" #5)

**Resolved: no physical filesystem split.** `elm-pages` requires every route module to live
under `app/Route/`, and its folder names become public URL path segments (`Route/Guide/TheLayers.elm`
is the live URL `/guide/the-layers`) — so moving `Route/Guide/` under a top-level `authored/` dir
(or `Route/Components/`, `Route/Family.elm`, `Route/Styles/` under `generated/`) would change public
URLs, not just relocate files. That's a real behavior change, not "physical-only" as originally
scoped — out of bounds per spec decision #9's "do not touch chapter prose/format" spirit (a URL change is a
user-facing format change even without touching prose).

The split is **already substantially true today via existing folder names** — no move needed to
make it legible:
- **generated (or should-be-generated per spec §5 bucket b/c):** `app/Route/Components/`,
  `app/Route/Family.elm`, `app/Route/Styles/`, parts of `app/Route/GettingStarted/`.
- **authored:** `app/Route/Guide/` (18 `.elm` route modules — Accessibility, CheatSheet,
  FirstComponent, Glossary, Motion, Seams, Strictness, TheLayers, Theming, etc.) plus the 4
  already-`.md` chapters under `docs/guides/` (EnumSafety.md, Glossary.md, Seams.md, TheLayers.md).

Add a short `docs/README.md` (or a section in the new package's own `README.md`) stating this
correspondence explicitly, so "generated/docs" in the directory tree reads as an honest label
without requiring a physical `generated/`/`authored/` subtree. **Do NOT** move any route file, do
NOT touch `elm.json` `source-directories` for this reason, do NOT convert any inline-Elm chapter to
`.md`, do NOT edit chapter prose. A real physical split (if ever wanted) is deferred to the
guide-markdown-migration project — at that point Guide content moves out of `.elm` route modules
into real `.md` files read via `BackendTask.File`, which aren't URL-routing-constrained the same
way, making a physical `authored/` directory cheap then instead of risky now.

- [ ] **Step 5.6: Add the `tools/family.json` entry + finalize docs-path refs**

- Add an `elm-m3e-docs` entry with `srcDir: "brands/m3e/generated/docs/elm-m3e-docs"`. Model
  its `mirror`/`copyFidelity` fields on how the docs package was tracked under the `elm-m3e`
  entry today — if docs was **not** independently mirrored (it was a subdir of `elm-m3e`),
  give it no `mirror` block, matching precedent (Open Q if unclear). Move any docs-specific
  `sourceFilterExcludePrefixes`/`authorizedAbsent` (`docs/dist/`, `docs/vendor/`,
  `docs/*lock*`) OFF the `elm-m3e` entry and onto the new `elm-m3e-docs` entry, rebased to the
  package root (e.g. `dist/`, `vendor/`).
- **Finalize the interim double-edits**: `check-drift.mjs` L176 → `brands/m3e/generated/docs/elm-m3e-docs/.elm-pages/Pages.elm`; `bump.mjs` L35 → same; `check-cc-elm-refs.mjs` L39 → `brands/m3e/generated/docs/elm-m3e-docs/vendor/elm-foundation`; `check-elm-shape-drift.mjs` L142 → `brands/m3e/generated/docs/elm-m3e-docs/scripts/examples-gen/lib/to-elm.mjs`.

- [ ] **Step 5.7: Reinstall + gate (+ explicit docs build)**

```bash
pnpm install && node tools/gate-all.mjs
```
The docs `build:site` (run inside gate-all) is the sharpest test — it chains `gen:reference`,
`gen:examples-*`, `gen:samples`, `gen:compose-attrs` (all the recomputed-anchor scripts). A wrong
anchor throws `ENOENT`/`MODULE_NOT_FOUND` immediately. If `build:site` is memoized/cached in
gate-all, force a clean docs build to exercise the generators. Patch forward, re-run until green.

- [ ] **Step 5.8: Commit**

```bash
git add -A
git commit -m "reorg(shape-v2): extract docs to brands/m3e/generated/docs/elm-m3e-docs (+ generated/authored split)"
```

---

## Task 6: Cleanup + final verification

**Model tier (informational):** sonnet / low.

**Files:** cosmetic comment fixes (finding V); `pnpm-workspace.yaml` (drop dead globs); the
design spec status line.

- [ ] **Step 6.1: Drop the now-dead `pnpm-workspace.yaml` globs**

Remove `core/*`, `brands/*/outputs/*`, `brands/*/outputs/*/*` (nothing lives under `core/` or
`brands/*/outputs/` any more — verify with `ls`). Keep `packages/_probe/*`, `packages/*`,
`pipeline/*`, `brands/*/inputs/*`, `brands/*/inputs/*/*`, `brands/*/generated/*/*`,
`brands/*/generated/*/*/*`, and the exclusions.

- [ ] **Step 6.2: Sweep cosmetic path mentions in comments (finding V)**

```bash
grep -rn "core/elm-cem\b\|core/cem-figma-connect\b\|core/elm-review-cem\b\|core/elm-typed-html\b\|core/elm-html-intermediate-representation\b\|core/tonal-palette-oklch\b\|core/tailwind-md3\b\|brands/m3e/outputs/\|tailwind-m3e-web\b\|m3e-api-okf\b\|m3e-builder-docs\b" tools/ .github/ 2>/dev/null
```
Update each remaining hit (should be comment-only prose by now) to its new location. Not
required for gate-all; verify nothing was load-bearing via the final run.

- [ ] **Step 6.3: Flip the design spec status line**

In `docs/superpowers/specs/2026-08-19-repo-shape-v2-design.md`, update the `Status:` line to
note wave 1 is implemented, citing this plan (`docs/plans/2026-08-19-repo-shape-v2-wave1-plan.md`).
Leave the deferred items (spec decisions #4, #7, #9-partial, #8-partial) noted as still-pending.

- [ ] **Step 6.4: Final full gate-all run**

```bash
node tools/gate-all.mjs
```
Expect `GATE-ALL GREEN` (modulo the Task-0 baseline known-unrelated failure). The summary
package list should show the new names/paths: `pipeline/elm-cem`, `pipeline/elm-cem-figma-connect`,
`pipeline/elm-cem-tailwind`, `packages/elm-virtual-dom-intermediate-representation`,
`packages/tonal-palette-oklch`,
`brands/html/generated/package/elm-typed-html`, `brands/m3e/generated/package/elm-m3e`,
`brands/m3e/generated/style/elm-m3e-tailwind`, `brands/m3e/generated/okf/elm-m3e-okf`,
`brands/m3e/generated/docs/elm-m3e-docs`. Zero unexpected skips beyond pre-existing `CHRONIC_SKIPS`.

- [ ] **Step 6.5: Commit**

```bash
git add -A
git commit -m "docs(shape-v2): drop dead workspace globs, cosmetic path cleanup, flip spec status"
```

---

## Out of scope (explicitly deferred — do NOT plan or execute here)

Per the spec's "Net effect" summary, these are separate later projects:

- **The 5-package explosion** — `elm-m3e` → `elm-m3e-{core,elements,components,build,facts}`
  as real standalone packages; the same for `elm-typed-html`; the `packages.json` rewrite this
  requires; the `-elements`/`-components` naming inversion execution (spec decisions #4, #7). `elm-m3e`
  and `elm-typed-html` stay **monolithic** internally this wave. `tools/check-m3e-5pkg.mjs`'s
  assertion of the deferred `packages.json` shape is preserved (path only), not acted on.
- **The 3 docs codegen wins** — `Route.Family` from `slots.json`, `Route.Styles/` token tables
  from the token manifest, `Installation` strings from package metadata (spec decision #9).
- **The guide-markdown migration** — moving the 9 still-inline-Elm guide chapters to `.md`
  (spec decision #9). This wave does **only the documentation-only `generated/`/`authored/` labeling**
  (Step 5.5 — no physical filesystem split, since elm-pages folder names are public URLs); chapter
  content and format are untouched, and the physical split waits for this same guide-markdown project.
- **Every brand beyond m3e + html** — `svg` (blocked on an IR namespaced-node additive),
  `shoelace`, `web-awesome`, `calcite`, `fluent-ui`, `warp`, `etc/` (spec decision #8). No empty brand
  dirs are scaffolded.
- **`brands/m3e/inputs/` changes** — the 10 config files stay separate, the live-resolved CEM
  stays uncommitted (spec decision #6). Already landed in the 2026-08-18 reorg; no further change.
- **Publishing / mirror rewiring** — the `mirror`/`bundleCopy`/`copyFidelity` blocks in
  `family.json` keep their existing repo coordinates (e.g. `jackhp95/m3e-okf`); only `srcDir`
  values move. No `jackhp95/<name>` mirror repo is touched.
- **The 3 pending-merge worktree branches** (`.claude/worktrees/agent-{a8e48485eed5250b1,adf03debc8e3b774c,ae099ba76362fbf0d}`)
  — not touched; their content is not assumed on `main`.
- **Turbo/Nx adoption** — rejected in spec §6; continue on `tools/lib/gate-scheduler.mjs`.

---

## Decisions log (2026-08-19, live session with Jack)

Six decisions were made live that shape this plan; each is now **folded into the task bodies above**
(this log is the condensed trail + the rationale, so the deliberation isn't lost — it is not a list of
open items). The two package renames (#1, #2), the okf consistency fix (#3), and the full-rename
resolution (#6, which extends #1–#3 to every local key/string/symlink) are the highest-leverage and
most error-prone, so their reasoning is preserved in full. **A later closeout pass (2026-08-19, final
rename-sweep) resolved the last two formerly-open flags as full renames — #7 (coverage-map/`REQUIRED_CONSUMERS`,
Step 1.7d) and #8 (the two cfc `copyFidelity` mirror-coupled entries, Step 1.7e) — under Jack's directive
"rename everything consistently"; see the "Resolved 2026-08-19" block below.**

1. **IR rename — `elm-html-intermediate-representation` → `elm-virtual-dom-intermediate-representation`,
   confirmed.** Done as part of the `packages/` extraction in **Task 1** (not a separate follow-up). It
   is a genuine published-package rename, so beyond the srcDir/relative-path edits (findings A/S/T) it
   cascades to the package's own `elm.json` `name` **and 4 dependents' `elm.json` dependency keys**
   (elm-typed-html in Task 1; elm-m3e + families + icons in Task 4) — enumerated in **finding A2**. The
   `HtmlIr.*` module namespace is untouched (package name ≠ module names). The elm-cem symlink **alias
   name is also renamed** to `elm-virtual-dom-intermediate-representation` (resolved by decision #6 below;
   verified no `elm.json` `source-directories` under `core/elm-cem` consumes the alias, so the earlier
   "avoid editing `source-directories`" reason was unfounded) — symlink-name + exclusion-glob change only.
   The `family.json` table key + every literal that looks it up also rename (finding A3).
2. **`cem-figma-connect` rename — → `elm-cem-figma-connect`, confirmed.** Done as part of Task 1's
   `core/`→`pipeline/` move (finding A2). Beyond paths, the identity edits are its own `package.json`
   `name` (no other package depends on it by workspace name — verified) **and — per decision #6 — the
   `family.json` table key + every literal that looks it up** (`consumer-output-drift.mjs`,
   `check-drift.test.mjs`, `bump.mjs` `pkgName`, `gate-all.mjs`/`gate-all-expected-steps.json` step-names,
   `snapshot-refs.json` key, `check-cc-elm-refs.mjs` segment, `check-elm-shape-drift.mjs` label — finding
   A3, Step 1.7c). Mirror repo `jackhp95/cem-figma-connect` stays external (its URL/`repo` values and the
   `jackhp95/${key}` manual-publish target are the carve-out).
3. **`elm-m3e-okf` — full local consistency, mirror stays separate.** Rename directory + `package.json`
   `name` + `tools/family.json` table key all to `elm-m3e-okf` together in **Task 3** — no reason to
   leave the key mismatched (same local bookkeeping risk class as every other rename). The mirror repo
   `jackhp95/m3e-okf` stays unrenamed — a live external published resource; renaming it is a separate
   deliberate publishing action, not swept into a structural commit. **Opportunistic fix folded in
   (Task 3, Step 3.4):** `family.json`'s `pnpmFilterName: "m3e-docs"` (L98) + its `$pnpmFilterNameNote`
   claim are stale/false — the real current `name` is `m3e-okf` (verified; no `package.json` is named
   `m3e-docs`) — so `pnpmFilterName` → `elm-m3e-okf` and the note is deleted in the same edit.
4. **`gen-facts-runner.mjs` — stays in `tools/lib`, gets a deprecation comment.** 3 genuinely
   non-tailwind consumers (tailwind, m3e-okf, cem-figma-connect — finding U), so only the single-consumer
   `component-css-utilities.mjs` moves into `pipeline/elm-cem-tailwind`. **Task 2 Step 2.3b** adds a code
   comment recording *why* it survives: it's scaffolding for a missing real `elm-m3e-facts` package; once
   the deferred explosion (spec decision #7) creates one, this runner should be deleted and the 3
   consumers switched to a `workspace:*` dep on `elm-m3e-facts`.
5. **Docs `generated/`/`authored/` split — documentation-only correspondence (neither a physical split
   nor a deferral).** No physical filesystem move under `app/Route/`, ever: elm-pages makes folder names
   public URL segments, so a literal move changes URLs — a bigger behavior change than "physical-only" as
   originally scoped. **Task 5 Step 5.5** documents the already-true correspondence (`Route/Guide/` =
   authored; `Route/Components/`+`Route/Family.elm`+`Route/Styles/` = generated-or-should-be) in a short
   README note, zero file moves. A real physical split waits for the guide-markdown-migration project
   (when Guide content leaves `.elm` route modules for `BackendTask.File`-read `.md` files — no longer
   URL-routing-constrained).

6. **Full local rename of the cfc/IR family.json keys + the elm-cem IR symlink alias — RESOLVED (both
   items, 2026-08-19).** The two previously-open flags (below) are now **closed as full renames**, on
   Jack's direct instruction this session. Jack, verbatim, when asked whether to also rename the
   `family.json` keys and the symlink alias (given a key rename means chasing every literal lookup):
   *"I want correctness. When in this process have I shown concern for blast radius. I don't want a whiff
   of the old names. That only makes things more confusing in the future,"* and *"again, fix it all.
   blast radius be damned."* So — for anything **inside this repo** — every local key, string comparison,
   asserted gate step-name, and the symlink name renames to the new package name. The **one exception**
   (separately confirmed, NOT covered by "blast radius be damned") is the **external GitHub mirror repos**
   `jackhp95/cem-figma-connect` and `jackhp95/elm-html-intermediate-representation` — live published
   resources whose rename is a real external action needing Jack's explicit per-mirror go (same standing
   rule as `m3e-okf`'s mirror, decision #3). Concretely:
   - **family.json keys rename** (`cem-figma-connect`→`elm-cem-figma-connect` L147, `elm-html-…`→`elm-virtual-dom-…`
     L84; `m3e-okf`→`elm-m3e-okf` L-okf already in #3; `tailwind-m3e-web`→`elm-m3e-tailwind` and
     `tailwind-md3`→`elm-cem-tailwind`). Full cascade enumerated in **finding A3** (+ the okf/tailwind
     additions in Tasks 2–3): `consumer-output-drift.mjs` descriptor keys + `familySrcDir` args,
     `check-drift.test.mjs` loop, `bump.mjs` `pkgName` (`pnpm --filter`), `gate-all.mjs:434` label,
     `gate-all-expected-steps.json` step-name assertions, `snapshot-refs.json` keys, `check-cc-elm-refs.mjs`
     segment, `check-elm-shape-drift.mjs` name label, `measure-docs-size.mjs` published-name key.
   - **elm-cem IR symlink alias renames** to `elm-virtual-dom-intermediate-representation` (Step 1.3) +
     the pnpm-workspace exclusion glob (Step 1.6). **Verified this session:** no `elm.json`
     `source-directories` under `core/elm-cem` actually consumes the alias, so the earlier "would force
     `source-directories` edits" rationale was unfounded — the alias rename is symlink-name + glob only.

**Open flags carried into execution (genuinely unresolved — surface to Jack, NOT silently swept):**
- **IR `publish-mirror-state.json` key stays old — a deliberate mismatch until the external mirror
  renames.** The briefing assumed `publish-mirror-state.json`'s key was "pure local bookkeeping, no URL to
  preserve"; **verified false** — the automated `check-mirror-drift.mjs` (a `gate-all` step) reads
  `state[name]` and derives the external mirror as `jackhp95/${name}`. So this key **cannot** rename until
  the live mirror `jackhp95/elm-html-intermediate-representation` is itself renamed (Jack's reserved
  external action). Net for IR after this wave: `family.json` key = `elm-virtual-dom-…` (new), but
  `publish-mirror-state.json` key = `elm-html-…` (old) — each correct for its own gate (local vs.
  automated-mirror). **Whoever renames the external mirror must, in the same action, rename this key.**
  (cfc/okf/tailwind have no `publish-mirror-state.json` entry, so this only affects IR.) See finding A3.
- **family.json key ↔ manual `publish-mirror.mjs` target coupling.** `publish-mirror.mjs` derives the
  push target `jackhp95/${family-key}`. It is manual + gated (never in automated `gate-all`), so the
  key rename is safe for all automated gates now; but the **next** `publish-mirror.mjs` run for a renamed
  package will target `jackhp95/<new-name>` — which must coincide with the external mirror rename. Flagged
  so the eventual publisher pairs the two, not a blocker for this wave. See finding A3 coupling note.
**Resolved 2026-08-19 (final rename-sweep pass — the last two formerly-open items, both closed as full
renames per Jack's directive "rename everything consistently"):**

7. **`check-coverage-map.mjs` `REQUIRED_CONSUMERS` + `coverage-map.json` consumer values — RENAME
   (Step 1.7d).** The earlier flag (kept these as "separate facts-bundle scope") was based on a wrong
   premise; **corrected this session:** `check-coverage-map.mjs` **is** a `gate-all` step (`gate-all.mjs:403`,
   `gate-all-expected-steps.json:24`), and its `REQUIRED_CONSUMERS` array (L33–38) is the closed set every
   `"consumer"` in `coverage-map.json` must belong to — so the array + the 146 consumer values (+ 10 prose
   spots) **rename in lockstep** (one atomic edit) or the gate fails. It is **load-bearing for automated
   gate-all**, not deferrable. No mirror/URL inside coverage-map.json → no carve-out. Names:
   `m3e-okf`→`elm-m3e-okf` (53), `tailwind-m3e-web`→`elm-m3e-tailwind` (12),
   `cem-figma-connect-{matcher,elm-emitter}`→`elm-cem-figma-connect-{matcher,elm-emitter}` (40+41). Audit
   *prose* (coverage-audit.md, scorecard, diffs, schema.json descriptions) is non-gate-read → Task 6.
8. **`family.json` cfc `copyFidelity` entries `.claude-memory/cem-figma-connect-state.md` (L174) +
   `test/fixtures/tailwind-m3e-web-0.1.0/` (L171) — RENAME (Step 1.7e), MIRROR-COUPLED.** Correction to the
   earlier "keep matching the physical file inside the package" note: **verified this session** that
   `authorizedAbsent*` entries are **external-cfc-mirror** paths (`copy-fidelity.mjs:115,119` compares the
   local package against the `snapshot-refs.json`-pinned mirror snapshot), not local files — neither file
   exists locally. So: the gate **SKIPs** when the snapshot is absent (normal gate-all) → renaming the local
   strings is safe for automated gate-all **now**; but a materialized-snapshot run flags the mirror's
   still-old-named files as `missing` until the mirror content is renamed. **Paired-rename flag (same
   discipline as item under Open flags above): whoever renames the external cfc mirror must, in the same
   action, rename `.claude-memory/*-state.md` and the `tailwind-m3e-web-0.1.0/` fixture dir inside the
   mirror.** Version `0.1.0` is unchanged; upstream `test/fixtures/m3e-web-2.7.0/` stays.

**New load-bearing spots the final sweep surfaced (folded into finding A2 addendum, not previously
enumerated):** the IR published name `jackhp95/elm-html-intermediate-representation` also lives in
`core/elm-cem/bin/{family-deps,registry-check,validate}.js` (string-literal special-cases — Task 1),
`core/elm-cem/tests/*.test.mjs` (Task 1), `brands/m3e/inputs/cem/config/slots.json` (the `_families`
config template that **generates** the family `elm.json` deps — Task 4, in-place, the one hit the Task-1
`grep → zero` caveat didn't cleanly place), `brands/m3e/outputs/elm-m3e/packages.json` + `measure-docs.cjs`
(Task 4). All were covered by finding A2's `grep → zero` gate but are now explicit.

---

## Rename-sweep verification (2026-08-19 fold-in) — every functional hit accounted for

This plan is **doc-only** (no `git mv`/code edits executed yet), so a whole-repo grep still returns the
old names everywhere — the evidence below is that **every functional occurrence is now covered by a
concrete plan step**, and that the deliberately-preserved mirror identities are the only non-cosmetic
hits left un-renamed. Command run this session (excludes `node_modules`, `.git`):

```
grep -rIn 'cem-figma-connect\|elm-html-intermediate-representation' tools/
```

**35 functional (non-comment) `tools/` lines**, each mapped:

| Class | Lines | Covered by |
|---|---|---|
| Path refs (`core/`→`pipeline`/`packages` + rename) | `check-emit-determinism-cfc.mjs:39`, `check-elm-shape-drift.mjs:133`, `gen-figma-config.mjs:46`, `measure-docs-size.mjs:77`, `family.json:85,148` (srcDir), `gen-hooks.mjs:42,46`, `bump.mjs:27,28,43,44` | findings A, E, F, G, I, K, L (pre-existing) |
| Table keys / name-identity / step-name assertions | `family.json:84,147` (keys), `family.json:158` (cache path), `consumer-output-drift.mjs:44,45,46`, `check-drift.test.mjs:128`, `bump.mjs:41` (pkgName), `gate-all.mjs:434` (label), `gate-all-expected-steps.json:10,11,16,17,32,33`, `check-cc-elm-refs.mjs:46`, `check-elm-shape-drift.mjs:132`, `measure-docs-size.mjs:76`, `snapshot-refs.json:8` (**key**) | **finding A3 → Step 1.7c** (+ okf/tailwind siblings in Tasks 2–3) |
| **Mirror identities — deliberately preserved (carve-out)** | `publish-mirror-state.json:28` (key → `jackhp95/${name}` mirror), `snapshot-refs.json:8` (`repo` URL **value**) | finding A3 carve-out + Decisions log open-flags |
| **Formerly flagged — now RESOLVED as renames** | `check-coverage-map.mjs:33-38` (facts-bundle audit consumer names — gate-all-wired), `family.json:171,174` (cfc `copyFidelity` bookkeeping — mirror-coupled) | **Step 1.7d** (coverage-map, lockstep) + **Step 1.7e** (cfc entries, paired-rename flag) — Decisions log #7, #8 |

**Result: zero un-accounted functional hits.** The only `tools/` occurrences that survive execution are
(1) the two mirror identities above (intended — external mirrors stay until Jack's explicit per-mirror
rename), (2) the two flagged-for-scope items, and (3) prose/comments, which Task 6's cosmetic sweep
(finding V) clears. Whole-repo hits **outside `tools/`** (VISION.md, README, `docs/**`, `brands/**`,
`core/**` SKILL/README/spec prose) are either the packages' own docs that move+rename with them, the
`elm.json` `name`/dependency strings enumerated in **finding A2**, or narrative prose batched to Task 6 —
none introduce a new load-bearing surface beyond what findings A/A2/A3/T already enumerate. At execution
time, the per-task `grep … → zero hits` gates in Steps 1.7b/1.7c, 4.3b, and each task's re-grep are the
final machine check that the sweep landed clean.

### Final exhaustive 4-string whole-repo grep (2026-08-19 — third verification pass)

The first two passes scoped to `tools/` and to the IR published name; this pass grepped the **entire repo**
(excluding `node_modules`, `.git`, `.cache`, and the 3 pending-merge `.claude/worktrees/agent-*` dirs —
Jack's separate in-flight work) for **all four** old strings, to catch any residue like the
`coverage-map.json` class the earlier passes missed. Command:

```
rg -c 'cem-figma-connect|elm-html-intermediate-representation|m3e-okf|tailwind-m3e-web' \
  --glob='!node_modules/**' --glob='!.git/**' --glob='!.cache/**' \
  --glob='!.claude/worktrees/agent-a8e48485eed5250b1/**' \
  --glob='!.claude/worktrees/agent-adf03debc8e3b774c/**' \
  --glob='!.claude/worktrees/agent-ae099ba76362fbf0d/**'
```

**Whole-repo matching-line counts:** `cem-figma-connect` **776**, `elm-html-intermediate-representation`
**247**, `m3e-okf` **380**, `tailwind-m3e-web` **814**. As expected for a doc-only plan (nothing renamed
yet), the old names still appear everywhere. The point of this pass is that **every hit falls into an
accounted-for class** — no un-planned load-bearing surface remains. By class:

| Class | Where | Accounting |
|---|---|---|
| Functional `tools/` gate scripts | the ~35 lines in the table above | findings A–U + A3 → Steps 1.7/2/3/4 |
| **Facts-bundle gate data (`coverage-map.json` + `check-coverage-map.mjs`)** | 146 `"consumer"` values + `REQUIRED_CONSUMERS` array + 10 prose | **NEWLY FOLDED IN → Step 1.7d** (gate-all-wired, lockstep) |
| **cfc `copyFidelity` mirror-coupled bookkeeping** | `family.json:171,174` | **NEWLY FOLDED IN → Step 1.7e** (paired-rename flag) |
| **IR published name in elm-cem bin/test + slots.json + packages.json/measure-docs.cjs** | 12 functional lines | **NEWLY ENUMERATED → finding A2 addendum** (was gate-covered, now explicit; `slots.json` is the one mis-placed hit) |
| `elm.json` `name`/dependency cascade | 5 elm.json (finding A2) + the addendum above | Tasks 1 + 4, `grep → zero` gates |
| Package-owned content that **moves+renames with its package** | `core/cem-figma-connect/**` (incl. 200+ generated `*.figma.ts`), `core/elm-html-intermediate-representation/**`, `core/tailwind-md3/**`, `brands/m3e/outputs/{elm-m3e,m3e-api-okf,tailwind-m3e-web}/**` | git mv in Tasks 1–4; internal content follows the dir (generated `*.figma.ts` regenerate from the renamed cfc profile) |
| `dist/` build artifacts (`docs/dist/elm*.js`, `*/index.html`) | elm-pages SSG output under elm-m3e docs | regenerated by build, never hand-edited (moves with docs, Task 5) |
| `pnpm-lock.yaml` | workspace lockfile | regenerated by `pnpm install` after each move (Task 0+) — not hand-edited |
| Narrative prose / historical docs | `docs/plans/**`, `docs/superpowers/**`, `docs/reviews/**`, `README.md`, `VISION.md`, `GAUNTLET-LEDGER.md`, package READMEs/SKILLs/CHANGELOGs, facts-bundle audit `.md` | Task 6 cosmetic "no whiff" sweep (finding V) — none gate-read; historical handoffs/reviews are immutable records left as-is |
| Comment-only refs in `tools/**` + `hooks/pre-push` | finding V + the added cosmetic-comment list | Task 6 (pre-push is regenerated) |
| **Mirror carve-outs — deliberately preserved** | `publish-mirror-state.json:28` key, `snapshot-refs.json:8` `repo` URL value, the two cfc `copyFidelity` entries' *external* counterparts | stay old until Jack's explicit per-mirror rename (Decisions log open-flags + #8) |
| This plan doc | `docs/plans/2026-08-19-repo-shape-v2-wave1-plan.md` (carries both old **and** new names by design) | n/a — it is the spec |

**Result: every whole-repo hit is accounted for. The only genuinely-new residue this third pass found
beyond the prior two is the three "NEWLY …" rows above** — the `coverage-map.json`/`check-coverage-map.mjs`
gate pair (Step 1.7d), the two mirror-coupled cfc `copyFidelity` entries (Step 1.7e), and the
`jackhp95/…IR…` dependents in elm-cem bin/tests + `slots.json` + `packages.json`/`measure-docs.cjs`
(finding A2 addendum). All are now folded into concrete steps. No further un-planned load-bearing surface
exists; the per-task `grep → zero` gates remain the machine check at execution.

## Self-review notes

- **All 7 scope items covered:** core→pipeline (Task 1), packages extraction (Task 1), tailwind
  split (Task 2), docs extraction (Task 5), m3e-okf rename (Task 3), outputs→generated umbrella
  (Tasks 2–5 collectively), html relocation (Task 1). Sequenced dependency-first, not
  scope-list-order.
- **Grep sweep re-verified against current state**, not copied from the 2026-08-18 plan — every
  `family.json`/`tools/*` line number and literal was read this session. New gaps the old plan
  didn't have: `check-single-cem-facts.mjs` SEARCH_ROOTS (finding M), `check-m3e-5pkg.mjs`
  (finding N), the two symlink retargets (finding S), `elm-cem`'s test `elm.json` IR refs
  (finding T), and the depth-changes that the same-depth 2026-08-18 moves never triggered.
- **Documented double-edits** (findings C/E/H): 4 tool refs to docs paths are edited to an
  interim `generated/package/elm-m3e/docs/…` in Task 4, then final `generated/docs/elm-m3e-docs/…`
  in Task 5 — a deliberate consequence of relocating elm-m3e before extracting docs (which
  minimizes edits to docs' many internal refs; see Architecture).
- **Depth arithmetic corrected** vs. an early sub-agent sweep: docs stays depth-5→depth-5; the
  break is un-nesting, not depth.
- **All live decisions folded into the task bodies**, with the condensed trail + rationale kept in the
  "Decisions log." The 6 live decisions (2 package renames, okf consistency, gen-facts-runner comment,
  docs labeling, **and the full-rename resolution #6**) are stated directly where they execute. The two
  formerly-open flags (cfc/IR `family.json` keys; IR symlink alias) are now **resolved as full renames**
  (decision #6, finding A3 + Step 1.7c). The **last two formerly-open flags — `check-coverage-map.mjs`
  audit names and the two `family.json` cfc `copyFidelity` entries — are now ALSO resolved as renames**
  (decisions #7/#8, Steps 1.7d/1.7e; the coverage-map pair is gate-all-wired so it renames in lockstep,
  the cfc entries are mirror-coupled so they carry a paired-rename flag). The only genuinely-open items
  left are the **mirror-coupling flags**: the IR `publish-mirror-state.json` key stays old until the
  external mirror renames; `publish-mirror.mjs`'s `jackhp95/${family-key}` target and the two cfc
  `copyFidelity` external counterparts likewise pair with their mirror rename — all surfaced in the
  Decisions log, none blocking this wave (local gate-all stays green throughout).
- **Rename-sweep completeness (2026-08-19 fold-in):** re-grepped `tools/` first-hand; found and folded
  in the load-bearing spots the earlier passes missed — `gate-all-expected-steps.json` step-name
  assertions (all renames), `consumer-output-drift.mjs` descriptor keys + `familySrcDir` args,
  `check-drift.test.mjs` key loop, `bump.mjs` `pkgName` `pnpm --filter` names (cfc/okf/tailwind),
  `check-cc-elm-refs.mjs:46` sibling segment, `measure-docs-size.mjs:76` published-name key,
  `check-elm-shape-drift.mjs:132` label. **Corrected two briefing assumptions against current code:**
  (a) the claimed `gate-all.mjs` `pkg.name === "cem-figma-connect"` comparison **does not exist** on this
  branch (main moved) — the real load-bearing surface is `gate-all-expected-steps.json`; (b)
  `publish-mirror-state.json`'s key is **not** "pure local bookkeeping" — it derives the external mirror,
  so it is preserved, not renamed. See the "Rename-sweep verification" section for the full mapping.
- **Out-of-scope section** mirrors the spec's deferred set so a reader isn't left wondering why the
  explosion / docs-codegen / other brands aren't here.
