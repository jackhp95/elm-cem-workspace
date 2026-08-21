module M3e.Internal.Types.Option exposing (Is, Attrs, Content, ChildAdmittedBy, HighlightMode, Builder, AttrCaps)

{-| Type definitions for Option. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Option` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, HighlightMode, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Option (generated).
-}
type alias Is s =
    { s | option : Brand }


{-| The `Attrs` type row for Option (generated).
-}
type alias Attrs =
    { class : Supported
    , disableHighlight : Supported
    , disabled : Supported
    , highlightMode : Supported
    , id : Supported
    , selected : Supported
    , slot : Supported
    , style : Supported
    , term : Supported
    , value : Supported
    }


{-| The `Content` type row for Option (generated).
-}
type alias Content =
    { heading : Brand
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for Option (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | option : Ctx }


{-| The `HighlightMode` type row for Option (generated).
-}
type alias HighlightMode =
    { contains : Supported
    , endsWith : Supported
    , startsWith : Supported
    }


{-| The `Builder` type row for Option (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Option (generated).
-}
type alias AttrCaps =
    { class : Available
    , disableHighlight : Available
    , disabled : Available
    , highlightMode : Available
    , id : Available
    , selected : Available
    , slot : Available
    , style : Available
    , term : Available
    , value : Available
    }
