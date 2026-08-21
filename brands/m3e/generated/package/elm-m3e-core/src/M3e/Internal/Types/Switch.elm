module M3e.Internal.Types.Switch exposing (Is, Attrs, ChildAdmittedBy, Icons, Builder, AttrCaps)

{-| Type definitions for Switch. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Switch` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Icons, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Switch (generated).
-}
type alias Is s =
    { s | switch : Brand }


{-| The `Attrs` type row for Switch (generated).
-}
type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , icons : Supported
    , id : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , slot : Supported
    , style : Supported
    , validationmessages : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for Switch (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | switch : Ctx }


{-| The `Icons` type row for Switch (generated).
-}
type alias Icons =
    { both : Supported
    , none : Supported
    , selected : Supported
    }


{-| The `Builder` type row for Switch (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Switch (generated).
-}
type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , icons : Available
    , id : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , slot : Available
    , style : Available
    , validationmessages : Available
    , value : Available
    }
