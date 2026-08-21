module Sl.Internal.Types.Range exposing (Is, Attrs, ChildAdmittedBy, Tooltip, Builder, AttrCaps)

{-| Type definitions for Range. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.Range` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Tooltip, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Range (generated).
-}
type alias Is s =
    { s | range : Brand }


{-| The `Attrs` type row for Range (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , form : Supported
    , helpText : Supported
    , id : Supported
    , label : Supported
    , max : Supported
    , min : Supported
    , name : Supported
    , onBlur : Supported
    , onChange : Supported
    , onFocus : Supported
    , onInput : Supported
    , onInvalid : Supported
    , slot : Supported
    , step : Supported
    , style : Supported
    , title : Supported
    , tooltip : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for Range (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | range : Ctx }


{-| The `Tooltip` type row for Range (generated).
-}
type alias Tooltip =
    { bottom : Supported
    , none : Supported
    , top : Supported
    }


{-| The `Builder` type row for Range (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Range (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , form : Available
    , helpText : Available
    , id : Available
    , label : Available
    , max : Available
    , min : Available
    , name : Available
    , onBlur : Available
    , onChange : Available
    , onFocus : Available
    , onInput : Available
    , onInvalid : Available
    , slot : Available
    , step : Available
    , style : Available
    , title : Available
    , tooltip : Available
    , value : Available
    }
