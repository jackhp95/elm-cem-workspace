module M3e.Build.InputChip exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, AvatarSlot, IconSlot, RemoveIconSlot, ChildAdmittedBy
    , withClass, withDisabled, withDisabledInteractive, withId, withOnClick, withOnRemove, withRemovable, withRemoveLabel, withSlot, withStyle, withValue, withVariant
    , avatar, icon, removeIcon
    , withAvatar, withIcon, withRemoveIcon, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, AvatarSlot, IconSlot, RemoveIconSlot, ChildAdmittedBy
@docs withClass, withDisabled, withDisabledInteractive, withId, withOnClick, withOnRemove, withRemovable, withRemoveLabel, withSlot, withStyle, withValue, withVariant
@docs avatar, icon, removeIcon
@docs withAvatar, withIcon, withRemoveIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Component.InputChip as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.AttrCaps


{-| -}
type alias SlotCaps =
    Component.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.Content


{-| -}
type alias AvatarSlot =
    Component.AvatarSlot


{-| -}
type alias IconSlot =
    Component.IconSlot


{-| -}
type alias RemoveIconSlot =
    Component.RemoveIconSlot


{-| -}
build :
    { content : Element Component.Content (Component.ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-input-chip" [] [ El.toNode required_.content ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
avatar :
    B.Builder childRow childAttrCaps childSlotCaps Component.AvatarSlot msg
    -> Element free freeAdmittedBy msg
avatar builder =
    Component.avatar (B.toElement builder)


{-| -}
icon :
    B.Builder childRow childAttrCaps childSlotCaps Component.IconSlot msg
    -> Element free freeAdmittedBy msg
icon builder =
    Component.icon (B.toElement builder)


{-| -}
removeIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.RemoveIconSlot msg
    -> Element free freeAdmittedBy msg
removeIcon builder =
    Component.removeIcon (B.toElement builder)


{-| -}
withAvatar :
    B.Builder childRow childAttrCaps childSlotCaps Component.AvatarSlot msg
    -> Builder attrCaps { s | avatar : Available } msg kind
    -> Builder attrCaps { s | avatar : Used } msg kind
withAvatar slotBuilder builder_ =
    B.withChild (El.toNode (Component.avatar (B.toElement slotBuilder))) builder_


{-| -}
withIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.IconSlot msg
    -> Builder attrCaps { s | icon : Available } msg kind
    -> Builder attrCaps { s | icon : Used } msg kind
withIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.icon (B.toElement slotBuilder))) builder_


{-| -}
withRemoveIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.RemoveIconSlot msg
    -> Builder attrCaps { s | removeIcon : Available } msg kind
    -> Builder attrCaps { s | removeIcon : Used } msg kind
withRemoveIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.removeIcon (B.toElement slotBuilder))) builder_


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
withDisabledInteractive : Bool -> Builder { a | disabledInteractive : Available } slotCaps msg kind -> Builder { a | disabledInteractive : Used } slotCaps msg kind
withDisabledInteractive value_ =
    B.withAttribute (A.disabledInteractive value_)


{-| -}
withRemovable : Bool -> Builder { a | removable : Available } slotCaps msg kind -> Builder { a | removable : Used } slotCaps msg kind
withRemovable value_ =
    B.withAttribute (A.removable value_)


{-| -}
withRemoveLabel : String -> Builder { a | removeLabel : Available } slotCaps msg kind -> Builder { a | removeLabel : Used } slotCaps msg kind
withRemoveLabel value_ =
    B.withAttribute (A.removeLabel value_)


{-| -}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)


{-| -}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)


{-| -}
withOnRemove : msg -> Builder { a | onRemove : Available } slotCaps msg kind -> Builder { a | onRemove : Used } slotCaps msg kind
withOnRemove value_ =
    B.withAttribute (Ev.onRemove value_)


{-| -}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
