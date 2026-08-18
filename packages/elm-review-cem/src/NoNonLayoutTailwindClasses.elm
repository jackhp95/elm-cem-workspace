module NoNonLayoutTailwindClasses exposing (rule, TokenUtilityBridge)

{-|

@docs rule, TokenUtilityBridge

-}

import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node(..))
import Review.ModuleNameLookupTable as ModuleNameLookupTable exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)
import Set exposing (Set)


{-| Reports CSS classes that do more than LAYOUT.

The standing rule this encodes: **Tailwind is for layout only.** Positioning,
sizing, spacing, flex/grid and flow are a legitimate use of a utility class.
**Styling — colour, background, border, radius, elevation/shadow, typography —
must come from a design-system component**, never from a utility class. A page
that paints `bg-surface-container-high text-on-surface rounded-md-corner-large`
has reimplemented a component in Tailwind: it inherits none of that
component's state layers, motion, density or accessibility, and it silently
drifts from the theme the moment a token is renamed.

It also carries a project-proprietary-token charter: classes matching a
configured `proprietaryPrefixes` list (e.g. `ds-*` / `t-*`) are tokens that ship
**no CSS** anywhere, so applying one renders nothing. The compiler cannot see
either failure because `class : String -> Attr … msg` accepts any string.

The rule inspects string-literal arguments to `class` and `classList` resolved
through any of the configured `classModules`, plus any `…withClass` builder
setter, and classifies every space-separated token.

This rule is **namespace-agnostic**: it hardcodes no brand's module names,
class-name prefixes or utility manifest. A design system wires its own
`classModules`, `proprietaryPrefixes`, `tokenUtilities` (its generated
component-token utility bridge, if it has one — see `TokenUtilityBridge`) and
`allowedModules` (the seam fence, shared with `NoSeamOutsideAllowedModules`).
The layout-vs-styling taxonomy itself (which Tailwind utility families are
layout, which paint) is **not** brand-parameterized — Tailwind's own utility
classes are the same across any design system that uses them, so that part is
shared and universal.


## Classification

Each token is reduced to its base utility — variant prefixes (`md:`, `hover:`,
`[&>*]:`) and the `!`/`-` modifiers are stripped — and then sorted into one of
four buckets:

  - **Proprietary** — starts with a configured `proprietaryPrefixes` entry.
    Renders nothing. Reported.
  - **Dead token utility** — looks like a `tokenUtilities.prefix` component-token
    utility but is not a real, generated one. Renders nothing. Reported.
  - **Styling** — a Tailwind family that paints: `bg-`, `border-`, `rounded-`,
    `shadow-`, `ring-`, `outline-`, `divide-`, `fill-`, `stroke-`, `font-`,
    `leading-`, `tracking-`, `list-`, the filter/blend families, the gradient
    stops, the typographic keywords (`uppercase`, `italic`, `underline`, …), and
    any `text-` that is not alignment/wrapping. Reported.
  - **Allowed** — true layout utilities (`flex`, `grid-cols-2`, `gap-4`, `w-full`,
    `p-4`, `inset-x-0`, `z-20`, `overflow-hidden`, …), the accessibility and
    interaction utilities (`sr-only`, `pointer-events-none`, `cursor-pointer`),
    the real `tokenUtilities` names (if configured — these set a component's
    **own** documented custom properties, styling _through_ the design system
    rather than around it), and any class that is not a Tailwind utility at all
    — a project semantic hook or a test selector.

Unknown tokens are **allowed** deliberately. Tailwind's painting surface is
enumerable, a project's semantic hooks are not, so denying by styling family
catches the regressions that matter without flagging every new test hook.


## The seam: where a genuine escape is allowed to live

Steps that fix a violation are a project concern (see `guidance` below); this
rule additionally supports the honest case — a real design-system gap someone
has to work around **today**. Inside a designated module (`allowedModules`),
this rule does not fire. That module is the **seam** — the same destination
`NoSeamOutsideAllowedModules` gates, so every design-system escape in a project
lands in one reviewable place regardless of whether it crossed a KIND (a
recast) or painted a SURFACE (a styling class).

Passing `[]` makes the rule unconditional — correct for a codebase that has no
seam module yet.


## Known limit

The rule reads literals, not values. It descends through `++`, parentheses, and
`if`/`case` branches to find every literal in a class argument, so
`class (base ++ " bg-surface")` is caught. But a class assembled entirely out of
non-literals — a `let`-bound `String`, or a helper like
`class (densityClass model.density)` — is invisible, because knowing what those
hold needs dataflow analysis this rule does not attempt.


## Fail

    Html.div [ Attr.class "bg-surface-container-high rounded-lg" ] []

    TA.div [ TA.class "text-body-lg text-on-surface-variant" ] []

    Attr.class "ds-card-media"


## Success

    Html.div [ Attr.class "flex items-center gap-2" ] []

    TA.div [ TA.class "grid grid-cols-2 p-4 overflow-hidden" ] []

    M3e.card [ MA.class "m3e-card-padding-[0.625rem]" ] []


## Configuring

    config =
        [ NoNonLayoutTailwindClasses.rule
            { classModules =
                [ [ "Html", "Attributes" ]
                , [ "TypedHtml", "Attributes" ]
                , [ "M3e", "Attributes" ]
                , [ "Svg", "Attributes" ]
                ]
            , proprietaryPrefixes = [ "ds-", "t-" ]
            , tokenUtilities =
                Just
                    { prefix = "m3e-"
                    , names = M3eUtilityNames.names
                    }
            , allowedModules = [ "Seam" ]
            , guidance =
                { proprietary = [ "Use a typed design-system slot/role binding, or a real utility class, instead." ]
                , styling = [ "Reach for the component that already owns this surface instead of repainting it." ]
                , deadUtility = [ "Regenerate the manifest and try again; if the utility SHOULD exist, that's a component gap to file, not a class to invent." ]
                }
            }
        ]

@docs rule, TokenUtilityBridge

-}
rule :
    { classModules : List (List String)
    , proprietaryPrefixes : List String
    , tokenUtilities : Maybe TokenUtilityBridge
    , allowedModules : List String
    , guidance :
        { proprietary : List String
        , styling : List String
        , deadUtility : List String
        }
    }
    -> Rule
