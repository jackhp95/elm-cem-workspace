module Route.Examples.DetailedView exposing (ActionData, Data, Model, Msg, route)

{-| **Detailed view** — a single Material 3 mobile "detailed view" screen: a
media item's full detail page, reconstructing the Figma M3 Community Kit's
"Examples/Detailed view-Mobile" frame as a Figma-to-Elm round-trip proof for
`cem-figma-connect`.

Unlike the other `/examples/*` routes this is a fixed-width MOBILE mock, not an
adaptive multi-breakpoint app — the Figma frame itself is a single phone
screen, so there is no `md:`/`lg:` reflow and no nav rail↔nav bar switch. The
screen is a phone-width column (`max-w-sm`) centered on the page: a plain
status bar and a plain gesture bar (both device chrome with no Material
equivalent) bookend a real `M3e.AppBar`, a header, two lorem-ipsum body
paragraphs, a `Section` of three `ListItem`s, and a compact media player card.

Tailwind is layout only (flex/grid/gap/padding/sizing/positioning); every
visual token — color, typography, surface, shape — comes from M3 components
(`Heading`, `ListItem`'s `supportingText` slot, …) or `m3e-<component>-*`
bridge token classes (`m3e-card-shape-md-corner-large`,
`m3e-filled-card-container-color-primary-container`) applied directly with
`TypedHtml.Attributes.class` — never a generic Tailwind color/type-scale
utility (this workspace has none; only per-component bridge classes exist).

-}

import BackendTask
import ExampleNav
import Head
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.AppBar
import M3e.Component.Button
import M3e.Component.Card
import M3e.Component.Icon
import M3e.Component.LinearProgressIndicator
import M3e.Component.ListItem
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



-- ROUTE -----------------------------------------------------------------------


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



-- VIEW ------------------------------------------------------------------------


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Detailed view" screen


{-| The phone-width shell. `max-w-sm mx-auto` is the whole "mobile mock"
device: a fixed-width column centered on the page rather than a full-viewport
adaptive layout, since the Figma source is one phone frame, not a responsive
app. `statusBar`/`gestureBar` bookend the real content the same way the phone
chrome bookends the frame in Figma; only the scrollable middle grows.
-}
screen : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
screen =
    TypedHtml.div [ TA.class "mx-auto flex h-dvh w-full max-w-sm flex-col overflow-hidden" ]
        [ statusBar
        , appBar
        , TypedHtml.div [ TA.class "flex flex-1 flex-col gap-6 overflow-y-auto p-4" ]
            [ header
            , bodyText
            , section
            , mediaPlayer
            , exampleFooter
            ]
        , gestureBar
        ]


exampleFooter : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
exampleFooter =
    ExampleNav.footer
        { builtFrom =
            [ ( "appbar", "AppBar" )
            , ( "heading", "Heading" )
            , ( "button", "Button" )
            , ( "iconbutton", "IconButton" )
            , ( "card", "Card" )
            , ( "list", "List" )
            , ( "listitem", "ListItem" )
            , ( "progress", "LinearProgressIndicator" )
            ]
        , prev = Just ( "/examples/feed", "Feed" )
        , next = Nothing
        }



-- DEVICE CHROME -----------------------------------------------------------
--
-- The status bar and gesture bar are phone chrome, not part of the Material
-- design system, so they stay plain `TypedHtml` markup — the one place bare
-- markup is the right call rather than a fallback. Even so, their glyphs go
-- through the real `M3e.icon`/Icon component (Material Symbols already covers
-- wifi/signal/battery/camera) and the gesture handle reuses the real
-- `M3e.divider`; nothing here paints a raw color or shape utility.


statusBar : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
statusBar =
    TypedHtml.div [ TA.class "relative flex shrink-0 items-center justify-between px-6 pt-3 pb-1" ]
        [ TypedHtml.span [] [ M3e.text "9:30" ]
        , TypedHtml.div [ TA.class "absolute inset-x-0 top-2 flex justify-center" ]
            [ M3e.icon [ TA.name "camera", M3e.Component.Icon.opticalSize 16 ] [] ]
        , TypedHtml.div [ TA.class "flex items-center gap-1" ]
            [ M3e.icon [ TA.name "signal_cellular_alt" ] []
            , M3e.icon [ TA.name "wifi" ] []
            , M3e.icon [ TA.name "battery_full" ] []
            ]
        ]


{-| The bottom home-indicator handle. A real `M3e.divider`, sized down to a
short pill-width bar via layout classes only — no hand-painted fill/shape.
-}
gestureBar : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
gestureBar =
    TypedHtml.div [ TA.class "flex shrink-0 justify-center py-2" ]
        [ M3e.divider [ TA.class "w-8" ] [] ]



-- APP BAR -------------------------------------------------------------------


appBar : Element { s | appBar : M3e.Kind.Brand } adm_ msg
appBar =
    M3e.appBar []
        [ M3e.Component.AppBar.leading (backButton "Back")
        , M3e.Component.AppBar.title (M3e.text "Label")
        , M3e.Component.AppBar.trailing (appBarIcon "bookmark" "Bookmark")
        , M3e.Component.AppBar.trailing (appBarIcon "more_vert" "More")
        ]


backButton : String -> Element { s | iconButton : M3e.Kind.Brand } adm_ msg
backButton label =
    M3e.iconButton [ Aria.label label ] [ M3e.icon [ TA.name "arrow_back" ] [] ]


appBarIcon : String -> String -> Element { s | iconButton : M3e.Kind.Brand } adm_ msg
appBarIcon iconName label =
    M3e.iconButton [ Aria.label label ] [ M3e.icon [ TA.name iconName ] [] ]



-- HEADER ----------------------------------------------------------------------


{-| The thumbnail + headline + supporting text + action, as a plain
`TypedHtml.div` row (matching `ListDetail.elm`'s `header` precedent: a bare
row of components, not a `Card` — this is page-level header content sitting
directly on the screen background, not a bounded surface). 136×136 leading
thumbnail (`w-34 h-34` = 136px at the 4px Tailwind spacing step), a headline,
supporting text, and a filled `Download` button.
-}
header : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
header =
    TypedHtml.div [ TA.class "flex items-start gap-4" ]
        [ thumbnail "w-34 h-34 shrink-0" "m3e-card-shape-md-corner-large"
        , TypedHtml.div [ TA.class "flex flex-1 flex-col items-start gap-2 pt-1" ]
            [ M3e.heading [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.small ] [ M3e.text "Headline" ]
            , TypedHtml.span [] [ M3e.text "supporting text" ]
            , downloadButton
            ]
        ]


downloadButton : Element { s | button : M3e.Kind.Brand } adm_ msg
downloadButton =
    M3e.button
        [ M3e.Attributes.variant Value.filled ]
        [ M3e.Component.Button.icon (M3e.icon [ TA.name "download" ] [])
        , M3e.text "Download"
        ]


{-| A placeholder media tile: a tinted, token-backed `M3e.card` standing in
for a real photo — the same precedent `Travel.elm`'s `media` function
established (`m3e-filled-card-container-color-*` tint + an `image` icon),
reused here for every thumbnail on this screen (header, list items, media
player) at three different sizes.
-}
thumbnail : String -> String -> Element { s | card : M3e.Kind.Brand } adm_ msg
thumbnail sizeClasses shapeClass =
    M3e.card
        [ M3e.Attributes.variant Value.filled
        , M3e.Attributes.class ("m3e-filled-card-container-color-primary-container " ++ shapeClass)
        , TA.class (sizeClasses ++ " flex items-center justify-center")
        ]
        [ M3e.icon [ TA.name "image" ] [] ]


{-| Same placeholder-media idea as `thumbnail`, but shaped for a `ListItem`
`leading` slot: that slot's kind row admits `sharedFlow`/`sharedIcon`
content, not `card` (an `M3e.card` is its own distinct kind and is not
admitted there), so this stays a bare `TypedHtml.div` — sized/centered with
layout classes only, no painted color or shape — wrapping the same real
`M3e.icon` glyph.
-}
thumbnailIcon : String -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
thumbnailIcon sizeClasses =
    TypedHtml.div [ TA.class (sizeClasses ++ " flex items-center justify-center") ]
        [ M3e.icon [ TA.name "image" ] [] ]



-- BODY TEXT -------------------------------------------------------------------


{-| The published-date label and two lorem-ipsum paragraphs. No `Heading`
role applies to body copy (`Heading` only carries display/headline/title/label,
never body), and this exact node was confirmed (during the Code Connect
mapping pass) to have no Material component of its own — so this follows the
plain-text precedent `ListDetail.elm`/`Travel.elm`/`SupportingPane.elm` already
use for non-heading text: a bare, CLASSLESS `TypedHtml` element. There is no
generic `text-body-md`/`text-on-surface-variant` Tailwind utility in this
workspace (only per-component `m3e-<component>-*` bridge classes exist,
see `packages/tailwind-m3e-web/generated/utilities.json`) — every other
example's plain body/caption text stays classless and inherits the page's
own default body type from the docs shell, and this does the same.
-}
bodyText : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
bodyText =
    TypedHtml.div [ TA.class "flex flex-col gap-2" ]
        [ M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large ] [ M3e.text "Published date" ]
        , TypedHtml.p []
            [ M3e.text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat." ]
        , TypedHtml.p []
            [ M3e.text "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." ]
        ]



-- SECTION -----------------------------------------------------------------


section : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
section =
    TypedHtml.div [ TA.class "flex flex-col gap-2" ]
        [ TypedHtml.div [ TA.class "flex items-center justify-between" ]
            [ M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.large ] [ M3e.text "Section title" ]
            , M3e.iconButton [ Aria.label "Star" ] [ M3e.icon [ TA.name "star" ] [] ]
            ]
        , M3e.list [] (List.map sectionItem [ 1, 2, 3 ])
        ]


