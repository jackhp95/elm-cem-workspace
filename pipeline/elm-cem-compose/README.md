# jackhp95/elm-cem-compose

A headless, type-directed editor for building a valid tree of custom elements
from a machine-readable component manifest ([`jackhp95/elm-cem-facts`](../elm-cem-facts)).

## Dependencies

- `elm/core`
- `elm-community/list-extra`
- `jackhp95/elm-cem-facts`

Nothing else. `elm-community/list-extra` supplies the indexed list operations
(`getAt`, `setAt`, `removeAt`, `unique`) the path-addressed edit logic needs;
`jackhp95/elm-cem-facts` supplies the `Fact`/`Facet` types this package's
queries are built against. There is no fourth dependency because there is
nothing else this package needs to do its job: it holds a tree, applies
messages to it, and answers pure queries about it.

## Why no `elm/html`

This package owns Fact-derived state, path-addressed edit logic, and pure
query functions — it renders nothing. Keeping rendering out of the package
means the consumer controls every pixel: any host application, embedding, or
future renderer can drive the same `Model` and `Msg` without this package
dictating markup, styling, or DOM structure. Adding `elm/html` would couple a
headless data model to one particular rendering choice.

## Why `Node` is opaque

`Node`'s constructor is not exposed. The slot-cardinality invariant (a
non-multi slot holds at most one child) and the shape of `attrs`/`children` are
maintained entirely by `update`. If a consumer could construct a `Node`
directly, it could build a tree that violates that invariant — a two-element
non-multi slot, for instance — and every downstream query (`slotChips`,
`attrMenuOptions`, codegen) would have to defend against trees this package
itself never produces. Opacity makes "every `Node` in existence came through
`update`" a fact, not a convention.

## Editing a node's component in place

`SetComponent path target` (1.1.0) changes an existing node's component
without rebuilding the tree around it. `componentOptions path model` reports
which components are legal there: at the root, every known fact; nested,
only what the parent slot affords — a nested node may only become something
its parent legally admits in that slot. `SetComponent` to anything outside
`componentOptions` is a no-op, the same menu/update agreement `AddChild`
keeps. On a real swap, content the new component doesn't support is pruned:
attrs it doesn't offer, slots it doesn't declare, and children whose kind
its slots no longer afford — then the slot's cap (multi vs. single) is
re-enforced against the target, not the old component.

## Why the consumer supplies `attrKinds`

Elm has no reflection: nothing in `Cem.Facts.Fact` says whether a given
attribute name is boolean, string, float, or int — `attrRewrites` is just
setter-name pairs, and an enum's shape is already fully described by
`fact.enums`. For every other attribute, only the generated library's own
per-component modules know the real parameter type, and that information does
not exist in a form this package could read from `Fact` alone. So `init` takes
`attrKinds : Dict String AttrKind` from the caller, who has it because it
generated (or knows) those modules; this package never guesses a type it
cannot see.
