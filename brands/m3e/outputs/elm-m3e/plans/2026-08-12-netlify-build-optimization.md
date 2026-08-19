# Netlify build-time optimization for the elm-m3e docs site

**Date:** 2026-08-12
**Status:** **Option (iii) chosen and implemented** (supersedes #224's cache approach).
**Related:** PR #224 (`feat/prepush-commit-generated-docs`) — this PR supersedes it. See reconciliation section below.

## TL;DR

- **The premise behind #224's original motivation was wrong.** Committing `docs/.elm-pages/` does **not** save Netlify build time. `elm-pages build` regenerates `.elm-pages/` from scratch on every build and never reads the committed copies.
- **The real cost of a Netlify build here is the two `lamdera make` Elm compiles** that `elm-pages build` runs (client app + server/CLI app).
- **Option (iii) — commit + serve `dist/` — is the chosen path.** Jack's explicit decision: Netlify's build is now a no-op (`command = "true"`); the committed `docs/dist/` is served directly. The pre-push hook builds and commits it locally before each push.
- **Accepted tradeoffs:** large, churny diffs in git history (minified bundle churn); bloats repo size over time. Acceptable for a docs repo. The payoff is instant, reproducible deploys with zero Netlify build time.

## Investigation (what is actually true)

### The build pipeline

- Netlify base directory = `docs/`; `publish = "dist/"` (relative → `docs/dist`).
- Old build command: `export ELM_HOME="$NETLIFY_BUILD_BASE/cache/elm" && corepack enable && pnpm install --frozen-lockfile && pnpm run build:ci`
- `build:ci` = `gen:reference` (`elm make --docs`) → `check:nav` → `build:site` (`elm-pages build` + search-index gen).

### Where time goes

`elm-pages build` runs, in order:

1. **Codegen** — synthesizes `.elm-pages/` modules from `app/Route/*.elm`. Fast-to-moderate.
2. **`lamdera make` of the client app** → optimize-level-2 → terser. **Heavy.**
3. **`lamdera make` of the server/CLI app**; `esbuild` bundles `compiled/render.mjs`. **Heavy.**
4. **Vite asset bundling.** Moderate.
5. **Pre-render of every route** across worker threads. Cheap.

For a docs site whose routes are all `single`/`preRender`, **steps 2–3 dominate.**

### Does committing `.elm-pages/` help? — No.

`build.js` calls `codegen.generate()` unconditionally at the start of every build. It synthesizes the `.elm-pages/` modules from route files and only writes via `writeFileIfChanged`. `compiled/render.mjs` is rebuilt by `esbuild` every run. **The committed `.elm-pages/` copies are never read as input.** Committing `.elm-pages/` is pure repo hygiene — zero Netlify build-time saving. (This was the false premise behind #224's original motivation.)

## Options considered

| Option | What | Build-time win | Repo impact | Verdict |
|---|---|---|---|---|
| (i) Cache `elm-stuff` via plugin | persist `docs/elm-stuff` across Netlify builds | Real but incremental (project recompile only) | ~13 lines in `netlify.toml`. No git churn. | Considered; superseded by (iii) |
| (ii) Commit `.elm-pages/` | keep tracked codegen in sync | **None** — elm-pages always regenerates it | Pure repo hygiene | Rejected (impossible as build win) |
| **(iii) Commit + serve `dist/`** | un-gitignore built output; `publish=dist`; no-op Netlify build | **Max** — zero Netlify build time | **HIGH** — large, churny diffs; bloats history | **✅ CHOSEN (Jack's explicit decision)** |

## What this PR implements (option iii)

1. **`docs/.gitignore`**: removed `dist/`; added `.elm-pages/`.
2. **`git rm -r --cached docs/.elm-pages`**: untracked the 5 previously-tracked codegen files. Fresh clones and CI still regenerate `.elm-pages/` at build time — elm-pages synthesizes it unconditionally.
3. **`docs/dist/`**: built via `pnpm run build:ci` (same reduced build Netlify previously ran) and committed. The committed output is what Netlify now serves.
4. **`docs/netlify.toml`**: `command = "true"` (no-op); `publish = "dist/"` unchanged; redirects + `[build.environment]` preserved.
5. **`hooks/pre-push`**: after gate passes, runs `pnpm run build:ci` in `docs/`, stages ONLY `docs/dist/` (pathspec-scoped — never `git add -A`), commits `chore(docs): prebuilt dist/ [skip ci]`, self-pushes under `PREPUSH_GENERATED_SELF` guard, then aborts the outer push (stale ref snapshot). Non-interactive/`CI=1` → skip + exit 0. `PREPUSH_FORCE_DIST_COMMIT=1` → force. No-change → no commit.

## Accepted tradeoffs

- Every content change produces a large diff (minified JS/CSS/HTML churn).
- `git` history grows permanently (binary-like build output).
- Review noise increases on the `docs/dist/` subtree.
- Local `git push` pays the ~2–4 min Elm build (previously paid by Netlify).

In exchange: Netlify deploys are instant, reproducible, and never fail due to Elm toolchain availability or build environment drift.

## Reconciliation with PR #224

- #224 (`feat/prepush-commit-generated-docs`) is **superseded** by this PR.
- #224's hook patterns (self-push under `PREPUSH_GENERATED_SELF`, non-interactive skip, `PREPUSH_FORCE_*` override, pathspec-scoped staging + commit) are directly reused here, adapted to target `docs/dist/` instead of `docs/.elm-pages`.
- #224's `netlify-plugin-cache` for `elm-stuff` is **not included** — it was a partial incremental win superseded by eliminating the build entirely.
- #224 should be closed as superseded by this PR.

## Verification

See task report in the PR body for:
- Hook test evidence (4 cases: dist change, unrelated staged file, CI=1, no-change).
- Confirmation `.elm-pages/` is untracked, `dist/` is committed, netlify command is no-op.
