module Sl.Build.Avatar exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withImage, withInitials, withLabel, withLoading, withOnError, withShape, withSlot, withStyle)

{-| The **Avatar** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.Avatar`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withClass, withId, withImage, withInitials, withLabel, withLoading, withOnError, withShape, withSlot, withStyle

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.Avatar as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.AvatarIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.AvatarBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.AvatarAttrCaps


{-| -}
type alias SlotCaps =
    Component.AvatarSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.AvatarChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-avatar" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.AvatarIs kind) admittedBy msg
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
withImage : String -> Builder { a | image : Available } slotCaps msg kind -> Builder { a | image : Used } slotCaps msg kind
withImage value_ =
    B.withAttribute (A.image value_)


{-| -}
withInitials : String -> Builder { a | initials : Available } slotCaps msg kind -> Builder { a | initials : Used } slotCaps msg kind
withInitials value_ =
    B.withAttribute (A.initials value_)


{-| -}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)


{-| -}
withLoading : Value Component.AvatarLoading -> Builder { a | loading : Available } slotCaps msg kind -> Builder { a | loading : Used } slotCaps msg kind
withLoading value_ =
    B.withAttribute (Component.avatarLoading value_)


{-| -}
withShape : Value Component.AvatarShape -> Builder { a | shape : Available } slotCaps msg kind -> Builder { a | shape : Used } slotCaps msg kind
withShape value_ =
    B.withAttribute (Component.avatarShape value_)


{-| -}
withOnError : msg -> Builder { a | onError : Available } slotCaps msg kind -> Builder { a | onError : Used } slotCaps msg kind
withOnError value_ =
    B.withAttribute (Ev.onError value_)
