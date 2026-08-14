module Br.Build exposing
    ( Builder
    , toElement
    , BarrenIs
    )

{-| The shared builder surface for the `Br` brand: the opaque `Builder`
and the single `toElement` that closes any component's builder. Per-component
modules provide the seeds (`build`) and the narrowed `withX` setters; they all
share this one representation, so `toElement` is defined once (in
`Br.Forge.Internal`) and re-exported here.

The `Is` aliases (`ButtonIs`, `CardIs`, …) let you annotate a phantom-kind
type without importing the component or its builder module.

@docs Builder
@docs toElement
@docs BarrenIs

-}

import Br.Build.Barren
import Br.Forge.Internal as Internal
import HtmlIr.Element exposing (Element)


{-| The shared pipe-builder — see each component's `Builder` alias for its
narrowed, brand-typed form.
-}
type alias Builder row attrCaps slotCaps accepts msg =
    Internal.Builder row attrCaps slotCaps accepts msg


{-| Close any builder into its element.
-}
toElement : Builder row attrCaps slotCaps accepts msg -> Element accepts admittedBy msg
toElement =
    Internal.toElement


{-| The `Barren` kind phantom — annotate with `List (Element (BarrenIs s) admittedBy msg)`.
-}
type alias BarrenIs s =
    Br.Build.Barren.Is s
