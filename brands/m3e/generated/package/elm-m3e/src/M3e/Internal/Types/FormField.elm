module M3e.Internal.Types.FormField exposing (Is, Attrs, ChildAdmittedBy, FloatLabel, HideSubscript, Variant, Builder, AttrCaps, SlotCaps)

{-| Type definitions for FormField. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.FormField` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, FloatLabel, HideSubscript, Variant, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for FormField (generated).
-}
type alias Is s =
    { s | formField : Brand }


{-| The `Attrs` type row for FormField (generated).
-}
type alias Attrs =
    { class : Supported
    , floatLabel : Supported
    , hideRequiredMarker : Supported
    , hideSubscript : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `ChildAdmittedBy` type row for FormField (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | formField : Ctx }


{-| The `FloatLabel` type row for FormField (generated).
-}
type alias FloatLabel =
    { always : Supported
    , auto : Supported
    }


{-| The `HideSubscript` type row for FormField (generated).
-}
type alias HideSubscript =
    { always : Supported
    , auto : Supported
    , never : Supported
    }


{-| The `Variant` type row for FormField (generated).
-}
type alias Variant =
    { filled : Supported
    , outlined : Supported
    }


{-| The `Builder` type row for FormField (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for FormField (generated).
-}
type alias AttrCaps =
    { class : Available
    , floatLabel : Available
    , hideRequiredMarker : Available
    , hideSubscript : Available
    , id : Available
    , slot : Available
    , style : Available
    , variant : Available
    }


{-| The `SlotCaps` type row for FormField (generated).
-}
type alias SlotCaps =
    { error : Available
    , hint : Available
    , label : Available
    , prefix : Available
    , prefixText : Available
    , suffix : Available
    , suffixText : Available
    }
