module M3e.Component.AppBar exposing (AppBarIs, AppBarAttrs, AppBarBuilder, AppBarAttrCaps, AppBarSlotCaps, AppBarLeadingSlot, AppBarSubtitleSlot, AppBarTitleSlot, AppBarTrailingSlot, AppBarChildAdmittedBy, AppBarSize, appBar, appBarSize, appBarCentered, appBarFor, appBarLeading, appBarLeadingIcon, appBarSubtitle, appBarTitle, appBarTrailing, appBarTrailingIcon)

{-| The **AppBar** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.AppBar`](M3e.Element.AppBar) as `appBar`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs AppBarIs, AppBarAttrs, AppBarBuilder, AppBarAttrCaps, AppBarSlotCaps, AppBarLeadingSlot, AppBarSubtitleSlot, AppBarTitleSlot, AppBarTrailingSlot, AppBarChildAdmittedBy, AppBarSize, appBar, appBarSize, appBarCentered, appBarFor, appBarLeading, appBarLeadingIcon, appBarSubtitle, appBarTitle, appBarTrailing, appBarTrailingIcon

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Element.AppBar as AppBar_


{-| The `appBar` element of this family — delegates to [`M3e.Element.AppBar.component`](M3e.Element.AppBar#component).
-}
appBar :
    List (Attr AppBarAttrs msg)
    -> List (Element childAccepts (AppBarChildAdmittedBy childAdm) msg)
    -> Element (AppBarIs s) admittedBy msg
appBar =
    AppBar_.component


{-| See [`M3e.Element.AppBar.Is`](M3e.Element.AppBar#Is).
-}
type alias AppBarIs s =
    AppBar_.Is s


{-| See [`M3e.Element.AppBar.Attrs`](M3e.Element.AppBar#Attrs).
-}
type alias AppBarAttrs =
    AppBar_.Attrs


{-| See [`M3e.Element.AppBar.Builder`](M3e.Element.AppBar#Builder).
-}
type alias AppBarBuilder attrCaps slotCaps msg kind =
    AppBar_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.AppBar.AttrCaps`](M3e.Element.AppBar#AttrCaps).
-}
type alias AppBarAttrCaps =
    AppBar_.AttrCaps


{-| See [`M3e.Element.AppBar.SlotCaps`](M3e.Element.AppBar#SlotCaps).
-}
type alias AppBarSlotCaps =
    AppBar_.SlotCaps


{-| See [`M3e.Element.AppBar.LeadingSlot`](M3e.Element.AppBar#LeadingSlot).
-}
type alias AppBarLeadingSlot =
    AppBar_.LeadingSlot


{-| See [`M3e.Element.AppBar.SubtitleSlot`](M3e.Element.AppBar#SubtitleSlot).
-}
type alias AppBarSubtitleSlot =
    AppBar_.SubtitleSlot


{-| See [`M3e.Element.AppBar.TitleSlot`](M3e.Element.AppBar#TitleSlot).
-}
type alias AppBarTitleSlot =
    AppBar_.TitleSlot


{-| See [`M3e.Element.AppBar.TrailingSlot`](M3e.Element.AppBar#TrailingSlot).
-}
type alias AppBarTrailingSlot =
    AppBar_.TrailingSlot


{-| See [`M3e.Element.AppBar.ChildAdmittedBy`](M3e.Element.AppBar#ChildAdmittedBy).
-}
type alias AppBarChildAdmittedBy childAdm =
    AppBar_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.AppBar.Size`](M3e.Element.AppBar#Size).
-}
type alias AppBarSize =
    AppBar_.Size


{-| See [`M3e.Element.AppBar.size`](M3e.Element.AppBar#size).
-}
appBarSize : Value AppBarSize -> Attr { c | size : Supported } msg
appBarSize =
    AppBar_.size


{-| See [`M3e.Element.AppBar.centered`](M3e.Element.AppBar#centered).
-}
appBarCentered : Bool -> Attr { c | centered : Supported } msg
appBarCentered =
    AppBar_.centered


{-| See [`M3e.Element.AppBar.for`](M3e.Element.AppBar#for).
-}
appBarFor : String -> Attr { c | for : Supported } msg
appBarFor =
    AppBar_.for


{-| See [`M3e.Element.AppBar.leading`](M3e.Element.AppBar#leading).
-}
appBarLeading : Element AppBarLeadingSlot admittedBy msg -> Element free freeAdmittedBy msg
appBarLeading =
    AppBar_.leading


{-| See [`M3e.Element.AppBar.leadingIcon`](M3e.Element.AppBar#leadingIcon).
-}
appBarLeadingIcon : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
appBarLeadingIcon =
    AppBar_.leadingIcon


{-| See [`M3e.Element.AppBar.subtitle`](M3e.Element.AppBar#subtitle).
-}
appBarSubtitle : Element AppBarSubtitleSlot admittedBy msg -> Element free freeAdmittedBy msg
appBarSubtitle =
    AppBar_.subtitle


{-| See [`M3e.Element.AppBar.title`](M3e.Element.AppBar#title).
-}
appBarTitle : Element AppBarTitleSlot admittedBy msg -> Element free freeAdmittedBy msg
appBarTitle =
    AppBar_.title


{-| See [`M3e.Element.AppBar.trailing`](M3e.Element.AppBar#trailing).
-}
appBarTrailing : Element AppBarTrailingSlot admittedBy msg -> Element free freeAdmittedBy msg
appBarTrailing =
    AppBar_.trailing


{-| See [`M3e.Element.AppBar.trailingIcon`](M3e.Element.AppBar#trailingIcon).
-}
appBarTrailingIcon : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
appBarTrailingIcon =
    AppBar_.trailingIcon
