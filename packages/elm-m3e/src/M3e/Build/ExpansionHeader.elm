module M3e.Build.ExpansionHeader exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ToggleIconSlot, ChildAdmittedBy
    , withClass, withDisabled, withHideToggle, withId, withOnClick, withSlot, withStyle, withToggleDirection, withTogglePosition
    , toggleIcon
    , withToggleIcon, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ToggleIconSlot, ChildAdmittedBy
@docs withClass, withDisabled, withHideToggle, withId, withOnClick, withSlot, withStyle, withToggleDirection, withTogglePosition
@docs toggleIcon
@docs withToggleIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Build.Internal as B
import M3e.Component.ExpansionHeader as Component
import M3e.Events as Ev
import M3e.Internal.Types.ExpansionHeader
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    M3e.Internal.Types.ExpansionHeader.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.ExpansionHeader.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.ExpansionHeader.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.ExpansionHeader.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.ExpansionHeader.ChildAdmittedBy childAdm


{-| -}
type alias Content =
    M3e.Internal.Types.ExpansionHeader.Content


{-| -}
type alias ToggleIconSlot =
    M3e.Internal.Types.ExpansionHeader.ToggleIconSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-expansion-header" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
toggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ToggleIconSlot msg
    -> Element free freeAdmittedBy msg
toggleIcon builder =
    Component.toggleIcon (B.toElement builder)


{-| -}
withToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ToggleIconSlot msg
    -> Builder attrCaps { s | toggleIcon : Available } msg kind
    -> Builder attrCaps { s | toggleIcon : Used } msg kind
withToggleIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.toggleIcon (B.toElement slotBuilder))) builder_


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
withToggleDirection : Value Component.ToggleDirection -> Builder { a | toggleDirection : Available } slotCaps msg kind -> Builder { a | toggleDirection : Used } slotCaps msg kind
withToggleDirection value_ =
    B.withAttribute (Component.toggleDirection value_)


{-| -}
withTogglePosition : Value Component.TogglePosition -> Builder { a | togglePosition : Available } slotCaps msg kind -> Builder { a | togglePosition : Used } slotCaps msg kind
withTogglePosition value_ =
    B.withAttribute (Component.togglePosition value_)


{-| -}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
