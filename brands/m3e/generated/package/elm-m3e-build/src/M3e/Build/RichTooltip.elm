module M3e.Build.RichTooltip exposing (RichTooltipBuilder, RichTooltipAttrCaps, RichTooltipSlotCaps, RichTooltipIs, RichTooltipContent, RichTooltipSubheadSlot, RichTooltipChildAdmittedBy, richTooltipBuild, richTooltipToElement, richTooltipWithClass, richTooltipWithDisabled, richTooltipWithFor, richTooltipWithHideDelay, richTooltipWithId, richTooltipWithOnBeforetoggle, richTooltipWithOnToggle, richTooltipWithPosition, richTooltipWithShowDelay, richTooltipWithSlot, richTooltipWithStyle, richTooltipWithTouchGestures, richTooltipActions, richTooltipSubhead, richTooltipWithActions, richTooltipWithSubhead, richTooltipWithChild, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionIs, ActionContent, ActionChildAdmittedBy, actionBuild, actionToElement, actionWithClass, actionWithDisableRestoreFocus, actionWithId, actionWithSlot, actionWithStyle, actionWithChild)

{-| The **RichTooltip** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.RichTooltip`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs RichTooltipBuilder, RichTooltipAttrCaps, RichTooltipSlotCaps, RichTooltipIs, RichTooltipContent, RichTooltipSubheadSlot, RichTooltipChildAdmittedBy, richTooltipBuild, richTooltipToElement, richTooltipWithClass, richTooltipWithDisabled, richTooltipWithFor, richTooltipWithHideDelay, richTooltipWithId, richTooltipWithOnBeforetoggle, richTooltipWithOnToggle, richTooltipWithPosition, richTooltipWithShowDelay, richTooltipWithSlot, richTooltipWithStyle, richTooltipWithTouchGestures, richTooltipActions, richTooltipSubhead, richTooltipWithActions, richTooltipWithSubhead, richTooltipWithChild, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionIs, ActionContent, ActionChildAdmittedBy, actionBuild, actionToElement, actionWithClass, actionWithDisableRestoreFocus, actionWithId, actionWithSlot, actionWithStyle, actionWithChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.RichTooltip as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias RichTooltipIs s =
    Component.RichTooltipIs s


{-| -}
type alias RichTooltipBuilder attrCaps slotCaps msg kind =
    Component.RichTooltipBuilder attrCaps slotCaps msg kind


{-| -}
type alias RichTooltipAttrCaps =
    Component.RichTooltipAttrCaps


{-| -}
type alias RichTooltipSlotCaps =
    Component.RichTooltipSlotCaps


{-| -}
type alias RichTooltipChildAdmittedBy childAdm =
    Component.RichTooltipChildAdmittedBy childAdm


{-| -}
type alias RichTooltipContent =
    Component.RichTooltipContent


{-| -}
type alias RichTooltipSubheadSlot =
    Component.RichTooltipSubheadSlot


{-| -}
richTooltipBuild :
    { content : Element Component.RichTooltipContent (Component.RichTooltipChildAdmittedBy childAdm) msg }
    -> RichTooltipBuilder RichTooltipAttrCaps RichTooltipSlotCaps msg kind
richTooltipBuild required_ =
    B.init "m3e-rich-tooltip" [] [ El.toNode required_.content ]


{-| -}
richTooltipToElement : RichTooltipBuilder attrCaps slotCaps msg kind -> Element (Component.RichTooltipIs kind) admittedBy msg
richTooltipToElement =
    B.toElement


{-| -}
richTooltipActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
richTooltipActions builder =
    Component.richTooltipActions (B.toElement builder)


{-| -}
richTooltipSubhead :
    B.Builder childRow childAttrCaps childSlotCaps Component.RichTooltipSubheadSlot msg
    -> Element free freeAdmittedBy msg
richTooltipSubhead builder =
    Component.richTooltipSubhead (B.toElement builder)


{-| -}
richTooltipWithActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> RichTooltipBuilder attrCaps { s | actions : Available } msg kind
    -> RichTooltipBuilder attrCaps { s | actions : Used } msg kind
richTooltipWithActions slotBuilder builder_ =
    B.withChild (El.toNode (Component.richTooltipActions (B.toElement slotBuilder))) builder_


{-| -}
richTooltipWithSubhead :
    B.Builder childRow childAttrCaps childSlotCaps Component.RichTooltipSubheadSlot msg
    -> RichTooltipBuilder attrCaps { s | subhead : Available } msg kind
    -> RichTooltipBuilder attrCaps { s | subhead : Used } msg kind
richTooltipWithSubhead slotBuilder builder_ =
    B.withChild (El.toNode (Component.richTooltipSubhead (B.toElement slotBuilder))) builder_


{-| -}
richTooltipWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> RichTooltipBuilder attrCaps slotCaps msg kind
    -> RichTooltipBuilder attrCaps slotCaps msg kind
richTooltipWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
richTooltipWithClass : String -> RichTooltipBuilder { a | class : Available } slotCaps msg kind -> RichTooltipBuilder { a | class : Used } slotCaps msg kind
richTooltipWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
richTooltipWithId : String -> RichTooltipBuilder { a | id : Available } slotCaps msg kind -> RichTooltipBuilder { a | id : Used } slotCaps msg kind
richTooltipWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
richTooltipWithSlot : String -> RichTooltipBuilder { a | slot : Available } slotCaps msg kind -> RichTooltipBuilder { a | slot : Used } slotCaps msg kind
richTooltipWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
richTooltipWithStyle : String -> String -> RichTooltipBuilder { a | style : Available } slotCaps msg kind -> RichTooltipBuilder { a | style : Used } slotCaps msg kind
richTooltipWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
richTooltipWithDisabled : Bool -> RichTooltipBuilder { a | disabled : Available } slotCaps msg kind -> RichTooltipBuilder { a | disabled : Used } slotCaps msg kind
richTooltipWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
richTooltipWithFor : String -> RichTooltipBuilder { a | for : Available } slotCaps msg kind -> RichTooltipBuilder { a | for : Used } slotCaps msg kind
richTooltipWithFor value_ =
    B.withAttribute (A.for value_)


{-| -}
richTooltipWithHideDelay : Float -> RichTooltipBuilder { a | hideDelay : Available } slotCaps msg kind -> RichTooltipBuilder { a | hideDelay : Used } slotCaps msg kind
richTooltipWithHideDelay value_ =
    B.withAttribute (A.hideDelay value_)


{-| -}
richTooltipWithPosition : Value Component.RichTooltipPosition -> RichTooltipBuilder { a | position : Available } slotCaps msg kind -> RichTooltipBuilder { a | position : Used } slotCaps msg kind
richTooltipWithPosition value_ =
    B.withAttribute (Component.richTooltipPosition value_)


{-| -}
richTooltipWithShowDelay : Float -> RichTooltipBuilder { a | showDelay : Available } slotCaps msg kind -> RichTooltipBuilder { a | showDelay : Used } slotCaps msg kind
richTooltipWithShowDelay value_ =
    B.withAttribute (A.showDelay value_)


{-| -}
richTooltipWithTouchGestures : Value Component.RichTooltipTouchGestures -> RichTooltipBuilder { a | touchGestures : Available } slotCaps msg kind -> RichTooltipBuilder { a | touchGestures : Used } slotCaps msg kind
richTooltipWithTouchGestures value_ =
    B.withAttribute (Component.richTooltipTouchGestures value_)


{-| -}
richTooltipWithOnBeforetoggle : msg -> RichTooltipBuilder { a | onBeforetoggle : Available } slotCaps msg kind -> RichTooltipBuilder { a | onBeforetoggle : Used } slotCaps msg kind
richTooltipWithOnBeforetoggle value_ =
    B.withAttribute (Ev.onBeforetoggle value_)


{-| -}
richTooltipWithOnToggle : msg -> RichTooltipBuilder { a | onToggle : Available } slotCaps msg kind -> RichTooltipBuilder { a | onToggle : Used } slotCaps msg kind
richTooltipWithOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)


{-| -}
type alias ActionIs s =
    Component.ActionIs s


{-| -}
type alias ActionBuilder attrCaps slotCaps msg kind =
    Component.ActionBuilder attrCaps slotCaps msg kind


{-| -}
type alias ActionAttrCaps =
    Component.ActionAttrCaps


{-| -}
type alias ActionSlotCaps =
    Component.ActionSlotCaps


{-| -}
type alias ActionChildAdmittedBy childAdm =
    Component.ActionChildAdmittedBy childAdm


{-| -}
type alias ActionContent =
    Component.ActionContent


{-| -}
actionBuild :
    { content : Element Component.ActionContent (Component.ActionChildAdmittedBy childAdm) msg }
    -> ActionBuilder ActionAttrCaps ActionSlotCaps msg kind
actionBuild required_ =
    B.init "m3e-rich-tooltip-action" [] [ El.toNode required_.content ]


{-| -}
actionToElement : ActionBuilder attrCaps slotCaps msg kind -> Element (Component.ActionIs kind) admittedBy msg
actionToElement =
    B.toElement


{-| -}
actionWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> ActionBuilder attrCaps slotCaps msg kind
    -> ActionBuilder attrCaps slotCaps msg kind
actionWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
actionWithClass : String -> ActionBuilder { a | class : Available } slotCaps msg kind -> ActionBuilder { a | class : Used } slotCaps msg kind
actionWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
actionWithId : String -> ActionBuilder { a | id : Available } slotCaps msg kind -> ActionBuilder { a | id : Used } slotCaps msg kind
actionWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
actionWithSlot : String -> ActionBuilder { a | slot : Available } slotCaps msg kind -> ActionBuilder { a | slot : Used } slotCaps msg kind
actionWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
actionWithStyle : String -> String -> ActionBuilder { a | style : Available } slotCaps msg kind -> ActionBuilder { a | style : Used } slotCaps msg kind
actionWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
actionWithDisableRestoreFocus : Bool -> ActionBuilder { a | disableRestoreFocus : Available } slotCaps msg kind -> ActionBuilder { a | disableRestoreFocus : Used } slotCaps msg kind
actionWithDisableRestoreFocus value_ =
    B.withAttribute (A.disableRestoreFocus value_)
