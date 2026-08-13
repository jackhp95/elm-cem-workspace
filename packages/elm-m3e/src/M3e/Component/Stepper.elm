module M3e.Component.Stepper exposing
    ( view
    , Is, Attrs, PanelSlot, StepSlot, ChildAdmittedBy
    , HeaderPosition, headerPosition, LabelPosition, labelPosition, Orientation, orientation
    , linear, onChange, onBeforeinput, onInput
    , panel, step
    )

{-| The `m3e-stepper` component — strict per-component surface.

Provides a wizard-like workflow by dividing content into logical steps.

@docs view
@docs Is, Attrs, PanelSlot, StepSlot, ChildAdmittedBy
@docs HeaderPosition, headerPosition, LabelPosition, labelPosition, Orientation, orientation
@docs linear, onChange, onBeforeinput, onInput
@docs panel, step

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Attributes as A
import M3e.Events as Ev
import M3e.Html as H
import M3e.Internal.Types.Stepper
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The kind row `m3e-stepper` produces (open — composes into any slot naming it).
-}
type alias Is s =
    M3e.Internal.Types.Stepper.Is s


{-| The closed attribute-capability row.
-}
type alias Attrs =
    M3e.Internal.Types.Stepper.Attrs


{-| The kinds the `panel` slot admits.
-}
type alias PanelSlot =
    M3e.Internal.Types.Stepper.PanelSlot


{-| The kinds the `step` slot admits.
-}
type alias StepSlot =
    M3e.Internal.Types.Stepper.StepSlot


{-| The context demand this container injects into each child's admittedBy row.
-}
type alias ChildAdmittedBy childAdm =
    M3e.Internal.Types.Stepper.ChildAdmittedBy childAdm


{-| The `headerPosition` values valid on this component (compile-tight narrowing).
-}
type alias HeaderPosition =
    M3e.Internal.Types.Stepper.HeaderPosition


{-| The `labelPosition` values valid on this component (compile-tight narrowing).
-}
type alias LabelPosition =
    M3e.Internal.Types.Stepper.LabelPosition


{-| The `orientation` values valid on this component (compile-tight narrowing).
-}
type alias Orientation =
    M3e.Internal.Types.Stepper.Orientation


{-| Standard constructor: `[attributes] [children]`.
-}
view :
    List (Attr Attrs msg)
    -> List (Element childAccepts (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view =
    H.stepper


{-| The position of the step header, when oriented horizontally. (default: `"above"`)
-}
headerPosition : Value HeaderPosition -> Attr { c | headerPosition : Supported } msg
headerPosition value_ =
    Ir.attribute "header-position" (Val.toString value_)


{-| The position of the step labels, when oriented horizontally. (default: `"end"`)
-}
labelPosition : Value LabelPosition -> Attr { c | labelPosition : Supported } msg
labelPosition value_ =
    Ir.attribute "label-position" (Val.toString value_)


{-| The orientation of the stepper. (default: `"horizontal"`)
-}
orientation : Value Orientation -> Attr { c | orientation : Supported } msg
orientation value_ =
    Ir.attribute "orientation" (Val.toString value_)


{-| See `M3e.Attributes.linear`.
-}
linear : Bool -> Attr { c | linear : Supported } msg
linear =
    A.linear


{-| See `M3e.Events.onChange`.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange =
    Ev.onChange


{-| See `M3e.Events.onBeforeinput`.
-}
onBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
onBeforeinput =
    Ev.onBeforeinput


{-| See `M3e.Events.onInput`.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput =
    Ev.onInput


{-| Place an element into the named `panel` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
panel : Element PanelSlot admittedBy msg -> Element free freeAdmittedBy msg
panel element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "panel") (El.toNode element))


{-| Place an element into the named `step` slot (input constrained to the
slot's kinds; output row free so it composes into the child list).
-}
step : Element StepSlot admittedBy msg -> Element free freeAdmittedBy msg
step element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "step") (El.toNode element))
