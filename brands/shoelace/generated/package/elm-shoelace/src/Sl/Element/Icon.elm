module Sl.Element.Icon exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , label, library, name, src, onLoad, onError
    )

{-| The `sl-icon` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs label, library, name, src, onLoad, onError

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Icon
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-icon` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Icon.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Icon.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Icon.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Icon.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Icon.AttrCaps


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
    H.icon


{-| See `Sl.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


{-| See `Sl.Attributes.library`.
-}
library : String -> Attr { c | library : Supported } msg
library =
    A.library


{-| See `Sl.Attributes.name`.
-}
name : String -> Attr { c | name : Supported } msg
name =
    A.name


{-| See `Sl.Attributes.src`.
-}
src : String -> Attr { c | src : Supported } msg
src =
    A.src


{-| See `Sl.Events.onLoad`.
-}
onLoad : msg -> Attr { c | onLoad : Supported } msg
onLoad =
    Ev.onLoad


{-| See `Sl.Events.onError`.
-}
onError : msg -> Attr { c | onError : Supported } msg
onError =
    Ev.onError
