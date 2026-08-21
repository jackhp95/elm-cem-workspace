module Hz.Element.AttrSlot exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, HintSlot, LabelSlot, ChildAdmittedBy
    , withHint, withLabel
    , hint, label
    )

{-| The `hz-attr-slot` component — strict per-component surface.

Tests K5: attr with-hint + slot hint collision, and with-label/label.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, HintSlot, LabelSlot, ChildAdmittedBy
@docs withHint, withLabel
@docs hint, label

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Hz.Attributes as A
import Hz.Html as H
import Hz.Internal.Types.AttrSlot
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `hz-attr-slot` produces (open — composes into any slot naming it).
-}
type alias Is s =
    Hz.Internal.Types.AttrSlot.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    Hz.Internal.Types.AttrSlot.Attrs


{-| The kinds the `hint` slot admits.
-}
type alias HintSlot =
    Hz.Internal.Types.AttrSlot.HintSlot


{-| The kinds the `label` slot admits.
-}
type alias LabelSlot =
    Hz.Internal.Types.AttrSlot.LabelSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    Hz.Internal.Types.AttrSlot.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `Hz.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    Hz.Internal.Types.AttrSlot.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    Hz.Internal.Types.AttrSlot.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    Hz.Internal.Types.AttrSlot.SlotCaps


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.attrSlot


{-| See `Hz.Attributes.withHint`.
-}
withHint : Bool -> Attr { c | withHint : Supported } msg
withHint =
    A.withHint


{-| See `Hz.Attributes.withLabel`.
-}
withLabel : Bool -> Attr { c | withLabel : Supported } msg
withLabel =
    A.withLabel


{-| Place an element into the named `hint` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
hint : Element HintSlot admittedBy msg -> Element free freeAdmittedBy msg
hint element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "hint") (El.toNode element))


{-| Place an element into the named `label` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
label : Element LabelSlot admittedBy msg -> Element free freeAdmittedBy msg
label element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "label") (El.toNode element))
