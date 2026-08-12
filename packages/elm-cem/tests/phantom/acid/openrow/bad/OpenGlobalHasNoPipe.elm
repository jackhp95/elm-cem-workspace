module OpenGlobalHasNoPipe exposing (broken)

{-| An open global gets NO `with<Field>` builder pipe. MUST FAIL.

A pipe consumes a capability field Available→Used, and an open global has no row
membership to consume — it is admitted structurally, by every element, forever.
So `withOflag` must not exist, while `withCflag` (its closed twin) must.

This is the builder-side half of "absent from every element's `Attrs` alias": the
`Attrs` record and the `AttrCaps` record are minted from the same field list, so a
pipe appearing here would mean the closed row grew the field back.

Deliberately UNANNOTATED: the only thing that may reject this module is the
absence of `withOflag` itself. An annotation could fail to unify for some
unrelated reason and this probe would "pass" while testing nothing — which is
exactly what it did on first draft.

-}

import Or.Plain


broken =
    Or.Plain.build |> Or.Plain.withOflag True
