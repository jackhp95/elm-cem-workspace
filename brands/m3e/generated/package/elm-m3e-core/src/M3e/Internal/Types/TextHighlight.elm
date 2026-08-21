module M3e.Internal.Types.TextHighlight exposing (Is, Attrs, ChildAdmittedBy, Mode, Builder, AttrCaps)

{-| Type definitions for TextHighlight. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.TextHighlight` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Mode, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for TextHighlight (generated).
-}
type alias Is s =
    { s | textHighlight : Brand }


{-| The `Attrs` type row for TextHighlight (generated).
-}
type alias Attrs =
    { caseSensitive : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , mode : Supported
    , onHighlight : Supported
    , slot : Supported
    , style : Supported
    , term : Supported
    }


{-| The `ChildAdmittedBy` type row for TextHighlight (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | textHighlight : Ctx }


{-| The `Mode` type row for TextHighlight (generated).
-}
type alias Mode =
    { contains : Supported
    , endsWith : Supported
    , startsWith : Supported
    }


{-| The `Builder` type row for TextHighlight (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for TextHighlight (generated).
-}
type alias AttrCaps =
    { caseSensitive : Available
    , class : Available
    , disabled : Available
    , id : Available
    , mode : Available
    , onHighlight : Available
    , slot : Available
    , style : Available
    , term : Available
    }
