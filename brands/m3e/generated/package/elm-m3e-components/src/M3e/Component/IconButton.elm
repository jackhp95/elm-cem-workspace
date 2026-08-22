module M3e.Component.IconButton exposing (IconButtonIs, IconButtonAttrs, IconButtonBuilder, IconButtonAttrCaps, IconButtonSlotCaps, IconButtonContent, IconButtonSelectedSlot, IconButtonChildAdmittedBy, IconButtonActionCaps, IconButtonShape, IconButtonSize, IconButtonType, IconButtonVariant, IconButtonWidth, iconButton, iconButtonShape, iconButtonSize, iconButtonType_, iconButtonVariant, iconButtonWidth, iconButtonDisabled, iconButtonDisabledInteractive, iconButtonDownload, iconButtonHref, iconButtonName, iconButtonRel, iconButtonTarget, iconButtonToggle, iconButtonValue, iconButtonDefaultValue, iconButtonOnBeforeinput, iconButtonOnInput, iconButtonOnChange, iconButtonOnClick, iconButtonSelected, iconButtonChild)

{-| The **IconButton** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.IconButton`](M3e.Element.IconButton) as `iconButton`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs IconButtonIs, IconButtonAttrs, IconButtonBuilder, IconButtonAttrCaps, IconButtonSlotCaps, IconButtonContent, IconButtonSelectedSlot, IconButtonChildAdmittedBy, IconButtonActionCaps, IconButtonShape, IconButtonSize, IconButtonType, IconButtonVariant, IconButtonWidth, iconButton, iconButtonShape, iconButtonSize, iconButtonType_, iconButtonVariant, iconButtonWidth, iconButtonDisabled, iconButtonDisabledInteractive, iconButtonDownload, iconButtonHref, iconButtonName, iconButtonRel, iconButtonTarget, iconButtonToggle, iconButtonValue, iconButtonDefaultValue, iconButtonOnBeforeinput, iconButtonOnInput, iconButtonOnChange, iconButtonOnClick, iconButtonSelected, iconButtonChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Action as Ac
import M3e.Element.IconButton as IconButton_


{-| The `iconButton` element of this family — delegates to [`M3e.Element.IconButton.component`](M3e.Element.IconButton#component).
-}
iconButton :
    { content : Element IconButtonContent (IconButtonChildAdmittedBy childAdm) msg
    , ariaLabel : String
    , action : Ac.Action IconButtonActionCaps msg
    }
    -> List (Attr IconButtonAttrs msg)
    -> List (Element IconButtonContent (IconButtonChildAdmittedBy childAdm) msg)
    -> Element (IconButtonIs s) admittedBy msg
iconButton =
    IconButton_.component


{-| See [`M3e.Element.IconButton.Is`](M3e.Element.IconButton#Is).
-}
type alias IconButtonIs s =
    IconButton_.Is s


{-| See [`M3e.Element.IconButton.Attrs`](M3e.Element.IconButton#Attrs).
-}
type alias IconButtonAttrs =
    IconButton_.Attrs


{-| See [`M3e.Element.IconButton.Builder`](M3e.Element.IconButton#Builder).
-}
type alias IconButtonBuilder attrCaps slotCaps msg kind =
    IconButton_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.IconButton.AttrCaps`](M3e.Element.IconButton#AttrCaps).
-}
type alias IconButtonAttrCaps =
    IconButton_.AttrCaps


