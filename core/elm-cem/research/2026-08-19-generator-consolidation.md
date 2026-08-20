# Generator consolidation — one Elm codegen pass, a thin JS shell, and facts as the hub

**Status:** Research (feasibility; companion to `core/elm-cem/specs/2026-08-19-brand-facts-design.md`)
**Date:** 2026-08-19
**Question (Jack):** Can the three separate generators become **one Elm codegen
process** that emits everything Elm? And, holistically, which JS scripts can
consolidate / split / die, and how do they interplay with the facts?

Grounded by two read-only investigations; every claim carries a `path:line`.

## 1. Verdict

- **Yes.** One `elm-codegen` process can emit the full multi-package `.elm` tree,
  every per-package `elm.json`/`README`/`LICENSE`, and the facts JSON — because
  `Elm.File.path` is an unconstrained string and elm-codegen's writer does
  `path.join(output_dir, file.path)` + recursive `mkdir` (so `path` may traverse
  `..` into sibling package trees). It already emits a JSON file today
  (`Generate/Phantom/Emit/FactsBundle.elm:37-42`).
- The three JS generators' **core logic is "generate Elm source,"** which belongs
  in the Elm pass. What legitimately remains JS is a **thin shell**: TypeScript
  `.d.ts` scraping, host/git provenance, filesystem idempotency probes, and the
  elm-codegen invocation itself — exactly the "scrapers + orchestration stay JS"
  line you drew.
- **Non-Elm outputs stay JS** (Tailwind CSS, Figma config, OKF markdown/skill,
  cem-figma-connect emitters) — correct as-is.
- The dominant risks are **not** "can Elm do it" but preserving today's
  dependency-DAG-check fidelity and not silently depending on an undocumented
  elm-codegen writer behavior (§5).

## 2. The three generators — per-generator verdict

| Generator | What it does | Why JS today | Verdict |
|---|---|---|---|
| `gen-icon-module.js` | `_iconModule` + icon catalog → one `M3e.Icon` Elm module | none structural — **zero CEM dependency**, pure config→Elm string with `fs` for I/O | **belongs in the Elm pass** — cleanest port. Blocker: `_iconModule`/catalog aren't in Elm flags (`grep _iconModule codegen/` → nothing) |
| `gen-family-package.js` | reads `_families`, **regex-reparses the just-rendered `M3e.Component.*` text** off disk (`parseModuleSurface`, `gen-family-package.js:101-153`) to rebuild `exposing`/type-alias/annotation data, then string-templates family modules | accidental — it reconstructs, via fragile regex over rendered text, data the phantom model already has natively (`Comp.attrs`/`.enums`/`.resolvedCtor`) | **belongs in the Elm pass** — strongest case; it's re-deriving Elm data from Elm text. Blocker: `_families` not in flags |
| `split.js` | walks materialized `.elm` tree, assigns modules→packages by `packages.json` buckets (`split.js:110-131`), regex-scans `import` lines for a dep-DAG gate (`split.js:165-184`), emits per-package `elm.json`/README/LICENSE + copies files | runs as a **second pass over the codegen's own on-disk text** rather than the in-memory model | **mixed** — the partition + DAG logic is model work (belongs in Elm, computed against `Brand`/`Comp`); `walkElm`/`copyFileSync` vanish once the Elm pass emits directly into per-package `src/` |

Common thread: all three re-derive, from disk/text, information the Elm pass
already holds — the split is an artifact of history, not necessity. The single
missing plumbing is that `_families`/`_iconModule` never reach Elm's flags today.

## 3. elm-codegen emission model (grounded)

- `Elm.File = { path : String, contents : String, warnings }`
  (`elm-codegen/6.0.1/src/Elm.elm:419-422`) — `contents` is a plain string, not
  constrained to Elm source (proven by the JSON facts file already emitted).
- The npm CLI writes `path.join(output_dir, file.path)` with `mkdirSync(..,
  {recursive:true})` (`node_modules/elm-codegen/dist/run.js:161-163`) — so one run
  can emit nested dirs and, via `../`, sibling package trees.
- `main : Program Json.Decode.Value () ()` (`Generate.elm:24`) — **single-shot,
  pure function of one flags value; no mid-run filesystem read.** `--flags-from`
  accepts a directory and bundles every file into flags (`run.js:669-682`) — a
  built-in way to compose many inputs without Node-side pre-merge.
