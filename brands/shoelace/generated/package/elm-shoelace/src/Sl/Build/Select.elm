module Sl.Build.Select exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
    , withClass, withClearable, withDisabled, withFilled, withForm, withGettag, withHelpText, withHoist, withId, withLabel, withMaxOptionsVisible, withMultiple, withName, withOnAfterHide, withOnAfterShow, withOnBlur, withOnChange, withOnClear, withOnFocus, withOnHide, withOnInput, withOnInvalid, withOnShow, withOpen, withPill, withPlaceholder, withPlacement, withRequired, withSize, withSlot, withStyle, withValue
    , withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
@docs withClass, withClearable, withDisabled, withFilled, withForm, withGettag, withHelpText, withHoist, withId, withLabel, withMaxOptionsVisible, withMultiple, withName, withOnAfterHide, withOnAfterShow, withOnBlur, withOnChange, withOnClear, withOnFocus, withOnHide, withOnInput, withOnInvalid, withOnShow, withOpen, withPill, withPlaceholder, withPlacement, withRequired, withSize, withSlot, withStyle, withValue
@docs withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Attributes as A
import Sl.Element.Select as Component
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
type alias Content =
    Component.Content


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "sl-select" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
withChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


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
withClearable : Bool -> Builder { a | clearable : Available } slotCaps msg kind -> Builder { a | clearable : Used } slotCaps msg kind
withClearable value_ =
    B.withAttribute (A.clearable value_)


{-| -}
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withFilled : Bool -> Builder { a | filled : Available } slotCaps msg kind -> Builder { a | filled : Used } slotCaps msg kind
withFilled value_ =
    B.withAttribute (A.filled value_)


{-| -}
withForm : String -> Builder { a | form : Available } slotCaps msg kind -> Builder { a | form : Used } slotCaps msg kind
withForm value_ =
    B.withAttribute (A.form value_)


{-| -}
withGettag : String -> Builder { a | gettag : Available } slotCaps msg kind -> Builder { a | gettag : Used } slotCaps msg kind
withGettag value_ =
    B.withAttribute (A.gettag value_)


{-| -}
withHelpText : String -> Builder { a | helpText : Available } slotCaps msg kind -> Builder { a | helpText : Used } slotCaps msg kind
withHelpText value_ =
    B.withAttribute (A.helpText value_)


{-| -}
withHoist : Bool -> Builder { a | hoist : Available } slotCaps msg kind -> Builder { a | hoist : Used } slotCaps msg kind
withHoist value_ =
    B.withAttribute (A.hoist value_)


{-| -}
withLabel : String -> Builder { a | label : Available } slotCaps msg kind -> Builder { a | label : Used } slotCaps msg kind
withLabel value_ =
    B.withAttribute (A.label value_)


{-| -}
withMaxOptionsVisible : Float -> Builder { a | maxOptionsVisible : Available } slotCaps msg kind -> Builder { a | maxOptionsVisible : Used } slotCaps msg kind
withMaxOptionsVisible value_ =
    B.withAttribute (A.maxOptionsVisible value_)


{-| -}
withMultiple : Bool -> Builder { a | multiple : Available } slotCaps msg kind -> Builder { a | multiple : Used } slotCaps msg kind
withMultiple value_ =
    B.withAttribute (A.multiple value_)


{-| -}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (A.name value_)


{-| -}
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
withPill : Bool -> Builder { a | pill : Available } slotCaps msg kind -> Builder { a | pill : Used } slotCaps msg kind
withPill value_ =
    B.withAttribute (A.pill value_)


{-| -}
withPlaceholder : String -> Builder { a | placeholder : Available } slotCaps msg kind -> Builder { a | placeholder : Used } slotCaps msg kind
withPlaceholder value_ =
    B.withAttribute (A.placeholder value_)


{-| -}
withPlacement : Value Component.Placement -> Builder { a | placement : Available } slotCaps msg kind -> Builder { a | placement : Used } slotCaps msg kind
withPlacement value_ =
    B.withAttribute (Component.placement value_)


{-| -}
withRequired : Bool -> Builder { a | required : Available } slotCaps msg kind -> Builder { a | required : Used } slotCaps msg kind
withRequired value_ =
    B.withAttribute (A.required value_)


{-| -}
withSize : Value Component.Size -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.size value_)


{-| -}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnClear : msg -> Builder { a | onClear : Available } slotCaps msg kind -> Builder { a | onClear : Used } slotCaps msg kind
withOnClear value_ =
    B.withAttribute (Ev.onClear value_)


{-| -}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
withOnFocus : msg -> Builder { a | onFocus : Available } slotCaps msg kind -> Builder { a | onFocus : Used } slotCaps msg kind
withOnFocus value_ =
    B.withAttribute (Ev.onFocus value_)


{-| -}
withOnBlur : msg -> Builder { a | onBlur : Available } slotCaps msg kind -> Builder { a | onBlur : Used } slotCaps msg kind
withOnBlur value_ =
    B.withAttribute (Ev.onBlur value_)


{-| -}
withOnShow : msg -> Builder { a | onShow : Available } slotCaps msg kind -> Builder { a | onShow : Used } slotCaps msg kind
withOnShow value_ =
    B.withAttribute (Ev.onShow value_)


{-| -}
withOnAfterShow : msg -> Builder { a | onAfterShow : Available } slotCaps msg kind -> Builder { a | onAfterShow : Used } slotCaps msg kind
withOnAfterShow value_ =
    B.withAttribute (Ev.onAfterShow value_)


{-| -}
withOnHide : msg -> Builder { a | onHide : Available } slotCaps msg kind -> Builder { a | onHide : Used } slotCaps msg kind
withOnHide value_ =
    B.withAttribute (Ev.onHide value_)


{-| -}
withOnAfterHide : msg -> Builder { a | onAfterHide : Available } slotCaps msg kind -> Builder { a | onAfterHide : Used } slotCaps msg kind
withOnAfterHide value_ =
    B.withAttribute (Ev.onAfterHide value_)


{-| -}
withOnInvalid : msg -> Builder { a | onInvalid : Available } slotCaps msg kind -> Builder { a | onInvalid : Used } slotCaps msg kind
withOnInvalid value_ =
    B.withAttribute (Ev.onInvalid value_)
