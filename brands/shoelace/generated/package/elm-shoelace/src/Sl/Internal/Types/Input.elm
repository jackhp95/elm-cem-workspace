module Sl.Internal.Types.Input exposing (Is, Attrs, ChildAdmittedBy, Autocapitalize, Autocorrect, Enterkeyhint, Inputmode, Size, Type, Builder, AttrCaps)

{-| Type definitions for Input. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `Sl` barrel and the strict
`Sl.Component.Input` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Autocapitalize, Autocorrect, Enterkeyhint, Inputmode, Size, Type, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import Sl.Forge.Internal as B
import Sl.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Input (generated).
-}
type alias Is s =
    { s | input : Brand }


{-| The `Attrs` type row for Input (generated).
-}
type alias Attrs =
    { autocapitalize : Supported
    , autocomplete : Supported
    , autocorrect : Supported
    , autofocus : Supported
    , class : Supported
    , clearable : Supported
    , disabled : Supported
    , enterkeyhint : Supported
    , filled : Supported
    , form : Supported
    , helpText : Supported
    , id : Supported
    , inputmode : Supported
    , label : Supported
    , max : Supported
    , maxlength : Supported
    , min : Supported
    , minlength : Supported
    , name : Supported
    , noSpinButtons : Supported
    , onBlur : Supported
    , onChange : Supported
    , onClear : Supported
    , onFocus : Supported
    , onInput : Supported
    , onInvalid : Supported
    , passwordToggle : Supported
    , passwordVisible : Supported
    , pattern : Supported
    , pill : Supported
    , placeholder : Supported
    , readonly : Supported
    , required : Supported
    , size : Supported
    , slot : Supported
    , spellcheck : Supported
    , step : Supported
    , style : Supported
    , title : Supported
    , type_ : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for Input (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | input : Ctx }


{-| The `Autocapitalize` type row for Input (generated).
-}
type alias Autocapitalize =
    { characters : Supported
    , none : Supported
    , off : Supported
    , on : Supported
    , sentences : Supported
    , words : Supported
    }


{-| The `Autocorrect` type row for Input (generated).
-}
type alias Autocorrect =
    { off : Supported
    , on : Supported
    }


{-| The `Enterkeyhint` type row for Input (generated).
-}
type alias Enterkeyhint =
    { done : Supported
    , enter : Supported
    , go : Supported
    , next : Supported
    , previous : Supported
    , search : Supported
    , send : Supported
    }


{-| The `Inputmode` type row for Input (generated).
-}
type alias Inputmode =
    { decimal : Supported
    , email : Supported
    , none : Supported
    , numeric : Supported
    , search : Supported
    , tel : Supported
    , text : Supported
    , url : Supported
    }


{-| The `Size` type row for Input (generated).
-}
type alias Size =
    { large : Supported
    , medium : Supported
    , small : Supported
    }


{-| The `Type` type row for Input (generated).
-}
type alias Type =
    { date : Supported
    , datetimeLocal : Supported
    , email : Supported
    , number : Supported
    , password : Supported
    , search : Supported
    , tel : Supported
    , text : Supported
    , time : Supported
    , url : Supported
    }


{-| The `Builder` type row for Input (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Input (generated).
-}
type alias AttrCaps =
    { autocapitalize : Available
    , autocomplete : Available
    , autocorrect : Available
    , autofocus : Available
    , class : Available
    , clearable : Available
    , disabled : Available
    , enterkeyhint : Available
    , filled : Available
    , form : Available
    , helpText : Available
    , id : Available
    , inputmode : Available
    , label : Available
    , max : Available
    , maxlength : Available
    , min : Available
    , minlength : Available
    , name : Available
    , noSpinButtons : Available
    , onBlur : Available
    , onChange : Available
    , onClear : Available
    , onFocus : Available
    , onInput : Available
    , onInvalid : Available
    , passwordToggle : Available
    , passwordVisible : Available
    , pattern : Available
    , pill : Available
    , placeholder : Available
    , readonly : Available
    , required : Available
    , size : Available
    , slot : Available
    , spellcheck : Available
    , step : Available
    , style : Available
    , title : Available
    , type_ : Available
    , value : Available
    }
