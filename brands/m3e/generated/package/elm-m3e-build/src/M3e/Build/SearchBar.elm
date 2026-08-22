module M3e.Build.SearchBar exposing (Builder, AttrCaps, SlotCaps, Is, ClearIconSlot, LeadingSlot, TrailingSlot, ChildAdmittedBy, build, toElement, withClass, withClearLabel, withClearable, withId, withOnClear, withSlot, withStyle, clearIcon, input, leading, trailing, withClearIcon, withInput, withLeading, withTrailing)

{-| The **SearchBar** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.SearchBar`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, ClearIconSlot, LeadingSlot, TrailingSlot, ChildAdmittedBy, build, toElement, withClass, withClearLabel, withClearable, withId, withOnClear, withSlot, withStyle, clearIcon, input, leading, trailing, withClearIcon, withInput, withLeading, withTrailing

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.SearchBar as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.SearchBarIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.SearchBarBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.SearchBarAttrCaps


{-| -}
type alias SlotCaps =
    Component.SearchBarSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.SearchBarChildAdmittedBy childAdm


{-| -}
type alias ClearIconSlot =
    Component.SearchBarClearIconSlot


{-| -}
type alias LeadingSlot =
    Component.SearchBarLeadingSlot


{-| -}
type alias TrailingSlot =
    Component.SearchBarTrailingSlot


{-| -}
build :
    { input : Element childAccepts (Component.SearchBarChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-search-bar" [] [ El.toNode (Component.searchBarInput required_.input) ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.SearchBarIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
clearIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchBarClearIconSlot msg
    -> Element free freeAdmittedBy msg
clearIcon builder =
    Component.searchBarClearIcon (B.toElement builder)


{-| -}
input :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
input builder =
    Component.searchBarInput (B.toElement builder)


{-| -}
leading :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchBarLeadingSlot msg
    -> Element free freeAdmittedBy msg
leading builder =
    Component.searchBarLeading (B.toElement builder)


{-| -}
trailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchBarTrailingSlot msg
    -> Element free freeAdmittedBy msg
trailing builder =
    Component.searchBarTrailing (B.toElement builder)


{-| -}
withClearIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchBarClearIconSlot msg
    -> Builder attrCaps { s | clearIcon : Available } msg kind
    -> Builder attrCaps { s | clearIcon : Used } msg kind
withClearIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.searchBarClearIcon (B.toElement slotBuilder))) builder_


{-| -}
withInput :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | input : Available } msg kind
    -> Builder attrCaps { s | input : Used } msg kind
withInput slotBuilder builder_ =
    B.withChild (El.toNode (Component.searchBarInput (B.toElement slotBuilder))) builder_


{-| -}
withLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchBarLeadingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.searchBarLeading (B.toElement slotBuilder))) builder_


{-| -}
withTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.SearchBarTrailingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.searchBarTrailing (B.toElement slotBuilder))) builder_


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
withClearable : Bool -> Builder { a | clearable : Available } slotCaps msg kind -> Builder { a | clearable : Used } slotCaps msg kind
withClearable value_ =
    B.withAttribute (A.clearable value_)


{-| -}
withOnClear : msg -> Builder { a | onClear : Available } slotCaps msg kind -> Builder { a | onClear : Used } slotCaps msg kind
withOnClear value_ =
    B.withAttribute (Ev.onClear value_)
