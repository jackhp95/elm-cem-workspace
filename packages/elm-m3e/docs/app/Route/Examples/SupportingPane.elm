module Route.Examples.SupportingPane exposing (ActionData, Data, Model, Msg, route)

{-| **Supporting pane** — the canonical Material 3 adaptive supporting-pane pattern,
built as a project overview screen. It is the worked reference the
`composing-m3e-layouts` skill points at for this pattern.

The difference from list-detail: the two regions are not peers. A wide **primary**
region holds the focus content; a narrower **supporting** pane holds secondary,
related material (activity, quick stats) that _supports_ the primary without
competing. On expanded windows (`lg:`) they sit side by side, primary flexing and
supporting fixed at `lg:w-80`. Below `lg:` the supporting pane reflows to the bottom
of the primary column — it stays available but yields the top of the reading order to
the primary content (the standard compact behavior for supporting panes: reflow,
don't hide).

Navigation switches the usual way: `M3e.NavRail` on desktop, `M3e.NavBar` on mobile,
one destination list. Tailwind is layout only; every visual token comes from M3
token classes inlined directly via `TypedHtml.Attributes.class`.

-}

import BackendTask
import ExampleNav
import Head
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.AppBar
import M3e.Component.Card
import M3e.Component.ListItem
import M3e.Component.NavItem
import M3e.Kind
import M3e.Values as Value
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes as TA
import TypedHtml.Component.Grouping
import View exposing (View)



-- MODEL -----------------------------------------------------------------------


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


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = BackendTask.succeed {} }
        |> RouteBuilder.buildNoState { view = view }


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    []


{-| The five navigation destinations, with their Material Symbols icon name.
-}
destinations : List { icon : String, label : String }
destinations =
    [ { icon = "dashboard", label = "Overview" }
    , { icon = "task", label = "Tasks" }
    , { icon = "forum", label = "Discussion" }
    , { icon = "folder", label = "Files" }
    , { icon = "settings", label = "Settings" }
    ]



-- VIEW ------------------------------------------------------------------------


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Supporting pane" screen


{-| The full-viewport shell: a desktop rail beside a column of AppBar + the
primary/supporting body, with a mobile bottom bar.

`flex-col md:flex-row`: one shell, two axes. At `md`+ it is a ROW (rail | main
column) and `mobileBar` is `md:hidden`. Below `md` the rail is `hidden` — so it
takes no flex slot — and the SAME div is a COLUMN whose in-flow children are,
top to bottom, the main column then the bottom nav bar. That is what lets the
bar stop being `position: fixed`: an in-flow bar can't occlude the content
above it, so no scroll region on this page needs a compensating `pb-24` to keep
its last row readable.

Note this `md:` breakpoint is the NAVIGATION one, and is independent of the
`lg:` breakpoint `body` uses to reflow the supporting pane.

`min-h-0` is the column-axis twin of `min-w-0`: a flex item's default
`min-height: auto` would let the main column grow to fit its content instead of
its flex basis, pushing the nav bar off the bottom of the viewport and turning
the DOCUMENT into the scroller.

-}
screen : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
screen =
    TypedHtml.div
        [ TA.class "flex flex-col md:flex-row h-dvh w-full overflow-hidden" ]
        [ desktopRail
        , TypedHtml.div [ TA.class "flex flex-1 flex-col min-w-0 min-h-0 overflow-hidden" ]
            [ appBar
            , TypedHtml.div [ TA.class "flex-1 overflow-y-auto" ]
                [ body
                , exampleFooter
                ]
            ]
        , mobileBar
        ]


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
            , ( "assistchip", "AssistChip" )
            ]
        , prev = Just ( "/examples/list-detail", "List-detail" )
        , next = Just ( "/examples/feed", "Feed" )
        }


appBar : Element { s | appBar : M3e.Kind.Brand } adm_ msg
appBar =
    M3e.appBar []
        [ M3e.Component.AppBar.title (M3e.text "Rally redesign") ]



-- PRIMARY + SUPPORTING BODY ---------------------------------------------------


{-| The whole point of the pattern: `flex-col lg:flex-row` puts the supporting
pane BELOW the primary on compact and BESIDE it on expanded. `flex-1` lets the
primary grow; `lg:w-80 lg:shrink-0` fixes the supporting pane's width so it never
crowds the primary.
-}
body : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
body =
    TypedHtml.div [ TA.class "mx-auto flex w-full max-w-6xl flex-col gap-6 p-4 md:p-6 lg:flex-row" ]
        [ primary
        , supporting
        ]


{-| The primary region: the focus content. Flexes to fill the row.
-}
primary : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
primary =
    TypedHtml.div [ TA.class "flex flex-1 flex-col gap-4 min-w-0" ]
        [ M3e.heading [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.small ] [ M3e.text "Project overview" ]
        , TypedHtml.span []
            [ M3e.text "The Rally redesign moves the metric cards to the top row and swaps the donut for a stacked bar so the trend reads at a glance. This quarter's focus is the motion pass and the adaptive navigation." ]
        , summaryCard
        , milestonesCard
        ]


