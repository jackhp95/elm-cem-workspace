module M3e.Build.Tabs exposing
    ( build, toElement
    , Builder, AttrCaps, SlotCaps, Is, Content, NextIconSlot, PanelSlot, PrevIconSlot, ChildAdmittedBy
    , withClass, withDisablePagination, withHeaderPosition, withId, withNextPageLabel, withOnBeforeinput, withOnChange, withOnInput, withPreviousPageLabel, withSlot, withStretch, withStyle, withVariant
    , nextIcon, panel, prevIcon
    , withNextIcon, withPrevIcon, withPanel, withChild
    )

{-|

@docs build, toElement
@docs Builder, AttrCaps, SlotCaps, Is, Content, NextIconSlot, PanelSlot, PrevIconSlot, ChildAdmittedBy
@docs withClass, withDisablePagination, withHeaderPosition, withId, withNextPageLabel, withOnBeforeinput, withOnChange, withOnInput, withPreviousPageLabel, withSlot, withStretch, withStyle, withVariant
@docs nextIcon, panel, prevIcon
@docs withNextIcon, withPrevIcon, withPanel, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Component.Tabs as Component
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
type alias NextIconSlot =
    Component.NextIconSlot


{-| -}
type alias PanelSlot =
    Component.PanelSlot


{-| -}
type alias PrevIconSlot =
    Component.PrevIconSlot


{-| -}
build : Builder AttrCaps SlotCaps msg kind
build =
    B.init "m3e-tabs" [] []


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.Is kind) admittedBy msg
toElement =
    B.toElement


{-| -}
nextIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.NextIconSlot msg
    -> Element free freeAdmittedBy msg
nextIcon builder =
    Component.nextIcon (B.toElement builder)


{-| -}
panel :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelSlot msg
    -> Element free freeAdmittedBy msg
panel builder =
    Component.panel (B.toElement builder)


{-| -}
prevIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PrevIconSlot msg
    -> Element free freeAdmittedBy msg
prevIcon builder =
    Component.prevIcon (B.toElement builder)


{-| -}
withNextIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.NextIconSlot msg
    -> Builder attrCaps { s | nextIcon : Available } msg kind
    -> Builder attrCaps { s | nextIcon : Used } msg kind
withNextIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.nextIcon (B.toElement slotBuilder))) builder_


{-| -}
withPrevIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.PrevIconSlot msg
    -> Builder attrCaps { s | prevIcon : Available } msg kind
    -> Builder attrCaps { s | prevIcon : Used } msg kind
withPrevIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.prevIcon (B.toElement slotBuilder))) builder_


{-| -}
withPanel :
    B.Builder childRow childAttrCaps childSlotCaps Component.PanelSlot msg
    -> Builder attrCaps slotCaps msg kind
    -> Builder attrCaps slotCaps msg kind
withPanel slotBuilder builder_ =
    B.withChild (El.toNode (Component.panel (B.toElement slotBuilder))) builder_


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
withDisablePagination : Value Component.DisablePagination -> Builder { a | disablePagination : Available } slotCaps msg kind -> Builder { a | disablePagination : Used } slotCaps msg kind
withDisablePagination value_ =
    B.withAttribute (Component.disablePagination value_)


{-| -}
withHeaderPosition : Value Component.HeaderPosition -> Builder { a | headerPosition : Available } slotCaps msg kind -> Builder { a | headerPosition : Used } slotCaps msg kind
withHeaderPosition value_ =
    B.withAttribute (Component.headerPosition value_)


{-| -}
withNextPageLabel : String -> Builder { a | nextPageLabel : Available } slotCaps msg kind -> Builder { a | nextPageLabel : Used } slotCaps msg kind
withNextPageLabel value_ =
    B.withAttribute (A.nextPageLabel value_)


{-| -}
withPreviousPageLabel : String -> Builder { a | previousPageLabel : Available } slotCaps msg kind -> Builder { a | previousPageLabel : Used } slotCaps msg kind
withPreviousPageLabel value_ =
    B.withAttribute (A.previousPageLabel value_)


{-| -}
withStretch : Bool -> Builder { a | stretch : Available } slotCaps msg kind -> Builder { a | stretch : Used } slotCaps msg kind
withStretch value_ =
    B.withAttribute (A.stretch value_)


{-| -}
withVariant : Value Component.Variant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.variant value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnBeforeinput : msg -> Builder { a | onBeforeinput : Available } slotCaps msg kind -> Builder { a | onBeforeinput : Used } slotCaps msg kind
withOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)
