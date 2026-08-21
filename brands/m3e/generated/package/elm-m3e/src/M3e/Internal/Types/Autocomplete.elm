module M3e.Internal.Types.Autocomplete exposing (Is, Attrs, Content, ChildAdmittedBy, Filter, Builder, AttrCaps, SlotCaps)

{-| Type definitions for Autocomplete. The canonical home of this
component's `Attrs`/`Is`/`Content`/… rows: the `M3e` barrel and the strict
`M3e.Element.Autocomplete` surface both re-export these, so they live in
the shared `core` tier (design §3.2a).

@docs Is, Attrs, Content, ChildAdmittedBy, Filter, Builder, AttrCaps, SlotCaps

-}

import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value as Val exposing (Value)
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)


{-| The `Is` type row for Autocomplete (generated).
-}
type alias Is s =
    { s | autocomplete : Brand }


{-| The `Attrs` type row for Autocomplete (generated).
-}
type alias Attrs =
    { autoActivate : Supported
    , caseSensitive : Supported
    , class : Supported
    , filter : Supported
    , for : Supported
    , hideLoading : Supported
    , hideNoData : Supported
    , hideSelectionIndicator : Supported
    , id : Supported
    , loading : Supported
    , loadingLabel : Supported
    , noDataLabel : Supported
    , onChange : Supported
    , onQuery : Supported
    , onToggle : Supported
    , panelClass : Supported
    , required : Supported
    , resultsLabel : Supported
    , slot : Supported
    , style : Supported
    }


{-| The `Content` type row for Autocomplete (generated).
-}
type alias Content =
    { optgroup : Brand
    , option : Brand
    }


{-| The `ChildAdmittedBy` type row for Autocomplete (generated).
-}
type alias ChildAdmittedBy childAdm =
    { childAdm | autocomplete : Ctx }


{-| The `Filter` type row for Autocomplete (generated).
-}
type alias Filter =
    { contains : Supported
    , endsWith : Supported
    , none : Supported
    , startsWith : Supported
    }


{-| The `Builder` type row for Autocomplete (generated).
-}
type alias Builder attrCaps slotCaps msg s =
    B.Builder Attrs attrCaps slotCaps (Is s) msg


{-| The `AttrCaps` type row for Autocomplete (generated).
-}
type alias AttrCaps =
    { autoActivate : Available
    , caseSensitive : Available
    , class : Available
    , filter : Available
    , for : Available
    , hideLoading : Available
    , hideNoData : Available
    , hideSelectionIndicator : Available
    , id : Available
    , loading : Available
    , loadingLabel : Available
    , noDataLabel : Available
    , onChange : Available
    , onQuery : Available
    , onToggle : Available
    , panelClass : Available
    , required : Available
    , resultsLabel : Available
    , slot : Available
    , style : Available
    }


{-| The `SlotCaps` type row for Autocomplete (generated).
-}
type alias SlotCaps =
    { loading : Available
    , noData : Available
    }
