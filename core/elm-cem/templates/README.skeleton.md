# {{BRAND}}

Type-safe Elm bindings for this component library, generated from its Custom
Elements Manifest by [elm-cem](https://github.com/jackhp95/elm-cem). The whole
of `src/` is generated — every module, its docs, and `exposed-modules` — so the
library never drifts from the upstream manifest.

## Install

```sh
elm install jackhp95/{{BRAND}}
```

## Usage

The barrel module `{{LIB}}` is the canonical one-import surface:

```elm
import {{LIB}}

view =
    {{LIB}}.button [ {{LIB}}.variant "filled" ] [ {{LIB}}.text "Save" ]
```

Per-component modules (`{{LIB}}.Button`, …) expose the same setters namespaced;
`elm-review` (see `review/`) migrates between the two forms with `--fix`.

## Development

This repo carries only **config**; all tooling lives in elm-cem and is invoked
through `ELM_CEM_BIN` (defaults to a sibling `../elm-cem` checkout).

```sh
npm ci                # install deps + elm toolchain
npm run gen           # regenerate src/ from the manifest + config/
npm run gate          # regen-drift + registry-check + acid
npm run validate      # docs-size gate (<= 700 KB)
npm run review        # elm-review (facts-driven Cem.* rules)
```

CI (`.github/workflows/ci.yml`) runs format · review · gate · validate on every
push and PR. Both the CI workflow and `review/src/ReviewConfig.elm` are generated
by `elm-cem brand-sync` and are identical across brands modulo the `{{LIB}}`
token — do not hand-edit them; edit the elm-cem templates and re-sync.

## License

BSD-3-Clause
