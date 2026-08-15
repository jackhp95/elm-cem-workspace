module Route.Examples.Travel exposing (ActionData, Category, Data, Dest, Model, Msg, route)

{-| **Travel** — a trip-planning browser in the spirit of Google Trips / Airbnb /
Material Crane. A self-contained, full-viewport app screen with its own nav chrome:

  - Adaptive navigation: an `M3e.NavRail` on desktop (`hidden md:flex`) and an
    `M3e.NavBar` bottom bar on mobile (`md:hidden`), plus a top `M3e.AppBar`.
  - A search HERO built from `M3e.SearchBar`, sitting in a tinted, large-cornered
    panel — a plain `TypedHtml.div` carrying `bg-surface-container` and a corner
    token.
  - Category `M3e.Tabs` (Flights / Stays / Experiences) driving the content.
  - Horizontally-scrolling destination RAILS (`flex gap-4 overflow-x-auto`) of
    `M3e.Card` items with shape-clipped media, a name, an `M3e.AssistChip` rating,
    and a price.

Local state drives the active nav destination and the active category tab. All
color / typography / shape come from M3 token classes applied directly with
`TypedHtml.Attributes.class`; Tailwind is used only for layout (flex / grid / gap
/ padding / responsive visibility).

-}

import BackendTask
import Doc.Slider
import Effect exposing (Effect)
import ExampleNav
import Head
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.AppBar
import M3e.Component.AssistChip
import M3e.Component.Card
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
import TypedHtml.Component.Grouping
import TypedHtml.Component.Sectioning
import UrlPath exposing (UrlPath)
import View exposing (View)



-- MODEL


type alias Model =
    { destination : Dest
    , category : Category
    }


{-| Top-level app destinations, mirrored across the rail and the bottom bar.
-}
type Dest
    = Explore
    | Trips
    | Saved
    | Profile


{-| The category tab that selects which sort of trip we are browsing.
-}
type Category
    = Flights
    | Stays
    | Experiences


type Msg
    = SetDest Dest
    | SetCategory Category


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
    ( { destination = Explore, category = Stays }, Effect.none )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        SetDest d ->
            ( { model | destination = d }, Effect.none )

        SetCategory c ->
            ( { model | category = c }, Effect.none )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    []



-- DATA


{-| A destination card: (name, region, tint classes, rating, price).
-}
type alias Place =
    { name : String
    , region : String
    , tint : String
    , rating : String
    , price : String
    }


{-| Popular destinations vary by the active category.
-}
popular : Category -> List Place
popular category =
    case category of
        Flights ->
            [ Place "Tokyo" "Japan" "bg-primary-container text-on-primary-container" "4.9" "$780"
            , Place "Reykjavík" "Iceland" "bg-secondary-container text-on-secondary-container" "4.8" "$610"
            , Place "Cape Town" "South Africa" "bg-tertiary-container text-on-tertiary-container" "4.7" "$920"
            , Place "Lima" "Peru" "bg-primary-container text-on-primary-container" "4.6" "$540"
            ]

        Stays ->
            [ Place "Kyoto" "Japan" "bg-secondary-container text-on-secondary-container" "4.9" "$240/nt"
            , Place "Santorini" "Greece" "bg-tertiary-container text-on-tertiary-container" "4.8" "$310/nt"
            , Place "Marrakesh" "Morocco" "bg-primary-container text-on-primary-container" "4.7" "$180/nt"
            , Place "Queenstown" "New Zealand" "bg-secondary-container text-on-secondary-container" "4.8" "$220/nt"
            ]

        Experiences ->
            [ Place "Aurora Hunt" "Tromsø" "bg-tertiary-container text-on-tertiary-container" "4.9" "$95"
            , Place "Souk Food Tour" "Fez" "bg-primary-container text-on-primary-container" "4.8" "$45"
            , Place "Caldera Sail" "Oia" "bg-secondary-container text-on-secondary-container" "4.7" "$120"
            , Place "Temple at Dawn" "Bagan" "bg-tertiary-container text-on-tertiary-container" "4.9" "$60"
            ]


{-| A second, static "Nearby getaways" rail for variety.
-}
nearby : List Place
nearby =
    [ Place "Lisbon" "Portugal" "bg-secondary-container text-on-secondary-container" "4.7" "$150/nt"
    , Place "Oaxaca" "Mexico" "bg-primary-container text-on-primary-container" "4.8" "$130/nt"
    , Place "Bologna" "Italy" "bg-tertiary-container text-on-tertiary-container" "4.6" "$170/nt"
    , Place "Porto" "Portugal" "bg-secondary-container text-on-secondary-container" "4.7" "$140/nt"
    ]


