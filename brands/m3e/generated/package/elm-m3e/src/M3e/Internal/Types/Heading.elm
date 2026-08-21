module M3e.Internal.Types.Heading exposing (Is, Attrs, Content, ChildAdmittedBy, Size, Variant, Builder, AttrCaps)

{-| Type definitions for Heading. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Heading` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Size, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Heading (generated).
-}
type alias Is s =
    { s | heading : Brand }


{-| The `Attrs` type row for Heading (generated).
-}
type alias Attrs =
    { class : Supported
    , emphasized : Supported
    , id : Supported
    , level : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , tocIgnore : Supported
    , variant : Supported
    }


{-| The `Content` type row for Heading (generated).
-}
type alias Content =
    { heading : Brand
    , sharedPhrasing : Shared
    , sharedText : Shared
    }


{-| The `ChildAdmittedBy` type row for Heading (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | heading : Ctx }


{-| The `Size` type row for Heading (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Variant` type row for Heading (generated).
-}
type alias Variant =
    { display : Supported
    , headline : Supported
    , label : Supported
    , title : Supported
    }


{-| The `Builder` type row for Heading (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Heading (generated).
-}
type alias AttrCaps =
    { class : Available
    , emphasized : Available
    , id : Available
    , level : Available
    , size : Available
    , slot : Available
    , style : Available
    , tocIgnore : Available
    , variant : Available
    }
