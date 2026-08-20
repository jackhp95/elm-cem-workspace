module Cem.Internal.BarrelMapping exposing
    ( attrToBarrel, attrToPerComponent
    , slotToBarrel, slotToPerComponent
    )

{-| Bidirectional attr/slot name lookups between a component's per-component
facet (`<root>.<Comp>.<perCompName>`) and its flat barrel facet
(`<root>.<barrelName>`), both read off the same `Fact.attrRewrites` /
`Fact.slotRewrites` / `Fact.slotUpgrades` pairs.

`Cem.PreferBarrel` (per-component → barrel) and `Cem.PreferComponentModules`
(barrel → per-component) are exact inverses of each other, and were each
independently indexing these same pairs — `PreferBarrel` via named functions,
`PreferComponentModules` via an inline `List.filter` at each of its two call
sites. Consolidated here so both directions are defined once, next to each
other, instead of drifting apart. This was the site the two rules' own doc
comments flagged as a documented past bug source: whichever rule reads a
fact's NAMESPACE (`Cem.Internal.Facts.factNamespace`, one level too deep in
the four-package shape) where it means the fact's BARREL ROOT
(`Cem.Internal.Facts.barrelRoot`) silently goes inert instead of erroring —
this module only resolves the attr/slot NAME mapping, not the namespace, so
it can't itself repeat that mistake; each rule still owns its own
namespace/barrel-root choice at the call site.

@docs attrToBarrel, attrToPerComponent
@docs slotToBarrel, slotToPerComponent

-}

import Cem.Facts exposing (Fact)


{-| `attrRewrites` maps barrel name → per-component name; read it right-to-left
to go per-component → barrel.

IDENTITY entries (barrel name == per-component name) are skipped. The barrel's
disambiguation scheme RENAMES every interchangeable setter (a scalar
`disabled` becomes `attrDisabled`), so a setter the barrel kept under its own
name is NOT the same function — it is a generic re-export with a different
signature (events: the per-component `onClick : msg -> …` convenience vs the
barrel `onClick : Decoder msg -> …`). Rewriting those changes the required
argument type and breaks compilation, so they must stay on the per-component
facet.

-}
attrToBarrel : Fact -> String -> Maybe String
attrToBarrel fact perComponentName =
    fact.attrRewrites
        |> List.filter (\( barrel, perComp ) -> perComp == perComponentName && barrel /= perComp)
        |> List.head
        |> Maybe.map Tuple.first


{-| `attrRewrites` maps barrel name → per-component name directly.
-}
attrToPerComponent : Fact -> String -> Maybe String
attrToPerComponent fact barrelName =
    fact.attrRewrites
        |> List.filter (\( barrel, _ ) -> barrel == barrelName)
        |> List.head
        |> Maybe.map Tuple.second


{-| `slotRewrites` (slotName → per-component setter) and `slotUpgrades`
(generic barrel setter → specific barrel setter) are emitted as parallel
lists, so zipping them maps a per-component setter to its generic barrel
form.
-}
slotToBarrel : Fact -> String -> Maybe String
slotToBarrel fact perComponentSetter =
    List.map2 (\( _, perComp ) ( generic, _ ) -> ( perComp, generic ))
        fact.slotRewrites
        fact.slotUpgrades
        |> List.filter (\( perComp, _ ) -> perComp == perComponentSetter)
        |> List.head
        |> Maybe.map Tuple.second


{-| `slotRewrites` maps slot name → per-component setter directly.
-}
slotToPerComponent : Fact -> String -> Maybe String
slotToPerComponent fact slotName =
    fact.slotRewrites
        |> List.filter (\( k, _ ) -> k == slotName)
        |> List.head
        |> Maybe.map Tuple.second
