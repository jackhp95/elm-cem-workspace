module M3e.Component.Fab exposing (FabIs, FabAttrs, FabBuilder, FabAttrCaps, FabSlotCaps, FabContent, FabCloseIconSlot, FabLabelSlot, FabChildAdmittedBy, FabActionCaps, FabSize, FabType, FabVariant, fab, fabSize, fabType_, fabVariant, fabDisabled, fabDisabledInteractive, fabDownload, fabExtended, fabHref, fabLowered, fabName, fabRel, fabTarget, fabValue, fabDefaultValue, fabOnClick, fabCloseIcon, fabLabel, fabChild)

{-| The **Fab** element — degenerate single-member family façade.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Fab`](M3e.Element.Fab) as `fab`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs FabIs, FabAttrs, FabBuilder, FabAttrCaps, FabSlotCaps, FabContent, FabCloseIconSlot, FabLabelSlot, FabChildAdmittedBy, FabActionCaps, FabSize, FabType, FabVariant, fab, fabSize, fabType_, fabVariant, fabDisabled, fabDisabledInteractive, fabDownload, fabExtended, fabHref, fabLowered, fabName, fabRel, fabTarget, fabValue, fabDefaultValue, fabOnClick, fabCloseIcon, fabLabel, fabChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Action as Ac
import M3e.Element.Fab as Fab_


{-| The `fab` element of this family — delegates to [`M3e.Element.Fab.component`](M3e.Element.Fab#component).
-}
fab :
    { content : Element FabContent (FabChildAdmittedBy childAdm) msg
    , action : Ac.Action FabActionCaps msg
    }
    -> List (Attr FabAttrs msg)
    -> List (Element FabContent (FabChildAdmittedBy childAdm) msg)
    -> Element (FabIs s) admittedBy msg
fab =
    Fab_.component


{-| See [`M3e.Element.Fab.Is`](M3e.Element.Fab#Is).
-}
type alias FabIs s =
    Fab_.Is s


{-| See [`M3e.Element.Fab.Attrs`](M3e.Element.Fab#Attrs).
-}
type alias FabAttrs =
    Fab_.Attrs


{-| See [`M3e.Element.Fab.Builder`](M3e.Element.Fab#Builder).
-}
type alias FabBuilder attrCaps slotCaps msg kind =
    Fab_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Fab.AttrCaps`](M3e.Element.Fab#AttrCaps).
-}
type alias FabAttrCaps =
    Fab_.AttrCaps


