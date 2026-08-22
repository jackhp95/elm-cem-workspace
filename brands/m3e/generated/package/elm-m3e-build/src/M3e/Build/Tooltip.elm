module M3e.Build.Tooltip exposing (Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withDisabled, withFor, withHideDelay, withId, withPosition, withShowDelay, withSlot, withStyle, withTouchGestures, withChild)

{-| The **Tooltip** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.Tooltip`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy, build, toElement, withClass, withDisabled, withFor, withHideDelay, withId, withPosition, withShowDelay, withSlot, withStyle, withTouchGestures, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Tooltip as Component
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.TooltipIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.TooltipBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.TooltipAttrCaps


{-| -}
type alias SlotCaps =
    Component.TooltipSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.TooltipChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.TooltipContent


{-| -}
build :
    { content : Element Component.TooltipContent (Component.TooltipChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-tooltip" [] [ El.toNode required_.content ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.TooltipIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
withChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


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
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| -}
withHideDelay : Float -> Builder { a | hideDelay : Available } slotCaps msg kind -> Builder { a | hideDelay : Used } slotCaps msg kind
withHideDelay value_ =
    B.withAttribute (A.hideDelay value_)


{-| -}
withPosition : Value Component.TooltipPosition -> Builder { a | position : Available } slotCaps msg kind -> Builder { a | position : Used } slotCaps msg kind
withPosition value_ =
    B.withAttribute (Component.tooltipPosition value_)


{-| -}
withShowDelay : Float -> Builder { a | showDelay : Available } slotCaps msg kind -> Builder { a | showDelay : Used } slotCaps msg kind
withShowDelay value_ =
    B.withAttribute (A.showDelay value_)


{-| -}
withTouchGestures : Value Component.TooltipTouchGestures -> Builder { a | touchGestures : Available } slotCaps msg kind -> Builder { a | touchGestures : Used } slotCaps msg kind
withTouchGestures value_ =
    B.withAttribute (Component.tooltipTouchGestures value_)
