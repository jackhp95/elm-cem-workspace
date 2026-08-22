module M3e.Component.Button exposing (ButtonIs, ButtonAttrs, ButtonBuilder, ButtonAttrCaps, ButtonSlotCaps, ButtonContent, ButtonIconSlot, ButtonSelectedSlot, ButtonSelectedIconSlot, ButtonTrailingIconSlot, ButtonChildAdmittedBy, ButtonActionCaps, ButtonShape, ButtonSize, ButtonType, ButtonVariant, button, buttonShape, buttonSize, buttonType_, buttonVariant, buttonDisabled, buttonDisabledInteractive, buttonDownload, buttonHref, buttonName, buttonRel, buttonTarget, buttonToggle, buttonValue, buttonDefaultValue, buttonOnBeforeinput, buttonOnInput, buttonOnChange, buttonOnClick, buttonIcon, buttonSelected, buttonSelectedIcon, buttonTrailingIcon, buttonChild)

{-| The **Button** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Button`](M3e.Element.Button) as `button`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ButtonIs, ButtonAttrs, ButtonBuilder, ButtonAttrCaps, ButtonSlotCaps, ButtonContent, ButtonIconSlot, ButtonSelectedSlot, ButtonSelectedIconSlot, ButtonTrailingIconSlot, ButtonChildAdmittedBy, ButtonActionCaps, ButtonShape, ButtonSize, ButtonType, ButtonVariant, button, buttonShape, buttonSize, buttonType_, buttonVariant, buttonDisabled, buttonDisabledInteractive, buttonDownload, buttonHref, buttonName, buttonRel, buttonTarget, buttonToggle, buttonValue, buttonDefaultValue, buttonOnBeforeinput, buttonOnInput, buttonOnChange, buttonOnClick, buttonIcon, buttonSelected, buttonSelectedIcon, buttonTrailingIcon, buttonChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Action as Ac
import M3e.Element.Button as Button_


{-| The `button` element of this family — delegates to [`M3e.Element.Button.component`](M3e.Element.Button#component).
-}
button :
    { content : Element ButtonContent (ButtonChildAdmittedBy childAdm) msg
    , action : Ac.Action ButtonActionCaps msg
    }
    -> List (Attr ButtonAttrs msg)
    -> List (Element ButtonContent (ButtonChildAdmittedBy childAdm) msg)
    -> Element (ButtonIs s) admittedBy msg
button =
    Button_.component


{-| See [`M3e.Element.Button.Is`](M3e.Element.Button#Is).
-}
type alias ButtonIs s =
    Button_.Is s


{-| See [`M3e.Element.Button.Attrs`](M3e.Element.Button#Attrs).
-}
type alias ButtonAttrs =
    Button_.Attrs


{-| See [`M3e.Element.Button.Builder`](M3e.Element.Button#Builder).
-}
type alias ButtonBuilder attrCaps slotCaps msg kind =
    Button_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Button.AttrCaps`](M3e.Element.Button#AttrCaps).
-}
type alias ButtonAttrCaps =
    Button_.AttrCaps


