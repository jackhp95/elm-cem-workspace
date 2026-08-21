module M3e.Internal.Types.Checkbox exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for Checkbox. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Checkbox` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Checkbox (generated).
-}
type alias Is s =
    { s | checkbox : Brand }


{-| The `Attrs` type row for Checkbox (generated).
-}
type alias Attrs =
    { checked : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , indeterminate : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onClick : Supported
    , onInput : Supported
    , onInvalid : Supported
    , required : Supported
    , slot : Supported
    , style : Supported
    , validationmessages : Supported
    , value : Supported
    }


{-| The `ChildAdmittedBy` type row for Checkbox (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | checkbox : Ctx }


{-| The `Builder` type row for Checkbox (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Checkbox (generated).
-}
type alias AttrCaps =
    { checked : Available
    , class : Available
    , disabled : Available
    , id : Available
    , indeterminate : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onClick : Available
    , onInput : Available
    , onInvalid : Available
    , required : Available
    , slot : Available
    , style : Available
    , validationmessages : Available
    , value : Available
    }
