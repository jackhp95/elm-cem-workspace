module Hz.Internal.Types.EventClash exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for EventClash. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Hz` barrel and the strict
`Hz.Element.EventClash` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import Hz.Forge.Internal as B
import Hz.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for EventClash (generated).
-}
type alias Is s =
    { s | eventClash : Brand }


{-| The `Attrs` type row for EventClash (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , onError : Supported
    , onHzError : Supported
    , onHzLoad : Supported
    , onLoad : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for EventClash (generated).
-}
type alias Content =
    {}


{-| The `ChildAdmittedBy` type row for EventClash (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | eventClash : Ctx }


{-| The `Builder` type row for EventClash (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for EventClash (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , onError : Available
    , onHzError : Available
    , onHzLoad : Available
    , onLoad : Available
    , slot : Available
    , style : Available
    }
