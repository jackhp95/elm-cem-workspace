---
name: generating-elm-bindings
description: >-
  Generates type-safe Elm bindings from a web component library's Custom Elements
  Manifest using the elm-cem CLI, end to end. Use in projects that depend on elm-cem
  when the user wants to "generate Elm bindings", "wire up elm-cem", "run elm-cem",
  create typed Elm modules from a custom-elements.json / CEM, add a `gen` script, or
  bind a component library (Shoelace, Carbon, Spectrum, Ionic, any `x-*` custom
  elements) into an Elm app. Covers acquiring a manifest (vendor-shipped vs the
  @custom-elements-manifest/analyzer), the --flags-from/--output/--config-from flags,
  validating with `elm make --docs`, and the commit-the-generated-tree convention.
  Not for authoring config overrides key-by-key (see configuring-cem-overrides) or
  diagnosing wrong output (see debugging-generated-output).
---

# Generating Elm bindings with elm-cem

elm-cem turns a component library's **Custom Elements Manifest** (`custom-elements.json`)
into a typed Elm binding layer. It ships no components and no runtime beyond plain
`elm/html`; it emits `<Lib>.*` modules named after the library's own tag prefix.

## Prerequisites (verify first)

- **Node.js ≥ 18** and elm-cem installed (dev dependency, or `github:jackhp95/elm-cem`
  pre-release).
- An **`elm` 0.19.1 compiler on `PATH`**. `elm-codegen` ships with elm-cem, but the
  `elm` binary does **not** — install `elm@0.19.1-6` globally or pin it with
  `elm-tooling`. If `elm` is missing, the run fails with `elm-codegen` "Compilation
  failed" **after** the output dir is already cleared (see footguns).

## The five steps

1. **Get a manifest.** Most libraries ship one in their npm package (e.g.
   `node_modules/<pkg>/dist/custom-elements.json`). If not, produce one upstream with
   [`@custom-elements-manifest/analyzer`](https://github.com/open-wc/custom-elements-manifest);
   this repo ships ready-made analyzer configs under `cem-configs/` (Carbon, Ionic,
   Spectrum). Those are analyzer configs, **not** elm-cem `--config-from` configs.

2. **Generate** into a dedicated output directory:

   ```bash
   npx elm-cem \
     --flags-from=node_modules/<pkg>/dist/custom-elements.json \
     --output=src/Generated
   ```

   `--flags-from` (the CEM, required) and `--output` (a dir, required) are the only
   mandatory flags. `--config-from=<json>` is optional and repeatable.

3. **Inspect the output.** Modules land under the library's namespace `<Lib>` (derived
   from the tag prefix — `sl-*` → `Sl`, `x-*` → `X`): a `<Lib>.elm` barrel, one
   `<Lib>.<Component>` per component (strict top layer), and lower layers under
   `<Lib>.Html.*` / `<Lib>.Raw.*`, plus `<Lib>.Token`. Read the generator's stdout —
   `⚠️`/`ℹ️` lines flag real modeling issues (see debugging-generated-output).

4. **Validate it compiles the way a package would.** Point Elm at the barrel, and
   ideally run the docs gate (what `elm publish` runs — stricter):

   ```bash
   elm make src/Generated/<Lib>.elm --output=/dev/null
   elm make --docs docs.json          # from a package elm.json — catches doc/annotation gaps
   ```

5. **Wire a `gen` script and commit the tree** (see below).

A full copy-pasteable Shoelace run is in [reference/end-to-end.md](reference/end-to-end.md).

## Regeneration workflow — commit the generated tree

Bindings are artifacts, but you **commit them** so downstream consumers of *your*
project don't need the elm-cem toolchain:

```jsonc
// package.json
{ "scripts": { "gen": "elm-cem --flags-from=node_modules/<pkg>/dist/custom-elements.json --output=src/Generated" } }
```

```bash
npm run gen           # rerun after upgrading the component library
git add src/Generated # the DIFF is your review surface (see below), then commit
```

The `src/Generated/` diff after `npm run gen` is what you review: added modules/setters
= expected (new component/attribute); a **renamed or retyped** existing signature is a
red flag — investigate before committing.

## Footguns

- **`--output` deletes every `.elm` file in the dir first** so stale modules can't
  linger. Point it at a dedicated dir holding **only** generated modules (e.g.
  `src/Generated/`). Any hand-written `.elm` there will be **deleted**. Non-`.elm`
  files are left alone.
- **Crash-mid-run leaves the output cleared.** If `elm` is missing (or the generator
  crashes), the `.elm` files are already gone. Keep the generated tree in git so a bad
  run is a `git checkout` away, and confirm `elm` is on `PATH` before running.
- **Temp-file residue.** Each run writes up to three temp JSON files to the OS temp dir
  (`elm-cem-tag/-rt/-cfg`), normally cleaned up. A hard crash may leave them; harmless.
- **Base classes leaking as modules.** Analyzer output sometimes includes abstract base
  classes as if they were components. Curate them out with the `_exclude` reserved
  config key (see configuring-cem-overrides), not by deleting generated files.

## Scaffolding a publishable package

To ship the bindings as an Elm package, start from **elm-cem-template**, which sets up
the package `elm.json`, the `gen` script, and CI. elm-cem's CLI auto-syncs a package
`elm.json`'s `exposed-modules` from what it emits, so you don't hand-maintain that list.

---
Validated against elm-cem 1.0.0, 2026-07.
