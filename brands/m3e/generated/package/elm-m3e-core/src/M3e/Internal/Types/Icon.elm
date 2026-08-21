module M3e.Internal.Types.Icon exposing (Is, Attrs, ChildAdmittedBy, Grade, Variant, Builder, AttrCaps)

{-| Type definitions for Icon. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.Icon` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Grade, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Ctx, Used)


{-| The `Is` type row for Icon (generated).
-}
type alias Is s =
    { s | sharedIcon : Shared }


{-| The `Attrs` type row for Icon (generated).
-}
type alias Attrs =
    { class : Supported
    , filled : Supported
    , grade : Supported
    , id : Supported
    , name : Supported
    , opticalSize : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    , weight : Supported
    }


{-| The `ChildAdmittedBy` type row for Icon (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | icon : Ctx }


{-| The `Grade` type row for Icon (generated).
-}
type alias Grade =
    { high : Supported
    , low : Supported
    , medium : Supported
    }


{-| The `Variant` type row for Icon (generated).
-}
type alias Variant =
    { outlined : Supported
    , rounded : Supported
    , sharp : Supported
    }


{-| The `Builder` type row for Icon (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Icon (generated).
-}
type alias AttrCaps =
    { class : Available
    , filled : Available
    , grade : Available
    , id : Available
    , name : Available
    , opticalSize : Available
    , slot : Available
    , style : Available
    , variant : Available
    , weight : Available
    }