{-| See [`M3e.Element.IconButton.SlotCaps`](M3e.Element.IconButton#SlotCaps).
-}
type alias IconButtonSlotCaps =
    IconButton_.SlotCaps


{-| See [`M3e.Element.IconButton.Content`](M3e.Element.IconButton#Content).
-}
type alias IconButtonContent =
    IconButton_.Content


{-| See [`M3e.Element.IconButton.SelectedSlot`](M3e.Element.IconButton#SelectedSlot).
-}
type alias IconButtonSelectedSlot =
    IconButton_.SelectedSlot


{-| See [`M3e.Element.IconButton.ChildAdmittedBy`](M3e.Element.IconButton#ChildAdmittedBy).
-}
type alias IconButtonChildAdmittedBy childAdm =
    IconButton_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.IconButton.ActionCaps`](M3e.Element.IconButton#ActionCaps).
-}
type alias IconButtonActionCaps =
    IconButton_.ActionCaps


{-| See [`M3e.Element.IconButton.Shape`](M3e.Element.IconButton#Shape).
-}
type alias IconButtonShape =
    IconButton_.Shape


{-| See [`M3e.Element.IconButton.shape`](M3e.Element.IconButton#shape).
-}
iconButtonShape : Value IconButtonShape -> Attr { c | shape : Supported } msg
iconButtonShape =
    IconButton_.shape


{-| See [`M3e.Element.IconButton.Size`](M3e.Element.IconButton#Size).
-}
type alias IconButtonSize =
    IconButton_.Size


{-| See [`M3e.Element.IconButton.size`](M3e.Element.IconButton#size).
-}
iconButtonSize : Value IconButtonSize -> Attr { c | size : Supported } msg
iconButtonSize =
    IconButton_.size


{-| See [`M3e.Element.IconButton.Type`](M3e.Element.IconButton#Type).
-}
type alias IconButtonType =
    IconButton_.Type


{-| See [`M3e.Element.IconButton.type_`](M3e.Element.IconButton#type_).
-}
iconButtonType_ : Value IconButtonType -> Attr { c | type_ : Supported } msg
iconButtonType_ =
    IconButton_.type_


{-| See [`M3e.Element.IconButton.Variant`](M3e.Element.IconButton#Variant).
-}
type alias IconButtonVariant =
    IconButton_.Variant


{-| See [`M3e.Element.IconButton.variant`](M3e.Element.IconButton#variant).
-}
iconButtonVariant : Value IconButtonVariant -> Attr { c | variant : Supported } msg
iconButtonVariant =
    IconButton_.variant


{-| See [`M3e.Element.IconButton.Width`](M3e.Element.IconButton#Width).
-}
type alias IconButtonWidth =
    IconButton_.Width


{-| See [`M3e.Element.IconButton.width`](M3e.Element.IconButton#width).
-}
iconButtonWidth : Value IconButtonWidth -> Attr { c | width : Supported } msg
iconButtonWidth =
    IconButton_.width


{-| See [`M3e.Element.IconButton.disabled`](M3e.Element.IconButton#disabled).
-}
iconButtonDisabled : Bool -> Attr { c | disabled : Supported } msg
iconButtonDisabled =
    IconButton_.disabled


{-| See [`M3e.Element.IconButton.disabledInteractive`](M3e.Element.IconButton#disabledInteractive).
-}
iconButtonDisabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
iconButtonDisabledInteractive =
    IconButton_.disabledInteractive


{-| See [`M3e.Element.IconButton.download`](M3e.Element.IconButton#download).
-}
iconButtonDownload : String -> Attr { c | download : Supported } msg
iconButtonDownload =
    IconButton_.download


{-| See [`M3e.Element.IconButton.href`](M3e.Element.IconButton#href).
-}
iconButtonHref : String -> Attr { c | href : Supported } msg
iconButtonHref =
    IconButton_.href


{-| See [`M3e.Element.IconButton.name`](M3e.Element.IconButton#name).
-}
iconButtonName : String -> Attr { c | name : Supported } msg
iconButtonName =
    IconButton_.name


{-| See [`M3e.Element.IconButton.rel`](M3e.Element.IconButton#rel).
-}
iconButtonRel : String -> Attr { c | rel : Supported } msg
iconButtonRel =
    IconButton_.rel


{-| See [`M3e.Element.IconButton.target`](M3e.Element.IconButton#target).
-}
iconButtonTarget : String -> Attr { c | target : Supported } msg
iconButtonTarget =
    IconButton_.target


{-| See [`M3e.Element.IconButton.toggle`](M3e.Element.IconButton#toggle).
-}
iconButtonToggle : Bool -> Attr { c | toggle : Supported } msg
iconButtonToggle =
    IconButton_.toggle


{-| See [`M3e.Element.IconButton.value`](M3e.Element.IconButton#value).
-}
iconButtonValue : String -> Attr { c | value : Supported } msg
iconButtonValue =
    IconButton_.value


{-| See [`M3e.Element.IconButton.defaultValue`](M3e.Element.IconButton#defaultValue).
-}
iconButtonDefaultValue : String -> Attr { c | value : Supported } msg
iconButtonDefaultValue =
    IconButton_.defaultValue


{-| See [`M3e.Element.IconButton.onBeforeinput`](M3e.Element.IconButton#onBeforeinput).
-}
iconButtonOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
iconButtonOnBeforeinput =
    IconButton_.onBeforeinput


{-| See [`M3e.Element.IconButton.onInput`](M3e.Element.IconButton#onInput).
-}
iconButtonOnInput : msg -> Attr { c | onInput : Supported } msg
iconButtonOnInput =
    IconButton_.onInput


{-| See [`M3e.Element.IconButton.onChange`](M3e.Element.IconButton#onChange).
-}
iconButtonOnChange : msg -> Attr { c | onChange : Supported } msg
iconButtonOnChange =
    IconButton_.onChange


{-| See [`M3e.Element.IconButton.onClick`](M3e.Element.IconButton#onClick).
-}
iconButtonOnClick : msg -> Attr { c | onClick : Supported } msg
iconButtonOnClick =
    IconButton_.onClick


{-| See [`M3e.Element.IconButton.selected`](M3e.Element.IconButton#selected).
-}
iconButtonSelected : Element IconButtonSelectedSlot admittedBy msg -> Element free freeAdmittedBy msg
iconButtonSelected =
    IconButton_.selected


{-| See [`M3e.Element.IconButton.child`](M3e.Element.IconButton#child).
-}
iconButtonChild : Element IconButtonContent admittedBy msg -> Element free freeAdmittedBy msg
iconButtonChild =
    IconButton_.child
