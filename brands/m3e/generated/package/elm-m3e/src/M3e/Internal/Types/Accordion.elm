module M3e.Internal.Types.Accordion exposing (Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Accordion. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Accordion` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Accordion (generated).
-}
type alias Is s =
    { s | accordion : Brand }


{-| The `Attrs` type row for Accordion (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , multi : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for Accordion (generated).
-}
type alias Content =
    { expansionPanel : Brand }


{-| The `ChildAdmittedBy` type row for Accordion (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | accordion : Ctx }


{-| The `Builder` type row for Accordion (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Accordion (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , multi : Available
    , slot : Available
    , style : Available
    }
