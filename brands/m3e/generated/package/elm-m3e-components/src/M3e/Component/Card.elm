module M3e.Component.Card exposing (CardIs, CardAttrs, CardBuilder, CardAttrCaps, CardSlotCaps, CardChildAdmittedBy, CardOrientation, CardType, CardVariant, card, cardOrientation, cardType_, cardVariant, cardActionable, cardDisabled, cardDisabledInteractive, cardDownload, cardHref, cardInline, cardName, cardRel, cardTarget, cardValue, cardDefaultValue, cardOnClick, cardActions, cardContent, cardFooter, cardHeader, cardChild)

{-| The **Card** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Card`](M3e.Element.Card) as `card`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs CardIs, CardAttrs, CardBuilder, CardAttrCaps, CardSlotCaps, CardChildAdmittedBy, CardOrientation, CardType, CardVariant, card, cardOrientation, cardType_, cardVariant, cardActionable, cardDisabled, cardDisabledInteractive, cardDownload, cardHref, cardInline, cardName, cardRel, cardTarget, cardValue, cardDefaultValue, cardOnClick, cardActions, cardContent, cardFooter, cardHeader, cardChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Card as Card_


{-| The `card` element of this family — delegates to [`M3e.Element.Card.component`](M3e.Element.Card#component).
-}
card :
    List (Attr CardAttrs msg)
    -> List (Element childAccepts (CardChildAdmittedBy childAdm) msg)
    -> Element (CardIs s) admittedBy msg
card =
    Card_.component


{-| See [`M3e.Element.Card.Is`](M3e.Element.Card#Is).
-}
type alias CardIs s =
    Card_.Is s


{-| See [`M3e.Element.Card.Attrs`](M3e.Element.Card#Attrs).
-}
type alias CardAttrs =
    Card_.Attrs


{-| See [`M3e.Element.Card.Builder`](M3e.Element.Card#Builder).
-}
type alias CardBuilder attrCaps slotCaps msg kind =
    Card_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Card.AttrCaps`](M3e.Element.Card#AttrCaps).
-}
type alias CardAttrCaps =
    Card_.AttrCaps


{-| See [`M3e.Element.Card.SlotCaps`](M3e.Element.Card#SlotCaps).
-}
type alias CardSlotCaps =
    Card_.SlotCaps


{-| See [`M3e.Element.Card.ChildAdmittedBy`](M3e.Element.Card#ChildAdmittedBy).
-}
type alias CardChildAdmittedBy childAdm =
    Card_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Card.Orientation`](M3e.Element.Card#Orientation).
-}
type alias CardOrientation =
    Card_.Orientation


{-| See [`M3e.Element.Card.orientation`](M3e.Element.Card#orientation).
-}
cardOrientation : Value CardOrientation -> Attr { c | orientation : Supported } msg
cardOrientation =
    Card_.orientation


{-| See [`M3e.Element.Card.Type`](M3e.Element.Card#Type).
-}
type alias CardType =
    Card_.Type


{-| See [`M3e.Element.Card.type_`](M3e.Element.Card#type_).
-}
cardType_ : Value CardType -> Attr { c | type_ : Supported } msg
cardType_ =
    Card_.type_


{-| See [`M3e.Element.Card.Variant`](M3e.Element.Card#Variant).
-}
type alias CardVariant =
    Card_.Variant


{-| See [`M3e.Element.Card.variant`](M3e.Element.Card#variant).
-}
cardVariant : Value CardVariant -> Attr { c | variant : Supported } msg
cardVariant =
    Card_.variant


{-| See [`M3e.Element.Card.actionable`](M3e.Element.Card#actionable).
-}
cardActionable : Bool -> Attr { c | actionable : Supported } msg
cardActionable =
    Card_.actionable


{-| See [`M3e.Element.Card.disabled`](M3e.Element.Card#disabled).
-}
cardDisabled : Bool -> Attr { c | disabled : Supported } msg
cardDisabled =
    Card_.disabled


{-| See [`M3e.Element.Card.disabledInteractive`](M3e.Element.Card#disabledInteractive).
-}
cardDisabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
cardDisabledInteractive =
    Card_.disabledInteractive


{-| See [`M3e.Element.Card.download`](M3e.Element.Card#download).
-}
cardDownload : String -> Attr { c | download : Supported } msg
cardDownload =
    Card_.download


{-| See [`M3e.Element.Card.href`](M3e.Element.Card#href).
-}
cardHref : String -> Attr { c | href : Supported } msg
cardHref =
    Card_.href


{-| See [`M3e.Element.Card.inline`](M3e.Element.Card#inline).
-}
cardInline : Bool -> Attr { c | inline : Supported } msg
cardInline =
    Card_.inline


{-| See [`M3e.Element.Card.name`](M3e.Element.Card#name).
-}
cardName : String -> Attr { c | name : Supported } msg
cardName =
    Card_.name


{-| See [`M3e.Element.Card.rel`](M3e.Element.Card#rel).
-}
cardRel : String -> Attr { c | rel : Supported } msg
cardRel =
    Card_.rel


{-| See [`M3e.Element.Card.target`](M3e.Element.Card#target).
-}
cardTarget : String -> Attr { c | target : Supported } msg
cardTarget =
    Card_.target


{-| See [`M3e.Element.Card.value`](M3e.Element.Card#value).
-}
cardValue : String -> Attr { c | value : Supported } msg
cardValue =
    Card_.value


{-| See [`M3e.Element.Card.defaultValue`](M3e.Element.Card#defaultValue).
-}
cardDefaultValue : String -> Attr { c | value : Supported } msg
cardDefaultValue =
    Card_.defaultValue


{-| See [`M3e.Element.Card.onClick`](M3e.Element.Card#onClick).
-}
cardOnClick : msg -> Attr { c | onClick : Supported } msg
cardOnClick =
    Card_.onClick


{-| See [`M3e.Element.Card.actions`](M3e.Element.Card#actions).
-}
cardActions : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
cardActions =
    Card_.actions


{-| See [`M3e.Element.Card.content`](M3e.Element.Card#content).
-}
cardContent : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
cardContent =
    Card_.content


{-| See [`M3e.Element.Card.footer`](M3e.Element.Card#footer).
-}
cardFooter : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
cardFooter =
    Card_.footer


{-| See [`M3e.Element.Card.header`](M3e.Element.Card#header).
-}
cardHeader : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
cardHeader =
    Card_.header


{-| See [`M3e.Element.Card.child`](M3e.Element.Card#child).
-}
cardChild : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
cardChild =
    Card_.child