summaryCard : Element { s | card : M3e.Kind.Brand } adm_ msg
summaryCard =
    M3e.card [ M3e.Attributes.variant Value.elevated ]
        [ M3e.Component.Card.header (M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.large ] [ M3e.text "This sprint" ])
        , M3e.Component.Card.content
            (TypedHtml.div [ TA.class "flex flex-wrap gap-6 pt-1" ]
                [ metric "12" "Tasks done"
                , metric "3" "In review"
                , metric "88%" "On track"
                ]
            )
        ]


metric : String -> String -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
metric value label =
    TypedHtml.div [ TA.class "flex flex-col" ]
        [ M3e.heading
            [ M3e.Attributes.variant Value.headline
            , M3e.Attributes.size Value.medium
            ]
            [ M3e.text value ]
        , M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large ] [ M3e.text label ]
        ]


milestonesCard : Element { s | card : M3e.Kind.Brand } adm_ msg
milestonesCard =
    M3e.card [ M3e.Attributes.variant Value.filled ]
        [ M3e.Component.Card.header (M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.large ] [ M3e.text "Milestones" ])
        , M3e.Component.Card.content
            (M3e.list []
                (List.intersperse (M3e.divider [ M3e.Attributes.inset True ] [])
                    [ milestoneRow "check_circle" "Motion tokens" "Shipped"
                    , milestoneRow "pending" "Adaptive nav" "In progress"
                    , milestoneRow "radio_button_unchecked" "A11y pass" "Not started"
                    ]
                )
            )
        ]


milestoneRow : String -> String -> String -> Element { s | listItem : M3e.Kind.Brand } adm_ msg
milestoneRow iconName label status =
    M3e.listItem []
        [ M3e.Component.ListItem.leading (M3e.icon [ TA.name iconName ] [])
        , M3e.text label
        , M3e.Component.ListItem.trailing
            (M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large ] [ M3e.text status ])
        ]


{-| The supporting pane: secondary, related material. Fixed width beside the
primary on `lg:`, reflowed beneath it on compact.
-}
supporting : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
supporting =
    TypedHtml.div [ TA.class "shrink-0 lg:w-80" ]
        [ M3e.card
            [ M3e.Attributes.variant Value.filled
            , M3e.Attributes.class "m3e-card-shape-md-corner-large"
            ]
            [ M3e.Component.Card.content
                (TypedHtml.div [ TA.class "flex flex-col gap-4 p-4" ]
                    [ M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium ] [ M3e.text "Recent activity" ]
                    , M3e.list [] (List.map activityRow activity)
                    , M3e.divider [] []
                    , M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium ] [ M3e.text "Tags" ]
                    , M3e.chipSet [ Aria.label "Tags" ]
                        (List.map tag [ "design", "motion", "a11y", "beta" ])
                    ]
                )
            ]
        ]


type alias Activity =
    { initials : String, who : String, what : String }


activity : List Activity
activity =
    [ { initials = "AC", who = "Ali", what = "commented on Motion tokens" }
    , { initials = "TH", who = "Trevor", what = "updated the trend chart" }
    , { initials = "SA", who = "Sandra", what = "approved the nav PR" }
    ]


activityRow : Activity -> Element { s | listItem : M3e.Kind.Brand } adm_ msg
activityRow a =
    M3e.listItem []
        [ M3e.Component.ListItem.leading (M3e.avatar [] [ M3e.text a.initials ])
        , M3e.text a.who
        , M3e.Component.ListItem.supportingText (M3e.text a.what)
        ]


tag : String -> Element { s | assistChip : M3e.Kind.Brand } adm_ msg
tag label =
    M3e.assistChip [] [ M3e.text label ]



-- NAVIGATION ------------------------------------------------------------------


desktopRail : Element { s | navRail : M3e.Kind.Brand } adm_ msg
desktopRail =
    M3e.navRail [ TA.class "hidden md:flex shrink-0" ]
        (List.map navItem destinations)


{-| Mobile: a bottom nav bar, replacing the rail below the `md` breakpoint.

The bar is a REAL flex child of `screen`'s outer `flex flex-col md:flex-row`,
not `position: fixed` — so on mobile it takes its own row at the bottom of the
column and can't occlude anything above it. That is what lets `body` skip the
compensating `pb-24` a floating bar would otherwise need.

-}
mobileBar : Element { s | navBar : M3e.Kind.Brand } adm_ msg
mobileBar =
    M3e.navBar [ TA.class "md:hidden shrink-0" ]
        (List.map navItem destinations)


navItem : { icon : String, label : String } -> Element { s | navItem : M3e.Kind.Brand } adm_ msg
navItem d =
    M3e.navItem
        [ M3e.Attributes.selected (d.label == "Overview") ]
        [ M3e.Component.NavItem.icon (M3e.icon [ TA.name d.icon ] [])
        , M3e.text d.label
        ]
