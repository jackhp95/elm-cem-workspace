module M3e.Build.ExpandableListItem exposing (Builder, AttrCaps, SlotCaps, Is, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, ToggleIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withId, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSlot, withStyle, items, leading, overline, supportingText, toggleIcon, withItems, withLeading, withOverline, withSupportingText, withToggleIcon, withChild)

{-| The **ExpandableListItem** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.ExpandableListItem`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, LeadingSlot, OverlineSlot, SupportingTextSlot, ToggleIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withId, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSlot, withStyle, items, leading, overline, supportingText, toggleIcon, withItems, withLeading, withOverline, withSupportingText, withToggleIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.ExpandableListItem as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.ExpandableListItemIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.ExpandableListItemBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.ExpandableListItemAttrCaps


{-| -}
type alias SlotCaps =
    Component.ExpandableListItemSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ExpandableListItemChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.ExpandableListItemContent


{-| -}
type alias LeadingSlot =
    Component.ExpandableListItemLeadingSlot


{-| -}
type alias OverlineSlot =
    Component.ExpandableListItemOverlineSlot


{-| -}
type alias SupportingTextSlot =
    Component.ExpandableListItemSupportingTextSlot


{-| -}
type alias ToggleIconSlot =
    Component.ExpandableListItemToggleIconSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-expandable-list-item" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ExpandableListItemIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
items :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
items builder =
    Component.expandableListItemItems (B.toElement builder)


{-| -}
leading :
    B.Builder childRow childAttrCaps childSlotCaps Component.ExpandableListItemLeadingSlot msg
    -> Element free freeAdmittedBy msg
leading builder =
    Component.expandableListItemLeading (B.toElement builder)


{-| -}
overline :
    B.Builder childRow childAttrCaps childSlotCaps Component.ExpandableListItemOverlineSlot msg
    -> Element free freeAdmittedBy msg
overline builder =
    Component.expandableListItemOverline (B.toElement builder)


{-| -}
supportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.ExpandableListItemSupportingTextSlot msg
    -> Element free freeAdmittedBy msg
supportingText builder =
    Component.expandableListItemSupportingText (B.toElement builder)


{-| -}
toggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ExpandableListItemToggleIconSlot msg
    -> Element free freeAdmittedBy msg
toggleIcon builder =
    Component.expandableListItemToggleIcon (B.toElement builder)


{-| -}
withItems :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | items : Available } msg kind
    -> Builder attrCaps { s | items : Used } msg kind
withItems slotBuilder builder_ =
    B.withChild (El.toNode (Component.expandableListItemItems (B.toElement slotBuilder))) builder_


{-| -}
withLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.ExpandableListItemLeadingSlot msg
    -> Builder attrCaps { s | leading : Available } msg kind
    -> Builder attrCaps { s | leading : Used } msg kind
withLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.expandableListItemLeading (B.toElement slotBuilder))) builder_


{-| -}
withOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.ExpandableListItemOverlineSlot msg
    -> Builder attrCaps { s | overline : Available } msg kind
    -> Builder attrCaps { s | overline : Used } msg kind
withOverline slotBuilder builder_ =
    B.withChild (El.toNode (Component.expandableListItemOverline (B.toElement slotBuilder))) builder_


{-| -}
withSupportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.ExpandableListItemSupportingTextSlot msg
    -> Builder attrCaps { s | supportingText : Available } msg kind
    -> Builder attrCaps { s | supportingText : Used } msg kind
withSupportingText slotBuilder builder_ =
    B.withChild (El.toNode (Component.expandableListItemSupportingText (B.toElement slotBuilder))) builder_


{-| -}
withToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ExpandableListItemToggleIconSlot msg
    -> Builder attrCaps { s | toggleIcon : Available } msg kind
    -> Builder attrCaps { s | toggleIcon : Used } msg kind
withToggleIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.expandableListItemToggleIcon (B.toElement slotBuilder))) builder_


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
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
withOnOpening : msg -> Builder { a | onOpening : Available } slotCaps msg kind -> Builder { a | onOpening : Used } slotCaps msg kind
withOnOpening value_ =
    B.withAttribute (Ev.onOpening value_)


{-| -}
withOnOpened : msg -> Builder { a | onOpened : Available } slotCaps msg kind -> Builder { a | onOpened : Used } slotCaps msg kind
withOnOpened value_ =
    B.withAttribute (Ev.onOpened value_)


{-| -}
withOnClosing : msg -> Builder { a | onClosing : Available } slotCaps msg kind -> Builder { a | onClosing : Used } slotCaps msg kind
withOnClosing value_ =
    B.withAttribute (Ev.onClosing value_)


{-| -}
withOnClosed : msg -> Builder { a | onClosed : Available } slotCaps msg kind -> Builder { a | onClosed : Used } slotCaps msg kind
withOnClosed value_ =
    B.withAttribute (Ev.onClosed value_)
