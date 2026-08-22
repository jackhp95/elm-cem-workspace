module M3e.Build.Tree exposing (TreeBuilder, TreeAttrCaps, TreeSlotCaps, TreeIs, TreeContent, TreeChildAdmittedBy, treeBuild, treeToElement, treeWithCascade, treeWithClass, treeWithId, treeWithMulti, treeWithOnChange, treeWithSlot, treeWithStyle, treeWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemContent, ItemIconSlot, ItemLabelSlot, ItemOpenToggleIconSlot, ItemSelectedIconSlot, ItemToggleIconSlot, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithDisabled, itemWithId, itemWithIndeterminate, itemWithOnClick, itemWithOnClosed, itemWithOnClosing, itemWithOnOpened, itemWithOnOpening, itemWithOpen, itemWithSelected, itemWithSlot, itemWithStyle, itemIcon, itemLabel, itemOpenToggleIcon, itemSelectedIcon, itemToggleIcon, itemWithIcon, itemWithLabel, itemWithOpenToggleIcon, itemWithSelectedIcon, itemWithToggleIcon, itemWithChild)

{-| The **Tree** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.Tree`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs TreeBuilder, TreeAttrCaps, TreeSlotCaps, TreeIs, TreeContent, TreeChildAdmittedBy, treeBuild, treeToElement, treeWithCascade, treeWithClass, treeWithId, treeWithMulti, treeWithOnChange, treeWithSlot, treeWithStyle, treeWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemContent, ItemIconSlot, ItemLabelSlot, ItemOpenToggleIconSlot, ItemSelectedIconSlot, ItemToggleIconSlot, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithDisabled, itemWithId, itemWithIndeterminate, itemWithOnClick, itemWithOnClosed, itemWithOnClosing, itemWithOnOpened, itemWithOnOpening, itemWithOpen, itemWithSelected, itemWithSlot, itemWithStyle, itemIcon, itemLabel, itemOpenToggleIcon, itemSelectedIcon, itemToggleIcon, itemWithIcon, itemWithLabel, itemWithOpenToggleIcon, itemWithSelectedIcon, itemWithToggleIcon, itemWithChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Tree as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias TreeIs s =
    Component.TreeIs s


{-| -}
type alias TreeBuilder attrCaps slotCaps msg kind =
    Component.TreeBuilder attrCaps slotCaps msg kind


{-| -}
type alias TreeAttrCaps =
    Component.TreeAttrCaps


{-| -}
type alias TreeSlotCaps =
    Component.TreeSlotCaps


{-| -}
type alias TreeChildAdmittedBy childAdm =
    Component.TreeChildAdmittedBy childAdm


{-| -}
type alias TreeContent =
    Component.TreeContent


{-| -}
treeBuild : TreeBuilder TreeAttrCaps TreeSlotCaps msg kind
treeBuild =
    B.init "m3e-tree" [] []


{-| -}
treeToElement : TreeBuilder attrCaps slotCaps msg kind -> Element (Component.TreeIs kind) admittedBy msg
treeToElement =
    B.toElement


{-| -}
treeWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> TreeBuilder attrCaps slotCaps msg kind
    -> TreeBuilder attrCaps slotCaps msg kind
treeWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
treeWithClass : String -> TreeBuilder { a | class : Available } slotCaps msg kind -> TreeBuilder { a | class : Used } slotCaps msg kind
treeWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
treeWithId : String -> TreeBuilder { a | id : Available } slotCaps msg kind -> TreeBuilder { a | id : Used } slotCaps msg kind
treeWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
treeWithSlot : String -> TreeBuilder { a | slot : Available } slotCaps msg kind -> TreeBuilder { a | slot : Used } slotCaps msg kind
treeWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
treeWithStyle : String -> String -> TreeBuilder { a | style : Available } slotCaps msg kind -> TreeBuilder { a | style : Used } slotCaps msg kind
treeWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
treeWithCascade : Bool -> TreeBuilder { a | cascade : Available } slotCaps msg kind -> TreeBuilder { a | cascade : Used } slotCaps msg kind
treeWithCascade value_ =
    B.withAttribute (A.cascade value_)


{-| -}
treeWithMulti : Bool -> TreeBuilder { a | multi : Available } slotCaps msg kind -> TreeBuilder { a | multi : Used } slotCaps msg kind
treeWithMulti value_ =
    B.withAttribute (A.multi value_)


{-| -}
treeWithOnChange : msg -> TreeBuilder { a | onChange : Available } slotCaps msg kind -> TreeBuilder { a | onChange : Used } slotCaps msg kind
treeWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


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
type alias ItemIconSlot =
    Component.ItemIconSlot


{-| -}
type alias ItemLabelSlot =
    Component.ItemLabelSlot


{-| -}
type alias ItemOpenToggleIconSlot =
    Component.ItemOpenToggleIconSlot


{-| -}
type alias ItemSelectedIconSlot =
    Component.ItemSelectedIconSlot


{-| -}
type alias ItemToggleIconSlot =
    Component.ItemToggleIconSlot


{-| -}
itemBuild :
    { label : Element Component.ItemLabelSlot (Component.ItemChildAdmittedBy childAdm) msg }
    -> ItemBuilder ItemAttrCaps ItemSlotCaps msg kind
itemBuild required_ =
    B.init "m3e-tree-item" [] [ El.toNode (Component.itemLabel required_.label) ]


{-| -}
itemToElement : ItemBuilder attrCaps slotCaps msg kind -> Element (Component.ItemIs kind) admittedBy msg
itemToElement =
    B.toElement


{-| -}
itemIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemIconSlot msg
    -> Element free freeAdmittedBy msg
itemIcon builder =
    Component.itemIcon (B.toElement builder)


{-| -}
itemLabel :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemLabelSlot msg
    -> Element free freeAdmittedBy msg
itemLabel builder =
    Component.itemLabel (B.toElement builder)


{-| -}
itemOpenToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemOpenToggleIconSlot msg
    -> Element free freeAdmittedBy msg
itemOpenToggleIcon builder =
    Component.itemOpenToggleIcon (B.toElement builder)


{-| -}
itemSelectedIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemSelectedIconSlot msg
    -> Element free freeAdmittedBy msg
itemSelectedIcon builder =
    Component.itemSelectedIcon (B.toElement builder)


{-| -}
itemToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemToggleIconSlot msg
    -> Element free freeAdmittedBy msg
itemToggleIcon builder =
    Component.itemToggleIcon (B.toElement builder)


{-| -}
itemWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemIconSlot msg
    -> ItemBuilder attrCaps { s | icon : Available } msg kind
    -> ItemBuilder attrCaps { s | icon : Used } msg kind
itemWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemIcon (B.toElement slotBuilder))) builder_


{-| -}
itemWithLabel :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemLabelSlot msg
    -> ItemBuilder attrCaps { s | label : Available } msg kind
    -> ItemBuilder attrCaps { s | label : Used } msg kind
itemWithLabel slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemLabel (B.toElement slotBuilder))) builder_


{-| -}
itemWithOpenToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemOpenToggleIconSlot msg
    -> ItemBuilder attrCaps { s | openToggleIcon : Available } msg kind
    -> ItemBuilder attrCaps { s | openToggleIcon : Used } msg kind
itemWithOpenToggleIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemOpenToggleIcon (B.toElement slotBuilder))) builder_


{-| -}
itemWithSelectedIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemSelectedIconSlot msg
    -> ItemBuilder attrCaps { s | selectedIcon : Available } msg kind
    -> ItemBuilder attrCaps { s | selectedIcon : Used } msg kind
itemWithSelectedIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemSelectedIcon (B.toElement slotBuilder))) builder_


{-| -}
itemWithToggleIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemToggleIconSlot msg
    -> ItemBuilder attrCaps { s | toggleIcon : Available } msg kind
    -> ItemBuilder attrCaps { s | toggleIcon : Used } msg kind
itemWithToggleIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemToggleIcon (B.toElement slotBuilder))) builder_


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
itemWithIndeterminate : Bool -> ItemBuilder { a | indeterminate : Available } slotCaps msg kind -> ItemBuilder { a | indeterminate : Used } slotCaps msg kind
itemWithIndeterminate value_ =
    B.withAttribute (A.indeterminate value_)


{-| -}
itemWithOpen : Bool -> ItemBuilder { a | open : Available } slotCaps msg kind -> ItemBuilder { a | open : Used } slotCaps msg kind
itemWithOpen value_ =
    B.withAttribute (A.open value_)


{-| -}
itemWithSelected : Bool -> ItemBuilder { a | selected : Available } slotCaps msg kind -> ItemBuilder { a | selected : Used } slotCaps msg kind
itemWithSelected value_ =
    B.withAttribute (A.selected value_)


{-| -}
itemWithOnOpening : msg -> ItemBuilder { a | onOpening : Available } slotCaps msg kind -> ItemBuilder { a | onOpening : Used } slotCaps msg kind
itemWithOnOpening value_ =
    B.withAttribute (Ev.onOpening value_)


{-| -}
itemWithOnOpened : msg -> ItemBuilder { a | onOpened : Available } slotCaps msg kind -> ItemBuilder { a | onOpened : Used } slotCaps msg kind
itemWithOnOpened value_ =
    B.withAttribute (Ev.onOpened value_)


{-| -}
itemWithOnClosing : msg -> ItemBuilder { a | onClosing : Available } slotCaps msg kind -> ItemBuilder { a | onClosing : Used } slotCaps msg kind
itemWithOnClosing value_ =
    B.withAttribute (Ev.onClosing value_)


{-| -}
itemWithOnClosed : msg -> ItemBuilder { a | onClosed : Available } slotCaps msg kind -> ItemBuilder { a | onClosed : Used } slotCaps msg kind
itemWithOnClosed value_ =
    B.withAttribute (Ev.onClosed value_)


{-| -}
itemWithOnClick : msg -> ItemBuilder { a | onClick : Available } slotCaps msg kind -> ItemBuilder { a | onClick : Used } slotCaps msg kind
itemWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)
