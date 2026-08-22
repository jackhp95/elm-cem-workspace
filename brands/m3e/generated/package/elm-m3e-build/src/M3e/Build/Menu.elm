module M3e.Build.Menu exposing (MenuBuilder, MenuAttrCaps, MenuSlotCaps, MenuIs, MenuContent, MenuChildAdmittedBy, menuBuild, menuToElement, menuWithClass, menuWithId, menuWithOnBeforetoggle, menuWithOnToggle, menuWithPositionX, menuWithPositionY, menuWithSlot, menuWithStyle, menuWithSubmenu, menuWithVariant, menuWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemContent, ItemIconSlot, ItemTrailingIconSlot, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithDisabled, itemWithDownload, itemWithHref, itemWithId, itemWithOnClick, itemWithRel, itemWithSlot, itemWithStyle, itemWithTarget, itemIcon, itemTrailingIcon, itemWithIcon, itemWithTrailingIcon, itemWithChild, ItemCheckboxBuilder, ItemCheckboxAttrCaps, ItemCheckboxSlotCaps, ItemCheckboxIs, ItemCheckboxContent, ItemCheckboxIconSlot, ItemCheckboxTrailingIconSlot, ItemCheckboxChildAdmittedBy, itemCheckboxBuild, itemCheckboxToElement, itemCheckboxWithChecked, itemCheckboxWithClass, itemCheckboxWithDisabled, itemCheckboxWithId, itemCheckboxWithOnClick, itemCheckboxWithSlot, itemCheckboxWithStyle, itemCheckboxIcon, itemCheckboxTrailingIcon, itemCheckboxWithIcon, itemCheckboxWithTrailingIcon, itemCheckboxWithChild, ItemGroupBuilder, ItemGroupAttrCaps, ItemGroupSlotCaps, ItemGroupIs, ItemGroupContent, ItemGroupChildAdmittedBy, itemGroupBuild, itemGroupToElement, itemGroupWithClass, itemGroupWithId, itemGroupWithSlot, itemGroupWithStyle, itemGroupWithChild, ItemRadioBuilder, ItemRadioAttrCaps, ItemRadioSlotCaps, ItemRadioIs, ItemRadioContent, ItemRadioIconSlot, ItemRadioTrailingIconSlot, ItemRadioChildAdmittedBy, itemRadioBuild, itemRadioToElement, itemRadioWithChecked, itemRadioWithClass, itemRadioWithDisabled, itemRadioWithId, itemRadioWithOnClick, itemRadioWithSlot, itemRadioWithStyle, itemRadioIcon, itemRadioTrailingIcon, itemRadioWithIcon, itemRadioWithTrailingIcon, itemRadioWithChild, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerIs, TriggerChildAdmittedBy, triggerBuild, triggerToElement, triggerWithClass, triggerWithFor, triggerWithId, triggerWithSlot, triggerWithStyle, triggerWithChild)

