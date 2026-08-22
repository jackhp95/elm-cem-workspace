module Sl.Component.CopyButton exposing (CopyButtonIs, CopyButtonAttrs, CopyButtonBuilder, CopyButtonAttrCaps, CopyButtonSlotCaps, CopyButtonChildAdmittedBy, CopyButtonTooltipPlacement, copyButton, copyButtonTooltipPlacement, copyButtonCopyLabel, copyButtonDisabled, copyButtonErrorLabel, copyButtonFeedbackDuration, copyButtonFrom, copyButtonHoist, copyButtonSuccessLabel, copyButtonValue, copyButtonDefaultValue, copyButtonOnCopy, copyButtonOnError)

{-| The **CopyButton** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.CopyButton`](Sl.Element.CopyButton) as `copyButton`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs CopyButtonIs, CopyButtonAttrs, CopyButtonBuilder, CopyButtonAttrCaps, CopyButtonSlotCaps, CopyButtonChildAdmittedBy, CopyButtonTooltipPlacement, copyButton, copyButtonTooltipPlacement, copyButtonCopyLabel, copyButtonDisabled, copyButtonErrorLabel, copyButtonFeedbackDuration, copyButtonFrom, copyButtonHoist, copyButtonSuccessLabel, copyButtonValue, copyButtonDefaultValue, copyButtonOnCopy, copyButtonOnError

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.CopyButton as CopyButton_


{-| The `copyButton` element of this family — delegates to [`Sl.Element.CopyButton.component`](Sl.Element.CopyButton#component).
-}
copyButton :
    List (Attr CopyButtonAttrs msg)
    -> List (Element childAccepts (CopyButtonChildAdmittedBy childAdm) msg)
    -> Element (CopyButtonIs s) admittedBy msg
copyButton =
    CopyButton_.component


{-| See [`Sl.Element.CopyButton.Is`](Sl.Element.CopyButton#Is).
-}
type alias CopyButtonIs s =
    CopyButton_.Is s


{-| See [`Sl.Element.CopyButton.Attrs`](Sl.Element.CopyButton#Attrs).
-}
type alias CopyButtonAttrs =
    CopyButton_.Attrs


{-| See [`Sl.Element.CopyButton.Builder`](Sl.Element.CopyButton#Builder).
-}
type alias CopyButtonBuilder attrCaps slotCaps msg kind =
    CopyButton_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.CopyButton.AttrCaps`](Sl.Element.CopyButton#AttrCaps).
-}
type alias CopyButtonAttrCaps =
    CopyButton_.AttrCaps


{-| See [`Sl.Element.CopyButton.SlotCaps`](Sl.Element.CopyButton#SlotCaps).
-}
type alias CopyButtonSlotCaps =
    CopyButton_.SlotCaps


{-| See [`Sl.Element.CopyButton.ChildAdmittedBy`](Sl.Element.CopyButton#ChildAdmittedBy).
-}
type alias CopyButtonChildAdmittedBy childAdm =
    CopyButton_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.CopyButton.TooltipPlacement`](Sl.Element.CopyButton#TooltipPlacement).
-}
type alias CopyButtonTooltipPlacement =
    CopyButton_.TooltipPlacement


{-| See [`Sl.Element.CopyButton.tooltipPlacement`](Sl.Element.CopyButton#tooltipPlacement).
-}
copyButtonTooltipPlacement : Value CopyButtonTooltipPlacement -> Attr { c | tooltipPlacement : Supported } msg
copyButtonTooltipPlacement =
    CopyButton_.tooltipPlacement


{-| See [`Sl.Element.CopyButton.copyLabel`](Sl.Element.CopyButton#copyLabel).
-}
copyButtonCopyLabel : String -> Attr { c | copyLabel : Supported } msg
copyButtonCopyLabel =
    CopyButton_.copyLabel


{-| See [`Sl.Element.CopyButton.disabled`](Sl.Element.CopyButton#disabled).
-}
copyButtonDisabled : Bool -> Attr { c | disabled : Supported } msg
copyButtonDisabled =
    CopyButton_.disabled


{-| See [`Sl.Element.CopyButton.errorLabel`](Sl.Element.CopyButton#errorLabel).
-}
copyButtonErrorLabel : String -> Attr { c | errorLabel : Supported } msg
copyButtonErrorLabel =
    CopyButton_.errorLabel


{-| See [`Sl.Element.CopyButton.feedbackDuration`](Sl.Element.CopyButton#feedbackDuration).
-}
copyButtonFeedbackDuration : Float -> Attr { c | feedbackDuration : Supported } msg
copyButtonFeedbackDuration =
    CopyButton_.feedbackDuration


{-| See [`Sl.Element.CopyButton.from`](Sl.Element.CopyButton#from).
-}
copyButtonFrom : String -> Attr { c | from : Supported } msg
copyButtonFrom =
    CopyButton_.from


{-| See [`Sl.Element.CopyButton.hoist`](Sl.Element.CopyButton#hoist).
-}
copyButtonHoist : Bool -> Attr { c | hoist : Supported } msg
copyButtonHoist =
    CopyButton_.hoist


{-| See [`Sl.Element.CopyButton.successLabel`](Sl.Element.CopyButton#successLabel).
-}
copyButtonSuccessLabel : String -> Attr { c | successLabel : Supported } msg
copyButtonSuccessLabel =
    CopyButton_.successLabel


{-| See [`Sl.Element.CopyButton.value`](Sl.Element.CopyButton#value).
-}
copyButtonValue : String -> Attr { c | value : Supported } msg
copyButtonValue =
    CopyButton_.value


{-| See [`Sl.Element.CopyButton.defaultValue`](Sl.Element.CopyButton#defaultValue).
-}
copyButtonDefaultValue : String -> Attr { c | value : Supported } msg
copyButtonDefaultValue =
    CopyButton_.defaultValue


{-| See [`Sl.Element.CopyButton.onCopy`](Sl.Element.CopyButton#onCopy).
-}
copyButtonOnCopy : msg -> Attr { c | onCopy : Supported } msg
copyButtonOnCopy =
    CopyButton_.onCopy


{-| See [`Sl.Element.CopyButton.onError`](Sl.Element.CopyButton#onError).
-}
copyButtonOnError : msg -> Attr { c | onError : Supported } msg
copyButtonOnError =
    CopyButton_.onError
