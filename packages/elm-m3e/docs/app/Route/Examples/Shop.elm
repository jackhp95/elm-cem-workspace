module Route.Examples.Shop exposing (ActionData, Data, Model, Msg, route)

{-| **Shop** example — a full-viewport Material 3 e-commerce storefront screen,
authored on the M3e API with the m3e component set carrying almost all of the
structure, and M3 token classes (applied directly with
`TypedHtml.Attributes.class`) owning every visual choice. Tailwind is used only
for layout (flex/grid/gap/spacing/positioning and responsive visibility).

Chrome adapts to the viewport: an `M3e.NavRail` on desktop (`hidden md:flex`) and
an `M3e.NavBar` bottom bar on mobile (`md:hidden`), with a top `M3e.AppBar`
carrying the store name and a cart `M3e.IconButton` wearing an `M3e.Badge` with a
live item count. The catalog is filtered by an `M3e.FilterChipSet` toolbar and
laid out as a responsive `M3e.Card` grid; each card has shape-clipped media (via
M3 corner tokens), a name, a price, and an add-to-cart `M3e.IconButton`. An
`M3e.Fab` floats over the content. Interactive local state: the active category
and the cart count.

-}

import BackendTask
import Effect exposing (Effect)
import ExampleNav
import Head
import M3e exposing (Attr, Element)
import M3e.Attributes
import M3e.Component.AppBar
import M3e.Component.Card
import M3e.Component.Fab
import M3e.Component.NavItem
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
import UrlPath exposing (UrlPath)
import View exposing (View)



-- MODEL / MSG -----------------------------------------------------------------


type alias Model =
    { category : String
    , cart : Int
    }


type Msg
    = SetCategory String
    | AddToCart


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
    ( { category = "All", cart = 2 }, Effect.none )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ msg model =
    case msg of
        SetCategory c ->
            ( { model | category = c }, Effect.none )

        AddToCart ->
            ( { model | cart = model.cart + 1 }, Effect.none )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    []



-- CATALOG ---------------------------------------------------------------------


type alias Product =
    { name : String
    , price : String
    , category : String
    , media : String
    , icon : String
    }


products : List Product
products =
    [ { name = "Vagabond sack", price = "$120", category = "Apparel", media = "m3e-filled-card-container-color-primary-container m3e-filled-card-text-color-on-primary-container", icon = "backpack" }
    , { name = "Stella sunglasses", price = "$58", category = "Apparel", media = "m3e-filled-card-container-color-tertiary-container m3e-filled-card-text-color-on-tertiary-container", icon = "eyeglasses" }
    , { name = "Chambray shirt", price = "$70", category = "Apparel", media = "m3e-filled-card-container-color-secondary-container m3e-filled-card-text-color-on-secondary-container", icon = "apparel" }
    , { name = "Gilt desk trio", price = "$58", category = "Home", media = "m3e-filled-card-container-color-secondary-container m3e-filled-card-text-color-on-secondary-container", icon = "table_restaurant" }
    , { name = "Copper wire rack", price = "$44", category = "Home", media = "m3e-filled-card-container-color-primary-container m3e-filled-card-text-color-on-primary-container", icon = "shelves" }
    , { name = "Terracotta vase", price = "$36", category = "Home", media = "m3e-filled-card-container-color-tertiary-container m3e-filled-card-text-color-on-tertiary-container", icon = "potted_plant" }
    , { name = "Rosewater mist", price = "$28", category = "Beauty", media = "m3e-filled-card-container-color-tertiary-container m3e-filled-card-text-color-on-tertiary-container", icon = "spa" }
    , { name = "Velvet lip tint", price = "$22", category = "Beauty", media = "m3e-filled-card-container-color-primary-container m3e-filled-card-text-color-on-primary-container", icon = "brush" }
    ]


categories : List String
categories =
    [ "All", "Apparel", "Home", "Beauty" ]



-- VIEW ------------------------------------------------------------------------


