module Sl.Internal.Types.Tag exposing (Is, Attrs, ChildAdmittedBy, Size, Variant, Builder, AttrCaps)

{-| Type definitions for Tag. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Tag` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Size, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Tag (generated).
-}
type alias Is s =
    { s | tag : Brand }


{-| The `Attrs` type row for Tag (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , onRemove : Supported
    , pill : Supported
    , removable : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `ChildAdmittedBy` type row for Tag (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | tag : Ctx }


{-| The `Size` type row for Tag (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Variant` type row for Tag (generated).
-}
type alias Variant =
    { danger : Supported
    , neutral : Supported
    , primary : Supported
    , success : Supported
    , text : Supported
    , warning : Supported
    }


{-| The `Builder` type row for Tag (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Tag (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , onRemove : Available
    , pill : Available
    , removable : Available
    , size : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
