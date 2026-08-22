module Cem.ValidComposition exposing
    ( Config, Severity(..), defaultConfig
    , rule, ruleWith
    )

{-| Codegen-aware, **relational** composition rule — the ancestor/descendant
complement to `Cem.ValidSlotKind`'s direct-slot membership check.

`ValidSlotKind` checks that a child in a parent's content list is a kind the
parent's slot admits (a flat, DIRECT allow-list). Three a11y/content-model
constraints cannot be expressed that way, because they are about the whole
descendant sub-tree, not the immediate child list:

  - **(a) interactive-content-descendant, arbitrary depth** (WHATWG). A
    `button`'s content model is "Phrasing content, but there must be no
    interactive content **descendant**." `button [] [ span [] [ a [] [] ] ]`
    passes every direct-slot check (an `a` is legal in a `span`, a `span` is
    legal in a `button`) yet is a spec violation. The DIRECT case is already a
    compile error (Task 3's `!@interactive` on `button`/`a`/`label`/`summary`);
    this catches the arbitrary-depth case the phantom types can't. **HARD.**

  - **(b) `label` single-labeled-control + no-nested-label** (WHATWG). A
    `label`'s content model is "Phrasing content, but with no descendant
    labelable elements unless it is the element's labeled control, and no
    descendant `label` elements." So at most ONE labelable descendant, and never
    a nested `label`. **HARD.**

  - **(c) ARIA required-context** (WAI-ARIA). A child with a required-context
    role needs an ancestor of the required container role — a `tab` needs a
    `tablist` ancestor, a `menuitem` needs a `menu`/`menubar` ancestor. Often a
    real bug, sometimes intentional composition (the child is owned via
    `aria-owns` from elsewhere). **WARN.**

  - **(d) SVG-AAM no-role-on-non-rendered-element** (SVG Accessibility API
    Mappings). A `role`/`aria-roledescription` **attribute** on a non-rendered
    svg element (`defs`, `clipPath`, `mask`, `pattern`, `filter`, `animate*`,
    `set`) is invalid — "no role may be applied." An accessibility-API-mapping
    concern, not a content-model violation. **WARN.**

The rule is brand-agnostic: it resolves component calls and their kinds through
the generated `Cem.Facts` (exactly as `ValidSlotKind` does), and consults a
`Config` for the relational tables the facts don't carry (which nouns are
interactive, which roles need which ancestor, …). `defaultConfig` ships the
WHATWG universal tables keyed by the standard element nouns (`button`, `a`,
`label`, `input`, …) that are identical across every brand that models real HTML
elements. A brand with its own component vocabulary (shoelace) extends it.

@docs Config, Severity, defaultConfig
@docs rule, ruleWith

-}

import Cem.Facts exposing (Facet(..), Fact)
import Cem.Internal.Facts as Facts
import Dict exposing (Dict)
import Elm.Syntax.Declaration as Declaration
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range exposing (Range)
import Review.ModuleNameLookupTable exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)
import Set exposing (Set)


