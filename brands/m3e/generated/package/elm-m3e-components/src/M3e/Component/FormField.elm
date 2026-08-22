module M3e.Component.FormField exposing (FormFieldIs, FormFieldAttrs, FormFieldBuilder, FormFieldAttrCaps, FormFieldSlotCaps, FormFieldChildAdmittedBy, FormFieldFloatLabel, FormFieldHideSubscript, FormFieldVariant, formField, formFieldFloatLabel, formFieldHideSubscript, formFieldVariant, formFieldHideRequiredMarker, formFieldError, formFieldHint, formFieldLabel, formFieldPrefix, formFieldPrefixText, formFieldSuffix, formFieldSuffixText, formFieldChild)

{-| The **FormField** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.FormField`](M3e.Element.FormField) as `formField`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs FormFieldIs, FormFieldAttrs, FormFieldBuilder, FormFieldAttrCaps, FormFieldSlotCaps, FormFieldChildAdmittedBy, FormFieldFloatLabel, FormFieldHideSubscript, FormFieldVariant, formField, formFieldFloatLabel, formFieldHideSubscript, formFieldVariant, formFieldHideRequiredMarker, formFieldError, formFieldHint, formFieldLabel, formFieldPrefix, formFieldPrefixText, formFieldSuffix, formFieldSuffixText, formFieldChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.FormField as FormField_


{-| The `formField` element of this family — delegates to [`M3e.Element.FormField.component`](M3e.Element.FormField#component).
-}
formField :
    List (Attr FormFieldAttrs msg)
    -> List (Element childAccepts (FormFieldChildAdmittedBy childAdm) msg)
    -> Element (FormFieldIs s) admittedBy msg
formField =
    FormField_.component


{-| See [`M3e.Element.FormField.Is`](M3e.Element.FormField#Is).
-}
type alias FormFieldIs s =
    FormField_.Is s


{-| See [`M3e.Element.FormField.Attrs`](M3e.Element.FormField#Attrs).
-}
type alias FormFieldAttrs =
    FormField_.Attrs


{-| See [`M3e.Element.FormField.Builder`](M3e.Element.FormField#Builder).
-}
type alias FormFieldBuilder attrCaps slotCaps msg kind =
    FormField_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.FormField.AttrCaps`](M3e.Element.FormField#AttrCaps).
-}
type alias FormFieldAttrCaps =
    FormField_.AttrCaps


{-| See [`M3e.Element.FormField.SlotCaps`](M3e.Element.FormField#SlotCaps).
-}
type alias FormFieldSlotCaps =
    FormField_.SlotCaps


{-| See [`M3e.Element.FormField.ChildAdmittedBy`](M3e.Element.FormField#ChildAdmittedBy).
-}
type alias FormFieldChildAdmittedBy childAdm =
    FormField_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.FormField.FloatLabel`](M3e.Element.FormField#FloatLabel).
-}
type alias FormFieldFloatLabel =
    FormField_.FloatLabel


{-| See [`M3e.Element.FormField.floatLabel`](M3e.Element.FormField#floatLabel).
-}
formFieldFloatLabel : Value FormFieldFloatLabel -> Attr { c | floatLabel : Supported } msg
formFieldFloatLabel =
    FormField_.floatLabel


{-| See [`M3e.Element.FormField.HideSubscript`](M3e.Element.FormField#HideSubscript).
-}
type alias FormFieldHideSubscript =
    FormField_.HideSubscript


{-| See [`M3e.Element.FormField.hideSubscript`](M3e.Element.FormField#hideSubscript).
-}
formFieldHideSubscript : Value FormFieldHideSubscript -> Attr { c | hideSubscript : Supported } msg
formFieldHideSubscript =
    FormField_.hideSubscript


{-| See [`M3e.Element.FormField.Variant`](M3e.Element.FormField#Variant).
-}
type alias FormFieldVariant =
    FormField_.Variant


{-| See [`M3e.Element.FormField.variant`](M3e.Element.FormField#variant).
-}
formFieldVariant : Value FormFieldVariant -> Attr { c | variant : Supported } msg
formFieldVariant =
    FormField_.variant


{-| See [`M3e.Element.FormField.hideRequiredMarker`](M3e.Element.FormField#hideRequiredMarker).
-}
formFieldHideRequiredMarker : Bool -> Attr { c | hideRequiredMarker : Supported } msg
formFieldHideRequiredMarker =
    FormField_.hideRequiredMarker


{-| See [`M3e.Element.FormField.error`](M3e.Element.FormField#error).
-}
formFieldError : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
formFieldError =
    FormField_.error


{-| See [`M3e.Element.FormField.hint`](M3e.Element.FormField#hint).
-}
formFieldHint : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
formFieldHint =
    FormField_.hint


{-| See [`M3e.Element.FormField.label`](M3e.Element.FormField#label).
-}
formFieldLabel : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
formFieldLabel =
    FormField_.label


{-| See [`M3e.Element.FormField.prefix`](M3e.Element.FormField#prefix).
-}
formFieldPrefix : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
formFieldPrefix =
    FormField_.prefix


{-| See [`M3e.Element.FormField.prefixText`](M3e.Element.FormField#prefixText).
-}
formFieldPrefixText : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
formFieldPrefixText =
    FormField_.prefixText


{-| See [`M3e.Element.FormField.suffix`](M3e.Element.FormField#suffix).
-}
formFieldSuffix : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
formFieldSuffix =
    FormField_.suffix


{-| See [`M3e.Element.FormField.suffixText`](M3e.Element.FormField#suffixText).
-}
formFieldSuffixText : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
formFieldSuffixText =
    FormField_.suffixText


{-| See [`M3e.Element.FormField.child`](M3e.Element.FormField#child).
-}
formFieldChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
formFieldChild =
    FormField_.child