{-| See [`M3e.Element.Button.SlotCaps`](M3e.Element.Button#SlotCaps).
-}
type alias ButtonSlotCaps =
    Button_.SlotCaps


{-| See [`M3e.Element.Button.Content`](M3e.Element.Button#Content).
-}
type alias ButtonContent =
    Button_.Content


{-| See [`M3e.Element.Button.IconSlot`](M3e.Element.Button#IconSlot).
-}
type alias ButtonIconSlot =
    Button_.IconSlot


{-| See [`M3e.Element.Button.SelectedSlot`](M3e.Element.Button#SelectedSlot).
-}
type alias ButtonSelectedSlot =
    Button_.SelectedSlot


{-| See [`M3e.Element.Button.SelectedIconSlot`](M3e.Element.Button#SelectedIconSlot).
-}
type alias ButtonSelectedIconSlot =
    Button_.SelectedIconSlot


{-| See [`M3e.Element.Button.TrailingIconSlot`](M3e.Element.Button#TrailingIconSlot).
-}
type alias ButtonTrailingIconSlot =
    Button_.TrailingIconSlot


{-| See [`M3e.Element.Button.ChildAdmittedBy`](M3e.Element.Button#ChildAdmittedBy).
-}
type alias ButtonChildAdmittedBy childAdm =
    Button_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Button.ActionCaps`](M3e.Element.Button#ActionCaps).
-}
type alias ButtonActionCaps =
    Button_.ActionCaps


{-| See [`M3e.Element.Button.Shape`](M3e.Element.Button#Shape).
-}
type alias ButtonShape =
    Button_.Shape


{-| See [`M3e.Element.Button.shape`](M3e.Element.Button#shape).
-}
buttonShape : Value ButtonShape -> Attr { c | shape : Supported } msg
buttonShape =
    Button_.shape


{-| See [`M3e.Element.Button.Size`](M3e.Element.Button#Size).
-}
type alias ButtonSize =
    Button_.Size


{-| See [`M3e.Element.Button.size`](M3e.Element.Button#size).
-}
buttonSize : Value ButtonSize -> Attr { c | size : Supported } msg
buttonSize =
    Button_.size


{-| See [`M3e.Element.Button.Type`](M3e.Element.Button#Type).
-}
type alias ButtonType =
    Button_.Type


{-| See [`M3e.Element.Button.type_`](M3e.Element.Button#type_).
-}
buttonType_ : Value ButtonType -> Attr { c | type_ : Supported } msg
buttonType_ =
    Button_.type_


{-| See [`M3e.Element.Button.Variant`](M3e.Element.Button#Variant).
-}
type alias ButtonVariant =
    Button_.Variant


{-| See [`M3e.Element.Button.variant`](M3e.Element.Button#variant).
-}
buttonVariant : Value ButtonVariant -> Attr { c | variant : Supported } msg
buttonVariant =
    Button_.variant


{-| See [`M3e.Element.Button.disabled`](M3e.Element.Button#disabled).
-}
buttonDisabled : Bool -> Attr { c | disabled : Supported } msg
buttonDisabled =
    Button_.disabled


{-| See [`M3e.Element.Button.disabledInteractive`](M3e.Element.Button#disabledInteractive).
-}
buttonDisabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
buttonDisabledInteractive =
    Button_.disabledInteractive


{-| See [`M3e.Element.Button.download`](M3e.Element.Button#download).
-}
buttonDownload : String -> Attr { c | download : Supported } msg
buttonDownload =
    Button_.download


{-| See [`M3e.Element.Button.href`](M3e.Element.Button#href).
-}
buttonHref : String -> Attr { c | href : Supported } msg
buttonHref =
    Button_.href


{-| See [`M3e.Element.Button.name`](M3e.Element.Button#name).
-}
buttonName : String -> Attr { c | name : Supported } msg
buttonName =
    Button_.name


{-| See [`M3e.Element.Button.rel`](M3e.Element.Button#rel).
-}
buttonRel : String -> Attr { c | rel : Supported } msg
buttonRel =
    Button_.rel


{-| See [`M3e.Element.Button.target`](M3e.Element.Button#target).
-}
buttonTarget : String -> Attr { c | target : Supported } msg
buttonTarget =
    Button_.target


{-| See [`M3e.Element.Button.toggle`](M3e.Element.Button#toggle).
-}
buttonToggle : Bool -> Attr { c | toggle : Supported } msg
buttonToggle =
    Button_.toggle


{-| See [`M3e.Element.Button.value`](M3e.Element.Button#value).
-}
buttonValue : String -> Attr { c | value : Supported } msg
buttonValue =
    Button_.value


{-| See [`M3e.Element.Button.defaultValue`](M3e.Element.Button#defaultValue).
-}
buttonDefaultValue : String -> Attr { c | value : Supported } msg
buttonDefaultValue =
    Button_.defaultValue


{-| See [`M3e.Element.Button.onBeforeinput`](M3e.Element.Button#onBeforeinput).
-}
buttonOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
buttonOnBeforeinput =
    Button_.onBeforeinput


{-| See [`M3e.Element.Button.onInput`](M3e.Element.Button#onInput).
-}
buttonOnInput : msg -> Attr { c | onInput : Supported } msg
buttonOnInput =
    Button_.onInput


{-| See [`M3e.Element.Button.onChange`](M3e.Element.Button#onChange).
-}
buttonOnChange : msg -> Attr { c | onChange : Supported } msg
buttonOnChange =
    Button_.onChange


{-| See [`M3e.Element.Button.onClick`](M3e.Element.Button#onClick).
-}
buttonOnClick : msg -> Attr { c | onClick : Supported } msg
buttonOnClick =
    Button_.onClick


{-| See [`M3e.Element.Button.icon`](M3e.Element.Button#icon).
-}
buttonIcon : Element ButtonIconSlot admittedBy msg -> Element free freeAdmittedBy msg
buttonIcon =
    Button_.icon


{-| See [`M3e.Element.Button.selected`](M3e.Element.Button#selected).
-}
buttonSelected : Element ButtonSelectedSlot admittedBy msg -> Element free freeAdmittedBy msg
buttonSelected =
    Button_.selected


{-| See [`M3e.Element.Button.selectedIcon`](M3e.Element.Button#selectedIcon).
-}
buttonSelectedIcon : Element ButtonSelectedIconSlot admittedBy msg -> Element free freeAdmittedBy msg
buttonSelectedIcon =
    Button_.selectedIcon


{-| See [`M3e.Element.Button.trailingIcon`](M3e.Element.Button#trailingIcon).
-}
buttonTrailingIcon : Element ButtonTrailingIconSlot admittedBy msg -> Element free freeAdmittedBy msg
buttonTrailingIcon =
    Button_.trailingIcon


{-| See [`M3e.Element.Button.child`](M3e.Element.Button#child).
-}
buttonChild : Element ButtonContent admittedBy msg -> Element free freeAdmittedBy msg
buttonChild =
    Button_.child
