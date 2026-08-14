---
name: elm-cem-repo-separation
description: "State of splitting the elm-cem monorepo into tool (#1) + template (#2) + per-library packages (#3); private repos created 2026-06-21"
metadata: 
  node_type: memory
  type: project
  originSessionId: ae776770-02ac-4bdf-96d1-8075ab0a9618
---

Splitting `elm-custom-elements-manifest` (elm-cem) into three deliverables, defined in its `SHIPPING.md`. See [[elm-cem-codegen-overhaul]] for the generator/branch state. All work done 2026-06-21; everything kept PRIVATE for review before publishing.

**#1 Tool** — kept the existing repo `jackhp95/elm-custom-elements-manifest` (no new repo, no rename). Made it **private** 2026-06-21. The restructure (bin/ + codegen/) still lives on PR #10 / branch `codegen-quality-overhaul`, NOT merged to `main`. Final cleanup (deferred, user-sequenced LAST): merge #10 → main, strip repo to tool-only (drop legacy `generated/`, `packages/`, examples, playground), back up (tag + `git bundle`) then squash history, then `npm publish`.

**#2 Template** — `jackhp95/elm-cem-template` (private, flagged as a GitHub template via `is_template`). Local: `~/Documents/code/elm-cem-template`. Pre-wired to Shoelace; `npm install && npm run gen && npm run validate` is green. Key design choices vs SHIPPING sketch:
- `scripts/set-exposed-modules.mjs` auto-populates `elm.json` exposed-modules from `src/` (kills the manual step the overhaul memory complained about).
- `src/` is COMMITTED, not gitignored (Elm registry publishes from the tagged tree).
- Tool dep = `github:jackhp95/elm-custom-elements-manifest#codegen-quality-overhaul` (private; npm install resolves via osxkeychain git creds). Switch to npm version once tool is published. CI (`generate.yml`) needs a token with read access to the private tool until then.
- Retarget = change 4 things: package.json dep + `gen` flags-from path, elm.json name+summary, README/examples.

**#3 Per-library packages** — 6 private repos, each a template instance (carries the gen harness; `src/` committed; examples/ dropped). All generated + passed `elm make --docs`; counts match the monorepo's `packages/`:
- elm-shoelace (`Sl`, 60), elm-warp (`W`, 28), elm-web-awesome (`Wa`, 59), elm-fluent-ui (`Fluent`, 61) — docs well under limit.
- elm-calcite (`Calcite`, 115, docs 586KB) and elm-m3e (`M3e`, 127, docs 751KB) **exceed the 512KB Elm-registry docs.json limit** — validate fine but must be doc-split before `elm publish`.
- **M3E** = matraic `@m3e/web@2.5.12`, ships `dist/custom-elements.json` (now supported). This is the 10th/11th library; not in the monorepo `packages/`.

**"Naturally support CEMs"** (ship their own manifest, no clone+`cem analyze`): shoelace, warp, webawesome, calcite, fluentui, m3e. The rest (carbon, spectrum, material-web, ionic) need cloning + `cem-configs/`.

**Thermo-nuclear review + fixes (2026-06-22, tool tag `v0.2.1` on branch `codegen-quality-overhaul`):** A 4-agent thermo-nuclear review drove a generator overhaul, then all repos were re-rolled. Key changes in `codegen/`:
- **Dropped the top-level aggregator module entirely** (was `Sl`/`Calcite`/`M3e` etc.). It duplicated every component's docs and silently collapsed colliding attr/event names (lossy API). Users now import per-component modules + `<Lib>.Common`. This + trimming CSS-token doc dumps fixed the 512KB problem: calcite 586→**286KB**, m3e 751→**183KB**, all 6 now well under limit and `elm make --docs`-valid.
- Routed all naming through `Naming` (deleted inline mungers + `Util.capitalize`); `Cem` decoder no longer fabricates `"unknown"`; nameless members filtered once via `dropNamelessMembers`; deleted dead code (unionTypes, generateComponentDocumentation, Emit.reexportDeclarations/setterType, generateDeduplicatedEventFunctions). `Generate.elm` 773→~430 lines. 89 tests pass.
- **`bin/elm-cem.js` now: (a) uses execFileSync (no shell), (b) writes `elm.json` exposed-modules itself, (c) clears stale `.elm` in the output dir before generating.** So `set-exposed-modules.mjs` was deleted from the template + all per-lib repos.
- Distribution: dep pinned to **tag `#v0.2.1`** (not a moving branch); manifest path hoisted to `package.json` `config.cem` (single retarget point); per-lib repos dropped the broken private-dep CI workflows; template's `generate.yml` made honest (ELM_CEM_TOKEN auth + warning). All 8 repos re-pushed.
- **npm gotcha:** npm cached the old branch SHA for the git dep; had to `rm -rf ~/.npm/_cacache` to get `#v0.2.x` to resolve to new code. Fresh machines/CI are unaffected.

**Still to do:** publish #1 to npm and #3 to the Elm registry (registry requires PUBLIC repos) after review; finalize #1 strip/squash (merge PR #10, drop `generated/` + stale `packages/`, backup+squash). **Monorepo `packages/` is now stale vs the v0.2.1 generator** (not regenerated — slated for removal in the strip). The standalone `elm-custom-elements-manifest-package` (Elm CEM decoder) looks orphaned now that the decoder lives in `codegen/Cem.elm` — fate undecided.
