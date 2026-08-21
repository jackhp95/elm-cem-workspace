module M3e.Internal.Types.RadioGroup exposing (Is, Attrs, ChildAdmittedBy, Builder, AttrCaps)

{-| Type definitions for RadioGroup. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Component.RadioGroup` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, ChildAdmittedBy, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for RadioGroup (generated).
-}
type alias Is s =
    { s | radioGroup : Brand }


{-| The `Attrs` type row for RadioGroup (generated).
-}
type alias Attrs =
    { ariaInvalid : Supported
    , class : Supported
    , disabled : Supported
    , id : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , required : Supported
    , slot : Supported
    , style : Supported
    , validationmessages : Supported
    }


{-| The `ChildAdmittedBy` type row for RadioGroup (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | radioGroup : Ctx }


{-| The `Builder` type row for RadioGroup (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for RadioGroup (generated).
-}
type alias AttrCaps =
    { ariaInvalid : Available
    , class : Available
    , disabled : Available
    , id : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , required : Available
    , slot : Available
    , style : Available
    , validationmessages : Available
    }
