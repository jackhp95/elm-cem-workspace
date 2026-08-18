module CodegenReviewConfig exposing (config)

{-| The **M3e-specific** rules that accompany the namespace-agnostic,
facts-driven set (which comes from the `jackhp95/elm-review-cem` package). These
encode M3e's own project boundaries and are not part of the generic package.

@docs config

-}

import Cem.Facts
import M3e.Review.Facts
import NoInternalImportOutsideAllowed
import NoMergedPipeAndSetter
import NoRedundantAttributeEscape
import NoRedundantElementEscape
import NoRedundantElementForge
import NoSeamOutsideAllowedModules
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

This replaces `NoSeamOutsideAllowedModules`'s old job of fencing `*.Unsafe`
directly (repurposed to that after the userland `Seam` module was deleted):
`NoUnsafeImportOutsideAllowed` was built for exactly that job, and running two
rules over one boundary is how they drift apart.

**`NoSeamOutsideAllowedModules` is still in the list below**, but for a
narrower, forward-looking job: containing `Recast`, the reserved destination
module name `ExtractToSeam` (`jackhp95/elm-review-cem`, opt-in `--fix`, kept
OUT of this gate) writes escapes into when a team runs it to hoist scattered
`M3e.Unsafe.recast` / `M3e.Unsafe.Attributes.recastAttr` calls into one place.
Today no `Recast` module exists in this project, so this entry is a no-op
(zero live findings) — but the import fence above only ever gates literal
`import *.Unsafe`, so a _hoisted_ `Recast.recastFoo` call site would import
`Recast`, not `M3e.Unsafe`, and would silently slip past it. Reserving
`"Recast"` here means the day someone runs `ExtractToSeam` with
`recastModule = "Recast"`, containment is already live with no further gate
change. If a team picks a different `recastModule` name, add it to both this
rule's `seamModules` and the import fence's allow-list (`Recast` is
allow-listed there too, since the destination module legitimately imports
`M3e.Unsafe` to wrap it).

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
      --   `Recast` — reserved `ExtractToSeam` destination (see docstring); the
      --     hoisted module itself is allowed to hold the `M3e.Unsafe` import
      --     it wraps.
      --   `Route.Components.Compose` — the Compose preview renders a
      --     runtime-chosen custom element, so no typed constructor can produce
      --     it; one documented `fromHtml` at the render boundary.
      NoUnsafeImportOutsideAllowed.rule
        [ "M3e"
        , "TypedHtml"
        , "Doc"
        , "Shared"
        , "View"
        , "Route.Examples.Shop"
        , "Route.Guide"
        , "Recast"
        , "Route.Components.Compose"
        ]

    -- The recast-containment fence for the reserved `Recast` destination
    -- module (see docstring). Same allow-list as the import fence above,
    -- minus `Recast` itself being redundant to list (a module is always
    -- allowed to reference its own functions unqualified; this only ever
    -- fires on a QUALIFIED `Recast.*` call from elsewhere).
    , NoSeamOutsideAllowedModules.rule
        { seamModules = [ "Recast" ]
        , allowedModules =
            [ "M3e"
            , "TypedHtml"
            , "Doc"
            , "Shared"
            , "View"
            , "Route.Examples.Shop"
            , "Route.Guide"
            , "Recast"
            ]
        }

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

    -- K5/#58 guard: a barrel must not co-expose `withX` pipes AND bare `x`
    -- setters for the same concept. Generated brand modules (M3e, TypedHtml,
    -- HtmlIr) are intentional source families and are allow-listed; any
    -- hand-written barrel that merges them accidentally is flagged.
    , NoMergedPipeAndSetter.rule { allowedModules = [ "M3e", "TypedHtml", "HtmlIr" ] }
    ]