- **Hard constraint:** every input must arrive up front — manifest, all config,
  `_families`, `_iconModule`, icon catalog, and any "does this file already exist"
  idempotency facts.

## 4. What must stay JS (a thin shell), and why

- **TypeScript `.d.ts` scanning** (`elm-cem.js:801-964`) — walks an arbitrary npm
  package's `.d.ts` tree and parses TS literal unions / const-enums; no Elm TS
  parser exists. This is an **input scraper** (your carve-out).
- **Bundled/relative asset loading** (`injectNativeAttrs`, `elm-cem.js:333-370`;
  and staging config into flags) — `__dirname`/`require.main`-relative reads with
  no flags-model equivalent; feed into the single flags payload.
- **Host/process provenance** (`tryGitHead`, `findPackageJsonUp`,
  `elm-cem.js:524-628`) — git HEAD + nearest package.json are CLI-time host reads.
- **Idempotency probes** — README/LICENSE "write only if absent" needs a pre-run
  `stat`; the shell probes and passes the result into flags.
- **elm-codegen invocation + CLI dispatch** (`resolveElmCodegen`, the subcommand
  table) — process orchestration, not generation.

Everything else in `elm-cem.js` (`injectConfig` deep-merge, `parseOutput`,
`readPublishShape`) is JSON-shuffling that exists only because flags arrive from N
`--config-from` files; elm-codegen's directory-flags mode can absorb most of it.

## 5. Migration risks (ranked)

