module Route.Examples.Mail exposing (ActionData, Data, Model, Msg, route)

{-| **Mail** — a full-viewport, responsive Material 3 email client screen built
almost entirely from `M3e.*` components. Tailwind is used only for layout
(flex/grid/gap/padding/positioning/responsive visibility); every visual token —
color, typography, surface, shape — comes from M3 token classes applied
directly with `TypedHtml.Attributes.class` (`text-on-surface`,
`surfaceContainer`, …), not a userland adapter.

Layout at a glance:

  - Adaptive navigation: an `M3e.NavRail` down the left on desktop (`hidden md:flex`)
    and an `M3e.NavBar` as the last in-flow row of the shell column on mobile
    (`md:hidden`) — a real flex child, not a `fixed` overlay, so nothing needs
    compensating bottom padding to stay clear of it. A top
    `M3e.AppBar` holds the app name and an `M3e.SearchBar`.
  - A message `M3e.List` beside an `M3e.DrawerContainer` `end` drawer holding the
    reading pane. The drawer slides in horizontally from the trailing edge when a
    row is selected; it never splits the screen vertically, which is what the
    list previously did below `md:` and which left both halves too short to read.
    `endMode auto` lets the element sit the pane BESIDE the list where there is
    room and slide it OVER the list where there is not.
  - Selecting a row (`SelectMessage`) repaints the reading pane and opens the
    drawer; dismissing it (scrim, Escape) reports back through `DrawerChanged`
    so Elm's model cannot drift from the element's own state.
  - An `M3e.Fab` floats bottom-right to compose.

-}

import BackendTask
import Effect exposing (Effect)
import ExampleNav
import Head
import Json.Decode as Decode
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.AppBar
import M3e.Component.AssistChip
import M3e.Component.DrawerContainer
import M3e.Component.Fab
import M3e.Component.ListAction
import M3e.Component.NavItem
import M3e.Component.SearchBar
import M3e.Events
import M3e.Kind
import M3e.Values as Value
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes as TA
import TypedHtml.Grouping
import TypedHtml.Sectioning
import UrlPath exposing (UrlPath)
import View exposing (View)


type alias Model =
    { selected : Int, readerOpen : Bool }


type Msg
    = SelectMessage Int
    | DrawerChanged Bool


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
    ( { selected = 0, readerOpen = False }, Effect.none )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        SelectMessage i ->
            ( { model | selected = i, readerOpen = True }, Effect.none )

        -- The element telling us what it already did -- a scrim click or Escape
        -- closes the drawer without asking Elm first. Syncing here is what keeps
        -- `readerOpen` from drifting out of step with the element, which would
        -- otherwise leave a row selected that opens nothing on the next click.
        DrawerChanged open ->
            ( { model | readerOpen = open }, Effect.none )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    []



-- DATA ------------------------------------------------------------------------


type alias Message =
    { sender : String
    , initials : String
    , subject : String
    , snippet : String
    , body : List String
    , time : String
    , labels : List String
    }


inbox : List Message
inbox =
    [ { sender = "Ali Connors"
      , initials = "AC"
      , subject = "Weekend hiking plans — trail options"
      , snippet = "I mapped out three routes for Saturday. The ridge loop looks best if the weather holds…"
      , body =
            [ "I mapped out three routes for Saturday. The ridge loop looks best if the weather holds — it is about 11 km with a long exposed section near the summit, so bring layers."
            , "The valley trail is the safer fallback: shorter, mostly shaded, and the river crossings are low this time of year. Let me know which you prefer and I will book the trailhead parking."
            ]
      , time = "9:32 AM"
      , labels = [ "Personal", "Travel" ]
      }
    , { sender = "Design team"
      , initials = "DT"
      , subject = "M3 Expressive review notes"
      , snippet = "Great progress on the motion pass. A few notes on the nav rail expansion and FAB placement…"
      , body =
            [ "Great progress on the motion pass. A few notes on the nav rail expansion and FAB placement before we ship the beta."
            , "The rail feels right in compact mode, but the expanded label transition should ease out a touch slower. The compose FAB should stay anchored above the bottom bar on small screens."
            ]
      , time = "8:15 AM"
      , labels = [ "Work" ]
      }
    , { sender = "Ferry Ticketing"
      , initials = "FT"
      , subject = "Your booking is confirmed"
      , snippet = "Booking #48213 is confirmed for the 07:40 sailing. Your boarding pass is attached…"
      , body =
            [ "Booking #48213 is confirmed for the 07:40 sailing on Saturday. Please arrive at the terminal at least 30 minutes before departure."
            , "Your boarding pass is attached to this message. Vehicle deck access closes 10 minutes prior to sailing."
            ]
      , time = "Yesterday"
      , labels = [ "Travel" ]
      }
    , { sender = "Product updates"
      , initials = "PU"
      , subject = "What's new in @m3e/web 2.5"
      , snippet = "This release adds split panes, refreshed search, and expressive elevation tokens…"
      , body =
            [ "This release adds split panes, a refreshed search experience, and expressive elevation tokens across every layer/form role."
            , "Upgrade notes and the full changelog are on the release page. No breaking changes to component slots in this cycle."
            ]
      , time = "Mon"
      , labels = [ "Updates" ]
      }
    , { sender = "Trevor Hansen"
      , initials = "TH"
      , subject = "Re: Rally dashboard mockups"
      , snippet = "Attaching the revised board with the metric cards on top. Thoughts on the chart colors?"
      , body =
            [ "Attaching the revised board with the metric cards moved to the top row. I swapped the donut for a stacked bar so the trend reads at a glance."
            , "Thoughts on the chart colors? I leaned on the tertiary palette to keep the primary reserved for actions."
            ]
      , time = "Sun"
      , labels = [ "Work" ]
      }
    ]


