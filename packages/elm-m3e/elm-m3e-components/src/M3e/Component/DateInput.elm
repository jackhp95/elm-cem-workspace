module M3e.Component.DateInput exposing
    ( view
    , Is, Attrs, ChildAdmittedBy
    , TimeFormat, timeFormat, Type, type_
    , dayLabel, disabled, hourLabel, maxDate, maxTime, minDate, minTime, minuteLabel, monthLabel, name, periodLabel, readonly, required, secondLabel, showSeconds, validationmessages, value, yearLabel, defaultValue, onChange, onBeforeinput, onInput, onInvalid
    )

{-| The `m3e-date-input` component — strict per-component surface.

A segmented input for entering date and/or time values using a keyboard.

@docs view
@docs Is, Attrs, ChildAdmittedBy
@docs TimeFormat, timeFormat, Type, type_
@docs dayLabel, disabled, hourLabel, maxDate, maxTime, minDate, minTime, minuteLabel, monthLabel, name, periodLabel, readonly, required, secondLabel, showSeconds, validationmessages, value, yearLabel, defaultValue, onChange, onBeforeinput, onInput, onInvalid

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.DateInput
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-date-input` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.DateInput.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.DateInput.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.DateInput.ChildAdmittedBy childAdm


{-| The `timeFormat` values valid on this component (compile-tight narrowing).
-}
type alias TimeFormat =
    M3e.Internal.Types.DateInput.TimeFormat


{-| The `type_` values valid on this component (compile-tight narrowing).
-}
type alias Type =
    M3e.Internal.Types.DateInput.Type


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.dateInput


{-| Format used when editing time values. (default: `"12"`)
-}
timeFormat : Value TimeFormat -> Attr { c | timeFormat : Supported } msg
timeFormat value_ =
    Ir.attribute "time-format" (Val.toString value_)


{-| The interaction mode for editing date and/or time values. (default: `"date"`)
-}
type_ : Value Type -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" (Val.toString value_)


{-| See `M3e.Attributes.dayLabel`.
-}
dayLabel : String -> Attr { c | dayLabel : Supported } msg
dayLabel =
    A.dayLabel


{-| See `M3e.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `M3e.Attributes.hourLabel`.
-}
hourLabel : String -> Attr { c | hourLabel : Supported } msg
hourLabel =
    A.hourLabel


{-| See `M3e.Attributes.maxDate`.
-}
maxDate : String -> Attr { c | maxDate : Supported } msg
maxDate =
    A.maxDate


{-| See `M3e.Attributes.maxTime`.
-}
maxTime : String -> Attr { c | maxTime : Supported } msg
maxTime =
    A.maxTime


{-| See `M3e.Attributes.minDate`.
-}
minDate : String -> Attr { c | minDate : Supported } msg
minDate =
    A.minDate


{-| See `M3e.Attributes.minTime`.
-}
minTime : String -> Attr { c | minTime : Supported } msg
minTime =
    A.minTime


{-| See `M3e.Attributes.minuteLabel`.
-}
minuteLabel : String -> Attr { c | minuteLabel : Supported } msg
minuteLabel =
    A.minuteLabel


{-| See `M3e.Attributes.monthLabel`.
-}
monthLabel : String -> Attr { c | monthLabel : Supported } msg
monthLabel =
    A.monthLabel


{-| The name that identifies the element when submitting the associated form.
-}
name : String -> Attr { c | name : Supported } msg
name value_ =
    Ir.attribute "name" value_


{-| See `M3e.Attributes.periodLabel`.
-}
periodLabel : String -> Attr { c | periodLabel : Supported } msg
periodLabel =
    A.periodLabel


{-| See `M3e.Attributes.readonly`.
-}
readonly : Bool -> Attr { c | readonly : Supported } msg
readonly =
    A.readonly


{-| See `M3e.Attributes.required`.
-}
required : Bool -> Attr { c | required : Supported } msg
required =
    A.required


{-| See `M3e.Attributes.secondLabel`.
-}
secondLabel : String -> Attr { c | secondLabel : Supported } msg
secondLabel =
    A.secondLabel


{-| See `M3e.Attributes.showSeconds`.
-}
showSeconds : Bool -> Attr { c | showSeconds : Supported } msg
showSeconds =
    A.showSeconds


{-| See `M3e.Attributes.validationmessages`.
-}
validationmessages : String -> Attr { c | validationmessages : Supported } msg
validationmessages =
    A.validationmessages


{-| See `M3e.Attributes.value`.
-}
value : String -> Attr { c | value : Supported } msg
value =
    A.value


{-| See `M3e.Attributes.yearLabel`.
-}
yearLabel : String -> Attr { c | yearLabel : Supported } msg
yearLabel =
    A.yearLabel


{-| See `M3e.Attributes.defaultValue`.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    A.defaultValue


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| See `M3e.Events.onBeforeinput`.
-}
onBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
onBeforeinput =
    Ev.onBeforeinput


{-| See `M3e.Events.onInput`.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput =
    Ev.onInput


{-| See `M3e.Events.onInvalid`.
-}
onInvalid : msg -> Attr { c | onInvalid : Supported } msg
onInvalid =
    Ev.onInvalid
