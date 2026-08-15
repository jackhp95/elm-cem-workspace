# elm-cem-workspace

The consolidated home for the **elm-cem codegen family** — the forge that turns a
component library's Custom Elements Manifest (CEM) into typed Elm packages, Figma
Code Connect, Tailwind utilities, and agent skills, and keeps them in sync as the
library changes.

**Start here:** [`VISION.md`](VISION.md) — what this is and where it's headed. ·
Live status: [`GAUNTLET-LEDGER.md`](GAUNTLET-LEDGER.md). · Phase-0 design:
[`docs/superpowers/specs/2026-08-12-elm-cem-workspace-spine-design.md`](docs/superpowers/specs/2026-08-12-elm-cem-workspace-spine-design.md).

The workspace hosts a pnpm JS graph and an Elm `elm.json` graph side by side. The
family packages live under `packages/` (elm-cem, elm-m3e, cem-figma-connect, m3e-okf,
tailwind-m3e-web, elm-cem-compose, and the shared substrate), with a root task runner
and gate that operate over both graphs. The `packages/_probe/` pair is the living,
executable test of the coexistence convention below.

## Layout

```
packages/
  <name>/                  one directory per absorbed package,
                            internal structure preserved verbatim
tools/
  tasks.mjs                enumerates the whole family graph (JS + Elm)
  gate.mjs                 root gate: runs tasks, compiles the Elm probe
pnpm-workspace.yaml         pnpm workspace globs
elm-tooling.json             pins the Elm toolchain at the workspace root
```

## The convention

1. **`packages/<name>/`, one directory per absorbed package**,
   internal structure preserved verbatim. A package dir may host both
   ecosystems at once.
2. **pnpm owns the JS graph.** `pnpm-workspace.yaml` globs `packages/*` and
   `packages/*/*` (the second glob catches nested JS packages), excluding
   `node_modules` and `elm-stuff`. Cross-package JS deps use `workspace:*`.
3. **Elm `type: package` `elm.json`s stay registry-faithful** — published
   `name`, normal semver registry `dependencies`. No monorepo-specific paths
   ever appear in a `type: package` elm.json, which keeps future Elm-registry
   publishing open.
4. **Local resolution happens only at the application layer.** An Elm
   `type: application` elm.json resolves an in-workspace Elm package by
   adding that package's `src/` to its own `source-directories` as a
   workspace-relative path (e.g. `"../elm-probe-pkg/src"`).
5. **The Elm toolchain is pinned at the workspace root** via a root
   `elm-tooling.json` plus the `elm-tooling` devDependency. Elm 0.19.1 is
   pinned, providing `elm`, `elm-format`, and `elm-test-rs`.
6. **A root task runner enumerates both graphs** — pnpm workspace packages
   with their scripts, and every discovered `elm.json` with its type and
   name. This is the one component that knows the whole family graph.

## Probe

`packages/_probe/elm-probe-pkg` is a registry-faithful Elm `type: package`
exposing `Probe.Lib.probeAnswer`. `packages/_probe/elm-probe-app` is an Elm
`type: application` that imports it via a workspace-relative
`source-directories` entry, demonstrating rule 4.

Run `pnpm run tasks` to see the enumerated graph, and `pnpm run gate` to
compile the probe and verify the layout.