{-| Per-constraint-family severity.

elm-review has no native warn-vs-error split — every `Rule.error` fails
`elm-review`. This rule mirrors `ValidSlotKind`'s posture convention: a `Hard`
family emits a plain error (fails the gate); a `Warn` family emits an error
whose message is prefixed `warning:` and whose details mark it advisory, so a
brand gate can surface it without necessarily failing on the intentional-
composition cases. The distinction is real and load-bearing — the WHATWG
content-model violations (interactive / label) are `Hard`, the ARIA relational
and SVG-AAM overlay ones are `Warn` (Jack's resolved OQ-2).

-}
type Severity
    = Hard
    | Warn


{-| The relational constraint tables the facts don't carry, plus the per-family
posture. `defaultConfig` fills these from the provenance-stamped a11y foundation
(`docs/a11y-foundation/composition-rules.json`).

  - `interactiveKinds` — component nouns that ARE interactive content (§2.2 of
    the foundation). A descendant of a `button`/`a`/`label`/`summary` whose noun
    is in this set is an interactive-content-descendant violation.
  - `interactiveParents` — nouns whose content model forbids an interactive
    descendant (`button`, `a`, `label`, `summary`).
  - `noSelfDescendant` — parent nouns that additionally forbid a same-noun
    descendant (`a` forbids a descendant `a`; `form` forbids a descendant
    `form`).
  - `labelKinds` — nouns whose content model is the `label` single-labeled-
    control rule.
  - `labelableKinds` — nouns that are labelable form controls (the things a
    `label` may contain at most one of).
  - `requiredContext` — child noun → the ancestor container nouns, one of which
    must be an ancestor.
  - `svgNonRendered` — svg element nouns that may carry no role/aria-role.
  - `roleAttrSetters` — attribute-setter names that assign a role or
    `aria-roledescription` (barrel + per-component forms), used by the SVG-AAM
    overlay.
  - `posture` — the per-family `Hard`/`Warn` split.

-}
type alias Config =
    { interactiveKinds : Set String
    , interactiveParents : Set String
    , noSelfDescendant : Set String
    , labelKinds : Set String
    , labelableKinds : Set String
    , requiredContext : Dict String (List String)
    , svgNonRendered : Set String
    , roleAttrSetters : Set String
    , posture :
        { interactive : Severity
        , label : Severity
        , requiredContext : Severity
        , svgAam : Severity
        }
    }


{-| The WHATWG + WAI-ARIA + SVG-AAM tables from the shared foundation, keyed by
the standard element nouns, with Jack's resolved OQ-2 posture (interactive/label
HARD, required-context/svg-aam WARN).

Sources (see `docs/a11y-foundation/composition-rules.json` for the
provenance-stamped originals):

  - interactive set + button/a/label/summary content models — WHATWG HTML
    Standard.
  - required-context table — WAI-ARIA 1.2 Required Context Role.
  - svg non-rendered set + role-attr overlay — SVG Accessibility API Mappings.

-}
defaultConfig : Config
defaultConfig =
    { interactiveKinds =
        Set.fromList
            [ "a", "audio", "button", "details", "embed", "iframe", "img", "input", "label", "select", "textarea", "video" ]
    , interactiveParents =
        -- `label` is deliberately NOT here: its content model is the special
        -- single-labeled-control rule (handled by the `label` family), NOT a
        -- blanket "no interactive descendant" — a `label` is MEANT to wrap one
        -- interactive labelable control.
        Set.fromList [ "button", "a", "summary" ]
    , noSelfDescendant =
        Set.fromList [ "a", "form" ]
    , labelKinds =
        Set.singleton "label"
    , labelableKinds =
        -- WHATWG "labelable elements": button, input, meter, output, progress,
        -- select, textarea (and form-associated custom elements).
        Set.fromList [ "button", "input", "meter", "output", "progress", "select", "textarea" ]
    , requiredContext =
        -- KEYS + CONTAINER NAMES are camelCase COMPONENT NOUNS (the identifiers
        -- that appear as `component = "…"` in the generated facts), NOT the
        -- lowercase ARIA role names — the facts speak nouns, so the table must
        -- too. Each entry lists BOTH the ARIA-role-shaped noun and the concrete
        -- element/component nouns a brand may realise it as, so html tag nouns
        -- (`select`, `ul`, `tr`, `tbody`) and shoelace ctor nouns (`tabGroup`,
        -- `radioGroup`) both satisfy the requirement.
        Dict.fromList
            [ ( "option", [ "listbox", "group", "select", "optgroup", "datalist" ] )
            , ( "menuItem", [ "menu", "menubar", "menuBar", "group" ] )
            , ( "menuItemCheckbox", [ "menu", "menubar", "menuBar", "group" ] )
            , ( "menuItemRadio", [ "menu", "menubar", "menuBar", "group" ] )
            , ( "tab", [ "tablist", "tabList", "tabGroup" ] )
            , ( "treeItem", [ "tree", "group" ] )
            , ( "row", [ "grid", "rowgroup", "rowGroup", "table", "treegrid", "treeGrid", "tbody", "thead", "tfoot" ] )
            , ( "gridcell", [ "row", "tr" ] )
            , ( "gridCell", [ "row", "tr" ] )
            , ( "columnheader", [ "row", "tr" ] )
            , ( "columnHeader", [ "row", "tr" ] )
            , ( "rowheader", [ "row", "tr" ] )
            , ( "rowHeader", [ "row", "tr" ] )
            , ( "radio", [ "radiogroup", "radioGroup" ] )
            , ( "listItem", [ "list", "group", "ul", "ol" ] )
            ]
    , svgNonRendered =
        Set.fromList
            [ "animate", "animateMotion", "animateTransform", "clipPath", "defs", "filter", "mask", "pattern", "set", "discard" ]
    , roleAttrSetters =
        Set.fromList [ "role", "attrRole", "ariaRoledescription", "attrAriaRoledescription" ]
    , posture =
        { interactive = Hard
        , label = Hard
        , requiredContext = Warn
        , svgAam = Warn
        }
    }


