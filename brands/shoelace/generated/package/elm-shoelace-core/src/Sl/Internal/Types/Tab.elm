module Sl.Internal.Types.Tab exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Tab. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Tab` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Tab (generated).
-}
type alias Is s =
    { s | tab : Brand }


{-| The `Attrs` type row for Tab (generated).
-}
type alias Attrs =
    { active : Supported
    , class : Supported
    , closable : Supported
    , disabled : Supported
    , id : Supported
    , onClose : Supported
    , panel : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for Tab (generated).
-}
type alias Content =
    { avatar : Brand
    , badge : Brand
    , formatBytes : Brand
    , formatDate : Brand
    , formatNumber : Brand
    , icon : Brand
    , relativeTime : Brand
    , sharedText : Shared
    , spinner : Brand
    , tag : Brand
    , visuallyHidden : Brand
    }


{-| The `ChildAdmittedBy` type row for Tab (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | tab : Ctx }


{-| The `Builder` type row for Tab (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Tab (generated).
-}
type alias AttrCaps =
    { active : Available
    , class : Available
    , closable : Available
    , disabled : Available
    , id : Available
    , onClose : Available
    , panel : Available
    , slot : Available
    , style : Available
    }
