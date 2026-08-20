# jackhp95/elm-m3e-families

Family-grouped nested module organization for elm-m3e components.

This package is a standalone sub-package of [elm-m3e](https://github.com/jackhp95/elm-m3e).
It is a **purely additive** re-organization: each module here is a **flat**
family module that re-exports the member elements of one family from the flat
`M3e.Component.*` surface — element-named constructors (`M3e.Family.Chip.assist`
delegates to `M3e.Component.AssistChip.component`) plus element-prefixed types
(`AssistIs`, `AssistAttrs`) and element-prefixed helpers (`assistVariant`) —
so nothing built against the flat surface regresses. Depends on
`jackhp95/elm-m3e-components` — it adds no logic of its own.

**Generated file.** Do not edit `src/` by hand — run `npm run gen:src` in the
elm-m3e repo to regenerate from the `_families` config (`config/slots.json`).

## Usage

```elm
import M3e.Family.Chip as Chip

Chip.set [] [ Chip.child (Chip.assist [] [ Chip.assistChild ... ]) ]
```

## License

BSD-3-Clause — see [LICENSE](LICENSE).