{-| The five navigation destinations, with their Material Symbols icon name.
-}
destinations : List { icon : String, label : String }
destinations =
    [ { icon = "inbox", label = "Inbox" }
    , { icon = "star", label = "Starred" }
    , { icon = "send", label = "Sent" }
    , { icon = "draft", label = "Drafts" }
    , { icon = "report", label = "Spam" }
    ]



-- VIEW ------------------------------------------------------------------------


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view _ _ model =
    View.fromElement "Mail" (M3e.mapMsg PagesMsg.fromMsg (screen model))


{-| The whole screen: full-viewport shell painted onto the base `surface`, with
the nav rail beside a column of AppBar + two-pane body, plus the mobile bottom
bar and the floating compose FAB.

`flex-col md:flex-row`: one shell, two axes. At `md`+ it is a ROW (rail | main
column) and `bottomBar` is `md:hidden`. Below `md` the rail is `hidden` -- so it
takes no flex slot -- and the SAME div is a COLUMN whose in-flow children are,
top to bottom, the main column then the bottom nav bar. That is what lets the
bar stop being `position: fixed`: an in-flow bar cannot occlude the content
above it, so no scroll region here needs a compensating bottom padding to stay
reachable.

`min-h-0` is the column-axis twin of `min-w-0` on the main column, and here it is
load-bearing rather than belt-and-braces: a flex item's default
`min-height: auto` lets that column grow to fit its content instead of its flex
basis. Without it, at 411x761 the column measures 1233px tall and pushes the nav
bar 540px past the bottom of the viewport, where the shell's `overflow-hidden`
clips it away entirely.

`composeFab` is `absolute`, not a flex child, so it keeps floating over the
content in both directions -- which is what the `relative` here anchors.

-}
screen : Model -> Element (TypedHtml.Grouping.DivIs s) adm_ Msg
screen model =
    TypedHtml.div
        [ TA.class "bg-surface text-on-surface relative flex flex-col md:flex-row h-dvh w-full overflow-hidden" ]
        [ navRail
        , TypedHtml.div [ TA.class "flex flex-1 flex-col min-w-0 min-h-0" ]
            [ topBar
            , body model
            ]
        , bottomBar
        , composeFab
        ]


{-| The shared "Built from" + prev/next strip.
-}
exampleFooter : Element (TypedHtml.Grouping.DivIs s) adm_ msg
exampleFooter =
    ExampleNav.footer
        { builtFrom =
            [ ( "appbar", "AppBar" )
            , ( "navrail", "NavRail" )
            , ( "navbar", "NavBar" )
            , ( "searchbar", "SearchBar" )
            , ( "list", "List" )
            , ( "listitem", "ListItem" )
            , ( "divider", "Divider" )
            , ( "fab", "Fab" )
            ]
        , prev = Just ( "/examples/shop", "Shop" )
        , next = Just ( "/examples/travel", "Travel" )
        }



-- NAVIGATION ------------------------------------------------------------------


{-| Desktop navigation rail (hidden below `md:`).
-}
navRail : Element (TypedHtml.Sectioning.NavIs s) adm_ Msg
navRail =
    TypedHtml.nav [ TA.class "hidden md:flex" ]
        [ M3e.navRail [ M3e.Attributes.mode Value.expanded ]
            (List.indexedMap railItem destinations)
        ]


railItem : Int -> { icon : String, label : String } -> Element { s | navItem : M3e.Kind.Brand } adm_ Msg
railItem index d =
    M3e.navItem
        [ M3e.Attributes.selected (index == 0) ]
        [ M3e.Component.NavItem.icon (M3e.icon [ TA.name d.icon ] [])
        , M3e.text d.label
        ]


