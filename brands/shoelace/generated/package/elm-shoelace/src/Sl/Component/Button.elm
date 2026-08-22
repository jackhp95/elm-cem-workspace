module Sl.Component.Button exposing (ButtonIs, ButtonAttrs, ButtonBuilder, ButtonAttrCaps, ButtonSlotCaps, ButtonChildAdmittedBy, ButtonFormenctype, ButtonFormmethod, ButtonFormtarget, ButtonSize, ButtonTarget, ButtonType, ButtonVariant, button, buttonFormenctype, buttonFormmethod, buttonFormtarget, buttonSize, buttonTarget, buttonType_, buttonVariant, buttonCaret, buttonCircle, buttonDisabled, buttonDownload, buttonForm, buttonFormnovalidate, buttonHref, buttonLoading, buttonName, buttonOutline, buttonPill, buttonRel, buttonTitle, buttonValue, buttonDefaultValue, buttonOnBlur, buttonOnFocus, buttonOnInvalid)

{-| The **Button** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Button`](Sl.Element.Button) as `button`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs ButtonIs, ButtonAttrs, ButtonBuilder, ButtonAttrCaps, ButtonSlotCaps, ButtonChildAdmittedBy, ButtonFormenctype, ButtonFormmethod, ButtonFormtarget, ButtonSize, ButtonTarget, ButtonType, ButtonVariant, button, buttonFormenctype, buttonFormmethod, buttonFormtarget, buttonSize, buttonTarget, buttonType_, buttonVariant, buttonCaret, buttonCircle, buttonDisabled, buttonDownload, buttonForm, buttonFormnovalidate, buttonHref, buttonLoading, buttonName, buttonOutline, buttonPill, buttonRel, buttonTitle, buttonValue, buttonDefaultValue, buttonOnBlur, buttonOnFocus, buttonOnInvalid

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.Button as Button_


{-| The `button` element of this family — delegates to [`Sl.Element.Button.component`](Sl.Element.Button#component).
-}
button :
    List (Attr ButtonAttrs msg)
    -> List (Element childAccepts (ButtonChildAdmittedBy childAdm) msg)
    -> Element (ButtonIs s) admittedBy msg
button =
    Button_.component


{-| See [`Sl.Element.Button.Is`](Sl.Element.Button#Is).
-}
type alias ButtonIs s =
    Button_.Is s


{-| See [`Sl.Element.Button.Attrs`](Sl.Element.Button#Attrs).
-}
type alias ButtonAttrs =
    Button_.Attrs


{-| See [`Sl.Element.Button.Builder`](Sl.Element.Button#Builder).
-}
type alias ButtonBuilder attrCaps slotCaps msg kind =
    Button_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Button.AttrCaps`](Sl.Element.Button#AttrCaps).
-}
type alias ButtonAttrCaps =
    Button_.AttrCaps


