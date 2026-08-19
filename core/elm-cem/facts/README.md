# jackhp95/elm-cem-facts

Zero-dependency Elm package exposing the `Cem.Facts` module — the `Fact` and
`Facet` types that form the contract between:

- **elm-cem-generated libraries**, whose unexposed-then-exposed
  `<Brand>.Review.Facts` module emits `facts : List Fact`, and
- **[jackhp95/elm-review-cem](https://github.com/jackhp95/elm-review-cem)**,
  whose codegen-aware rules consume that `List Fact`.

Because this package has NO `elm-review` dependency, a generated
`<Brand>.Review.Facts` module can import `Cem.Facts` without dragging review
machinery (jfmengels/elm-review, stil4m/elm-syntax) into every UI consumer's
dependency closure. The review tooling only enters in the consuming project's
review config.

## Source of truth

The canonical source lives in the [elm-cem](https://github.com/jackhp95/elm-cem)
repository under `facts/` — elm-cem is the emitter that defines the facts
contract. This repository is a **publish mirror**: do not edit here, do not PR
here. Issues and source live in `jackhp95/elm-cem`.

## Install

```
elm install jackhp95/elm-cem-facts
```
