module Sl.Build.IconButton exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDisabled, withDownload, withHref, withId, withLabel, withLibrary, withName, withOnBlur, withOnFocus, withSlot, withSrc, withStyle, withTarget)

{-| The **IconButton** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.IconButton`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withDisabled, withDownload, withHref, withId, withLabel, withLibrary, withName, withOnBlur, withOnFocus, withSlot, withSrc, withStyle, withTarget

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.IconButton as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.IconButtonIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.IconButtonBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.IconButtonAttrCaps


{-| -}
type alias SlotCaps =
    Component.IconButtonSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.IconButtonChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-icon-button" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.IconButtonIs kind) admittedBy msg
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
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withDownload : String -> Builder { a | download : Available } slotCaps msg kind -> Builder { a | download : Used } slotCaps msg kind
withDownload value_ =
    B.withAttribute (A.download value_)


{-| -}
withHref : String -> Builder { a | href : Available } slotCaps msg kind -> Builder { a | href : Used } slotCaps msg kind
withHref value_ =
    B.withAttribute (A.href value_)


{-| -}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)


{-| -}
withLibrary : String -> Builder { a | library : Available } slotCaps msg kind -> Builder { a | library : Used } slotCaps msg kind
withLibrary value_ =
    B.withAttribute (A.library value_)


{-| -}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (A.name value_)


{-| -}
withSrc : String -> Builder { a | src : Available } slotCaps msg kind -> Builder { a | src : Used } slotCaps msg kind
withSrc value_ =
    B.withAttribute (A.src value_)


{-| -}
withTarget : Value Component.IconButtonTarget -> Builder { a | target : Available } slotCaps msg kind -> Builder { a | target : Used } slotCaps msg kind
withTarget value_ =
    B.withAttribute (Component.iconButtonTarget value_)


{-| -}
withOnBlur : msg -> Builder { a | onBlur : Available } slotCaps msg kind -> Builder { a | onBlur : Used } slotCaps msg kind
withOnBlur value_ =
    B.withAttribute (Ev.onBlur value_)


{-| -}
withOnFocus : msg -> Builder { a | onFocus : Available } slotCaps msg kind -> Builder { a | onFocus : Used } slotCaps msg kind
withOnFocus value_ =
    B.withAttribute (Ev.onFocus value_)