{-| Build from the generated facts with the default (WHATWG/ARIA/SVG-AAM) config.
-}
rule : List Fact -> Rule
rule =
    ruleWith defaultConfig


{-| Build from the generated facts with an explicit `Config` (a brand extends
`defaultConfig` with its own interactive nouns / required-context role-map).
-}
ruleWith : Config -> List Fact -> Rule
ruleWith config facts =
    Rule.newModuleRuleSchemaUsingContextCreator "ValidComposition" (initContext config facts)
        |> Rule.withDeclarationEnterVisitor declarationEnterVisitor
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


type alias Context =
    { lookup : ModuleNameLookupTable
    , factsIndex : Dict String Fact
    , namespaces : List (List String)
    , scope : Dict String (Node Expression)
    , config : Config

    -- Ranges of required-context child calls that a satisfying container
    -- ancestor has already cleared. Populated when a container root is visited
    -- (pre-order, so the container is always seen before its descendant child
    -- calls) and consulted when each child call is later visited as its own
    -- root, so a properly-contained child is never double-reported.
    , clearedByContainer : Set ( ( Int, Int ), ( Int, Int ) )
    }


initContext : Config -> List Fact -> Rule.ContextCreator () Context
initContext config facts =
    Rule.initContextCreator
        (\lookup () ->
            { lookup = lookup
            , factsIndex = Facts.buildIndex facts
            , namespaces = Facts.namespaces facts
            , scope = Dict.empty
            , config = config
            , clearedByContainer = Set.empty
            }
        )
        |> Rule.withModuleNameLookupTable


declarationEnterVisitor : Node Declaration.Declaration -> Context -> ( List (Error {}), Context )
declarationEnterVisitor node context =
    case Facts.collectLetScope node of
        Just scope ->
            ( [], { context | scope = scope } )

        Nothing ->
            ( [], context )


rangeKey : Range -> ( ( Int, Int ), ( Int, Int ) )
rangeKey r =
    ( ( r.start.row, r.start.column ), ( r.end.row, r.end.column ) )


{-| We root every check at a fully-applied component call. From that root we walk
the whole descendant sub-tree ONCE (through nested component calls and their
content lists), which is what makes the arbitrary-depth checks possible.

To avoid double-reporting the same violation from every enclosing call on the
way down, each family reports only against the OUTERMOST relevant root:

  - interactive-descendant + label: reported when the ROOT is an
    interactive-parent / label. A nested interactive parent inside another is
    itself a direct-child violation caught by the phantom types, so we don't
    also re-walk from it here.
  - required-context: reported when the root is the required child-role noun AND
    no required ancestor is found among the syntactic ancestors of that call.
    Because elm-review's enter-visitor sees nodes top-down, we compute the
    ancestor set by walking DOWN from every call and checking each descendant
    child-role noun against the ancestors accumulated on the way — done in one
    traversal rooted at each call, guarded so only the outermost traversal
    reports (a child-role call nested under a container is cleared by that
    container; a bare top-level child-role call is flagged).

-}
expressionVisitor : Node Expression -> Context -> ( List (Error {}), Context )
expressionVisitor node context =
    case componentCallNoun context node of
        Just ( noun, contentNode ) ->
            let
                ( rcErrors, newlyCleared ) =
                    requiredContextCheck context noun node contentNode

                errors =
                    interactiveAndLabelErrors context noun contentNode
                        ++ rcErrors
                        ++ svgAamCheck context noun node
            in
            ( errors
            , { context | clearedByContainer = Set.union context.clearedByContainer newlyCleared }
            )

        Nothing ->
            ( [], context )


{-| If `node` is a fully-applied component constructor call, return its resolved
component noun and its content-list argument node. This is the same call-site
resolution `ValidSlotKind` uses, restricted to the Standard/Record facets whose
last argument is the content list.
-}
componentCallNoun : Context -> Node Expression -> Maybe ( String, Node Expression )
componentCallNoun context node =
    case Node.value node of
        Expression.Application (fnNode :: args) ->
            case Facts.callSite context.namespaces context.lookup fnNode of
                Just site ->
                    case Facts.find site context.factsIndex of
                        Just _ ->
                            let
                                minArgs =
                                    case site.facet of
                                        Record ->
                                            3

                                        _ ->
                                            2
                            in
                            if List.length args >= minArgs then
                                case List.reverse args |> List.head of
                                    Just contentNode ->
                                        Just ( site.noun, contentNode )

                                    Nothing ->
                                        Nothing

                            else
                                Nothing

                        Nothing ->
                            Nothing

                Nothing ->
                    Nothing

        _ ->
            Nothing


