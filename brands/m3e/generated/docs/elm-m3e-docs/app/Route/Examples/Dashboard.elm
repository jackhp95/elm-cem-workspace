module Route.Examples.Dashboard exposing (ActionData, Data, Model, Msg, route)

{-| **Aperture Analytics** — a full-viewport Material 3 analytics dashboard screen,
authored on the M3e API, with M3 token classes for every visual choice. It carries
its own nav chrome: an `AppBar` header, a `NavRail` on desktop and a bottom `NavBar`
on mobile (same five destinations), a KPI stat-card row, an Accounts card grid, a
Budgets card whose rows pair a category with a `Progress.linear` meter, a
Recent-activity data table built from `ListItem` rows separated by `Divider`, and a
`Fab` primary action.

Everything visual (color, type scale, surface, shape) comes from M3 token classes
inlined directly via `TypedHtml.Attributes.class`; Tailwind is used only for layout
and responsive visibility. Static screen (no local state).

-}

import BackendTask
import Doc
import Effect exposing (Effect)
import ExampleNav
import Head
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.AppBar
import M3e.Component.Card
import M3e.Component.Fab
import M3e.Component.LinearProgressIndicator
import M3e.Component.ListItem
import M3e.Component.NavItem
import M3e.Kind
import M3e.Values as Value
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes as TA
import TypedHtml.Component.Grouping
import TypedHtml.Component.Sectioning
import UrlPath exposing (UrlPath)
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


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
    ( {}, Effect.none )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ _ model =
    ( model, Effect.none )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    []



-- DATA ------------------------------------------------------------------------


type alias Destination =
    { icon : String, name : String, selected : Bool }


destinations : List Destination
destinations =
    [ { icon = "dashboard", name = "Overview", selected = True }
    , { icon = "insights", name = "Reports", selected = False }
    , { icon = "receipt_long", name = "Transactions", selected = False }
    , { icon = "savings", name = "Budgets", selected = False }
    , { icon = "settings", name = "Settings", selected = False }
    ]


{-| Direction of a trend delta, which drives the icon + color role.
-}
type Trend
    = Up
    | Down


type alias Kpi =
    { label : String, value : String, delta : String, trend : Trend }


kpis : List Kpi
kpis =
    [ { label = "Total Revenue", value = "$48,290", delta = "+12.4%", trend = Up }
    , { label = "Active Users", value = "9,381", delta = "+3.1%", trend = Up }
    , { label = "Conversion", value = "4.7%", delta = "-0.6%", trend = Down }
    , { label = "Avg. Session", value = "5m 12s", delta = "+8.9%", trend = Up }
    ]


type alias Account =
    { icon : String, name : String, balance : String }


accounts : List Account
accounts =
    [ { icon = "account_balance", name = "Operating", balance = "$21,904.18" }
    , { icon = "savings", name = "Reserve", balance = "$62,890.55" }
    , { icon = "payments", name = "Payouts", balance = "$8,120.00" }
    , { icon = "credit_card", name = "Card", balance = "-$1,204.32" }
    ]


type alias Budget =
    { category : String, amount : String, used : Float, max : Float }


budgets : List Budget
budgets =
    [ { category = "Marketing", amount = "$3,200 / $4,000", used = 3200, max = 4000 }
    , { category = "Infrastructure", amount = "$1,050 / $2,500", used = 1050, max = 2500 }
    , { category = "Payroll", amount = "$18,400 / $20,000", used = 18400, max = 20000 }
    , { category = "Travel", amount = "$980 / $900", used = 980, max = 900 }
    ]


type alias Activity =
    { date : String, description : String, amount : String, incoming : Bool }


activity : List Activity
activity =
    [ { date = "Jul 02", description = "Stripe payout", amount = "+$4,120.00", incoming = True }
    , { date = "Jul 01", description = "AWS invoice", amount = "-$842.19", incoming = False }
    , { date = "Jun 30", description = "New subscription — Acme Co.", amount = "+$299.00", incoming = True }
    , { date = "Jun 29", description = "Figma seats", amount = "-$180.00", incoming = False }
    , { date = "Jun 28", description = "Refund — order #10482", amount = "-$59.00", incoming = False }
    ]



