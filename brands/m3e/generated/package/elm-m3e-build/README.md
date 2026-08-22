# jackhp95/elm-m3e-build

Composed phantom builder API (M3e.Build.*) for M3e.

This package is a standalone sub-package of [elm-m3e](https://github.com/jackhp95/elm-m3e).
It is a **purely additive** re-organization: each module here is a **flat**
family module that re-exports the member elements of one family from the flat
`M3e.Element.*` surface — element-named constructors (`M3e.Component.Chip.assist`
delegates to `M3e.Element.AssistChip.component`) plus element-prefixed types
(`AssistIs`, `AssistAttrs`) and element-prefixed helpers (`assistVariant`) —
so nothing built against the flat surface regresses. Depends on
`jackhp95/elm-m3e-components` — it adds no logic of its own.

**Generated file.** Do not edit `src/` by hand — run `npm run gen:src` in the
elm-m3e repo to regenerate from the `_families` config (`config/slots.json`).

## Usage

```elm
import M3e.Component.Chip as Chip

Chip.set [] [ Chip.child (Chip.assist [] [ Chip.assistChild ... ]) ]
```

## License

BSD-3-Clause — see [LICENSE](LICENSE).
