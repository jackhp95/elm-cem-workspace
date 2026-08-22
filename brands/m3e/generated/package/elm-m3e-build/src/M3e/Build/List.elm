module M3e.Build.List exposing (ListBuilder, ListAttrCaps, ListSlotCaps, ListIs, ListContent, ListChildAdmittedBy, listBuild, listToElement, listWithClass, listWithId, listWithSlot, listWithStyle, listWithVariant, listWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemContent, ItemLeadingSlot, ItemOverlineSlot, ItemSupportingTextSlot, ItemTrailingSlot, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithId, itemWithSlot, itemWithStyle, itemLeading, itemOverline, itemSupportingText, itemTrailing, itemWithLeading, itemWithOverline, itemWithSupportingText, itemWithTrailing, itemWithChild, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionIs, ActionContent, ActionLeadingSlot, ActionOverlineSlot, ActionSupportingTextSlot, ActionTrailingSlot, ActionChildAdmittedBy, actionBuild, actionToElement, actionWithClass, actionWithDisabled, actionWithDownload, actionWithHref, actionWithId, actionWithOnClick, actionWithRel, actionWithSlot, actionWithStyle, actionWithTarget, actionLeading, actionOverline, actionSupportingText, actionTrailing, actionWithLeading, actionWithOverline, actionWithSupportingText, actionWithTrailing, actionWithChild, OptionBuilder, OptionAttrCaps, OptionSlotCaps, OptionIs, OptionContent, OptionLeadingSlot, OptionOverlineSlot, OptionSupportingTextSlot, OptionTrailingSlot, OptionChildAdmittedBy, optionBuild, optionToElement, optionWithClass, optionWithDisabled, optionWithId, optionWithOnBeforeinput, optionWithOnChange, optionWithOnClick, optionWithOnInput, optionWithSelected, optionWithSlot, optionWithStyle, optionWithValue, optionLeading, optionOverline, optionSupportingText, optionTrailing, optionWithLeading, optionWithOverline, optionWithSupportingText, optionWithTrailing, optionWithChild)