-- VIEW ------------------------------------------------------------------------


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view _ _ _ =
    View.fromElement "Aperture Analytics"
        -- A COLUMN bounded to the viewport: app bar, then the rail|content row,
        -- then the mobile bottom bar as a plain in-flow last child.
        --
        -- `h-dvh` + `overflow-hidden`, NOT `min-h-screen`. `min-h-screen` is a
        -- FLOOR, not a height: the root stayed auto-tall, the DOCUMENT was the
        -- scroller, and the bar needed `sticky bottom-0` to stay on screen. A
        -- definite height bounds the root instead, so `mainContent` is the one
        -- scroll region and the bar simply cannot be pushed anywhere -- no
        -- positioning of any kind on it, and no compensating bottom padding on
        -- anything it might otherwise have occluded. `h-dvh` (not `h-screen`)
        -- because `100vh` overshoots the visible viewport on mobile browsers
        -- with a retracting URL bar, which would push an in-flow bar under the
        -- browser chrome -- reintroducing by UNIT the occlusion this removes by
        -- POSITIONING.
        --
        -- `min-h-0` on the row is the guard that makes the bound real: a flex
        -- item's default `min-height: auto` lets it grow to fit content instead
        -- of its flex basis. Verified load-bearing by perturbation -- dropping
        -- it at 411x761 grows the row from 629px to 2061px and puts the bar at
        -- y=2125, which `overflow-hidden` then clips away entirely: the bar is
        -- not merely below the fold, it is gone, and no amount of scrolling
        -- reaches it.
        (TypedHtml.div
            [ TA.class "flex flex-col h-dvh w-full overflow-hidden" ]
            [ appBar
            , TypedHtml.div [ TA.class "flex flex-1 min-h-0" ]
                [ desktopRail
                , mainContent
                ]
            , mobileBar
            ]
        )


{-| The shared "Built from" + prev/next strip. Dashboard is the first example,
so it has no previous screen.

It lives INSIDE `mainContent`'s scroll region rather than beside it as a root
child. Once the root is bounded to `h-dvh`, every root child spends viewport
height that the content can never get back -- a permanent ~100px tax on a
761px phone, for a strip that is by design a quiet annotation read after the
screen. Scrolling it in with the content is also what the other examples do.

-}
exampleFooter : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
exampleFooter =
    ExampleNav.footer
        { builtFrom =
            [ ( "appbar", "AppBar" )
            , ( "navrail", "NavRail" )
            , ( "navbar", "NavBar" )
            , ( "card", "Card" )
            , ( "listitem", "ListItem" )
            , ( "divider", "Divider" )
            , ( "progress", "Progress" )
            , ( "fab", "Fab" )
            , ( "iconbutton", "IconButton" )
            ]
        , prev = Nothing
        , next = Just ( "/examples/shop", "Shop" )
        }



-- CHROME ----------------------------------------------------------------------


appBar : Element { s | appBar : M3e.Kind.Brand } adm_ msg
appBar =
    M3e.appBar [ M3e.Attributes.size Value.small ]
        [ M3e.Component.AppBar.leading (M3e.icon [ TA.name "analytics" ] [])
        , M3e.Component.AppBar.title (M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.large ] [ M3e.text "Aperture Analytics" ])
        , M3e.Component.AppBar.trailing (iconAction "search")
        , M3e.Component.AppBar.trailing (iconAction "notifications")
        , M3e.Component.AppBar.trailing (iconAction "account_circle")
        ]


iconAction : String -> Element { s | iconButton : M3e.Kind.Brand } adm_ msg
iconAction name =
    M3e.iconButton
        [ M3e.Attributes.variant Value.standard, Aria.label name ]
        [ M3e.icon [ TA.name name ] [] ]


{-| The desktop side rail. Hidden on mobile via `hidden md:flex`.

No `sticky top-0 self-start` any more: that existed only to keep the rail on
screen while the DOCUMENT scrolled past it. The document no longer scrolls, so
the rail is a plain full-height flex child of the bounded row and stays put on
its own.

-}
desktopRail : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
desktopRail =
    TypedHtml.div [ TA.class "hidden md:flex shrink-0" ]
        [ M3e.navRail []
            (List.map railItem destinations)
        ]


railItem : Destination -> Element { s | navItem : M3e.Kind.Brand } adm_ msg
railItem d =
    M3e.navItem
        [ M3e.Attributes.href "#", M3e.Attributes.selected d.selected ]
        [ M3e.Component.NavItem.icon (M3e.icon [ TA.name d.icon ] [])
        , M3e.text d.name
        ]


