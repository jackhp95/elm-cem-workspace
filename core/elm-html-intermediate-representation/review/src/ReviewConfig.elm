module ReviewConfig exposing (config)

{-| elm-review configuration for elm-html-intermediate-representation.

This is the Tier-0 hand-written IR package — every module is hand-written and
fully public. The full rule set runs on all of `src/` with no exclusions.

`NoInternalImportOutsideAllowed` is intentionally absent: that rule governs
_consumers_ of the IR (it prevents brand authors from importing
`HtmlIr.Internal` without opt-in), not the IR itself. It lives in
`jackhp95/elm-review-cem`, not here.

Run from the repo root:

    npm run review

-}

import NoDebug.Log
import NoDebug.TodoOrToString
import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Exports
import NoUnused.Modules
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import Review.Rule as Rule exposing (Rule)
import Simplify


config : List Rule
config =
    correctness ++ unused


{-| Correctness rules — run everywhere.
-}
correctness : List Rule
correctness =
    [ Simplify.rule Simplify.defaults
    , NoDebug.Log.rule
    , NoDebug.TodoOrToString.rule
    ]


{-| Unused-code rules.

Accepted findings (lint-fence, not bugs):

  - `NoUnused.CustomTypeConstructors` on `HtmlIr.Kind`: `Supported` and `Shared`
    are intentional phantom-only markers. Their constructors exist at the type
    level only — they are used as field types in extensible record rows, never as
    runtime values. Suppressed per-file rather than by passing them as exceptions
    to the rule, so the rule still catches accidental phantom constructors in
    other modules.

  - `NoUnused.Exports` on `HtmlIr.Internal`: functions like `fromNode`, `token`,
    `fromHtml`, `attribute`, `property`, `on`, `fromHtmlAttribute` are the forge
    surface — their callers live in generated brand packages in other repos, not
    inside this package. They have no in-repo callers by design.

-}
unused : List Rule
unused =
    [ NoUnused.Variables.rule
    , NoUnused.CustomTypeConstructors.rule []
        |> Rule.ignoreErrorsForFiles [ "src/HtmlIr/Kind.elm" ]
    , NoUnused.CustomTypeConstructorArgs.rule
    , NoUnused.Exports.rule
        |> Rule.ignoreErrorsForFiles [ "src/HtmlIr/Internal.elm" ]
    , NoUnused.Modules.rule
    , NoUnused.Parameters.rule
    , NoUnused.Patterns.rule
    ]
