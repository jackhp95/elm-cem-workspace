module M3e.Build.ListItemButton exposing (Builder, AttrCaps, SlotCaps, Is, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, TrailingSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withDownload, withHref, withId, withOnClick, withRel, withSlot, withStyle, withTarget, leading, overline, supportingText, trailing, withLeading, withOverline, withSupportingText, withTrailing, withChild)

{-| The **ListItemButton** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.ListItemButton`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, TrailingSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withDownload, withHref, withId, withOnClick, withRel, withSlot, withStyle, withTarget, leading, overline, supportingText, trailing, withLeading, withOverline, withSupportingText, withTrailing, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.ListItemButton as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.ListItemButtonIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.ListItemButtonBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.ListItemButtonAttrCaps


{-| -}
type alias SlotCaps =
    Component.ListItemButtonSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ListItemButtonChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.ListItemButtonContent


{-| -}
type alias LeadingSlot =
    Component.ListItemButtonLeadingSlot


{-| -}
type alias OverlineSlot =
    Component.ListItemButtonOverlineSlot


{-| -}
type alias SupportingTextSlot =
    Component.ListItemButtonSupportingTextSlot


{-| -}
type alias TrailingSlot =
    Component.ListItemButtonTrailingSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-list-item-button" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ListItemButtonIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
leading :
    B.Builder childRow childAttrCaps childSlotCaps Component.ListItemButtonLeadingSlot msg
    -> Element free freeAdmittedBy msg
leading builder =
    Component.listItemButtonLeading (B.toElement builder)


{-| -}
overline :
    B.Builder childRow childAttrCaps childSlotCaps Component.ListItemButtonOverlineSlot msg
    -> Element free freeAdmittedBy msg
overline builder =
    Component.listItemButtonOverline (B.toElement builder)


{-| -}
supportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.ListItemButtonSupportingTextSlot msg
    -> Element free freeAdmittedBy msg
supportingText builder =
    Component.listItemButtonSupportingText (B.toElement builder)


{-| -}
trailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.ListItemButtonTrailingSlot msg
    -> Element free freeAdmittedBy msg
trailing builder =
    Component.listItemButtonTrailing (B.toElement builder)


{-| -}
withLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.ListItemButtonLeadingSlot msg
    -> Builder attrCaps { s | leading : Available } msg kind
    -> Builder attrCaps { s | leading : Used } msg kind
withLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.listItemButtonLeading (B.toElement slotBuilder))) builder_


{-| -}
withOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.ListItemButtonOverlineSlot msg
    -> Builder attrCaps { s | overline : Available } msg kind
    -> Builder attrCaps { s | overline : Used } msg kind
withOverline slotBuilder builder_ =
    B.withChild (El.toNode (Component.listItemButtonOverline (B.toElement slotBuilder))) builder_


{-| -}
withSupportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.ListItemButtonSupportingTextSlot msg
    -> Builder attrCaps { s | supportingText : Available } msg kind
    -> Builder attrCaps { s | supportingText : Used } msg kind
withSupportingText slotBuilder builder_ =
    B.withChild (El.toNode (Component.listItemButtonSupportingText (B.toElement slotBuilder))) builder_


{-| -}
withTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.ListItemButtonTrailingSlot msg
    -> Builder attrCaps { s | trailing : Available } msg kind
    -> Builder attrCaps { s | trailing : Used } msg kind
withTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.listItemButtonTrailing (B.toElement slotBuilder))) builder_


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
