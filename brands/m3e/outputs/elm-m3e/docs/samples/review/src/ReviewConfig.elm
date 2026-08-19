module ReviewConfig exposing (config)

{-| The elm-review configuration for the **guide samples** project
(`docs/samples`), whose modules are generated from the Elm code the guide pages
display. See `docs/samples/README.md`.

This is deliberately NOT the docs app's config (`review/src/ReviewConfig.elm`).
A displayed sample is a *fragment*, not application source: it has no type
annotations to be missing, nothing imports it, and it exports one binding on
purpose. Running `NoMissingTypeAnnotation` / `NoUnused.*` / `NoExposingEverything`
over it would produce nothing but noise, and a gate that cries wolf gets turned
off.

What a sample IS accountable for is the discipline it teaches, so this config
keeps exactly two families.

**1. Escape discipline** — taken WHOLE from `CodegenReviewConfig`, the same value
the docs app runs (a byte copy of `review/src/CodegenReviewConfig.elm`, refreshed
by `npm run gen:samples` and byte-compared by `check:drift`, so the two cannot
disagree about what an escape is or drift as the rules' own APIs change). This is
the family that would have caught `/guide/tooling-refactors` shipping
`M3e.Unsafe.Attributes.fromHtmlAttribute (class "…")` as its *after-autofix*
result while `TypedHtml.Attributes.class` existed.

Exactly one rule is swapped, by name, and only its allow-list changes:
`NoUnsafeImportOutsideAllowed` allow-lists `Sample`. Guide samples about the
escape surface must be able to hold an escape — the same reason the docs config
allow-lists `Route.Guide` ("these pages' teaching subject IS the escape surface").
Layer 1, the *import* fence, therefore says nothing here; layers 2–3, the *use*
layer, have no allow-list and are what actually judge a sample. They are also the
layers that can name the typed setter a needless escape should have been.

**2. Facts-driven correctness** — the `Cem.*` rules read the same generated
manifest the API was generated from, so a sample cannot invent an enum token,
drop a required attribute, or fill a one-only slot twice. Same set and posture as
the docs config.

Two rules the docs config runs are deliberately absent, both for the reason it
already exempts `app/Route/Guide/`: `Cem.preferBarrel` and
`Cem.preferComponentSetters` are layer/form *preferences*, and the Guide teaches
every layer on purpose — `/guide/the-layers` and `/guide/cheat-sheet` show the
per-component form precisely because it exists. Gating samples on a form the
pages are contrasting would fire on the pages doing their job.

-}

import Cem
import CodegenReviewConfig
import M3e.Review.Facts
import NoUnsafeImportOutsideAllowed
import Review.Rule as Rule exposing (Rule)


config : List Rule
config =
    List.map ignoreNonSampleSources (escapeDiscipline ++ factsDriven)


{-| The docs app's escape rules verbatim, with the import fence re-pointed at
`Sample`. Swapping by `Rule.ruleName` keeps this a one-line divergence instead of
a second copy of the rule list that could quietly fall behind.
-}
escapeDiscipline : List Rule
escapeDiscipline =
    NoUnsafeImportOutsideAllowed.rule [ "Sample" ]
        :: List.filter
            (\rule -> Rule.ruleName rule /= "NoUnsafeImportOutsideAllowed")
            CodegenReviewConfig.config


{-| The facts-driven correctness set, mirroring `codegenAware` in the docs config
minus its two form preferences (see the module docs).
-}
factsDriven : List Rule
factsDriven =
    [ Cem.validEnumValue M3e.Review.Facts.facts
    , Cem.requireSlot M3e.Review.Facts.facts
    , Cem.singularSlot M3e.Review.Facts.facts
    , Cem.singularAttribute M3e.Review.Facts.facts
    , Cem.missingRequiredAttribute M3e.Review.Facts.facts
    , Cem.missingRequiredSingularSlot M3e.Review.Facts.facts
    , Cem.validSlotKindWith Cem.Lenient M3e.Review.Facts.facts
    ]


{-| The review runs over the WHOLE samples project, not just `good/`, because
`NoRedundantAttributeEscape` is a project rule: it only claims a typed setter
exists once it has *seen that setter's declaration*, which means it has to visit
`TypedHtml.Attributes`. Scoped to `good/` it degrades to silence — a green run
that proves nothing. So the ignores below are what narrow it back down.

`docs/samples/elm.json` lists the generated library and the vendored foundation
as source-directories so samples compile against the real API. Neither is sample
code, and both are gated by their own regen-diff checks — never lint them from
here. `support/` is the hand-written stub module the samples import; its
polymorphic stubs are built with `recast` on purpose (see its module docs), which
is a statement about the harness, not about any sample. `bad/` holds probes that
are *supposed* not to compile; the compiler already judges them, and linting code
that does not typecheck says nothing useful.

`../../tests/` is the library's own elm-test project. elm-review reaches it from
the `../../src` source-directory the same way it does from `docs/`, where the
docs config already ignores it wholesale (`ignoreLibraryTests`) — it is not docs
source and not a sample, and it has its own gate.
-}
ignoreNonSampleSources : Rule -> Rule
ignoreNonSampleSources =
    Rule.ignoreErrorsForDirectories
        [ "../../src/"
        , "../vendor/elm-foundation/"
        , "support/"
        , "bad/"
        , "../../tests/"
        ]