{-| One repeated section row: 120×120 leading thumbnail, a `title-large`
headline, a `body-medium`/`on-surface-variant` description, a leading-icon
"Today • 23 min" meta row folded into the `supportingText` slot (a real
`sharedFlow` div, per `ListItem`'s own admitted content), and a trailing
filled `play_arrow` icon. The trailing icon stays a bare `M3e.icon`
(`sharedIcon`) rather than an `M3e.iconButton`: `ListItem`'s `TrailingSlot`
admits `avatar`/`checkbox`/`heading`/`radio`/`switch`/`sharedFlow`/`sharedIcon`/
`sharedPhrasing`/`sharedText` — never an icon-button's own `iconButton` kind
(confirmed against `M3e.Internal.Types.ListItem` and every other example's
`ListItem.trailing`/`leading` usage, all of which pass bare icons/avatars,
never a nested button).
-}
sectionItem : Int -> Element { s | listItem : M3e.Kind.Brand } adm_ msg
sectionItem _ =
    M3e.listItem []
        [ M3e.Component.ListItem.leading (thumbnailIcon "w-30 h-30 shrink-0")
        , M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.large ] [ M3e.text "Title" ]
        , M3e.Component.ListItem.supportingText
            (TypedHtml.div [ TA.class "flex flex-col gap-1" ]
                [ TypedHtml.span []
                    [ M3e.text "Description duis aute irure dolor in reprehenderit in voluptate velit." ]
                , metaRow
                ]
            )
        , M3e.Component.ListItem.trailing
            (M3e.icon [ TA.name "play_arrow", M3e.Component.Icon.filled True ] [])
        ]