{-| The **Menu** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.Menu`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs MenuBuilder, MenuAttrCaps, MenuSlotCaps, MenuIs, MenuContent, MenuChildAdmittedBy, menuBuild, menuToElement, menuWithClass, menuWithId, menuWithOnBeforetoggle, menuWithOnToggle, menuWithPositionX, menuWithPositionY, menuWithSlot, menuWithStyle, menuWithSubmenu, menuWithVariant, menuWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemContent, ItemIconSlot, ItemTrailingIconSlot, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithDisabled, itemWithDownload, itemWithHref, itemWithId, itemWithOnClick, itemWithRel, itemWithSlot, itemWithStyle, itemWithTarget, itemIcon, itemTrailingIcon, itemWithIcon, itemWithTrailingIcon, itemWithChild, ItemCheckboxBuilder, ItemCheckboxAttrCaps, ItemCheckboxSlotCaps, ItemCheckboxIs, ItemCheckboxContent, ItemCheckboxIconSlot, ItemCheckboxTrailingIconSlot, ItemCheckboxChildAdmittedBy, itemCheckboxBuild, itemCheckboxToElement, itemCheckboxWithChecked, itemCheckboxWithClass, itemCheckboxWithDisabled, itemCheckboxWithId, itemCheckboxWithOnClick, itemCheckboxWithSlot, itemCheckboxWithStyle, itemCheckboxIcon, itemCheckboxTrailingIcon, itemCheckboxWithIcon, itemCheckboxWithTrailingIcon, itemCheckboxWithChild, ItemGroupBuilder, ItemGroupAttrCaps, ItemGroupSlotCaps, ItemGroupIs, ItemGroupContent, ItemGroupChildAdmittedBy, itemGroupBuild, itemGroupToElement, itemGroupWithClass, itemGroupWithId, itemGroupWithSlot, itemGroupWithStyle, itemGroupWithChild, ItemRadioBuilder, ItemRadioAttrCaps, ItemRadioSlotCaps, ItemRadioIs, ItemRadioContent, ItemRadioIconSlot, ItemRadioTrailingIconSlot, ItemRadioChildAdmittedBy, itemRadioBuild, itemRadioToElement, itemRadioWithChecked, itemRadioWithClass, itemRadioWithDisabled, itemRadioWithId, itemRadioWithOnClick, itemRadioWithSlot, itemRadioWithStyle, itemRadioIcon, itemRadioTrailingIcon, itemRadioWithIcon, itemRadioWithTrailingIcon, itemRadioWithChild, TriggerBuilder, TriggerAttrCaps, TriggerSlotCaps, TriggerIs, TriggerChildAdmittedBy, triggerBuild, triggerToElement, triggerWithClass, triggerWithFor, triggerWithId, triggerWithSlot, triggerWithStyle, triggerWithChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.Menu as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias MenuIs s =
    Component.MenuIs s


{-| -}
type alias MenuBuilder attrCaps slotCaps msg kind =
    Component.MenuBuilder attrCaps slotCaps msg kind


{-| -}
type alias MenuAttrCaps =
    Component.MenuAttrCaps


{-| -}
type alias MenuSlotCaps =
    Component.MenuSlotCaps


{-| -}
type alias MenuChildAdmittedBy childAdm =
    Component.MenuChildAdmittedBy childAdm


{-| -}
type alias MenuContent =
    Component.MenuContent


{-| -}
menuBuild : MenuBuilder MenuAttrCaps MenuSlotCaps msg kind
menuBuild =
    B.init "m3e-menu" [] []


{-| -}
menuToElement : MenuBuilder attrCaps slotCaps msg kind -> Element (Component.MenuIs kind) admittedBy msg
menuToElement =
    B.toElement


{-| -}
menuWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> MenuBuilder attrCaps slotCaps msg kind
    -> MenuBuilder attrCaps slotCaps msg kind
menuWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
menuWithClass : String -> MenuBuilder { a | class : Available } slotCaps msg kind -> MenuBuilder { a | class : Used } slotCaps msg kind
menuWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
menuWithId : String -> MenuBuilder { a | id : Available } slotCaps msg kind -> MenuBuilder { a | id : Used } slotCaps msg kind
menuWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
menuWithSlot : String -> MenuBuilder { a | slot : Available } slotCaps msg kind -> MenuBuilder { a | slot : Used } slotCaps msg kind
menuWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
menuWithStyle : String -> String -> MenuBuilder { a | style : Available } slotCaps msg kind -> MenuBuilder { a | style : Used } slotCaps msg kind
menuWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
menuWithPositionX : Value Component.MenuPositionX -> MenuBuilder { a | positionX : Available } slotCaps msg kind -> MenuBuilder { a | positionX : Used } slotCaps msg kind
menuWithPositionX value_ =
    B.withAttribute (Component.menuPositionX value_)


{-| -}
menuWithPositionY : Value Component.MenuPositionY -> MenuBuilder { a | positionY : Available } slotCaps msg kind -> MenuBuilder { a | positionY : Used } slotCaps msg kind
menuWithPositionY value_ =
    B.withAttribute (Component.menuPositionY value_)


{-| -}
menuWithSubmenu : Bool -> MenuBuilder { a | submenu : Available } slotCaps msg kind -> MenuBuilder { a | submenu : Used } slotCaps msg kind
menuWithSubmenu value_ =
    B.withAttribute (A.submenu value_)


{-| -}
menuWithVariant : Value Component.MenuVariant -> MenuBuilder { a | variant : Available } slotCaps msg kind -> MenuBuilder { a | variant : Used } slotCaps msg kind
menuWithVariant value_ =
    B.withAttribute (Component.menuVariant value_)


{-| -}
menuWithOnBeforetoggle : msg -> MenuBuilder { a | onBeforetoggle : Available } slotCaps msg kind -> MenuBuilder { a | onBeforetoggle : Used } slotCaps msg kind
menuWithOnBeforetoggle value_ =
    B.withAttribute (Ev.onBeforetoggle value_)


{-| -}
menuWithOnToggle : (String -> msg) -> MenuBuilder { a | onToggle : Available } slotCaps msg kind -> MenuBuilder { a | onToggle : Used } slotCaps msg kind
menuWithOnToggle value_ =
    B.withAttribute (Component.menuOnToggle value_)


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
type alias ItemTrailingIconSlot =
    Component.ItemTrailingIconSlot


{-| -}
itemBuild : ItemBuilder ItemAttrCaps ItemSlotCaps msg kind
itemBuild =
    B.init "m3e-menu-item" [] []


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
itemTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemTrailingIconSlot msg
    -> Element free freeAdmittedBy msg
itemTrailingIcon builder =
    Component.itemTrailingIcon (B.toElement builder)


{-| -}
itemWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemIconSlot msg
    -> ItemBuilder attrCaps { s | icon : Available } msg kind
    -> ItemBuilder attrCaps { s | icon : Used } msg kind
itemWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemIcon (B.toElement slotBuilder))) builder_


{-| -}
itemWithTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemTrailingIconSlot msg
    -> ItemBuilder attrCaps { s | trailingIcon : Available } msg kind
    -> ItemBuilder attrCaps { s | trailingIcon : Used } msg kind
itemWithTrailingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemTrailingIcon (B.toElement slotBuilder))) builder_


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
itemWithDownload : String -> ItemBuilder { a | download : Available } slotCaps msg kind -> ItemBuilder { a | download : Used } slotCaps msg kind
itemWithDownload value_ =
    B.withAttribute (A.download value_)


{-| -}
itemWithHref : String -> ItemBuilder { a | href : Available } slotCaps msg kind -> ItemBuilder { a | href : Used } slotCaps msg kind
itemWithHref value_ =
    B.withAttribute (A.href value_)


{-| -}
itemWithRel : String -> ItemBuilder { a | rel : Available } slotCaps msg kind -> ItemBuilder { a | rel : Used } slotCaps msg kind
itemWithRel value_ =
    B.withAttribute (A.rel value_)


{-| -}
itemWithTarget : String -> ItemBuilder { a | target : Available } slotCaps msg kind -> ItemBuilder { a | target : Used } slotCaps msg kind
itemWithTarget value_ =
    B.withAttribute (A.target value_)


{-| -}
itemWithOnClick : msg -> ItemBuilder { a | onClick : Available } slotCaps msg kind -> ItemBuilder { a | onClick : Used } slotCaps msg kind
itemWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| -}
type alias ItemCheckboxIs s =
    Component.ItemCheckboxIs s


{-| -}
type alias ItemCheckboxBuilder attrCaps slotCaps msg kind =
    Component.ItemCheckboxBuilder attrCaps slotCaps msg kind


{-| -}
type alias ItemCheckboxAttrCaps =
    Component.ItemCheckboxAttrCaps


{-| -}
type alias ItemCheckboxSlotCaps =
    Component.ItemCheckboxSlotCaps


{-| -}
type alias ItemCheckboxChildAdmittedBy childAdm =
    Component.ItemCheckboxChildAdmittedBy childAdm


{-| -}
type alias ItemCheckboxContent =
    Component.ItemCheckboxContent


{-| -}
type alias ItemCheckboxIconSlot =
    Component.ItemCheckboxIconSlot


{-| -}
type alias ItemCheckboxTrailingIconSlot =
    Component.ItemCheckboxTrailingIconSlot


{-| -}
itemCheckboxBuild : ItemCheckboxBuilder ItemCheckboxAttrCaps ItemCheckboxSlotCaps msg kind
itemCheckboxBuild =
    B.init "m3e-menu-item-checkbox" [] []


{-| -}
itemCheckboxToElement : ItemCheckboxBuilder attrCaps slotCaps msg kind -> Element (Component.ItemCheckboxIs kind) admittedBy msg
itemCheckboxToElement =
    B.toElement


{-| -}
itemCheckboxIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemCheckboxIconSlot msg
    -> Element free freeAdmittedBy msg
itemCheckboxIcon builder =
    Component.itemCheckboxIcon (B.toElement builder)


{-| -}
itemCheckboxTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemCheckboxTrailingIconSlot msg
    -> Element free freeAdmittedBy msg
itemCheckboxTrailingIcon builder =
    Component.itemCheckboxTrailingIcon (B.toElement builder)


{-| -}
itemCheckboxWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemCheckboxIconSlot msg
    -> ItemCheckboxBuilder attrCaps { s | icon : Available } msg kind
    -> ItemCheckboxBuilder attrCaps { s | icon : Used } msg kind
itemCheckboxWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemCheckboxIcon (B.toElement slotBuilder))) builder_


{-| -}
itemCheckboxWithTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemCheckboxTrailingIconSlot msg
    -> ItemCheckboxBuilder attrCaps { s | trailingIcon : Available } msg kind
    -> ItemCheckboxBuilder attrCaps { s | trailingIcon : Used } msg kind
itemCheckboxWithTrailingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemCheckboxTrailingIcon (B.toElement slotBuilder))) builder_


{-| -}
itemCheckboxWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> ItemCheckboxBuilder attrCaps slotCaps msg kind
    -> ItemCheckboxBuilder attrCaps slotCaps msg kind
itemCheckboxWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
itemCheckboxWithClass : String -> ItemCheckboxBuilder { a | class : Available } slotCaps msg kind -> ItemCheckboxBuilder { a | class : Used } slotCaps msg kind
itemCheckboxWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
itemCheckboxWithId : String -> ItemCheckboxBuilder { a | id : Available } slotCaps msg kind -> ItemCheckboxBuilder { a | id : Used } slotCaps msg kind
itemCheckboxWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
itemCheckboxWithSlot : String -> ItemCheckboxBuilder { a | slot : Available } slotCaps msg kind -> ItemCheckboxBuilder { a | slot : Used } slotCaps msg kind
itemCheckboxWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
itemCheckboxWithStyle : String -> String -> ItemCheckboxBuilder { a | style : Available } slotCaps msg kind -> ItemCheckboxBuilder { a | style : Used } slotCaps msg kind
itemCheckboxWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
itemCheckboxWithChecked : Bool -> ItemCheckboxBuilder { a | checked : Available } slotCaps msg kind -> ItemCheckboxBuilder { a | checked : Used } slotCaps msg kind
itemCheckboxWithChecked value_ =
    B.withAttribute (A.checked value_)


{-| -}
itemCheckboxWithDisabled : Bool -> ItemCheckboxBuilder { a | disabled : Available } slotCaps msg kind -> ItemCheckboxBuilder { a | disabled : Used } slotCaps msg kind
itemCheckboxWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
itemCheckboxWithOnClick : msg -> ItemCheckboxBuilder { a | onClick : Available } slotCaps msg kind -> ItemCheckboxBuilder { a | onClick : Used } slotCaps msg kind
itemCheckboxWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| -}
type alias ItemGroupIs s =
    Component.ItemGroupIs s


{-| -}
type alias ItemGroupBuilder attrCaps slotCaps msg kind =
    Component.ItemGroupBuilder attrCaps slotCaps msg kind


{-| -}
type alias ItemGroupAttrCaps =
    Component.ItemGroupAttrCaps


{-| -}
type alias ItemGroupSlotCaps =
    Component.ItemGroupSlotCaps


{-| -}
type alias ItemGroupChildAdmittedBy childAdm =
    Component.ItemGroupChildAdmittedBy childAdm


{-| -}
type alias ItemGroupContent =
    Component.ItemGroupContent


{-| -}
itemGroupBuild : ItemGroupBuilder ItemGroupAttrCaps ItemGroupSlotCaps msg kind
itemGroupBuild =
    B.init "m3e-menu-item-group" [] []


{-| -}
itemGroupToElement : ItemGroupBuilder attrCaps slotCaps msg kind -> Element (Component.ItemGroupIs kind) admittedBy msg
itemGroupToElement =
    B.toElement


{-| -}
itemGroupWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> ItemGroupBuilder attrCaps slotCaps msg kind
    -> ItemGroupBuilder attrCaps slotCaps msg kind
itemGroupWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
itemGroupWithClass : String -> ItemGroupBuilder { a | class : Available } slotCaps msg kind -> ItemGroupBuilder { a | class : Used } slotCaps msg kind
itemGroupWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
itemGroupWithId : String -> ItemGroupBuilder { a | id : Available } slotCaps msg kind -> ItemGroupBuilder { a | id : Used } slotCaps msg kind
itemGroupWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
itemGroupWithSlot : String -> ItemGroupBuilder { a | slot : Available } slotCaps msg kind -> ItemGroupBuilder { a | slot : Used } slotCaps msg kind
itemGroupWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
itemGroupWithStyle : String -> String -> ItemGroupBuilder { a | style : Available } slotCaps msg kind -> ItemGroupBuilder { a | style : Used } slotCaps msg kind
itemGroupWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
type alias ItemRadioIs s =
    Component.ItemRadioIs s


{-| -}
type alias ItemRadioBuilder attrCaps slotCaps msg kind =
    Component.ItemRadioBuilder attrCaps slotCaps msg kind


{-| -}
type alias ItemRadioAttrCaps =
    Component.ItemRadioAttrCaps


{-| -}
type alias ItemRadioSlotCaps =
    Component.ItemRadioSlotCaps


{-| -}
type alias ItemRadioChildAdmittedBy childAdm =
    Component.ItemRadioChildAdmittedBy childAdm


{-| -}
type alias ItemRadioContent =
    Component.ItemRadioContent


{-| -}
type alias ItemRadioIconSlot =
    Component.ItemRadioIconSlot


{-| -}
type alias ItemRadioTrailingIconSlot =
    Component.ItemRadioTrailingIconSlot


{-| -}
itemRadioBuild : ItemRadioBuilder ItemRadioAttrCaps ItemRadioSlotCaps msg kind
itemRadioBuild =
    B.init "m3e-menu-item-radio" [] []


{-| -}
itemRadioToElement : ItemRadioBuilder attrCaps slotCaps msg kind -> Element (Component.ItemRadioIs kind) admittedBy msg
itemRadioToElement =
    B.toElement


{-| -}
itemRadioIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemRadioIconSlot msg
    -> Element free freeAdmittedBy msg
itemRadioIcon builder =
    Component.itemRadioIcon (B.toElement builder)


{-| -}
itemRadioTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemRadioTrailingIconSlot msg
    -> Element free freeAdmittedBy msg
itemRadioTrailingIcon builder =
    Component.itemRadioTrailingIcon (B.toElement builder)


{-| -}
itemRadioWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemRadioIconSlot msg
    -> ItemRadioBuilder attrCaps { s | icon : Available } msg kind
    -> ItemRadioBuilder attrCaps { s | icon : Used } msg kind
itemRadioWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemRadioIcon (B.toElement slotBuilder))) builder_


{-| -}
itemRadioWithTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemRadioTrailingIconSlot msg
    -> ItemRadioBuilder attrCaps { s | trailingIcon : Available } msg kind
    -> ItemRadioBuilder attrCaps { s | trailingIcon : Used } msg kind
itemRadioWithTrailingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemRadioTrailingIcon (B.toElement slotBuilder))) builder_


{-| -}
itemRadioWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> ItemRadioBuilder attrCaps slotCaps msg kind
    -> ItemRadioBuilder attrCaps slotCaps msg kind
itemRadioWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
itemRadioWithClass : String -> ItemRadioBuilder { a | class : Available } slotCaps msg kind -> ItemRadioBuilder { a | class : Used } slotCaps msg kind
itemRadioWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
itemRadioWithId : String -> ItemRadioBuilder { a | id : Available } slotCaps msg kind -> ItemRadioBuilder { a | id : Used } slotCaps msg kind
itemRadioWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
itemRadioWithSlot : String -> ItemRadioBuilder { a | slot : Available } slotCaps msg kind -> ItemRadioBuilder { a | slot : Used } slotCaps msg kind
itemRadioWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
itemRadioWithStyle : String -> String -> ItemRadioBuilder { a | style : Available } slotCaps msg kind -> ItemRadioBuilder { a | style : Used } slotCaps msg kind
itemRadioWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
itemRadioWithChecked : Bool -> ItemRadioBuilder { a | checked : Available } slotCaps msg kind -> ItemRadioBuilder { a | checked : Used } slotCaps msg kind
itemRadioWithChecked value_ =
    B.withAttribute (A.checked value_)


{-| -}
itemRadioWithDisabled : Bool -> ItemRadioBuilder { a | disabled : Available } slotCaps msg kind -> ItemRadioBuilder { a | disabled : Used } slotCaps msg kind
itemRadioWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
itemRadioWithOnClick : msg -> ItemRadioBuilder { a | onClick : Available } slotCaps msg kind -> ItemRadioBuilder { a | onClick : Used } slotCaps msg kind
itemRadioWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| -}
type alias TriggerIs s =
    Component.TriggerIs s


{-| -}
type alias TriggerBuilder attrCaps slotCaps msg kind =
    Component.TriggerBuilder attrCaps slotCaps msg kind


{-| -}
type alias TriggerAttrCaps =
    Component.TriggerAttrCaps


{-| -}
type alias TriggerSlotCaps =
    Component.TriggerSlotCaps


{-| -}
type alias TriggerChildAdmittedBy childAdm =
    Component.TriggerChildAdmittedBy childAdm


{-| -}
triggerBuild : TriggerBuilder TriggerAttrCaps TriggerSlotCaps msg kind
triggerBuild =
    B.init "m3e-menu-trigger" [] []


{-| -}
triggerToElement : TriggerBuilder attrCaps slotCaps msg kind -> Element (Component.TriggerIs kind) admittedBy msg
triggerToElement =
    B.toElement


{-| -}
triggerWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> TriggerBuilder attrCaps slotCaps msg kind
    -> TriggerBuilder attrCaps slotCaps msg kind
triggerWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
triggerWithClass : String -> TriggerBuilder { a | class : Available } slotCaps msg kind -> TriggerBuilder { a | class : Used } slotCaps msg kind
triggerWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
triggerWithId : String -> TriggerBuilder { a | id : Available } slotCaps msg kind -> TriggerBuilder { a | id : Used } slotCaps msg kind
triggerWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
triggerWithSlot : String -> TriggerBuilder { a | slot : Available } slotCaps msg kind -> TriggerBuilder { a | slot : Used } slotCaps msg kind
triggerWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
triggerWithStyle : String -> String -> TriggerBuilder { a | style : Available } slotCaps msg kind -> TriggerBuilder { a | style : Used } slotCaps msg kind
triggerWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
triggerWithFor : String -> TriggerBuilder { a | for : Available } slotCaps msg kind -> TriggerBuilder { a | for : Used } slotCaps msg kind
triggerWithFor value_ =
    B.withAttribute (A.for value_)
