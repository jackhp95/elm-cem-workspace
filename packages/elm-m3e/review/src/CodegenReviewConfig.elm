module CodegenReviewConfig exposing (config)

{-| The **M3e-specific** rules that accompany the namespace-agnostic,
facts-driven set (which comes from the `jackhp95/elm-review-cem` package). These
encode M3e's own project boundaries and are not part of the generic package.

@docs config

-}

import Cem.Facts
import M3e.Review.Facts
import NoInternalImportOutsideAllowed
import NoRedundantAttributeEscape
import NoRedundantElementEscape
import NoRedundantElementForge
import NoUnsafeImportOutsideAllowed
import Review.Rule exposing (Rule)
import TypedHtml.Review.Facts


{-| The facts both brands contribute, in ladder order.

M3e first is deliberate: when a redundant escape could be replaced by either a
design-system setter or a native one, the M3e suggestion is the one a reader
should see first. That is the same `M3e > TypedHtml > escape` ordering the
`auditing-m3e-escapes` skill enforces by hand.

-}
facts : List Cem.Facts.Fact
facts =
    M3e.Review.Facts.facts ++ TypedHtml.Review.Facts.facts


{-| The M3e-specific project-discipline rules.

**Escape discipline is three layers, not one**, because each catches what the
others structurally cannot:

1.  `NoUnsafeImportOutsideAllowed` — the _import_ fence. One error per module,
    naming no call site. Cheap, and it is the only layer that fires when a module
    has no business holding an escape at all.
2.  `NoRedundantAttributeEscape` / `NoRedundantElementEscape` — the _use_ layer.
    These name the specific call and the typed alternative that already exists,
    which the import fence cannot do, and they stay silent for modules that are
    allow-listed above.
3.  `NoRedundantElementForge` — the _producer_ layer, for a blessed adapter
    re-forging a plain tag `TypedHtml.*` already provides.

This replaces `NoSeamOutsideAllowedModules`, which had been repurposed to fence
`*.Unsafe` after the userland `Seam` module was deleted. That was a wheel already
in the box: `NoUnsafeImportOutsideAllowed` was built for exactly that job, and
running two rules over one boundary is how they drift apart.

-}
config : List Rule
config =
    [ -- The import fence. Allowed holders, and why each earns it:
      --   `M3e` / `TypedHtml` — generated brand code imports its own escapes.
      --   `Doc` / `Doc.Slider` — the doc-rendering adapters (Markdown, syntax
      --     highlighting, a `<slide-panels>` custom element).
      --   `Shared` — the app-shell root; raw `Html` chrome and the render exit.
      --   `View` — the page boundary; the app's single re-assertion of phantom
      --     rows onto an erased `Node`.
      --   `Route.Examples.Shop` — one documented `recast`; `AppBar.TrailingSlot`
      --     genuinely does not admit a Badge.
      --   `Route.Guide` — pedagogical: these pages' teaching subject IS the
      --     escape surface, shown inline as live examples.
      NoUnsafeImportOutsideAllowed.rule
        [ "M3e"
        , "TypedHtml"
        , "Doc"
        , "Shared"
        , "View"
        , "Route.Examples.Shop"
        , "Route.Guide"
        ]

    -- The use layer: names the call AND the typed setter that already exists.
    -- Evidence-driven — a setter is only ever suggested when the rule has seen
    -- its declaration, so it degrades to silence rather than to guesswork.
    , NoRedundantAttributeEscape.rule
        { setterModules = []

        -- The element-independent vocabulary, read from the generator rather than
        -- hardcoded in the rule. Both brands contribute: TypedHtml carries HTML's
        -- `_globals` roster, M3e carries its own four. A name outside this set is
        -- element-SPECIFIC, and the rule must stay silent about it — from an escape
        -- call site, `content` on a `<meta>` is indistinguishable from `content` on a
        -- custom element that gives the name its own meaning.
        , globalAttributes =
            M3e.Review.Facts.globalAttributes ++ TypedHtml.Review.Facts.globalAttributes
        }
        facts
    , NoRedundantElementEscape.rule { seamEscapes = [] } facts
        -- `app/Shared.elm` holds the app's ONE render exit: elm-pages' `Shared.view`
        -- must return `{ body : List (Html msg) }`, so the shell has to call
        -- `M3e.toHtml` exactly once. The rule is right in general — dropping a typed
        -- Element to plain `Html` discards slot checking — but at the boundary that
        -- is the required move, not a reflex. Verified there is exactly one
        -- `toHtml` call in the whole app, and it is that one.
        |> Review.Rule.ignoreErrorsForFiles [ "app/Shared.elm", "docs/app/Shared.elm" ]
    , NoRedundantElementForge.rule TypedHtml.Review.Facts.facts

    -- The opaque-IR `*.Internal` boundary (docs/DESIGN.md §4): only generated
    -- brand code may import an interior module. Userland has no business here at
    -- all — the generated `*.Unsafe` modules are the sanctioned crossings, and
    -- they live inside the brand.
    , NoInternalImportOutsideAllowed.rule [ "M3e", "TypedHtml", "HtmlIr" ]
    ]
