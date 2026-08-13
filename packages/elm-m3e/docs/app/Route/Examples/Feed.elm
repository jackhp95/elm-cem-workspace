module Route.Examples.Feed exposing (ActionData, Data, Model, Msg, route)

{-| **Feed** — the canonical Material 3 adaptive feed pattern: a responsive grid of
content cards whose column count grows with the window size class, driven by a
`FilterChipSet` toolbar. It is the worked reference the `composing-m3e-layouts` skill
points at for this pattern.

The grid is the whole adaptivity: `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3` — one
column on compact, two on medium, three on expanded — so the cards reflow to fill the
available width without any per-breakpoint markup. A row of `FilterChip`s filters the
feed by category; selecting one is real state (`SelectFilter`). Navigation switches the
usual way: `M3e.NavRail` on desktop, `M3e.NavBar` on mobile, one destination list.

Tailwind is layout only (grid/gap/padding/responsive columns); every visual token —
color, typography, surface, shape — comes from M3 token classes applied directly
with `TypedHtml.Attributes.class`.

-}

import BackendTask
import Effect exposing (Effect)
import ExampleNav
import Head
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.AppBar
import M3e.Component.Card
import M3e.Component.NavItem
import M3e.Events
import M3e.Kind
import M3e.Values as Value
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import TypedHtml.Grouping
import UrlPath exposing (UrlPath)
import View exposing (View)



-- MODEL -----------------------------------------------------------------------


type alias Model =
    { filter : String }


type Msg
    = SelectFilter String



-- ROUTE -----------------------------------------------------------------------


type alias RouteParams =
    {}


type alias Data =
    {}


type alias ActionData =
    {}


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single { head = head, data = BackendTask.succeed {} }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( { filter = "All" }, Effect.none )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        SelectFilter category ->
            ( { model | filter = category }, Effect.none )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    []



-- DATA ------------------------------------------------------------------------


type alias Post =
    { title : String
    , excerpt : String
    , category : String
    , author : String
    , when : String
    , media : String
    , icon : String
    }


posts : List Post
posts =
    [ { title = "Motion tokens land in 2.5", excerpt = "Springs and shape morphing now derive from the theme's motion scheme.", category = "Release", author = "Design team", when = "2h", media = "bg-primary-container text-on-primary-container", icon = "animation" }
    , { title = "Adaptive nav, one destination list", excerpt = "How the rail and the bottom bar share a single producer so they never drift.", category = "Guide", author = "Britta Holt", when = "5h", media = "bg-tertiary-container text-on-tertiary-container", icon = "dashboard" }
    , { title = "A11y-tree spot-checks", excerpt = "The Playwright recipe for asserting every interactive node has a name.", category = "Guide", author = "Miriam Steketee", when = "1d", media = "bg-secondary-container text-on-secondary-container", icon = "accessibility_new" }
    , { title = "Re-skin with tokens", excerpt = "A brand refresh is a few Theme inputs, not a sheet of overrides.", category = "Guide", author = "Ali Connors", when = "1d", media = "bg-primary-container text-on-primary-container", icon = "palette" }
    , { title = "Split panes and refreshed search", excerpt = "The 2.5 layer/form roles get expressive elevation tokens across the board.", category = "Release", author = "Product", when = "2d", media = "bg-tertiary-container text-on-tertiary-container", icon = "space_dashboard" }
    , { title = "Community: composing rich cards", excerpt = "A pattern for media-topped cards that clip to the shape scale.", category = "Community", author = "Trevor Hansen", when = "3d", media = "bg-secondary-container text-on-secondary-container", icon = "groups" }
    ]


filters : List String
filters =
    [ "All", "Release", "Guide", "Community" ]


{-| The four navigation destinations, with their Material Symbols icon name.
-}
destinations : List { icon : String, label : String }
destinations =
    [ { icon = "home", label = "Home" }
    , { icon = "explore", label = "Explore" }
    , { icon = "bookmark", label = "Saved" }
    , { icon = "notifications", label = "Activity" }
    ]



-- VIEW ------------------------------------------------------------------------


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view _ _ model =
    View.fromElement "Feed" (M3e.mapMsg PagesMsg.fromMsg (screen model))


