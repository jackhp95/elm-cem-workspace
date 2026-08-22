module Sl.Component.Option exposing (OptionIs, OptionAttrs, OptionBuilder, OptionAttrCaps, OptionSlotCaps, OptionContent, OptionChildAdmittedBy, option, optionDisabled, optionValue, optionDefaultValue, optionChild)

{-| The **Option** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`Sl.Element.Option`](Sl.Element.Option) as `option`.

Prefer whichever import reads best — the flat `Sl.Element.*` modules and
this family module are the same elements, same types.

@docs OptionIs, OptionAttrs, OptionBuilder, OptionAttrCaps, OptionSlotCaps, OptionContent, OptionChildAdmittedBy, option, optionDisabled, optionValue, optionDefaultValue, optionChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Element.Option as Option_


{-| The `option` element of this family — delegates to [`Sl.Element.Option.component`](Sl.Element.Option#component).
-}
option :
    List (Attr OptionAttrs msg)
    -> List (Element OptionContent (OptionChildAdmittedBy childAdm) msg)
    -> Element (OptionIs s) admittedBy msg
option =
    Option_.component


{-| See [`Sl.Element.Option.Is`](Sl.Element.Option#Is).
-}
type alias OptionIs s =
    Option_.Is s


{-| See [`Sl.Element.Option.Attrs`](Sl.Element.Option#Attrs).
-}
type alias OptionAttrs =
    Option_.Attrs


{-| See [`Sl.Element.Option.Builder`](Sl.Element.Option#Builder).
-}
type alias OptionBuilder attrCaps slotCaps msg kind =
    Option_.Builder attrCaps slotCaps msg kind


{-| See [`Sl.Element.Option.AttrCaps`](Sl.Element.Option#AttrCaps).
-}
type alias OptionAttrCaps =
    Option_.AttrCaps


{-| See [`Sl.Element.Option.SlotCaps`](Sl.Element.Option#SlotCaps).
-}
type alias OptionSlotCaps =
    Option_.SlotCaps


{-| See [`Sl.Element.Option.Content`](Sl.Element.Option#Content).
-}
type alias OptionContent =
    Option_.Content


{-| See [`Sl.Element.Option.ChildAdmittedBy`](Sl.Element.Option#ChildAdmittedBy).
-}
type alias OptionChildAdmittedBy childAdm =
    Option_.ChildAdmittedBy childAdm


{-| See [`Sl.Element.Option.disabled`](Sl.Element.Option#disabled).
-}
optionDisabled : Bool -> Attr { c | disabled : Supported } msg
optionDisabled =
    Option_.disabled


{-| See [`Sl.Element.Option.value`](Sl.Element.Option#value).
-}
optionValue : String -> Attr { c | value : Supported } msg
optionValue =
    Option_.value


{-| See [`Sl.Element.Option.defaultValue`](Sl.Element.Option#defaultValue).
-}
optionDefaultValue : String -> Attr { c | value : Supported } msg
optionDefaultValue =
    Option_.defaultValue


{-| See [`Sl.Element.Option.child`](Sl.Element.Option#child).
-}
optionChild : Element OptionContent admittedBy msg -> Element free freeAdmittedBy msg
optionChild =
    Option_.child
