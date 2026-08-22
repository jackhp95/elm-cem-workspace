module M3e.Build.Fab exposing (Builder, AttrCaps, SlotCaps, Is, Content, CloseIconSlot, LabelSlot, ChildAdmittedBy, ActionCaps, build, toElement, withClass, withDisabled, withDisabledInteractive, withDownload, withExtended, withHref, withId, withLowered, withName, withOnClick, withRel, withSize, withSlot, withStyle, withTarget, withType, withValue, withVariant, closeIcon, label, withCloseIcon, withLabel, withChild)

{-| The **Fab** family — the COMPOSED builder tier.

A degenerate single-member family: the flat, un-prefixed per-element
builder surface, sourced through `M3e.Component.Fab`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs Builder, AttrCaps, SlotCaps, Is, Content, CloseIconSlot, LabelSlot, ChildAdmittedBy, ActionCaps, build, toElement, withClass, withDisabled, withDisabledInteractive, withDownload, withExtended, withHref, withId, withLowered, withName, withOnClick, withRel, withSize, withSlot, withStyle, withTarget, withType, withValue, withVariant, closeIcon, label, withCloseIcon, withLabel, withChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import M3e.Action as Ac
import M3e.Attributes as A
import M3e.Component.Fab as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias Is s =
    Component.FabIs s


{-| -}
type alias Builder attrCaps slotCaps msg kind =
    Component.FabBuilder attrCaps slotCaps msg kind


{-| -}
type alias AttrCaps =
    Component.FabAttrCaps


{-| -}
type alias SlotCaps =
    Component.FabSlotCaps


{-| -}
type alias ChildAdmittedBy childAdm =
    Component.FabChildAdmittedBy childAdm


{-| -}
type alias Content =
    Component.FabContent


{-| -}
type alias CloseIconSlot =
    Component.FabCloseIconSlot


{-| -}
type alias LabelSlot =
    Component.FabLabelSlot


{-| -}
type alias ActionCaps =
    Component.FabActionCaps


{-| -}
build :
    { content : Element Component.FabContent (Component.FabChildAdmittedBy childAdm) msg
    , action : Ac.Action Component.FabActionCaps msg
    }
    -> Builder AttrCaps SlotCaps msg kind
build required_ =
    B.init "m3e-fab" (Ac.toAttrs required_.action) [ Ac.wrapContent required_.action (El.toNode required_.content) ]


{-| -}
toElement : Builder attrCaps slotCaps msg kind -> Element (Component.FabIs kind) admittedBy msg
toElement =
    B.toElement


{-| -}
closeIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.FabCloseIconSlot msg
    -> Element free freeAdmittedBy msg
closeIcon builder =
    Component.fabCloseIcon (B.toElement builder)


{-| -}
label :
    B.Builder childRow childAttrCaps childSlotCaps Component.FabLabelSlot msg
    -> Element free freeAdmittedBy msg
label builder =
    Component.fabLabel (B.toElement builder)


{-| -}
withCloseIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.FabCloseIconSlot msg
    -> Builder attrCaps { s | closeIcon : Available } msg kind
    -> Builder attrCaps { s | closeIcon : Used } msg kind
withCloseIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.fabCloseIcon (B.toElement slotBuilder))) builder_


{-| -}
withLabel :
    B.Builder childRow childAttrCaps childSlotCaps Component.FabLabelSlot msg
    -> Builder attrCaps { s | label : Available } msg kind
    -> Builder attrCaps { s | label : Used } msg kind
withLabel slotBuilder builder_ =
    B.withChild (El.toNode (Component.fabLabel (B.toElement slotBuilder))) builder_


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
withDisabledInteractive : Bool -> Builder { a | disabledInteractive : Available } slotCaps msg kind -> Builder { a | disabledInteractive : Used } slotCaps msg kind
withDisabledInteractive value_ =
    B.withAttribute (A.disabledInteractive value_)


{-| -}
withDownload : String -> Builder { a | download : Available } slotCaps msg kind -> Builder { a | download : Used } slotCaps msg kind
withDownload value_ =
    B.withAttribute (A.download value_)


{-| -}
withExtended : Bool -> Builder { a | extended : Available } slotCaps msg kind -> Builder { a | extended : Used } slotCaps msg kind
withExtended value_ =
    B.withAttribute (A.extended value_)


{-| -}
withHref : String -> Builder { a | href : Available } slotCaps msg kind -> Builder { a | href : Used } slotCaps msg kind
withHref value_ =
    B.withAttribute (A.href value_)


{-| -}
withLowered : Bool -> Builder { a | lowered : Available } slotCaps msg kind -> Builder { a | lowered : Used } slotCaps msg kind
withLowered value_ =
    B.withAttribute (A.lowered value_)


{-| -}
withName : String -> Builder { a | name : Available } slotCaps msg kind -> Builder { a | name : Used } slotCaps msg kind
withName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| -}
withRel : String -> Builder { a | rel : Available } slotCaps msg kind -> Builder { a | rel : Used } slotCaps msg kind
withRel value_ =
    B.withAttribute (A.rel value_)


{-| -}
withSize : Value Component.FabSize -> Builder { a | size : Available } slotCaps msg kind -> Builder { a | size : Used } slotCaps msg kind
withSize value_ =
    B.withAttribute (Component.fabSize value_)


{-| -}
withTarget : String -> Builder { a | target : Available } slotCaps msg kind -> Builder { a | target : Used } slotCaps msg kind
withTarget value_ =
    B.withAttribute (A.target value_)


{-| -}
withType : Value Component.FabType -> Builder { a | type_ : Available } slotCaps msg kind -> Builder { a | type_ : Used } slotCaps msg kind
withType value_ =
    B.withAttribute (Component.fabType_ value_)


{-| -}
withValue : String -> Builder { a | value : Available } slotCaps msg kind -> Builder { a | value : Used } slotCaps msg kind
withValue value_ =
    B.withAttribute (A.value value_)


{-| -}
withVariant : Value Component.FabVariant -> Builder { a | variant : Available } slotCaps msg kind -> Builder { a | variant : Used } slotCaps msg kind
withVariant value_ =
    B.withAttribute (Component.fabVariant value_)


{-| -}
withOnClick : msg -> Builder { a | onClick : Available } slotCaps msg kind -> Builder { a | onClick : Used } slotCaps msg kind
withOnClick value_ =
    B.withAttribute (Ev.onClick value_)
