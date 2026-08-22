module M3e.Build.ListAction exposing (Builder, AttrCaps, SlotCaps, Is, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, TrailingSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withDownload, withHref, withId, withOnClick, withRel, withSlot, withStyle, withTarget, leading, overline, supportingText, trailing, withLeading, withOverline, withSupportingText, withTrailing, withChild)

{-| The **ListAction** element — the flat per-element builder surface,
sourced through the **List** family façade
(`M3e.Component.List`). This module and the aggregated
`M3e.Build.List` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, TrailingSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withDownload, withHref, withId, withOnClick, withRel, withSlot, withStyle, withTarget, leading, overline, supportingText, trailing, withLeading, withOverline, withSupportingText, withTrailing, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.List as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.ActionIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.ActionBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.ActionAttrCaps


{-| -}
type alias SlotCaps =
    Component.ActionSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ActionChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.ActionContent


{-| -}
type alias LeadingSlot =
    Component.ActionLeadingSlot


{-| -}
type alias OverlineSlot =
    Component.ActionOverlineSlot


{-| -}
type alias SupportingTextSlot =
    Component.ActionSupportingTextSlot


{-| -}
type alias TrailingSlot =
    Component.ActionTrailingSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-list-action" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ActionIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
leading :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionLeadingSlot msg
    -> Element free freeAdmittedBy msg
leading builder =
    Component.actionLeading (B.toElement builder)


{-| -}
overline :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionOverlineSlot msg
    -> Element free freeAdmittedBy msg
overline builder =
    Component.actionOverline (B.toElement builder)


{-| -}
supportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionSupportingTextSlot msg
    -> Element free freeAdmittedBy msg
supportingText builder =
    Component.actionSupportingText (B.toElement builder)


{-| -}
trailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionTrailingSlot msg
    -> Element free freeAdmittedBy msg
trailing builder =
    Component.actionTrailing (B.toElement builder)


{-| -}
withLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionLeadingSlot msg
    -> Builder attrCaps { s | leading : Available } msg kind
    -> Builder attrCaps { s | leading : Used } msg kind
withLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.actionLeading (B.toElement slotBuilder))) builder_


{-| -}
withOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionOverlineSlot msg
    -> Builder attrCaps { s | overline : Available } msg kind
    -> Builder attrCaps { s | overline : Used } msg kind
withOverline slotBuilder builder_ =
    B.withChild (El.toNode (Component.actionOverline (B.toElement slotBuilder))) builder_


{-| -}
withSupportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionSupportingTextSlot msg
    -> Builder attrCaps { s | supportingText : Available } msg kind
    -> Builder attrCaps { s | supportingText : Used } msg kind
withSupportingText slotBuilder builder_ =
    B.withChild (El.toNode (Component.actionSupportingText (B.toElement slotBuilder))) builder_


{-| -}
withTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionTrailingSlot msg
    -> Builder attrCaps { s | trailing : Available } msg kind
    -> Builder attrCaps { s | trailing : Used } msg kind
withTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.actionTrailing (B.toElement slotBuilder))) builder_


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
withDownload : String -> Builder { a | download : Available } slotCaps msg kind -> Builder { a | download : Used } slotCaps msg kind
withDownload value_ =
    B.withAttribute (A.download value_)


{-| -}
withHref : String -> Builder { a | href : Available } slotCaps msg kind -> Builder { a | href : Used } slotCaps msg kind
withHref value_ =
    B.withAttribute (A.href value_)


{-| -}
withRel : String -> Builder { a | rel : Available } slotCaps msg kind -> Builder { a | rel : Used } slotCaps msg kind
withRel value_ =
    B.withAttribute (A.rel value_)


{-| -}
withTarget : String -> Builder { a | target : Available } slotCaps msg kind -> Builder { a | target : Used } slotCaps msg kind
withTarget value_ =
    B.withAttribute (A.target value_)


{-| -}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
