module Or.Build exposing
    ( Builder
    , toElement
    , PlainIs, WidgetIs
    )

{-| The shared builder surface for the `Or` brand: the opaque `Builder`
and the single `toElement` that closes any component's builder. Per-component
modules provide the seeds (`build`) and the narrowed `withX` setters; they all
share this one representation, so `toElement` is defined once (in
`Or.Forge.Internal`) and re-exported here.

The `Is` aliases (`ButtonIs`, `CardIs`, …) let you annotate a phantom-kind
type without importing the component or its builder module.

@docs Builder
@docs toElement
@docs PlainIs, WidgetIs

-}

import HtmlIr.Element exposing (Element)
import Or.Build.Plain
import Or.Build.Widget
import Or.Forge.Internal as Internal


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


{-| The `Plain` kind phantom — annotate with `List (Element (PlainIs s) admittedBy msg)`.
-}
type alias PlainIs s =
    Or.Build.Plain.Is s


{-| The `Widget` kind phantom — annotate with `List (Element (WidgetIs s) admittedBy msg)`.
-}
type alias WidgetIs s =
    Or.Build.Widget.Is s
