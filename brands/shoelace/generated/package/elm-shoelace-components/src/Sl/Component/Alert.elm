module Sl.Component.Alert exposing (AlertIs, AlertAttrs, AlertBuilder, AlertAttrCaps, AlertSlotCaps, AlertChildAdmittedBy, AlertCountdown, AlertVariant, alert, alertCountdown, alertVariant, alertClosable, alertDuration, alertOpen, alertOnShow, alertOnAfterShow, alertOnHide, alertOnAfterHide)

{-| The **Alert** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Alert`](Sl.Element.Alert) as `alert`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs AlertIs, AlertAttrs, AlertBuilder, AlertAttrCaps, AlertSlotCaps, AlertChildAdmittedBy, AlertCountdown, AlertVariant, alert, alertCountdown, alertVariant, alertClosable, alertDuration, alertOpen, alertOnShow, alertOnAfterShow, alertOnHide, alertOnAfterHide

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Alert as Alert_


{-| The `alert` element of this family — delegates to [`Sl.Element.Alert.component`](Sl.Element.Alert#component).
-}
alert :
    List (Attr AlertAttrs msg)
    -> List (Element childAccepts (AlertChildAdmittedBy childAdm) msg)
    -> Element (AlertIs s) admittedBy msg
alert =
    Alert_.component


{-| See [`Sl.Element.Alert.Is`](Sl.Element.Alert#Is).
-}
type alias AlertIs s =
    Alert_.Is s


{-| See [`Sl.Element.Alert.Attrs`](Sl.Element.Alert#Attrs).
-}
type alias AlertAttrs =
    Alert_.Attrs


{-| See [`Sl.Element.Alert.Builder`](Sl.Element.Alert#Builder).
-}
type alias AlertBuilder attrCaps slotCaps msg kind =
    Alert_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Alert.AttrCaps`](Sl.Element.Alert#AttrCaps).
-}
type alias AlertAttrCaps =
    Alert_.AttrCaps


{-| See [`Sl.Element.Alert.SlotCaps`](Sl.Element.Alert#SlotCaps).
-}
type alias AlertSlotCaps =
    Alert_.SlotCaps


{-| See [`Sl.Element.Alert.ChildAdmittedBy`](Sl.Element.Alert#ChildAdmittedBy).
-}
type alias AlertChildAdmittedBy childAdm =
    Alert_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Alert.Countdown`](Sl.Element.Alert#Countdown).
-}
type alias AlertCountdown =
    Alert_.Countdown


{-| See [`Sl.Element.Alert.countdown`](Sl.Element.Alert#countdown).
-}
alertCountdown : Value AlertCountdown -> Attr { c | countdown : Supported } msg
alertCountdown =
    Alert_.countdown


{-| See [`Sl.Element.Alert.Variant`](Sl.Element.Alert#Variant).
-}
type alias AlertVariant =
    Alert_.Variant


{-| See [`Sl.Element.Alert.variant`](Sl.Element.Alert#variant).
-}
alertVariant : Value AlertVariant -> Attr { c | variant : Supported } msg
alertVariant =
    Alert_.variant


{-| See [`Sl.Element.Alert.closable`](Sl.Element.Alert#closable).
-}
alertClosable : Bool -> Attr { c | closable : Supported } msg
alertClosable =
    Alert_.closable


{-| See [`Sl.Element.Alert.duration`](Sl.Element.Alert#duration).
-}
alertDuration : Float -> Attr { c | duration : Supported } msg
alertDuration =
    Alert_.duration


{-| See [`Sl.Element.Alert.open`](Sl.Element.Alert#open).
-}
alertOpen : Bool -> Attr { c | open : Supported } msg
alertOpen =
    Alert_.open


{-| See [`Sl.Element.Alert.onShow`](Sl.Element.Alert#onShow).
-}
alertOnShow : msg -> Attr { c | onShow : Supported } msg
alertOnShow =
    Alert_.onShow


{-| See [`Sl.Element.Alert.onAfterShow`](Sl.Element.Alert#onAfterShow).
-}
alertOnAfterShow : msg -> Attr { c | onAfterShow : Supported } msg
alertOnAfterShow =
    Alert_.onAfterShow


{-| See [`Sl.Element.Alert.onHide`](Sl.Element.Alert#onHide).
-}
alertOnHide : msg -> Attr { c | onHide : Supported } msg
alertOnHide =
    Alert_.onHide


{-| See [`Sl.Element.Alert.onAfterHide`](Sl.Element.Alert#onAfterHide).
-}
alertOnAfterHide : msg -> Attr { c | onAfterHide : Supported } msg
alertOnAfterHide =
    Alert_.onAfterHide
