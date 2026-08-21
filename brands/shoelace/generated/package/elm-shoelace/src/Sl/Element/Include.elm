module Sl.Element.Include exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Mode, mode
    , allowScripts, src, onLoad, onError
    )

{-| The `sl-include` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Mode, mode
@docs allowScripts, src, onLoad, onError

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Include
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-include` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Include.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Include.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Include.ChildAdmittedBy childAdm


{-| The `mode` values valid on this component (compile-tight narrowing).
-}
type alias Mode =
    Sl.Internal.Types.Include.Mode


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Include.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Include.AttrCaps


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
    H.include


{-| The fetch mode to use. (default: `'cors'`)
-}
mode : Value Mode -> Attr { c | mode : Supported } msg
mode value_ =
    Ir.attribute "mode" (Val.toString value_)


{-| See `Sl.Attributes.allowScripts`.
-}
allowScripts : Bool -> Attr { c | allowScripts : Supported } msg
allowScripts =
    A.allowScripts


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
