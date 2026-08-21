module Sl.Build.Range exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withClass, withDisabled, withForm, withHelpText, withId, withLabel, withMax, withMin, withName, withOnBlur, withOnChange, withOnFocus, withOnInput, withOnInvalid, withSlot, withStep, withStyle, withTitle, withTooltip, withValue
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withClass, withDisabled, withForm, withHelpText, withId, withLabel, withMax, withMin, withName, withOnBlur, withOnChange, withOnFocus, withOnInput, withOnInvalid, withSlot, withStep, withStyle, withTitle, withTooltip, withValue

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Element.Range as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.AttrCaps


{-| -}
type alias SlotCaps =
    {}


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-range" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
withClass : String -> Builder { a | class : Available } slotCaps msg kind -> Builder { a | class : Used } slotCaps msg kind
withClass value_ =
    B.withAttribute (A.class value_)


{-| -}
withId : String -> Builder { a | id : Available } slotCaps msg kind -> Builder { a | id : Used } slotCaps msg kind
withId value_ =
    B.withAttribute (A.id value_)


{-| -}
withSlot : String -> Builder { a | slot : Available } slotCaps msg kind -> Builder { a | slot : Used } slotCaps msg kind
withSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
withStyle : String -> String -> Builder { a | style : Available } slotCaps msg kind -> Builder { a | style : Used } slotCaps msg kind
withStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withForm : String -> Builder { a | form : Available } slotCaps msg kind -> Builder { a | form : Used } slotCaps msg kind
withForm value_ =
    B.withAttribute (A.form value_)


{-| -}
withHelpText : String -> Builder { a | helpText : Available } slotCaps msg kind -> Builder { a | helpText : Used } slotCaps msg kind
withHelpText value_ =
    B.withAttribute (A.helpText value_)


{-| -}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)


{-| -}
withMax : Float -> Builder { a | max : Available } slotCaps msg kind -> Builder { a | max : Used } slotCaps msg kind
withMax value_ =
    B.withAttribute (Ir.attribute "max" (String.fromFloat value_))


{-| -}
withMin : Float -> Builder { a | min : Available } slotCaps msg kind -> Builder { a | min : Used } slotCaps msg kind
withMin value_ =
    B.withAttribute (Ir.attribute "min" (String.fromFloat value_))


{-| -}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (A.name value_)


{-| -}
withStep : Float -> Builder { a | step : Available } slotCaps msg kind -> Builder { a | step : Used } slotCaps msg kind
withStep value_ =
    B.withAttribute (Ir.attribute "step" (String.fromFloat value_))


{-| -}
withTitle : String -> Builder { a | title : Available } slotCaps msg kind -> Builder { a | title : Used } slotCaps msg kind
withTitle value_ =
    B.withAttribute (A.title value_)


{-| -}
withTooltip : Value Component.Tooltip -> Builder { a | tooltip : Available } slotCaps msg kind -> Builder { a | tooltip : Used } slotCaps msg kind
withTooltip value_ =
    B.withAttribute (Component.tooltip value_)


{-| -}
withValue : Float -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (Ir.property "value" (Json.Encode.float value_))


{-| -}
withOnBlur : msg -> Builder { a | onBlur : Available } slotCaps msg kind -> Builder { a | onBlur : Used } slotCaps msg kind
withOnBlur value_ =
    B.withAttribute (Ev.onBlur value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnFocus : msg -> Builder { a | onFocus : Available } slotCaps msg kind -> Builder { a | onFocus : Used } slotCaps msg kind
withOnFocus value_ =
    B.withAttribute (Ev.onFocus value_)


{-| -}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
withOnInvalid : msg -> Builder { a | onInvalid : Available } slotCaps msg kind -> Builder { a | onInvalid : Used } slotCaps msg kind
withOnInvalid value_ =
    B.withAttribute (Ev.onInvalid value_)
