module Route.Examples.Settings exposing (ActionData, Data, Model, Msg, route)

{-| **Settings** — a self-contained, full-viewport system settings screen built
almost entirely from `M3e.*` components. It demonstrates adaptive navigation
(a `NavRail` on desktop, a bottom `NavBar` on mobile) around an `AppBar` and a
scrollable, width-constrained column of sectioned preference groups.

Each section is a surface-container card (large corners) with
an overline heading and a run of `ListItem` rows divided by `Divider`s. Trailing
controls are real components: `Switch`es for toggles, a `Radio` group for theme,
a `Slider` for density, and chevron `Icon`s for drill-in rows. Color, type, and
shape all come from the kit; Tailwind is used only for layout.

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
import M3e.Component.ListItem
import M3e.Component.NavItem
import M3e.Component.SliderThumb
import M3e.Events
import M3e.Kind
import M3e.Values as Value
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes as TA
import TypedHtml.Component.Grouping
import TypedHtml.Kind
import UrlPath exposing (UrlPath)
import View exposing (View)



-- MODEL -----------------------------------------------------------------------


{-| `section` and `theme` are held as `String` ids rather than custom types: the
`NoMissingTypeExpose` review rule would require any custom type reachable from
this exposed `Model` alias to be exposed too (the same reason `RouteParams` is
suppressed for every route). Keeping them as strings keeps the module's public
API to what elm-pages needs. The screen is presentational, so the ids are just
selection markers.
-}
type alias Model =
    { section : String
    , push : Bool
    , email : Bool
    , sms : Bool
    , analytics : Bool
    , crashReports : Bool
    , personalized : Bool
    , theme : String
    }


type Toggle
    = Push
    | Email
    | Sms
    | Analytics
    | CrashReports
    | Personalized


type Msg
    = SelectSection String
    | Flip Toggle
    | SetTheme String



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
    ( { section = "general"
      , push = True
      , email = True
      , sms = False
      , analytics = False
      , crashReports = True
      , personalized = True
      , theme = "system"
      }
    , Effect.none
    )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        SelectSection section ->
            ( { model | section = section }, Effect.none )

        SetTheme theme ->
            ( { model | theme = theme }, Effect.none )

        Flip toggle ->
            ( flip toggle model, Effect.none )


flip : Toggle -> Model -> Model
flip toggle model =
    case toggle of
        Push ->
            { model | push = not model.push }

        Email ->
            { model | email = not model.email }

        Sms ->
            { model | sms = not model.sms }

        Analytics ->
            { model | analytics = not model.analytics }

        CrashReports ->
            { model | crashReports = not model.crashReports }

