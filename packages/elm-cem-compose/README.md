# jackhp95/elm-cem-compose

A headless, type-directed editor for building a valid tree of custom elements
from a machine-readable component manifest ([`jackhp95/elm-cem-facts`](../elm-cem/facts)).

## Dependencies

- `elm/core`
- `elm-community/list-extra`
- `jackhp95/elm-cem-facts`

## Why no `elm/html`

This package owns Fact-derived state, path-addressed edit logic, and pure
query functions — it renders nothing. Keeping rendering out of the package
means the consumer controls every pixel: any host application, embedding, or
future renderer can drive the same `Model` and `Msg` without this package
dictating markup, styling, or DOM structure. Adding `elm/html` would couple a
headless data model to one particular rendering choice.