{-| The kind (component noun) of an expression, when statically resolvable, plus
its content node. `Nothing` for helpers / unresolvable children.
-}
resolvedCall : Context -> Node Expression -> Maybe ( String, Node Expression )
resolvedCall context element =
    case Node.value element of
        Expression.ParenthesizedExpression inner ->
            resolvedCall context inner

        _ ->
            componentCallNoun context element


{-| The bare resolved noun of an element (for a `foo [] []` call OR a bare
`foo`), regardless of whether it carries a content list. Used to classify a
descendant child.
-}
resolvedNoun : Context -> Node Expression -> Maybe String
resolvedNoun context node =
    case Node.value node of
        Expression.ParenthesizedExpression inner ->
            resolvedNoun context inner

        Expression.Application (headNode :: _) ->
            Facts.callSite context.namespaces context.lookup headNode
                |> Maybe.andThen (\site -> Facts.find site context.factsIndex |> Maybe.map (\_ -> site.noun))

        Expression.FunctionOrValue _ _ ->
            Facts.callSite context.namespaces context.lookup node
                |> Maybe.andThen (\site -> Facts.find site context.factsIndex |> Maybe.map (\_ -> site.noun))

        _ ->
            Nothing


{-| All statically-known descendant component calls under a content node,
flattened (the whole sub-tree, arbitrary depth). Each entry is the descendant's
`(noun, node)`; the content list of each descendant is itself recursed into.
-}
descendantCalls : Context -> Node Expression -> List ( String, Node Expression )
descendantCalls context contentNode =
    Facts.tracedList context.lookup context.scope contentNode
        |> .known
        |> List.concatMap
            (\childNode ->
                let
                    -- Unwrap parentheses so the recorded node's RANGE matches the
                    -- inner `Application` node the child later visits as its own
                    -- root (elm-review visits the parens node and its inner
                    -- application separately; `componentCallNoun` fires on the
                    -- application). Range alignment is what makes the
                    -- `clearedByContainer` dedup correct.
                    inner =
                        unwrapParens childNode
                in
                case resolvedCall context inner of
                    Just ( noun, childContent ) ->
                        ( noun, inner ) :: descendantCalls context childContent

                    Nothing ->
                        -- A child that resolves to a noun but carries no content
                        -- list (bare `foo`), or an unresolvable helper. If it
                        -- resolves to a noun, still record it as a leaf
                        -- descendant so interactive/labelable leaves count.
                        case resolvedNoun context inner of
                            Just noun ->
                                [ ( noun, inner ) ]

                            Nothing ->
                                []
            )


unwrapParens : Node Expression -> Node Expression
unwrapParens node =
    case Node.value node of
        Expression.ParenthesizedExpression inner ->
            unwrapParens inner

        _ ->
            node


{-| The interactive-descendant and label constraint families, rooted at `noun`.
Both scan the whole descendant sub-tree, so they are checked only when the root
IS an interactive-parent / label — the arbitrary-depth cases the phantom types
can't catch.
-}
interactiveAndLabelErrors : Context -> String -> Node Expression -> List (Error {})
interactiveAndLabelErrors context noun contentNode =
    let
        config =
            context.config

        descendants =
            descendantCalls context contentNode

        interactiveErrors =
            if Set.member noun config.interactiveParents then
                descendants
                    |> List.filterMap
                        (\( d, dNode ) ->
                            if Set.member d config.interactiveKinds then
                                Just (interactiveDescendantError config noun d dNode)

                            else if Set.member noun config.noSelfDescendant && d == noun then
                                Just (selfDescendantError config noun dNode)

                            else
                                Nothing
                        )

            else
                []

        labelErrors =
            if Set.member noun config.labelKinds then
                let
                    nestedLabels =
                        descendants
                            |> List.filter (\( d, _ ) -> Set.member d config.labelKinds)

                    labelables =
                        descendants
                            |> List.filter (\( d, _ ) -> Set.member d config.labelableKinds)

                    nestedLabelErrs =
                        nestedLabels
                            |> List.map (\( _, dNode ) -> nestedLabelError config dNode)

                    -- At most ONE labelable descendant (the labeled control).
                    -- Every labelable beyond the first is a violation.
                    extraLabelableErrs =
                        case labelables of
                            _ :: extra ->
                                extra |> List.map (\( d, dNode ) -> extraLabelableError config d dNode)

                            [] ->
                                []
                in
                nestedLabelErrs ++ extraLabelableErrs

            else
                []
    in
    interactiveErrors ++ labelErrors


