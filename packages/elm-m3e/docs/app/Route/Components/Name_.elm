module Route.Components.Name_ exposing (ActionData, Data, Model, Msg, route)

{-| The per-component **API reference** page (`/components/:slug`), re-authored on the
M3e API (opus). Data-driven: one pre-rendered page per component in
`data/reference.json`, each showing the component name, overview, and its API members
(types + functions with signatures + docs) in the content-pane + card pattern using
real `M3e.*` components. (The original also embedded per-component _live demos_, which
imported all 55 component modules; those are deferred — this restores the reference.)
-}

import BackendTask exposing (BackendTask)
import Dict
import Doc
import Doc.Data exposing (Component, ExampleUsage, allComponents, allExampleUsage, allUsage)
import Doc.Usage as Usage exposing (UsageExample)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Card
import M3e.Component.ListItem
import M3e.Kind
import M3e.Values as Value
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import Theme.Ports
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Component.Grouping
import UrlPath exposing (UrlPath)
import View exposing (View)


{-| No per-route state: the layer-tab selection lives in `Shared.Model`
(`activeSurface`) so it survives client-side navigation. This page only reads it
and forwards tab clicks to `Theme.Ports.storeSurface`.
-}
type alias Model =
    ()


type alias Msg =
    Usage.Msg


type alias RouteParams =
    { name : String }


type alias Data =
    { component : Component
    , usage : List UsageExample
    , exampleUsage : List ExampleUsage
    }


type alias ActionData =
    {}


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.preRender { head = head, pages = pages, data = data }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( (), Effect.none )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ (Usage.SelectSurface surface) _ =
    -- Write the choice to localStorage; `index.ts` echoes it back through
    -- `readSurface` to `Shared`, which owns `activeSurface` and re-renders every
    -- tab strip on the page from that one value.
    ( (), Effect.fromCmd (Theme.Ports.storeSurface (Usage.encodeSurface surface)) )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    -- The `readSurface` subscription lives in `Shared` (single source of truth).
    Sub.none


pages : BackendTask FatalError (List RouteParams)
pages =
    allComponents |> BackendTask.map (List.map (\c -> { name = c.slug }))


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    BackendTask.map3 Data
        (componentFor routeParams)
        (allUsage |> BackendTask.map (Dict.get routeParams.name >> Maybe.withDefault []))
        (allExampleUsage |> BackendTask.map (Dict.get routeParams.name >> Maybe.withDefault []))


componentFor : RouteParams -> BackendTask FatalError Component
componentFor routeParams =
    allComponents
        |> BackendTask.andThen
            (\components ->
                case List.filter (\c -> c.slug == routeParams.name) components of
                    c :: _ ->
                        BackendTask.succeed c

                    [] ->
                        BackendTask.fail (FatalError.fromString ("Unknown component: " ++ routeParams.name))
            )


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    []


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view app shared _ =
    let
        component : Component
        component =
            app.data.component
    in
    View.fromElement component.label
        (M3e.mapMsg PagesMsg.fromMsg
            (Doc.pane
                [ -- One vertical rhythm (`space-y-10`) governs every top-level doc
                  -- section — header, Usage, API — so their spacing is uniform.
                  TypedHtml.div [ TA.class "space-y-10" ]
                    (header component
                        :: Usage.usageBlocks shared.activeSurface app.data.usage
                        ++ [ apiSection shared.activeSurface component ]
                        ++ exampleAppsSection app.data.exampleUsage
                    )
                ]
            )
        )


{-| The page header, mirroring the matraic component pages: the component name as
a display heading (with its category chip alongside), the cleaned one-line CEM
summary, and a barrel-first install card. Events and slots are documented by the
colocated API section below, not repeated here.
-}
header : Component -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
header component =
    TypedHtml.div [ TA.class "space-y-4" ]
        (TypedHtml.div [ TA.class "flex flex-wrap items-center gap-3" ]
            (M3e.heading
                [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small, M3e.Attributes.level 1 ]
                [ M3e.text component.label ]
                :: categoryChip component.category
            )
            :: summaryBlock component.summary
            ++ [ installCard, Doc.userlandNote ]
        )


{-| Cross-links to the example apps (`/examples/*`) that instantiate this
component, from `data/example-usage.json`. Rendered only when non-empty, so a
component absent from every example app shows no section at all.
-}
exampleAppsSection : List ExampleUsage -> List (Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg)
exampleAppsSection usages =
    if List.isEmpty usages then
        []

    else
        [ TypedHtml.div [ TA.class "space-y-4" ]
            [ Doc.sectionHeadingWithId (Doc.slugify "In the example apps") "In the example apps"
            , TypedHtml.div [ TA.class "flex flex-wrap gap-2" ]
                (List.map
                    (\u -> Doc.anchorPill { href = u.route, label = u.title })
                    usages
                )
            ]
        ]


{-| The component's category as a non-interactive suggestion chip, alongside the
title. Empty ⇒ nothing (many derived/record modules carry no category).
-}
categoryChip : String -> List (Element { s | suggestionChip : M3e.Kind.Brand } adm_ msg)
categoryChip cat =
    if cat == "" then
        []

    else
        [ M3e.suggestionChip [] [ M3e.text cat ] ]


{-| The one-line summary paragraph, constrained to a comfortable reading measure.
Empty ⇒ nothing.
-}
summaryBlock : String -> List (Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg)
summaryBlock summary =
    if summary == "" then
        []

    else
        [ TypedHtml.div [ TA.class "max-w-2xl" ]
            [ TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ] [ M3e.text summary ] ]
        ]