{-| See [`M3e.Element.Fab.SlotCaps`](M3e.Element.Fab#SlotCaps).
-}
type alias FabSlotCaps =
    Fab_.SlotCaps


{-| See [`M3e.Element.Fab.Content`](M3e.Element.Fab#Content).
-}
type alias FabContent =
    Fab_.Content


{-| See [`M3e.Element.Fab.CloseIconSlot`](M3e.Element.Fab#CloseIconSlot).
-}
type alias FabCloseIconSlot =
    Fab_.CloseIconSlot


{-| See [`M3e.Element.Fab.LabelSlot`](M3e.Element.Fab#LabelSlot).
-}
type alias FabLabelSlot =
    Fab_.LabelSlot


{-| See [`M3e.Element.Fab.ChildAdmittedBy`](M3e.Element.Fab#ChildAdmittedBy).
-}
type alias FabChildAdmittedBy childAdm =
    Fab_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Fab.ActionCaps`](M3e.Element.Fab#ActionCaps).
-}
type alias FabActionCaps =
    Fab_.ActionCaps


{-| See [`M3e.Element.Fab.Size`](M3e.Element.Fab#Size).
-}
type alias FabSize =
    Fab_.Size


{-| See [`M3e.Element.Fab.size`](M3e.Element.Fab#size).
-}
fabSize : Value FabSize -> Attr { c | size : Supported } msg
fabSize =
    Fab_.size


{-| See [`M3e.Element.Fab.Type`](M3e.Element.Fab#Type).
-}
type alias FabType =
    Fab_.Type


{-| See [`M3e.Element.Fab.type_`](M3e.Element.Fab#type_).
-}
fabType_ : Value FabType -> Attr { c | type_ : Supported } msg
fabType_ =
    Fab_.type_


{-| See [`M3e.Element.Fab.Variant`](M3e.Element.Fab#Variant).
-}
type alias FabVariant =
    Fab_.Variant


{-| See [`M3e.Element.Fab.variant`](M3e.Element.Fab#variant).
-}
fabVariant : Value FabVariant -> Attr { c | variant : Supported } msg
fabVariant =
    Fab_.variant


{-| See [`M3e.Element.Fab.disabled`](M3e.Element.Fab#disabled).
-}
fabDisabled : Bool -> Attr { c | disabled : Supported } msg
fabDisabled =
    Fab_.disabled


{-| See [`M3e.Element.Fab.disabledInteractive`](M3e.Element.Fab#disabledInteractive).
-}
fabDisabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
fabDisabledInteractive =
    Fab_.disabledInteractive


{-| See [`M3e.Element.Fab.download`](M3e.Element.Fab#download).
-}
fabDownload : String -> Attr { c | download : Supported } msg
fabDownload =
    Fab_.download


{-| See [`M3e.Element.Fab.extended`](M3e.Element.Fab#extended).
-}
fabExtended : Bool -> Attr { c | extended : Supported } msg
fabExtended =
    Fab_.extended


{-| See [`M3e.Element.Fab.href`](M3e.Element.Fab#href).
-}
fabHref : String -> Attr { c | href : Supported } msg
fabHref =
    Fab_.href


{-| See [`M3e.Element.Fab.lowered`](M3e.Element.Fab#lowered).
-}
fabLowered : Bool -> Attr { c | lowered : Supported } msg
fabLowered =
    Fab_.lowered


{-| See [`M3e.Element.Fab.name`](M3e.Element.Fab#name).
-}
fabName : String -> Attr { c | name : Supported } msg
fabName =
    Fab_.name


{-| See [`M3e.Element.Fab.rel`](M3e.Element.Fab#rel).
-}
fabRel : String -> Attr { c | rel : Supported } msg
fabRel =
    Fab_.rel


{-| See [`M3e.Element.Fab.target`](M3e.Element.Fab#target).
-}
fabTarget : String -> Attr { c | target : Supported } msg
fabTarget =
    Fab_.target


{-| See [`M3e.Element.Fab.value`](M3e.Element.Fab#value).
-}
fabValue : String -> Attr { c | value : Supported } msg
fabValue =
    Fab_.value


{-| See [`M3e.Element.Fab.defaultValue`](M3e.Element.Fab#defaultValue).
-}
fabDefaultValue : String -> Attr { c | value : Supported } msg
fabDefaultValue =
    Fab_.defaultValue


{-| See [`M3e.Element.Fab.onClick`](M3e.Element.Fab#onClick).
-}
fabOnClick : msg -> Attr { c | onClick : Supported } msg
fabOnClick =
    Fab_.onClick


{-| See [`M3e.Element.Fab.closeIcon`](M3e.Element.Fab#closeIcon).
-}
fabCloseIcon : Element FabCloseIconSlot admittedBy msg -> Element free freeAdmittedBy msg
fabCloseIcon =
    Fab_.closeIcon


{-| See [`M3e.Element.Fab.label`](M3e.Element.Fab#label).
-}
fabLabel : Element FabLabelSlot admittedBy msg -> Element free freeAdmittedBy msg
fabLabel =
    Fab_.label


{-| See [`M3e.Element.Fab.child`](M3e.Element.Fab#child).
-}
fabChild : Element FabContent admittedBy msg -> Element free freeAdmittedBy msg
fabChild =
    Fab_.child
