module Sl.Build.Input exposing (Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withAutocapitalize, withAutocomplete, withAutocorrect, withAutofocus, withClass, withClearable, withDisabled, withEnterkeyhint, withFilled, withForm, withHelpText, withId, withInputmode, withLabel, withMax, withMaxlength, withMin, withMinlength, withName, withNoSpinButtons, withOnBlur, withOnChange, withOnClear, withOnFocus, withOnInput, withOnInvalid, withPasswordToggle, withPasswordVisible, withPattern, withPill, withPlaceholder, withReadonly, withRequired, withSize, withSlot, withSpellcheck, withStep, withStyle, withTitle, withType, withValue)

{-| The **Input** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `Sl.Component.Input`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `Sl.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy, build, toElement, withAutocapitalize, withAutocomplete, withAutocorrect, withAutofocus, withClass, withClearable, withDisabled, withEnterkeyhint, withFilled, withForm, withHelpText, withId, withInputmode, withLabel, withMax, withMaxlength, withMin, withMinlength, withName, withNoSpinButtons, withOnBlur, withOnChange, withOnClear, withOnFocus, withOnInput, withOnInvalid, withPasswordToggle, withPasswordVisible, withPattern, withPill, withPlaceholder, withReadonly, withRequired, withSize, withSlot, withSpellcheck, withStep, withStyle, withTitle, withType, withValue

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Attributes as A
import Sl.Component.Input as Component
import Sl.Events as Ev
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)
import Sl.Values


{-| -}
type alias Is s =
    Component.InputIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.InputBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.InputAttrCaps


{-| -}
type alias SlotCaps =
    Component.InputSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.InputChildAdmittedBy childAdm


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-input" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.InputIs kind) admittedBy msg
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
withAutocapitalize : Value Component.InputAutocapitalize -> Builder { a | autocapitalize : Available } slotCaps msg kind -> Builder { a | autocapitalize : Used } slotCaps msg kind
withAutocapitalize value_ =
    B.withAttribute (Component.inputAutocapitalize value_)


{-| -}
withAutocomplete : String -> Builder { a | autocomplete : Available } slotCaps msg kind -> Builder { a | autocomplete : Used } slotCaps msg kind
withAutocomplete value_ =
    B.withAttribute (A.autocomplete value_)


{-| -}
withAutocorrect : Value Component.InputAutocorrect -> Builder { a | autocorrect : Available } slotCaps msg kind -> Builder { a | autocorrect : Used } slotCaps msg kind
withAutocorrect value_ =
    B.withAttribute (Component.inputAutocorrect value_)


{-| -}
withAutofocus : Bool -> Builder { a | autofocus : Available } slotCaps msg kind -> Builder { a | autofocus : Used } slotCaps msg kind
withAutofocus value_ =
    B.withAttribute (A.autofocus value_)


{-| -}
withClearable : Bool -> Builder { a | clearable : Available } slotCaps msg kind -> Builder { a | clearable : Used } slotCaps msg kind
withClearable value_ =
    B.withAttribute (A.clearable value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withEnterkeyhint : Value Component.InputEnterkeyhint -> Builder { a | enterkeyhint : Available } slotCaps msg kind -> Builder { a | enterkeyhint : Used } slotCaps msg kind
withEnterkeyhint value_ =
    B.withAttribute (Component.inputEnterkeyhint value_)


{-| -}
withFilled : Bool -> Builder { a | filled : Available } slotCaps msg kind -> Builder { a | filled : Used } slotCaps msg kind
withFilled value_ =
    B.withAttribute (A.filled value_)


{-| -}
withForm : String -> Builder { a | form : Available } slotCaps msg kind -> Builder { a | form : Used } slotCaps msg kind
withForm value_ =
    B.withAttribute (A.form value_)


{-| -}
withHelpText : String -> Builder { a | helpText : Available } slotCaps msg kind -> Builder { a | helpText : Used } slotCaps msg kind
withHelpText value_ =
    B.withAttribute (A.helpText value_)


{-| -}
withInputmode : Value Component.InputInputmode -> Builder { a | inputmode : Available } slotCaps msg kind -> Builder { a | inputmode : Used } slotCaps msg kind
withInputmode value_ =
    B.withAttribute (Component.inputInputmode value_)


{-| -}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)


{-| -}
withMax : String -> Builder { a | max : Available } slotCaps msg kind -> Builder { a | max : Used } slotCaps msg kind
withMax value_ =
    B.withAttribute (A.max value_)


{-| -}
withMaxlength : Float -> Builder { a | maxlength : Available } slotCaps msg kind -> Builder { a | maxlength : Used } slotCaps msg kind
withMaxlength value_ =
    B.withAttribute (A.maxlength value_)


{-| -}
withMin : String -> Builder { a | min : Available } slotCaps msg kind -> Builder { a | min : Used } slotCaps msg kind
withMin value_ =
    B.withAttribute (A.min value_)


{-| -}
withMinlength : Float -> Builder { a | minlength : Available } slotCaps msg kind -> Builder { a | minlength : Used } slotCaps msg kind
withMinlength value_ =
    B.withAttribute (A.minlength value_)


{-| -}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (A.name value_)


{-| -}
withNoSpinButtons : Bool -> Builder { a | noSpinButtons : Available } slotCaps msg kind -> Builder { a | noSpinButtons : Used } slotCaps msg kind
withNoSpinButtons value_ =
    B.withAttribute (A.noSpinButtons value_)


{-| -}
withPasswordToggle : Bool -> Builder { a | passwordToggle : Available } slotCaps msg kind -> Builder { a | passwordToggle : Used } slotCaps msg kind
withPasswordToggle value_ =
    B.withAttribute (A.passwordToggle value_)


{-| -}
withPasswordVisible : Bool -> Builder { a | passwordVisible : Available } slotCaps msg kind -> Builder { a | passwordVisible : Used } slotCaps msg kind
withPasswordVisible value_ =
    B.withAttribute (A.passwordVisible value_)


{-| -}
withPattern : String -> Builder { a | pattern : Available } slotCaps msg kind -> Builder { a | pattern : Used } slotCaps msg kind
withPattern value_ =
    B.withAttribute (A.pattern value_)


{-| -}
withPill : Bool -> Builder { a | pill : Available } slotCaps msg kind -> Builder { a | pill : Used } slotCaps msg kind
withPill value_ =
    B.withAttribute (A.pill value_)


{-| -}
withPlaceholder : String -> Builder { a | placeholder : Available } slotCaps msg kind -> Builder { a | placeholder : Used } slotCaps msg kind
withPlaceholder value_ =
    B.withAttribute (A.placeholder value_)


{-| -}
withReadonly : Bool -> Builder { a | readonly : Available } slotCaps msg kind -> Builder { a | readonly : Used } slotCaps msg kind
withReadonly value_ =
    B.withAttribute (A.readonly value_)


{-| -}
withRequired : Bool -> Builder { a | required : Available } slotCaps msg kind -> Builder { a | required : Used } slotCaps msg kind
withRequired value_ =
    B.withAttribute (A.required value_)


{-| -}
withSize : Value Component.InputSize -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.inputSize value_)


{-| -}
withSpellcheck : Bool -> Builder { a | spellcheck : Available } slotCaps msg kind -> Builder { a | spellcheck : Used } slotCaps msg kind
withSpellcheck value_ =
    B.withAttribute (A.spellcheck value_)


{-| -}
withStep : String -> Builder { a | step : Available } slotCaps msg kind -> Builder { a | step : Used } slotCaps msg kind
withStep value_ =
    B.withAttribute (A.step value_)


{-| -}
withTitle : String -> Builder { a | title : Available } slotCaps msg kind -> Builder { a | title : Used } slotCaps msg kind
withTitle value_ =
    B.withAttribute (A.title value_)


{-| -}
withType : Value Component.InputType -> Builder { a | type_ : Available } slotCaps msg kind -> Builder { a | type_ : Used } slotCaps msg kind
withType value_ =
    B.withAttribute (Component.inputType_ value_)


{-| -}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)


{-| -}
withOnBlur : msg -> Builder { a | onBlur : Available } slotCaps msg kind -> Builder { a | onBlur : Used } slotCaps msg kind
withOnBlur value_ =
    B.withAttribute (Ev.onBlur value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnClear : msg -> Builder { a | onClear : Available } slotCaps msg kind -> Builder { a | onClear : Used } slotCaps msg kind
withOnClear value_ =
    B.withAttribute (Ev.onClear value_)


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
