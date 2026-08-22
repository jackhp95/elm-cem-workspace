module Sl.Component.Rating exposing (RatingIs, RatingAttrs, RatingBuilder, RatingAttrCaps, RatingSlotCaps, RatingChildAdmittedBy, rating, ratingDisabled, ratingGetsymbol, ratingLabel, ratingMax, ratingPrecision, ratingReadonly, ratingValue, ratingDefaultValue, ratingOnChange, ratingOnHover)

{-| The **Rating** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Rating`](Sl.Element.Rating) as `rating`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs RatingIs, RatingAttrs, RatingBuilder, RatingAttrCaps, RatingSlotCaps, RatingChildAdmittedBy, rating, ratingDisabled, ratingGetsymbol, ratingLabel, ratingMax, ratingPrecision, ratingReadonly, ratingValue, ratingDefaultValue, ratingOnChange, ratingOnHover

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.Rating as Rating_


{-| The `rating` element of this family — delegates to [`Sl.Element.Rating.component`](Sl.Element.Rating#component).
-}
rating :
    List (Attr RatingAttrs msg)
    -> List (Element childAccepts (RatingChildAdmittedBy childAdm) msg)
    -> Element (RatingIs s) admittedBy msg
rating =
    Rating_.component


{-| See [`Sl.Element.Rating.Is`](Sl.Element.Rating#Is).
-}
type alias RatingIs s =
    Rating_.Is s


{-| See [`Sl.Element.Rating.Attrs`](Sl.Element.Rating#Attrs).
-}
type alias RatingAttrs =
    Rating_.Attrs


{-| See [`Sl.Element.Rating.Builder`](Sl.Element.Rating#Builder).
-}
type alias RatingBuilder attrCaps slotCaps msg kind =
    Rating_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Rating.AttrCaps`](Sl.Element.Rating#AttrCaps).
-}
type alias RatingAttrCaps =
    Rating_.AttrCaps


{-| See [`Sl.Element.Rating.SlotCaps`](Sl.Element.Rating#SlotCaps).
-}
type alias RatingSlotCaps =
    Rating_.SlotCaps


{-| See [`Sl.Element.Rating.ChildAdmittedBy`](Sl.Element.Rating#ChildAdmittedBy).
-}
type alias RatingChildAdmittedBy childAdm =
    Rating_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Rating.disabled`](Sl.Element.Rating#disabled).
-}
ratingDisabled : Bool -> Attr { c | disabled : Supported } msg
ratingDisabled =
    Rating_.disabled


{-| See [`Sl.Element.Rating.getsymbol`](Sl.Element.Rating#getsymbol).
-}
ratingGetsymbol : String -> Attr { c | getsymbol : Supported } msg
ratingGetsymbol =
    Rating_.getsymbol


{-| See [`Sl.Element.Rating.label`](Sl.Element.Rating#label).
-}
ratingLabel : String -> Attr { c | label : Supported } msg
ratingLabel =
    Rating_.label


{-| See [`Sl.Element.Rating.max`](Sl.Element.Rating#max).
-}
ratingMax : Float -> Attr { c | max : Supported } msg
ratingMax =
    Rating_.max


{-| See [`Sl.Element.Rating.precision`](Sl.Element.Rating#precision).
-}
ratingPrecision : Float -> Attr { c | precision : Supported } msg
ratingPrecision =
    Rating_.precision


{-| See [`Sl.Element.Rating.readonly`](Sl.Element.Rating#readonly).
-}
ratingReadonly : Bool -> Attr { c | readonly : Supported } msg
ratingReadonly =
    Rating_.readonly


{-| See [`Sl.Element.Rating.value`](Sl.Element.Rating#value).
-}
ratingValue : Float -> Attr { c | value : Supported } msg
ratingValue =
    Rating_.value


{-| See [`Sl.Element.Rating.defaultValue`](Sl.Element.Rating#defaultValue).
-}
ratingDefaultValue : Float -> Attr { c | value : Supported } msg
ratingDefaultValue =
    Rating_.defaultValue


{-| See [`Sl.Element.Rating.onChange`](Sl.Element.Rating#onChange).
-}
ratingOnChange : msg -> Attr { c | onChange : Supported } msg
ratingOnChange =
    Rating_.onChange


{-| See [`Sl.Element.Rating.onHover`](Sl.Element.Rating#onHover).
-}
ratingOnHover : msg -> Attr { c | onHover : Supported } msg
ratingOnHover =
    Rating_.onHover