{-| The **List** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.List`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs ListBuilder, ListAttrCaps, ListSlotCaps, ListIs, ListContent, ListChildAdmittedBy, listBuild, listToElement, listWithClass, listWithId, listWithSlot, listWithStyle, listWithVariant, listWithChild, ItemBuilder, ItemAttrCaps, ItemSlotCaps, ItemIs, ItemContent, ItemLeadingSlot, ItemOverlineSlot, ItemSupportingTextSlot, ItemTrailingSlot, ItemChildAdmittedBy, itemBuild, itemToElement, itemWithClass, itemWithId, itemWithSlot, itemWithStyle, itemLeading, itemOverline, itemSupportingText, itemTrailing, itemWithLeading, itemWithOverline, itemWithSupportingText, itemWithTrailing, itemWithChild, ActionBuilder, ActionAttrCaps, ActionSlotCaps, ActionIs, ActionContent, ActionLeadingSlot, ActionOverlineSlot, ActionSupportingTextSlot, ActionTrailingSlot, ActionChildAdmittedBy, actionBuild, actionToElement, actionWithClass, actionWithDisabled, actionWithDownload, actionWithHref, actionWithId, actionWithOnClick, actionWithRel, actionWithSlot, actionWithStyle, actionWithTarget, actionLeading, actionOverline, actionSupportingText, actionTrailing, actionWithLeading, actionWithOverline, actionWithSupportingText, actionWithTrailing, actionWithChild, OptionBuilder, OptionAttrCaps, OptionSlotCaps, OptionIs, OptionContent, OptionLeadingSlot, OptionOverlineSlot, OptionSupportingTextSlot, OptionTrailingSlot, OptionChildAdmittedBy, optionBuild, optionToElement, optionWithClass, optionWithDisabled, optionWithId, optionWithOnBeforeinput, optionWithOnChange, optionWithOnClick, optionWithOnInput, optionWithSelected, optionWithSlot, optionWithStyle, optionWithValue, optionLeading, optionOverline, optionSupportingText, optionTrailing, optionWithLeading, optionWithOverline, optionWithSupportingText, optionWithTrailing, optionWithChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Attributes as A
import M3e.Component.List as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias ListIs s =
    Component.ListIs s


{-| -}
type alias ListBuilder attrCaps slotCaps msg kind =
    Component.ListBuilder attrCaps slotCaps msg kind


{-| -}
type alias ListAttrCaps =
    Component.ListAttrCaps


{-| -}
type alias ListSlotCaps =
    Component.ListSlotCaps


{-| -}
type alias ListChildAdmittedBy childAdm =
    Component.ListChildAdmittedBy childAdm


{-| -}
type alias ListContent =
    Component.ListContent


{-| -}
listBuild : ListBuilder ListAttrCaps ListSlotCaps msg kind
listBuild =
    B.init "m3e-list" [] []


{-| -}
listToElement : ListBuilder attrCaps slotCaps msg kind -> Element (Component.ListIs kind) admittedBy msg
listToElement =
    B.toElement


{-| -}
listWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> ListBuilder attrCaps slotCaps msg kind
    -> ListBuilder attrCaps slotCaps msg kind
listWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
listWithClass : String -> ListBuilder { a | class : Available } slotCaps msg kind -> ListBuilder { a | class : Used } slotCaps msg kind
listWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
listWithId : String -> ListBuilder { a | id : Available } slotCaps msg kind -> ListBuilder { a | id : Used } slotCaps msg kind
listWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
listWithSlot : String -> ListBuilder { a | slot : Available } slotCaps msg kind -> ListBuilder { a | slot : Used } slotCaps msg kind
listWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
listWithStyle : String -> String -> ListBuilder { a | style : Available } slotCaps msg kind -> ListBuilder { a | style : Used } slotCaps msg kind
listWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
listWithVariant : Value Component.ListVariant -> ListBuilder { a | variant : Available } slotCaps msg kind -> ListBuilder { a | variant : Used } slotCaps msg kind
listWithVariant value_ =
    B.withAttribute (Component.listVariant value_)


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
type alias ItemLeadingSlot =
    Component.ItemLeadingSlot


{-| -}
type alias ItemOverlineSlot =
    Component.ItemOverlineSlot


{-| -}
type alias ItemSupportingTextSlot =
    Component.ItemSupportingTextSlot


{-| -}
type alias ItemTrailingSlot =
    Component.ItemTrailingSlot


{-| -}
itemBuild : ItemBuilder ItemAttrCaps ItemSlotCaps msg kind
itemBuild =
    B.init "m3e-list-item" [] []


{-| -}
itemToElement : ItemBuilder attrCaps slotCaps msg kind -> Element (Component.ItemIs kind) admittedBy msg
itemToElement =
    B.toElement


{-| -}
itemLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemLeadingSlot msg
    -> Element free freeAdmittedBy msg
itemLeading builder =
    Component.itemLeading (B.toElement builder)


{-| -}
itemOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemOverlineSlot msg
    -> Element free freeAdmittedBy msg
itemOverline builder =
    Component.itemOverline (B.toElement builder)


{-| -}
itemSupportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemSupportingTextSlot msg
    -> Element free freeAdmittedBy msg
itemSupportingText builder =
    Component.itemSupportingText (B.toElement builder)


{-| -}
itemTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemTrailingSlot msg
    -> Element free freeAdmittedBy msg
itemTrailing builder =
    Component.itemTrailing (B.toElement builder)


{-| -}
itemWithLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemLeadingSlot msg
    -> ItemBuilder attrCaps { s | leading : Available } msg kind
    -> ItemBuilder attrCaps { s | leading : Used } msg kind
itemWithLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemLeading (B.toElement slotBuilder))) builder_


{-| -}
itemWithOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemOverlineSlot msg
    -> ItemBuilder attrCaps { s | overline : Available } msg kind
    -> ItemBuilder attrCaps { s | overline : Used } msg kind
itemWithOverline slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemOverline (B.toElement slotBuilder))) builder_


{-| -}
itemWithSupportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemSupportingTextSlot msg
    -> ItemBuilder attrCaps { s | supportingText : Available } msg kind
    -> ItemBuilder attrCaps { s | supportingText : Used } msg kind
itemWithSupportingText slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemSupportingText (B.toElement slotBuilder))) builder_


{-| -}
itemWithTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.ItemTrailingSlot msg
    -> ItemBuilder attrCaps { s | trailing : Available } msg kind
    -> ItemBuilder attrCaps { s | trailing : Used } msg kind
itemWithTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.itemTrailing (B.toElement slotBuilder))) builder_


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
type alias ActionIs s =
    Component.ActionIs s


{-| -}
type alias ActionBuilder attrCaps slotCaps msg kind =
    Component.ActionBuilder attrCaps slotCaps msg kind


{-| -}
type alias ActionAttrCaps =
    Component.ActionAttrCaps


{-| -}
type alias ActionSlotCaps =
    Component.ActionSlotCaps


{-| -}
type alias ActionChildAdmittedBy childAdm =
    Component.ActionChildAdmittedBy childAdm


{-| -}
type alias ActionContent =
    Component.ActionContent


{-| -}
type alias ActionLeadingSlot =
    Component.ActionLeadingSlot


{-| -}
type alias ActionOverlineSlot =
    Component.ActionOverlineSlot


{-| -}
type alias ActionSupportingTextSlot =
    Component.ActionSupportingTextSlot


{-| -}
type alias ActionTrailingSlot =
    Component.ActionTrailingSlot


{-| -}
actionBuild : ActionBuilder ActionAttrCaps ActionSlotCaps msg kind
actionBuild =
    B.init "m3e-list-action" [] []


{-| -}
actionToElement : ActionBuilder attrCaps slotCaps msg kind -> Element (Component.ActionIs kind) admittedBy msg
actionToElement =
    B.toElement


{-| -}
actionLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionLeadingSlot msg
    -> Element free freeAdmittedBy msg
actionLeading builder =
    Component.actionLeading (B.toElement builder)


{-| -}
actionOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionOverlineSlot msg
    -> Element free freeAdmittedBy msg
actionOverline builder =
    Component.actionOverline (B.toElement builder)


{-| -}
actionSupportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionSupportingTextSlot msg
    -> Element free freeAdmittedBy msg
actionSupportingText builder =
    Component.actionSupportingText (B.toElement builder)


{-| -}
actionTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionTrailingSlot msg
    -> Element free freeAdmittedBy msg
actionTrailing builder =
    Component.actionTrailing (B.toElement builder)


{-| -}
actionWithLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionLeadingSlot msg
    -> ActionBuilder attrCaps { s | leading : Available } msg kind
    -> ActionBuilder attrCaps { s | leading : Used } msg kind
actionWithLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.actionLeading (B.toElement slotBuilder))) builder_


{-| -}
actionWithOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionOverlineSlot msg
    -> ActionBuilder attrCaps { s | overline : Available } msg kind
    -> ActionBuilder attrCaps { s | overline : Used } msg kind
actionWithOverline slotBuilder builder_ =
    B.withChild (El.toNode (Component.actionOverline (B.toElement slotBuilder))) builder_


{-| -}
actionWithSupportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionSupportingTextSlot msg
    -> ActionBuilder attrCaps { s | supportingText : Available } msg kind
    -> ActionBuilder attrCaps { s | supportingText : Used } msg kind
actionWithSupportingText slotBuilder builder_ =
    B.withChild (El.toNode (Component.actionSupportingText (B.toElement slotBuilder))) builder_


{-| -}
actionWithTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.ActionTrailingSlot msg
    -> ActionBuilder attrCaps { s | trailing : Available } msg kind
    -> ActionBuilder attrCaps { s | trailing : Used } msg kind
actionWithTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.actionTrailing (B.toElement slotBuilder))) builder_


{-| -}
actionWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> ActionBuilder attrCaps slotCaps msg kind
    -> ActionBuilder attrCaps slotCaps msg kind
actionWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
actionWithClass : String -> ActionBuilder { a | class : Available } slotCaps msg kind -> ActionBuilder { a | class : Used } slotCaps msg kind
actionWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
actionWithId : String -> ActionBuilder { a | id : Available } slotCaps msg kind -> ActionBuilder { a | id : Used } slotCaps msg kind
actionWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
actionWithSlot : String -> ActionBuilder { a | slot : Available } slotCaps msg kind -> ActionBuilder { a | slot : Used } slotCaps msg kind
actionWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
actionWithStyle : String -> String -> ActionBuilder { a | style : Available } slotCaps msg kind -> ActionBuilder { a | style : Used } slotCaps msg kind
actionWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
actionWithDisabled : Bool -> ActionBuilder { a | disabled : Available } slotCaps msg kind -> ActionBuilder { a | disabled : Used } slotCaps msg kind
actionWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
actionWithDownload : String -> ActionBuilder { a | download : Available } slotCaps msg kind -> ActionBuilder { a | download : Used } slotCaps msg kind
actionWithDownload value_ =
    B.withAttribute (A.download value_)


{-| -}
actionWithHref : String -> ActionBuilder { a | href : Available } slotCaps msg kind -> ActionBuilder { a | href : Used } slotCaps msg kind
actionWithHref value_ =
    B.withAttribute (A.href value_)


{-| -}
actionWithRel : String -> ActionBuilder { a | rel : Available } slotCaps msg kind -> ActionBuilder { a | rel : Used } slotCaps msg kind
actionWithRel value_ =
    B.withAttribute (A.rel value_)


{-| -}
actionWithTarget : String -> ActionBuilder { a | target : Available } slotCaps msg kind -> ActionBuilder { a | target : Used } slotCaps msg kind
actionWithTarget value_ =
    B.withAttribute (A.target value_)


{-| -}
actionWithOnClick : msg -> ActionBuilder { a | onClick : Available } slotCaps msg kind -> ActionBuilder { a | onClick : Used } slotCaps msg kind
actionWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| -}
type alias OptionIs s =
    Component.OptionIs s


{-| -}
type alias OptionBuilder attrCaps slotCaps msg kind =
    Component.OptionBuilder attrCaps slotCaps msg kind


{-| -}
type alias OptionAttrCaps =
    Component.OptionAttrCaps


{-| -}
type alias OptionSlotCaps =
    Component.OptionSlotCaps


{-| -}
type alias OptionChildAdmittedBy childAdm =
    Component.OptionChildAdmittedBy childAdm


{-| -}
type alias OptionContent =
    Component.OptionContent


{-| -}
type alias OptionLeadingSlot =
    Component.OptionLeadingSlot


{-| -}
type alias OptionOverlineSlot =
    Component.OptionOverlineSlot


{-| -}
type alias OptionSupportingTextSlot =
    Component.OptionSupportingTextSlot


{-| -}
type alias OptionTrailingSlot =
    Component.OptionTrailingSlot


{-| -}
optionBuild : OptionBuilder OptionAttrCaps OptionSlotCaps msg kind
optionBuild =
    B.init "m3e-list-option" [] []


{-| -}
optionToElement : OptionBuilder attrCaps slotCaps msg kind -> Element (Component.OptionIs kind) admittedBy msg
optionToElement =
    B.toElement


{-| -}
optionLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionLeadingSlot msg
    -> Element free freeAdmittedBy msg
optionLeading builder =
    Component.optionLeading (B.toElement builder)


{-| -}
optionOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionOverlineSlot msg
    -> Element free freeAdmittedBy msg
optionOverline builder =
    Component.optionOverline (B.toElement builder)


{-| -}
optionSupportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionSupportingTextSlot msg
    -> Element free freeAdmittedBy msg
optionSupportingText builder =
    Component.optionSupportingText (B.toElement builder)


{-| -}
optionTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionTrailingSlot msg
    -> Element free freeAdmittedBy msg
optionTrailing builder =
    Component.optionTrailing (B.toElement builder)


{-| -}
optionWithLeading :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionLeadingSlot msg
    -> OptionBuilder attrCaps { s | leading : Available } msg kind
    -> OptionBuilder attrCaps { s | leading : Used } msg kind
optionWithLeading slotBuilder builder_ =
    B.withChild (El.toNode (Component.optionLeading (B.toElement slotBuilder))) builder_


{-| -}
optionWithOverline :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionOverlineSlot msg
    -> OptionBuilder attrCaps { s | overline : Available } msg kind
    -> OptionBuilder attrCaps { s | overline : Used } msg kind
optionWithOverline slotBuilder builder_ =
    B.withChild (El.toNode (Component.optionOverline (B.toElement slotBuilder))) builder_


{-| -}
optionWithSupportingText :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionSupportingTextSlot msg
    -> OptionBuilder attrCaps { s | supportingText : Available } msg kind
    -> OptionBuilder attrCaps { s | supportingText : Used } msg kind
optionWithSupportingText slotBuilder builder_ =
    B.withChild (El.toNode (Component.optionSupportingText (B.toElement slotBuilder))) builder_


{-| -}
optionWithTrailing :
    B.Builder childRow childAttrCaps childSlotCaps Component.OptionTrailingSlot msg
    -> OptionBuilder attrCaps { s | trailing : Available } msg kind
    -> OptionBuilder attrCaps { s | trailing : Used } msg kind
optionWithTrailing slotBuilder builder_ =
    B.withChild (El.toNode (Component.optionTrailing (B.toElement slotBuilder))) builder_


{-| -}
optionWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> OptionBuilder attrCaps slotCaps msg kind
    -> OptionBuilder attrCaps slotCaps msg kind
optionWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
optionWithClass : String -> OptionBuilder { a | class : Available } slotCaps msg kind -> OptionBuilder { a | class : Used } slotCaps msg kind
optionWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
optionWithId : String -> OptionBuilder { a | id : Available } slotCaps msg kind -> OptionBuilder { a | id : Used } slotCaps msg kind
optionWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
optionWithSlot : String -> OptionBuilder { a | slot : Available } slotCaps msg kind -> OptionBuilder { a | slot : Used } slotCaps msg kind
optionWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
optionWithStyle : String -> String -> OptionBuilder { a | style : Available } slotCaps msg kind -> OptionBuilder { a | style : Used } slotCaps msg kind
optionWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
optionWithDisabled : Bool -> OptionBuilder { a | disabled : Available } slotCaps msg kind -> OptionBuilder { a | disabled : Used } slotCaps msg kind
optionWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
optionWithSelected : Bool -> OptionBuilder { a | selected : Available } slotCaps msg kind -> OptionBuilder { a | selected : Used } slotCaps msg kind
optionWithSelected value_ =
    B.withAttribute (A.selected value_)


{-| -}
optionWithValue : String -> OptionBuilder { a | value : Available } slotCaps msg kind -> OptionBuilder { a | value : Used } slotCaps msg kind
optionWithValue value_ =
    B.withAttribute (A.value value_)


{-| -}
optionWithOnBeforeinput : msg -> OptionBuilder { a | onBeforeinput : Available } slotCaps msg kind -> OptionBuilder { a | onBeforeinput : Used } slotCaps msg kind
optionWithOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
optionWithOnInput : msg -> OptionBuilder { a | onInput : Available } slotCaps msg kind -> OptionBuilder { a | onInput : Used } slotCaps msg kind
optionWithOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
optionWithOnChange : msg -> OptionBuilder { a | onChange : Available } slotCaps msg kind -> OptionBuilder { a | onChange : Used } slotCaps msg kind
optionWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
optionWithOnClick : msg -> OptionBuilder { a | onClick : Available } slotCaps msg kind -> OptionBuilder { a | onClick : Used } slotCaps msg kind
optionWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)
