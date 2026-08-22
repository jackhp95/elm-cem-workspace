module M3e.Component.Option exposing (OptionIs, OptionAttrs, OptionBuilder, OptionAttrCaps, OptionSlotCaps, OptionContent, OptionChildAdmittedBy, OptionHighlightMode, option, optionHighlightMode, optionDisableHighlight, optionDisabled, optionSelected, optionTerm, optionValue, optionDefaultSelected, optionDefaultValue, optionChild)

{-| The **Option** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Option`](M3e.Element.Option) as `option`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs OptionIs, OptionAttrs, OptionBuilder, OptionAttrCaps, OptionSlotCaps, OptionContent, OptionChildAdmittedBy, OptionHighlightMode, option, optionHighlightMode, optionDisableHighlight, optionDisabled, optionSelected, optionTerm, optionValue, optionDefaultSelected, optionDefaultValue, optionChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.Option as Option_


{-| The `option` element of this family — delegates to [`M3e.Element.Option.component`](M3e.Element.Option#component).
-}
option :
    { content : Element OptionContent (OptionChildAdmittedBy childAdm) msg }
    -> List (Attr OptionAttrs msg)
    -> List (Element OptionContent (OptionChildAdmittedBy childAdm) msg)
    -> Element (OptionIs s) admittedBy msg
option =
    Option_.component


{-| See [`M3e.Element.Option.Is`](M3e.Element.Option#Is).
-}
type alias OptionIs s =
    Option_.Is s


{-| See [`M3e.Element.Option.Attrs`](M3e.Element.Option#Attrs).
-}
type alias OptionAttrs =
    Option_.Attrs


{-| See [`M3e.Element.Option.Builder`](M3e.Element.Option#Builder).
-}
type alias OptionBuilder attrCaps slotCaps msg kind =
    Option_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Option.AttrCaps`](M3e.Element.Option#AttrCaps).
-}
type alias OptionAttrCaps =
    Option_.AttrCaps


{-| See [`M3e.Element.Option.SlotCaps`](M3e.Element.Option#SlotCaps).
-}
type alias OptionSlotCaps =
    Option_.SlotCaps


{-| See [`M3e.Element.Option.Content`](M3e.Element.Option#Content).
-}
type alias OptionContent =
    Option_.Content


{-| See [`M3e.Element.Option.ChildAdmittedBy`](M3e.Element.Option#ChildAdmittedBy).
-}
type alias OptionChildAdmittedBy childAdm =
    Option_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Option.HighlightMode`](M3e.Element.Option#HighlightMode).
-}
type alias OptionHighlightMode =
    Option_.HighlightMode


{-| See [`M3e.Element.Option.highlightMode`](M3e.Element.Option#highlightMode).
-}
optionHighlightMode : Value OptionHighlightMode -> Attr { c | highlightMode : Supported } msg
optionHighlightMode =
    Option_.highlightMode


{-| See [`M3e.Element.Option.disableHighlight`](M3e.Element.Option#disableHighlight).
-}
optionDisableHighlight : Bool -> Attr { c | disableHighlight : Supported } msg
optionDisableHighlight =
    Option_.disableHighlight


{-| See [`M3e.Element.Option.disabled`](M3e.Element.Option#disabled).
-}
optionDisabled : Bool -> Attr { c | disabled : Supported } msg
optionDisabled =
    Option_.disabled


{-| See [`M3e.Element.Option.selected`](M3e.Element.Option#selected).
-}
optionSelected : Bool -> Attr { c | selected : Supported } msg
optionSelected =
    Option_.selected


{-| See [`M3e.Element.Option.term`](M3e.Element.Option#term).
-}
optionTerm : String -> Attr { c | term : Supported } msg
optionTerm =
    Option_.term


{-| See [`M3e.Element.Option.value`](M3e.Element.Option#value).
-}
optionValue : String -> Attr { c | value : Supported } msg
optionValue =
    Option_.value


{-| See [`M3e.Element.Option.defaultSelected`](M3e.Element.Option#defaultSelected).
-}
optionDefaultSelected : Bool -> Attr { c | selected : Supported } msg
optionDefaultSelected =
    Option_.defaultSelected


{-| See [`M3e.Element.Option.defaultValue`](M3e.Element.Option#defaultValue).
-}
optionDefaultValue : String -> Attr { c | value : Supported } msg
optionDefaultValue =
    Option_.defaultValue


{-| See [`M3e.Element.Option.child`](M3e.Element.Option#child).
-}
optionChild : Element OptionContent admittedBy msg -> Element free freeAdmittedBy msg
optionChild =
    Option_.child