view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view _ _ model =
    let
        shown : List Product
        shown =
            if model.category == "All" then
                products

            else
                List.filter (\p -> p.category == model.category) products
    in
    View.fromElement "Shop"
        -- `flex-col md:flex-row`: one root, two axes. At `md`+ it is a ROW
        -- (rail | main column) and `navBar` is `md:hidden`. Below `md` the rail
        -- is `hidden` -- so it takes no flex slot -- and the SAME div is a
        -- COLUMN whose in-flow children are, top to bottom, the main column then
        -- the bottom nav bar. That is what lets the bar stop being
        -- `position: fixed`: an in-flow bar can't occlude the content above it,
        -- so the content wrapper no longer needs the compensating `pb-24` that
        -- kept the last row of cards clear of a floating bar.
        --
        -- `h-dvh` + `overflow-hidden`, NOT `min-h-screen`. This used to be a
        -- floor rather than a height, which left the root auto-tall and made the
        -- DOCUMENT the scroller -- and an in-flow bar at the bottom of a 4400px
        -- document is only visible once you reach the end of the page, which is
        -- the opposite of what a bottom nav is for. A definite height bounds the
        -- root to the viewport, so the bar stays put and the `overflow-y-auto`
        -- section below is the one scroll region. `h-dvh` (not `h-screen`)
        -- because `100vh` overshoots the visible viewport on mobile browsers
        -- with a retracting URL bar -- which would push an in-flow bar under the
        -- browser chrome, reintroducing by unit exactly the occlusion this
        -- change removes by positioning.
        --
        -- `min-h-0` on the column and the section is the standard guard: a flex
        -- item's default `min-height: auto` would let either grow to fit content
        -- instead of its flex basis, unbounding the scroll region and pushing the
        -- bar off-viewport.
        (TypedHtml.div
            [ TA.class "flex h-dvh w-full flex-col overflow-hidden md:flex-row" ]
            [ navRail model
            , TypedHtml.div [ TA.class "flex min-h-0 min-w-0 flex-1 flex-col" ]
                [ appBar model
                , TypedHtml.section [ TA.class "relative min-h-0 flex-1 overflow-y-auto" ]
                    -- `checkoutFab` is `sticky`, and a sticky element's stick
                    -- range is its CONTAINING BLOCK. Left as a direct child of
                    -- the scroller that block spans the footer too, so the FAB
                    -- never settled back into its own row and sat over the
                    -- prev/next strip at full scroll (measured: FAB 589-669
                    -- across "Mail ->" at 579-595). This wrapper ends where the
                    -- content ends, so the FAB un-sticks and scrolls away as the
                    -- footer arrives -- no z-index fight, no offset tuned to the
                    -- footer's height.
                    [ TypedHtml.div []
                        [ TypedHtml.div [ TA.class "mx-auto flex w-full max-w-6xl flex-col gap-6 p-4 md:p-6" ]
                            [ hero
                            , filterBar model.category
                            , productGrid shown
                            ]
                        , checkoutFab
                        ]
                    , exampleFooter
                    ]
                ]
            , navBar model
            ]
        )


{-| The shared "Built from" + prev/next strip.
-}
exampleFooter : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
exampleFooter =
    ExampleNav.footer
        { builtFrom =
            [ ( "appbar", "AppBar" )
            , ( "navrail", "NavRail" )
            , ( "navbar", "NavBar" )
            , ( "card", "Card" )
            , ( "badge", "Badge" )
            , ( "filterchipset", "FilterChipSet" )
            , ( "fab", "Fab" )
            , ( "iconbutton", "IconButton" )
            ]
        , prev = Just ( "/examples/dashboard", "Dashboard" )
        , next = Just ( "/examples/mail", "Mail" )
        }



-- CHROME ----------------------------------------------------------------------


{-| Top app bar: brand icon in the leading slot, store name in the title slot,
a search + cart action trailing. The cart button wears a Badge showing the live
item count.
-}
appBar : Model -> Element { s | appBar : M3e.Kind.Brand } adm_ (PagesMsg Msg)
appBar model =
    M3e.appBar
        [ TA.class "px-2" ]
        [ M3e.Component.AppBar.leading (M3e.icon [ TA.name "storefront", M3e.Attributes.filled True ] [])
        , M3e.Component.AppBar.title (M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.large ] [ M3e.text "Maru Market" ])
        , M3e.Component.AppBar.trailing (iconAction "search")
        , M3e.Component.AppBar.trailing (cartAction model.cart)
        ]