        Personalized ->
            { model | personalized = not model.personalized }


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    []



-- VIEW ------------------------------------------------------------------------


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view _ _ model =
    View.fromElement "Settings" (screen model)


{-| The full-viewport shell: a desktop nav rail beside a main column, with a
mobile bottom bar. `h-dvh`/`overflow-hidden` pin the chrome so only the
content column scrolls.

`flex-col md:flex-row`: one shell, two axes. At `md`+ it is a ROW
(rail | main column) and `mobileBar` is `md:hidden`. Below `md` the rail is
`hidden` -- so it takes no flex slot -- and the SAME div is a COLUMN whose
in-flow children are, top to bottom, the main column then the bottom nav bar.
That is what lets the bar stop being `position: fixed`: an in-flow bar can't
occlude the content above it, so the content column needs no compensating
`pb-24` to keep its last row (and `exampleFooter`) reachable.

`min-h-0` is the column-axis guard: a flex item's default `min-height: auto`
would let the main column grow to fit its content instead of its flex basis,
pushing the nav bar off the bottom of the viewport. Belt-and-braces today (the
column's own `overflow-hidden` already suppresses the automatic minimum size),
but it keeps the bounded-scroll invariant from depending on that.

-}
screen : Model -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ (PagesMsg Msg)
screen model =
    TypedHtml.div
        [ TA.class "flex flex-col md:flex-row h-dvh w-full overflow-hidden" ]
        [ desktopRail model.section
        , TypedHtml.div [ TA.class "flex flex-1 flex-col min-h-0 overflow-hidden" ]
            [ appBar
            , TypedHtml.div [ TA.class "flex-1 overflow-y-auto" ]
                [ TypedHtml.div [ TA.class "mx-auto w-full max-w-2xl flex flex-col gap-6 px-4 py-6" ]
                    (content model)
                , exampleFooter
                ]
            ]
        , mobileBar model.section
        ]


{-| The shared "Built from" + prev/next strip. Settings is the last example, so
it has no next screen.
-}
exampleFooter : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
exampleFooter =
    ExampleNav.footer
        { builtFrom =
            [ ( "appbar", "AppBar" )
            , ( "navrail", "NavRail" )
            , ( "navbar", "NavBar" )
            , ( "listitem", "ListItem" )
            , ( "switch", "Switch" )
            , ( "radio", "Radio" )
            , ( "slider", "Slider" )
            , ( "divider", "Divider" )
            ]
        , prev = Just ( "/examples/travel", "Travel" )
        , next = Just ( "/examples/list-detail", "List-detail" )
        }


appBar : Element { s | appBar : M3e.Kind.Brand } adm_ msg
appBar =
    M3e.appBar [ M3e.Attributes.size Value.medium ]
        [ M3e.Component.AppBar.leading (M3e.icon [ TA.name "menu" ] [])
        , M3e.Component.AppBar.title (M3e.text "Settings")
        ]



-- NAVIGATION ------------------------------------------------------------------


sections : List ( String, String, String )
sections =
    [ ( "general", "General", "tune" )
    , ( "account", "Account", "account_circle" )
    , ( "notifications", "Notifications", "notifications" )
    , ( "privacy", "Privacy", "shield" )
    , ( "about", "About", "info" )
    ]


{-| Desktop navigation rail — hidden below the `md` breakpoint.
-}
desktopRail : String -> Element { s | navRail : M3e.Kind.Brand } adm_ (PagesMsg Msg)
desktopRail current =
    M3e.navRail [ TA.class "hidden md:flex shrink-0" ]
        (List.map (navItem current) sections)


{-| Mobile bottom navigation bar — hidden at `md` and up.

The bar is a REAL flex child of `screen`'s outer `flex flex-col md:flex-row`,
not `position: fixed` — so on mobile it takes its own row at the bottom of the
column and stays put while the content column scrolls beside it, without
occluding anything. That is what lets the content column skip the compensating
`pb-24` a floating bar would otherwise demand of every scroll region.

-}
mobileBar : String -> Element { s | navBar : M3e.Kind.Brand } adm_ (PagesMsg Msg)
mobileBar current =
    M3e.navBar [ TA.class "md:hidden shrink-0" ]
        (List.map (navItem current) sections)


navItem : String -> ( String, String, String ) -> Element { s | navItem : M3e.Kind.Brand } adm_ (PagesMsg Msg)
navItem current ( section, name, iconName ) =
    M3e.navItem
        [ M3e.Attributes.selected (section == current)
        , M3e.Events.onClick (PagesMsg.fromMsg (SelectSection section))
        ]
        [ M3e.Component.NavItem.icon (M3e.icon [ TA.name iconName ] [])
        , M3e.text name
        ]



-- CONTENT ---------------------------------------------------------------------


{-| The element kind a card row can be. `ListItem` rows carry `listItem`, the
interleaved `Divider`s carry `divider`, and a few rows nest raw layout (`html`);
they must share ONE type to live in a single list, so `Row` names the union of
every field any row needs. Each producing function's `view` returns an open row,
which widens to fill this closed record.
-}
type alias Row msg =
    Element { sharedFlow : TypedHtml.Kind.Shared, listItem : M3e.Kind.Brand, divider : M3e.Kind.Brand } (TypedHtml.Component.Grouping.DivChildAdmittedBy {}) msg


content : Model -> List (Element (TypedHtml.Component.Grouping.DivIs s) adm_ (PagesMsg Msg))
content model =
    [ accountCard
    , sectionCard "Notifications"
        [ switchRow "notifications" "Push notifications" "Alerts on this device" model.push (Flip Push)
        , switchRow "mail" "Email updates" "Product news and receipts" model.email (Flip Email)
        , switchRow "sms" "SMS alerts" "Security codes and reminders" model.sms (Flip Sms)
        ]
    , sectionCard "Appearance"
        [ themeRow "light" "Light" "light_mode" model.theme
        , themeRow "dark" "Dark" "dark_mode" model.theme
        , themeRow "system" "System" "brightness_auto" model.theme
        , densityRow
        ]
    , sectionCard "Privacy"
        [ switchRow "analytics" "Usage analytics" "Share anonymous usage data" model.analytics (Flip Analytics)
        , switchRow "bug_report" "Crash reports" "Send diagnostics after a crash" model.crashReports (Flip CrashReports)
        , switchRow "recommend" "Personalized content" "Tailor suggestions to you" model.personalized (Flip Personalized)
        ]
    , sectionCard "About"
        [ linkRow "description" "Terms of Service" "Last updated May 2026"
        , linkRow "policy" "Privacy Policy" "How we handle your data"
        , infoRow "verified" "Version" "3.0.1 (build 4021)"
        ]
    ]


{-| A settings section: an overline heading above a rounded card grouping the
section's `ListItem` rows.
-}
sectionCard : String -> List (Row msg) -> Element (TypedHtml.Component.Grouping.DivIs s) admOut_ msg
sectionCard heading rows =
    TypedHtml.div [ TA.class "flex flex-col gap-2" ]
        [ Doc.sectionLabelCaps heading
        , groupedCard rows
        ]


{-| A card grouping a column of `ListItem` rows, separated by `Divider`s so the
group reads as a single section.
-}
groupedCard : List (Row msg) -> Element { s | card : M3e.Kind.Brand } adm_ msg
groupedCard rows =
    M3e.card
        [ M3e.Attributes.variant Value.filled
        , M3e.Attributes.class "m3e-card-shape-md-corner-large"
        ]
        [ M3e.Component.Card.content
            (TypedHtml.div [ TA.class "flex flex-col" ] (dividize rows))
        ]


{-| Interleave `Divider`s between rows so groups read as one card.
-}
dividize : List (Row msg) -> List (Row msg)
dividize rows =
    List.intersperse (M3e.divider [ M3e.Attributes.inset True ] []) rows


{-| The account header: a profile card (avatar + name + email) followed by a
drill-in row for managing the account.
-}
accountCard : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
accountCard =
    TypedHtml.div [ TA.class "flex flex-col gap-2" ]
        [ Doc.sectionLabelCaps "Account"
        , groupedCard
            [ M3e.listItem []
                [ M3e.Component.ListItem.leading (M3e.avatar [] [ M3e.text "JD" ])
                , M3e.text "Jane Doe"
                , M3e.Component.ListItem.supportingText (M3e.text "jane@example.com")
                , M3e.Component.ListItem.trailing (M3e.icon [ TA.name "chevron_right" ] [])
                ]
            , linkRow "manage_accounts" "Manage account" "Password, 2FA, connected apps"
            , linkRow "sync" "Sync & backup" "Last synced 2 minutes ago"
            ]
        ]


{-| A toggle row: leading icon, label + supporting text, trailing `Switch`.
-}
switchRow : String -> String -> String -> Bool -> Msg -> Row (PagesMsg Msg)
switchRow iconName label supporting on toggle =
    M3e.listItem []
        [ M3e.Component.ListItem.leading (M3e.icon [ TA.name iconName ] [])
        , M3e.text label
        , M3e.Component.ListItem.supportingText (M3e.text supporting)
        , M3e.Component.ListItem.trailing
            (M3e.switch
                [ Aria.label label
                , M3e.Attributes.checked on
                , M3e.Events.onClick (PagesMsg.fromMsg toggle)
                ]
                []
            )
        ]


{-| A theme-choice row backed by a `Radio` (single group via shared `name`).
-}
themeRow : String -> String -> String -> String -> Row (PagesMsg Msg)
themeRow theme label iconName current =
    M3e.listItem []
        [ M3e.Component.ListItem.leading (M3e.icon [ TA.name iconName ] [])
        , M3e.text label
        , M3e.Component.ListItem.trailing
            (M3e.radio
                [ Aria.label label
                , TA.name "theme"
                , M3e.Attributes.value theme
                , M3e.Attributes.checked (theme == current)
                , M3e.Events.onClick (PagesMsg.fromMsg (SetTheme theme))
                ]
                []
            )
        ]


{-| A density row whose control is a full-width `Slider`. A `Slider` is not list
supporting-text, so this row is a plain layout (leading icon + label above the
slider) rather than a `ListItem` with the control crammed into a text slot.
-}
densityRow : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
densityRow =
    TypedHtml.div [ TA.class "flex flex-col gap-3 px-4 py-3" ]
        [ TypedHtml.div [ TA.class "flex items-center gap-4" ]
            [ M3e.icon [ TA.name "density_medium" ] []
            , M3e.text "Display density"
            ]
        , M3e.slider
            [ M3e.Attributes.min 0
            , M3e.Attributes.max 3
            , M3e.Attributes.step 1
            , M3e.Attributes.discrete True
            , M3e.Attributes.labelled True
            , Aria.label "Display density"
            , TA.class "w-full"
            ]
            [ M3e.sliderThumb [ M3e.Component.SliderThumb.value 2 ] [] ]
        ]


{-| A drill-in row: label + supporting text with a trailing chevron.
-}
linkRow : String -> String -> String -> Row msg
linkRow iconName label supporting =
    M3e.listItem []
        [ M3e.Component.ListItem.leading (M3e.icon [ TA.name iconName ] [])
        , M3e.text label
        , M3e.Component.ListItem.supportingText (M3e.text supporting)
        , M3e.Component.ListItem.trailing (M3e.icon [ TA.name "chevron_right" ] [])
        ]


{-| A static info row: label with a trailing value tinted as a variant.
-}
infoRow : String -> String -> String -> Row msg
infoRow iconName label value =
    M3e.listItem []
        [ M3e.Component.ListItem.leading (M3e.icon [ TA.name iconName ] [])
        , M3e.text label
        , M3e.Component.ListItem.trailing
            (M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large ] [ M3e.text value ])
        ]
