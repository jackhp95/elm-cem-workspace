# docs-gen (WIP skeleton)

Brand-agnostic generator for the **generated docs surface** (family table, token
galleries, per-component reference, …). The docs-layer peer of
`pipeline/elm-cem-compose`; follows the JS `pipeline/elm-cem-figma-connect` shape
(agnostic core + brand-supplied config).

> **Status: SKELETON.** The data-derivation core is built and parity-tested; the
> route-generation layer and brand adoption are NOT built. See **[DESIGN.md](./DESIGN.md)**
> §5 for the full gap list. This package is intentionally excluded from the
> workspace/gate graph (`pnpm-workspace.yaml`) until it is adopted.

## What works today

Pure, dependency-free transforms from a brand's config to the generated docs data:

| Function | From | Produces |
|---|---|---|
| `deriveFamilies(familiesConfig)` | `slots.json._families.families` | the `/family` page table |
| `deriveTypescale(css)` | `--md-sys-typescale-*` CSS | the type-scale gallery rows |
| `deriveShapeCorners(css, sizes)` | `--md-sys-shape-corner-*` CSS | the corner-radius scale |
| `deriveColorRoleInventory(css)` | `--md-sys-color-*` CSS | the full color-role inventory |
| `splitSections(md)` / `joinSections` | `@@@`-delimited guide `.md` | the guide-prose section map |

```js
import { deriveFamilies, deriveTypescale } from "docs-gen";
```

## Test

```sh
cd pipeline/docs-gen && npm test
```

The tests are **parity tests**: they run the core against the real m3e brand
inputs and assert byte-equality with the committed `elm-m3e-docs/data/*.json` — the
proof that the extracted seam faithfully reproduces the brand's own generators, so
a brand's `gen-*` script could delegate here without changing any output.

## Next

The bulk of a real docs-gen is the **route-generation layer** (emitting the
per-component reference / gallery / family Elm pages from the facts bundle), plus
lifting `extract-reference` / `examples-gen` in and having a brand consume it. See
[DESIGN.md](./DESIGN.md) §4–§5.