{-| See [`Sl.Element.Button.SlotCaps`](Sl.Element.Button#SlotCaps).
-}
type alias ButtonSlotCaps =
    Button_.SlotCaps


{-| See [`Sl.Element.Button.ChildAdmittedBy`](Sl.Element.Button#ChildAdmittedBy).
-}
type alias ButtonChildAdmittedBy childAdm =
    Button_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Button.Formenctype`](Sl.Element.Button#Formenctype).
-}
type alias ButtonFormenctype =
    Button_.Formenctype


{-| See [`Sl.Element.Button.formenctype`](Sl.Element.Button#formenctype).
-}
buttonFormenctype : Value ButtonFormenctype -> Attr { c | formenctype : Supported } msg
buttonFormenctype =
    Button_.formenctype


{-| See [`Sl.Element.Button.Formmethod`](Sl.Element.Button#Formmethod).
-}
type alias ButtonFormmethod =
    Button_.Formmethod


{-| See [`Sl.Element.Button.formmethod`](Sl.Element.Button#formmethod).
-}
buttonFormmethod : Value ButtonFormmethod -> Attr { c | formmethod : Supported } msg
buttonFormmethod =
    Button_.formmethod


{-| See [`Sl.Element.Button.Formtarget`](Sl.Element.Button#Formtarget).
-}
type alias ButtonFormtarget =
    Button_.Formtarget


{-| See [`Sl.Element.Button.formtarget`](Sl.Element.Button#formtarget).
-}
buttonFormtarget : Value ButtonFormtarget -> Attr { c | formtarget : Supported } msg
buttonFormtarget =
    Button_.formtarget


{-| See [`Sl.Element.Button.Size`](Sl.Element.Button#Size).
-}
type alias ButtonSize =
    Button_.Size


{-| See [`Sl.Element.Button.size`](Sl.Element.Button#size).
-}
buttonSize : Value ButtonSize -> Attr { c | size : Supported } msg
buttonSize =
    Button_.size


{-| See [`Sl.Element.Button.Target`](Sl.Element.Button#Target).
-}
type alias ButtonTarget =
    Button_.Target


{-| See [`Sl.Element.Button.target`](Sl.Element.Button#target).
-}
buttonTarget : Value ButtonTarget -> Attr { c | target : Supported } msg
buttonTarget =
    Button_.target


{-| See [`Sl.Element.Button.Type`](Sl.Element.Button#Type).
-}
type alias ButtonType =
    Button_.Type


{-| See [`Sl.Element.Button.type_`](Sl.Element.Button#type_).
-}
buttonType_ : Value ButtonType -> Attr { c | type_ : Supported } msg
buttonType_ =
    Button_.type_


{-| See [`Sl.Element.Button.Variant`](Sl.Element.Button#Variant).
-}
type alias ButtonVariant =
    Button_.Variant


{-| See [`Sl.Element.Button.variant`](Sl.Element.Button#variant).
-}
buttonVariant : Value ButtonVariant -> Attr { c | variant : Supported } msg
buttonVariant =
    Button_.variant


{-| See [`Sl.Element.Button.caret`](Sl.Element.Button#caret).
-}
buttonCaret : Bool -> Attr { c | caret : Supported } msg
buttonCaret =
    Button_.caret


{-| See [`Sl.Element.Button.circle`](Sl.Element.Button#circle).
-}
buttonCircle : Bool -> Attr { c | circle : Supported } msg
buttonCircle =
    Button_.circle


{-| See [`Sl.Element.Button.disabled`](Sl.Element.Button#disabled).
-}
buttonDisabled : Bool -> Attr { c | disabled : Supported } msg
buttonDisabled =
    Button_.disabled


{-| See [`Sl.Element.Button.download`](Sl.Element.Button#download).
-}
buttonDownload : String -> Attr { c | download : Supported } msg
buttonDownload =
    Button_.download


{-| See [`Sl.Element.Button.form`](Sl.Element.Button#form).
-}
buttonForm : String -> Attr { c | form : Supported } msg
buttonForm =
    Button_.form


{-| See [`Sl.Element.Button.formnovalidate`](Sl.Element.Button#formnovalidate).
-}
buttonFormnovalidate : Bool -> Attr { c | formnovalidate : Supported } msg
buttonFormnovalidate =
    Button_.formnovalidate


{-| See [`Sl.Element.Button.href`](Sl.Element.Button#href).
-}
buttonHref : String -> Attr { c | href : Supported } msg
buttonHref =
    Button_.href


{-| See [`Sl.Element.Button.loading`](Sl.Element.Button#loading).
-}
buttonLoading : Bool -> Attr { c | loading : Supported } msg
buttonLoading =
    Button_.loading


{-| See [`Sl.Element.Button.name`](Sl.Element.Button#name).
-}
buttonName : String -> Attr { c | name : Supported } msg
buttonName =
    Button_.name


{-| See [`Sl.Element.Button.outline`](Sl.Element.Button#outline).
-}
buttonOutline : Bool -> Attr { c | outline : Supported } msg
buttonOutline =
    Button_.outline


{-| See [`Sl.Element.Button.pill`](Sl.Element.Button#pill).
-}
buttonPill : Bool -> Attr { c | pill : Supported } msg
buttonPill =
    Button_.pill


{-| See [`Sl.Element.Button.rel`](Sl.Element.Button#rel).
-}
buttonRel : String -> Attr { c | rel : Supported } msg
buttonRel =
    Button_.rel


{-| See [`Sl.Element.Button.title`](Sl.Element.Button#title).
-}
buttonTitle : String -> Attr { c | title : Supported } msg
buttonTitle =
    Button_.title


{-| See [`Sl.Element.Button.value`](Sl.Element.Button#value).
-}
buttonValue : String -> Attr { c | value : Supported } msg
buttonValue =
    Button_.value


{-| See [`Sl.Element.Button.defaultValue`](Sl.Element.Button#defaultValue).
-}
buttonDefaultValue : String -> Attr { c | value : Supported } msg
buttonDefaultValue =
    Button_.defaultValue


{-| See [`Sl.Element.Button.onBlur`](Sl.Element.Button#onBlur).
-}
buttonOnBlur : msg -> Attr { c | onBlur : Supported } msg
buttonOnBlur =
    Button_.onBlur


{-| See [`Sl.Element.Button.onFocus`](Sl.Element.Button#onFocus).
-}
buttonOnFocus : msg -> Attr { c | onFocus : Supported } msg
buttonOnFocus =
    Button_.onFocus


{-| See [`Sl.Element.Button.onInvalid`](Sl.Element.Button#onInvalid).
-}
buttonOnInvalid : msg -> Attr { c | onInvalid : Supported } msg
buttonOnInvalid =
    Button_.onInvalid
