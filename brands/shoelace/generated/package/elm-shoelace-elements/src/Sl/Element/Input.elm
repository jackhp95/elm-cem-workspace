module Sl.Element.Input exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Autocapitalize, autocapitalize, Autocorrect, autocorrect, Enterkeyhint, enterkeyhint, Inputmode, inputmode, Size, size, Type, type_
    , autocomplete, autofocus, clearable, disabled, filled, form, helpText, label, max, maxlength, min, minlength, name, noSpinButtons, passwordToggle, passwordVisible, pattern, pill, placeholder, readonly, required, spellcheck, step, title, value, defaultValue, onBlur, onChange, onClear, onFocus, onInput, onInvalid
    )

{-| The `sl-input` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Autocapitalize, autocapitalize, Autocorrect, autocorrect, Enterkeyhint, enterkeyhint, Inputmode, inputmode, Size, size, Type, type_
@docs autocomplete, autofocus, clearable, disabled, filled, form, helpText, label, max, maxlength, min, minlength, name, noSpinButtons, passwordToggle, passwordVisible, pattern, pill, placeholder, readonly, required, spellcheck, step, title, value, defaultValue, onBlur, onChange, onClear, onFocus, onInput, onInvalid

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Input
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-input` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Input.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Input.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Input.ChildAdmittedBy childAdm


{-| The `autocapitalize` values valid on this component (compile-tight narrowing).
-}
type alias Autocapitalize =
    Sl.Internal.Types.Input.Autocapitalize


{-| The `autocorrect` values valid on this component (compile-tight narrowing).
-}
type alias Autocorrect =
    Sl.Internal.Types.Input.Autocorrect


{-| The `enterkeyhint` values valid on this component (compile-tight narrowing).
-}
type alias Enterkeyhint =
    Sl.Internal.Types.Input.Enterkeyhint


{-| The `inputmode` values valid on this component (compile-tight narrowing).
-}
type alias Inputmode =
    Sl.Internal.Types.Input.Inputmode


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    Sl.Internal.Types.Input.Size


{-| The `type_` values valid on this component (compile-tight narrowing).
-}
type alias Type =
    Sl.Internal.Types.Input.Type


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Input.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Input.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.input


{-| Controls whether and how text input is automatically capitalized as it is entered by the user.
-}
autocapitalize : Value Autocapitalize -> Attr { c | autocapitalize : Supported } msg
autocapitalize value_ =
    Ir.attribute "autocapitalize" (Val.toString value_)


{-| Indicates whether the browser's autocorrect feature is on or off.
-}
autocorrect : Value Autocorrect -> Attr { c | autocorrect : Supported } msg
autocorrect value_ =
    Ir.attribute "autocorrect" (Val.toString value_)


{-| Used to customize the label or icon of the Enter key on virtual keyboards.
-}
enterkeyhint : Value Enterkeyhint -> Attr { c | enterkeyhint : Supported } msg
enterkeyhint value_ =
    Ir.attribute "enterkeyhint" (Val.toString value_)


{-| Tells the browser what type of data will be entered by the user, allowing it to display the appropriate virtual
keyboard on supportive devices.
-}
inputmode : Value Inputmode -> Attr { c | inputmode : Supported } msg
inputmode value_ =
    Ir.attribute "inputmode" (Val.toString value_)


{-| The input's size. (default: `'medium'`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


{-| The type of input. Works the same as a native `<input>` element, but only a subset of types are supported. Defaults
to `text`. (default: `'text'`)
-}
type_ : Value Type -> Attr { c | type_ : Supported } msg
type_ value_ =
    Ir.attribute "type" (Val.toString value_)


{-| See `Sl.Attributes.autocomplete`.
-}
autocomplete : String -> Attr { c | autocomplete : Supported } msg
autocomplete =
    A.autocomplete


{-| See `Sl.Attributes.autofocus`.
-}
autofocus : Bool -> Attr { c | autofocus : Supported } msg
autofocus =
    A.autofocus


{-| See `Sl.Attributes.clearable`.
-}
clearable : Bool -> Attr { c | clearable : Supported } msg
clearable =
    A.clearable


{-| See `Sl.Attributes.disabled`.
-}
disabled : Bool -> Attr { c | disabled : Supported } msg
disabled =
    A.disabled


{-| See `Sl.Attributes.filled`.
-}
filled : Bool -> Attr { c | filled : Supported } msg
filled =
    A.filled


{-| See `Sl.Attributes.form`.
-}
form : String -> Attr { c | form : Supported } msg
form =
    A.form


{-| See `Sl.Attributes.helpText`.
-}
helpText : String -> Attr { c | helpText : Supported } msg
helpText =
    A.helpText


{-| See `Sl.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


{-| See `Sl.Attributes.max`.
-}
max : String -> Attr { c | max : Supported } msg
max =
    A.max


{-| See `Sl.Attributes.maxlength`.
-}
maxlength : Float -> Attr { c | maxlength : Supported } msg
maxlength =
    A.maxlength


{-| See `Sl.Attributes.min`.
-}
min : String -> Attr { c | min : Supported } msg
min =
    A.min


{-| See `Sl.Attributes.minlength`.
-}
minlength : Float -> Attr { c | minlength : Supported } msg
minlength =
    A.minlength


{-| See `Sl.Attributes.name`.
-}
name : String -> Attr { c | name : Supported } msg
name =
    A.name


{-| See `Sl.Attributes.noSpinButtons`.
-}
noSpinButtons : Bool -> Attr { c | noSpinButtons : Supported } msg
noSpinButtons =
    A.noSpinButtons


{-| See `Sl.Attributes.passwordToggle`.
-}
passwordToggle : Bool -> Attr { c | passwordToggle : Supported } msg
passwordToggle =
    A.passwordToggle


{-| See `Sl.Attributes.passwordVisible`.
-}
passwordVisible : Bool -> Attr { c | passwordVisible : Supported } msg
passwordVisible =
    A.passwordVisible


{-| See `Sl.Attributes.pattern`.
-}
pattern : String -> Attr { c | pattern : Supported } msg
pattern =
    A.pattern


{-| See `Sl.Attributes.pill`.
-}
pill : Bool -> Attr { c | pill : Supported } msg
pill =
    A.pill


{-| See `Sl.Attributes.placeholder`.
-}
placeholder : String -> Attr { c | placeholder : Supported } msg
placeholder =
    A.placeholder


{-| See `Sl.Attributes.readonly`.
-}
readonly : Bool -> Attr { c | readonly : Supported } msg
readonly =
    A.readonly


{-| See `Sl.Attributes.required`.
-}
required : Bool -> Attr { c | required : Supported } msg
required =
    A.required


{-| See `Sl.Attributes.spellcheck`.
-}
spellcheck : Bool -> Attr { c | spellcheck : Supported } msg
spellcheck =
    A.spellcheck


{-| See `Sl.Attributes.step`.
-}
step : String -> Attr { c | step : Supported } msg
step =
    A.step


{-| See `Sl.Attributes.title`.
-}
title : String -> Attr { c | title : Supported } msg
title =
    A.title


{-| See `Sl.Attributes.value`.
-}
value : String -> Attr { c | value : Supported } msg
value =
    A.value


{-| See `Sl.Attributes.defaultValue`.
-}
defaultValue : String -> Attr { c | value : Supported } msg
defaultValue =
    A.defaultValue


{-| See `Sl.Events.onBlur`.
-}
onBlur : msg -> Attr { c | onBlur : Supported } msg
onBlur =
    Ev.onBlur


{-| See `Sl.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| See `Sl.Events.onClear`.
-}
onClear : msg -> Attr { c | onClear : Supported } msg
onClear =
    Ev.onClear


{-| See `Sl.Events.onFocus`.
-}
onFocus : msg -> Attr { c | onFocus : Supported } msg
onFocus =
    Ev.onFocus


{-| See `Sl.Events.onInput`.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput =
    Ev.onInput


{-| See `Sl.Events.onInvalid`.
-}
onInvalid : msg -> Attr { c | onInvalid : Supported } msg
onInvalid =
    Ev.onInvalid
