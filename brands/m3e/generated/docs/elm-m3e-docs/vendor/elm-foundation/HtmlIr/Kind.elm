module HtmlIr.Kind exposing (Supported, Shared)

{-| The cross-package phantom-row **marker vocabulary** — the only marker types
that must be shared by every library on the substrate, because unification
across package boundaries requires one common type.

Everything else is deliberately **per-brand**: each brand package mints its own
`Brand` kind marker (nominal privacy for its slot kinds), its own `Ctx` context
marker (so two brands' `admittedBy` fields never unify by accident, even under
the same field name), and — if it gates ARIA roles — its own `Role` marker.
The IR ships none of those; supplying a shared one would silently break brand
privacy.

@docs Supported, Shared

-}


{-| The field marker for **capability and value rows**: a field
`href : Supported` in an attribute's capability row means "admitted here"; a
field `filled : Supported` in a value's tag row means "this token is a legal
value here". Shared across brands on purpose — a native global attribute
(`class`, `id`) is admitted by any brand's element that lists the field.
-}
type Supported
    = Supported


{-| The **cross-library atom** kind marker. An accepts-row field typed `Shared`
(`{ s | sharedText : Shared }`) marks content any brand may produce and any
opted-in slot may admit — the text/icon/link atoms that make cross-brand
composition work without coercion. Brand-private kinds use the brand's own
marker type instead.
-}
type Shared
    = Shared
