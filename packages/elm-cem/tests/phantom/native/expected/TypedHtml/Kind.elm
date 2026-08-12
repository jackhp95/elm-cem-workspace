module TypedHtml.Kind exposing
    ( Brand, Ctx, Role
    , Available, Used
    , Supported, Shared
    , Flow, Phrasing
    )

{-| The library's private phantom markers and named kind/context sets.

`Brand` marks this library's kind-row fields; `Ctx` marks its context-row
fields. Both are nominal and private to this library — a foreign library's
markers never unify with them, even under the same field name.
`Available`/`Used` are the pipe-builder's write-once capability markers.

`Supported` and `Shared` are the CROSS-library markers, re-exported from
the IR substrate so callers never import `HtmlIr.Kind` directly. Unlike
`Brand`/`Ctx` these are deliberately shared: every brand's `Supported` is
the same type, and a `Shared`-marked atom is admissible into any brand's
opted-in slot.

@docs Brand, Ctx, Role
@docs Available, Used
@docs Supported, Shared
@docs Flow, Phrasing

-}

import HtmlIr.Kind


{-| Admission marker for capability and value rows. Re-exported from `HtmlIr.Kind`.
-}
type alias Supported =
    HtmlIr.Kind.Supported


{-| The cross-library atom marker. Re-exported from `HtmlIr.Kind`.
-}
type alias Shared =
    HtmlIr.Kind.Shared


{-| The private kind marker (never constructed).
-}
type Brand
    = Brand_


{-| The private context marker (never constructed).
-}
type Ctx
    = Ctx_


{-| The private ARIA-role marker (never constructed).
-}
type Role
    = Role_


{-| Pipe-builder capability: still writable.
-}
type Available
    = Available_


{-| Pipe-builder capability: consumed.
-}
type Used
    = Used_


{-| The `flow` kind set.
-}
type alias Flow =
    { a : Brand
    , div : Brand
    , fieldset : Brand
    , p : Brand
    , picture : Brand
    , select : Brand
    , video : Brand
    }


{-| The `phrasing` kind set.
-}
type alias Phrasing =
    { a : Brand
    , span : Brand
    }