{-| The mobile bottom bar. Hidden on desktop via `md:hidden`.

A plain STATIC last-in-flow child of the bounded root column -- no `sticky`,
no `fixed`, no `z-10`. The parent is height-bounded and `mainContent` absorbs
every extra pixel, so nothing can push the bar and there is nothing for it to
stack above. `shrink-0` keeps it at its intrinsic height when the row above
competes for space.

-}
mobileBar : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
mobileBar =
    TypedHtml.div [ TA.class "md:hidden shrink-0" ]
        [ M3e.navBar []
            (List.map barItem destinations)
        ]


barItem : Destination -> Element { s | navItem : M3e.Kind.Brand } adm_ msg
barItem d =
    M3e.navItem
        [ M3e.Attributes.href "#", M3e.Attributes.selected d.selected ]
        [ M3e.Component.NavItem.icon (M3e.icon [ TA.name d.icon ] [])
        , M3e.text d.name
        ]


{-| The primary action, floating over the content by Material convention.

`sticky`, not `fixed`, and it lives INSIDE `mainContent`'s scroll region. The
distinction is the whole point: `fixed` is viewport-relative wherever it sits in
the DOM, so it had to hardcode `bottom-20` to clear the bar -- a magic number
that silently encodes the bar's 68px height and goes wrong the moment the bar
changes. `sticky` is relative to the nearest scrolling ancestor, and that
scroller's bottom edge IS the bar's top edge, so a plain `bottom-6` clears the
bar by construction with no knowledge of it. That also drops the `md:` variant:
one offset is now correct at both widths.

`pointer-events-none` on the positioned wrapper with `pointer-events-auto` on
the FAB itself keeps the full-width sticky row from blanketing the content it
floats over.

-}
fab : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
fab =
    TypedHtml.div [ TA.class "pointer-events-none sticky bottom-6 flex justify-end pr-4 md:pr-6" ]
        [ TypedHtml.div [ TA.class "pointer-events-auto" ]
            [ M3e.fab
                [ M3e.Attributes.variant Value.primary, M3e.Attributes.extended True, Aria.label "Add" ]
                [ M3e.icon [ TA.name "add" ] []
                , M3e.Component.Fab.label (M3e.text "New report")
                ]
            ]
        ]



-- MAIN CONTENT ----------------------------------------------------------------


{-| The one scroll region on the page. `overflow-y-auto` is what makes it absorb
all the overflow the bounded root refuses to grow for, which is in turn what
lets `mobileBar` be static -- and, because this box's bottom edge is exactly the
bar's top edge, what gives the sticky `fab` an offset that clears the bar
without knowing the bar exists.

`min-h-0` here is belt-and-braces, and honestly so: `overflow-y-auto` already
zeroes this box's own automatic minimum size, and perturbation confirms it --
dropping `min-h-0` from this section moves nothing by a pixel, while dropping
it from the parent row blows the layout out. It stays because the invariant
should not silently depend on the overflow class never moving; the class that
actually holds the line is the parent's.

The padding moves to an inner wrapper so `exampleFooter` and `fab` can sit
inside the scroller (edge to edge, and outside the `gap-6` rhythm of the content
above them) rather than costing the viewport a permanent row each. The old
`pb-28 md:pb-6` is gone: it was compensation for a floating bar, and nothing
floats over this box any more.

-}
mainContent : Element (TypedHtml.Component.Sectioning.SectionIs s) adm_ msg
mainContent =
    TypedHtml.section [ TA.class "flex-1 min-w-0 min-h-0 overflow-y-auto" ]
        -- `fab` is `sticky`, and a sticky element's stick range is its
        -- CONTAINING BLOCK. Left as a direct child of the scroller that block
        -- spans the footer too, so the FAB never settled back into its own row
        -- and sat over the prev/next strip at full scroll (measured on Shop,
        -- which had the identical shape: FAB 589-669 across the next-example
        -- link at 579-595). This wrapper ends where the content ends, so the
        -- FAB un-sticks and scrolls away as the footer arrives.
        [ TypedHtml.div []
            [ TypedHtml.div [ TA.class "flex flex-col gap-6 p-4 md:p-6" ]
                [ pageHeader
                , kpiRow
                , TypedHtml.div [ TA.class "grid grid-cols-1 gap-6 lg:grid-cols-3" ]
                    [ TypedHtml.div [ TA.class "lg:col-span-2 flex flex-col gap-6" ]
                        [ accountsSection
                        , activitySection
                        ]
                    , budgetsSection
                    ]
                ]
            , fab
            ]
        , exampleFooter
        ]


pageHeader : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
pageHeader =
    TypedHtml.div [ TA.class "flex flex-col gap-1" ]
        [ Doc.sectionLabelCaps "Overview"
        , M3e.heading [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small ] [ M3e.text "Good morning, Jack" ]
        , TypedHtml.span [] [ M3e.text "Here is how your business is doing today." ]
        ]