rule config =
    Rule.newModuleRuleSchemaUsingContextCreator "NoNonLayoutTailwindClasses" (initialContext config)
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


{-| A design system's generated component-token utility bridge — one Tailwind
utility per public custom property a component exposes (e.g.
`@utility m3e-card-padding-*`). Setting one of these is styling _through_ the
design system rather than around it, so it is the sanctioned bridge and is
allowed. `names` carries no trailing `-*`: `@utility m3e-card-padding-*`
appears as `"m3e-card-padding"`. A class matches a name when it equals the name
or starts with the name plus `-`, which is what Tailwind's `-*` suffix means.

Pass `Nothing` for a design system (or a plain-HTML consumer) with no such
generated bridge — the dead-utility bucket and the bridge allowance are both
skipped entirely, and any class starting with `prefix` would have nowhere to
be checked against anyway.

-}
type alias TokenUtilityBridge =
    { prefix : String
    , names : List String
    }


type alias Guidance =
    { proprietary : List String
    , styling : List String
    , deadUtility : List String
    }


type alias Config =
    { classModules : List (List String)
    , proprietaryPrefixes : List String
    , tokenUtilities : Maybe TokenUtilityBridge
    , allowedModules : List String
    , guidance : Guidance
    }


{-| The membership half of `TokenUtilityBridge.names` precomputed once as a
`Set`, at `rule` construction, so a module with a real generated manifest (a
brand's might carry thousands of names) pays the `List -> Set` conversion once
per review run rather than once per class-string literal visited.
-}
type alias ResolvedTokenUtilities =
    { prefix : String
    , names : List String
    , nameSet : Set String
    }


type alias Resolved =
    { classModules : List (List String)
    , proprietaryPrefixes : List String
    , tokenUtilities : Maybe ResolvedTokenUtilities
    , guidance : Guidance
    }


resolve : Config -> Resolved
resolve config =
    { classModules = config.classModules
    , proprietaryPrefixes = config.proprietaryPrefixes
    , tokenUtilities =
        Maybe.map
            (\bridge ->
                { prefix = bridge.prefix
                , names = bridge.names
                , nameSet = Set.fromList bridge.names
                }
            )
            config.tokenUtilities
    , guidance = config.guidance
    }


type alias Context =
    { lookupTable : ModuleNameLookupTable
    , gated : Bool
    , config : Resolved
    }


initialContext : Config -> Rule.ContextCreator () Context
initialContext config =
    let
        resolved : Resolved
        resolved =
            resolve config
    in
    Rule.initContextCreator
        (\lookupTable moduleName () ->
            { lookupTable = lookupTable
            , gated = not (isAllowedModule config.allowedModules (String.join "." moduleName))
            , config = resolved
            }
        )
        |> Rule.withModuleNameLookupTable
        |> Rule.withModuleName


{-| A module is allowed when its name equals, or is nested under (at a dot
boundary), one of the allow-list prefixes — so `"Seam"` covers `Seam` and
`Seam.Surface`. Same matching as `NoSeamOutsideAllowedModules.isAllowed`, on
purpose: the two fences share a destination and should agree on what "inside it"
means.
-}
isAllowedModule : List String -> String -> Bool
isAllowedModule allowed currentModule =
    List.any
        (\prefix -> currentModule == prefix || String.startsWith (prefix ++ ".") currentModule)
        allowed


expressionVisitor : Node Expression -> Context -> ( List (Error {}), Context )
expressionVisitor node context =
    if not context.gated then
        -- Inside the designated seam. A styling class here is the CONTAINED,
        -- reviewable form this rule exists to push people toward, so it is not an
        -- error. The proprietary check is skipped too: those render nothing at
        -- all, but a seam module is exactly where a deliberate dead-class
        -- workaround would be parked and justified.
        ( [], context )

    else
        case Node.value node of
            Expression.Application (fn :: arg :: []) ->
                ( checkClassCall context fn arg, context )

            _ ->
                ( [], context )


checkClassCall : Context -> Node Expression -> Node Expression -> List (Error {})
checkClassCall context fn arg =
    case fn of
        Node _ (Expression.FunctionOrValue _ name) ->
            if isClassLike context fn name then
                checkClassArgument context.config arg

            else if name == "classList" && resolvesToClassModule context fn then
                checkClassList context.config arg

            else
                []

        _ ->
            []


{-| `class` from any of the configured class-bearing attribute modules, or any
builder setter named `withClass` (the phantom-typed builder pipeline's setter
convention — see `Cem.TranslateToBuild`).
-}
isClassLike : Context -> Node Expression -> String -> Bool
isClassLike context fn name =
    (name == "class" && resolvesToClassModule context fn)
        || (name == "withClass")


resolvesToClassModule : Context -> Node Expression -> Bool
resolvesToClassModule context fn =
    case ModuleNameLookupTable.moduleNameFor context.lookupTable fn of
        Just moduleName ->
            List.member moduleName context.config.classModules

        Nothing ->
            False


{-| A class argument is rarely just a literal. Real call sites concatenate a
computed part onto a fixed part (`class (bodyCls ++ " text-on-surface-variant")`)
or pick between literals in a branch, and checking only `Expression.Literal`
misses every one of those — a painting class hidden behind a `++` would be
silently unenforced. So descend through the shapes that still contain a
checkable literal.

The computed halves (a `let`-bound `String`, a function call like
`densityClass model.theme.density`) remain invisible: knowing what they hold
needs dataflow analysis this rule does not do. That is a documented limit, not
an oversight — see the module docs.

-}
checkClassArgument : Resolved -> Node Expression -> List (Error {})
checkClassArgument config node =
    case Node.value node of
        Expression.Literal str ->
            errorsForClassString config node str

        Expression.ParenthesizedExpression inner ->
            checkClassArgument config inner

        Expression.OperatorApplication "++" _ left right ->
            checkClassArgument config left ++ checkClassArgument config right

        Expression.IfBlock _ onTrue onFalse ->
            checkClassArgument config onTrue ++ checkClassArgument config onFalse

        Expression.CaseExpression { cases } ->
            List.concatMap (\( _, body ) -> checkClassArgument config body) cases

        _ ->
            []


{-| `classList [ ( "ds-active", cond ), … ]` — check each tuple's first element.
-}
checkClassList : Resolved -> Node Expression -> List (Error {})
checkClassList config node =
    case Node.value node of
        Expression.ListExpr entries ->
            List.concatMap (checkClassListEntry config) entries

        _ ->
            []


checkClassListEntry : Resolved -> Node Expression -> List (Error {})
checkClassListEntry config node =
    case Node.value node of
        Expression.TupledExpression (keyNode :: _) ->
            checkClassArgument config keyNode

        _ ->
            []



-- REPORTING -------------------------------------------------------------------


{-| At most one error per category per literal, each naming the exact tokens at
fault so the fix is mechanical from the report alone.
-}
errorsForClassString : Resolved -> Node Expression -> String -> List (Error {})
errorsForClassString config node str =
    let
        tokens : List String
        tokens =
            String.words str

        classified : List ( String, Classification )
        classified =
            List.map (\token -> ( token, classify config token )) tokens

        forBucket : Classification -> List String
        forBucket bucket =
            List.filterMap
                (\( token, c ) ->
                    if c == bucket then
                        Just token

                    else
                        Nothing
                )
                classified
    in
    List.filterMap identity
        [ case forBucket Proprietary of
            [] ->
                Nothing

            tokens_ ->
                Just (proprietaryError config node tokens_)
        , case forBucket DeadTokenUtility of
            [] ->
                Nothing

            tokens_ ->
                Just (deadUtilityError config node tokens_)
        , case forBucket Styling of
            [] ->
                Nothing

            tokens_ ->
                Just (stylingError config node tokens_)
        ]


proprietaryError : Resolved -> Node Expression -> List String -> Error {}
proprietaryError config node tokens =
    Rule.error
        { message = "Proprietary CSS class — ships no CSS"
        , details =
            [ formattedProprietaryPrefixes config.proprietaryPrefixes
                ++ " classes are project-proprietary tokens that are not part of this design system and ship no CSS, so they render nothing."
            , "Offending: " ++ String.join ", " tokens
            ]
                ++ config.guidance.proprietary
        }
        (Node.range node)


formattedProprietaryPrefixes : List String -> String
formattedProprietaryPrefixes prefixes =
    prefixes
        |> List.map (\p -> "`" ++ p ++ "*`")
        |> String.join " / "


deadUtilityError : Resolved -> Node Expression -> List String -> Error {}
deadUtilityError config node tokens =
    let
        prefixLabel : String
        prefixLabel =
            case config.tokenUtilities of
                Just bridge ->
                    "`" ++ bridge.prefix ++ "*`"

                Nothing ->
                    "component-token"
    in
    Rule.error
        { message = "Unknown " ++ prefixLabel ++ " utility — ships no CSS"
        , details =
            [ "This class is spelled like one of the generated " ++ prefixLabel ++ " component-token utilities, but it is not one of them, so it ships no CSS and renders nothing."
            , "Offending: " ++ String.join ", " tokens
            ]
                ++ config.guidance.deadUtility
        }
        (Node.range node)


stylingError : Resolved -> Node Expression -> List String -> Error {}
stylingError config node tokens =
    Rule.error
        { message = "Non-layout CSS class — styling must come from a design-system component"
        , details =
            [ "Tailwind is for LAYOUT only. Colour, background, border, radius, elevation/shadow and typography must come from a design-system component, not a utility class."
            , "Offending: " ++ String.join ", " tokens
            ]
                ++ config.guidance.styling
                ++ tokenUtilityClosingLine config.tokenUtilities
        }
        (Node.range node)


tokenUtilityClosingLine : Maybe ResolvedTokenUtilities -> List String
tokenUtilityClosingLine tokenUtilities =
    case tokenUtilities of
        Just bridge ->
            [ "Layout utilities (`flex`, `grid-cols-2`, `gap-4`, `w-full`, `p-4`, `z-20`, …) stay. So do the generated `" ++ bridge.prefix ++ "*` token utilities, which set a component's own documented custom properties." ]

        Nothing ->
            [ "Layout utilities (`flex`, `grid-cols-2`, `gap-4`, `w-full`, `p-4`, `z-20`, …) stay." ]



-- CLASSIFICATION --------------------------------------------------------------


type Classification
    = Proprietary
    | DeadTokenUtility
    | Styling
    | Allowed


classify : Resolved -> String -> Classification
classify config token =
    let
        base : String
        base =
            token |> utilityPart |> stripModifiers
    in
    if base == "" then
        Allowed

    else if isProprietary config.proprietaryPrefixes base then
        Proprietary

    else if isTokenUtility config.tokenUtilities base then
        Allowed

    else if tokenPrefixMatches config.tokenUtilities base then
        -- Claims to be a component-token utility but is not one. Falling through
        -- to the unknown-token default would ALLOW it, which is how a prefix
        -- guess used to behave; it ships no CSS and renders nothing, so it
        -- belongs with the proprietary dead classes rather than in the
        -- permissive tail.
        DeadTokenUtility

    else if String.startsWith "[" base then
        classifyArbitraryProperty config.tokenUtilities base

    else if isShadowedStyling base then
        Styling

    else if isLayout base then
        Allowed

    else if isStyling base then
        Styling

    else
        Allowed


{-| Keep the final `:`-separated segment — the utility itself, with every variant
prefix (`md:`, `hover:`, `group-hover:`, `[&>*]:`, `[:not([selected])]:`) gone.

Depth tracking is load-bearing: an arbitrary value legitimately contains a colon
(`[--m3e-nav-rail-icon-button-inset:auto]`, `bg-[url(https://x)]`), and splitting
naively on every `:` would shred it into a meaningless tail.

-}
utilityPart : String -> String
utilityPart token =
    token
        |> String.foldl
            (\char ( depth, current ) ->
                case char of
                    '[' ->
                        ( depth + 1, current ++ String.fromChar char )

                    '(' ->
                        ( depth + 1, current ++ String.fromChar char )

                    ']' ->
                        ( depth - 1, current ++ String.fromChar char )

                    ')' ->
                        ( depth - 1, current ++ String.fromChar char )

                    ':' ->
                        if depth == 0 then
                            ( depth, "" )

                        else
                            ( depth, current ++ String.fromChar char )

                    _ ->
                        ( depth, current ++ String.fromChar char )
            )
            ( 0, "" )
        |> Tuple.second


{-| Drop the `!` important marker and the leading `-` of a negative utility
(`-mx-4` is the same family as `mx-4`).
-}
stripModifiers : String -> String
stripModifiers utility =
    utility
        |> dropPrefix "!"
        |> dropPrefix "-"


dropPrefix : String -> String -> String
dropPrefix prefix str =
    if String.startsWith prefix str then
        String.dropLeft (String.length prefix) str

    else
        str


isProprietary : List String -> String -> Bool
isProprietary prefixes base =
    List.any (\prefix -> String.startsWith prefix base) prefixes


{-| Membership is checked against the REAL generated list (`bridge.names`), not
against the prefix alone. A prefix-only guess lets a typo like
`m3e-crd-padding-4` slip through: it is not a utility, ships no CSS, and renders
nothing — indistinguishable at the call site from a proprietary dead class.

A token matches when it equals a name or starts with that name plus `-`, which is
what Tailwind's `-*` suffix means: `@utility m3e-card-padding-*` admits
`m3e-card-padding-[0.625rem]` and `m3e-card-padding-4`.

-}
isTokenUtility : Maybe ResolvedTokenUtilities -> String -> Bool
isTokenUtility tokenUtilities base =
    case tokenUtilities of
        Nothing ->
            False

        Just bridge ->
            if not (String.startsWith bridge.prefix base) then
                False

            else
                Set.member base bridge.nameSet
                    || List.any (\name -> String.startsWith (name ++ "-") base) bridge.names


tokenPrefixMatches : Maybe ResolvedTokenUtilities -> String -> Bool
tokenPrefixMatches tokenUtilities base =
    case tokenUtilities of
        Nothing ->
            False

        Just bridge ->
            String.startsWith bridge.prefix base


{-| A bare arbitrary property (`[--m3e-inset:auto]`, `[color:red]`). Setting a
configured token-utility bridge's custom property is the sanctioned bridge;
setting any other raw CSS property from a class is exactly the hand-painting
this rule exists to stop.
-}
classifyArbitraryProperty : Maybe ResolvedTokenUtilities -> String -> Classification
classifyArbitraryProperty tokenUtilities base =
    case tokenUtilities of
        Just bridge ->
            if String.startsWith ("[--" ++ bridge.prefix) base then
                Allowed

            else
                Styling

        Nothing ->
            Styling


{-| Styling families whose names begin with a LAYOUT prefix, so `isLayout` would
otherwise swallow them: `inset-shadow-lg` and `inset-ring-2` are elevation, not
the `inset-` positioning family. Checked ahead of `isLayout` for that reason.
-}
isShadowedStyling : String -> Bool
isShadowedStyling base =
    List.any (\prefix -> String.startsWith prefix base)
        [ "inset-shadow-"
        , "inset-ring-"
        ]


isLayout : String -> Bool
isLayout base =
    List.member base layoutKeywords
        || List.any (\prefix -> String.startsWith prefix base) layoutPrefixes


isStyling : String -> Bool
isStyling base =
    List.member base stylingKeywords
        || List.any (\prefix -> String.startsWith prefix base) stylingPrefixes


{-| Single-word layout utilities: display, position, and the accessibility pair.
-}
layoutKeywords : List String
layoutKeywords =
    [ "flex"
    , "grid"
    , "contents"
    , "block"
    , "inline"
    , "inline-block"
    , "inline-flex"
    , "inline-grid"
    , "inline-table"
    , "table"
    , "flow-root"
    , "list-item"
    , "hidden"
    , "static"
    , "fixed"
    , "absolute"
    , "relative"
    , "sticky"
    , "isolate"
    , "isolation-auto"
    , "visible"
    , "invisible"
    , "collapse"
    , "sr-only"
    , "not-sr-only"
    , "truncate"
    , "container"
    , "transform-none"
    , "antialiased-none"
    ]


{-| Layout utility families, matched as `prefix-`. Ordering is irrelevant because
`isStyling` is only consulted after this returns `False`, and the two lists are
disjoint by construction — the one genuine overlap, `text-`, is resolved by
listing the alignment/wrapping members explicitly here.
-}
layoutPrefixes : List String
layoutPrefixes =
    [ -- flex + grid
      "flex-"
    , "grid-"
    , "col-"
    , "row-"
    , "auto-cols-"
    , "auto-rows-"
    , "gap-"
    , "space-"
    , "items-"
    , "justify-"
    , "place-"
    , "content-"
    , "self-"
    , "order-"
    , "basis-"
    , "grow-"
    , "shrink-"
    , "columns-"

    -- sizing
    , "w-"
    , "h-"
    , "size-"
    , "min-w-"
    , "max-w-"
    , "min-h-"
    , "max-h-"
    , "aspect-"

    -- padding
    , "p-"
    , "px-"
    , "py-"
    , "pt-"
    , "pr-"
    , "pb-"
    , "pl-"
    , "ps-"
    , "pe-"

    -- margin
    , "m-"
    , "mx-"
    , "my-"
    , "mt-"
    , "mr-"
    , "mb-"
    , "ml-"
    , "ms-"
    , "me-"

    -- position + stacking
    , "inset-x-"
    , "inset-y-"
    , "inset-"
    , "top-"
    , "right-"
    , "bottom-"
    , "left-"
    , "start-"
    , "end-"
    , "z-"
    , "float-"
    , "clear-"

    -- flow + overflow
    , "overflow-"
    , "overscroll-"
    , "object-"
    , "box-"
    , "break-"
    , "whitespace-"
    , "hyphens-"
    , "wrap-"

    -- text alignment and wrapping: layout concerns that happen to live under
    -- the `text-` prefix. Every other `text-*` is colour or type scale.
    , "text-left"
    , "text-center"
    , "text-right"
    , "text-justify"
    , "text-start"
    , "text-end"
    , "text-wrap"
    , "text-nowrap"
    , "text-balance"
    , "text-pretty"
    , "text-ellipsis"
    , "text-clip"

    -- transform + motion
    , "translate-"
    , "rotate-"
    , "scale-"
    , "skew-"
    , "transform-"
    , "origin-"
    , "perspective-"
    , "transition"
    , "duration-"
    , "delay-"
    , "ease-"
    , "animate-"
    , "will-change-"

    -- interaction, scrolling, accessibility. Not paint: none of these carry a
    -- colour, a type scale, a border or an elevation.
    , "snap-"
    , "scroll-"
    , "touch-"
    , "select-"
    , "resize-"
    , "cursor-"
    , "pointer-events-"
    , "appearance-"
    , "opacity-"
    , "contain-"
    , "@container"
    ]


{-| Typographic and decorative single-word utilities.
-}
stylingKeywords : List String
stylingKeywords =
    [ "italic"
    , "not-italic"
    , "uppercase"
    , "lowercase"
    , "capitalize"
    , "normal-case"
    , "underline"
    , "overline"
    , "line-through"
    , "no-underline"
    , "antialiased"
    , "subpixel-antialiased"
    , "ordinal"
    , "slashed-zero"
    , "lining-nums"
    , "oldstyle-nums"
    , "proportional-nums"
    , "tabular-nums"
    , "diagonal-fractions"
    , "stacked-fractions"
    , "normal-nums"
    , "border"
    , "rounded"
    , "shadow"
    , "ring"
    , "outline"
    , "grayscale"
    , "invert"
    , "sepia"
    , "backdrop-grayscale"
    , "backdrop-invert"
    , "backdrop-sepia"
    ]


{-| The painting families. Every one of these sets a colour, a background, a
border, a radius, an elevation, a filter or a type scale.
-}
stylingPrefixes : List String
stylingPrefixes =
    [ -- background + gradients
      "bg-"
    , "from-"
    , "via-"
    , "to-"

    -- borders, outlines, rings, dividers
    , "border-"
    , "divide-"
    , "outline-"
    , "ring-"
    , "rounded-"

    -- elevation
    , "shadow-"
    , "drop-shadow-"
    , "inset-shadow-"
    , "inset-ring-"
    , "text-shadow-"
    , "elevation-"

    -- typography
    , "font-"
    , "leading-"
    , "tracking-"
    , "decoration-"
    , "indent-"
    , "list-"
    , "align-"

    -- colour on non-text surfaces
    , "text-"
    , "fill-"
    , "stroke-"
    , "accent-"
    , "caret-"
    , "placeholder-"

    -- filters + blend
    , "blur-"
    , "brightness-"
    , "contrast-"
    , "saturate-"
    , "hue-rotate-"
    , "backdrop-"
    , "mix-blend-"
    , "bg-blend-"
    ]