{-| Cart icon button carrying a Badge with the item count.

`AppBar.TrailingSlot` still does not admit a Badge — the upstream manifest calls
the slot "one or more action buttons", and a Badge is not one. The Badge is only
here because `M3e.Attributes.for` anchors it to `#cart-btn` positionally, so it
has to be _somewhere_ in the DOM nearby.

What changed with RC5 is that the honest fix now type-checks. The slot's config
`"html"` kind used to desugar to M3e's private `Brand`, which nothing produced,
so a native wrapper could not satisfy it and the only way in was a loud
`M3e.Unsafe.recast`. It now desugars to `shared:flow` + `shared:phrasing`, and
`TypedHtml.div` produces `sharedFlow` — so the wrapper goes in as itself, and the
compiler still checks the Badge is legal _inside the div_ rather than being told
to stop looking.

-}
cartAction : Int -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ (PagesMsg Msg)
cartAction count =
    TypedHtml.div
        [ TA.class "inline-flex" ]
        [ M3e.iconButton
            [ M3e.Attributes.id "cart-btn", M3e.Attributes.variant Value.standard, Aria.label "Cart" ]
            [ M3e.icon [ TA.name "shopping_bag" ] [] ]
        , M3e.badge [ M3e.Attributes.for "cart-btn" ] [ M3e.text (String.fromInt count) ]
        ]


{-| Left navigation rail — desktop only.
-}
navRail : Model -> Element { s | navRail : M3e.Kind.Brand } adm_ (PagesMsg Msg)
navRail model =
    M3e.navRail
        [ TA.class "hidden shrink-0 md:flex" ]
        (List.map (railItem model.category) destinations)


{-| Bottom navigation bar — mobile only.

A REAL flex child of the page root (`view`'s `flex flex-col md:flex-row`), not
`position: fixed` — below `md` it takes its own row at the end of the column and
so cannot occlude anything above it. That is what lets the content wrapper drop
the compensating `pb-24` a floating bar would otherwise demand, forever, from
every current and future block that reaches the bottom of the page.

-}
navBar : Model -> Element { s | navBar : M3e.Kind.Brand } adm_ (PagesMsg Msg)
navBar model =
    M3e.navBar
        [ TA.class "shrink-0 md:hidden" ]
        (List.map (barItem model.category) destinations)


type alias Destination =
    { label : String, icon : String, category : Maybe String }


destinations : List Destination
destinations =
    [ { label = "Shop", icon = "storefront", category = Just "All" }
    , { label = "Apparel", icon = "apparel", category = Just "Apparel" }
    , { label = "Wishlist", icon = "favorite", category = Nothing }
    , { label = "Account", icon = "person", category = Nothing }
    ]


railItem : String -> Destination -> Element { s | navItem : M3e.Kind.Brand } adm_ (PagesMsg Msg)
railItem current dest =
    navDestination current dest


barItem : String -> Destination -> Element { s | navItem : M3e.Kind.Brand } adm_ (PagesMsg Msg)
barItem current dest =
    navDestination current dest


navDestination : String -> Destination -> Element { s | navItem : M3e.Kind.Brand } adm_ (PagesMsg Msg)
navDestination current dest =
    let
        attrs : List (Attr { c | selected : M3e.Kind.Supported, onClick : M3e.Kind.Supported } (PagesMsg Msg))
        attrs =
            case dest.category of
                Just cat ->
                    [ M3e.Attributes.selected (cat == current)
                    , M3e.Events.onClick (PagesMsg.fromMsg (SetCategory cat))
                    ]

                Nothing ->
                    [ M3e.Attributes.selected False ]
    in
    M3e.navItem attrs
        [ M3e.Component.NavItem.icon (M3e.icon [ TA.name dest.icon ] [])
        , M3e.text dest.label
        ]



-- CONTENT ---------------------------------------------------------------------


{-| A small welcome banner painted on a container surface.
-}
hero : Element { s | card : M3e.Kind.Brand } adm_ msg
hero =
    M3e.card
        [ M3e.Attributes.variant Value.filled
        , M3e.Attributes.class "m3e-filled-card-container-color-primary-container m3e-filled-card-text-color-on-primary-container m3e-card-shape-md-corner-extra-large"
        ]
        [ M3e.Component.Card.content
            (TypedHtml.div [ TA.class "flex flex-col gap-1 p-6" ]
                [ M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large ] [ M3e.text "New season" ]
                , M3e.heading [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.small ] [ M3e.text "Everyday goods, thoughtfully made" ]
                , TypedHtml.span [] [ M3e.text "Free shipping on orders over $75." ]
                ]
            )
        ]


