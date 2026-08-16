module Cem.Facts exposing (Fact, Facet(..))

{-| The data types the codegen-aware rules consume.

A code generator (e.g. `elm-cem`) emits a `facts : List Fact` value in an
unexposed module of the generated library and imports these types from here.
Because this module has NO `elm-review` dependency, that generated facts module
stays free of any `elm-review` import — the review tooling only enters the
picture in the consuming project's review config, which passes the `facts` into
each rule.

@docs Fact, Facet

-}


{-| The five facets (addressable points) — the raw and Html layers plus the top
layer's three forms — of a generated component library.

`Raw` = the raw-HTML bottom module; `Html` = the Html-typed middle module;
`Standard` = the double-list top module; `Record` = the record + double-list
top module; `Build` = the phantom-typed pipeline module.

-}
type Facet
    = Raw
    | Html
    | Standard
    | Record
    | Build


{-| Per-component facts: valid enum token names per attribute, the
required/multi slot names, which facets the component emits at, which HTML
attributes are required, and the barrel/per-component name maps the rules use to
translate between facets.

  - `component` — the camelCase component noun (e.g. `"button"`).
  - `module_` — the component's Standard (top) module, fully qualified (e.g.
    `"Lib.Button"`). The rules derive the library's root namespace from this, so
    nothing hardcodes a namespace.
  - `enums` — attribute setter name → the value tokens it accepts.
  - `requiredSlots` / `multiSlots` — slot names by kind.
  - `attrRewrites` — barrel setter name → per-component setter name.
  - `slotRewrites` — raw slot name → per-component content-setter name.
  - `slotKinds` — raw slot name → the child-kind (component noun) strings the slot
    accepts. Drives `Cem.ValidSlotKind`; an empty/absent entry means "unconstrained".
  - `slotUpgrades` — generic barrel slot setter → component-specific one.
  - `groupConstructors` — for a VARIANT-GROUP module (e.g. `<Brand>.Progress`, whose
    members are `circular`/`linear`), the group's member constructor names. Each
    is re-exposed flat under the barrel by its own name (identity: `circular` →
    `circular`), so `Cem.PreferBarrel` rewrites `<root>.<Group>.circular` →
    `<root>.circular`. Empty for an ordinary component (its sole constructor is
    the component's own lowercased name, handled separately).
  - `facets` — the facets this component emits at.
  - `requiredAttrs` — HTML attribute names the component requires.
  - `actionMap` — action attribute name → its action constructor name.
  - `usesAction` — whether the component's record shape carries an `action` field.

-}
type alias Fact =
    { component : String
    , module_ : String
    , enums : List ( String, List String )
    , requiredSlots : List String
    , multiSlots : List String
    , attrRewrites : List ( String, String )
    , slotRewrites : List ( String, String )
    , slotKinds : List ( String, List String )
    , slotUpgrades : List ( String, String )
    , groupConstructors : List String
    , facets : List Facet
    , requiredAttrs : List String
    , actionMap : List ( String, String )
    , usesAction : Bool
    }
