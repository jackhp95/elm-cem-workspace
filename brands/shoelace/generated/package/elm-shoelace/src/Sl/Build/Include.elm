module Sl.Build.Include exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withAllowScripts, withClass, withId, withMode, withOnError, withOnLoad, withSlot, withSrc, withStyle
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withAllowScripts, withClass, withId, withMode, withOnError, withOnLoad, withSlot, withSrc, withStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Component.Include as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-include" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
withClass : String -> Builder { a | class : Available } slotCaps msg kind -> Builder { a | class : Used } slotCaps msg kind
withClass value_ =
    B.withAttribute (A.class value_)


{-| -}
withId : String -> Builder { a | id : Available } slotCaps msg kind -> Builder { a | id : Used } slotCaps msg kind
withId value_ =
    B.withAttribute (A.id value_)


{-| -}
withSlot : String -> Builder { a | slot : Available } slotCaps msg kind -> Builder { a | slot : Used } slotCaps msg kind
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg kind -> Builder { a | style : Used } slotCaps msg kind
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
withAllowScripts : Bool -> Builder { a | allowScripts : Available } slotCaps msg kind -> Builder { a | allowScripts : Used } slotCaps msg kind
withAllowScripts value_ =
    B.withAttribute (A.allowScripts value_)


{-| -}
withMode : Value Component.Mode -> Builder { a | mode : Available } slotCaps msg kind -> Builder { a | mode : Used } slotCaps msg kind
withMode value_ =
    B.withAttribute (Component.mode value_)


{-| -}
withSrc : String -> Builder { a | src : Available } slotCaps msg kind -> Builder { a | src : Used } slotCaps msg kind
withSrc value_ =
    B.withAttribute (A.src value_)


{-| -}
withOnLoad : msg -> Builder { a | onLoad : Available } slotCaps msg kind -> Builder { a | onLoad : Used } slotCaps msg kind
withOnLoad value_ =
    B.withAttribute (Ev.onLoad value_)


{-| -}
withOnError : msg -> Builder { a | onError : Available } slotCaps msg kind -> Builder { a | onError : Used } slotCaps msg kind
withOnError value_ =
    B.withAttribute (Ev.onError value_)
