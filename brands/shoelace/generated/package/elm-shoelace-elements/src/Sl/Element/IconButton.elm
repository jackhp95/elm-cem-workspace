module Sl.Element.IconButton exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Target, target
    , disabled, download, href, label, library, name, src, onBlur, onFocus
    )

{-| The `sl-icon-button` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Target, target
@docs disabled, download, href, label, library, name, src, onBlur, onFocus

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.IconButton
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-icon-button` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.IconButton.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.IconButton.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.IconButton.ChildAdmittedBy childAdm


{-| The `target` values valid on this component (compile-tight narrowing).
-}
type alias Target =
    Sl.Internal.Types.IconButton.Target


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.IconButton.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.IconButton.AttrCaps


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
    H.iconButton


{-| Tells the browser where to open the link. Only used when `href` is set.
-}
target : Value Target -> Attr { c | target : Supported } msg
target value_ =
    Ir.attribute "target" (Val.toString value_)


{-| See `Sl.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Sl.Attributes.download`.
-}
download : String -> Attr { c | download : Supported } msg
download =
    A.download


{-| See `Sl.Attributes.href`.
-}
href : String -> Attr { c | href : Supported } msg
href =
    A.href


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


{-| See `Sl.Events.onBlur`.
-}
onBlur : msg -> Attr { c | onBlur : Supported } msg
onBlur =
    Ev.onBlur


{-| See `Sl.Events.onFocus`.
-}
onFocus : msg -> Attr { c | onFocus : Supported } msg
onFocus =
    Ev.onFocus