{-| Category filter toolbar: a single-select FilterChipSet that scrolls
horizontally on narrow screens, plus a sort action.
-}
filterBar : String -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ (PagesMsg Msg)
filterBar current =
    TypedHtml.div [ TA.class "flex items-center gap-2" ]
        [ TypedHtml.div [ TA.class "min-w-0 flex-1 overflow-x-auto" ]
            [ M3e.filterChipSet []
                (List.map (categoryChip current) categories)
            ]
        , iconAction "sort"
        ]


categoryChip : String -> String -> Element { s | filterChip : M3e.Kind.Brand } adm_ (PagesMsg Msg)
categoryChip current cat =
    M3e.filterChip
        [ M3e.Attributes.selected (cat == current)
        , M3e.Events.onClick (PagesMsg.fromMsg (SetCategory cat))
        ]
        [ M3e.text cat ]


{-| Responsive product grid: 1 col on mobile, 2 on small, 3/4 on larger screens.
-}
productGrid : List Product -> Element (TypedHtml.Component.Grouping.DivIs s) adm_ (PagesMsg Msg)
productGrid shown =
    TypedHtml.div [ TA.class "grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4" ]
        (List.map productCard shown)


{-| A product card: shape-clipped media, name, price, add-to-cart action.
-}
productCard : Product -> Element { s | card : M3e.Kind.Brand } adm_ (PagesMsg Msg)
productCard product =
    M3e.card [ M3e.Attributes.variant Value.elevated ]
        [ M3e.Component.Card.header (media product)
        , M3e.Component.Card.content
            (TypedHtml.div [ TA.class "flex flex-col gap-0.5 px-1" ]
                [ M3e.heading [ M3e.Attributes.variant Value.title, M3e.Attributes.size Value.medium ] [ M3e.text product.name ]
                , M3e.heading [ M3e.Attributes.variant Value.label, M3e.Attributes.size Value.large ] [ M3e.text product.category ]
                ]
            )
        , M3e.Component.Card.actions
            (TypedHtml.div [ TA.class "flex w-full items-center justify-between px-1" ]
                [ M3e.heading
                    [ M3e.Attributes.variant Value.title
                    , M3e.Attributes.size Value.large
                    ]
                    [ M3e.text product.price ]
                , M3e.iconButton
                    [ M3e.Attributes.variant Value.tonal, Aria.label "Add to cart", M3e.Events.onClick (PagesMsg.fromMsg AddToCart) ]
                    [ M3e.icon [ TA.name "add_shopping_cart" ] [] ]
                ]
            )
        ]


{-| Placeholder media: a shape-clipped, token-tinted `M3e.card` tile with a
centered glyph. Nested (as the outer card's `header`) rather than a hand-
painted div — `product.media` carries the sanctioned
`m3e-filled-card-container-color-*` / `m3e-filled-card-text-color-*` bridge
utilities instead of raw `bg-*`/`text-*` Tailwind.
-}
media : Product -> Element { s | card : M3e.Kind.Brand } adm_ msg
media product =
    M3e.card
        [ M3e.Attributes.variant Value.filled
        , M3e.Attributes.class (product.media ++ " m3e-card-shape-md-corner-large")
        , TA.class "flex aspect-square items-center justify-center"
        ]
        [ M3e.icon [ TA.name product.icon, M3e.Attributes.opticalSize 48 ] [] ]


{-| A floating checkout action over the content.
-}
checkoutFab : Element (TypedHtml.Component.Grouping.DivIs s) adm_ msg
checkoutFab =
    TypedHtml.div [ TA.class "pointer-events-none sticky bottom-6 flex justify-end pr-2" ]
        [ TypedHtml.div [ TA.class "pointer-events-auto" ]
            [ M3e.fab
                [ M3e.Attributes.variant Value.primary, M3e.Attributes.extended True, Aria.label "Checkout" ]
                [ M3e.icon [ TA.name "shopping_cart_checkout" ] []
                , M3e.Component.Fab.label (M3e.text "Checkout")
                ]
            ]
        ]


{-| A standalone standard icon button used for toolbar actions.
-}
iconAction : String -> Element { s | iconButton : M3e.Kind.Brand } adm_ msg
iconAction icon =
    M3e.iconButton
        [ M3e.Attributes.variant Value.standard, Aria.label icon ]
        [ M3e.icon [ TA.name icon ] [] ]
