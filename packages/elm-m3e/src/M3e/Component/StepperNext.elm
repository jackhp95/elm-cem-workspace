module M3e.Component.StepperNext exposing
    ( component
    , Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy
    )

{-| The `m3e-stepper-next` component — strict per-component surface.

An element, nested within a clickable element, used to move a stepper to the next step.

@docs component
@docs Is, Attrs, Builder, AttrCaps, SlotCaps, ChildAdmittedBy

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import M3e.Attributes as A
import M3e.Html as H
import M3e.Internal.Types.StepperNext
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-stepper-next` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.StepperNext.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.StepperNext.Attrs


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.StepperNext.ChildAdmittedBy childAdm


{-| The narrowed pipe-builder this component's `M3e.Build.<X>` module exposes.
-}
type alias Builder attrCaps slotCaps msg kind =
    M3e.Internal.Types.StepperNext.Builder attrCaps slotCaps msg kind


{-| The attribute capabilities this component's builder admits.
-}
type alias AttrCaps =
    M3e.Internal.Types.StepperNext.AttrCaps


{-| The singular-slot capabilities this component's builder admits.
-}
type alias SlotCaps =
    {}


{-| Standard constructor: `[attributes] [children]`.
-}
component :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
component =
    H.stepperNext