{-| "Today • 23 min", nested inside `supportingText` above — the slot's own
CSS already renders `body-medium`/`on-surface-variant` and cascades that down
to unstyled children, so these spans stay classless rather than repainting
a type role by hand.
-}
metaRow : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
metaRow =
    TypedHtml.div [ TA.class "flex items-center gap-1" ]
        [ M3e.icon [ TA.name "add_circle" ] []
        , TypedHtml.span [] [ M3e.text "Today" ]
        , TypedHtml.span [] [ M3e.text "•" ]
        , TypedHtml.span [] [ M3e.text "23 min" ]
        ]



-- COMPACT MEDIA PLAYER --------------------------------------------------------


{-| A compact media player: a determinate `LinearProgressIndicator` (real
component, `defaultValue` so the ~20% fill SERIALIZES into the static markup
instead of relying on a live DOM property nothing sets on first paint) across
the top edge, then a row of a 64×64 thumbnail, title/artist text, and
transport `IconButton`s. `w-full` on the progress bar is explicit so it fills
the card instead of collapsing to its intrinsic (near-zero) width.
-}
mediaPlayer : Element { s | card : M3e.Kind.Brand } adm_ msg
mediaPlayer =
    M3e.card
        [ M3e.Attributes.variant Value.filled
        , M3e.Attributes.class "m3e-card-shape-md-corner-large"
        ]
        [ M3e.Component.Card.header
            (M3e.linearProgressIndicator
                [ M3e.Component.LinearProgressIndicator.defaultValue 20
                , M3e.Attributes.max 100
                , TA.class "block w-full"
                ]
                []
            )
        , M3e.Component.Card.content playerRow
        ]


{-| The thumbnail/title/artist/transport row. Unlike `sectionItem` this is a
plain `TypedHtml.div` rather than an `M3e.listItem`: the transport controls
are genuine `M3e.iconButton`s (per the spec — "pause icon-button", "skip\_next
icon-button (filled)"), and `ListItem`'s `TrailingSlot` cannot host an
icon-button (see `sectionItem`'s note) — so the row is composed directly,
the same way `Dashboard.elm`/`Travel.elm` build bespoke rows outside a `List`
when their content doesn't fit a named-slot component. "Artist" still stays
a classless span (no size/color role applies outside a real component here).
-}
playerRow : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
playerRow =
    TypedHtml.div [ TA.class "flex items-center gap-3 p-3" ]
        [ thumbnailIcon "w-16 h-16 shrink-0"
        , TypedHtml.div [ TA.class "flex flex-1 flex-col min-w-0" ]
            [ M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium ] [ M3e.text "Title" ]
            , TypedHtml.span [] [ M3e.text "Artist" ]
            ]
        , M3e.iconButton [ Aria.label "Pause" ] [ M3e.icon [ TA.name "pause" ] [] ]
        , M3e.iconButton
            [ M3e.Attributes.variant Value.filled, Aria.label "Skip next" ]
            [ M3e.icon [ TA.name "skip_next" ] [] ]
        ]
