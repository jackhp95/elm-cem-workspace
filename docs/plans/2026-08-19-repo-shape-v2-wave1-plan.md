# Repo Shape v2 — Wave 1 Execution Plan

**Status: ready to execute (not started).** Written 2026-08-19 on branch
`plan/repo-shape-v2-wave1` (off `spec/repo-shape-v2-research`, off `main`).

**Design of record:** `docs/superpowers/specs/2026-08-19-repo-shape-v2-design.md`
— specifically **§9 "Resolved decisions"** (the Jack-confirmed live-session record)
and its **"Net effect: what's actually in this wave"** summary. §9 supersedes §0–§8
wherever they conflict. This plan executes §9's wave-1 slice only; everything §9 marks
deferred is enumerated under "Out of scope" below.

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

1. `core/` → `pipeline/` (brand-agnostic machinery) — §9/#5.
2. Extract the two truly-foundational libs to a new top-level `packages/` — §9/#3 + the
   IR's dictated placement.
3. `tailwind-md3` → `pipeline/elm-cem-tailwind` + `tailwind-m3e-web` →
   `brands/m3e/generated/style/elm-m3e-tailwind` (finish the split) — §9/#1.
4. Extract the docs site to `brands/m3e/generated/docs/elm-m3e-docs` with an internal
   `generated/`/`authored/` split — §9/#9.
5. `m3e-okf` → `elm-m3e-okf`, relocate to `brands/m3e/generated/okf/` — §9/#10.
6. `brands/m3e/outputs/` → `brands/m3e/generated/{package,okf,style,docs}/` — the umbrella
   move (item 6 of scope).
7. Relocate the html brand: `elm-typed-html` → `brands/html/generated/package/`,
   `config/config.json` → `brands/html/inputs/config.json` — §9/#8.

