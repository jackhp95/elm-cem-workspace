module Sl.Component.Tab exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , active, closable, disabled, panel, onClose
    )

{-| The `sl-tab` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs active, closable, disabled, panel, onClose

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Tab
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-tab` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Tab.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Tab.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Tab.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Tab.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Tab.AttrCaps


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
    H.tab


{-| See `Sl.Attributes.active`.
-}
active : Bool -> Attr { c | active : Supported } msg
active =
    A.active


{-| See `Sl.Attributes.closable`.
-}
closable : Bool -> Attr { c | closable : Supported } msg
closable =
    A.closable


{-| See `Sl.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Sl.Attributes.panel`.
-}
panel : String -> Attr { c | panel : Supported } msg
panel =
    A.panel


{-| See `Sl.Events.onClose`.
-}
onClose : msg -> Attr { c | onClose : Supported } msg
onClose =
    Ev.onClose
