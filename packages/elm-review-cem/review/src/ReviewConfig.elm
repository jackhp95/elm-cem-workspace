module ReviewConfig exposing (config)

{-| Dogfood review configuration for elm-review-cem itself.

This runs the standard jfmengels unused/simplify set over this package's own
`src/` and `tests/`. It is deliberately conservative: correctness/hygiene rules
only, no stylistic bikeshedding.

NOTE: this package's OWN `Cem.*` rules are NOT (and cannot be) run here. They are
codegen-driven — each takes a generated `List Cem.Facts.Fact` value emitted by
`elm-cem` into a consuming library. This repo generates no such facts, so there
is nothing for the `Cem.*` rules to check. They are exercised by the test suite
(`tests/`) against hand-written fixtures instead.

Do not rename the ReviewConfig module or the config function: `elm-review`
looks for these by name.

-}

import NoExposingEverything
import NoImportingEverything
import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Modules
import NoUnused.Patterns
import NoUnused.Variables
import Review.Rule exposing (Rule)
import Simplify


config : List Rule
config =
    [ NoExposingEverything.rule
    , NoImportingEverything.rule []
    , NoUnused.CustomTypeConstructors.rule []
    , NoUnused.CustomTypeConstructorArgs.rule
    , NoUnused.Dependencies.rule
    , NoUnused.Modules.rule
    , NoUnused.Patterns.rule
    , NoUnused.Variables.rule
    , Simplify.rule Simplify.defaults

    -- NoUnused.Exports is intentionally NOT enabled: this is a *published
    -- package*, whose exposed API (every rule module) is consumed externally, so
    -- elm-review cannot see those usages and would report the entire public
    -- surface as unused.
    --
    -- NoMissingTypeAnnotationInLetIn / NoMissingTypeAnnotation are intentionally
    -- NOT enabled: this codebase deliberately leaves most `let` bindings
    -- unannotated (their types are obvious from a one-line RHS), and annotating
    -- all ~230 of them would be noise, not signal.
    --
    -- NoUnused.Parameters is intentionally NOT enabled: several helpers keep a
    -- `_`/unused parameter to hold a shared function signature (e.g. the
    -- per-facet `Fact -> ... -> String` emitters), which the rule cannot
    -- distinguish from genuine dead parameters.
    ]
