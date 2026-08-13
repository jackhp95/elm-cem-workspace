module M3e.Internal.Types.FormField exposing (..)

{-| Internal type definitions for FormField — unexposed so docs.json
shows short qualified references instead of expanded record rows.
-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Build.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


type alias Is s =
    { s | formField : Brand }


type alias Attrs =
    { class : Supported
    , floatLabel : Supported
    , hideRequiredMarker : Supported
    , hideSubscript : Supported
    , id : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


type alias ChildAdmittedBy childAdm =
    { childAdm | formField : Ctx }


type alias FloatLabel =
    { always : Supported
    , auto : Supported
    }


type alias HideSubscript =
    { always : Supported
    , auto : Supported
    , never : Supported
    }


type alias Variant =
    { filled : Supported
    , outlined : Supported
    }


type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


type alias AttrCaps =
    { class : Available
    , floatLabel : Available
    , hideRequiredMarker : Available
    , hideSubscript : Available
    , id : Available
    , slot : Available
    , style : Available
    , variant : Available
    }


type alias SlotCaps =
    { error : Available
    , hint : Available
    , label : Available
    , prefix : Available
    , prefixText : Available
    , suffix : Available
    , suffixText : Available
    }
