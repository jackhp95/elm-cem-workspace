module Route.Examples.ListDetail exposing (ActionData, Data, Model, Msg, route)

{-| **List-detail** — the canonical Material 3 adaptive list-detail (master-detail)
pattern, built as a self-contained contacts screen. It is the worked reference the
`composing-m3e-layouts` skill points at for this pattern.

The body reflows by window size class. On `md:` and up it is two panes side by side:
a fixed-width `M3e.List` of contacts (`md:w-80`) beside a filling detail pane. Below
`md:` the two collapse into one column — the list is full-width and the selected
contact's detail stacks beneath it — the standard compact fallback for list-detail.

Navigation switches the same way every example does: an `M3e.NavRail` on desktop
(`hidden md:flex`), an `M3e.NavBar` at the bottom on mobile (`md:hidden shrink-0`,
a real in-flow flex child of the screen's `flex-col md:flex-row` root rather than a
`position: fixed` overlay), one shared destination list and one `navItem` producer
so the two copies never drift.

Tailwind is layout only (flex/grid/gap/padding/positioning/responsive visibility);
every visual token — color, typography, surface, shape — comes from M3 token
classes applied directly with `TypedHtml.Attributes.class`.

-}

import BackendTask
import Effect exposing (Effect)
import ExampleNav
import Head
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.AppBar
import M3e.Component.ListAction
import M3e.Component.ListItem
import M3e.Component.NavItem
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
    { selected : Int }


type Msg
    = SelectContact Int



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
    ( { selected = 0 }, Effect.none )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        SelectContact i ->
            ( { model | selected = i }, Effect.none )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    []



-- DATA ------------------------------------------------------------------------


type alias Contact =
    { name : String
    , initials : String
    , role : String
    , email : String
    , phone : String
    , note : String
    }


contacts : List Contact
contacts =
    [ { name = "Ali Connors", initials = "AC", role = "Product designer", email = "ali@example.com", phone = "+1 555 0142", note = "Leads the M3 Expressive motion pass. Prefers async updates." }
    , { name = "Trevor Hansen", initials = "TH", role = "Data analyst", email = "trevor@example.com", phone = "+1 555 0198", note = "Owns the rally dashboard. Ping before 3pm for chart reviews." }
    , { name = "Sandra Adams", initials = "SA", role = "Engineering lead", email = "sandra@example.com", phone = "+1 555 0110", note = "Reviews the component library PRs. Two-week release cadence." }
    , { name = "Britta Holt", initials = "BH", role = "Content strategist", email = "britta@example.com", phone = "+1 555 0176", note = "Writes the release notes and the guide prose." }
    , { name = "Miriam Steketee", initials = "MS", role = "Accessibility", email = "miriam@example.com", phone = "+1 555 0155", note = "Runs the a11y-tree spot-checks each cycle." }
    ]


{-| The four navigation destinations, with their Material Symbols icon name.
-}
destinations : List { icon : String, label : String }
destinations =
    [ { icon = "contacts", label = "Contacts" }
    , { icon = "groups", label = "Teams" }
    , { icon = "star", label = "Favorites" }
    , { icon = "history", label = "Recent" }
    ]



-- VIEW ------------------------------------------------------------------------


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view _ _ model =
    View.fromElement "List-detail" (M3e.mapMsg PagesMsg.fromMsg (screen model))


{-| The full-viewport shell. `h-dvh`/`overflow-hidden` pin the chrome so only
the panes scroll.

`flex-col md:flex-row` is one shell serving two axes. At `md:` and up it is a ROW
— rail on the left, then the column of AppBar + two-pane body — and `mobileBar`
is `md:hidden`. Below `md:` the rail is `hidden`, so it takes no flex slot, and
the SAME div is a COLUMN whose in-flow children are, top to bottom, that main
column then the bottom nav bar. That is what lets the bar stop being
`position: fixed`: an in-flow bar cannot occlude the content above it, so neither
pane — nor any scroll region added here later — needs a compensating bottom
padding to stay fully reachable.

`min-h-0` is the column-axis twin of `min-w-0` on the main column: a flex item's
default `min-height: auto` would let that column grow to fit its content instead
of its flex basis, pushing the nav bar off the bottom of the viewport and turning
the DOCUMENT into the scroller. `overflow-hidden` already forces the same `0`
today; `min-h-0` states it directly so the invariant does not hinge on the
overflow class staying put.

-}
screen : Model -> Element (TypedHtml.Grouping.DivIs s) adm_ Msg
screen model =
    TypedHtml.div
        [ TA.class "bg-surface text-on-surface flex flex-col md:flex-row h-dvh w-full overflow-hidden" ]
        [ desktopRail
        , TypedHtml.div [ TA.class "flex flex-1 flex-col min-w-0 min-h-0 overflow-hidden" ]
            [ appBar
            , body model
            , exampleFooter
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
            , ( "list", "List" )
            , ( "listitem", "ListItem" )
            , ( "divider", "Divider" )
            , ( "avatar", "Avatar" )
            ]
        , prev = Just ( "/examples/settings", "Settings" )
        , next = Just ( "/examples/supporting-pane", "Supporting pane" )
        }