{-| The full-viewport shell: a desktop rail beside a column of AppBar + the
filter bar and the reflowing card grid, with a mobile bottom bar.

`flex-col md:flex-row` is one shell on two axes. At `md`+ it is a ROW
(rail | main column) and `mobileBar` is `md:hidden`. Below `md` the rail is
`hidden` -- so it takes no flex slot -- and the SAME div is a COLUMN whose
in-flow children are, top to bottom, the main column then the bottom bar.
That is what lets the bar stop being `position: fixed`: an in-flow bar
cannot occlude the content above it, so the feed's scroll region needs no
compensating `pb-24` to keep its last card reachable.

`min-h-0` is the column-axis twin of `min-w-0`: a flex item's default
`min-height: auto` would let the main column grow to fit its content rather
than its flex basis, pushing the bar off the bottom of the viewport and
turning the DOCUMENT into the scroller. Belt-and-braces alongside the
column's own `overflow-hidden` (which already suppresses `min-height: auto`),
but it keeps the "one bounded scroll region" invariant from hanging on that
one class.

-}
screen : Model -> Element (TypedHtml.Grouping.DivIs s) adm_ Msg
screen model =
    TypedHtml.div
        [ TA.class "bg-surface text-on-surface flex flex-col md:flex-row h-dvh w-full overflow-hidden" ]
        [ desktopRail
        , TypedHtml.div [ TA.class "flex flex-1 flex-col min-w-0 min-h-0 overflow-hidden" ]
            [ appBar
            , TypedHtml.div [ TA.class "flex-1 overflow-y-auto" ]
                [ TypedHtml.div [ TA.class "mx-auto flex w-full max-w-6xl flex-col gap-6 p-4 md:p-6" ]
                    [ filterBar model.filter
                    , cardGrid (shownPosts model.filter)
                    ]
                , exampleFooter
                ]
            ]
        , mobileBar
        ]


exampleFooter : Element (TypedHtml.Grouping.DivIs s) adm_ msg
exampleFooter =
    ExampleNav.footer
        { builtFrom =
            [ ( "appbar", "AppBar" )
            , ( "navrail", "NavRail" )
            , ( "navbar", "NavBar" )
            , ( "card", "Card" )
            , ( "filterchipset", "FilterChipSet" )
            , ( "filterchip", "FilterChip" )
            ]
        , prev = Just ( "/examples/supporting-pane", "Supporting pane" )
        , next = Nothing
        }


appBar : Element { s | appBar : M3e.Kind.Brand } adm_ msg
appBar =
    M3e.appBar []
        [ M3e.Component.AppBar.title (M3e.text "Feed") ]



-- FILTER BAR ------------------------------------------------------------------


{-| The filter toolbar: a `FilterChipSet` of `FilterChip`s. The selected chip
carries `attrSelected`; clicking one is real state via `M3e.Events.onClick` (a
`FilterChip`'s selection is presentation — the app owns which category is active).
-}
filterBar : String -> Element { s | filterChipSet : M3e.Kind.Brand } adm_ Msg
filterBar current =
    M3e.filterChipSet []
        (List.map (filterChip current) filters)


filterChip : String -> String -> Element { s | filterChip : M3e.Kind.Brand } adm_ Msg
filterChip current category =
    M3e.filterChip
        [ M3e.Attributes.selected (category == current)
        , M3e.Events.onClick (SelectFilter category)
        ]
        [ M3e.text category ]



-- CARD GRID -------------------------------------------------------------------


shownPosts : String -> List Post
shownPosts filter =
    if filter == "All" then
        posts

    else
        List.filter (\p -> p.category == filter) posts


cardGrid : List Post -> Element (TypedHtml.Grouping.DivIs s) adm_ msg
cardGrid shown =
    TypedHtml.div [ TA.class "grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3" ]
        (List.map postCard shown)


postCard : Post -> Element { s | card : M3e.Kind.Brand } adm_ msg
postCard post =
    M3e.card [ M3e.Attributes.variant Value.elevated ]
        [ M3e.Component.Card.header
            (TypedHtml.div
                [ TA.class (post.media ++ " rounded-md-corner-medium flex h-32 items-center justify-center") ]
                [ M3e.icon [ TA.name post.icon, TA.class "text-4xl" ] [] ]
            )
        , M3e.Component.Card.content
            (TypedHtml.div [ TA.class "flex flex-col gap-2 pt-1" ]
                [ M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.small, TA.class "text-primary" ] [ M3e.text (String.toUpper post.category) ]
                , M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium, TA.class "text-on-surface" ] [ M3e.text post.title ]
                , TypedHtml.span [ TA.class "text-body-md text-on-surface-variant" ] [ M3e.text post.excerpt ]
                , M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.small, TA.class "text-on-surface-variant" ] [ M3e.text (post.author ++ " · " ++ post.when) ]
                ]
            )
        ]



-- NAVIGATION ------------------------------------------------------------------


desktopRail : Element { s | navRail : M3e.Kind.Brand } adm_ msg
desktopRail =
    M3e.navRail [ TA.class "hidden md:flex shrink-0" ]
        (List.map navItem destinations)


{-| Mobile: a bottom nav bar, replacing the rail below the `md` breakpoint.

It is a REAL flex child of `screen`'s outer `flex flex-col md:flex-row`, not
`position: fixed` -- so on mobile it takes its own row at the bottom of the
column and cannot occlude the feed above it. `shrink-0` keeps it at its
intrinsic height when the feed is tall.

-}
mobileBar : Element { s | navBar : M3e.Kind.Brand } adm_ msg
mobileBar =
    M3e.navBar [ TA.class "md:hidden shrink-0" ]
        (List.map navItem destinations)


navItem : { icon : String, label : String } -> Element { s | navItem : M3e.Kind.Brand } adm_ msg
navItem d =
    M3e.navItem
        [ M3e.Attributes.selected (d.label == "Home") ]
        [ M3e.Component.NavItem.icon (M3e.icon [ TA.name d.icon ] [])
        , M3e.text d.label
        ]
