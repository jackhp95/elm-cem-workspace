module M3e.Build.Autocomplete exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
    , withAutoActivate, withCaseSensitive, withClass, withFilter, withFor, withHideLoading, withHideNoData, withHideSelectionIndicator, withId, withLoading, withLoadingLabel, withNoDataLabel, withOnChange, withOnQuery, withOnToggle, withPanelClass, withRequired, withResultsLabel, withSlot, withStyle
    , loading, noData
    , withLoadingSlot, withNoData, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, ChildAdmittedBy
@docs withAutoActivate, withCaseSensitive, withClass, withFilter, withFor, withHideLoading, withHideNoData, withHideSelectionIndicator, withId, withLoading, withLoadingLabel, withNoDataLabel, withOnChange, withOnQuery, withOnToggle, withPanelClass, withRequired, withResultsLabel, withSlot, withStyle
@docs loading, noData
@docs withLoadingSlot, withNoData, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Component.Autocomplete as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


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
    Component.SlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.ChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.Content


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-autocomplete" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
loading :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
loading builder =
    Component.loading (B.toElement builder)


{-| -}
noData :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
noData builder =
    Component.noData (B.toElement builder)


{-| -}
withLoadingSlot :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | loading : Available } msg kind
    -> Builder attrCaps { s | loading : Used } msg kind
withLoadingSlot slotBuilder builder_ =
    B.withChild (El.toNode (Component.loading (B.toElement slotBuilder))) builder_


{-| -}
withNoData :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | noData : Available } msg kind
    -> Builder attrCaps { s | noData : Used } msg kind
withNoData slotBuilder builder_ =
    B.withChild (El.toNode (Component.noData (B.toElement slotBuilder))) builder_


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
withAutoActivate : Bool -> Builder { a | autoActivate : Available } slotCaps msg kind -> Builder { a | autoActivate : Used } slotCaps msg kind
withAutoActivate value_ =
    B.withAttribute (A.autoActivate value_)


{-| -}
withCaseSensitive : Bool -> Builder { a | caseSensitive : Available } slotCaps msg kind -> Builder { a | caseSensitive : Used } slotCaps msg kind
withCaseSensitive value_ =
    B.withAttribute (A.caseSensitive value_)


{-| -}
withFilter : Value Component.Filter -> Builder { a | filter : Available } slotCaps msg kind -> Builder { a | filter : Used } slotCaps msg kind
withFilter value_ =
    B.withAttribute (Component.filter value_)


{-| -}
withFor : String -> Builder { a | for : Available } slotCaps msg kind -> Builder { a | for : Used } slotCaps msg kind
withFor value_ =
    B.withAttribute (A.for value_)


{-| -}
withHideLoading : Bool -> Builder { a | hideLoading : Available } slotCaps msg kind -> Builder { a | hideLoading : Used } slotCaps msg kind
withHideLoading value_ =
    B.withAttribute (A.hideLoading value_)


{-| -}
withHideNoData : Bool -> Builder { a | hideNoData : Available } slotCaps msg kind -> Builder { a | hideNoData : Used } slotCaps msg kind
withHideNoData value_ =
    B.withAttribute (A.hideNoData value_)


{-| -}
withHideSelectionIndicator : Bool -> Builder { a | hideSelectionIndicator : Available } slotCaps msg kind -> Builder { a | hideSelectionIndicator : Used } slotCaps msg kind
withHideSelectionIndicator value_ =
    B.withAttribute (A.hideSelectionIndicator value_)


{-| -}
withLoading : Bool -> Builder { a | loading : Available } slotCaps msg kind -> Builder { a | loading : Used } slotCaps msg kind
withLoading value_ =
    B.withAttribute (A.loading value_)


{-| -}
withLoadingLabel : String -> Builder { a | loadingLabel : Available } slotCaps msg kind -> Builder { a | loadingLabel : Used } slotCaps msg kind
withLoadingLabel value_ =
    B.withAttribute (A.loadingLabel value_)


{-| -}
withNoDataLabel : String -> Builder { a | noDataLabel : Available } slotCaps msg kind -> Builder { a | noDataLabel : Used } slotCaps msg kind
withNoDataLabel value_ =
    B.withAttribute (A.noDataLabel value_)


{-| -}
withPanelClass : String -> Builder { a | panelClass : Available } slotCaps msg kind -> Builder { a | panelClass : Used } slotCaps msg kind
withPanelClass value_ =
    B.withAttribute (A.panelClass value_)


{-| -}
withRequired : Bool -> Builder { a | required : Available } slotCaps msg kind -> Builder { a | required : Used } slotCaps msg kind
withRequired value_ =
    B.withAttribute (A.required value_)


{-| -}
withResultsLabel : String -> Builder { a | resultsLabel : Available } slotCaps msg kind -> Builder { a | resultsLabel : Used } slotCaps msg kind
withResultsLabel value_ =
    B.withAttribute (A.resultsLabel value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnQuery : msg -> Builder { a | onQuery : Available } slotCaps msg kind -> Builder { a | onQuery : Used } slotCaps msg kind
withOnQuery value_ =
    B.withAttribute (Ev.onQuery value_)


{-| -}
withOnToggle : msg -> Builder { a | onToggle : Available } slotCaps msg kind -> Builder { a | onToggle : Used } slotCaps msg kind
withOnToggle value_ =
    B.withAttribute (Ev.onToggle value_)