categories : List ( Category, String )
categories =
    [ ( Flights, "Flights" )
    , ( Stays, "Stays" )
    , ( Experiences, "Experiences" )
    ]


destinations : List ( Dest, String, String )
destinations =
    [ ( Explore, "explore", "Explore" )
    , ( Trips, "luggage", "Trips" )
    , ( Saved, "favorite", "Saved" )
    , ( Profile, "person", "Profile" )
    ]



-- VIEW


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view _ _ model =
    View.fromElement "Travel" (shell model)


{-| Full-viewport chrome: a top app bar, a rail-or-main body, and a bottom bar
that only appears on small screens.
-}
shell : Model -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ (PagesMsg Msg)
shell model =
    TypedHtml.div [ TA.class "flex h-dvh w-full flex-col" ]
        [ appBar
        , TypedHtml.div [ TA.class "flex min-h-0 flex-1" ]
            [ navRail model.destination
            , TypedHtml.section [ TA.class "min-w-0 flex-1 overflow-y-auto" ]
                [ content model
                , exampleFooter
                ]
            ]
        , navBar model.destination
        ]


{-| The shared "Built from" + prev/next strip.
-}
exampleFooter : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
exampleFooter =
    ExampleNav.footer
        { builtFrom =
            [ ( "appbar", "AppBar" )
            , ( "navrail", "NavRail" )
            , ( "navbar", "NavBar" )
            , ( "searchbar", "SearchBar" )
            , ( "tabs", "Tabs" )
            , ( "tab", "Tab" )
            , ( "card", "Card" )
            , ( "assistchip", "AssistChip" )
            ]
        , prev = Just ( "/examples/mail", "Mail" )
        , next = Just ( "/examples/settings", "Settings" )
        }


appBar : Element { s | appBar : M3e.Kind.Brand } adm_ (PagesMsg Msg)
appBar =
    M3e.appBar []
        [ M3e.Component.AppBar.leading (M3e.icon [ TA.name "public" ] [])
        , M3e.Component.AppBar.title (M3e.text "Wander")
        , M3e.Component.AppBar.trailing
            (M3e.iconButton
                [ M3e.Attributes.variant Value.standard, Aria.label "Notifications" ]
                [ M3e.icon [ TA.name "notifications" ] [] ]
            )
        ]



-- NAVIGATION


{-| The desktop navigation rail, hidden below the `md` breakpoint.
-}
navRail : Dest -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ (PagesMsg Msg)
navRail current =
    TypedHtml.div [ TA.class "hidden md:flex" ]
        [ M3e.navRail []
            (List.map (railItem current) destinations)
        ]


railItem : Dest -> ( Dest, String, String ) -> Element { s | navItem : M3e.Kind.Brand } adm_ (PagesMsg Msg)
railItem current ( dest, iconName, label ) =
    M3e.navItem
        [ M3e.Attributes.selected (dest == current)
        , M3e.Events.onClick (PagesMsg.fromMsg (SetDest dest))
        ]
        [ M3e.Component.NavItem.icon (M3e.icon [ TA.name iconName ] [])
        , M3e.text label
        ]


{-| The mobile bottom navigation bar, hidden at and above the `md` breakpoint.
-}
navBar : Dest -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ (PagesMsg Msg)
navBar current =
    TypedHtml.div [ TA.class "md:hidden" ]
        [ M3e.navBar []
            (List.map (barItem current) destinations)
        ]


barItem : Dest -> ( Dest, String, String ) -> Element { s | navItem : M3e.Kind.Brand } adm_ (PagesMsg Msg)
barItem current ( dest, iconName, label ) =
    M3e.navItem
        [ M3e.Attributes.selected (dest == current)
        , M3e.Events.onClick (PagesMsg.fromMsg (SetDest dest))
        ]
        [ M3e.Component.NavItem.icon (M3e.icon [ TA.name iconName ] [])
        , M3e.text label
        ]



-- CONTENT


content : Model -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ (PagesMsg Msg)
content model =
    TypedHtml.div [ TA.class "flex flex-col gap-8 p-4 md:p-8" ]
        [ hero
        , categoryTabs model.category
        , popularRails model.category
        , rail "Nearby getaways" nearby
        ]


{-| The category-driven "Popular destinations" rail, sliding between categories.
Reuses `Doc.Slider.slidingPanels` (the same helper the API code toggle
uses): every category's rail is mounted in the track, and switching the category
tab slides the prior rail out and the new one in. The static "Nearby getaways"
rail below is category-independent and stays put.
-}
popularRails : Category -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ (PagesMsg Msg)
popularRails current =
    Doc.Slider.slidingPanels
        (categoryIndex current)
        (List.map (\( c, _ ) -> rail "Popular destinations" (popular c)) categories)


