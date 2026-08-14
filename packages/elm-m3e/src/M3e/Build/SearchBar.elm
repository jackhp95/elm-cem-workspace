module M3e.Build.SearchBar exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, ClearIconSlot, LeadingSlot, TrailingSlot, ChildAdmittedBy
    , withClass, withClearLabel, withClearable, withId, withOnClear, withSlot, withStyle
    , clearIcon, input, leading, trailing
    , withClearIcon, withInput, withLeading, withTrailing
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, ClearIconSlot, LeadingSlot, TrailingSlot, ChildAdmittedBy
@docs withClass, withClearLabel, withClearable, withId, withOnClear, withSlot, withStyle
@docs clearIcon, input, leading, trailing
@docs withClearIcon, withInput, withLeading, withTrailing

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import M3e.Attributes as A
import M3e.Component.SearchBar as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Internal.Types.SearchBar
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| -}
type alias Is s =
    M3e.Internal.Types.SearchBar.Is s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.SearchBar.Builder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    M3e.Internal.Types.SearchBar.AttrCaps


{-| -}
type alias SlotCaps =
    M3e.Internal.Types.SearchBar.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.SearchBar.ChildAdmittedBy childAdm


{-| -}
type alias ClearIconSlot =
    M3e.Internal.Types.SearchBar.ClearIconSlot


{-| -}
type alias LeadingSlot =
    M3e.Internal.Types.SearchBar.LeadingSlot


{-| -}
type alias TrailingSlot =
    M3e.Internal.Types.SearchBar.TrailingSlot


{-| -}
build :
    { input : Element childAccepts (Component.ChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-search-bar" [] [ El.toNode (Component.input required_.input) ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
clearIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ClearIconSlot msg
    -> Element free freeAdmittedBy msg
clearIcon builder =
    Component.clearIcon (B.toElement builder)


{-| -}
input :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
input builder =
    Component.input (B.toElement builder)


{-| -}
leading :
    B.Builder childRow childAttrCaps childSlotCaps Component.LeadingSlot msg
    -> Element free freeAdmittedBy msg
leading builder =
    Component.leading (B.toElement builder)


{-| -}
trailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.TrailingSlot msg
    -> Element free freeAdmittedBy msg
trailing builder =
    Component.trailing (B.toElement builder)


{-| -}
withClearIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ClearIconSlot msg
    -> Builder attrCaps { s | clearIcon : Available } msg kind
    -> Builder attrCaps { s | clearIcon : Used } msg kind
withClearIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.clearIcon (B.toElement slotBuilder))) builder_


{-| -}
withInput :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | input : Available } msg kind
    -> Builder attrCaps { s | input : Used } msg kind
withInput slotBuilder builder_ =
    B.withChild (El.toNode (Component.input (B.toElement slotBuilder))) builder_


{-| -}
withLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.LeadingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.leading (B.toElement slotBuilder))) builder_


{-| -}
withTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.TrailingSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.trailing (B.toElement slotBuilder))) builder_


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