{-| Required-context (WARN): a child with a required-context role/noun needs an
ancestor of a required container role — a `tab` needs a `tablist`/`tabGroup`
ancestor, a `menuitem` a `menu`/`menubar` ancestor.

elm-review's enter-visitor gives no ancestor stack, so we exploit its PRE-ORDER
traversal instead. Two things happen at each call visit:

1.  **Clearing (when the root is a container):** if `noun` is listed as a
    required container for some child role, we walk this root's whole descendant
    sub-tree and record the RANGE of every required-context child it satisfies
    into `context.clearedByContainer`. Because a container is always visited
    before its descendants, this set is populated before any cleared child is
    visited as its own root.

2.  **Reporting (when the root is a child role):** if `noun` is itself a
    required-context child, we flag it UNLESS its own range is already in
    `clearedByContainer` (a proper container above it cleared it). A bare,
    uncontained child role therefore reports exactly once, from its own visit; a
    contained one never reports.

The two are computed in one pass here: this call's contribution is (a) the
clearing set it adds (returned so the visitor can union it into context) and (b)
the single self-report, if any. This is robust to arbitrary nesting depth and
never double-reports.

-}
requiredContextCheck : Context -> String -> Node Expression -> Node Expression -> ( List (Error {}), Set ( ( Int, Int ), ( Int, Int ) ) )
requiredContextCheck context noun rootNode contentNode =
    let
        config =
            context.config

        -- (1) Clearing: does this root satisfy any child role? If so, collect
        -- the ranges of the required-context descendants it clears.
        isContainerForSomeChild =
            config.requiredContext
                |> Dict.values
                |> List.any (List.member noun)

        cleared =
            if isContainerForSomeChild then
                descendantCalls context contentNode
                    |> List.filterMap
                        (\( d, dNode ) ->
                            case Dict.get d config.requiredContext of
                                Just requiredContainers ->
                                    if List.member noun requiredContainers then
                                        Just (rangeKey (Node.range dNode))

                                    else
                                        Nothing

                                Nothing ->
                                    Nothing
                        )
                    |> Set.fromList

            else
                Set.empty

        -- (2) Reporting: is THIS call an uncontained required-context child?
        selfError =
            case Dict.get noun config.requiredContext of
                Just _ ->
                    if Set.member (rangeKey (Node.range rootNode)) context.clearedByContainer then
                        []

                    else
                        [ requiredContextError config noun rootNode ]

                Nothing ->
                    []
    in
    ( selfError, cleared )


{-| SVG-AAM overlay: a `role`/`aria-roledescription` attribute setter in the
ATTRIBUTES list of a non-rendered svg element call is a violation. The attributes
list is the FIRST argument of the constructor (Standard/Html facet); we scan it
for a setter whose head name is in `config.roleAttrSetters`.
-}
svgAamCheck : Context -> String -> Node Expression -> List (Error {})
svgAamCheck context noun rootNode =
    if Set.member noun context.config.svgNonRendered then
        case Node.value rootNode of
            Expression.Application (_ :: attrsNode :: _) ->
                attrSetterHeads context attrsNode
                    |> List.filterMap
                        (\( setterName, setterNode ) ->
                            if Set.member setterName context.config.roleAttrSetters then
                                Just (svgAamError context.config noun setterName setterNode)

                            else
                                Nothing
                        )

            _ ->
                []

    else
        []


{-| The `(name, node)` of every attribute setter in an attributes-list argument
that we can statically see (`[ Attr.role "x", … ]`). Resolves both barrel
(`Svg.role`) and per-component/module (`Attributes.role`) forms by their bare
value name.
-}
attrSetterHeads : Context -> Node Expression -> List ( String, Node Expression )
attrSetterHeads context attrsNode =
    Facts.tracedList context.lookup context.scope attrsNode
        |> .known
        |> List.filterMap
            (\attrNode ->
                case Node.value attrNode of
                    Expression.Application (headNode :: _) ->
                        case Node.value headNode of
                            Expression.FunctionOrValue _ name ->
                                Just ( name, attrNode )

                            _ ->
                                Nothing

                    Expression.FunctionOrValue _ name ->
                        Just ( name, attrNode )

                    _ ->
                        Nothing
            )



