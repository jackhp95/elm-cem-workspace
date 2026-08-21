module Sl.Internal.Types.BreadcrumbItem exposing (Is, Attrs, ChildAdmittedBy, Target, Builder, AttrCaps)

{-| Type definitions for BreadcrumbItem. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.BreadcrumbItem` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Target, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for BreadcrumbItem (generated).
-}
type alias Is s =
    { s | breadcrumbItem : Brand }


{-| The `Attrs` type row for BreadcrumbItem (generated).
-}
type alias Attrs =
    { class : Supported
    , href : Supported
    , id : Supported
    , rel : Supported
    , slot : Supported
    , style : Supported
    , target : Supported
    }


{-| The `ChildAdmittedBy` type row for BreadcrumbItem (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | breadcrumbItem : Ctx }


{-| The `Target` type row for BreadcrumbItem (generated).
-}
type alias Target =
    { blank_ : Supported
    , parent_ : Supported
    , self_ : Supported
    , top_ : Supported
    }


{-| The `Builder` type row for BreadcrumbItem (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for BreadcrumbItem (generated).
-}
type alias AttrCaps =
    { class : Available
    , href : Available
    , id : Available
    , rel : Available
    , slot : Available
    , style : Available
    , target : Available
    }
