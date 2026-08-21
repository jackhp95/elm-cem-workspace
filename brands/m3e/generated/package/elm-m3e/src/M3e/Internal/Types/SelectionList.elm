module M3e.Internal.Types.SelectionList exposing (Is, Attrs, Content, ChildAdmittedBy, Variant, Builder, AttrCaps)

{-| Type definitions for SelectionList. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.SelectionList` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Variant, Builder, AttrCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for SelectionList (generated).
-}
type alias Is s =
    { s | selectionList : Brand }


{-| The `Attrs` type row for SelectionList (generated).
-}
type alias Attrs =
    { class : Supported
    , disabled : Supported
    , hideSelectionIndicator : Supported
    , id : Supported
    , multi : Supported
    , name : Supported
    , onBeforeinput : Supported
    , onChange : Supported
    , onInput : Supported
    , slot : Supported
    , style : Supported
    , variant : Supported
    }


{-| The `Content` type row for SelectionList (generated).
-}
type alias Content =
    { divider : Brand
    , expandableListItem : Brand
    , listOption : Brand
    }


{-| The `ChildAdmittedBy` type row for SelectionList (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | selectionList : Ctx }


{-| The `Variant` type row for SelectionList (generated).
-}
type alias Variant =
    { segmented : Supported
    , standard : Supported
    }


{-| The `Builder` type row for SelectionList (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for SelectionList (generated).
-}
type alias AttrCaps =
    { class : Available
    , disabled : Available
    , hideSelectionIndicator : Available
    , id : Available
    , multi : Available
    , name : Available
    , onBeforeinput : Available
    , onChange : Available
    , onInput : Available
    , slot : Available
    , style : Available
    , variant : Available
    }
