module M3e.Build.InputChip exposing (Builder, AttrCaps, SlotCaps, Is, Content, AvatarSlot, IconSlot, RemoveIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withDisabledInteractive, withId, withOnClick, withOnRemove, withRemovable, withRemoveLabel, withSlot, withStyle, withValue, withVariant, avatar, icon, removeIcon, withAvatar, withIcon, withRemoveIcon, withChild)

{-| The **InputChip** element — the flat per-element builder surface,
sourced through the **Chip** family façade
(`M3e.Component.Chip`). This module and the aggregated
`M3e.Build.Chip` are both first-class, permanent surfaces
(DAG-rework OQ-3/OQ-4).

@docs Builder, AttrCaps, SlotCaps, Is, Content, AvatarSlot, IconSlot, RemoveIconSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withDisabledInteractive, withId, withOnClick, withOnRemove, withRemovable, withRemoveLabel, withSlot, withStyle, withValue, withVariant, avatar, icon, removeIcon, withAvatar, withIcon, withRemoveIcon, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Chip as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.InputIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.InputBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.InputAttrCaps


{-| -}
type alias SlotCaps =
    Component.InputSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.InputChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.InputContent


{-| -}
type alias AvatarSlot =
    Component.InputAvatarSlot


{-| -}
type alias IconSlot =
    Component.InputIconSlot


{-| -}
type alias RemoveIconSlot =
    Component.InputRemoveIconSlot


{-| -}
build :
    { content : Element Component.InputContent (Component.InputChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-input-chip" [] [ El.toNode required_.content ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.InputIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
avatar :
    B.Builder childRow childAttrCaps childSlotCaps Component.InputAvatarSlot msg
    -> Element free freeAdmittedBy msg
avatar builder =
    Component.inputAvatar (B.toElement builder)


{-| -}
icon :
    B.Builder childRow childAttrCaps childSlotCaps Component.InputIconSlot msg
    -> Element free freeAdmittedBy msg
icon builder =
    Component.inputIcon (B.toElement builder)


{-| -}
removeIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.InputRemoveIconSlot msg
    -> Element free freeAdmittedBy msg
removeIcon builder =
    Component.inputRemoveIcon (B.toElement builder)


{-| -}
withAvatar :
    B.Builder childRow childAttrCaps childSlotCaps Component.InputAvatarSlot msg
    -> Builder attrCaps { s | avatar : Available } msg kind
    -> Builder attrCaps { s | avatar : Used } msg kind
withAvatar slotBuilder builder_ =
    B.withChild (El.toNode (Component.inputAvatar (B.toElement slotBuilder))) builder_


{-| -}
withIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.InputIconSlot msg
    -> Builder attrCaps { s | icon : Available } msg kind
    -> Builder attrCaps { s | icon : Used } msg kind
withIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.inputIcon (B.toElement slotBuilder))) builder_


{-| -}
withRemoveIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.InputRemoveIconSlot msg
    -> Builder attrCaps { s | removeIcon : Available } msg kind
    -> Builder attrCaps { s | removeIcon : Used } msg kind
withRemoveIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.inputRemoveIcon (B.toElement slotBuilder))) builder_


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
withVariant : Value Component.InputVariant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.inputVariant value_)


{-| -}
withOnRemove : msg -> Builder { a | onRemove : Available } slotCaps msg kind -> Builder { a | onRemove : Used } slotCaps msg kind
withOnRemove value_ =
    B.withAttribute (Ev.onRemove value_)


{-| -}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
