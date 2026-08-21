module Sl.Build.Textarea exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
    , withAutocapitalize, withAutocomplete, withAutocorrect, withAutofocus, withClass, withDisabled, withEnterkeyhint, withFilled, withForm, withHelpText, withId, withInputmode, withLabel, withMaxlength, withMinlength, withName, withOnBlur, withOnChange, withOnFocus, withOnInput, withOnInvalid, withPlaceholder, withReadonly, withRequired, withResize, withRows, withSize, withSlot, withSpellcheck, withStyle, withTitle, withValue
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ChildAdmittedBy
@docs withAutocapitalize, withAutocomplete, withAutocorrect, withAutofocus, withClass, withDisabled, withEnterkeyhint, withFilled, withForm, withHelpText, withId, withInputmode, withLabel, withMaxlength, withMinlength, withName, withOnBlur, withOnChange, withOnFocus, withOnInput, withOnInvalid, withPlaceholder, withReadonly, withRequired, withResize, withRows, withSize, withSlot, withSpellcheck, withStyle, withTitle, withValue

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Json.Encode
import Sl.Attributes as A
import Sl.Element.Textarea as Component
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
    B.init "sl-textarea" [] []


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
withAutocapitalize : Value Component.Autocapitalize -> Builder { a | autocapitalize : Available } slotCaps msg kind -> Builder { a | autocapitalize : Used } slotCaps msg kind
withAutocapitalize value_ =
    B.withAttribute (Component.autocapitalize value_)


{-| -}
withAutocomplete : String -> Builder { a | autocomplete : Available } slotCaps msg kind -> Builder { a | autocomplete : Used } slotCaps msg kind
withAutocomplete value_ =
    B.withAttribute (A.autocomplete value_)


{-| -}
withAutocorrect : String -> Builder { a | autocorrect : Available } slotCaps msg kind -> Builder { a | autocorrect : Used } slotCaps msg kind
withAutocorrect value_ =
    B.withAttribute (Ir.attribute "autocorrect" value_)


{-| -}
withAutofocus : Bool -> Builder { a | autofocus : Available } slotCaps msg kind -> Builder { a | autofocus : Used } slotCaps msg kind
withAutofocus value_ =
    B.withAttribute (A.autofocus value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withEnterkeyhint : Value Component.Enterkeyhint -> Builder { a | enterkeyhint : Available } slotCaps msg kind -> Builder { a | enterkeyhint : Used } slotCaps msg kind
withEnterkeyhint value_ =
    B.withAttribute (Component.enterkeyhint value_)


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
withInputmode : Value Component.Inputmode -> Builder { a | inputmode : Available } slotCaps msg kind -> Builder { a | inputmode : Used } slotCaps msg kind
withInputmode value_ =
    B.withAttribute (Component.inputmode value_)


{-| -}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)


{-| -}
withMaxlength : Float -> Builder { a | maxlength : Available } slotCaps msg kind -> Builder { a | maxlength : Used } slotCaps msg kind
withMaxlength value_ =
    B.withAttribute (A.maxlength value_)


{-| -}
withMinlength : Float -> Builder { a | minlength : Available } slotCaps msg kind -> Builder { a | minlength : Used } slotCaps msg kind
withMinlength value_ =
    B.withAttribute (A.minlength value_)


{-| -}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (A.name value_)


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
withResize : Value Component.Resize -> Builder { a | resize : Available } slotCaps msg kind -> Builder { a | resize : Used } slotCaps msg kind
withResize value_ =
    B.withAttribute (Component.resize value_)


{-| -}
withRows : Float -> Builder { a | rows : Available } slotCaps msg kind -> Builder { a | rows : Used } slotCaps msg kind
withRows value_ =
    B.withAttribute (A.rows value_)


{-| -}
withSize : Value Component.Size -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.size value_)


{-| -}
withSpellcheck : Bool -> Builder { a | spellcheck : Available } slotCaps msg kind -> Builder { a | spellcheck : Used } slotCaps msg kind
withSpellcheck value_ =
    B.withAttribute (A.spellcheck value_)


{-| -}
withTitle : String -> Builder { a | title : Available } slotCaps msg kind -> Builder { a | title : Used } slotCaps msg kind
withTitle value_ =
    B.withAttribute (A.title value_)


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