{-| Mobile bottom navigation bar (hidden at `md:` and up).

The `<nav>` landmark is the REAL last flex child of `screen`'s
`flex flex-col md:flex-row` shell -- it is not `position: fixed` -- so below
`md` it takes its own row at the bottom of the column and cannot occlude
anything above it. `shrink-0` keeps it at its intrinsic height when the column
above wants more room. Keeping the wrapper (rather than a `display: contents`
wrapper around the bar) as the flex child mirrors `navRail`, whose `<nav>` is
likewise the flex child at `md:` and up.

-}
bottomBar : Element (TypedHtml.Sectioning.NavIs s) adm_ Msg
bottomBar =
    TypedHtml.nav [ TA.class "md:hidden shrink-0" ]
        [ M3e.navBar []
            (List.indexedMap barItem destinations)
        ]


barItem : Int -> { icon : String, label : String } -> Element { s | navItem : M3e.Kind.Brand } adm_ Msg
barItem index d =
    M3e.navItem
        [ M3e.Attributes.selected (index == 0) ]
        [ M3e.Component.NavItem.icon (M3e.icon [ TA.name d.icon ] [])
        , M3e.text d.label
        ]



-- TOP BAR ---------------------------------------------------------------------


topBar : Element { s | appBar : M3e.Kind.Brand } adm_ Msg
topBar =
    M3e.appBar [ M3e.Attributes.size Value.medium ]
        [ M3e.Component.AppBar.leading (M3e.icon [ TA.name "menu" ] [])
        , M3e.Component.AppBar.title (M3e.text "Mail")
        , M3e.Component.AppBar.trailing searchBar
        ]


searchBar : Element { s | searchBar : M3e.Kind.Brand } adm_ Msg
searchBar =
    M3e.searchBar
        []
        [ M3e.Component.SearchBar.input
            (TypedHtml.input
                [ TA.placeholder "Search mail"
                , TA.type_ "search"
                ]
                []
            )
        , M3e.Component.SearchBar.leading (M3e.icon [ TA.name "search" ] [])
        ]



-- BODY: TWO-PANE --------------------------------------------------------------


{-| The body: the message list, with the reading pane as a drawer that slides in
from the trailing edge.

This used to be a two-pane split that stacked VERTICALLY below `md:`, and that
was the wrong shape twice over. It halved an already short phone viewport, so
neither the list nor the message was comfortably readable; and before the
`flex-1 min-h-0` fix the list's intrinsic 608px of rows ate the whole column and
the reading pane measured `height: 0` -- present, scrollable in principle, and
completely unreachable. A drawer sidesteps the whole class of problem: the
reading pane is either beside the list or over it, never carved out of it.

`endMode auto` is what makes one markup serve both widths. The element picks
`side` where there is room for the pane to sit BESIDE the list and `over` where
there is not, so the horizontal slide-in is the narrow-width behaviour without
Elm having to know the breakpoint or duplicate the pane.

The list is the ONE scroll region, and `exampleFooter` lives at the bottom of it
rather than pinned under the body -- so the footer is what you reach after
reading the inbox, not a strip permanently spending viewport height.

-}
body : Model -> Element (M3e.Component.DrawerContainer.Is s) adm_ Msg
body model =
    M3e.drawerContainer
        [ M3e.Component.DrawerContainer.endMode Value.auto
        , M3e.Attributes.end model.readerOpen
        , M3e.Events.onChangeWith drawerChangeDecoder
        , TA.class "flex-1 min-h-0 overflow-hidden"
        ]
        [ TypedHtml.section [ TA.class "h-full min-h-0 overflow-y-auto" ]
            [ messageList model
            , exampleFooter
            ]
        , [ readingPane (selectedMessage model) ]
            |> M3e.contentPane [ TA.class "h-full w-full overflow-y-auto md:w-[32rem]" ]
            |> M3e.Component.DrawerContainer.end
        ]


{-| The way back to the inbox.

This is load-bearing, not decoration. Below `md` the drawer opens in `over` mode
at the full width of the viewport, so there is no exposed scrim to click past
it, and the element does not close `end` on Escape. Without an explicit control
the reading pane is a one-way door: measured before this existed, the pane
opened at `left: 0` and neither Escape nor an outside click could dismiss it.

Shown at every width. At `md`+ the pane sits BESIDE the list rather than over
it, where dismissing is a preference rather than a necessity -- but a control
that moves or disappears between widths is worse than one that does not.

-}
closeReader : Element (TypedHtml.Grouping.DivIs s) adm_ Msg
closeReader =
    TypedHtml.div [ TA.class "flex" ]
        [ M3e.iconButton
            [ M3e.Attributes.variant Value.standard
            , Aria.label "Back to inbox"
            , M3e.Events.onClick (DrawerChanged False)
            ]
            [ M3e.icon [ TA.name "arrow_back" ] [] ]
        ]


