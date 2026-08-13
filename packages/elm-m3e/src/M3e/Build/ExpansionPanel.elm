module M3e.Build.ExpansionPanel exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ToggleIconSlot, ChildAdmittedBy
    , withClass, withDisabled, withHideToggle, withId, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSlot, withStyle, withToggleDirection, withTogglePosition
    , actions, header, toggleIcon
    , withHeader, withToggleIcon, withActions, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ToggleIconSlot, ChildAdmittedBy
@docs withClass, withDisabled, withHideToggle, withId, withOnClosed, withOnClosing, withOnOpened, withOnOpening, withOpen, withSlot, withStyle, withToggleDirection, withTogglePosition
@docs actions, header, toggleIcon
@docs withHeader, withToggleIcon, withActions, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.ExpansionPanel as Component
import M3e.Events as Ev
import M3e.Internal.Types.ExpansionPanel
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    M3e.Internal.Types.ExpansionPanel.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.ExpansionPanel.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.ExpansionPanel.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.ExpansionPanel.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ExpansionPanel.ChildAdmittedBy childAdm


{-| -}
type alias ToggleIconSlot =
    M3e.Internal.Types.ExpansionPanel.ToggleIconSlot


{-| -}
build :
    { header : Element childAccepts (Component.ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-expansion-panel" [] [ El.toNode (Component.header required_.header) ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
actions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
actions builder =
    Component.actions (B.toElement builder)


{-| -}
header :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
header builder =
    Component.header (B.toElement builder)


{-| -}
toggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ToggleIconSlot msg
    -> Element free freeAdmittedBy msg
toggleIcon builder =
    Component.toggleIcon (B.toElement builder)


{-| -}
withHeader :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | header : Available } msg kind
    -> Builder attrCaps { s | header : Used } msg kind
withHeader slotBuilder builder_ =
    B.withChild (El.toNode (Component.header (B.toElement slotBuilder))) builder_


{-| -}
withToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ToggleIconSlot msg
    -> Builder attrCaps { s | toggleIcon : Available } msg kind
    -> Builder attrCaps { s | toggleIcon : Used } msg kind
withToggleIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.toggleIcon (B.toElement slotBuilder))) builder_


{-| -}
withActions :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withActions slotBuilder builder_ =
    B.withChild (El.toNode (Component.actions (B.toElement slotBuilder))) builder_


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
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
withToggleDirection : Value Component.ToggleDirection -> Builder { a | toggleDirection : Available } slotCaps msg kind -> Builder { a | toggleDirection : Used } slotCaps msg kind
withToggleDirection value_ =
    B.withAttribute (Component.toggleDirection value_)


{-| -}
withTogglePosition : Value Component.TogglePosition -> Builder { a | togglePosition : Available } slotCaps msg kind -> Builder { a | togglePosition : Used } slotCaps msg kind
withTogglePosition value_ =
    B.withAttribute (Component.togglePosition value_)


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