**Not in this wave** (§9/#4, #7, #9-partial, #8-partial): the 5-package explosion, the
`packages.json` rewrite, the `-elements`/`-components` naming inversion, the 3 docs codegen
wins, the guide-markdown migration, and every brand beyond m3e + html. See "Out of scope."

## Architecture

Seven sequential, independently-gated tasks (Task 0 is an additive no-op safety net).
Ordering is dependency-driven, not scope-list order:

- **Task 1 (foundation)** does the `core/`→`pipeline/` rename, the `packages/` extraction,
  AND the html-brand relocation together — because `elm-typed-html`, `elm-cem`'s IR symlink,
  and `elm-cem`'s test `elm.json`s all reference the same IR/`elm-cem` dirs that move here.
  Splitting them would force provisional double-edits (move to `pipeline/`, then re-move).
  Doing them atomically means every cross-reference is edited **once, to its final value**.
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
| `core/cem-figma-connect` → `pipeline/cem-figma-connect` | 2 | 2 | 0 | none (name unchanged — see Open Q #2) |
| `core/elm-html-intermediate-representation` → `packages/…` | 2 | 2 | 0 | none for the pkg itself; **its referrers change `core/`→`packages/`** |
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
| `cem-figma-connect` | `core/cem-figma-connect` (L148) | `pipeline/cem-figma-connect` | 1 |
| `elm-cem-facts` | `core/elm-cem/facts` (L144) | `pipeline/elm-cem/facts` | 1 |
| `elm-html-intermediate-representation` | `core/elm-html-intermediate-representation` (L85) | `packages/elm-html-intermediate-representation` | 1 |
| `elm-typed-html` | `core/elm-typed-html` (L93) | `brands/html/generated/package/elm-typed-html` | 1 |
| `tailwind-m3e-web` | `brands/m3e/outputs/tailwind-m3e-web` (L122) | `brands/m3e/generated/style/elm-m3e-tailwind` | 2 |
| `m3e-okf` | `brands/m3e/outputs/m3e-api-okf` (L97) | `brands/m3e/generated/okf/elm-m3e-okf` | 3 |
| `elm-m3e` | `brands/m3e/outputs/elm-m3e` (L9) | `brands/m3e/generated/package/elm-m3e` | 4 |

Notes: `material-okf` (L116, `brands/m3e/inputs/material-okf`) is **unchanged** this wave.
`m3e-okf`'s `pnpmFilterName: "m3e-docs"` (L98) is a pre-existing package-name mismatch
(its `package.json` `name` is `m3e-docs`) — **out of scope, leave as-is** (Open Q #3).
`elm-m3e`'s `authorizedExtraPrefixes: ["elm-m3e-families/"]` (L76) is a relative-within-srcDir
prefix and needs **no** change when `elm-m3e` relocates. There is **no `tonal-palette-oklch`
or `tailwind-md3` entry** in `family.json` today (verified) — nothing to edit for those two.

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

- L27–28: `import … from "../core/cem-figma-connect/src/tokens/{classify-delta,token-change-report}.mjs";` → `"../pipeline/cem-figma-connect/…"` (**Task 1**).
- L34: `const ELM_M3E = path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e");` → `generated/package/elm-m3e` (**Task 4**).
- L35: `const PAGES_ELM_REL = "brands/m3e/outputs/elm-m3e/docs/.elm-pages/Pages.elm";` → interim `…/generated/package/elm-m3e/docs/…` (**Task 4**), then `…/generated/docs/elm-m3e-docs/.elm-pages/Pages.elm` (**Task 5**). Double-edit.
- L43–44: `path.join(repoRoot, "core", "cem-figma-connect", "profiles", …)` (×2) → `"pipeline", "cem-figma-connect", …` (**Task 1**).
- L49: `path.join(repoRoot, "brands", "m3e", "outputs", "m3e-api-okf", "data", "cem-facts.json")` → `generated/okf/elm-m3e-okf/…` (**Task 3**).
- L53: `path.join(repoRoot, "brands", "m3e", "outputs", "tailwind-m3e-web", "data", "cem-facts.json")` → `generated/style/elm-m3e-tailwind/…` (**Task 2**).
- L318: `path.join(repoRoot, "brands", "m3e", "outputs", "tailwind-m3e-web", "package.json")` → `generated/style/elm-m3e-tailwind/package.json` (**Task 2**).

### F. `tools/gen-hooks.mjs` (verified — the 7-entry pre-push target list, L40–48)

- L40–41: `core/elm-cem/hooks/pre-push`, `core/elm-cem/templates/pre-push` → `pipeline/elm-cem/…` (**Task 1**).
- L42: `core/elm-html-intermediate-representation/hooks/pre-push` → `packages/elm-html-intermediate-representation/hooks/pre-push` (**Task 1**).
- L43: `core/elm-review-cem/hooks/pre-push` → `pipeline/elm-review-cem/…` (**Task 1**).
- L44: `core/elm-typed-html/hooks/pre-push` → `brands/html/generated/package/elm-typed-html/hooks/pre-push` (**Task 1**).
- L45: `brands/m3e/outputs/m3e-api-okf/hooks/pre-push` → `brands/m3e/generated/okf/elm-m3e-okf/hooks/pre-push` (**Task 3**).
- L46: `core/cem-figma-connect/hooks/pre-push` → `pipeline/cem-figma-connect/…` (**Task 1**).
- L48: `const ELM_M3E_TARGET = "brands/m3e/outputs/elm-m3e/hooks/pre-push";` → `generated/package/elm-m3e/hooks/pre-push` (**Task 4**).

### G. `tools/check-elm-shape-drift.mjs` (verified)

- L48: `} from "../core/elm-cem/src/elm-shape.mjs";` → `"../pipeline/elm-cem/src/elm-shape.mjs"` (**Task 1**).
- L133: `file: "core/cem-figma-connect/profiles/m3-kit/emitters/elm.mjs",` → `"pipeline/cem-figma-connect/…"` (**Task 1**).
- L142: `file: "brands/m3e/outputs/elm-m3e/docs/scripts/examples-gen/lib/to-elm.mjs",` → interim `…/generated/package/elm-m3e/docs/…` (**Task 4**), then `…/generated/docs/elm-m3e-docs/scripts/examples-gen/lib/to-elm.mjs` (**Task 5**). Double-edit.

### H. `tools/check-cc-elm-refs.mjs` (verified)

- L38: `path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e", "src")` → `generated/package/elm-m3e/src` (**Task 4**).
- L39: `path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e", "docs", "vendor", "elm-foundation")` → interim `generated/package/elm-m3e/docs/vendor/elm-foundation` (**Task 4**), then `generated/docs/elm-m3e-docs/vendor/elm-foundation` (**Task 5**). Double-edit.
- L45: the `CC_ELM_DIR` list contains `"core"` as a path segment for `core/cem-figma-connect/generated/m3-kit/elm` → `"pipeline"` (**Task 1**). Read L44–49 in full and swap the `core`→`pipeline` segment.

### I. `tools/gen-figma-config.mjs` (verified)

- L46: `const cfcDir = path.join(repoRoot, "core", "cem-figma-connect");` → `"pipeline", "cem-figma-connect"` (**Task 1**).
- The `elm-m3e` config dir is resolved via the `elm-m3e` path; when `elm-m3e` relocates (Task 4) grep this file again for any `brands/m3e/outputs/elm-m3e` literal and swap to `generated/package/elm-m3e`. (Comment refs at L9, L23 are cosmetic — Task 6.)

### J. `tools/ab-elm-cem.sh` / `tools/ab-elm-m3e-split.sh` (verified)

- `ab-elm-cem.sh` L25: `WORKSPACE_ELM_CEM="$REPO_ROOT/core/elm-cem"` → `"$REPO_ROOT/pipeline/elm-cem"` (**Task 1**). L26: `ELM_M3E="${ELM_M3E:-$REPO_ROOT/brands/m3e/outputs/elm-m3e}"` → `generated/package/elm-m3e` (**Task 4**).
- `ab-elm-m3e-split.sh` L42: same `WORKSPACE_ELM_CEM` fix (**Task 1**). L43: same `ELM_M3E` fix (**Task 4**).

### K. `tools/measure-docs-size.mjs` (verified)

- L77: `process.env.IR_SRC || path.join(ROOT, "core/elm-html-intermediate-representation/src")` → `"packages/elm-html-intermediate-representation/src"` (**Task 1**).
- L78: `process.env.FACTS_SRC || path.join(ROOT, "core/elm-cem/facts/src")` → `"pipeline/elm-cem/facts/src"` (**Task 1**).
- L81: `const DEFAULT_TARGETS = ["brands/m3e/outputs/elm-m3e/elm-m3e-icons"];` → `["brands/m3e/generated/package/elm-m3e/elm-m3e-icons"]` (**Task 4**).

### L. `tools/check-emit-determinism-cfc.mjs` (verified)

- L39: `const pkgDir = path.join(repoRoot, "core", "cem-figma-connect");` → `"pipeline", "cem-figma-connect"` (**Task 1**).

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
  - "!pipeline/*/elm-html-intermediate-representation"   # the elm-cem IR symlink (was !core/*/…)
```

Note: `brands/*/outputs/*` today ALSO matches `brands/m3e/outputs/elm-m3e/docs` (via
`brands/*/outputs/*/*`) — that is how the docs package (`name: m3e-builder-docs`, verified)
is discovered today. The `brands/*/generated/*/*` glob covers `elm-m3e-docs` after Task 5.

### S. Symlinks (verified — 2 exist, both need retargeting)

1. `core/elm-cem/elm-html-intermediate-representation -> ../elm-html-intermediate-representation`
   → moves with `elm-cem` to `pipeline/elm-cem/…`; IR moves to `packages/`. Retarget to
   `../../packages/elm-html-intermediate-representation` (**Task 1**). The exclusion glob
   (item R) tracks it: `!pipeline/*/elm-html-intermediate-representation`.
2. `brands/m3e/outputs/elm-m3e/config -> ../../inputs/cem/config` → moves with `elm-m3e` to
   `brands/m3e/generated/package/elm-m3e/config`. Retarget `../../inputs/cem/config` →
   `../../../inputs/cem/config` (+1 segment; **Task 4**).

### T. Package-internal cross-boundary relative refs (verified)

**`core/elm-typed-html` (→ `brands/html/generated/package/elm-typed-html`, +3 depth) — Task 1:**
- `scripts/regen.sh` L7: `ELM_CEM_BIN="${ELM_CEM_BIN:-../elm-cem/bin/elm-cem.js}"` (resolves to `core/elm-cem` today) → `../../../../../pipeline/elm-cem/bin/elm-cem.js`. Also references `$REPO_ROOT/manifest/native.cem.json`, `$REPO_ROOT/config/config.json`, `$REPO_ROOT/src` — all package-internal (`REPO_ROOT` computed from `$0`), so they follow the package move automatically. **But `config/config.json` physically relocates to `brands/html/inputs/config.json`** — update the `--config-from` arg to point there (`$REPO_ROOT/../../../inputs/config.json` from `brands/html/generated/package/elm-typed-html`, i.e. 3 up to `brands/html`, then `inputs/config.json`). See Task 1 Step for exact value.
- `scripts/validate.mjs` L62: `path.resolve(repoRoot, "../elm-html-intermediate-representation/src")` → `path.resolve(repoRoot, "../../../../../packages/elm-html-intermediate-representation/src")`. L75: `path.resolve(repoRoot, "../elm-cem/facts/src")` → `path.resolve(repoRoot, "../../../../../pipeline/elm-cem/facts/src")`.
- `package.json` L20: `"hooks:install": "node ../../tools/hooks-install.mjs"` → `"node ../../../../../tools/hooks-install.mjs"`.
- `review/elm.json` L5–8 (`source-directories`): `../src` (package-internal, keep), `../../elm-review-cem/src` → `../../../../../../pipeline/elm-review-cem/src`, `../../elm-cem/facts/src` → `../../../../../../pipeline/elm-cem/facts/src`, `../../elm-html-intermediate-representation/src` → `../../../../../../packages/elm-html-intermediate-representation/src`. (From `review/` at depth 6: 6 `../` reaches root.)
- `verify/elm.json` L3 (`source-directories`): `[ "src", "bad", "../src", "../../elm-html-intermediate-representation/src", "../../elm-cem/facts/src" ]` → keep `src`/`bad`/`../src`; `../../elm-html-intermediate-representation/src` → `../../../../../../packages/elm-html-intermediate-representation/src`; `../../elm-cem/facts/src` → `../../../../../../pipeline/elm-cem/facts/src`. (`verify/` at depth 6.)

**`core/elm-cem` (→ `pipeline/elm-cem`, depth unchanged) — Task 1** (IR leaves `core/` for `packages/`, so its sibling refs break):
- `tests/phantom/native/acid/elm.json` L7: `../../../../../elm-html-intermediate-representation/src` (5 `../` from that dir reaches `core/`) → `../../../../../../packages/elm-html-intermediate-representation/src` (+1 `../` to reach root, then `packages/`). Dir `pipeline/elm-cem/tests/phantom/native/acid` is depth 6; 6 `../` reaches root.
- `tests/phantom/acid/elm.json` L7: `../../../../elm-html-intermediate-representation/src` (4 `../` reaches `core/`) → `../../../../../packages/elm-html-intermediate-representation/src` (+1). Dir depth 5.
- Grep `core/elm-cem` for any other `elm-html-intermediate-representation` relative ref before committing; the two above are the ones that cross the `core/`→`packages/` boundary this session's sweep found.

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
  tailwind-relevant path" with the absorb — the grep shows it is shared substrate. Flagged
  as Open Q #4 for confirmation; the plan proceeds on the evidence.)

### V. Cosmetic-only prose/comment references (Task 6, non-blocking)

`tools/gen-hooks.mjs:8`, `tools/check-single-cem-facts.mjs:5,65`, `tools/install-toolchains.mjs:8`,
`tools/publish-mirror.mjs:274`, `tools/gen-figma-config.mjs:3,5,7,20,9,23`, `tools/check-cc-elm-refs.mjs:6`,
`tools/check-elm-shape-drift.mjs:5`, `tools/ab-elm-cem.sh:12`, `tools/ab-elm-m3e-split.sh:6,30`,
`tools/gate-all.mjs:44`, `tools/check-single-cem-facts.mjs:26,28`, `tools/check-drift.mjs:8,35`,
`tools/lib/check-drift-core.mjs:49,70,293`, `tools/lib/consumer-output-drift.mjs:72`,
`tools/check-drift.test.mjs:110`, `tools/lib/regen.mjs:9,10` — all mention old `core/…` or
`brands/m3e/outputs/…` paths **in comments only**. Batched to Task 6; anything functional
would already have failed a gate run.

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
- `core/cem-figma-connect` → `pipeline/cem-figma-connect` (name unchanged — Open Q #2)
- `core/elm-html-intermediate-representation` → `packages/elm-html-intermediate-representation`
- `core/tonal-palette-oklch` → `packages/tonal-palette-oklch`
- `core/elm-typed-html` → `brands/html/generated/package/elm-typed-html`
- `core/elm-typed-html/config/config.json` → `brands/html/inputs/config.json`

- [ ] **Step 1.1: Create parents + move machinery to `pipeline/`**

```bash
mkdir -p pipeline packages
git mv core/elm-cem pipeline/elm-cem
git mv core/elm-cem-compose pipeline/elm-cem-compose
git mv core/elm-review-cem pipeline/elm-review-cem
git mv core/cem-figma-connect pipeline/cem-figma-connect
```

- [ ] **Step 1.2: Extract the two foundational libs to top-level `packages/`**

```bash
git mv core/elm-html-intermediate-representation packages/elm-html-intermediate-representation
git mv core/tonal-palette-oklch packages/tonal-palette-oklch
```

- [ ] **Step 1.3: Retarget the `elm-cem` IR symlink (finding S #1)**

```bash
rm pipeline/elm-cem/elm-html-intermediate-representation
ln -s ../../packages/elm-html-intermediate-representation pipeline/elm-cem/elm-html-intermediate-representation
git add pipeline/elm-cem/elm-html-intermediate-representation
```

- [ ] **Step 1.4: Relocate the html brand**

```bash
mkdir -p brands/html/generated/package brands/html/inputs
git mv core/elm-typed-html brands/html/generated/package/elm-typed-html
git mv brands/html/generated/package/elm-typed-html/config/config.json brands/html/inputs/config.json
# remove the now-empty config/ dir inside the package if git leaves it
rmdir brands/html/generated/package/elm-typed-html/config 2>/dev/null || true
```

Note per §9/#8 and the research spec §3: `elm-typed-html`'s CEM manifest is `manifest/native.cem.json`
(a committed file, moves with the package) — there is **no** live `custom-elements-manifest.json`
to place under `brands/html/inputs/`; do not invent one. `brands/html/inputs/` holds only
`config.json`.

- [ ] **Step 1.5: `core/` should now be empty except `tailwind-md3`**

```bash
ls core/   # expect only: tailwind-md3
```

Leave `tailwind-md3` in `core/` — Task 2 renames+moves it and removes the empty `core/`.

- [ ] **Step 1.6: `pnpm-workspace.yaml` — flip the IR-exclusion glob**

Change `!core/*/elm-html-intermediate-representation` → `!pipeline/*/elm-html-intermediate-representation`.
(Old `core/*`, `brands/*/outputs/*` globs still stand — `tailwind-md3` + the m3e outputs still
live under them until Tasks 2–5.)

- [ ] **Step 1.7: Fix all `tools/*` files with `core/`→`pipeline/`/`packages/` refs**

Apply every **Task 1** entry from findings A–R above, file by file, using the exact current
strings cited: `family.json` (elm-cem, elm-cem-compose, elm-review-cem, cem-figma-connect,
elm-cem-facts, IR, elm-typed-html), `gate-all.mjs` (L195 walk, L268), `check-drift.mjs` (L90),
`bump.mjs` (L27–28, L43–44), `gen-hooks.mjs` (L40–44, L46), `check-elm-shape-drift.mjs` (L48, L133),
`check-cc-elm-refs.mjs` (L45), `gen-figma-config.mjs` (L46), `ab-elm-cem.sh` (L25),
`ab-elm-m3e-split.sh` (L42), `measure-docs-size.mjs` (L77–78), `check-emit-determinism-cfc.mjs` (L39),
`check-single-cem-facts.mjs` (L86–88), `lib/regen.mjs` (L34), `install-toolchains.mjs` (L54).

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
git commit -m "reorg(shape-v2): core/->pipeline/, extract IR+tonal to packages/, relocate html brand"
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

- [ ] **Step 3.2: Rename the package**

In `brands/m3e/generated/okf/elm-m3e-okf/package.json`, change the `name` field to
`elm-m3e-okf`. **Verify the current value first** — the research spec §9/#10 says it "still
literally says `m3e-okf`", while `family.json`'s `pnpmFilterName: "m3e-docs"` note (L98–99)
claims the `name` is `m3e-docs`. Read the actual `package.json` and set `name: "elm-m3e-okf"`
regardless of which it currently is. If the `family.json` key/`pnpmFilterName` must track the
new name, update L98 `pnpmFilterName` accordingly (see Step 3.4). (This resolves the long-standing
mismatch noted in `family.json` L98–99 — but confirm it's desired, Open Q #3.)

- [ ] **Step 3.3: Fix the package's internal cross-boundary refs (+1 depth, finding T)**

`scripts/check-skills-meta.mjs` L19 (`okf-lib.mjs`), `scripts/gen-facts.mjs` L17
(`gen-facts-runner.mjs`), `package.json` `hooks:install`, and any other `../../../../../tools`
ref — apply +1 (`../../../../../` → `../../../../../../`). Re-grep the package for
`../../../../../` and fix uniformly.

- [ ] **Step 3.4: Update `tools/family.json`**

L97 srcDir → `brands/m3e/generated/okf/elm-m3e-okf`. **Keep** the `mirror`, `bundleCopy`,
`copyFidelity` blocks (publishing/mirror config is out of scope — the mirror repo stays
`jackhp95/m3e-okf`). Update `pnpmFilterName` (L98) to match the new `package.json` `name`
if it changed. The table **key** `"m3e-okf"` may stay (it tracks the mirror identity) — do
NOT rename the key unless the mirror repo is also renamed (it isn't). Flag any residual
name/key/dir divergence in Open Q #3.

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
(§9/#7, the 5-package explosion is deferred). The `docs/` subtree moves **with** elm-m3e here
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

`review/elm.json` `source-directories` (re-read — by now the `core`→`pipeline`/`packages`
rename from Task 1 is reflected; apply +1 `../` to each cross-package entry), `package.json`
`hooks:install` + any `../../../../tools` ref, and re-grep the package **excluding `docs/`**
for `../../../../../` cross-package refs; apply +1. (The `docs/` subtree's own refs are handled
in Task 5 — do not touch `docs/` here beyond letting it ride along.)

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

Per §9/#9, also reorganize the package internals into `generated/` (facts-sourced: reference
pages, examples, search index, `Compose/Attrs.elm`, family/token pages) vs `authored/` (the
guide chapters under today's `app/Route/Guide/`). **Physical boundary + top-level
`generated/`/`authored/` split only** — do NOT migrate the 9 still-inline-Elm guide chapters
to `.md`, and do NOT touch any chapter's content/format (§9/#9 explicitly defers that).

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
- `scripts/vendor-foundation.mjs`, `scripts/vendor-tailwind-m3e-web.mjs` — vendor IR/typed-html/tailwind srcs via `../../../../../core/…`: IR → `packages/elm-html-intermediate-representation`, typed-html → `brands/html/generated/package/elm-typed-html`, tailwind → `brands/m3e/generated/style/elm-m3e-tailwind`. Recompute from the docs root (depth 5 → 5 `../` to root). **`vendor-tailwind-m3e-web.mjs` likely also needs the `tailwind-m3e-web`→`elm-m3e-tailwind` rename from Task 2** — grep it.

- [ ] **Step 5.4: Fix `docs/samples/review/elm.json`** (verified current values)

- `"src"` — local, keep.
- `"../../../src"` (→ was `elm-m3e/src`) → `"../../../../package/elm-m3e/src"`. (From `elm-m3e-docs/samples/review`, `../../../` = docs root; need `../../../../package/elm-m3e/src`.)
- `"../../../../../../../core/elm-review-cem/src"` → `"../../../../../../../pipeline/elm-review-cem/src"` (same count, `core`→`pipeline`).
- `"../../../../../../../core/elm-cem/facts/src"` → `"../../../../../../../pipeline/elm-cem/facts/src"`.
- `"../../../../../../../core/elm-html-intermediate-representation/src"` → `"../../../../../../../packages/elm-html-intermediate-representation/src"`.
- `"../../../../../../../core/elm-typed-html/src"` (if present) → `"../../../../../../../brands/html/generated/package/elm-typed-html/src"` (**re-verify** — typed-html moved to a deeper path; count `../` from `samples/review/` at docs depth 5 + 2 = 7 to root, then descend). **Read the file in full at execution time and recompute each entry.**

- [ ] **Step 5.5: Internal `generated/`/`authored/` split (§9/#9 — physical only)**

Reorganize the package internals so the "generated/docs" label is honest:
- `generated/` ← facts-sourced surface: the reference pages, `examples.*`, search index,
  `app/Compose/Attrs.elm` (header `GENERATED by scripts/gen-compose-attrs.mjs`), family/token
  route pages.
- `authored/` ← the guide chapters under `app/Route/Guide/` (18 `.elm` route modules verified:
  Accessibility, CheatSheet, FirstComponent, Glossary, Motion, Seams, Strictness, TheLayers,
  Theming, etc.) **plus** the 4 already-`.md` chapters under `docs/guides/` (EnumSafety.md,
  Glossary.md, Seams.md, TheLayers.md — verified).

**Do the split as directory moves only**, then fix the elm-pages route wiring (`app/Route/…`
paths, `elm.json` `source-directories` for the relocated `app/`/`src` subdirs) so the site
still builds. **Do NOT** convert any inline-Elm chapter to `.md` and **do NOT** edit chapter
prose (§9/#9 defers both). If the elm-pages `RouteBuilder` structure makes a clean physical
`generated/`/`authored/` filesystem split infeasible without touching route content, **stop and
raise Open Q #5** rather than forcing it — the honest-label goal must not require prose edits.

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
Leave the deferred items (§9/#4, #7, #9-partial, #8-partial) noted as still-pending.

- [ ] **Step 6.4: Final full gate-all run**

```bash
node tools/gate-all.mjs
```
Expect `GATE-ALL GREEN` (modulo the Task-0 baseline known-unrelated failure). The summary
package list should show the new names/paths: `pipeline/elm-cem`, `pipeline/elm-cem-tailwind`,
`packages/elm-html-intermediate-representation`, `packages/tonal-palette-oklch`,
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

Per §9's "Net effect" summary, these are separate later projects:

- **The 5-package explosion** — `elm-m3e` → `elm-m3e-{core,elements,components,build,facts}`
  as real standalone packages; the same for `elm-typed-html`; the `packages.json` rewrite this
  requires; the `-elements`/`-components` naming inversion execution (§9/#4, #7). `elm-m3e` and
  `elm-typed-html` stay **monolithic** internally this wave. `tools/check-m3e-5pkg.mjs`'s
  assertion of the deferred `packages.json` shape is preserved (path only), not acted on.
- **The 3 docs codegen wins** — `Route.Family` from `slots.json`, `Route.Styles/` token tables
  from the token manifest, `Installation` strings from package metadata (§9/#9).
- **The guide-markdown migration** — moving the 9 still-inline-Elm guide chapters to `.md`
  (§9/#9). This wave does the physical `generated/`/`authored/` split only; chapter content
  and format are untouched.
- **Every brand beyond m3e + html** — `svg` (blocked on an IR namespaced-node additive),
  `shoelace`, `web-awesome`, `calcite`, `fluent-ui`, `warp`, `etc/` (§9/#8). No empty brand
  dirs are scaffolded.
- **`brands/m3e/inputs/` changes** — the 10 config files stay separate, the live-resolved CEM
  stays uncommitted (§9/#6). Already landed in the 2026-08-18 reorg; no further change.
- **Publishing / mirror rewiring** — the `mirror`/`bundleCopy`/`copyFidelity` blocks in
  `family.json` keep their existing repo coordinates (e.g. `jackhp95/m3e-okf`); only `srcDir`
  values move. No `jackhp95/<name>` mirror repo is touched.
- **The 3 pending-merge worktree branches** (`.claude/worktrees/agent-{a8e48485eed5250b1,adf03debc8e3b774c,ae099ba76362fbf0d}`)
  — not touched; their content is not assumed on `main`.
- **Turbo/Nx adoption** — rejected in §6; continue on `tools/lib/gate-scheduler.mjs`.

---

## Open questions for Jack

1. **IR package rename (flagged per scope item 2 — NOT resolved here).** The name
   `elm-virtual-dom-intermediate-representation` appeared **once**, in Jack's original dictated
   tree (research spec §1a L77), describing what the package does. Unlike every other rename in
   §9, it was **never separately confirmed** in the live Q&A. This plan relocates
   `elm-html-intermediate-representation` to `packages/` **under its current name** and does not
   rename it. **Confirm separately** whether the IR should be renamed to
   `elm-virtual-dom-intermediate-representation` (or another name); if so it becomes its own
   small follow-up (a published-package rename cascades to every dependent's `elm.json`).

2. **`cem-figma-connect` rename.** The research reconciliation table (spec §1a L75) suggested
   `cem-figma-connect` → `elm-cem-figma-connect` (matching VISION.md's 2026-08-17 open question),
   but **§9 does not list this rename**, and scope item 1 enumerates it as a plain re-parent.
   This plan moves it to `pipeline/cem-figma-connect` **unchanged**. Confirm whether the
   `elm-cem-figma-connect` rename should be folded in (mechanically cheap — same class as the
   `m3e-okf` rename) or deferred.

3. **`elm-m3e-okf` name/key/mirror divergence.** After the rename, three identifiers may
   disagree: the directory (`elm-m3e-okf`), the `package.json` `name` (currently `m3e-docs` per
   `family.json` L98's note, or `m3e-okf` per spec §9/#10 — **verify at execution**), the
   `family.json` table key (`m3e-okf`), and the mirror repo (`jackhp95/m3e-okf`). This plan sets
   `package.json` `name` → `elm-m3e-okf` and leaves the mirror key/repo as `m3e-okf` (publishing
   is out of scope). Confirm this is the intended end-state, or whether the mirror repo should
   also be renamed (a separate publishing action).

4. **`gen-facts-runner.mjs` placement (finding U).** Item 3b implied both
   `component-css-utilities.mjs` and `gen-facts-runner.mjs`'s tailwind path move into
   `pipeline/elm-cem-tailwind`. The grep shows `gen-facts-runner.mjs` has **3 consumers**
   (tailwind, m3e-okf, cem-figma-connect) — it is shared substrate, so this plan **leaves it in
   `tools/lib`** and moves only the single-consumer `component-css-utilities.mjs`. Confirm this
   reading (or, if `gen-facts-runner` should become a real `pipeline/elm-cem-tailwind` export
   that m3e-okf + cem-figma-connect then depend on by workspace name, that's a larger refactor
   worth its own task).

5. **Docs `generated/`/`authored/` physical split feasibility (Task 5, Step 5.5).** §9/#9 wants
   the internal split done "at extraction time," but the elm-pages route structure (`app/Route/…`)
   may not cleanly split on the filesystem without touching route wiring or chapter content — and
   §9/#9 forbids touching chapter prose/format. If a clean directory-only split proves infeasible
   without prose edits, this plan **stops and asks** rather than forcing it. Confirm the fallback:
   (a) do the physical split even if it requires benign route-wiring edits (no prose change), or
   (b) defer the `generated/`/`authored/` split to the same later project as the guide-markdown
   migration, and this wave only relocates the docs package as-is.

---

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
- **Genuine ambiguities surfaced, not silently resolved:** 5 open questions, IR rename included
  per instruction, each cited to a spec section or grep finding.
- **Out-of-scope section** mirrors §9's deferred set so a reader isn't left wondering why the
  explosion / docs-codegen / other brands aren't here.
