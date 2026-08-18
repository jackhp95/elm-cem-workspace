# core/ vs brands/ Workspace Reorg — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize `elm-cem-workspace`'s `packages/` into `core/` (library-agnostic codegen/tooling) and `brands/m3e/{inputs,outputs}/` (M3E-specific input config and generated/enriched output), per `docs/superpowers/specs/2026-08-18-core-brands-workspace-reorg-design.md`, while keeping `node tools/gate-all.mjs` green throughout.

**Architecture:** Six sequential, independently-gated phases. Phase 1 is a no-op safety check. Phase 2 does every wholesale `git mv` (packages that don't need internal splitting) plus every hardcoded-path fix that move requires, in one commit. Phases 3–5 handle the three packages that need real surgery, not just a move: the `tailwind-m3e-web` split (new `core/tailwind-md3`), the `m3e-okf` split (`material-okf` + `m3e-api-okf`), and standing up `brands/m3e/inputs/cem`. Phase 6 is cleanup + final verification.

**Tech Stack:** pnpm workspaces, Node ESM tooling under `tools/`, Elm packages, Tailwind v4 CSS.

---

## Resolved open questions (from the spec)

### 1. Full grep sweep — every hardcoded path reference to a moved package

Enumerated below, verified against actual file contents (not paraphrased) for every entry marked **exact**. Organized by which tool/manifest file needs editing. "Depth-change risk" items are relative `../` imports that need MORE `../` segments after the move (see "Additional gaps" section below for why).

**`tools/family.json`** — `srcDir` fields (8 entries: `elm-cem`, `elm-m3e`, `elm-cem-compose`, `elm-html-intermediate-representation`, `elm-review-cem`, `elm-typed-html`, `m3e-okf`, `tailwind-m3e-web`, `elm-cem-facts`, `cem-figma-connect` — 10 total including the two nested ones).

**`tools/snapshot-refs.json`** — no functional path fields to fix (keys are package names, values are `repo`/`sha`/`bundle` — `bundle` value `tools/snapshots/elm-cem-generator.bundle` is itself under `tools/`, unaffected). The long `_comment_elm_cem` prose mentions `packages/elm-cem` — cosmetic only, fixed in Phase 6 for accuracy.

**`tools/publish-mirror-state.json`** — **verified: NO changes needed.** Keyed entirely by package name (`elm-cem`, `elm-m3e`, etc.), no path fields. (An earlier automated sweep flagged this file as needing 9 edits — that was a false positive, corrected here after direct inspection.)

**`tools/gate-all.mjs`** (exact, verified):
- Line 42: `const ELM_M3E = process.env.ELM_M3E || path.join(repoRoot, "packages", "elm-m3e");` → `path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e")`
- Line 150: `walk(path.join(repoRoot, "packages"));` (fallback-only, used if `pnpm ls -r` fails) → must walk `core/`, `brands/*/inputs/*`, `brands/*/outputs/*`, and `packages/_probe/*` — rewritten as a small helper (see Phase 2, Step 2.9).
- Line 195: `require(path.join(repoRoot, "packages", "elm-cem", "bin", "validate-facts-bundle.js"))` → `path.join(repoRoot, "core", "elm-cem", "bin", "validate-facts-bundle.js")`

**`tools/check-drift.mjs`** (exact, verified):
- Line 55: `const ELM_M3E = process.env.ELM_M3E || path.join(repoRoot, "packages", "elm-m3e");` → `brands/m3e/outputs/elm-m3e`
- Line 90: `require(path.join(repoRoot, "packages", "elm-cem", "bin", "validate-facts-bundle.js"))` → `core/elm-cem/...`
- Line 176: `const relPath = "packages/elm-m3e/docs/.elm-pages/Pages.elm";` → `"brands/m3e/outputs/elm-m3e/docs/.elm-pages/Pages.elm"`

**`tools/check-drift.test.mjs`** (exact, verified):
- Line 20: `const elmM3e = process.env.ELM_M3E || path.join(repoRoot, "packages", "elm-m3e");` → `brands/m3e/outputs/elm-m3e`
- Line 21: `const realCommittedCemFacts = path.join(repoRoot, "packages", "m3e-okf", "data", "cem-facts.json");` → `path.join(repoRoot, "brands", "m3e", "outputs", "m3e-api-okf", "data", "cem-facts.json")` (cem-facts.json is CEM-verified, M3E-specific — lands in the outputs half of the m3e-okf split, see Phase 4).

**`tools/bump.mjs`** (exact, verified):
- Line 27: `import { classifyDelta, readBaseSources } from "../packages/cem-figma-connect/src/tokens/classify-delta.mjs";` → `"../core/cem-figma-connect/src/tokens/classify-delta.mjs"`
- Line 28: `import { changesFromVerdict, runGate } from "../packages/cem-figma-connect/src/tokens/token-change-report.mjs";` → `"../core/cem-figma-connect/src/tokens/token-change-report.mjs"`
- Line 34: `const ELM_M3E = path.join(repoRoot, "packages", "elm-m3e");` → `brands/m3e/outputs/elm-m3e`
- Line 35: `const PAGES_ELM_REL = "packages/elm-m3e/docs/.elm-pages/Pages.elm";` → `"brands/m3e/outputs/elm-m3e/docs/.elm-pages/Pages.elm"`
- Lines 43–44: `path.join(repoRoot, "packages", "cem-figma-connect", "profiles", ...)` (×2) → `path.join(repoRoot, "core", "cem-figma-connect", "profiles", ...)`
- Line 49: `path.join(repoRoot, "packages", "m3e-okf", "data", "cem-facts.json")` → `path.join(repoRoot, "brands", "m3e", "outputs", "m3e-api-okf", "data", "cem-facts.json")`
- Line 53: `path.join(repoRoot, "packages", "tailwind-m3e-web", "data", "cem-facts.json")` → `path.join(repoRoot, "brands", "m3e", "outputs", "tailwind-m3e-web", "data", "cem-facts.json")`
- Line 318: `path.join(repoRoot, "packages", "tailwind-m3e-web", "package.json")` → `brands/m3e/outputs/tailwind-m3e-web/package.json`

**`tools/gen-hooks.mjs`** (exact, verified):
- Lines 40–46: the 7-entry pre-push target list — `packages/elm-cem/hooks/pre-push`, `packages/elm-cem/templates/pre-push`, `packages/elm-html-intermediate-representation/hooks/pre-push`, `packages/elm-review-cem/hooks/pre-push`, `packages/elm-typed-html/hooks/pre-push`, `packages/m3e-okf/hooks/pre-push`, `packages/cem-figma-connect/hooks/pre-push` → `core/elm-cem/...` (×2), `core/elm-html-intermediate-representation/...`, `core/elm-review-cem/...`, `core/elm-typed-html/...`, `brands/m3e/outputs/m3e-api-okf/hooks/pre-push` (m3e-okf's `hooks/` — CEM/publish-related, lands in the outputs half — see Phase 4), `core/cem-figma-connect/...`
- Line 48: `const ELM_M3E_TARGET = "packages/elm-m3e/hooks/pre-push";` → `"brands/m3e/outputs/elm-m3e/hooks/pre-push"`

**`tools/check-elm-shape-drift.mjs`** (exact, verified):
- Line 48: `} from "../packages/elm-cem/src/elm-shape.mjs";` → `"../core/elm-cem/src/elm-shape.mjs"`
- Line 133: `file: "packages/cem-figma-connect/profiles/m3-kit/emitters/elm.mjs",` → `"core/cem-figma-connect/profiles/m3-kit/emitters/elm.mjs"`
- Line 142: `file: "packages/elm-m3e/docs/scripts/examples-gen/lib/to-elm.mjs",` → `"brands/m3e/outputs/elm-m3e/docs/scripts/examples-gen/lib/to-elm.mjs"`

**`tools/check-cc-elm-refs.mjs`** (exact, verified):
- Line 38: `path.join(repoRoot, "packages", "elm-m3e", "src")` → `brands/m3e/outputs/elm-m3e/src`
- Line 39: `path.join(repoRoot, "packages", "elm-m3e", "docs", "vendor", "elm-foundation")` → same prefix swap
- Lines 44–49 (`CC_ELM_DIR`): `path.join(repoRoot, "packages", "cem-figma-connect", "generated", "m3-kit", "elm")` → `path.join(repoRoot, "core", "cem-figma-connect", "generated", "m3-kit", "elm")`

**`tools/gen-figma-config.mjs`** (exact, verified):
- Line 46: `const cfcDir = path.join(repoRoot, "packages", "cem-figma-connect");` → `core/cem-figma-connect`
- Line 47: `const elmM3eConfigDir = path.join(repoRoot, "packages", "elm-m3e", "config");` → `path.join(repoRoot, "brands", "m3e", "inputs", "cem", "config")` (this is `config/*.json`, moving to `inputs/cem/` — see Phase 5; the symlink from `elm-m3e/config` means the OLD value would also still resolve, but pointing directly at the real location is more correct and is what this file should do since it's a cross-package tool, not something invoked with `cwd: elmM3e`).

**`tools/ab-elm-cem.sh`** (exact, verified):
- Line 25: `WORKSPACE_ELM_CEM="$REPO_ROOT/packages/elm-cem"` → `"$REPO_ROOT/core/elm-cem"`
- Line 26: `ELM_M3E="${ELM_M3E:-$REPO_ROOT/packages/elm-m3e}"` → `"${ELM_M3E:-$REPO_ROOT/brands/m3e/outputs/elm-m3e}"`

**`tools/ab-elm-m3e-split.sh`** (exact, verified):
- Line 42: same `WORKSPACE_ELM_CEM` fix as above
- Line 43: same `ELM_M3E` fix as above

**`tools/measure-docs-size.mjs`** (exact, verified):
- Line 77: `process.env.IR_SRC || path.join(ROOT, "packages/elm-html-intermediate-representation/src")` → `"core/elm-html-intermediate-representation/src"`
- Line 78: `"jackhp95/elm-cem-facts": process.env.FACTS_SRC || path.join(ROOT, "packages/elm-cem/facts/src")` → `"core/elm-cem/facts/src"`
- Line 81: `const DEFAULT_TARGETS = ["packages/elm-m3e/elm-m3e-icons"];` → `["brands/m3e/outputs/elm-m3e/elm-m3e-icons"]`

**`tools/check-emit-determinism-cfc.mjs`** (exact, verified):
- Line 39: `const pkgDir = path.join(repoRoot, "packages", "cem-figma-connect");` → `core/cem-figma-connect`

**`tools/lib/gen-facts-runner.mjs`** (exact, verified):
- Line 35: `const elmM3e = process.env.ELM_M3E || path.join(repoRoot, "packages", "elm-m3e");` → `brands/m3e/outputs/elm-m3e`

**`tools/lib/regen.mjs`** (exact, verified):
- Line 33 (`elmCemCli`): `path.join(repoRoot, "packages", "elm-cem", "bin", "elm-cem.js")` → `core/elm-cem/bin/elm-cem.js`
- Line 37 (`defaultElmM3e`): `process.env.ELM_M3E || path.join(repoRoot, "packages", "elm-m3e")` → `brands/m3e/outputs/elm-m3e`

**`tools/install-toolchains.mjs`** — line 43's `const pkgsDir = path.join(repoRoot, "packages");` walk logic needs to become reorg-aware (see "Additional gaps" below — this is a *functional* fix, not a string swap).

**`pnpm-workspace.yaml`** — see Phase 1 and Phase 2, Step 2.10.

**Package-internal cross-references** (elm.json / relative imports crossing a package boundary):
- `packages/elm-typed-html/verify/elm.json` — `../../elm-html-intermediate-representation/src`, `../../elm-cem/facts/src`. **No edit needed**: both `elm-typed-html` and its targets move to `core/` together in Phase 2, same relative depth preserved.
- `packages/elm-m3e/docs/scripts/examples-gen/lib/to-elm.mjs:52` — `"../../../../../elm-cem/src/elm-shape.mjs"` → depth-change + cross-boundary, becomes `"../../../../../../../../core/elm-cem/src/elm-shape.mjs"` (8 `../` from `brands/m3e/outputs/elm-m3e/docs/scripts/examples-gen/lib/`, then descend into `core/elm-cem/src/elm-shape.mjs`).
- `packages/elm-m3e/docs/samples/review/elm.json` — 4 source-directories (`../../../../elm-review-cem/src`, `../../../../elm-cem/facts/src`, `../../../../elm-html-intermediate-representation/src`, `../../../../elm-typed-html/src`), all depth-change + cross-boundary. From `brands/m3e/outputs/elm-m3e/docs/samples/review/` (7 segments), each becomes `../../../../../../../core/<name>/...` (7 `../`, then `core/elm-review-cem/src`, `core/elm-cem/facts/src`, `core/elm-html-intermediate-representation/src`, `core/elm-typed-html/src` respectively).
- `packages/elm-m3e/docs/scripts/samples-gen/extract-samples.mjs:293` — computed via `path.posix.join("../../..", d.replace(...))`, not a literal string. Verify at runtime after the move (Phase 2 gate-all run); patch the `"../../.."` base if the computed result is wrong.
- `packages/cem-figma-connect/package.json:31` — `"elm-cem": "workspace:*"`. **No edit needed** — pnpm resolves workspace deps by package name, not physical path.
- `packages/tailwind-m3e-web/package.json:60` — `"tonal-palette-oklch": "workspace:*"`. **No edit needed**, same reason (both move to `core/` in this reorg — see Phase 3 — but even if they didn't, name-based resolution is depth-independent).
- `packages/tailwind-m3e-web/bin/generate-component-utilities.mjs:40` — `"../../../tools/lib/component-css-utilities.mjs"` → depth-change, becomes `"../../../../../tools/lib/component-css-utilities.mjs"` (tailwind-m3e-web moves from depth-2 `packages/tailwind-m3e-web` to depth-4 `brands/m3e/outputs/tailwind-m3e-web`, +2 `../`).
- `packages/tailwind-m3e-web/scripts/gen-facts.mjs:16` — `"../../../tools/lib/gen-facts-runner.mjs"` → same +2 fix, becomes `"../../../../../tools/lib/gen-facts-runner.mjs"`.
- `packages/m3e-okf/scripts/{check-paraphrase,check-skills-meta,gen-facts,build-okf}.mjs` and `scripts/lib/validate-okf.mjs` — all import `../../../tools/lib/okf-lib.mjs` or `../../../tools/lib/gen-facts-runner.mjs` (3 `../`, or 4 for the one in `scripts/lib/`). Both halves of the m3e-okf split land at depth-4 (`brands/m3e/inputs/material-okf` and `brands/m3e/outputs/m3e-api-okf`), so all of these need the same +2 `../` fix. Handled per-file in Phase 4 as each script is assigned to its new package.

**`.github/workflows/ci.yml`** — verified, no package paths at all (just runs `node tools/gate-all.mjs`). No edit needed.

**`.github/actions/fetch-elm-review-cem/action.yml`** (lives at `packages/elm-m3e/.github/actions/fetch-elm-review-cem/action.yml`, moves with elm-m3e to `brands/m3e/outputs/elm-m3e/.github/...` in Phase 2) — clones `jackhp95/elm-review-cem` by URL, not by local path. No edit needed (mirror URL is untouched by this reorg — see spec's "Non-goals").

**Cosmetic-only (prose comments, no functional effect)** — `tools/install-toolchains.mjs:8`, `tools/check-single-cem-facts.mjs` (multiple), `tools/gate-all.mjs` header comments, `tools/publish-mirror.mjs:195,213`, `tools/gen-hooks.mjs` header, `tools/ab-elm-cem.sh`/`tools/ab-elm-m3e-split.sh` header comments, `tools/check-drift.mjs` header, `tools/gen-figma-config.mjs` header, `tools/snapshot-refs.json`'s `_comment_elm_cem`. Fixed in Phase 6 (batched, cosmetic-only, does not block any gate).

### 2. Package.json split: does `core/tailwind-md3` get its own `package.json`?

**Yes — separate `package.json`, confirmed.** Justification:
1. Matches the spec's own stated precedent: `elm-typed-html` already depends on `elm-cem` as an independent sibling package, not a subdirectory.
2. `core/tailwind-md3` has genuinely independent consumers (any M3-based brand, not just `@m3e/web`) and its own `exports` map (`.`, `./roles-extended`) distinct from the brand package's `./utilities` export.
3. It has a self-contained generation step (`bin/calibrate-tones.mjs` + the `tonal-palette-oklch` dependency) with zero `@m3e/web` involvement — a real, independently-testable unit.
4. `gate-all.mjs`'s package discovery is `pnpm ls -r`-driven, running each workspace member's own `check`/`test` script. Giving `tailwind-md3` its own `package.json` means it gets its own `check` script (verifying `_tone-table.css` is fresh — see Phase 3) that plugs into the existing discovery loop with zero changes to `gate-all.mjs` itself. Folding it into `tailwind-m3e-web` instead would require inventing a "sub-package check" concept that doesn't exist anywhere else in this codebase.

---

## Additional gaps discovered during planning (not called out in the spec's own "open questions" section, but load-bearing)

1. **Depth-change risk.** `packages/<name>/` is 2 path segments deep. `core/<name>/` is *also* 2 segments deep (same depth, just a renamed parent — **zero** relative-`../`-depth fixes needed for core-bound packages, only literal-string `"packages/..."` fixes). But `brands/m3e/outputs/<name>/` and `brands/m3e/inputs/<name>/` are **4** segments deep — every relative `../` import inside `elm-m3e`, `tailwind-m3e-web`, or the two m3e-okf halves that reaches out to `tools/` or a `core/` sibling needs **+2** additional `../` segments. This is enumerated file-by-file above and handled per-phase below. `gate-all.mjs` is the safety net for anything this enumeration missed — a wrong relative path throws `MODULE_NOT_FOUND` or `ENOENT` immediately when the referencing script runs.

2. **`tailwind-m3e-web`'s file-level split is finer than the spec's prose.** The spec says "`ref/` + `theme.css` + `roles-extended.css` → `core/tailwind-md3`", but doesn't mention `seed.css` or the top-level `density.css` (as opposed to `sys/density.css`, which the spec does cover). Applying the spec's own genericity test (brand-neutral vs. cites `@m3e/web` internals):
   - `src/seed.css` — pure `--md-seed-primary`/`--md-seed-error` tokens, zero `@m3e/web` mention → **moves to `core/tailwind-md3`**.
   - `src/density.css` (top-level, NOT `src/sys/density.css`) — its own header comment cites `@m3e/web`'s `dist/core.js` `DensityToken` behavior by name → **stays in `brands/m3e/outputs/tailwind-m3e-web`**, same bucket as `sys/*.css`.
   - `bin/calibrate-tones.mjs` (writes `src/ref/_tone-table.css`) and its `tonal-palette-oklch` dependency → **move to `core/tailwind-md3`** (confirmed by reading the script: it's the generator for the `ref/` files that are moving).
   - `bin/check-privates.mjs` → **stays in `tailwind-m3e-web`, unchanged.** Verified by reading it: it checks a *different* kind of "private" var (`--_*` names declared via `@utility m3e-_foo-*` in `utilities-private.template.css`, checked against the installed `@m3e/web` JS) — unrelated to the `--_m3e-tone-*` OKLCH calibration vars. Resolution via `require.resolve("@m3e/web/core")` (bare specifier), so it's also depth-independent.
   - The private OKLCH calibration vars (`--_m3e-tone-10-rich`, etc. — 24 declarations in `_tone-table.css`, ~72 usages across `palette.css` and `roles-extended.css`) rename to **`--_md-tone-*`** (picking the spec's second suggested option, for consistency with the surrounding `--md-*` token-family prefix already used by `--md-seed-*` and `--md-ref-palette-*` in the same files). All three files move to `core/tailwind-md3` together, so this rename is fully self-contained — no cross-package reference to fix.

3. **`m3e-okf`'s `build-okf.mjs` crosses the exact boundary the split wants to create.** Read in full (`packages/m3e-okf/scripts/build-okf.mjs`, 147 lines). It does two independent things in one file: (a) generates `knowledge/**` from `data/knowledge/**` (lines 1–119, needs zero cross-package knowledge of anything else), and (b) copies `skills/m3e/components/*.md` into `implementations/m3e-web/components/` and writes an `implementations/m3e-web/index.md` (lines 121–146). These two halves don't actually depend on each other's *output* — (b) reads from `skills/m3e/components` (produced by `build-skill.mjs`), not from `knowledge/`. Splitting the script in two, one half per new package, is mechanical and low-risk (see Phase 4). The other five `scripts/*.mjs` (`extract.mjs`, `guidance.mjs`, `build-examples.mjs`, `build-skill.mjs`, `check-skill.mjs`, `check-okf.mjs`, `check-staleness.mjs`, `gen-facts.mjs`) all read/write `data/{components,guidance,examples,cem-facts,sources}.json` and `skills/m3e/**` — none of them touch `knowledge/` or `data/knowledge/**` — so they all move wholesale to `m3e-api-okf` with zero internal surgery beyond the `+2 ../` depth fix. Two scripts DO belong on the knowledge side: `scripts/check-paraphrase.mjs` and `scripts/lib/validate-okf.mjs` (+ its test) validate `knowledge/` content specifically (citation/paraphrase rules) — these move to `material-okf`. `scripts/check-skills-meta.mjs` stays in `m3e-api-okf` (validates `skills/` frontmatter) but its link-checker needs a cross-package resolution fix for `/knowledge/`-prefixed links (see Phase 4, Step 4.6).

4. **`brands/m3e/inputs/cem/` mechanics.** The spec's target-layout diagram lists this directory as holding "M3E's custom-elements.json + config/*.json". Verified: **`custom-elements.json` is not a committed file** — `tools/lib/regen.mjs`'s `GEN_CONFIG_ARGS` resolves it live from the installed npm dependency (`--flags-from=docs/node_modules/@m3e/web/dist/custom-elements.json`, relative to `cwd: elmM3e`). That path is untouched by this reorg (still resolved relative to wherever `elm-m3e` itself lives, and its whole `docs/` subtree moves as one unit in Phase 2) — there is nothing to physically move for that half. What *does* physically exist and move is `packages/elm-m3e/config/*.json` (10 files: `categories.json`, 4× `examples.*.json`, `favicon.json`, `figma.generated.json`, `icons-catalog.json`, `icons.json`, `native-mdn.json`, `slots.json`, plus `ATTRIBUTION.md`). Resolution (Phase 5): move these into `brands/m3e/inputs/cem/config/`, and leave a symlink `brands/m3e/outputs/elm-m3e/config -> ../../inputs/cem/config` — the exact same pattern this repo already uses for `elm-cem/elm-html-intermediate-representation`. This means `regen.mjs`'s `--config-from=config/slots.json` etc. (resolved relative to `cwd: elmM3e`) keep working with **zero code changes**, since `config/` still resolves through the symlink. `brands/m3e/inputs/cem/` is a **plain data directory, not a pnpm package** — no `package.json`, unlike `material-okf` (which the spec explicitly frames as syncing from a separate external repo and therefore needs its own package identity).

5. **`install-toolchains.mjs`'s package-discovery walk is one level deep and needs to become reorg-aware** (functional fix, not cosmetic — see Phase 2, Step 2.11).

6. **`m3e-okf`'s family.json/mirror identity.** Per the spec's non-goal ("Publishing/mirror changes — untouched by this reorg"), the existing `mirror`/`bundleCopy` identity currently keyed `"m3e-okf"` in `tools/family.json` stays keyed `"m3e-okf"` and continues pointing at `jackhp95/m3e-okf.git` (unrenamed) — but its `srcDir` now points at `brands/m3e/outputs/m3e-api-okf` (the half that keeps the scripts, CEM-verification, and `data/cem-facts.json` — the natural continuation of "the thing published as m3e-okf"). `material-okf` gets a **new**, separate `family.json` entry with no `mirror` block (it's an input, not something this workspace publishes) and no `copyFidelity.sourceEnvVar` yet either — wiring an actual external-repo sync per the spec's "Sync mechanism" paragraph requires a real external repo coordinate (URL + pinned SHA) that isn't confirmed to exist yet. **Flagged explicitly as deferred, not fabricated**: Phase 4 moves `material-okf`'s content locally (from this workspace's own `packages/m3e-okf/data/knowledge/**`) and leaves a `$TODO` comment in `family.json` for wiring the real snapshot-refs entry once Jack confirms the separate OKF repo's coordinates — this is a **structure-only** pass per the spec's own stated scope, and inventing a GitHub URL I haven't verified is out of bounds.

---

## Task 1: Baseline safety check — additive `pnpm-workspace.yaml` glob

**Files:**
- Modify: `pnpm-workspace.yaml`

- [ ] **Step 1.1: Add the new glob patterns alongside the old ones**

```yaml
packages:
  - "packages/*"
  - "packages/*/*"
  - "core/*"
  - "brands/*/inputs/*"
  - "brands/*/outputs/*"
  - "!**/node_modules"
  - "!**/elm-stuff"
  - "!packages/*/elm-html-intermediate-representation"

allowBuilds:
  '@parcel/watcher': true
  elm: true
  elm-format: true
  esbuild: true
  lamdera: true

minimumReleaseAgeExclude:
  - '@m3e/web@2.5.13'
```

- [ ] **Step 1.2: Verify nothing broke (superset glob, no new dirs exist yet, so this should be a no-op)**

Run: `pnpm install && node tools/gate-all.mjs`
Expected: `GATE-ALL GREEN` (identical result to before this change — the new globs match nothing yet).

- [ ] **Step 1.3: Commit**

```bash
git add pnpm-workspace.yaml
git commit -m "chore(workspace): add core/+brands/ globs ahead of package moves"
```

---

## Task 2: Wholesale package moves + path-reference fixes

Moves 9 packages that need **no internal splitting** — `elm-cem`, `elm-cem-compose`, `elm-review-cem`, `elm-html-intermediate-representation`, `elm-typed-html`, `cem-figma-connect`, `tonal-palette-oklch` → `core/`; `elm-m3e`, `tailwind-m3e-web` → `brands/m3e/outputs/` — plus every path reference enumerated in "Resolved open questions §1" above that these 9 moves require. `tailwind-m3e-web` and `elm-m3e` still contain everything at this point (the `tailwind-md3` carve-out is Task 3; the `m3e-okf` split and `inputs/cem` creation are Tasks 4–5, done separately since `m3e-okf` doesn't have a single destination).

**Files:**
- Move (git mv): `packages/elm-cem` → `core/elm-cem`, `packages/elm-cem-compose` → `core/elm-cem-compose`, `packages/elm-review-cem` → `core/elm-review-cem`, `packages/elm-html-intermediate-representation` → `core/elm-html-intermediate-representation`, `packages/elm-typed-html` → `core/elm-typed-html`, `packages/cem-figma-connect` → `core/cem-figma-connect`, `packages/tonal-palette-oklch` → `core/tonal-palette-oklch`, `packages/elm-m3e` → `brands/m3e/outputs/elm-m3e`, `packages/tailwind-m3e-web` → `brands/m3e/outputs/tailwind-m3e-web`
- Modify: every file listed in "Resolved open questions §1" above (family.json, gate-all.mjs, check-drift.mjs, check-drift.test.mjs, bump.mjs, gen-hooks.mjs, check-elm-shape-drift.mjs, check-cc-elm-refs.mjs, gen-figma-config.mjs, ab-elm-cem.sh, ab-elm-m3e-split.sh, measure-docs-size.mjs, check-emit-determinism-cfc.mjs, lib/gen-facts-runner.mjs, lib/regen.mjs, install-toolchains.mjs, pnpm-workspace.yaml, plus elm-m3e's internal `docs/scripts/examples-gen/lib/to-elm.mjs`, `docs/samples/review/elm.json`, `docs/scripts/samples-gen/extract-samples.mjs`, and tailwind-m3e-web's `bin/generate-component-utilities.mjs` + `scripts/gen-facts.mjs`)

- [ ] **Step 2.1: Move the 7 core-bound packages**

```bash
mkdir -p core
git mv packages/elm-cem core/elm-cem
git mv packages/elm-cem-compose core/elm-cem-compose
git mv packages/elm-review-cem core/elm-review-cem
git mv packages/elm-html-intermediate-representation core/elm-html-intermediate-representation
git mv packages/elm-typed-html core/elm-typed-html
git mv packages/cem-figma-connect core/cem-figma-connect
git mv packages/tonal-palette-oklch core/tonal-palette-oklch
```

Note: `core/elm-cem/elm-html-intermediate-representation` (the symlink to `../elm-html-intermediate-representation`) moves automatically with `elm-cem` and needs no target-path edit — both packages are still siblings under `core/`.

- [ ] **Step 2.2: Move the 2 brand-output packages**

```bash
mkdir -p brands/m3e/outputs
git mv packages/elm-m3e brands/m3e/outputs/elm-m3e
git mv packages/tailwind-m3e-web brands/m3e/outputs/tailwind-m3e-web
```

- [ ] **Step 2.3: Fix `pnpm-workspace.yaml` — drop the old globs, keep `_probe` reachable**

```yaml
packages:
  - "packages/_probe/*"
  - "core/*"
  - "brands/*/inputs/*"
  - "brands/*/outputs/*"
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

- [ ] **Step 2.4: Fix `tools/family.json` — update `srcDir` for the 9 moved entries**

Use Edit on `tools/family.json`, changing each `"srcDir": "packages/<name>"` to its new location:
- `elm-cem` → `"core/elm-cem"`
- `elm-m3e` → `"brands/m3e/outputs/elm-m3e"`
- `elm-cem-compose` → `"core/elm-cem-compose"`
- `elm-html-intermediate-representation` → `"core/elm-html-intermediate-representation"`
- `elm-review-cem` → `"core/elm-review-cem"`
- `elm-typed-html` → `"core/elm-typed-html"`
- `tailwind-m3e-web` → `"brands/m3e/outputs/tailwind-m3e-web"`
- `elm-cem-facts` → `"core/elm-cem/facts"`
- `cem-figma-connect` → `"core/cem-figma-connect"`

(`m3e-okf`'s entry is handled in Task 4, not here.)

- [ ] **Step 2.5: Fix `tools/gate-all.mjs`**

Edit line 42:
```js
const ELM_M3E = process.env.ELM_M3E || path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e");
```

Edit line 195:
```js
const { validate } = require(path.join(repoRoot, "core", "elm-cem", "bin", "validate-facts-bundle.js"));
```

Replace the `discoverPackages()` fallback walk (around line 150) so it covers the new layout:
```js
    const found = [];
    const SKIP = new Set(["node_modules", "elm-stuff", ".git"]);
    const walk = (dir) => {
        for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
            if (SKIP.has(entry.name)) continue;
            if (!entry.isDirectory()) continue;
            const full = path.join(dir, entry.name);
            if (fs.existsSync(path.join(full, "package.json"))) {
                const pkg = JSON.parse(fs.readFileSync(path.join(full, "package.json"), "utf8"));
                found.push({ name: pkg.name, dir: full });
            }
            walk(full);
        }
    };
    walk(path.join(repoRoot, "core"));
    walk(path.join(repoRoot, "brands"));
    walk(path.join(repoRoot, "packages", "_probe"));
    return found;
```

- [ ] **Step 2.6: Fix `tools/check-drift.mjs`, `tools/check-drift.test.mjs`, `tools/bump.mjs`, `tools/gen-hooks.mjs`, `tools/check-elm-shape-drift.mjs`, `tools/check-cc-elm-refs.mjs`, `tools/gen-figma-config.mjs`, `tools/ab-elm-cem.sh`, `tools/ab-elm-m3e-split.sh`, `tools/measure-docs-size.mjs`, `tools/check-emit-determinism-cfc.mjs`, `tools/lib/gen-facts-runner.mjs`, `tools/lib/regen.mjs`**

Apply every exact old→new string replacement enumerated in "Resolved open questions §1" above, file by file (each entry there gives the literal current line and its replacement — use Edit with those exact strings). For `gen-figma-config.mjs` line 47, use the **intermediate** value for now (`path.join(repoRoot, "packages", "elm-m3e", "config")` → keep resolving through elm-m3e until Task 5 moves `config/` — see Step 2.6a) since `brands/m3e/inputs/cem` doesn't exist until Task 5.

- [ ] **Step 2.6a: `gen-figma-config.mjs` line 47 interim fix**

```js
const elmM3eConfigDir = path.join(repoRoot, "brands", "m3e", "outputs", "elm-m3e", "config");
```
(Task 5 will change this again once `config/` physically moves to `inputs/cem/`.)

- [ ] **Step 2.7: Fix elm-m3e's internal cross-package references**

`brands/m3e/outputs/elm-m3e/docs/scripts/examples-gen/lib/to-elm.mjs` line 52:
```js
} from "../../../../../../../../core/elm-cem/src/elm-shape.mjs";
```

`brands/m3e/outputs/elm-m3e/docs/samples/review/elm.json` — update `source-directories`:
```json
{
    "source-directories": [
        "src",
        "../../../../../../../core/elm-review-cem/src",
        "../../../../../../../core/elm-cem/facts/src",
        "../../../../../../../core/elm-html-intermediate-representation/src",
        "../../../../../../../core/elm-typed-html/src"
    ]
}
```
(Read the file first to confirm the exact current `source-directories` array shape/ordering before editing — the first entry, likely `"../../../src"` or similar pointing at the sample's own source, stays relative and unaffected.)

- [ ] **Step 2.8: Fix tailwind-m3e-web's `tools/lib/` imports**

`brands/m3e/outputs/tailwind-m3e-web/bin/generate-component-utilities.mjs` line 40:
```js
} from "../../../../../tools/lib/component-css-utilities.mjs";
```

`brands/m3e/outputs/tailwind-m3e-web/scripts/gen-facts.mjs` line 16:
```js
import { runGenFacts } from "../../../../../tools/lib/gen-facts-runner.mjs";
```

- [ ] **Step 2.9: Verify `extract-samples.mjs`'s computed path**

Read `brands/m3e/outputs/elm-m3e/docs/scripts/samples-gen/extract-samples.mjs` around line 293 (the `path.posix.join("../../..", ...)` call) and confirm by inspection whether `"../../.."` is computed relative to a base that changed depth. If elm-m3e's own internal directory structure (docs/scripts/samples-gen/ → docs/samples/) didn't change (only the whole `elm-m3e` package moved as a unit), this stays correct unchanged — the join is internal to the package, not cross-package. Confirm via the gate-all run in Step 2.13; only edit if it fails.

- [ ] **Step 2.10: Fix `tools/install-toolchains.mjs`'s discovery walk**

Replace the current single-level `packages/` walk (lines ~42–47) with:
```js
const dirs = [repoRoot];
function scanFor(baseDir, depth) {
    if (!existsSync(baseDir)) return;
    for (const name of readdirSync(baseDir)) {
        const dir = path.join(baseDir, name);
        if (depth > 1) {
            scanFor(dir, depth - 1);
            continue;
        }
        if (existsSync(path.join(dir, "elm-tooling.json")) && !selfInstalls(dir)) dirs.push(dir);
    }
}
scanFor(path.join(repoRoot, "core"), 1);
scanFor(path.join(repoRoot, "brands"), 3); // brands/<brand>/{inputs,outputs}/<name>
scanFor(path.join(repoRoot, "packages", "_probe"), 1);
```

- [ ] **Step 2.11: Run the gate, iterate on failures**

Run: `node tools/gate-all.mjs`

This is the primary safety net for anything the enumeration above missed (computed paths, an overlooked comment that turned out to be load-bearing, etc.). Read `FAILED ITEMS`, patch forward, re-run. Do not proceed to Step 2.12 until `GATE-ALL GREEN`.

- [ ] **Step 2.12: Commit**

```bash
git add -A
git commit -m "reorg(workspace): move core packages to core/, elm-m3e+tailwind-m3e-web to brands/m3e/outputs/"
```

---

## Task 3: Carve `core/tailwind-md3` out of `tailwind-m3e-web`

**Files:**
- Create: `core/tailwind-md3/package.json`, `core/tailwind-md3/src/index.css`
- Move (git mv): `brands/m3e/outputs/tailwind-m3e-web/src/ref/` → `core/tailwind-md3/src/ref/`, `.../src/theme.css` → `core/tailwind-md3/src/theme.css`, `.../src/roles-extended.css` → `core/tailwind-md3/src/roles-extended.css`, `.../src/seed.css` → `core/tailwind-md3/src/seed.css`, `.../bin/calibrate-tones.mjs` → `core/tailwind-md3/bin/calibrate-tones.mjs`
- Modify: `brands/m3e/outputs/tailwind-m3e-web/src/index.css`, `brands/m3e/outputs/tailwind-m3e-web/package.json`, `tools/family.json` (no `tailwind-md3` entry needed — it has no mirror/copyFidelity relationship, it's newly born from this reorg)
- Create (shim): `brands/m3e/outputs/tailwind-m3e-web/src/roles-extended.css`

- [ ] **Step 3.1: Move the generic files**

```bash
mkdir -p core/tailwind-md3/src core/tailwind-md3/bin
git mv brands/m3e/outputs/tailwind-m3e-web/src/ref core/tailwind-md3/src/ref
git mv brands/m3e/outputs/tailwind-m3e-web/src/theme.css core/tailwind-md3/src/theme.css
git mv brands/m3e/outputs/tailwind-m3e-web/src/roles-extended.css core/tailwind-md3/src/roles-extended.css
git mv brands/m3e/outputs/tailwind-m3e-web/src/seed.css core/tailwind-md3/src/seed.css
git mv brands/m3e/outputs/tailwind-m3e-web/bin/calibrate-tones.mjs core/tailwind-md3/bin/calibrate-tones.mjs
```

- [ ] **Step 3.2: Rename the private OKLCH tone vars**

In `core/tailwind-md3/src/ref/_tone-table.css`, `core/tailwind-md3/src/ref/palette.css`, and `core/tailwind-md3/src/roles-extended.css`, replace every occurrence of `--_m3e-tone-` with `--_md-tone-` (24 declarations in `_tone-table.css`, ~72 usages combined across `palette.css` and `roles-extended.css` — use a project-wide find/replace scoped to these 3 files, e.g. `sed -i '' 's/--_m3e-tone-/--_md-tone-/g' core/tailwind-md3/src/ref/_tone-table.css core/tailwind-md3/src/ref/palette.css core/tailwind-md3/src/roles-extended.css`).

- [ ] **Step 3.3: Write `core/tailwind-md3/package.json`**

```json
{
  "name": "tailwind-md3",
  "version": "0.1.0",
  "description": "Generic Material 3 Tailwind v4 theme — OKLCH tonal-palette color science, ref tokens, and role-extended (success/info/warning) palettes. Brand-neutral: usable by any M3-based design system, not just @m3e/web.",
  "license": "MIT",
  "author": "Jack H Peterson",
  "type": "module",
  "engines": { "node": ">=20" },
  "files": [
    "src/**/*.css",
    "README.md",
    "LICENSE"
  ],
  "exports": {
    ".": "./src/index.css",
    "./roles-extended": "./src/roles-extended.css"
  },
  "devDependencies": {
    "@material/material-color-utilities": "^0.3.0",
    "culori": "^4.0.2",
    "tonal-palette-oklch": "workspace:*"
  },
  "scripts": {
    "generate:tones": "node bin/calibrate-tones.mjs",
    "generate": "pnpm run generate:tones",
    "check": "pnpm run generate:tones && git diff --exit-code -- src/ref/_tone-table.css",
    "hooks:install": "node ../../tools/hooks-install.mjs"
  }
}
```

- [ ] **Step 3.4: Write `core/tailwind-md3/src/index.css`**

```css
/*
 * Default-import barrel — `@import "tailwind-md3"` resolves here.
 *
 * Loads the brand-neutral M3 layers in dependency order:
 *   Layer 0 (seed) -> Layer 1 (ref palette) -> Layer 3 (@theme)
 *
 * A brand package (e.g. tailwind-m3e-web) imports this FIRST, then layers
 * its own brand-specific sys/* tokens (Layer 2) and density scope utilities
 * on top -- see that package's own src/index.css.
 *
 * Consumers wanting success/info/warning roles also add:
 *   @import "tailwind-md3/roles-extended";
 */

/* Layer 0 -- seed tokens. */
@import "./seed.css";

/* Layer 1 -- ref palette tonal scales (oklch-derived). */
@import "./ref/palette.css";

/* Layer 3 -- Tailwind v4 @theme keys. */
@import "./theme.css";
```

- [ ] **Step 3.5: Rewrite `brands/m3e/outputs/tailwind-m3e-web/src/index.css`**

```css
/*
 * Default-import barrel -- `@import "tailwind-m3e-web"` resolves here.
 *
 * Loads tailwind-md3 (seed + ref palette + @theme, brand-neutral) then layers
 * the @m3e/web-specific sys tokens (Layer 2) and density scope utilities on
 * top.
 *
 * Consumers wanting the @m3e/web component-utility surface also add:
 *   @import "tailwind-m3e-web/utilities";
 *
 * Consumers wanting success/info/warning add:
 *   @import "tailwind-m3e-web/roles-extended";
 */

/* Layer 0+1+3 -- brand-neutral M3 theme (seed, ref palette, @theme keys). */
@import "tailwind-md3";

/* Layer 2 -- M3 sys tokens, @m3e/web-specific. color must load before
   typescale (some typescale tokens reference --md-sys-color-* in their
   fallbacks). */
@import "./sys/color.css";
@import "./sys/typescale.css";
@import "./sys/motion.css";
@import "./sys/shape.css";
@import "./sys/elevation.css";
@import "./sys/state.css";
@import "./sys/density.css";

/* Layer 3 (m3e-specific) -- density scope utilities (density-0...density-3). */
@import "./density.css";
```

- [ ] **Step 3.6: Create the `roles-extended.css` re-export shim**

`brands/m3e/outputs/tailwind-m3e-web/src/roles-extended.css` (replaces the moved-out real content):
```css
/* Re-exported from tailwind-md3 -- see core/tailwind-md3/src/roles-extended.css
   for the actual success/info/warning role-extended palette definitions.
   This shim keeps `@import "tailwind-m3e-web/roles-extended"` working for
   existing consumers through the brand package's barrel. */
@import "tailwind-md3/roles-extended";
```

`brands/m3e/outputs/tailwind-m3e-web/package.json`'s `exports["./roles-extended"]` field stays `"./src/roles-extended.css"` unchanged — only the file's content changed.

- [ ] **Step 3.7: Update `brands/m3e/outputs/tailwind-m3e-web/package.json` dependencies**

Remove `"tonal-palette-oklch": "workspace:*"` from `devDependencies` (moved with `calibrate-tones.mjs` to `tailwind-md3`). Add `"tailwind-md3": "workspace:*"` to `dependencies` (a real runtime CSS dependency, not dev-only — tailwind-m3e-web's own `src/index.css` now `@import`s it).

- [ ] **Step 3.8: Reinstall + run the gate**

Run: `pnpm install && node tools/gate-all.mjs`

Watch specifically for: `tailwind-md3`'s new `check` script running and passing (confirms `_tone-table.css` regenerates byte-identical after the rename), `tailwind-m3e-web`'s `check`/`test` still passing, and the E2E facts-bundle proof (unaffected — it doesn't touch CSS). Patch forward on any failure, then re-run until green.

- [ ] **Step 3.9: Commit**

```bash
git add -A
git commit -m "reorg(tailwind): split core/tailwind-md3 out of tailwind-m3e-web (generic M3 color science vs @m3e/web-specific sys tokens)"
```

---

## Task 4: Split `m3e-okf` into `material-okf` (input) + `m3e-api-okf` (output)

**Files:**
- Create: `brands/m3e/inputs/material-okf/package.json`, `brands/m3e/inputs/material-okf/scripts/build-knowledge.mjs`, `brands/m3e/outputs/m3e-api-okf/package.json`
- Move (git mv): `packages/m3e-okf/data/knowledge` → `brands/m3e/inputs/material-okf/data/knowledge`, `packages/m3e-okf/knowledge` → `brands/m3e/inputs/material-okf/knowledge`, `packages/m3e-okf/scripts/check-paraphrase.mjs` → `brands/m3e/inputs/material-okf/scripts/check-paraphrase.mjs`, `packages/m3e-okf/scripts/lib/validate-okf.mjs` (+ test) → `brands/m3e/inputs/material-okf/scripts/lib/`; everything else in `packages/m3e-okf/` → `brands/m3e/outputs/m3e-api-okf/`
- Modify: `packages/m3e-okf/scripts/build-okf.mjs` (split), `scripts/check-skills-meta.mjs`, `tools/family.json`, `tools/gen-hooks.mjs` (already pointed at the outputs path in Task 2, Step 2.6 — confirm), `tools/bump.mjs` (already fixed in Task 2), `tools/check-drift.test.mjs` (already fixed in Task 2)

- [ ] **Step 4.1: Move the knowledge-side files to `material-okf`**

```bash
mkdir -p brands/m3e/inputs/material-okf/scripts/lib
git mv packages/m3e-okf/data/knowledge brands/m3e/inputs/material-okf/data-knowledge-staging
mkdir -p brands/m3e/inputs/material-okf/data
git mv brands/m3e/inputs/material-okf/data-knowledge-staging brands/m3e/inputs/material-okf/data/knowledge
git mv packages/m3e-okf/knowledge brands/m3e/inputs/material-okf/knowledge
git mv packages/m3e-okf/scripts/check-paraphrase.mjs brands/m3e/inputs/material-okf/scripts/check-paraphrase.mjs
git mv packages/m3e-okf/scripts/lib/validate-okf.mjs brands/m3e/inputs/material-okf/scripts/lib/validate-okf.mjs
git mv packages/m3e-okf/scripts/lib/validate-okf.test.mjs brands/m3e/inputs/material-okf/scripts/lib/validate-okf.test.mjs
```
(If `validate-okf.test.mjs` doesn't exist under that exact name, `ls packages/m3e-okf/scripts/lib/` first and adjust — move whatever test file(s) accompany `validate-okf.mjs`.)

- [ ] **Step 4.2: Move everything else to `m3e-api-okf`**

```bash
mkdir -p brands/m3e/outputs/m3e-api-okf
git mv packages/m3e-okf/data brands/m3e/outputs/m3e-api-okf/data
git mv packages/m3e-okf/implementations brands/m3e/outputs/m3e-api-okf/implementations
git mv packages/m3e-okf/skills brands/m3e/outputs/m3e-api-okf/skills
git mv packages/m3e-okf/scripts brands/m3e/outputs/m3e-api-okf/scripts
git mv packages/m3e-okf/hooks brands/m3e/outputs/m3e-api-okf/hooks
git mv packages/m3e-okf/templates brands/m3e/outputs/m3e-api-okf/templates
git mv packages/m3e-okf/.github brands/m3e/outputs/m3e-api-okf/.github
git mv packages/m3e-okf/package.json brands/m3e/outputs/m3e-api-okf/package.json
git mv packages/m3e-okf/package-lock.json brands/m3e/outputs/m3e-api-okf/package-lock.json
git mv packages/m3e-okf/.gitignore brands/m3e/outputs/m3e-api-okf/.gitignore
git mv packages/m3e-okf/README.md brands/m3e/outputs/m3e-api-okf/README.md
git mv packages/m3e-okf/CONTRIBUTING.md brands/m3e/outputs/m3e-api-okf/CONTRIBUTING.md
git mv packages/m3e-okf/LICENSE brands/m3e/outputs/m3e-api-okf/LICENSE
git mv packages/m3e-okf/SECURITY.md brands/m3e/outputs/m3e-api-okf/SECURITY.md
```

Note: `data/knowledge` already left this tree in Step 4.1, so `git mv packages/m3e-okf/data` here moves everything else under `data/` (`components.json`, `guidance.json`, `examples.json`, `cem-facts.json`, `sources.json`, etc.) intact.

- [ ] **Step 4.3: Split `build-okf.mjs`**

Write `brands/m3e/inputs/material-okf/scripts/build-knowledge.mjs`:
```js
// build-knowledge.mjs -- generate knowledge/ from data/knowledge/**.
//
// DECISION (Phase 5b, carried over from the pre-split build-okf.mjs):
// knowledge/ is a GENERATED TARGET, not a hand-edited tree. The source of
// truth is data/knowledge/** (technology-neutral authored prose with OKF
// frontmatter) + data/knowledge/*/_dir.json (per-directory metadata). This
// build copies the concept files verbatim into knowledge/**, copies log.md,
// and DERIVES each directory's index.md deterministically from _dir.json +
// the frontmatter of the concept files present.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { parseFrontmatter } from "../../../../../tools/lib/okf-lib.mjs";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const SRC = path.join(ROOT, "data/knowledge");
const OUT = path.join(ROOT, "knowledge");

const isConcept = (f) => f.endsWith(".md") && f !== "index.md" && f !== "log.md";

function rmrf(dir) {
  if (fs.existsSync(dir)) fs.rmSync(dir, { recursive: true, force: true });
}
rmrf(OUT);

function readDirMeta(srcDir) {
  const p = path.join(srcDir, "_dir.json");
  return fs.existsSync(p) ? JSON.parse(fs.readFileSync(p, "utf8")) : { title: path.basename(srcDir), intro: "" };
}

function buildIndex(srcDir, outDir, relBase) {
  fs.mkdirSync(outDir, { recursive: true });
  const meta = readDirMeta(srcDir);

  const entries = fs.readdirSync(srcDir).sort();
  const subdirs = entries.filter((e) => fs.statSync(path.join(srcDir, e)).isDirectory());
  const conceptFiles = entries.filter(isConcept);

  const orderedSubdirs = meta.subdirs
    ? meta.subdirs.filter((s) => subdirs.includes(s)).concat(subdirs.filter((s) => !meta.subdirs.includes(s)))
    : subdirs;

  let md = `# ${meta.title}\n\n`;
  if (meta.intro) md += `${meta.intro}\n\n`;

  if (orderedSubdirs.length) {
    md += `## Sections\n\n`;
    for (const sub of orderedSubdirs) {
      const subMeta = readDirMeta(path.join(srcDir, sub));
      md += `- [${subMeta.title}](/${relBase}${sub}/) -- ${subMeta.intro || ""}`.trimEnd() + "\n";
    }
    md += "\n";
  }

  if (conceptFiles.length) {
    md += `## Concepts\n\n`;
    md += `| Concept | What it covers |\n| --- | --- |\n`;
    for (const f of conceptFiles) {
      const { data } = parseFrontmatter(fs.readFileSync(path.join(srcDir, f), "utf8"));
      const id = `/${relBase}${f.replace(/\.md$/, "")}`;
      const title = data.title || f.replace(/\.md$/, "");
      const desc = (data.description || "").replace(/\|/g, "\\|");
      md += `| [${title}](${id}) | ${desc} |\n`;
    }
    md += "\n";
  } else if (!orderedSubdirs.length) {
    md += `_Concept files land in the authoring campaign._\n`;
  }

  fs.writeFileSync(path.join(outDir, "index.md"), md);

  for (const f of conceptFiles) {
    fs.copyFileSync(path.join(srcDir, f), path.join(outDir, f));
  }
  for (const sub of orderedSubdirs) {
    buildIndex(path.join(srcDir, sub), path.join(outDir, sub), `${relBase}${sub}/`);
  }
  return { concepts: conceptFiles.length, subdirs: orderedSubdirs.length };
}

fs.mkdirSync(OUT, { recursive: true });
buildIndex(SRC, OUT, "");

const logSrc = path.join(SRC, "log.md");
if (fs.existsSync(logSrc)) fs.copyFileSync(logSrc, path.join(OUT, "log.md"));

let conceptCount = 0;
(function count(dir) {
  for (const f of fs.readdirSync(dir)) {
    const p = path.join(dir, f);
    if (fs.statSync(p).isDirectory()) count(p);
    else if (isConcept(f)) conceptCount++;
  }
})(OUT);

console.log(`build-knowledge: ${conceptCount} concept files across the knowledge bundle`);
```

Rewrite `brands/m3e/outputs/m3e-api-okf/scripts/build-okf.mjs` (trimmed to the implementation-layer half only):
```js
// build-okf.mjs -- assemble the implementations/m3e-web/ layer: the
// CEM-verified, tech-specific counterpart to the (separately-generated,
// separately-packaged) knowledge/ bundle in brands/m3e/inputs/material-okf.
//
// Its component cards are the SAME cards build-skill.mjs renders (tag-level
// API), re-emitted here under a clearly-labeled implementation root.
// build-skill.mjs stays the source of those cards; this build copies them so
// the OKF layout is complete.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const IMPL = path.join(ROOT, "implementations/m3e-web");
const CARDS = path.join(ROOT, "skills/m3e/components");

function rmrf(dir) {
  if (fs.existsSync(dir)) fs.rmSync(dir, { recursive: true, force: true });
}
rmrf(IMPL);

fs.mkdirSync(path.join(IMPL, "components"), { recursive: true });
const cardFiles = fs.existsSync(CARDS) ? fs.readdirSync(CARDS).filter((f) => f.endsWith(".md")).sort() : [];
for (const f of cardFiles) {
  fs.copyFileSync(path.join(CARDS, f), path.join(IMPL, "components", f));
}

let implIndex = `# @m3e/web -- verified implementation layer\n\n`;
implIndex += `Technology-specific, **CEM-verified** component API for the \`@m3e/web\` custom-element\n`;
implIndex += `library (\`matraic/m3e\`). These cards are tag-level API -- real \`<m3e-*>\` tags,\n`;
implIndex += `attributes, slots, events, and CSS tokens -- generated from the library's build-time\n`;
implIndex += `Custom Elements Manifest. For technology-neutral design guidance (anatomy, usage,\n`;
implIndex += `accessibility), see the [knowledge bundle](/index).\n\n`;
implIndex += `## Components (${cardFiles.length})\n\n`;
implIndex += cardFiles
  .map((f) => `- [${f.replace(/\.md$/, "")}](/implementations/m3e-web/components/${f.replace(/\.md$/, "")})`)
  .join("\n") + "\n";
fs.writeFileSync(path.join(IMPL, "index.md"), implIndex);

console.log(`build-okf: ${cardFiles.length} CEM-verified cards under implementations/m3e-web/`);
```

- [ ] **Step 4.4: Fix `+2 ../` depth in the remaining `m3e-api-okf` scripts**

`brands/m3e/outputs/m3e-api-okf/scripts/check-paraphrase.mjs` already moved to material-okf (Step 4.1) — skip. For the scripts that stayed (`check-skills-meta.mjs`, `gen-facts.mjs`, and `scripts/lib/validate-okf.mjs`'s former importers if any remain), find every `../../../tools/lib/` and change to `../../../../../tools/lib/`:

```bash
grep -rl '\.\./\.\./\.\./tools/lib/' brands/m3e/outputs/m3e-api-okf/scripts/
```

For each file found, edit the import to prepend two more `../` (3 → 5). Do the same check for `brands/m3e/inputs/material-okf/scripts/`:

```bash
grep -rl '\.\./\.\./\.\./tools/lib/' brands/m3e/inputs/material-okf/scripts/
```

`check-paraphrase.mjs` and `validate-okf.mjs` both import `../../../tools/lib/okf-lib.mjs` (3 `../`) — fix to `../../../../tools/lib/okf-lib.mjs` (`material-okf/scripts/` is 4 segments deep: `brands/m3e/inputs/material-okf/scripts` — wait, `validate-okf.mjs` lives in `scripts/lib/` (5 segments deep), so its fix is `../../../../../tools/lib/okf-lib.mjs`; `check-paraphrase.mjs` lives directly in `scripts/` (4 segments deep), so its fix is `../../../../tools/lib/okf-lib.mjs`. Verify each file's actual nesting depth before editing (`scripts/` vs `scripts/lib/` differ by one segment) rather than applying a single blanket rule.

- [ ] **Step 4.5: Write `brands/m3e/inputs/material-okf/package.json`**

Base it on the original `m3e-okf/package.json`'s shared boilerplate, trimmed to only what `build-knowledge.mjs` + `check-paraphrase.mjs` + `validate-okf.mjs` need:
```json
{
  "name": "material-okf",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "description": "Technology-neutral Material 3 knowledge bundle (OKF v0.1) -- foundations, styles, components, patterns. Brand input: consumed by brands/m3e/outputs/m3e-api-okf and the applying-material-design skill.",
  "license": "BSD-3-Clause",
  "scripts": {
    "gen": "node scripts/build-knowledge.mjs",
    "check:paraphrase": "node scripts/check-paraphrase.mjs",
    "check:validity": "node scripts/lib/validate-okf.mjs",
    "check": "run-p check:paraphrase check:validity",
    "test:lib": "node --test scripts/lib/*.test.mjs",
    "test": "run-p test:*",
    "hooks:install": "node ../../../../tools/hooks-install.mjs"
  },
  "devDependencies": {
    "npm-run-all2": "^9.0.3"
  }
}
```

- [ ] **Step 4.6: Fix `check-skills-meta.mjs`'s cross-package `/knowledge/` link resolution**

Read `brands/m3e/outputs/m3e-api-okf/scripts/check-skills-meta.mjs` in full (the earlier sweep found the relevant logic around line 74-79, resolving `/knowledge/...`-prefixed links). Change the base directory used to resolve `/knowledge/`-prefixed link targets from a local `knowledge/` lookup to `path.join(ROOT, "..", "..", "inputs", "material-okf", "knowledge")` (or equivalent, matching whatever variable name the file already uses for its `ROOT` constant) — `/implementations/`-prefixed links keep resolving locally, unchanged.

- [ ] **Step 4.7: Update `tools/family.json`**

Replace the `"m3e-okf"` entry's `srcDir` with `"brands/m3e/outputs/m3e-api-okf"` (keep the `mirror`, `bundleCopy`, and `copyFidelity` blocks exactly as-is — per the spec's non-goal, publishing/mirror config is untouched). Add a new entry:
```json
"material-okf": {
    "srcDir": "brands/m3e/inputs/material-okf",
    "mirror": { "auditedExclusions": false },
    "$TODO_external_sync": "Per the design spec's 'Sync mechanism' section, this should eventually sync from a separate external OKF repo via copyFidelity (sourceEnvVar + tools/snapshot-refs.json entry), same pattern as m3e-okf. Not wired up in this structure-only pass -- needs Jack to confirm the real external repo's URL + pinned SHA first. For now this package's content is locally-authored (moved from this workspace's own former packages/m3e-okf/data/knowledge/**), not synced from anywhere."
}
```

- [ ] **Step 4.8: Remove the now-empty `packages/m3e-okf` directory**

```bash
rmdir packages/m3e-okf 2>/dev/null || find packages/m3e-okf -type f
```
If any files remain (something this plan's enumeration missed), move them to the correct new home based on whether they're knowledge-side or implementation-side, following the same test used throughout this task.

- [ ] **Step 4.9: Reinstall + run the gate**

Run: `pnpm install && node tools/gate-all.mjs`

Watch specifically for: `material-okf: check`/`test`, `m3e-api-okf: check`/`test` (both newly-discovered via `pnpm ls -r`), `workspace: copy-fidelity m3e-okf` (now pointing at `m3e-api-okf`'s `srcDir`), and the E2E facts-bundle proof (uses `ELM_M3E`, unaffected by this task). Patch forward on any failure, re-run until green.

- [ ] **Step 4.10: Commit**

```bash
git add -A
git commit -m "reorg(m3e-okf): split into brands/m3e/inputs/material-okf (knowledge) + brands/m3e/outputs/m3e-api-okf (CEM-verified implementation)"
```

---

## Task 5: Stand up `brands/m3e/inputs/cem`

**Files:**
- Move (git mv): `brands/m3e/outputs/elm-m3e/config/*` → `brands/m3e/inputs/cem/config/*`
- Create: symlink `brands/m3e/outputs/elm-m3e/config` → `../../inputs/cem/config`
- Modify: `tools/gen-figma-config.mjs` (line 47, again — final value this time)

- [ ] **Step 5.1: Move the config files**

```bash
mkdir -p brands/m3e/inputs/cem
git mv brands/m3e/outputs/elm-m3e/config brands/m3e/inputs/cem/config
```

- [ ] **Step 5.2: Recreate the symlink so relative `config/*.json` invocations keep working**

```bash
ln -s ../../inputs/cem/config brands/m3e/outputs/elm-m3e/config
git add brands/m3e/outputs/elm-m3e/config
```

This mirrors the existing `core/elm-cem/elm-html-intermediate-representation -> ../elm-html-intermediate-representation` precedent already in this repo. `tools/lib/regen.mjs`'s `--config-from=config/slots.json` etc. (resolved relative to `cwd: elmM3e`) and `tools/ab-elm-cem.sh`/`tools/ab-elm-m3e-split.sh`'s equivalent invocations need **zero further edits** — `config/` still resolves through the symlink.

- [ ] **Step 5.3: Point `gen-figma-config.mjs` at the real location**

Edit line 47 (currently the Step 2.6a interim value):
```js
const elmM3eConfigDir = path.join(repoRoot, "brands", "m3e", "inputs", "cem", "config");
```

- [ ] **Step 5.4: Run the gate**

Run: `node tools/gate-all.mjs`

The E2E facts-bundle proof (`factsBundleE2E`) is the sharpest test here — it invokes `runFactsGenerator`, which shells out with `cwd: elmM3e` and the `--config-from=config/*.json` args; if the symlink is wrong this fails immediately with an `ENOENT` on a config file. Patch forward, re-run until green.

- [ ] **Step 5.5: Commit**

```bash
git add -A
git commit -m "reorg(m3e-inputs): move elm-m3e's config/*.json to brands/m3e/inputs/cem, symlink back for compat"
```

---

## Task 6: Cleanup + final verification

**Files:**
- Modify: cosmetic-only comment fixes in `tools/install-toolchains.mjs`, `tools/check-single-cem-facts.mjs`, `tools/gate-all.mjs`, `tools/publish-mirror.mjs`, `tools/gen-hooks.mjs`, `tools/ab-elm-cem.sh`, `tools/ab-elm-m3e-split.sh`, `tools/check-drift.mjs`, `tools/gen-figma-config.mjs`, `tools/snapshot-refs.json`
- Modify: `docs/superpowers/specs/2026-08-18-core-brands-workspace-reorg-design.md` (status line)

- [ ] **Step 6.1: Sweep remaining cosmetic `packages/<old-name>` mentions in comments**

```bash
grep -rn "packages/elm-cem\b\|packages/elm-m3e\b\|packages/elm-cem-compose\b\|packages/elm-html-intermediate-representation\b\|packages/elm-review-cem\b\|packages/elm-typed-html\b\|packages/m3e-okf\b\|packages/tailwind-m3e-web\b\|packages/cem-figma-connect\b" tools/ .github/ 2>/dev/null
```

For each hit remaining after Tasks 2–5 (should now be comment-only prose — anything functional would already have failed a `gate-all` run), update the path in the comment text to match its new location. This is pure documentation accuracy, not required for gate-all to pass — verify with a final gate run in Step 6.3 that nothing here was accidentally load-bearing.

- [ ] **Step 6.2: Flip the spec's status line**

In `docs/superpowers/specs/2026-08-18-core-brands-workspace-reorg-design.md`, change:
```
Status: draft, pending user review
```
to:
```
Status: implemented (2026-08-18) — see docs/plans/2026-08-18-core-brands-workspace-reorg-plan.md
```

- [ ] **Step 6.3: Final full gate-all run**

Run: `node tools/gate-all.mjs`

Expected: `GATE-ALL GREEN`, with the summary package list showing the new names/paths (`core/elm-cem`, `brands/m3e/outputs/elm-m3e`, `tailwind-md3`, `material-okf`, `m3e-api-okf`, etc.) and zero unexpected skips beyond the pre-existing `CHRONIC_SKIPS` (network-dependent snapshot gates, unrelated to this reorg).

- [ ] **Step 6.4: Commit**

```bash
git add -A
git commit -m "docs(reorg): cosmetic path-reference cleanup, flip spec status to implemented"
```

---

## Self-review notes

- **Spec coverage:** target layout (Task 2–5), m3e-okf split (Task 4), tailwind-m3e-web split (Task 3), naming decisions (no rename needed for `tailwind-m3e-web`/`cem-figma-connect` — confirmed, no task required), non-goals respected (no Carbon brand stood up, no CLI change, no publish/mirror rewiring beyond the required `srcDir` pointer updates which are structural not publishing actions).
- **Both explicit open questions resolved** with concrete, evidence-backed answers (grep sweep enumerated above; package.json split decided and justified).
- **Three additional gaps found during planning** (not in the spec's own open-questions list) are each resolved with a concrete mechanism: relative-path depth changes (enumerated per-file), the `build-okf.mjs` script-boundary crossing (split into two scripts with verified I/O), and `brands/m3e/inputs/cem`'s actual physical contents (config/*.json + symlink, with `custom-elements.json` clarified as never having been a committed file).
- **Known deferred item, explicitly flagged, not silently dropped:** `material-okf`'s external-repo sync (spec's "Sync mechanism" paragraph) needs a real repo coordinate from Jack before it can be wired into `tools/snapshot-refs.json` — left as a `$TODO` in `family.json` rather than fabricated.