-- ERRORS


{-| Prefix `warning:` onto a `Warn`-posture message so brand gate output and
reviewers can tell an advisory apart from a hard content-model failure, while
still using elm-review's single error channel (§ Severity docs).
-}
withSeverity : Severity -> String -> String
withSeverity severity message =
    case severity of
        Hard ->
            message

        Warn ->
            "warning: " ++ message


advisoryNote : Severity -> List String -> List String
advisoryNote severity details =
    case severity of
        Hard ->
            details

        Warn ->
            details ++ [ "This is an advisory (WARN posture): it is often a real bug but can be intentional composition (e.g. the child is owned from elsewhere via aria-owns). It does not, on its own, fail the strict content-model gate." ]


interactiveDescendantError : Config -> String -> String -> Node Expression -> Error {}
interactiveDescendantError config parent descendant node =
    Rule.error
        { message =
            withSeverity config.posture.interactive
                ("`" ++ descendant ++ "` is interactive content and may not be a descendant of `" ++ parent ++ "`")
        , details =
            advisoryNote config.posture.interactive
                [ "The `" ++ parent ++ "` content model forbids any interactive-content descendant at any depth (WHATWG). `" ++ descendant ++ "` is interactive content."
                , "Move `" ++ descendant ++ "` out of `" ++ parent ++ "`, or use a non-interactive element in its place."
                ]
        }
        (Node.range node)


selfDescendantError : Config -> String -> Node Expression -> Error {}
selfDescendantError config parent node =
    Rule.error
        { message =
            withSeverity config.posture.interactive
                ("`" ++ parent ++ "` may not have a `" ++ parent ++ "` descendant")
        , details =
            advisoryNote config.posture.interactive
                [ "The `" ++ parent ++ "` content model forbids a descendant of the same element (WHATWG)."
                , "Move the nested `" ++ parent ++ "` out of its ancestor `" ++ parent ++ "`."
                ]
        }
        (Node.range node)


nestedLabelError : Config -> Node Expression -> Error {}
nestedLabelError config node =
    Rule.error
        { message =
            withSeverity config.posture.label
                "`label` may not have a descendant `label`"
        , details =
            advisoryNote config.posture.label
                [ "A `label`'s content model forbids any descendant `label` element (WHATWG)."
                , "Split the nested `label` out so each labeled control has its own label."
                ]
        }
        (Node.range node)


extraLabelableError : Config -> String -> Node Expression -> Error {}
extraLabelableError config kind node =
    Rule.error
        { message =
            withSeverity config.posture.label
                ("`label` may contain at most one labelable control; `" ++ kind ++ "` is an extra one")
        , details =
            advisoryNote config.posture.label
                [ "A `label` may contain a labelable descendant only if it is the element's single labeled control (WHATWG). A second labelable descendant (`" ++ kind ++ "`) has no defined association."
                , "Give each labelable control its own `label`."
                ]
        }
        (Node.range node)


requiredContextError : Config -> String -> Node Expression -> Error {}
requiredContextError config childRole node =
    let
        required =
            Dict.get childRole config.requiredContext |> Maybe.withDefault []
    in
    Rule.error
        { message =
            withSeverity config.posture.requiredContext
                ("`" ++ childRole ++ "` requires an ancestor of role " ++ describeContainers required)
        , details =
            advisoryNote config.posture.requiredContext
                [ "WAI-ARIA gives `" ++ childRole ++ "` a required context role: it must be contained in " ++ describeContainers required ++ "."
                , "Place `" ++ childRole ++ "` inside its required container."
                ]
        }
        (Node.range node)


svgAamError : Config -> String -> String -> Node Expression -> Error {}
svgAamError config element setterName node =
    Rule.error
        { message =
            withSeverity config.posture.svgAam
                ("`" ++ setterName ++ "` on a non-rendered SVG element `" ++ element ++ "` is not allowed")
        , details =
            advisoryNote config.posture.svgAam
                [ "SVG Accessibility API Mappings: `" ++ element ++ "` creates no accessible object, so no role may be applied and `aria-roledescription` must not be exposed on it."
                , "Remove the role / aria-roledescription attribute from `" ++ element ++ "`."
                ]
        }
        (Node.range node)


describeContainers : List String -> String
describeContainers containers =
    case containers of
        [] ->
            "(unspecified)"

        [ one ] ->
            "`" ++ one ++ "`"

        many ->
            "one of " ++ String.join ", " (List.map (\c -> "`" ++ c ++ "`") many)
