module M3e.Component.SelectionIndicator exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , bounce, centered, disabled, for, selected, defaultSelected
    )

{-| The `m3e-selection-indicator` component — strict per-component surface.

Provides selection, focus, and hover state layer treatment for an interactive element that supports selection.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs bounce, centered, disabled, for, selected, defaultSelected

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.SelectionIndicator
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-selection-indicator` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.SelectionIndicator.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.SelectionIndicator.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SelectionIndicator.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.SelectionIndicator.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.SelectionIndicator.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.selectionIndicator


{-| See `M3e.Attributes.bounce`.
-}
bounce : Bool -> Attr { c | bounce : Supported } msg
bounce =
    A.bounce


{-| See `M3e.Attributes.centered`.
-}
centered : Bool -> Attr { c | centered : Supported } msg
centered =
    A.centered


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.for`.
-}
for : String -> Attr { c | for : Supported } msg
for =
    A.for


{-| See `M3e.Attributes.selected`.
-}
selected : Bool -> Attr { c | selected : Supported } msg
selected =
    A.selected


{-| See `M3e.Attributes.defaultSelected`.
-}
defaultSelected : Bool -> Attr { c | selected : Supported } msg
defaultSelected =
    A.defaultSelected
