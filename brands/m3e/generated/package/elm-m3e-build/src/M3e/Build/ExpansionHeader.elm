module M3e.Build.ExpansionHeader exposing (Builder, AttrCaps, SlotCaps, Is, Content, ToggleIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withHideToggle, withId, withOnClick, withSlot, withStyle, withToggleDirection, withTogglePosition, toggleIcon, withToggleIcon, withChild)

{-| The **ExpansionHeader** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.ExpansionHeader`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, ToggleIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withHideToggle, withId, withOnClick, withSlot, withStyle, withToggleDirection, withTogglePosition, toggleIcon, withToggleIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.ExpansionHeader as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.ExpansionHeaderIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.ExpansionHeaderBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.ExpansionHeaderAttrCaps


{-| -}
type alias SlotCaps =
    Component.ExpansionHeaderSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ExpansionHeaderChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.ExpansionHeaderContent


{-| -}
type alias ToggleIconSlot =
    Component.ExpansionHeaderToggleIconSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-expansion-header" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.ExpansionHeaderIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
toggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ExpansionHeaderToggleIconSlot msg
    -> Element free freeAdmittedBy msg
toggleIcon builder =
    Component.expansionHeaderToggleIcon (B.toElement builder)


{-| -}
withToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ExpansionHeaderToggleIconSlot msg
    -> Builder attrCaps { s | toggleIcon : Available } msg kind
    -> Builder attrCaps { s | toggleIcon : Used } msg kind
withToggleIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.expansionHeaderToggleIcon (B.toElement slotBuilder))) builder_


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
withHideToggle : Bool -> Builder { a | hideToggle : Available } slotCaps msg kind -> Builder { a | hideToggle : Used } slotCaps msg kind
withHideToggle value_ =
    B.withAttribute (A.hideToggle value_)


{-| -}
withToggleDirection : Value Component.ExpansionHeaderToggleDirection -> Builder { a | toggleDirection : Available } slotCaps msg kind -> Builder { a | toggleDirection : Used } slotCaps msg kind
withToggleDirection value_ =
    B.withAttribute (Component.expansionHeaderToggleDirection value_)


{-| -}
withTogglePosition : Value Component.ExpansionHeaderTogglePosition -> Builder { a | togglePosition : Available } slotCaps msg kind -> Builder { a | togglePosition : Used } slotCaps msg kind
withTogglePosition value_ =
    B.withAttribute (Component.expansionHeaderTogglePosition value_)


{-| -}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
