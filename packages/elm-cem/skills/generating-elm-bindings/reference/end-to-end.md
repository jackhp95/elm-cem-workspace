# End-to-end worked example (Shoelace)

A complete, copy-pasteable run, adapted from the elm-cem README's end-to-end recipe.
Shoelace is used only because it ships a manifest and uses a neutral `sl-*` prefix —
any library with a `custom-elements.json` works identically.

## 1. Get a `custom-elements.json`

Shoelace publishes one inside its npm package:

```bash
npm install --save-dev @shoelace-style/shoelace
# -> node_modules/@shoelace-style/shoelace/dist/custom-elements.json
```

If a library ships **no** manifest, produce one upstream with
`@custom-elements-manifest/analyzer` (see `cem-configs/` for ready-made analyzer
configs for Carbon / Ionic / Spectrum), then point `--flags-from` at the produced file.

## 2. Generate

```bash
npx elm-cem \
  --flags-from=node_modules/@shoelace-style/shoelace/dist/custom-elements.json \
  --output=src/Generated
```

Equivalent invocations: `node node_modules/.bin/elm-cem …` or the raw
`node node_modules/elm-cem/bin/elm-cem.js …`.

## 3. What `--output` produces

Modules land under the library's own top-level namespace (`Sl` for `sl-*`):

```
src/Generated/
├── Sl.elm                 -- one-import barrel: every component + shared vocabulary
├── Sl/
│   ├── Button.elm         -- top layer: strict, phantom-typed view + setters
│   ├── Dialog.elm
│   ├── Token.elm          -- the enum token vocabulary (primary, large, …)
│   ├── Html/
│   │   ├── Button.elm     -- Html layer: typed attrs, plain Html children
│   │   └── Shared.elm     -- shared, component-agnostic Html vocabulary
│   └── Raw/
│       └── Button.elm     -- raw layer: the plain elm/html builder, no phantoms
```

The interior `Html` / `Raw` segments are the two lower layers you drop to; the strict
everyday API is the un-prefixed `Sl.<Component>`. Both segments are configurable via the
`_htmlNamespace` / `_rawNamespace` config keys (defaults `"Html"` / `"Raw"`).

## 4. Use it

```elm
import Sl.Button as Button

view =
    Button.view [ Button.variant Button.primary ] [ text "Go" ]
```

## 5. Validate

```bash
elm make src/Generated/Sl.elm --output=/dev/null
```

If the output lives in an Elm **package** (from elm-cem-template), also run the publish
gate, which is stricter (demands an annotation + `@docs` entry on every exposed value):

```bash
elm make --docs docs.json
```

## 6. Wire regeneration + commit

```jsonc
// package.json
{ "scripts": { "gen": "elm-cem --flags-from=node_modules/@shoelace-style/shoelace/dist/custom-elements.json --output=src/Generated" } }
```

```bash
npm run gen              # after upgrading @shoelace-style/shoelace
git add src/Generated    # review the diff, then commit the regenerated tree
```
