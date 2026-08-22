module M3e.Component.SplitButton exposing (SplitButtonIs, SplitButtonAttrs, SplitButtonBuilder, SplitButtonAttrCaps, SplitButtonSlotCaps, SplitButtonLeadingButtonSlot, SplitButtonTrailingButtonSlot, SplitButtonChildAdmittedBy, SplitButtonSize, SplitButtonVariant, splitButton, splitButtonSize, splitButtonVariant, splitButtonLeadingButton, splitButtonTrailingButton)

{-| The **SplitButton** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.SplitButton`](M3e.Element.SplitButton) as `splitButton`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs SplitButtonIs, SplitButtonAttrs, SplitButtonBuilder, SplitButtonAttrCaps, SplitButtonSlotCaps, SplitButtonLeadingButtonSlot, SplitButtonTrailingButtonSlot, SplitButtonChildAdmittedBy, SplitButtonSize, SplitButtonVariant, splitButton, splitButtonSize, splitButtonVariant, splitButtonLeadingButton, splitButtonTrailingButton

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.SplitButton as SplitButton_


{-| The `splitButton` element of this family — delegates to [`M3e.Element.SplitButton.component`](M3e.Element.SplitButton#component).
-}
splitButton :
    { leadingButton : Element SplitButtonLeadingButtonSlot (SplitButtonChildAdmittedBy childAdm) msg
    , trailingButton : Element SplitButtonTrailingButtonSlot (SplitButtonChildAdmittedBy childAdm) msg
    }
    -> List (Attr SplitButtonAttrs msg)
    -> List (Element childAccepts (SplitButtonChildAdmittedBy childAdm) msg)
    -> Element (SplitButtonIs s) admittedBy msg
splitButton =
    SplitButton_.component


{-| See [`M3e.Element.SplitButton.Is`](M3e.Element.SplitButton#Is).
-}
type alias SplitButtonIs s =
    SplitButton_.Is s


{-| See [`M3e.Element.SplitButton.Attrs`](M3e.Element.SplitButton#Attrs).
-}
type alias SplitButtonAttrs =
    SplitButton_.Attrs


{-| See [`M3e.Element.SplitButton.Builder`](M3e.Element.SplitButton#Builder).
-}
type alias SplitButtonBuilder attrCaps slotCaps msg kind =
    SplitButton_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.SplitButton.AttrCaps`](M3e.Element.SplitButton#AttrCaps).
-}
type alias SplitButtonAttrCaps =
    SplitButton_.AttrCaps


{-| See [`M3e.Element.SplitButton.SlotCaps`](M3e.Element.SplitButton#SlotCaps).
-}
type alias SplitButtonSlotCaps =
    SplitButton_.SlotCaps


{-| See [`M3e.Element.SplitButton.LeadingButtonSlot`](M3e.Element.SplitButton#LeadingButtonSlot).
-}
type alias SplitButtonLeadingButtonSlot =
    SplitButton_.LeadingButtonSlot


{-| See [`M3e.Element.SplitButton.TrailingButtonSlot`](M3e.Element.SplitButton#TrailingButtonSlot).
-}
type alias SplitButtonTrailingButtonSlot =
    SplitButton_.TrailingButtonSlot


{-| See [`M3e.Element.SplitButton.ChildAdmittedBy`](M3e.Element.SplitButton#ChildAdmittedBy).
-}
type alias SplitButtonChildAdmittedBy childAdm =
    SplitButton_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.SplitButton.Size`](M3e.Element.SplitButton#Size).
-}
type alias SplitButtonSize =
    SplitButton_.Size


{-| See [`M3e.Element.SplitButton.size`](M3e.Element.SplitButton#size).
-}
splitButtonSize : Value SplitButtonSize -> Attr { c | size : Supported } msg
splitButtonSize =
    SplitButton_.size


{-| See [`M3e.Element.SplitButton.Variant`](M3e.Element.SplitButton#Variant).
-}
type alias SplitButtonVariant =
    SplitButton_.Variant


{-| See [`M3e.Element.SplitButton.variant`](M3e.Element.SplitButton#variant).
-}
splitButtonVariant : Value SplitButtonVariant -> Attr { c | variant : Supported } msg
splitButtonVariant =
    SplitButton_.variant


{-| See [`M3e.Element.SplitButton.leadingButton`](M3e.Element.SplitButton#leadingButton).
-}
splitButtonLeadingButton : Element SplitButtonLeadingButtonSlot admittedBy msg -> Element free freeAdmittedBy msg
splitButtonLeadingButton =
    SplitButton_.leadingButton


{-| See [`M3e.Element.SplitButton.trailingButton`](M3e.Element.SplitButton#trailingButton).
-}
splitButtonTrailingButton : Element SplitButtonTrailingButtonSlot admittedBy msg -> Element free freeAdmittedBy msg
splitButtonTrailingButton =
    SplitButton_.trailingButton
