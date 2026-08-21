module M3e.Internal.Types.Shape exposing (Is, Attrs, ChildAdmittedBy, Name, Builder, AttrCaps)

{-| Type definitions for Shape. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Shape` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Name, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Shape (generated).
-}
type alias Is s =
    { s | shape : Brand }


{-| The `Attrs` type row for Shape (generated).
-}
type alias Attrs =
    { class : Supported
    , id : Supported
    , name : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `ChildAdmittedBy` type row for Shape (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | shape : Ctx }


{-| The `Name` type row for Shape (generated).
-}
type alias Name =
    { value12SidedCookie : Supported
    , value4LeafClover : Supported
    , value4SidedCookie : Supported
    , value6SidedCookie : Supported
    , value7SidedCookie : Supported
    , value8LeafClover : Supported
    , value9SidedCookie : Supported
    , arch : Supported
    , arrow : Supported
    , boom : Supported
    , bun : Supported
    , burst : Supported
    , circle : Supported
    , diamond : Supported
    , fan : Supported
    , flower : Supported
    , gem : Supported
    , ghostIsh : Supported
    , heart : Supported
    , hexagon : Supported
    , oval : Supported
    , pentagon : Supported
    , pill : Supported
    , pixelCircle : Supported
    , pixelTriangle : Supported
    , puffy : Supported
    , puffyDiamond : Supported
    , semicircle : Supported
    , slanted : Supported
    , softBoom : Supported
    , softBurst : Supported
    , square : Supported
    , sunny : Supported
    , triangle : Supported
    , verySunny : Supported
    }


{-| The `Builder` type row for Shape (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Shape (generated).
-}
type alias AttrCaps =
    { class : Available
    , id : Available
    , name : Available
    , slot : Available
    , style : Available
    }
