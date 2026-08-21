module Mini.Internal.Types.Icon exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Icon. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Mini` barrel and the strict
`Mini.Element.Icon` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import Mini.Forge.Internal as B
import Mini.Kind exposing (Available, Ctx, Used)


{-| The `Is` type row for Icon (generated).
-}
type alias Is s =
    { s | sharedIcon : Shared }


{-| The `Attrs` type row for Icon (generated).
-}
type alias Attrs =
    { class : Supported
    , dir : Supported
    , id : Supported
    , inert : Supported
    , slot : Supported
    , style : Supported
    , tabindex : Supported
    }


{-| The `Content` type row for Icon (generated).
-}
type alias Content =
    { sharedText : Shared }


{-| The `ChildAdmittedBy` type row for Icon (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | icon : Ctx }


{-| The `Builder` type row for Icon (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Icon (generated).
-}
type alias AttrCaps =
    { class : Available
    , dir : Available
    , id : Available
    , inert : Available
    , slot : Available
    , style : Available
    , tabindex : Available
    }
