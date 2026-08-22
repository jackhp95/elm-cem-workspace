module M3e.Build.SearchView exposing (Builder, AttrCaps, SlotCaps, Is, ClearIconSlot, CloseIconSlot, ClosedLeadingSlot, ClosedTrailingSlot, OpenLeadingSlot, OpenTrailingSlot, SearchIconSlot, ChildAdmittedBy, build, toElement, withClass, withClearLabel, withCloseLabel, withContained, withHideSearchIcon, withId, withMode, withOnBeforetoggle, withOnClear, withOnQuery, withOnToggle, withOpen, withSlot, withStyle, clearIcon, closeIcon, closedLeading, closedTrailing, input, openLeading, openTrailing, searchIcon, withClearIcon, withCloseIcon, withInput, withSearchIcon, withClosedLeading, withClosedTrailing, withOpenLeading, withOpenTrailing, withChild)

{-| The **SearchView** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.SearchView`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ClearIconSlot, CloseIconSlot, ClosedLeadingSlot, ClosedTrailingSlot, OpenLeadingSlot, OpenTrailingSlot, SearchIconSlot, ChildAdmittedBy, build, toElement, withClass, withClearLabel, withCloseLabel, withContained, withHideSearchIcon, withId, withMode, withOnBeforetoggle, withOnClear, withOnQuery, withOnToggle, withOpen, withSlot, withStyle, clearIcon, closeIcon, closedLeading, closedTrailing, input, openLeading, openTrailing, searchIcon, withClearIcon, withCloseIcon, withInput, withSearchIcon, withClosedLeading, withClosedTrailing, withOpenLeading, withOpenTrailing, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.SearchView as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.SearchViewIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.SearchViewBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.SearchViewAttrCaps


{-| -}
type alias SlotCaps =
    Component.SearchViewSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.SearchViewChildAdmittedBy childAdm


{-| -}
type alias ClearIconSlot =
    Component.SearchViewClearIconSlot


{-| -}
type alias CloseIconSlot =
    Component.SearchViewCloseIconSlot


{-| -}
type alias ClosedLeadingSlot =
    Component.SearchViewClosedLeadingSlot


{-| -}
type alias ClosedTrailingSlot =
    Component.SearchViewClosedTrailingSlot


{-| -}
type alias OpenLeadingSlot =
    Component.SearchViewOpenLeadingSlot


{-| -}
type alias OpenTrailingSlot =
    Component.SearchViewOpenTrailingSlot


{-| -}
type alias SearchIconSlot =
    Component.SearchViewSearchIconSlot


{-| -}
build :
    { input : Element childAccepts (Component.SearchViewChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-search-view" [] [ El.toNode (Component.searchViewInput required_.input) ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.SearchViewIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
clearIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewClearIconSlot msg
    -> Element free freeAdmittedBy msg
clearIcon builder =
    Component.searchViewClearIcon (B.toElement builder)


{-| -}
closeIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewCloseIconSlot msg
    -> Element free freeAdmittedBy msg
closeIcon builder =
    Component.searchViewCloseIcon (B.toElement builder)


{-| -}
closedLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewClosedLeadingSlot msg
    -> Element free freeAdmittedBy msg
closedLeading builder =
    Component.searchViewClosedLeading (B.toElement builder)


{-| -}
closedTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewClosedTrailingSlot msg
    -> Element free freeAdmittedBy msg
closedTrailing builder =
    Component.searchViewClosedTrailing (B.toElement builder)


{-| -}
input :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
input builder =
    Component.searchViewInput (B.toElement builder)


{-| -}
openLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewOpenLeadingSlot msg
    -> Element free freeAdmittedBy msg
openLeading builder =
    Component.searchViewOpenLeading (B.toElement builder)


{-| -}
openTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewOpenTrailingSlot msg
    -> Element free freeAdmittedBy msg
openTrailing builder =
    Component.searchViewOpenTrailing (B.toElement builder)


{-| -}
searchIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewSearchIconSlot msg
    -> Element free freeAdmittedBy msg
searchIcon builder =
    Component.searchViewSearchIcon (B.toElement builder)


{-| -}
withClearIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewClearIconSlot msg
    -> Builder attrCaps { s | clearIcon : Available } msg kind
    -> Builder attrCaps { s | clearIcon : Used } msg kind
withClearIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.searchViewClearIcon (B.toElement slotBuilder))) builder_


{-| -}
withCloseIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewCloseIconSlot msg
    -> Builder attrCaps { s | closeIcon : Available } msg kind
    -> Builder attrCaps { s | closeIcon : Used } msg kind
withCloseIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.searchViewCloseIcon (B.toElement slotBuilder))) builder_


{-| -}
withInput :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | input : Available } msg kind
    -> Builder attrCaps { s | input : Used } msg kind
withInput slotBuilder builder_ =
    B.withChild (El.toNode (Component.searchViewInput (B.toElement slotBuilder))) builder_


{-| -}
withSearchIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewSearchIconSlot msg
    -> Builder attrCaps { s | searchIcon : Available } msg kind
    -> Builder attrCaps { s | searchIcon : Used } msg kind
withSearchIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.searchViewSearchIcon (B.toElement slotBuilder))) builder_


{-| -}
withClosedLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewClosedLeadingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withClosedLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.searchViewClosedLeading (B.toElement slotBuilder))) builder_


{-| -}
withClosedTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewClosedTrailingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withClosedTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.searchViewClosedTrailing (B.toElement slotBuilder))) builder_


{-| -}
withOpenLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewOpenLeadingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withOpenLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.searchViewOpenLeading (B.toElement slotBuilder))) builder_


{-| -}
withOpenTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchViewOpenTrailingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withOpenTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.searchViewOpenTrailing (B.toElement slotBuilder))) builder_


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
withClearLabel : String -> Builder { a | clearLabel : Available } slotCaps msg kind -> Builder { a | clearLabel : Used } slotCaps msg kind
withClearLabel value_ =
    B.withAttribute (A.clearLabel value_)


{-| -}
withCloseLabel : String -> Builder { a | closeLabel : Available } slotCaps msg kind -> Builder { a | closeLabel : Used } slotCaps msg kind
withCloseLabel value_ =
    B.withAttribute (A.closeLabel value_)


{-| -}
withContained : Bool -> Builder { a | contained : Available } slotCaps msg kind -> Builder { a | contained : Used } slotCaps msg kind
withContained value_ =
    B.withAttribute (A.contained value_)


{-| -}
withHideSearchIcon : Bool -> Builder { a | hideSearchIcon : Available } slotCaps msg kind -> Builder { a | hideSearchIcon : Used } slotCaps msg kind
withHideSearchIcon value_ =
    B.withAttribute (A.hideSearchIcon value_)


{-| -}
withMode : Value Component.SearchViewMode -> Builder { a | mode : Available } slotCaps msg kind -> Builder { a | mode : Used } slotCaps msg kind
withMode value_ =
    B.withAttribute (Component.searchViewMode value_)


{-| -}
withOpen : Bool -> Builder { a | open : Available } slotCaps msg kind -> Builder { a | open : Used } slotCaps msg kind
withOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
withOnQuery : msg -> Builder { a | onQuery : Available } slotCaps msg kind -> Builder { a | onQuery : Used } slotCaps msg kind
withOnQuery value_ =
    B.withAttribute (Ev.onQuery value_)


{-| -}
withOnClear : msg -> Builder { a | onClear : Available } slotCaps msg kind -> Builder { a | onClear : Used } slotCaps msg kind
withOnClear value_ =
    B.withAttribute (Ev.onClear value_)


{-| -}
withOnBeforetoggle : msg -> Builder { a | onBeforetoggle : Available } slotCaps msg kind -> Builder { a | onBeforetoggle : Used } slotCaps msg kind
withOnBeforetoggle value_ =
    B.withAttribute (Ev.onBeforetoggle value_)


{-| -}
withOnToggle : msg -> Builder { a | onToggle : Available } slotCaps msg kind -> Builder { a | onToggle : Used } slotCaps msg kind
withOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)
