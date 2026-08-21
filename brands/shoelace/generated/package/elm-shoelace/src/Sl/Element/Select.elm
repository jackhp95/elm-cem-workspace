module Sl.Element.Select exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    , Placement, placement, Size, size
    , clearable, disabled, filled, form, gettag, helpText, hoist, label, maxOptionsVisible, multiple, name, open, pill, placeholder, required, value, defaultValue, onChange, onClear, onInput, onFocus, onBlur, onShow, onAfterShow, onHide, onAfterHide, onInvalid
    )

{-| The `sl-select` component — strict per-component surface.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
@docs Placement, placement, Size, size
@docs clearable, disabled, filled, form, gettag, helpText, hoist, label, maxOptionsVisible, multiple, name, open, pill, placeholder, required, value, defaultValue, onChange, onClear, onInput, onFocus, onBlur, onShow, onAfterShow, onHide, onAfterHide, onInvalid

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Events as Ev
import Sl.Html as H
import Sl.Internal.Types.Select
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `sl-select` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Sl.Internal.Types.Select.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Sl.Internal.Types.Select.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Sl.Internal.Types.Select.ChildAdmittedBy childAdm


{-| The `placement` values valid on this component (compile-tight narrowing).
-}
type alias Placement =
    Sl.Internal.Types.Select.Placement


{-| The `size` values valid on this component (compile-tight narrowing).
-}
type alias Size =
    Sl.Internal.Types.Select.Size


{-| The narrowed pipe-builder this component's `Sl.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Sl.Internal.Types.Select.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Sl.Internal.Types.Select.AttrCaps


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
    H.select


{-| The preferred placement of the select's menu. Note that the actual placement may vary as needed to keep the listbox
inside of the viewport. (default: `'bottom'`)
-}
placement : Value Placement -> Attr { c | placement : Supported } msg
placement value_ =
    Ir.attribute "placement" (Val.toString value_)


{-| The select's size. (default: `'medium'`)
-}
size : Value Size -> Attr { c | size : Supported } msg
size value_ =
    Ir.attribute "size" (Val.toString value_)


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


{-| See `Sl.Attributes.gettag`.
-}
gettag : String -> Attr { c | gettag : Supported } msg
gettag =
    A.gettag


{-| See `Sl.Attributes.helpText`.
-}
helpText : String -> Attr { c | helpText : Supported } msg
helpText =
    A.helpText


{-| See `Sl.Attributes.hoist`.
-}
hoist : Bool -> Attr { c | hoist : Supported } msg
hoist =
    A.hoist


{-| See `Sl.Attributes.label`.
-}
label : String -> Attr { c | label : Supported } msg
label =
    A.label


{-| See `Sl.Attributes.maxOptionsVisible`.
-}
maxOptionsVisible : Float -> Attr { c | maxOptionsVisible : Supported } msg
maxOptionsVisible =
    A.maxOptionsVisible


{-| See `Sl.Attributes.multiple`.
-}
multiple : Bool -> Attr { c | multiple : Supported } msg
multiple =
    A.multiple


{-| See `Sl.Attributes.name`.
-}
name : String -> Attr { c | name : Supported } msg
name =
    A.name


{-| See `Sl.Attributes.open`.
-}
open : Bool -> Attr { c | open : Supported } msg
open =
    A.open


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


{-| See `Sl.Attributes.required`.
-}
required : Bool -> Attr { c | required : Supported } msg
required =
    A.required


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


{-| See `Sl.Events.onInput`.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput =
    Ev.onInput


{-| See `Sl.Events.onFocus`.
-}
onFocus : msg -> Attr { c | onFocus : Supported } msg
onFocus =
    Ev.onFocus


{-| See `Sl.Events.onBlur`.
-}
onBlur : msg -> Attr { c | onBlur : Supported } msg
onBlur =
    Ev.onBlur


{-| See `Sl.Events.onShow`.
-}
onShow : msg -> Attr { c | onShow : Supported } msg
onShow =
    Ev.onShow


{-| See `Sl.Events.onAfterShow`.
-}
onAfterShow : msg -> Attr { c | onAfterShow : Supported } msg
onAfterShow =
    Ev.onAfterShow


{-| See `Sl.Events.onHide`.
-}
onHide : msg -> Attr { c | onHide : Supported } msg
onHide =
    Ev.onHide


{-| See `Sl.Events.onAfterHide`.
-}
onAfterHide : msg -> Attr { c | onAfterHide : Supported } msg
onAfterHide =
    Ev.onAfterHide


{-| See `Sl.Events.onInvalid`.
-}
onInvalid : msg -> Attr { c | onInvalid : Supported } msg
onInvalid =
    Ev.onInvalid
