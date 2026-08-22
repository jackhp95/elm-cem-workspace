module M3e.Build.Select exposing (Builder, AttrCaps, SlotCaps, Is, Content, ArrowSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withHideSelectionIndicator, withId, withMulti, withName, withOnBeforeinput, withOnChange, withOnInput, withOnToggle, withPanelClass, withRequired, withSlot, withStyle, withValidationmessages, arrow, value, withArrow, withValue, withChild)

{-| The **Select** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.Select`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, ArrowSlot, ChildAdmittedBy, build, toElement, withClass, withDisabled, withHideSelectionIndicator, withId, withMulti, withName, withOnBeforeinput, withOnChange, withOnInput, withOnToggle, withPanelClass, withRequired, withSlot, withStyle, withValidationmessages, arrow, value, withArrow, withValue, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import M3e.Attributes as A
import M3e.Component.Select as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.SelectIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.SelectBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.SelectAttrCaps


{-| -}
type alias SlotCaps =
    Component.SelectSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.SelectChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.SelectContent


{-| -}
type alias ArrowSlot =
    Component.SelectArrowSlot


{-| -}
build :
    { content : Element Component.SelectContent (Component.SelectChildAdmittedBy childAdm) msg }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-select" [] [ El.toNode required_.content ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.SelectIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
arrow :
    B.Builder childRow childAttrCaps childSlotCaps Component.SelectArrowSlot msg
    -> Element free freeAdmittedBy msg
arrow builder =
    Component.selectArrow (B.toElement builder)


{-| -}
value :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
value builder =
    Component.selectValue (B.toElement builder)


{-| -}
withArrow :
    B.Builder childRow childAttrCaps childSlotCaps Component.SelectArrowSlot msg
    -> Builder attrCaps { s | arrow : Available } msg kind
    -> Builder attrCaps { s | arrow : Used } msg kind
withArrow slotBuilder builder_ =
    B.withChild (El.toNode (Component.selectArrow (B.toElement slotBuilder))) builder_


{-| -}
withValue :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Builder attrCaps { s | value : Available } msg kind
    -> Builder attrCaps { s | value : Used } msg kind
withValue slotBuilder builder_ =
    B.withChild (El.toNode (Component.selectValue (B.toElement slotBuilder))) builder_


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
withDisabled : Bool -> Builder { a | disabled : Available } slotCaps msg kind -> Builder { a | disabled : Used } slotCaps msg kind
withDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
withHideSelectionIndicator : Bool -> Builder { a | hideSelectionIndicator : Available } slotCaps msg kind -> Builder { a | hideSelectionIndicator : Used } slotCaps msg kind
withHideSelectionIndicator value_ =
    B.withAttribute (A.hideSelectionIndicator value_)


{-| -}
withMulti : Bool -> Builder { a | multi : Available } slotCaps msg kind -> Builder { a | multi : Used } slotCaps msg kind
withMulti value_ =
    B.withAttribute (A.multi value_)


{-| -}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| -}
withPanelClass : String -> Builder { a | panelClass : Available } slotCaps msg kind -> Builder { a | panelClass : Used } slotCaps msg kind
withPanelClass value_ =
    B.withAttribute (A.panelClass value_)


{-| -}
withRequired : Bool -> Builder { a | required : Available } slotCaps msg kind -> Builder { a | required : Used } slotCaps msg kind
withRequired value_ =
    B.withAttribute (A.required value_)


{-| -}
withValidationmessages : String -> Builder { a | validationmessages : Available } slotCaps msg kind -> Builder { a | validationmessages : Used } slotCaps msg kind
withValidationmessages value_ =
    B.withAttribute (A.validationmessages value_)


{-| -}
withOnChange : msg -> Builder { a | onChange : Available } slotCaps msg kind -> Builder { a | onChange : Used } slotCaps msg kind
withOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
withOnToggle : (String -> msg) -> Builder { a | onToggle : Available } slotCaps msg kind -> Builder { a | onToggle : Used } slotCaps msg kind
withOnToggle value_ =
    B.withAttribute (Component.selectOnToggle value_)


{-| -}
withOnBeforeinput : msg -> Builder { a | onBeforeinput : Available } slotCaps msg kind -> Builder { a | onBeforeinput : Used } slotCaps msg kind
withOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
withOnInput : msg -> Builder { a | onInput : Available } slotCaps msg kind -> Builder { a | onInput : Used } slotCaps msg kind
withOnInput value_ =
    B.withAttribute (Ev.onInput value_)