{-| The install snippet: the barrel-first imports every Usage example's top
form uses (`M3e.button`, `M3e.variant`, `M3e.Values.elevated`). Rendered as the
same filled, rounded code block the Usage section uses (matraic's install card is
a bare `<pre>`); wrapping it in an outlined Card would nest a surface-container
fill inside a card border — a box-in-box that fights the M3 surface roles.
-}
installCard : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
installCard =
    Doc.codeBlock Doc.Elm "import M3e\nimport M3e.Values"


{-| The four API layers, in tab order, each mapping a `Surface` to its label and
the member list to render: `Top → the M3e barrel's per-component slice`,
`Record → M3e.Component.<Name>`, `Build → M3e.Build.<Name>`, `Raw → the underlying
custom element's CEM attributes/events/slots`. These reuse `Doc.Usage.Surface`, so
a Usage-tab click and an API-tab click move the SAME site-wide `activeSurface`.
-}
apiLayers : Component -> List ( Usage.Surface, String, List Doc.Data.Member )
apiLayers component =
    [ ( Usage.Top, "M3e", component.layers.m3e )
    , ( Usage.Record, "Components", component.layers.components )
    , ( Usage.Build, "Builder", component.layers.builder )
    , ( Usage.Raw, "Raw", component.layers.raw )
    ]


{-| The API-reference section, rendered like an elm module page: a page-wide Types
block (the component's aliases/unions, un-tabbed, above — they are not
layer-specific), then the 4-tab layer strip driven by the shared `activeSurface`,
then the selected layer's members grouped by role (constructor, attribute setters,
slot setters, events, other), each group an overline-labelled outlined card.
Members keep their `@docs` order within a group. Empty groups drop out.
-}
apiSection : Usage.Surface -> Component -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ Usage.Msg
apiSection activeSurface component =
    let
        activeLayer : List Doc.Data.Member
        activeLayer =
            apiLayers component
                |> List.filter (\( s, _, _ ) -> s == activeSurface)
                |> List.head
                |> Maybe.map (\( _, _, ms ) -> ms)
                -- Every Surface maps to a layer, so this is an unreachable
                -- safety net — never a blank section.
                |> Maybe.withDefault component.layers.m3e
    in
    TypedHtml.div [ TA.class "space-y-6" ]
        (Doc.sectionHeadingWithId (Doc.slugify "API") "API"
            :: typesBlock component.types
            ++ [ apiTabStrip activeSurface component ]
            ++ List.filterMap (apiGroup activeLayer) apiGroups
        )


{-| The component's type aliases/unions, shared across the M3e and Components
layers (the barrel re-exports the same types verbatim). Rendered once, above the
tab strip — NOT inside any tab — since they aren't layer-specific. Empty ⇒
nothing.
-}
typesBlock : List Doc.Data.Member -> List (Element (TypedHtml.Component.Grouping.DivIs s) adm_ Usage.Msg)
typesBlock types =
    case types of
        [] ->
            []

        _ ->
            [ TypedHtml.div [ TA.class "space-y-3" ]
                [ Doc.sectionLabel "Types"
                , M3e.card [ M3e.Attributes.variant Value.outlined ]
                    [ M3e.Component.Card.content (M3e.list [] (List.map memberRow types)) ]
                ]
            ]


{-| The 4-tab API layer strip (`M3e | Components | Builder | Raw`), driven by the
shared `activeSurface`. A click emits the SAME `Doc.Usage.SelectSurface` the Usage
tabs emit, so both strips move together.
-}
apiTabStrip : Usage.Surface -> Component -> Element { s | tabs : M3e.Kind.Brand } adm_ Usage.Msg
apiTabStrip activeSurface component =
    Usage.tabStrip
        activeSurface
        (List.map (\( surf, lbl, _ ) -> ( lbl, surf )) (apiLayers component))


{-| The API groups, in render order, each with the member roles it collects. Type
aliases/unions no longer live here — they render in the page-wide Types block
above. The trailing group catches helper values (e.g. `M3e.Action` combinators)
that are neither attrs, slots, nor events.
-}
apiGroups : List ( String, List String )
apiGroups =
    [ ( "Constructor", [ "ctor" ] )
    , ( "Attributes", [ "attr" ] )
    , ( "Slots", [ "slot" ] )
    , ( "Events", [ "event" ] )
    , ( "Other", [ "other", "" ] )
    ]


{-| One API group: an overline label over an outlined card listing its members.
`Nothing` when the group has no members, so it drops out of the section rhythm.
-}
apiGroup : List Doc.Data.Member -> ( String, List String ) -> Maybe (Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg)
apiGroup members ( label, roles ) =
    case List.filter (\m -> List.member m.role roles) members of
        [] ->
            Nothing

        group ->
            Just
                (TypedHtml.div [ TA.class "space-y-3" ]
                    [ Doc.sectionLabel label
                    , M3e.card [ M3e.Attributes.variant Value.outlined ]
                        [ M3e.Component.Card.content (M3e.list [] (List.map memberRow group)) ]
                    ]
                )


{-| One API member: the syntax-highlighted signature (`type Name` for aliases /
unions, `name : signature` for values) and its Markdown-rendered doc. The kind
eyebrow is gone — the enclosing group heading now conveys what each row is.
-}
memberRow : Doc.Data.Member -> Element { s | listItem : M3e.Kind.Brand } adm_ msg
memberRow m =
    let
        sig : String
        sig =
            if m.kind == "type" then
                "type " ++ m.name

            else if m.signature == "" then
                m.name

            else
                m.name ++ " : " ++ m.signature
    in
    M3e.listItem []
        (Doc.elmSignature sig
            :: (if m.doc == "" then
                    []

                else
                    [ M3e.Component.ListItem.supportingText (Doc.markdown m.doc) ]
               )
        )
