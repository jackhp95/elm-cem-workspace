module M3e.Internal.Types.Stepper exposing (Is, Attrs, PanelSlot, StepSlot, ChildAdmittedBy, HeaderPosition, LabelPosition, Orientation, Builder, AttrCaps)

{-| Type definitions for Stepper. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Stepper` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, PanelSlot, StepSlot, ChildAdmittedBy, HeaderPosition, LabelPosition, Orientation, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Stepper (generated).
-}
type alias Is s =
    { s | stepper : Brand }


{-| The `Attrs` type row for Stepper (generated).
-}
type alias Attrs =
    { class : Supported
    , headerPosition : Supported
    , id : Supported
    , labelPosition : Supported
    , linear : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , orientation : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `PanelSlot` type row for Stepper (generated).
-}
type alias PanelSlot =
    { stepPanel : Brand }


{-| The `StepSlot` type row for Stepper (generated).
-}
type alias StepSlot =
    { step : Brand }


{-| The `ChildAdmittedBy` type row for Stepper (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | stepper : Ctx }


{-| The `HeaderPosition` type row for Stepper (generated).
-}
type alias HeaderPosition =
    { above : Supported
    , below : Supported
    }


{-| The `LabelPosition` type row for Stepper (generated).
-}
type alias LabelPosition =
    { below : Supported
    , end : Supported
    }


{-| The `Orientation` type row for Stepper (generated).
-}
type alias Orientation =
    { auto : Supported
    , horizontal : Supported
    , vertical : Supported
    }


{-| The `Builder` type row for Stepper (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Stepper (generated).
-}
type alias AttrCaps =
    { class : Available
    , headerPosition : Available
    , id : Available
    , labelPosition : Available
    , linear : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , orientation : Available
    , slot : Available
    , style : Available
    }
