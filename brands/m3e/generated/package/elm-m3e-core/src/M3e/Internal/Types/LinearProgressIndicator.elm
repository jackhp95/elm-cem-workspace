module M3e.Internal.Types.LinearProgressIndicator exposing (Is, Attrs, ChildAdmittedBy, Mode, Variant, Builder, AttrCaps)

{-| Type definitions for LinearProgressIndicator. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.LinearProgressIndicator` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Mode, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for LinearProgressIndicator (generated).
-}
type alias Is s =
    { s | linearProgressIndicator : Brand }


{-| The `Attrs` type row for LinearProgressIndicator (generated).
-}
type alias Attrs =
    { bufferValue : Supported
    , class : Supported
    , id : Supported
    , max : Supported
    , mode : Supported
    , slot : Supported
    , style : Supported
    , value : Supported
    , variant : Supported
    }


{-| The `ChildAdmittedBy` type row for LinearProgressIndicator (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | linearProgressIndicator : Ctx }


{-| The `Mode` type row for LinearProgressIndicator (generated).
-}
type alias Mode =
    { buffer : Supported
    , determinate : Supported
    , indeterminate : Supported
    , query : Supported
    }


{-| The `Variant` type row for LinearProgressIndicator (generated).
-}
type alias Variant =
    { flat : Supported
    , wavy : Supported
    }


{-| The `Builder` type row for LinearProgressIndicator (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for LinearProgressIndicator (generated).
-}
type alias AttrCaps =
    { bufferValue : Available
    , class : Available
    , id : Available
    , max : Available
    , mode : Available
    , slot : Available
    , style : Available
    , value : Available
    , variant : Available
    }