{-| `event.target.end` is the drawer's reflected open state. Read it from the
element rather than assuming our own last write still holds: the element closes
`end` itself on a scrim click or Escape and does not consult Elm first.
-}
drawerChangeDecoder : Decode.Decoder Msg
drawerChangeDecoder =
    Decode.map DrawerChanged (Decode.at [ "target", "end" ] Decode.bool)


selectedMessage : Model -> Message
selectedMessage model =
    inbox
        |> List.drop model.selected
        |> List.head
        |> Maybe.withDefault (Maybe.withDefault emptyMessage (List.head inbox))


emptyMessage : Message
emptyMessage =
    { sender = "", initials = "", subject = "", snippet = "", body = [], time = "", labels = [] }


{-| The inbox list: one interactive `M3e.ListAction` per message with an avatar,
sender, subject, snippet (supporting text) and timestamp, separated by dividers.
Selecting a row (`onClick`) marks it with a `surfaceContainer` background.
-}
messageList : Model -> Element { s | list : M3e.Kind.Brand } adm_ Msg
messageList model =
    M3e.list []
        (List.intersperse divider
            (List.indexedMap (messageRow model.selected) inbox)
        )


divider : Element { s | divider : M3e.Kind.Brand } adm_ msg
divider =
    M3e.divider [ M3e.Attributes.inset True ] []


messageRow : Int -> Int -> Message -> Element { s | listAction : M3e.Kind.Brand } adm_ Msg
messageRow selected index message =
    let
        rowSurface : String
        rowSurface =
            if index == selected then
                "bg-surface-container text-on-surface"

            else
                "bg-surface text-on-surface"
    in
    M3e.listAction
        [ TA.class rowSurface
        , M3e.Component.ListAction.onClick (SelectMessage index)
        ]
        [ M3e.Component.ListAction.leading (M3e.avatar [] [ M3e.text message.initials ])
        , M3e.Component.ListAction.overline (M3e.text message.sender)
        , M3e.text message.subject
        , M3e.Component.ListAction.supportingText (M3e.text message.snippet)
        , M3e.Component.ListAction.trailing
            (M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.small, TA.class "text-on-surface-variant" ] [ M3e.text message.time ])
        ]



-- READING PANE ----------------------------------------------------------------


{-| The reading pane for the selected message: subject heading, sender row with
avatar and timestamp, label chips, and the body paragraphs — all styled with
M3 token classes applied directly.
-}
readingPane : Message -> Element (TypedHtml.Grouping.DivIs s) adm_ Msg
readingPane message =
    TypedHtml.div [ TA.class "flex flex-col gap-6 p-6" ]
        [ closeReader
        , M3e.heading [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.small, TA.class "text-on-surface" ] [ M3e.text message.subject ]
        , TypedHtml.div [ TA.class "flex items-center gap-3" ]
            [ M3e.avatar [] [ M3e.text message.initials ]
            , TypedHtml.div [ TA.class "flex flex-col" ]
                [ M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium, TA.class "text-on-surface" ] [ M3e.text message.sender ]
                , M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.small, TA.class "text-on-surface-variant" ] [ M3e.text ("to me · " ++ message.time) ]
                ]
            ]
        , M3e.chipSet [ Aria.label "Labels" ]
            (List.map labelChip message.labels)
        , TypedHtml.div [ TA.class "flex flex-col gap-4" ]
            (List.map (\p -> TypedHtml.p [ TA.class "text-body-md text-on-surface-variant" ] [ M3e.text p ]) message.body)
        ]


labelChip : String -> Element { s | assistChip : M3e.Kind.Brand } adm_ msg
labelChip name =
    M3e.assistChip
        []
        [ M3e.text name
        , M3e.Component.AssistChip.icon (M3e.icon [ TA.name "label" ] [])
        ]



-- FAB -------------------------------------------------------------------------


{-| Floating compose action, anchored bottom-right (kept above the mobile bar).

`pointer-events-none` on the positioned wrapper with `pointer-events-auto` on
the FAB is not cosmetic here. Without it the wrapper's box sat over the footer's
next-example link and swallowed the click outright -- Playwright could not
follow "Travel ->" at 411px at all, reporting the FAB subtree as intercepting
pointer events. Only the FAB itself should be clickable; the gutter around it
belongs to whatever is underneath.

-}
composeFab : Element (TypedHtml.Grouping.DivIs s) adm_ msg
composeFab =
    TypedHtml.div [ TA.class "pointer-events-none absolute bottom-20 right-6 md:bottom-6 [&>*]:pointer-events-auto" ]
        [ M3e.fab
            [ M3e.Attributes.variant Value.primaryContainer
            , M3e.Attributes.extended True
            , Aria.label "Compose"
            ]
            [ M3e.icon [ TA.name "edit" ] []
            , M3e.Component.Fab.label (M3e.text "Compose")
            ]
        ]