1. **DAG-check fidelity (hardest).** Today's gate regexes the *literal bytes*
   written to disk, including hand-authored raw-string `import`s in each
   `Generate/Phantom/Emit/*` module (`Emit.elm:5` — raw strings, not
   elm-codegen's auto-import-tracked API). Moving it into Elm requires each
   emitter to also **declare its imports as data** so the check stays byte-faithful
   — a refactor across every emitter, else the gate silently weakens.
2. **Undocumented writer reliance.** Multi-package emission via `path: "../other-pkg/src/X.elm"`
   works only because `path.join` resolves `..` (`run.js:161`); nothing in
   elm-codegen's contract promises this. A future sandboxed writer would break it.
   Flag to elm-codegen or design a first-class multi-output mechanism.
3. **`_families`/`_iconModule` not in flags** — plumbing, but touches
   `Generate.Config`'s decoder and the `_config` deep-merge (`elm-cem.js:425-450`),
   whose two-level merge assumption doesn't fit these nested-object keys.
4. **Idempotency state must be pre-staged** into flags (README/LICENSE preserve).
5. **Easy:** `reconcileTagNames` (`elm-cem.js:265-324`) is a pure CEM-JSON transform
   already shaped like `Generate.Normalize` — mechanical to port. `gen-icon-module`
   ports with the lowest risk once its config reaches flags.

## 6. Holistic JS script census

The repo already ran a 2026-08-17 "thermonuclear audit" that consolidated most
duplication (`gen-facts-runner.mjs`, `regen.mjs`, `component-css-utilities.mjs`,
`gen-hooks.mjs`). Categories: **S** input-scraper · **E** Elm-output · **N**
non-Elm output · **F** facts producer/validator · **G** gate/glue.

- **E (Elm output → candidates for the single Elm pass):** `gen-icon-module.js`,
  `gen-family-package.js`, `split.js`, and the Face-A half of `elm-cem.js`;
  `classify.js` (structural classifier of Face-A output).
- **F (facts):** `facts-bundle.js` (Face B), `validate-facts-bundle.js`,
  `tools/lib/regen.mjs`, `tools/lib/gen-facts-runner.mjs`, the consumer
  `gen-facts.mjs` copies.
- **N (non-Elm output — legit JS):** `gen-figma-config.mjs`,
  `tools/lib/component-css-utilities.mjs`, tailwind `generate-component-utilities.mjs`,
  cem-figma-connect `emit/**` + `profiles/m3-kit/emitters/elm.mjs`, okf `build-skill.mjs`.
- **S (scrapers — legit JS):** `fetch-snapshots.mjs`, `fetch-mdn-native-summaries.mjs`,
  `oracle.mjs` (mapping oracle), the scrape half of okf `extract.mjs`, `render-verify.mjs`.
- **G (gate/glue):** the rest of `tools/*` and `elm-cem.js`'s subcommands.

### Consolidation candidates (new, beyond the audit)
- `docs/scripts/examples-gen/lib/facts.mjs` keeps its **own copy** of `GEN_CONFIG_ARGS`
  (`lib/facts.mjs:33-38`) that `tools/lib/regen.mjs:25-30` already centralizes —
  "kept in step by hand." Route through `regen.mjs`.
- `gen-figma-config.mjs:338` self-notes it is **not yet** wired into `regen.mjs`'s
  args — same drift risk.

### Split candidates
- `m3e-api-okf/scripts/extract.mjs` does two jobs with different trust levels:
  (a) project Face B → `components.json` (facts consumption) and (b) scrape raw TS
  for README/`:host` display (`extract.mjs:30-31,210,216`). Split so the
  bypass boundary is explicit.
- `elm-cem.js` (44 KB) still mixes Face-A codegen + Face B/C write + CLI; finish
  the extraction already in progress (`post-generate.js:1-10` cites prior code-motion).

### Dead / vestigial
- `fetch-mdn-native-summaries.mjs` + the `_nativeAttrTable` injection
  (`elm-cem.js:327-362`) — the `_native` dead-config surface (self-documented
  `fetch-mdn-native-summaries.mjs:20-29`); Theme-5 cleanup not yet run.
- `cem-figma-connect/src/ingest/dts-inline.mjs` — dead-in-pipeline, kept for tests.

## 7. Facts as the hub — the bypass offenders to re-route

The whole pipeline already routes through Face B/C **except** three documented
bypasses — the re-route-through-Brand-Facts candidates:

1. **`oracle.mjs`** (`docs/scripts/examples-gen/lib/oracle.mjs:26-33`) — reads raw
   `custom-elements.json` **and** `config/slots.json` because Face B's distilled
   shape drops raw fields the HTML→Elm mapper needs (`type.raw`/`parsed` vs raw
   `attr.type.text`; `tagReconciliation.mismatches` vs raw `mod.exports`). **Top
   candidate:** the Brand Facts superset (spec §4.6 — retain `source :
   Cem.Declaration`) closes this directly.
2. **`extract.mjs`** — `:host { display }` and README prose the bundle can't carry
   (`extract.mjs:30-31,163,210,216`). Either add a `restingDisplay` fact per
   component or formally accept README/display as a permanent out-of-bundle
   category. (This is the CSS-display gap the Brand Facts spec §1 already notes.)
3. **`render-verify.mjs`** — loads the compiled `@m3e/web` into jsdom to verify
   build-vs-manifest agreement; a legitimate bypass (Facts can't self-certify a
   build), **not** a routing gap.

## 8. Recommendation

The single-Elm-generator goal is sound and **complements** the Brand Facts work —
they share the same move (make the Elm resolved model authoritative and emit
everything from it). Suggested sequencing, as a **companion track** to the facts
spec's phases:

- **G1 — plumb `_families`/`_iconModule` into Elm flags** (risk #3). Unblocks the
  two easy ports.
- **G2 — port `gen-icon-module` into the Elm pass** (lowest risk, zero CEM dep).
- **G3 — port `gen-family-package` into the Elm pass** (kills the fragile
  text-reparse; uses `Brand.comps` natively).
- **G4 — move `split`'s partition + DAG check into the Elm pass**, emitting
  directly into per-package `src/` — **gated on** resolving risk #1 (emitters
  declare their imports as data) and a decision on risk #2 (writer `..`-traversal
  vs a first-class multi-output mechanism / raising it with elm-codegen).
- **Parallel cleanups** (independent, low-risk): route `examples-gen/lib/facts.mjs`
  + `gen-figma-config.mjs` through `regen.mjs`; run the `_native` dead-surface
  removal; extend Brand Facts to close the `oracle.mjs`/`extract.mjs` bypasses
  (folds into the facts spec's phase 2 + phase 4).

Net: JS shrinks to scrapers (`.d.ts`, MDN, snapshots), non-Elm output generators,
host/provenance + idempotency probes, and the elm-codegen invocation — one Elm
process owns all Elm output and the facts, with facts as the single hub every
non-Elm consumer reads.