{-| The 0-based position of the active category within `categories` — the rail
`slidingPanels` translates into view.
-}
categoryIndex : Category -> Int
categoryIndex current =
    categories
        |> List.map Tuple.first
        |> List.indexedMap Tuple.pair
        |> List.filter (\( _, c ) -> c == current)
        |> List.head
        |> Maybe.map Tuple.first
        |> Maybe.withDefault 0


{-| A search hero: a headline over a `SearchBar`, wrapped in a tinted,
extra-large-cornered panel — a plain `TypedHtml.div` carrying
`bg-surface-container` and `rounded-md-corner-extra-large`.
-}
hero : Element (TypedHtml.Component.Grouping.DivIs s) adm_ (PagesMsg Msg)
hero =
    TypedHtml.div
        [ TA.class "bg-surface-container text-on-surface rounded-md-corner-extra-large flex flex-col gap-4 p-6 md:p-8" ]
        [ M3e.heading [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.small ] [ M3e.text "Where to next?" ]
        , TypedHtml.span [ TA.class "text-body-md text-on-surface-variant" ] [ M3e.text "Search destinations, dates, and guests." ]
        , searchBar
        ]


searchBar : Element { s | html : M3e.Kind.Brand, searchBar : M3e.Kind.Brand } adm_ (PagesMsg Msg)
searchBar =
    M3e.searchBar
        []
        [ M3e.Component.SearchBar.input (TypedHtml.input [] [])
        , M3e.Component.SearchBar.leading (M3e.icon [ TA.name "search" ] [])
        , M3e.Component.SearchBar.trailing (M3e.icon [ TA.name "tune" ] [])
        ]


{-| Category tabs (Flights / Stays / Experiences) that reselect the rails' data.
-}
categoryTabs : Category -> Element { s | tabs : M3e.Kind.Brand } adm_ (PagesMsg Msg)
categoryTabs current =
    M3e.tabs []
        (List.map (categoryTab current) categories)


categoryTab : Category -> ( Category, String ) -> Element { s | tab : M3e.Kind.Brand } adm_ (PagesMsg Msg)
categoryTab current ( category, label ) =
    M3e.tab
        [ M3e.Attributes.selected (category == current)
        , M3e.Events.onClick (PagesMsg.fromMsg (SetCategory category))
        ]
        [ M3e.text label ]



-- RAILS


{-| A titled, horizontally-scrolling strip of destination cards.
-}
rail : String -> List Place -> Element (TypedHtml.Component.Sectioning.SectionIs s) adm_ (PagesMsg Msg)
rail heading places =
    TypedHtml.section [ TA.class "flex flex-col gap-4" ]
        [ M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.large ] [ M3e.text heading ]
        , TypedHtml.div [ TA.class "flex gap-4 overflow-x-auto pb-2" ]
            (List.map placeCard places)
        ]


{-| One destination card: shape-clipped tinted media, name + region, a rating
`AssistChip` with a star, and a price. Fixed width so cards line up in the rail.
-}
placeCard : Place -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ (PagesMsg Msg)
placeCard place =
    TypedHtml.div [ TA.class "w-56 shrink-0" ]
        [ M3e.card [ M3e.Attributes.variant Value.elevated ]
            [ M3e.Component.Card.header (media place)
            , M3e.Component.Card.content
                (TypedHtml.div [ TA.class "flex flex-col gap-2" ]
                    [ M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium ] [ M3e.text place.name ]
                    , TypedHtml.span [ TA.class "text-body-sm text-on-surface-variant" ] [ M3e.text place.region ]
                    , TypedHtml.div [ TA.class "flex items-center justify-between" ]
                        [ ratingChip place.rating
                        , M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large, TA.class "text-primary" ] [ M3e.text place.price ]
                        ]
                    ]
                )
            ]
        ]


{-| Placeholder media: a tinted card-media block standing in for a destination photo.
-}
media : Place -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
media place =
    TypedHtml.div
        [ TA.class (place.tint ++ " rounded-md-corner-large overflow-hidden flex h-28 w-full items-end p-3") ]
        [ M3e.icon [ TA.name "image" ] [] ]


ratingChip : String -> Element { s | assistChip : M3e.Kind.Brand } adm_ (PagesMsg Msg)
ratingChip rating =
    M3e.assistChip
        []
        [ M3e.text rating
        , M3e.Component.AssistChip.icon (M3e.icon [ TA.name "star", M3e.Attributes.filled True ] [])
        ]
