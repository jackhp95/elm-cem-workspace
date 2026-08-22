module M3e.Build.Toc exposing (TocBuilder, TocAttrCaps, TocSlotCaps, TocIs, TocOverlineSlot, TocTitleSlot, TocChildAdmittedBy, tocBuild, tocToElement, tocWithClass, tocWithFor, tocWithId, tocWithMaxDepth, tocWithSlot, tocWithStyle, tocOverline, tocTitle, tocWithOverline, tocWithTitle, tocWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemContent, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithDisabled, itemWithId, itemWithOnClick, itemWithSelected, itemWithSlot, itemWithStyle, itemWithChild)

{-| The **Toc** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.Toc`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs TocBuilder, TocAttrCaps, TocSlotCaps, TocIs, TocOverlineSlot, TocTitleSlot, TocChildAdmittedBy, tocBuild, tocToElement, tocWithClass, tocWithFor, tocWithId, tocWithMaxDepth, tocWithSlot, tocWithStyle, tocOverline, tocTitle, tocWithOverline, tocWithTitle, tocWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemContent, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithDisabled, itemWithId, itemWithOnClick, itemWithSelected, itemWithSlot, itemWithStyle, itemWithChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Toc as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias TocIs s =
    Component.TocIs s


{-| -}
type alias TocBuilder attrCaps slotCaps msg kind =
    Component.TocBuilder attrCaps slotCaps msg kind


{-| -}
type alias TocAttrCaps =
    Component.TocAttrCaps


{-| -}
type alias TocSlotCaps =
    Component.TocSlotCaps


{-| -}
type alias TocChildAdmittedBy childAdm =
    Component.TocChildAdmittedBy childAdm


{-| -}
type alias TocOverlineSlot =
    Component.TocOverlineSlot


{-| -}
type alias TocTitleSlot =
    Component.TocTitleSlot


{-| -}
tocBuild : TocBuilder TocAttrCaps TocSlotCaps msg kind
tocBuild =
    B.init "m3e-toc" [] []


{-| -}
tocToElement : TocBuilder attrCaps slotCaps msg kind -> Element (Component.TocIs kind) admittedBy msg
tocToElement =
    B.toElement


{-| -}
tocOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.TocOverlineSlot msg
    -> Element free freeAdmittedBy msg
tocOverline builder =
    Component.tocOverline (B.toElement builder)


{-| -}
tocTitle :
    B.Builder childRow childAttrCaps childSlotCaps Component.TocTitleSlot msg
    -> Element free freeAdmittedBy msg
tocTitle builder =
    Component.tocTitle (B.toElement builder)


{-| -}
tocWithOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.TocOverlineSlot msg
    -> TocBuilder attrCaps { s | overline : Available } msg kind
    -> TocBuilder attrCaps { s | overline : Used } msg kind
tocWithOverline slotBuilder builder_ =
    B.withChild (El.toNode (Component.tocOverline (B.toElement slotBuilder))) builder_


{-| -}
tocWithTitle :
    B.Builder childRow childAttrCaps childSlotCaps Component.TocTitleSlot msg
    -> TocBuilder attrCaps { s | title : Available } msg kind
    -> TocBuilder attrCaps { s | title : Used } msg kind
tocWithTitle slotBuilder builder_ =
    B.withChild (El.toNode (Component.tocTitle (B.toElement slotBuilder))) builder_


{-| -}
tocWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> TocBuilder attrCaps slotCaps msg kind
    -> TocBuilder attrCaps slotCaps msg kind
tocWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
tocWithClass : String -> TocBuilder { a | class : Available } slotCaps msg kind -> TocBuilder { a | class : Used } slotCaps msg kind
tocWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
tocWithId : String -> TocBuilder { a | id : Available } slotCaps msg kind -> TocBuilder { a | id : Used } slotCaps msg kind
tocWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
tocWithSlot : String -> TocBuilder { a | slot : Available } slotCaps msg kind -> TocBuilder { a | slot : Used } slotCaps msg kind
tocWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
tocWithStyle : String -> String -> TocBuilder { a | style : Available } slotCaps msg kind -> TocBuilder { a | style : Used } slotCaps msg kind
tocWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
tocWithFor : String -> TocBuilder { a | for : Available } slotCaps msg kind -> TocBuilder { a | for : Used } slotCaps msg kind
tocWithFor value_ =
    B.withAttribute (A.for value_)


{-| -}
tocWithMaxDepth : Float -> TocBuilder { a | maxDepth : Available } slotCaps msg kind -> TocBuilder { a | maxDepth : Used } slotCaps msg kind
tocWithMaxDepth value_ =
    B.withAttribute (A.maxDepth value_)


{-| -}
type alias ItemIs s =
    Component.ItemIs s


{-| -}
type alias ItemBuilder attrCaps slotCaps msg kind =
    Component.ItemBuilder attrCaps slotCaps msg kind


{-| -}
type alias ItemAttrCaps =
    Component.ItemAttrCaps


{-| -}
type alias ItemSlotCaps =
    Component.ItemSlotCaps


{-| -}
type alias ItemChildAdmittedBy childAdm =
    Component.ItemChildAdmittedBy childAdm


{-| -}
type alias ItemContent =
    Component.ItemContent


{-| -}
itemBuild :
    { content : Element Component.ItemContent (Component.ItemChildAdmittedBy childAdm) msg }
    -> ItemBuilder ItemAttrCaps ItemSlotCaps msg kind
itemBuild required_ =
    B.init "m3e-toc-item" [] [ El.toNode required_.content ]


{-| -}
itemToElement : ItemBuilder attrCaps slotCaps msg kind -> Element (Component.ItemIs kind) admittedBy msg
itemToElement =
    B.toElement


{-| -}
itemWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> ItemBuilder attrCaps slotCaps msg kind
    -> ItemBuilder attrCaps slotCaps msg kind
itemWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
itemWithClass : String -> ItemBuilder { a | class : Available } slotCaps msg kind -> ItemBuilder { a | class : Used } slotCaps msg kind
itemWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
itemWithId : String -> ItemBuilder { a | id : Available } slotCaps msg kind -> ItemBuilder { a | id : Used } slotCaps msg kind
itemWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
itemWithSlot : String -> ItemBuilder { a | slot : Available } slotCaps msg kind -> ItemBuilder { a | slot : Used } slotCaps msg kind
itemWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
itemWithStyle : String -> String -> ItemBuilder { a | style : Available } slotCaps msg kind -> ItemBuilder { a | style : Used } slotCaps msg kind
itemWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
itemWithDisabled : Bool -> ItemBuilder { a | disabled : Available } slotCaps msg kind -> ItemBuilder { a | disabled : Used } slotCaps msg kind
itemWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
itemWithSelected : Bool -> ItemBuilder { a | selected : Available } slotCaps msg kind -> ItemBuilder { a | selected : Used } slotCaps msg kind
itemWithSelected value_ =
    B.withAttribute (A.selected value_)


{-| -}
itemWithOnClick : msg -> ItemBuilder { a | onClick : Available } slotCaps msg kind -> ItemBuilder { a | onClick : Used } slotCaps msg kind
itemWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)
