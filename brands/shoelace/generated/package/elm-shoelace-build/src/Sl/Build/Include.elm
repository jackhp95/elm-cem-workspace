module Sl.Build.Include exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withAllowScripts, withClass, withId, withMode, withOnError, withOnLoad, withSlot, withSrc, withStyle)

{-| The **Include** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.Include`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withAllowScripts, withClass, withId, withMode, withOnError, withOnLoad, withSlot, withSrc, withStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.Include as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.IncludeIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.IncludeBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.IncludeAttrCaps


{-| -}
type alias SlotCaps =
    Component.IncludeSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.IncludeChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-include" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.IncludeIs kind) admittedBy msg
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
withMode : Value Component.IncludeMode -> Builder { a | mode : Available } slotCaps msg kind -> Builder { a | mode : Used } slotCaps msg kind
withMode value_ =
    B.withAttribute (Component.includeMode value_)


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
