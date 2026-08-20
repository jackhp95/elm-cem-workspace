# docs-gen — design

**Status: SKELETON / WIP.** The data-derivation core (families, tokens, guide
sections) is built and tested; the route-generation layer and brand adoption are
NOT. This document is the architecture + the honest gap list.

Date: 2026-08-19. Author: docs-codegen maximalist Phase 3.

---

## 1. What this is, and the analogy it follows

`docs-gen` is the brand-agnostic generator for the **generated docs surface** — the
per-component reference pages, token galleries, family page, component browser —
that today live as brand-specific code inside `brands/m3e/generated/docs/elm-m3e-docs/`.
It is the docs-layer peer of `pipeline/elm-cem-compose`.

`elm-cem-compose` is the template for "how this workspace builds a brand-agnostic
tool that brands configure" (verified structure):

- A **headless core** (`Cem.Compose`, a single exposed Elm module) whose entry
  takes a facts bundle + a brand-supplied binding:
  `Cem.Compose.init { facts : List Fact, attrKinds : Dict String AttrKind, root : String }`
  (`pipeline/elm-cem-compose/src/Cem/Compose.elm:125`).
- The `Fact` type comes from the shared `elm-cem-facts` package
  (`pipeline/elm-cem/facts/src/Cem/Facts.elm:61` — `{ component, module_, enums,
  requiredSlots, slotKinds, facets, ... }`).
- The brand supplies the **generated binding** (`Compose.Attrs`, emitted by
  `scripts/gen-compose-attrs.mjs` with a `{- GENERATED ... do not edit -}` header)
  plus its generated facts values; the core is pure and side-effect-free.

`elm-cem-figma-connect` is the second template data-point: a **JS** brand-agnostic
core (`loadCem(bundlePath) -> { components, ... }`,
`pipeline/elm-cem-figma-connect/src/ingest/cem.mjs:100`) + brand `profiles/<name>/`
supplying `cem/`, `figma/`, and brand-specific `emitters/`.

**docs-gen follows the figma-connect shape (JS), not the compose shape (Elm)**,
because the docs generators are already `.mjs` that emit JSON consumed by
elm-pages `BackendTask`s. The unit of reuse is a *data-derivation function*, not an
Elm module.

## 2. The three-part contract (what a brand supplies vs. what docs-gen owns)

```
                 brand-supplied                      docs-gen (agnostic)
  ┌─────────────────────────────────────┐   ┌──────────────────────────────────┐
  │ facts bundle  (Dict String Fact,     │   │ deriveFamilies(familiesConfig)   │
  │   from elm-cem-facts)                │──▶│ deriveTypescale(css, taxonomy)   │──▶ data/*.json
  │ config: slots.json, categories.json, │   │ deriveShapeCorners(css, sizes)   │   (the GENERATED
  │   the --*-sys-* token CSS manifest,  │   │ deriveColorRoleInventory(css)    │    docs surface)
  │   package identities (elm/pkg json)  │   │ splitSections(md)   [guide fmt]  │
  ├─────────────────────────────────────┤   └──────────────────────────────────┘
  │ hand-authored guide markdown         │            (route layer: NOT BUILT — §5)
  │   (content/guides/*.md — Phase 2)    │
  └─────────────────────────────────────┘
```

- **Brand supplies** its facts bundle + config files + hand-authored guide prose.
- **docs-gen owns** the pure transforms from those inputs to the generated docs
  data. The taxonomy that is genuinely M3-specific (which typescale roles exist,
  which corner sizes) is passed as *arguments* with M3 defaults, so a
  `brands/carbon/` can pass its own.
- The brand keeps a thin `gen-*` wrapper that does the fs I/O (read config, call
  docs-gen, write `data/*.json`) — see §4.

## 3. What is built (this skeleton), and tested

`src/families.mjs` — `deriveFamilies(familiesConfig, {sort})`. Faithful to
`gen-family-package.js`'s labelling (root label = family name, member label =
`lowerFirst(path)`, root-first). **Parity-tested** against the real
`slots.json._families.families` → byte-equal to the committed
`elm-m3e-docs/data/families.json`.

`src/tokens.mjs` — `customProps` (generic CSS custom-property parser) +
`deriveTypescale` / `deriveShapeCorners` / `deriveColorRoleInventory`.
**Parity-tested** against the real `elm-m3e-tailwind/src/sys/*.css` → byte-equal to
the committed `style-tokens.json` sub-tables.

`src/sections.mjs` — `splitSections` / `joinSections`: the `@@@ <name>` guide-md
format, the shared contract between the authored `.md`, the Elm reader
(`Doc.sections`), and JS tooling. **Tested** against a real migrated chapter.

Run: `cd pipeline/docs-gen && npm test` (5 tests, no dependencies — node builtins
only). The package is **excluded from the workspace/gate graph**
(`pnpm-workspace.yaml`) until §5 lands and a brand adopts it.

## 4. Migration path (how a brand adopts docs-gen, incrementally)

The brand's existing generators become thin wrappers. Example for family data —
the brand `scripts/gen-family-data.mjs` would collapse to:

```js
import { deriveFamilies } from "docs-gen";
const slots = JSON.parse(fs.readFileSync(SLOTS, "utf8"));
fs.writeFileSync(OUT, JSON.stringify(deriveFamilies(slots._families.families), null, 2) + "\n");
```

Same for `gen-style-tokens.mjs` (call `deriveTypescale`/`deriveShapeCorners`/…).
The parity tests guarantee this delegation is byte-identical, so it can land
without touching a single rendered page. **Deliberately NOT done in this skeleton**
— it would couple the (gate-green) Phase-1 generators to a not-yet-integrated
package; adopt it when docs-gen is wired into the workspace.

## 5. What is NOT built (the honest gap — the bulk of a real docs-gen)

1. **The route-generation layer.** The biggest piece. Today the per-component
   reference pages, token galleries, and family page are rendered by *brand-specific
   Elm* (`app/Route/Components/Name_.elm`, `app/Route/Styles/*`, `app/Route/Family.elm`).
   A truly brand-agnostic docs-gen would emit these routes (or a themeable
   elm-pages layer that reads only the facts bundle + config). That is real new
   Elm-codegen work, not a data transform — the analogue of what
   `Generate/Phantom/Emit/*` does for components.
2. **Reference extraction + examples.** `extract-reference.mjs` (elm make --docs)
   and the 1,962-line `examples-gen/` are agnostic in mechanism but not yet lifted
   here. They are the next data-derivations to move in (before the route layer).
3. **install-facts / search-index / roundtrip** derivations — smaller, also
   liftable.
4. **A facts-bundle-typed input.** Today docs-gen takes raw config objects. The
   compose-style target is to take `Dict String Fact` (from `elm-cem-facts`) as the
   single normalized input, with config as a thin overlay — so every brand feeds
   docs-gen the same shape.
5. **Workspace + gate integration** (remove the `pnpm-workspace.yaml` exclusion;
   add copy-fidelity/coverage entries if it becomes a mirrored package).
6. **A brand actually consuming it** (§4) — the real proof, deferred with #1.

## 6. Why this is a credible skeleton and not vapor

The two hardest-to-fake claims of a "brand-agnostic core" are (a) that the core is
genuinely separable from the brand, and (b) that it reproduces the brand's real
output. Both are demonstrated: the extracted functions are pure (no fs, no m3e
knowledge beyond passed-in taxonomy), and the parity tests prove they reproduce the
committed `families.json` / `style-tokens.json` byte-for-byte. The gap in §5 is
scope, not soundness — the seam is real; the surface it covers is small.