appBar : Element { s | appBar : M3e.Kind.Brand } adm_ msg
appBar =
    M3e.appBar []
        [ M3e.Component.AppBar.title (M3e.text "Contacts") ]



-- TWO-PANE BODY ---------------------------------------------------------------


{-| The reflowing list-detail body. `flex-1 flex-col md:flex-row` is the whole
adaptivity: a single column on compact (list, then detail beneath), two panes on
`md:` and up (a fixed `md:w-80` list beside a filling detail). Both panes scroll
independently.
-}
body : Model -> Element (TypedHtml.Grouping.DivIs s) adm_ Msg
body model =
    TypedHtml.div [ TA.class "flex flex-1 flex-col overflow-hidden md:flex-row" ]
        [ listPane model.selected
        , detailPane (selectedContact model.selected)
        ]


{-| The master list — full-width on compact, a fixed rail on `md:`.
-}
listPane : Int -> Element (TypedHtml.Grouping.DivIs s) adm_ Msg
listPane selected =
    TypedHtml.div [ TA.class "min-h-0 flex-1 overflow-y-auto border-outline-variant/40 md:w-80 md:flex-none md:shrink-0 md:border-r" ]
        [ M3e.list []
            (List.intersperse (M3e.divider [ M3e.Attributes.inset True ] [])
                (List.indexedMap (contactRow selected) contacts)
            )
        ]


{-| One row — the selected row swaps to surfaceContainer so the active item reads
against the base surface.
-}
contactRow : Int -> Int -> Contact -> Element { s | listAction : M3e.Kind.Brand } adm_ Msg
contactRow selected index contact =
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
        , M3e.Component.ListAction.onClick (SelectContact index)
        ]
        [ M3e.Component.ListAction.leading (M3e.avatar [] [ M3e.text contact.initials ])
        , M3e.text contact.name
        , M3e.Component.ListAction.supportingText (M3e.text contact.role)
        ]


{-| The detail pane — fills the rest on `md:`, stacks beneath the list on compact.
-}
detailPane : Contact -> Element (TypedHtml.Grouping.DivIs s) adm_ msg
detailPane contact =
    TypedHtml.div [ TA.class "min-h-0 flex-1 overflow-y-auto p-4 md:p-8" ]
        [ TypedHtml.div [ TA.class "mx-auto flex w-full max-w-xl flex-col gap-6" ]
            [ header contact
            , detailCard contact
            ]
        ]


header : Contact -> Element (TypedHtml.Grouping.DivIs s) adm_ msg
header contact =
    TypedHtml.div [ TA.class "flex flex-col items-center gap-3 pt-2" ]
        [ M3e.avatar [] [ M3e.text contact.initials ]
        , M3e.heading [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.small, TA.class "text-on-surface" ] [ M3e.text contact.name ]
        , TypedHtml.span [ TA.class "text-body-lg text-on-surface-variant" ] [ M3e.text contact.role ]
        ]


{-| The contact's fields, as a surface-container card of divided rows.
-}
detailCard : Contact -> Element { s | list : M3e.Kind.Brand } adm_ msg
detailCard contact =
    M3e.list
        [ TA.class "bg-surface-container text-on-surface rounded-md-corner-large overflow-hidden"
        ]
        (List.intersperse (M3e.divider [ M3e.Attributes.inset True ] [])
            [ fieldRow "mail" "Email" contact.email
            , fieldRow "call" "Phone" contact.phone
            , fieldRow "sticky_note_2" "Note" contact.note
            ]
        )


fieldRow : String -> String -> String -> Element { s | listItem : M3e.Kind.Brand } adm_ msg
fieldRow iconName label value =
    M3e.listItem []
        [ M3e.Component.ListItem.leading (M3e.icon [ TA.name iconName ] [])
        , M3e.text label
        , M3e.Component.ListItem.supportingText (M3e.text value)
        ]


selectedContact : Int -> Contact
selectedContact index =
    contacts
        |> List.drop index
        |> List.head
        |> Maybe.withDefault fallbackContact


fallbackContact : Contact
fallbackContact =
    { name = "No contact", initials = "?", role = "", email = "", phone = "", note = "" }



-- NAVIGATION ------------------------------------------------------------------


desktopRail : Element { s | navRail : M3e.Kind.Brand } adm_ msg
desktopRail =
    M3e.navRail [ TA.class "hidden md:flex shrink-0" ]
        (List.map navItem destinations)


{-| Mobile: the bottom nav bar, replacing the rail below `md:`. It is a REAL last
flex child of `screen`'s `flex-col md:flex-row` root, not a `fixed` overlay, so it
takes its own row at the bottom of the column and cannot occlude the panes above.
-}
mobileBar : Element { s | navBar : M3e.Kind.Brand } adm_ msg
mobileBar =
    M3e.navBar [ TA.class "md:hidden shrink-0" ]
        (List.map navItem destinations)


navItem : { icon : String, label : String } -> Element { s | navItem : M3e.Kind.Brand } adm_ msg
navItem d =
    M3e.navItem
        [ M3e.Attributes.selected (d.label == "Contacts") ]
        [ M3e.Component.NavItem.icon (M3e.icon [ TA.name d.icon ] [])
        , M3e.text d.label
        ]
