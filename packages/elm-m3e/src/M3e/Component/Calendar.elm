module M3e.Component.Calendar exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , StartView, startView
    , date, maxDate, minDate, nextMonthLabel, nextMultiYearLabel, nextYearLabel, previousMonthLabel, previousMultiYearLabel, previousYearLabel, rangeEnd, rangeStart, startAt, onChange
    , header
    )

{-| The `m3e-calendar` component — strict per-component surface.

A calendar used to select a date.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs StartView, startView
@docs date, maxDate, minDate, nextMonthLabel, nextMultiYearLabel, nextYearLabel, previousMonthLabel, previousMultiYearLabel, previousYearLabel, rangeEnd, rangeStart, startAt, onChange
@docs header

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Decode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Calendar
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-calendar` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Calendar.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Calendar.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Calendar.ChildAdmittedBy childAdm


{-| The `startView` values valid on this component (compile-tight narrowing).
-}
type alias StartView =
    M3e.Internal.Types.Calendar.StartView


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.calendar


{-| The initial view used to select a date. (default: `"month"`)
-}
startView : Value StartView -> Attr { c | startView : Supported } msg
startView value_ =
    Ir.attribute "start-view" (Val.toString value_)


{-| See `M3e.Attributes.date`.
-}
date : String -> Attr { c | date : Supported } msg
date =
    A.date


{-| See `M3e.Attributes.maxDate`.
-}
maxDate : String -> Attr { c | maxDate : Supported } msg
maxDate =
    A.maxDate


{-| See `M3e.Attributes.minDate`.
-}
minDate : String -> Attr { c | minDate : Supported } msg
minDate =
    A.minDate


{-| See `M3e.Attributes.nextMonthLabel`.
-}
nextMonthLabel : String -> Attr { c | nextMonthLabel : Supported } msg
nextMonthLabel =
    A.nextMonthLabel


{-| See `M3e.Attributes.nextMultiYearLabel`.
-}
nextMultiYearLabel : String -> Attr { c | nextMultiYearLabel : Supported } msg
nextMultiYearLabel =
    A.nextMultiYearLabel


{-| See `M3e.Attributes.nextYearLabel`.
-}
nextYearLabel : String -> Attr { c | nextYearLabel : Supported } msg
nextYearLabel =
    A.nextYearLabel


{-| See `M3e.Attributes.previousMonthLabel`.
-}
previousMonthLabel : String -> Attr { c | previousMonthLabel : Supported } msg
previousMonthLabel =
    A.previousMonthLabel


{-| See `M3e.Attributes.previousMultiYearLabel`.
-}
previousMultiYearLabel : String -> Attr { c | previousMultiYearLabel : Supported } msg
previousMultiYearLabel =
    A.previousMultiYearLabel


{-| See `M3e.Attributes.previousYearLabel`.
-}
previousYearLabel : String -> Attr { c | previousYearLabel : Supported } msg
previousYearLabel =
    A.previousYearLabel


{-| See `M3e.Attributes.rangeEnd`.
-}
rangeEnd : String -> Attr { c | rangeEnd : Supported } msg
rangeEnd =
    A.rangeEnd


{-| See `M3e.Attributes.rangeStart`.
-}
rangeStart : String -> Attr { c | rangeStart : Supported } msg
rangeStart =
    A.rangeStart


{-| See `M3e.Attributes.startAt`.
-}
startAt : String -> Attr { c | startAt : Supported } msg
startAt =
    A.startAt


{-| Typed `change` event: decodes `target.date` as String.
-}
onChange : (String -> msg) -> Attr { c | onChange : Supported } msg
onChange toMsg =
    Ir.on "change" (Json.Decode.map toMsg (Json.Decode.at [ "target", "date" ] Json.Decode.string))


{-| Place an element into the named `header` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
header : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
header element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "header") (El.toNode element))
