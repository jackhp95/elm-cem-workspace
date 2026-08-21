module Sl.Internal.Types.ColorPicker exposing (Is, Attrs, ChildAdmittedBy, Format, Size, Builder, AttrCaps)

{-| Type definitions for ColorPicker. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Element.ColorPicker` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Format, Size, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for ColorPicker (generated).
-}
type alias Is s =
    { s | colorPicker : Brand }


{-| The `Attrs` type row for ColorPicker (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , form : Supported
    , format : Supported
    , hoist : Supported
    , id : Supported
    , inline : Supported
    , label : Supported
    , name : Supported
    , noFormatToggle : Supported
    , onBlur : Supported
    , onChange : Supported
    , onFocus : Supported
    , onInput : Supported
    , onInvalid : Supported
    , opacity : Supported
    , required : Supported
    , size : Supported
    , slot : Supported
    , style : Supported
    , swatches : Supported
    , uppercase : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for ColorPicker (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | colorPicker : Ctx }


{-| The `Format` type row for ColorPicker (generated).
-}
type alias Format =
    { hex : Supported
    , hsl : Supported
    , hsv : Supported
    , rgb : Supported
    }


{-| The `Size` type row for ColorPicker (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Builder` type row for ColorPicker (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for ColorPicker (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , form : Available
    , format : Available
    , hoist : Available
    , id : Available
    , inline : Available
    , label : Available
    , name : Available
    , noFormatToggle : Available
    , onBlur : Available
    , onChange : Available
    , onFocus : Available
    , onInput : Available
    , onInvalid : Available
    , opacity : Available
    , required : Available
    , size : Available
    , slot : Available
    , style : Available
    , swatches : Available
    , uppercase : Available
    , value : Available
    }
