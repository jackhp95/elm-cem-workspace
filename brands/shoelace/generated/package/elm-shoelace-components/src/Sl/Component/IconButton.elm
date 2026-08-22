module Sl.Component.IconButton exposing (IconButtonIs, IconButtonAttrs, IconButtonBuilder, IconButtonAttrCaps, IconButtonSlotCaps, IconButtonChildAdmittedBy, IconButtonTarget, iconButton, iconButtonTarget, iconButtonDisabled, iconButtonDownload, iconButtonHref, iconButtonLabel, iconButtonLibrary, iconButtonName, iconButtonSrc, iconButtonOnBlur, iconButtonOnFocus)

{-| The **IconButton** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.IconButton`](Sl.Element.IconButton) as `iconButton`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs IconButtonIs, IconButtonAttrs, IconButtonBuilder, IconButtonAttrCaps, IconButtonSlotCaps, IconButtonChildAdmittedBy, IconButtonTarget, iconButton, iconButtonTarget, iconButtonDisabled, iconButtonDownload, iconButtonHref, iconButtonLabel, iconButtonLibrary, iconButtonName, iconButtonSrc, iconButtonOnBlur, iconButtonOnFocus

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Sl.Element.IconButton as IconButton_


{-| The `iconButton` element of this family — delegates to [`Sl.Element.IconButton.component`](Sl.Element.IconButton#component).
-}
iconButton :
    List (Attr IconButtonAttrs msg)
    -> List (Element childAccepts (IconButtonChildAdmittedBy childAdm) msg)
    -> Element (IconButtonIs s) admittedBy msg
iconButton =
    IconButton_.component


{-| See [`Sl.Element.IconButton.Is`](Sl.Element.IconButton#Is).
-}
type alias IconButtonIs s =
    IconButton_.Is s


{-| See [`Sl.Element.IconButton.Attrs`](Sl.Element.IconButton#Attrs).
-}
type alias IconButtonAttrs =
    IconButton_.Attrs


{-| See [`Sl.Element.IconButton.Builder`](Sl.Element.IconButton#Builder).
-}
type alias IconButtonBuilder attrCaps slotCaps msg kind =
    IconButton_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.IconButton.AttrCaps`](Sl.Element.IconButton#AttrCaps).
-}
type alias IconButtonAttrCaps =
    IconButton_.AttrCaps


{-| See [`Sl.Element.IconButton.SlotCaps`](Sl.Element.IconButton#SlotCaps).
-}
type alias IconButtonSlotCaps =
    IconButton_.SlotCaps


{-| See [`Sl.Element.IconButton.ChildAdmittedBy`](Sl.Element.IconButton#ChildAdmittedBy).
-}
type alias IconButtonChildAdmittedBy childAdm =
    IconButton_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.IconButton.Target`](Sl.Element.IconButton#Target).
-}
type alias IconButtonTarget =
    IconButton_.Target


{-| See [`Sl.Element.IconButton.target`](Sl.Element.IconButton#target).
-}
iconButtonTarget : Value IconButtonTarget -> Attr { c | target : Supported } msg
iconButtonTarget =
    IconButton_.target


{-| See [`Sl.Element.IconButton.disabled`](Sl.Element.IconButton#disabled).
-}
iconButtonDisabled : Bool -> Attr { c | disabled : Supported } msg
iconButtonDisabled =
    IconButton_.disabled


{-| See [`Sl.Element.IconButton.download`](Sl.Element.IconButton#download).
-}
iconButtonDownload : String -> Attr { c | download : Supported } msg
iconButtonDownload =
    IconButton_.download


{-| See [`Sl.Element.IconButton.href`](Sl.Element.IconButton#href).
-}
iconButtonHref : String -> Attr { c | href : Supported } msg
iconButtonHref =
    IconButton_.href


{-| See [`Sl.Element.IconButton.label`](Sl.Element.IconButton#label).
-}
iconButtonLabel : String -> Attr { c | label : Supported } msg
iconButtonLabel =
    IconButton_.label


{-| See [`Sl.Element.IconButton.library`](Sl.Element.IconButton#library).
-}
iconButtonLibrary : String -> Attr { c | library : Supported } msg
iconButtonLibrary =
    IconButton_.library


{-| See [`Sl.Element.IconButton.name`](Sl.Element.IconButton#name).
-}
iconButtonName : String -> Attr { c | name : Supported } msg
iconButtonName =
    IconButton_.name


{-| See [`Sl.Element.IconButton.src`](Sl.Element.IconButton#src).
-}
iconButtonSrc : String -> Attr { c | src : Supported } msg
iconButtonSrc =
    IconButton_.src


{-| See [`Sl.Element.IconButton.onBlur`](Sl.Element.IconButton#onBlur).
-}
iconButtonOnBlur : msg -> Attr { c | onBlur : Supported } msg
iconButtonOnBlur =
    IconButton_.onBlur


{-| See [`Sl.Element.IconButton.onFocus`](Sl.Element.IconButton#onFocus).
-}
iconButtonOnFocus : msg -> Attr { c | onFocus : Supported } msg
iconButtonOnFocus =
    IconButton_.onFocus
