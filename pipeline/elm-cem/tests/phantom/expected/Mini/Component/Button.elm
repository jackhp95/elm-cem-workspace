module Mini.Component.Button exposing (ButtonIs, ButtonAttrs, ButtonBuilder, ButtonAttrCaps, ButtonSlotCaps, ButtonContent, ButtonIconSlot, ButtonChildAdmittedBy, ButtonVariant, button, buttonVariant, buttonDisabled, buttonWeight, buttonWeightAsNumber, buttonOnClick, buttonIcon, buttonChild)

{-| The **Button** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Mini.Element.Button`](Mini.Element.Button) as `button`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ButtonIs, ButtonAttrs, ButtonBuilder, ButtonAttrCaps, ButtonSlotCaps, ButtonContent, ButtonIconSlot, ButtonChildAdmittedBy, ButtonVariant, button, buttonVariant, buttonDisabled, buttonWeight, buttonWeightAsNumber, buttonOnClick, buttonIcon, buttonChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Mini.Element.Button as Button_


{-| The `button` element of this family — delegates to [`Mini.Element.Button.component`](Mini.Element.Button#component).
-}
button :
    { content : Element ButtonContent (ButtonChildAdmittedBy childAdm) msg }
    -> List (Attr ButtonAttrs msg)
    -> List (Element ButtonContent (ButtonChildAdmittedBy childAdm) msg)
    -> Element (ButtonIs s) admittedBy msg
button =
    Button_.component


{-| See [`Mini.Element.Button.Is`](Mini.Element.Button#Is).
-}
type alias ButtonIs s =
    Button_.Is s


{-| See [`Mini.Element.Button.Attrs`](Mini.Element.Button#Attrs).
-}
type alias ButtonAttrs =
    Button_.Attrs


{-| See [`Mini.Element.Button.Builder`](Mini.Element.Button#Builder).
-}
type alias ButtonBuilder attrCaps slotCaps msg kind =
    Button_.Builder attrCaps slotCaps msg kind


{-| See [`Mini.Element.Button.AttrCaps`](Mini.Element.Button#AttrCaps).
-}
type alias ButtonAttrCaps =
    Button_.AttrCaps


{-| See [`Mini.Element.Button.SlotCaps`](Mini.Element.Button#SlotCaps).
-}
type alias ButtonSlotCaps =
    Button_.SlotCaps


{-| See [`Mini.Element.Button.Content`](Mini.Element.Button#Content).
-}
type alias ButtonContent =
    Button_.Content


{-| See [`Mini.Element.Button.IconSlot`](Mini.Element.Button#IconSlot).
-}
type alias ButtonIconSlot =
    Button_.IconSlot


{-| See [`Mini.Element.Button.ChildAdmittedBy`](Mini.Element.Button#ChildAdmittedBy).
-}
type alias ButtonChildAdmittedBy childAdm =
    Button_.ChildAdmittedBy childAdm


{-| See [`Mini.Element.Button.Variant`](Mini.Element.Button#Variant).
-}
type alias ButtonVariant =
    Button_.Variant


{-| See [`Mini.Element.Button.variant`](Mini.Element.Button#variant).
-}
buttonVariant : Value ButtonVariant -> Attr { c | variant : Supported } msg
buttonVariant =
    Button_.variant


{-| See [`Mini.Element.Button.disabled`](Mini.Element.Button#disabled).
-}
buttonDisabled : Bool -> Attr { c | disabled : Supported } msg
buttonDisabled =
    Button_.disabled


{-| See [`Mini.Element.Button.weight`](Mini.Element.Button#weight).
-}
buttonWeight : String -> Attr { c | weight : Supported } msg
buttonWeight =
    Button_.weight


{-| See [`Mini.Element.Button.weightAsNumber`](Mini.Element.Button#weightAsNumber).
-}
buttonWeightAsNumber : Float -> Attr { c | weight : Supported } msg
buttonWeightAsNumber =
    Button_.weightAsNumber


{-| See [`Mini.Element.Button.onClick`](Mini.Element.Button#onClick).
-}
buttonOnClick : msg -> Attr { c | onClick : Supported } msg
buttonOnClick =
    Button_.onClick


{-| See [`Mini.Element.Button.icon`](Mini.Element.Button#icon).
-}
buttonIcon : Element ButtonIconSlot admittedBy msg -> Element free freeAdmittedBy msg
buttonIcon =
    Button_.icon


{-| See [`Mini.Element.Button.child`](Mini.Element.Button#child).
-}
buttonChild : Element ButtonContent admittedBy msg -> Element free freeAdmittedBy msg
buttonChild =
    Button_.child