-- KPI ROW ---------------------------------------------------------------------


kpiRow : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
kpiRow =
    TypedHtml.div [ TA.class "grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4" ]
        (List.map kpiCard kpis)


kpiCard : Kpi -> Element { s | card : M3e.Kind.Brand } adm_ msg
kpiCard k =
    M3e.card [ M3e.Attributes.variant Value.filled ]
        [ M3e.Component.Card.content
            (TypedHtml.div [ TA.class "flex flex-col gap-2 p-4" ]
                [ M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large ] [ M3e.text k.label ]
                , M3e.heading [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small ] [ M3e.text k.value ]
                , trendDelta k.trend k.delta
                ]
            )
        ]


trendDelta : Trend -> String -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
trendDelta trend delta =
    let
        ( iconName, role ) =
            case trend of
                Up ->
                    ( "trending_up", "text-primary" )

                Down ->
                    ( "trending_down", "text-error" )
    in
    TypedHtml.div [ TA.class "flex items-center gap-1" ]
        [ M3e.icon [ TA.name iconName, TA.class role ] []
        , M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large, TA.class role ] [ M3e.text delta ]
        ]



-- ACCOUNTS --------------------------------------------------------------------


accountsSection : Element { s | card : M3e.Kind.Brand } adm_ msg
accountsSection =
    sectionCard "Accounts"
        (TypedHtml.div [ TA.class "grid grid-cols-1 gap-3 sm:grid-cols-2" ]
            (List.map accountRow accounts)
        )


accountRow : Account -> Element { s | card : M3e.Kind.Brand } adm_ msg
accountRow a =
    M3e.card
        [ M3e.Attributes.variant Value.filled
        , M3e.Attributes.class "m3e-card-shape-md-corner-large"
        ]
        [ M3e.Component.Card.content
            (TypedHtml.div [ TA.class "flex items-center gap-3 p-3" ]
                [ M3e.avatar
                    [ M3e.Attributes.class "m3e-avatar-color-secondary-container m3e-avatar-label-color-on-secondary-container" ]
                    [ M3e.icon [ TA.name a.icon ] [] ]
                , TypedHtml.div [ TA.class "flex flex-col min-w-0" ]
                    [ TypedHtml.span [] [ M3e.text a.name ]
                    , M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium ] [ M3e.text a.balance ]
                    ]
                ]
            )
        ]



-- BUDGETS ---------------------------------------------------------------------


budgetsSection : Element { s | card : M3e.Kind.Brand } adm_ msg
budgetsSection =
    sectionCard "Budgets"
        (TypedHtml.div [ TA.class "flex flex-col gap-5" ]
            (List.map budgetRow budgets)
        )


budgetRow : Budget -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
budgetRow b =
    TypedHtml.div [ TA.class "flex flex-col gap-2" ]
        [ TypedHtml.div [ TA.class "flex items-center justify-between gap-2" ]
            [ TypedHtml.span [] [ M3e.text b.category ]
            , M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large ] [ M3e.text b.amount ]
            ]
        , M3e.linearProgressIndicator
            [ M3e.Component.LinearProgressIndicator.value b.used, M3e.Attributes.max b.max ]
            []
        ]



-- RECENT ACTIVITY -------------------------------------------------------------


activitySection : Element { s | card : M3e.Kind.Brand } adm_ msg
activitySection =
    sectionCard "Recent activity"
        (M3e.list []
            (List.intersperse (M3e.divider [] [])
                (List.map activityRow activity)
            )
        )


activityRow : Activity -> Element { s | listItem : M3e.Kind.Brand } adm_ msg
activityRow a =
    let
        role : String
        role =
            if a.incoming then
                "text-primary"

            else
                "text-on-surface"
    in
    M3e.listItem []
        [ M3e.Component.ListItem.leading
            (M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large ] [ M3e.text a.date ])
        , M3e.text a.description
        , M3e.Component.ListItem.trailing
            (M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium, TA.class role ] [ M3e.text a.amount ])
        ]



-- SHARED SECTION CARD ---------------------------------------------------------


sectionCard : String -> Element any adm_ msg -> Element { r | card : M3e.Kind.Brand } adm_ msg
sectionCard heading content =
    M3e.card [ M3e.Attributes.variant Value.elevated ]
        [ M3e.Component.Card.header
            (M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.large ] [ M3e.text heading ])
        , M3e.Component.Card.content content
        ]
