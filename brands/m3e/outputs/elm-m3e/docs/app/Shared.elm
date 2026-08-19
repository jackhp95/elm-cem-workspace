module Shared exposing (Data, Model, Msg, NavComponent, SearchEntry, componentCategories, template)

{-| The M3 application shell that frames every docs route.

Owns the single `<m3e-theme>` for the whole app. Navigation is split across
three surfaces:

  - **Top-level sections** (Start, Guide, Styles, Examples, Components) live
    in a persistent `M3e.NavRail` down the left edge on desktop, swapped for a
    fixed-bottom `M3e.NavBar` on mobile (`docsNavRail`/`docsNavBar`, Tailwind
    `md:` swap at 768px).
  - **The current section's page tree** lives in the `start` slot of an
    `M3e.DrawerContainer` below the app bar (`navMenu`), pinned open on
    desktop and toggled from the app bar's hamburger on narrow screens. It
    shows only the CURRENT section's items (`currentSectionItems`) — the rail
    already says which section you're in, so the tree doesn't repeat it.
  - **The current page's table of contents** auto-discovers the page's
    headings at render time (`M3e.Toc`, in `tocPanel`) and lives in the same
    container's `end` slot, pinned open on wide screens and toggled from the
    app bar's "On this page" button otherwise.

Above them sits a real `M3e.AppBar` top app bar; the live theme controls are in
a settings bottom sheet toggled from it. Every icon goes through `M3e.Icon`;
every action through `M3e.IconButton`; every theme control through
`M3e.SegmentedButton`.

Both drawer panels' open state is genuinely model-owned (`treeOpen`/`tocOpen`)
rather than recomputed per render — see `drawerSideBreakpointPx` for why that
distinction is load-bearing.

The scheme/contrast/direction state is held as generated `Value` tokens — there is
no local shadow union — so `M3e.Theme` takes the model field directly and the
settings controls render from the generated `<enum>Values` lists. Every
constructor is `Module.component [attrs] [content]`.

-}

import BackendTask exposing (BackendTask)
import Browser.Events
import Doc.Data
import Doc.Usage
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Html exposing (Html)
import HtmlIr.Element
import Http
import Json.Decode as Decode
import Logo
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.AppBar
import M3e.Component.BottomSheet
import M3e.Component.BottomSheetTrigger
import M3e.Component.DrawerContainer
import M3e.Component.ExpansionPanel
import M3e.Component.Fab
import M3e.Component.Icon
import M3e.Component.IconButton
import M3e.Component.NavItem
import M3e.Component.NavMenuItem
import M3e.Component.NavRailToggle
import M3e.Component.SearchView
import M3e.Component.Theme
import M3e.Component.Toc
import M3e.Events
import M3e.Kind
import M3e.Unsafe
import M3e.Values as Value exposing (Value)
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import Ports
import Process
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import Task
import Theme
import Theme.Fonts
import Theme.Ports
import Theme.Presets
import Theme.Sections.Advanced
import Theme.Sections.Appearance
import Theme.Sections.Color
import Theme.Sections.CssVariables
import Theme.Sections.Shape
import Theme.Sections.Typography
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes
import TypedHtml.Component.Grouping
import TypedHtml.Component.Sectioning
import TypedHtml.Events
import TypedHtml.Values
import UrlPath exposing (UrlPath)
import View exposing (View)


template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Just (\_ -> PageChanged)
    }



-- MODEL


type alias Model =
    { treeOpen : Bool
    , tocOpen : Bool
    , viewportWidth : Int
    , theme : Theme.Model
    , dir : TypedHtml.Values.Value TypedHtml.Values.Dir
    , searchOpen : Bool
    , searchViewOpen : Bool
    , searchQuery : String
    , searchIndex : Maybe (Result Http.Error (List SearchEntry))

    -- The site-wide API-layer tab selection shared by every Usage example and
    -- every component page's API section. It lives HERE, not in a route's local
    -- model, so it survives client-side navigation between component pages;
    -- localStorage (via `Theme.Ports.storeSurface`/`readSurface`) survives a
    -- reload. Routes only read it and forward tab clicks to the store port.
    , activeSurface : Doc.Usage.Surface
    }


{-| One search-index entry: either a whole page (`heading = Nothing`) or one
heading inside it. Built by `docs/scripts/search-index-gen/build-search-index.mjs`
from the rendered `dist/**/index.html` -- titles and headings only, no body
text (see `specs/2026-08-07-nav-rail-search-design.md`). Fetched at
`/search-index.json` on the first search-view `query` event, not eagerly on
app boot.
-}
type alias SearchEntry =
    { url : String
    , title : String
    , heading : Maybe String
    , anchor : Maybe String
    }


searchEntryDecoder : Decode.Decoder SearchEntry
searchEntryDecoder =
    Decode.map4 SearchEntry
        (Decode.field "url" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.field "heading" (Decode.nullable Decode.string))
        (Decode.field "anchor" (Decode.nullable Decode.string))


searchEntryListDecoder : Decode.Decoder (List SearchEntry)
searchEntryListDecoder =
    Decode.list searchEntryDecoder


{-| One drawer-nav component, derived from `data/reference.json`: the entries
that `config/categories.json` gives a category (so they appear in the drawer),
each carrying its editorial `label` and `category` for grouping.
-}
type alias NavComponent =
    { slug : String, label : String, category : String }


{-| The shared data every route sees: the derived component-nav list. Read once
from `reference.json` (the single source), so the drawer, the `/components/all`
grouping, and the home-page count can never drift from the catalogue again.
-}
type alias Data =
    { components : List NavComponent }


{-| The width at or above which `DrawerContainer`'s `auto` mode keeps a panel
in `side` (pinned, content-shrinking) rather than `push`/`over` (overlaying,
scrim-dismissable).

**This number is not ours to pick.** It is `Breakpoint.Medium`'s
`(min-width: 960px)` in `@m3e/web/dist/core-layout.js`, which
`_updateMode` in `@m3e/web/dist/drawer-container.js` observes. Elm has to
mirror it because the panels' open state is a Lit property, not CSS state:
Elm decides whether a panel starts pinned open, and the element decides how a
pinned panel is drawn. Elm used to say 768 while the element said 960, and
every width in between was a trap: the element auto-CLOSED the panel and said
so via its `change` event, but Elm's open state was a formula
(`not (isMobile model) || model.showMenu`) that still evaluated to the same
constant `True`, so the virtual-DOM diff emitted no patch and the panel stayed
shut for good — no later tap and no later resize could reopen it.

Hence both halves of the fix: this constant matches the element's, AND the open
state is now a plain model field (`treeOpen`/`tocOpen`) rendered directly, so it
cannot collapse into a constant again.

This is deliberately NOT the Tailwind `md` breakpoint (768px), which
independently controls the `docsNavRail`/`docsNavBar` swap in pure CSS and
needs no Elm state at all.

-}
drawerSideBreakpointPx : Int
drawerSideBreakpointPx =
    960


{-| The width at or above which the TOC panel is ALSO pinned open beside the
tree, instead of being one-at-a-time with it.

Derived from the layout budget rather than from a Material breakpoint: the
rail is fixed `expanded` (`docsNavRail`) at 220px and each drawer panel is
`--m3e-drawer-container-width` = 14rem = 224px (set in `drawerShell`), so both
panels open costs 220 + 224 + 224 = 668px of chrome. At 1200px that still
leaves ~532px of readable content; below it, pinning both would crush the
content pane, so below this width `panelsExclusive` lets only one panel be
open at a time.

-}
tocPinBreakpointPx : Int
tocPinBreakpointPx =
    1200


{-| The width below which the search overlay runs in **fullscreen** mode
instead of **docked**.

Not a layout choice of ours: this is `@m3e/web`'s own `Breakpoint.XSmall`
(`max-width: 599.98px`) restated in Elm, because `searchOverlay` drives
`mode` explicitly rather than letting the element pick — see `searchModeFor`.
Keep it equal to that breakpoint; a mismatch would only mean the overlay
renders in the mode we asked for at a width the element would have chosen
differently, which is harmless but confusing.

-}
searchFullscreenBreakpointPx : Int
searchFullscreenBreakpointPx =
    600


{-| The `mode` to hand `m3e-search-view` at this width.

The element ships a `mode="auto"` that computes exactly this itself, and we
deliberately do NOT use it. `auto` installs an `M3eBreakpointObserver` in
`willUpdate`, and its callback fires ONCE on install with the real match:

    const currentMode = this.currentMode;             // "docked" (the default)
    this._mode = matches.get(Breakpoint.XSmall) ? "fullscreen" : "docked";
    if (currentMode !== this._mode && this.open) {
        this.open = false;                            // no `toggle` event!
    }

Since `searchOverlay` mounts the element already `open`, below 600px that
callback flips `open` back to `false` on the very first render — and it does
so WITHOUT dispatching `toggle`, so `searchToggleDecoder` never fires and
`model.searchOpen` stays `True` forever. The panel never opens, and every
later FAB tap is a no-op (no model change -> no re-render -> the element is
never asked to open again). Passing a non-`auto` mode takes the
`this._mode = undefined; updateMode()` branch instead, which installs no
observer at all, so there is no race to lose.

`model.viewportWidth` is already maintained by the `Browser.Events.onResize`
subscription, so a resize across the breakpoint re-renders with the other
mode — the element's `willUpdate` then closes the overlay on a genuine mode
CHANGE, which does route through `updated`/`toggle` and stays in sync.

-}
searchModeFor : Int -> Value M3e.Component.SearchView.Mode
searchModeFor width =
    if width < searchFullscreenBreakpointPx then
        Value.fullscreen

    else
        Value.docked


{-| Does this route render the docs shell at all?

`/examples/*` pages render bare (`view` short-circuits to `View.body`) so the
example owns the whole viewport. Nothing shell-shaped exists on those routes:
no rail, no bottom bar, no FAB — and no `searchOverlay`, since that is mounted
inside the same branch. `subscriptions` reads this too, so the Cmd/Ctrl+K port
cannot set `searchOpen = True` on a route with nothing to show for it (which
would then pop the overlay open unrequested on the NEXT navigation).

`docs/index.ts` mirrors this prefix check before it calls `preventDefault()`,
so on `/examples/*` the browser keeps its own Cmd/Ctrl+K instead of having it
swallowed for no visible effect.

-}
hasDocsShell : UrlPath -> Bool
hasDocsShell path =
    not (String.startsWith "/examples/" (UrlPath.toAbsolute path))


{-| Is the page tree pinned open at this width? Also the default it is restored
to on a route change or on growing past the breakpoint.
-}
treePinsOpen : Int -> Bool
treePinsOpen width =
    width >= drawerSideBreakpointPx


{-| Is the TOC pinned open at this width? (Only relevant on a page that opted
into a TOC — `drawerShell` still gates the `end` slot on non-empty entries.)
-}
tocPinsOpen : Int -> Bool
tocPinsOpen width =
    width >= tocPinBreakpointPx


{-| May only ONE of the two panels be open at this width?

Below `drawerSideBreakpointPx` this is forced on us: `DrawerContainer.willUpdate`
force-closes `start` when `end` opens (and vice versa) whenever the other panel
is not in `side` mode — and it does so WITHOUT dispatching a `change` event, so
Elm cannot learn about it after the fact and has to apply the same rule in its
own handlers or its model silently drifts from the element's.

Between `drawerSideBreakpointPx` and `tocPinBreakpointPx` the element would
happily hold both open, but there is not enough room for a readable content
column, so we enforce exclusivity ourselves. Elm being STRICTER than the
element is safe: it closes the other panel in the same update, so the element
never sees the both-open state it would have corrected.

-}
panelsExclusive : Int -> Bool
panelsExclusive width =
    not (tocPinsOpen width)


type Msg
    = ToggleTree
    | PageChanged
    | DrawerChanged Bool Bool
    | ViewportResized Int
    | ToggleToc
    | CloseToc
    | OpenSearch
    | RevealSearch
    | CloseSearch
    | SetSearchQuery String
    | GotSearchIndex (Result Http.Error (List SearchEntry))
    | ThemeMsg Theme.Msg
    | SetDirection (TypedHtml.Values.Value TypedHtml.Values.Dir)
    | ResetControlRow
    | PresetRequested String
    | SurfaceLoaded Decode.Value


init :
    Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : UrlPath
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Effect Msg )
init flags _ =
    let
        width : Int
        width =
            initialViewportWidth flags
    in
    ( { treeOpen = treePinsOpen width
      , tocOpen = tocPinsOpen width
      , viewportWidth = width
      , theme = Theme.init
      , dir = TypedHtml.Values.ltr
      , searchOpen = False
      , searchViewOpen = False
      , searchQuery = ""
      , searchIndex = Nothing
      , activeSurface = Doc.Usage.Top
      }
      -- Load every reel card's specimen-subset webfont once at boot (§D6). The
      -- reel appears in both the settings drawer AND the Welcome page, and Shared
      -- hosts the whole app shell above both, so this is the single seam that
      -- serves both placements without making the pure `Theme.Reel` view impure.
      -- Each card sets its own inline `font-family`; this loads the font FILES so
      -- those families resolve instead of falling back to sans-serif.
    , Effect.fromCmd
        (Theme.Ports.loadSpecimenFonts
            (Theme.Fonts.specimenSubsetUrls Theme.Presets.presets)
        )
    )


{-| Open or close the page tree, applying the tree/TOC mutual exclusion
`panelsExclusive` describes. Opening the tree can close the TOC; closing it
never touches the TOC.
-}
setTreeOpen : Bool -> Model -> Model
setTreeOpen open model =
    { model
        | treeOpen = open
        , tocOpen = model.tocOpen && not (open && panelsExclusive model.viewportWidth)
    }


{-| `setTreeOpen`'s mirror image for the TOC panel.
-}
setTocOpen : Bool -> Model -> Model
setTocOpen open model =
    { model
        | tocOpen = open
        , treeOpen = model.treeOpen && not (open && panelsExclusive model.viewportWidth)
    }


{-| Record a new viewport width, re-pinning each panel to its default when — and
only when — the resize CROSSED that panel's breakpoint.

Crossing-only, rather than recomputing from the width every time, is what keeps
an explicit toggle sticky: a user who closes the pinned tree at 1440px keeps it
closed while nudging the window to 1500px. Crossing back up is what makes the
old "stuck closed forever" failure recoverable at all — the `subscriptions`
comment has always promised this; before, `ViewportResized` only stored the
width.

Both defaults are routed through `setTreeOpen`/`setTocOpen` so that widening
from mobile — where the user may have had the TOC open — into the 960-1199 band
cannot leave both panels open at once.

-}
resizeTo : Int -> Model -> Model
resizeTo width model =
    let
        resized : Model
        resized =
            { model | viewportWidth = width }

        afterTree : Model
        afterTree =
            if treePinsOpen width /= treePinsOpen model.viewportWidth then
                setTreeOpen (treePinsOpen width) resized

            else
                resized
    in
    if tocPinsOpen width /= tocPinsOpen model.viewportWidth then
        setTocOpen (tocPinsOpen width) afterTree

    else
        afterTree


{-| Read `flags.width` (passed by docs/index.ts on the client). Falls back to
a desktop-leaning width so server-rendered HTML defaults to the side drawer.
-}
initialViewportWidth : Pages.Flags.Flags -> Int
initialViewportWidth flags =
    case flags of
        Pages.Flags.BrowserFlags raw ->
            Decode.decodeValue (Decode.field "width" Decode.int) raw
                |> Result.withDefault 1024

        Pages.Flags.PreRenderFlags ->
            1024


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ToggleTree ->
            ( setTreeOpen (not model.treeOpen) model, Effect.none )

        -- A route change re-pins both panels to their width's default: closed
        -- on a narrow screen (so a mobile overlay can't survive the navigation
        -- it triggered), open where they belong pinned. `update` cannot see the
        -- INCOMING page's TOC entries, so `tocOpen` is set optimistically and
        -- `drawerShell` still gates the `end` slot on non-empty entries.
        --
        -- The search overlay is that same kind of overlay, at every width, so
        -- it closes unconditionally. Its query is cleared with it: the overlay
        -- is unmounted while closed, so a surviving `searchQuery` would only
        -- reappear pre-filled on the NEXT open, stale by a whole navigation.
        -- (`searchIndex` is deliberately kept — it's an immutable fetched
        -- cache, not overlay state, and dropping it would refetch per page.)
        PageChanged ->
            ( { model
                | treeOpen = treePinsOpen model.viewportWidth
                , tocOpen = tocPinsOpen model.viewportWidth
                , searchOpen = False
                , searchViewOpen = False
                , searchQuery = ""
              }
            , Effect.none
            )

        -- The `<m3e-drawer-container>` `change` event reports the element's own
        -- `start`/`end` open state (scrim click, Esc, breakpoint auto-close — a
        -- scrim click closes BOTH sides in one event, per `_handleScrimClick` in
        -- `@m3e/web/dist/drawer-container.js`). Synced from both here so an
        -- element-driven close can't desync Elm (which would need a double-tap of
        -- `ToggleTree`/`ToggleToc` to reopen — the first tap would just be
        -- computing the state the element is already in). `event.target.start`/
        -- `.end` are the reflected boolean properties read by `drawerChangeDecoder`.
        --
        -- NOTE this is the element telling us what it already did, so it is the
        -- one place that assigns both fields raw, WITHOUT `setTreeOpen`'s
        -- exclusion rule: whatever combination the element reports is by
        -- definition the truth to sync to.
        DrawerChanged startOpen endOpen ->
            ( { model | treeOpen = startOpen, tocOpen = endOpen }, Effect.none )

        ViewportResized width ->
            ( resizeTo width model, Effect.none )

        ToggleToc ->
            ( setTocOpen (not model.tocOpen) model, Effect.none )

        -- Fired when a TOC jump-link is clicked. Below `drawerSideBreakpointPx`
        -- the panel is a `push`/`over` overlay that holds the content `inert`,
        -- so without this the user would land on the right heading but stay
        -- stuck behind the still-open panel. At or above it the panel is a
        -- `side` panel sitting BESIDE live content, so dismissing it would just
        -- be yanking the TOC away from someone using it — left alone there.
        CloseToc ->
            if treePinsOpen model.viewportWidth then
                ( model, Effect.none )

            else
                ( setTocOpen False model, Effect.none )

        -- Mounts `m3e-search-view` (via `searchOpen`) WITHOUT its `open`
        -- attribute, then flips `open` on a moment later via `RevealSearch`
        -- -- see that Msg's comment for why the two steps can't collapse into
        -- one.
        OpenSearch ->
            ( { model | searchOpen = True, searchViewOpen = False }
            , Effect.fromCmd
                (Task.perform (\_ -> RevealSearch) (Process.sleep 16))
            )

        -- The second half of `OpenSearch`, always fired a beat later. Guarded
        -- on `searchOpen` still being true in case `CloseSearch` (or a route
        -- change) landed in between and already unmounted the element --
        -- without the guard this would silently remount it.
        RevealSearch ->
            if model.searchOpen then
                ( { model | searchViewOpen = True }, Effect.none )

            else
                ( model, Effect.none )

        -- Fired by CloseSearch itself, by a result link's click (see
        -- searchResultLink), and by searchToggleDecoder when the search
        -- view's own internal back button closes it -- the same
        -- element-can-close-itself sync the settings bottom sheet no longer
        -- needs at all now that it's a native `m3e-bottom-sheet-trigger`
        -- with no Elm-tracked open state (see `settingsButton`).
        CloseSearch ->
            ( { model | searchOpen = False, searchViewOpen = False }, Effect.none )

        -- The search view fires `query` both when it opens (term = "") and
        -- on every keystroke -- there's no separate "opened" event to hang
        -- the lazy fetch on. Fetching only when `searchIndex == Nothing`
        -- means the very first query (on open) triggers it, and every
        -- later keystroke (this session) just re-filters the already-loaded
        -- index.
        SetSearchQuery term ->
            ( { model | searchQuery = term }
            , if model.searchIndex == Nothing then
                Effect.fromCmd
                    (Http.get
                        { url = "/search-index.json"
                        , expect = Http.expectJson GotSearchIndex searchEntryListDecoder
                        }
                    )

              else
                Effect.none
            )

        GotSearchIndex result ->
            ( { model | searchIndex = Just result }, Effect.none )

        ThemeMsg themeMsg ->
            let
                ( newTheme, themeCmd ) =
                    Theme.update themeMsg model.theme
            in
            ( { model | theme = newTheme }, Effect.fromCmd (Cmd.map ThemeMsg themeCmd) )

        SetDirection dir ->
            ( { model | dir = dir }, Effect.none )

        -- Scoped reset for `controlRow` only: variant → neutral, scheme → auto
        -- ("System"), direction → auto. Deliberately NOT `Theme.ResetAll`, which
        -- would also discard every colour, typescale, shape and CSS-variable
        -- override the visitor has built up in the sections below.
        ResetControlRow ->
            let
                ( theme2, themeCmd ) =
                    Theme.update (Theme.SetVariant Value.neutral) model.theme

                ( theme3, themeCmd2 ) =
                    Theme.update (Theme.SetScheme Value.auto) theme2
            in
            ( { model | theme = theme3, dir = TypedHtml.Values.auto }
            , Effect.fromCmd (Cmd.batch [ Cmd.map ThemeMsg themeCmd, Cmd.map ThemeMsg themeCmd2 ])
            )

        PresetRequested id ->
            case Theme.Presets.byId id of
                Just preset ->
                    let
                        ( newTheme, themeCmd ) =
                            Theme.update (Theme.ApplyPreset preset) model.theme
                    in
                    ( { model | theme = newTheme }, Effect.fromCmd (Cmd.map ThemeMsg themeCmd) )

                Nothing ->
                    ( model, Effect.none )

        -- The site-wide layer-tab selection, mirrored from localStorage.
        -- `index.ts` sends this on boot AND after every `storeSurface` (a tab
        -- click on any page), so this single field is the only writer and it
        -- survives client-side navigation between component pages. Falls back to
        -- the current value on absence/decode failure rather than resetting to
        -- `Top` — a bad blob must not silently undo the user's choice.
        SurfaceLoaded value ->
            let
                surface : Doc.Usage.Surface
                surface =
                    case Decode.decodeValue Decode.string value of
                        Ok s ->
                            Doc.Usage.surfaceFromString s
                                |> Result.withDefault model.activeSurface

                        Err _ ->
                            model.activeSurface
            in
            ( { model | activeSurface = surface }, Effect.none )


{-| Watch viewport width so `resizeTo` can re-pin the tree (and, past
`tocPinBreakpointPx`, the TOC) when the user crosses back up from a narrow
window to a wide one. Without this the panels the element auto-closed on the way
DOWN would stay closed on the way back up, since nothing else in the app ever
sets `treeOpen` without a deliberate tap.

The Cmd/Ctrl+K port is gated on `hasDocsShell`, because `searchOverlay` is
mounted inside the shell branch of `view`: on an `/examples/*` route the
shortcut would set `searchOpen = True` with nothing rendered to show it, and
the flag would then survive until the next `PageChanged` — popping the overlay
open unrequested on a route the user never asked to search from.

-}
subscriptions : UrlPath -> Model -> Sub Msg
subscriptions path _ =
    Sub.batch
        [ Browser.Events.onResize (\w _ -> ViewportResized w)
        , Sub.map ThemeMsg Theme.subscriptions
        , Theme.Ports.onPresetRequested PresetRequested
        , Theme.Ports.readSurface SurfaceLoaded
        , if hasDocsShell path then
            Ports.onOpenSearchRequested (\_ -> OpenSearch)

          else
            Sub.none
        ]


data : BackendTask FatalError Data
data =
    Doc.Data.allComponents
        |> BackendTask.map
            (\components ->
                { components =
                    components
                        -- Only categorised entries are nav components; the rest
                        -- (base classes, sub-elements) stay out of the drawer.
                        |> List.filter (\c -> c.category /= "")
                        |> List.map (\c -> { slug = c.slug, label = c.label, category = c.category })
                        -- Sort by slug so each category's items render in the
                        -- same order the old hand-list did (it was slug-sorted).
                        |> List.sortBy .slug
                }
            )



-- VIEW


view :
    Data
    ->
        { path : UrlPath
        , route : Maybe Route
        }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : List (Html msg), title : String }
view sharedData page model toMsg pageView =
    { title = breadcrumbTitle page.path (View.title pageView)
    , body =
        [ M3e.theme
            [ M3e.Component.Theme.color model.theme.seed
            , M3e.Component.Theme.scheme model.theme.scheme
            , M3e.Component.Theme.contrast model.theme.contrast
            , M3e.Component.Theme.variant model.theme.variant
            , M3e.Component.Theme.density model.theme.density
            , M3e.Component.Theme.motion model.theme.motion
            , TypedHtml.Attributes.dir model.dir

            -- The m3e-theme element's `density` prop/attr is NON-reactive, so the
            -- control has no effect unless we drive `--md-sys-density-scale` (which
            -- the m3e components read via density.calc) ourselves. Elm can't set a
            -- CSS custom property directly — `style` uses `node.style[key]=…` which
            -- ignores `--vars`, and `attribute "style"` gets clobbered on re-render —
            -- so it goes through a Tailwind arbitrary-property CLASS instead.
            , TypedHtml.Attributes.class (densityClass model.theme.density)
            ]
            -- `dir` is admissible directly on the `m3e-theme` host because `dir` is
            -- part of the open-row `_globals` axis (elm-cem, elm-typed-html), so the
            -- wrapper div that used to carry the shell classes and `dir` together is
            -- gone — both now live on the host itself.
            (if not (hasDocsShell page.path) then
                View.body pageView

             else
                [ skipLink

                -- `flex-col md:flex-row`: one shell, two axes. At `md`+ it is a
                -- ROW (rail | main column) and `docsNavBar` is `md:hidden`. Below
                -- `md` the rail is `hidden` -- so it takes no flex slot -- and the
                -- SAME div is a COLUMN whose in-flow children are, top to bottom,
                -- the main column then the bottom nav bar. That is what lets the
                -- bar stop being `position: fixed`: an in-flow bar can't occlude
                -- the content above it, so no scroll region anywhere in the shell
                -- needs a compensating `pb-20 md:pb-0` to stay reachable.
                --
                -- `min-h-0` is the column-axis twin of `min-w-0`: a flex item's
                -- default `min-height: auto` would let the main column grow to fit
                -- its content instead of its flex basis, pushing the nav bar off
                -- the bottom of the viewport and turning the DOCUMENT into the
                -- scroller. It is belt-and-braces today (`drawerShell`'s own `h-0`
                -- already keeps the column's intrinsic height at ~0), but it is the
                -- guard that keeps the "one bounded scroll region" invariant from
                -- depending on that one class in another function.
                , TypedHtml.div
                    [ TypedHtml.Attributes.id "docs-shell"
                    , TypedHtml.Attributes.class "h-dvh w-full flex flex-col md:flex-row"
                    ]
                    [ docsNavRail toMsg page.path
                    , TypedHtml.div [ TypedHtml.Attributes.class "flex flex-1 flex-col min-w-0 min-h-0" ]
                        [ M3e.mapMsg toMsg (appShellBar page.path)
                        , drawerShell toMsg model page sharedData.components (View.body pageView)
                        ]
                    , docsNavBar toMsg page.path
                    ]
                , M3e.mapMsg toMsg (settingsBottomSheet model)
                , M3e.mapMsg toMsg (searchOverlay model)
                ]
            )
            |> M3e.toHtml
        ]
    }


{-| A "Skip to main content" link — the first focusable element on the page, so
keyboard/AT users can jump the ~98-item nav and land on `#main-content` (the
`<main>` landmark `drawerShell` wraps the page body in). Visually hidden until
focused, then it surfaces as a floating chip.
-}
skipLink : Element { s | sharedText : M3e.Kind.Shared } adm_ msg
skipLink =
    TypedHtml.a
        [ TypedHtml.Attributes.href "#main-content"
        , TypedHtml.Attributes.class "sr-only focus:not-sr-only focus:fixed focus:top-2 focus:left-2 focus:z-50 focus:px-4 focus:py-2"
        ]
        [ M3e.text "Skip to main content" ]


normalizePath : String -> String
normalizePath path =
    if path /= "/" && String.endsWith "/" path then
        String.dropRight 1 path

    else
        path



-- TOP APP BAR


{-| The TOC toggle is always shown. It used to be gated on whether the route
had declared any `View.TocEntry`s, back when a route had to enumerate its own
headings by hand — but `tocPanel` now mounts a single `m3e-toc` that discovers
headings from the real rendered DOM at runtime, so Elm has no advance list to
check emptiness against. The rare page with no qualifying headings just opens
to a near-empty panel rather than hiding the button; that's an honest (if
minor) trade against ever again silently missing a heading, which is exactly
how this button's old gating condition and the old hand-built entry lists
drifted apart.

It used to be gated on viewport width too, because the `end` panel's
visibility was a formula that ignored `tocOpen` on desktop — so the button
would have been a focusable no-op there. Now that `tocOpen` is the single
authority at every width, the button always does something visible: below
`tocPinBreakpointPx` it opens the panel (closing the tree), at or above it
collapses the pinned panel to give the content column its width back.

-}
appShellBar : UrlPath -> Element (M3e.Component.AppBar.Is s) admittedBy Msg
appShellBar path =
    M3e.appBar
        [ M3e.Component.AppBar.size Value.small
        , M3e.Attributes.id "docs-app-bar"
        ]
        [ M3e.Component.AppBar.leading
            (M3e.iconButton [ Aria.label "Toggle navigation", M3e.Events.onClick ToggleTree ]
                [ M3e.icon [ M3e.Component.Icon.name "list" ] [] ]
            )
        , M3e.Component.AppBar.title (M3e.text (Maybe.withDefault "" (currentSectionLabel path)))
        , M3e.Component.AppBar.subtitle (M3e.text "elm-m3e — Material 3 Expressive for Elm")
        , M3e.Component.AppBar.trailing
            (M3e.iconButton [ Aria.label "On this page", M3e.Events.onClick ToggleToc ]
                [ M3e.icon [ M3e.Component.Icon.name "toc" ] [] ]
            )
        , M3e.Component.AppBar.trailing githubLink
        , M3e.Component.AppBar.trailing settingsButton
        ]


{-| The GitHub link. The mark is registered into `m3e-icon`'s own icon registry at
startup (`docs/gen/icons.js`, generated from `config/icons.json`), so this is an
ordinary typed icon — no raw SVG string and no `M3e.Unsafe` escape. Registry-rendered
icons are `<svg><path/></svg>` inside `m3e-icon`, so the mark still inherits the app
bar's on-surface foreground and adapts to light/dark.
-}
githubLink : Element { s | iconButton : M3e.Kind.Brand } admittedBy Msg
githubLink =
    M3e.iconButton
        [ Aria.label "GitHub repository"
        , M3e.Attributes.href "https://github.com/jackhp95/elm-m3e"
        , M3e.Attributes.target "_blank"
        , M3e.Attributes.rel "noreferrer noopener"
        ]
        [ M3e.icon [ M3e.Component.Icon.name "github" ] [] ]


{-| The app-bar settings control: an icon button carrying a nested
`m3e-bottom-sheet-trigger` (matching `docsNavRail`'s `m3e-nav-rail-toggle`
composition -- an action element nested INSIDE a clickable element, not a
container wrapping one), which opens `settingsBottomSheet` directly. (Was a
Card popover trigger, then an end-drawer toggle; the icon is the standard
overflow "more" glyph rather than a gear, matching the sheet's move off the
settings-specific end drawer.)
-}
settingsButton : Element { s | iconButton : M3e.Kind.Brand } admittedBy Msg
settingsButton =
    M3e.iconButton
        [ Aria.label "Settings" ]
        [ M3e.icon [ M3e.Component.Icon.name "more_vert" ] []
        , M3e.bottomSheetTrigger [ M3e.Component.BottomSheetTrigger.for "settings-sheet" ] []
        ]



-- SETTINGS (bottom sheet — cloned from matraic's #settings-drawer, moved off the end drawer)


{-| The settings bottom sheet, opened by the `m3e-bottom-sheet-trigger` nested
in `settingsButton` (the element's own `_onClick` calls `.show()` directly --
no Elm round-trip). `modal` scrims the page and dismisses on an outside click
or Escape (the actual dismiss-outside-listener attach is deferred a frame via
`requestAnimationFrame`, so the SAME click that opened it is never seen as
"outside" -- that race is what an earlier, `onClick`-through-Elm version of
this trigger hit, since Elm's own render round-trip landed unpredictably
relative to that same deferred frame; a native trigger's synchronous
`.show()` call doesn't have that round-trip to race). `handle` + `hideable`
let a swipe-down dismiss it too. The element owns its own open/closed state
entirely -- opening AND closing -- with no Elm involvement at all, not even
to sync a mirrored model field back afterward; the same way `docsNavRail`'s
`m3e-nav-rail-toggle` owns the rail's expanded/compact width with no
Elm-side counterpart either.
-}
settingsBottomSheet : Model -> Element (M3e.Component.BottomSheet.Is s) admittedBy Msg
settingsBottomSheet model =
    M3e.bottomSheet
        [ M3e.Attributes.id "settings-sheet"
        , M3e.Component.BottomSheet.modal True
        , M3e.Component.BottomSheet.handle True
        , M3e.Component.BottomSheet.hideable True
        , M3e.Component.BottomSheet.detents "half full"
        ]
        [ settingsSheetContent model ]


{-| One accordion entry: a header (plain text label) plus the section's body.

This used to need TWO `M3e.Unsafe.recast` calls, and they were a codegen-config
bug rather than a genuine type gap. `config/slots.json` declared the panel's
`header` slot as `"kinds": ["any"]`, exactly like its `unnamed` slot, so codegen
gave both the SAME `childAccepts` type variable — forcing the header and the body
to unify to one kind. A real `M3e.expansionHeader` therefore could never coexist
with arbitrary body content, and erasing both rows with `recast` was the only way
through. The config now declares `header` as `["expansionHeader"]` (the way
`Accordion`'s `unnamed` already declared `["expansionPanel"]`), codegen emits a
dedicated `HeaderSlot`, and the typed header drops straight in. No escape needed.

-}
sectionPanel :
    String
    -> Element cs (M3e.Component.ExpansionPanel.ChildAdmittedBy childAdm) msg
    -> Element { s | expansionPanel : M3e.Kind.Brand } admittedBy msg
sectionPanel label body =
    M3e.Component.ExpansionPanel.component
        { header = M3e.expansionHeader [] [ M3e.text label ] }
        []
        [ body ]


{-| The 6 theme-editor sections wrapped in an accordion. Assembles the
`sectionsEl` passed to `Theme.view`. The section bodies carry the expansion
panel's own `ChildAdmittedBy` row rather than a bare type variable, which is what
lets `sectionPanel` place them in a typed slot with no escape hatch.
-}
sectionsAccordion :
    { color : Element cs (M3e.Component.ExpansionPanel.ChildAdmittedBy childAdm) msg
    , typography : Element cs (M3e.Component.ExpansionPanel.ChildAdmittedBy childAdm) msg
    , shape : Element cs (M3e.Component.ExpansionPanel.ChildAdmittedBy childAdm) msg
    , appearance : Element cs (M3e.Component.ExpansionPanel.ChildAdmittedBy childAdm) msg
    , advanced : Element cs (M3e.Component.ExpansionPanel.ChildAdmittedBy childAdm) msg
    , cssVariables : Element cs (M3e.Component.ExpansionPanel.ChildAdmittedBy childAdm) msg
    }
    -> Element { s | accordion : M3e.Kind.Brand } admittedBy msg
sectionsAccordion themeSections =
    M3e.accordion []
        [ sectionPanel "Color" themeSections.color
        , sectionPanel "Typography" themeSections.typography
        , sectionPanel "Shape" themeSections.shape
        , sectionPanel "Appearance" themeSections.appearance
        , sectionPanel "Advanced" themeSections.advanced

        -- Last, and named for the mechanism rather than a topic: this is the raw
        -- CSS-custom-property hatch, reached after the curated sections above
        -- have failed to expose whatever the visitor is after.
        , sectionPanel "CSS Variables" themeSections.cssVariables
        ]


{-| The theme controls, rendered into the settings bottom sheet. `Theme.view`
lays out the drawer shell and delegates each section (color, typography,
shape, appearance, advanced) to its own `Theme.Sections.*` module; `Shared`
only wires those section views together and handles direction, which is not
part of `Theme.Model`. The container keeps the typed `role="complementary"`
landmark via `Aria.role`.

All our richer controls are kept (scheme, contrast, seed color, density,
direction); their LOCATION moved, first from the old Card popover into an
end drawer, then from that end drawer into this bottom sheet, and finally
their CONTROL logic moved out of `Shared` into the `Theme` module and its
per-section `Theme.Sections.*` views.

-}
settingsSheetContent : Model -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
settingsSheetContent model =
    TypedHtml.div
        [ TypedHtml.Attributes.id "settings-sheet-content"

        -- Extra bottom padding gives the sheet scroll runway so the last control
        -- clears the mobile browser URL bar (the bottom sheet's height is
        -- component-driven — there is no CSS height knob to make it `dvh`-aware).
        -- `env(safe-area-inset-bottom)` additionally clears the iOS home
        -- indicator and is 0 on desktop, so it costs desktop nothing.
        , TypedHtml.Attributes.class "flex flex-col gap-2 pt-4 pb-[max(1rem,env(safe-area-inset-bottom))] max-md:pb-[calc(5rem+env(safe-area-inset-bottom))]"
        , Aria.role Aria.complementary
        ]
        [ controlRow model
        , Theme.view
            { dir = model.dir
            , onSetDirection = SetDirection
            , sectionsEl =
                sectionsAccordion
                    { color = Theme.Sections.Color.view model.theme |> HtmlIr.Element.map ThemeMsg
                    , typography = Theme.Sections.Typography.view model.theme |> HtmlIr.Element.map ThemeMsg
                    , shape = Theme.Sections.Shape.view model.theme |> HtmlIr.Element.map ThemeMsg
                    , appearance = Theme.Sections.Appearance.view model.theme |> HtmlIr.Element.map ThemeMsg
                    , advanced = Theme.Sections.Advanced.view model.theme |> HtmlIr.Element.map ThemeMsg
                    , cssVariables = Theme.Sections.CssVariables.view model.theme |> HtmlIr.Element.map ThemeMsg
                    }
            }
            model.theme
            ThemeMsg
        ]


{-| The variant + scheme + direction row, pinned at the top of the settings
sheet: the three "what does the whole app look like" knobs, previously scattered
(scheme and variant were full-width segmented strips inside `Theme.view`,
direction was a labelled strip at the very bottom of the sheet).

Variant and scheme come from `Theme` (mapped through `ThemeMsg`); direction is
assembled here, since `dir` lives in `Shared.Model`, not `Theme.Model`. One
scoped reset fires all three back to their neutral values — deliberately NOT
`Theme.ResetAll`, which would also discard every colour/typescale override.

-}
controlRow : Model -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
controlRow model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-wrap items-end gap-2" ]
        [ Theme.variantSelect model.theme |> HtmlIr.Element.map ThemeMsg
        , Theme.schemeToggle model.theme |> HtmlIr.Element.map ThemeMsg
        , directionToggle model
        , M3e.iconButton
            [ TypedHtml.Events.onClick ResetControlRow
            , Aria.label "Reset variant, scheme, and direction"
            ]
            [ M3e.icon [ M3e.Component.Icon.name "restart_alt" ] [] ]
        ]


{-| Drive `--md-sys-density-scale` via a Tailwind arbitrary-property class — Elm
cannot set a CSS custom property directly. The three class strings are literals
so Tailwind's scanner (`@source "./app"` in style.css) emits all three rules.
-}
densityClass : Float -> String
densityClass d =
    if d <= -2 then
        "[--md-sys-density-scale:-2]"

    else if d <= -1 then
        "[--md-sys-density-scale:-1]"

    else
        "[--md-sys-density-scale:0]"


{-| Direction control: a single icon button flipping LTR ⇄ RTL, replacing the
2-option segmented strip (a two-option enum strip is a toggle wearing a costume,
and it cost a full row plus its own label). Shows
`format_textdirection_l_to_r` when LTR and `format_textdirection_r_to_l` when RTL;
clicking flips to the other and fires `SetDirection`. `aria-pressed`/`aria-label`
carry the state, since the glyph alone does not.

`auto` is not offered — it defers to the document/OS, which is already what the
shell does when this control is untouched, so it would be a button that visibly
does nothing. It stays reachable through `ResetControlRow`.

-}
directionToggle : Model -> Element { s | iconButton : M3e.Kind.Brand } admittedBy Msg
directionToggle model =
    let
        isRtl : Bool
        isRtl =
            TypedHtml.Values.toString model.dir == "rtl"

        ( next, glyph, lbl ) =
            if isRtl then
                ( TypedHtml.Values.ltr, "format_textdirection_l_to_r", "Switch to left-to-right" )

            else
                ( TypedHtml.Values.rtl, "format_textdirection_r_to_l", "Switch to right-to-left" )
    in
    M3e.iconButton
        [ TypedHtml.Events.onClick (SetDirection next)
        , Aria.label lbl
        , Aria.pressed
            (if isRtl then
                Aria.true

             else
                Aria.false
            )
        ]
        [ M3e.icon [ M3e.Component.Icon.name glyph ] [] ]



-- SEARCH


{-| The search overlay. Unlike `settingsBottomSheet` (always mounted, toggled
via its own `open` attribute), this is only mounted in the DOM at all while
`model.searchOpen`: `m3e-search-view` renders a persistent, full-width pill
bar whenever it's present and NOT open (verified against a live build --
neither `contained` nor any other attribute suppresses it), and nothing in
this layout wants that pill sitting anywhere -- the FAB is the only visible
trigger. Conditional rendering sidesteps needing to suppress it via CSS.

The mode is derived from `model.viewportWidth` rather than delegated to the
element's own `mode="auto"` — see `searchModeFor` for why `auto` is a race
this overlay always loses below 600px. `open` is driven by `searchViewOpen`,
NOT `searchOpen` itself, and is deliberately false on the very render that
first mounts the element — see `OpenSearch`/`RevealSearch`.

That split exists because `@m3e/web` 2.7.6 added a SECOND version of the same
race the `auto`-mode paragraph above describes, this time independent of
`mode="auto"` entirely. `M3eSearchViewElement.willUpdate` now does this on
ANY `mode` change, observer or not:

    if (changedProperties.has("mode")) {
        const previousMode = changedProperties.get("mode");
        if (previousMode && previousMode !== this.mode && this.open) {
            this.open = false;                            // no `toggle` event!
        }
        ...
    }

`changedProperties.get("mode")` on an element's OWN FIRST update returns its
Lit-declared default (`"docked"`), not "no previous value" — so mounting the
element with `mode="fullscreen"` and `open` TRUE in the same render counts as
"mode changed while open" and silently flips `open` back off, exactly like
the `auto` bug, just triggered by our own explicit `mode` attribute instead
of the observer. Splitting the mount into two Elm renders — create the
element closed (`searchOpen = True, searchViewOpen = False`), then flip
`open` on `RevealSearch` once `mode` is no longer changing — means the
`open`-setting render never touches `mode` at all, so `willUpdate` never
takes the `changedProperties.has("mode")` branch and the guard can't fire.

`RevealSearch` fires off a `Process.sleep 16` rather than an immediate
`Task.succeed` because Elm's own renderer batches same-tick model updates
into ONE `requestAnimationFrame` draw (`elm/browser`'s `_Browser_makeAnimator`)
-- a same-tick follow-up Msg would very likely get coalesced with `OpenSearch`
into the exact single first-mount draw this is trying to split in two. A real
macrotask boundary (`setTimeout`, which `Process.sleep` compiles to) is what
actually guarantees the mount has been painted, and the custom element's own
first `willUpdate` has already run with `open` still false, before the second
render sets it true.

**The classes are load-bearing, not decoration.** `m3e-bottom-sheet` is
`position: fixed` on its host and positions itself; `m3e-search-view` is
`:host { display: block }` — plain static flow. Mounted here, as the last
child of `m3e-theme` next to the shell's own `h-dvh` div, it lands directly
BELOW a box that already fills the viewport: measured at 1400x900, the host
sat at `y = 900`, entirely under the fold, so clicking the FAB looked like
it did nothing. (Playwright hid this: `.click()` auto-scrolls and
`toBeVisible()` never asserts in-viewport — hence the bounding-box
assertion in `search.spec.ts`.)

Only DOCKED mode depends on this: `#openDocked` positions its popover from
the shadow `.anchor` inside the host, so the host's own box is what it
follows. Fullscreen mode sets `position: fixed` + `100dvw/100dvh` on the
popover and ignores the host entirely — the classes are harmless there.
`max-w-2xl mx-auto` keeps the docked bar from stretching to a 1400px-wide
pill (the docked popover's width is copied from the anchor's `clientWidth`);
padding is avoided on the host for the same reason, since `clientWidth`
would include it.

-}
searchOverlay : Model -> Element { s | searchView : M3e.Kind.Brand, sharedText : M3e.Kind.Shared } admittedBy Msg
searchOverlay model =
    if not model.searchOpen then
        M3e.text ""

    else
        M3e.searchView
            [ TypedHtml.Attributes.class "fixed inset-x-0 top-2 z-50 mx-auto w-full max-w-2xl"
            , M3e.Component.SearchView.mode (searchModeFor model.viewportWidth)
            , M3e.Component.SearchView.open model.searchViewOpen
            , M3e.Events.onQueryWith searchQueryDecoder
            , M3e.Events.onToggleWith searchToggleDecoder
            ]
            [ M3e.Component.SearchView.input
                (TypedHtml.input
                    [ TypedHtml.Attributes.type_ "text"
                    , TypedHtml.Attributes.placeholder "Search..."
                    , TypedHtml.Attributes.value model.searchQuery
                    ]
                    []
                )
            , searchResults model
            ]


{-| The results list (or an empty-state hint). `filterSearchEntries` never
runs against an unloaded or failed index -- both surface their own message
instead, so a failed fetch is visibly "Search unavailable," not a silently
empty panel.
-}
searchResults : Model -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
searchResults model =
    case model.searchIndex of
        Nothing ->
            TypedHtml.div [ TypedHtml.Attributes.class "p-4" ] [ M3e.text "Loading..." ]

        Just (Err _) ->
            TypedHtml.div [ TypedHtml.Attributes.class "p-4" ] [ M3e.text "Search unavailable" ]

        Just (Ok entries) ->
            if String.isEmpty (String.trim model.searchQuery) then
                TypedHtml.div [ TypedHtml.Attributes.class "p-4" ] [ M3e.text "Type to search" ]

            else
                case filterSearchEntries model.searchQuery entries of
                    [] ->
                        TypedHtml.div [ TypedHtml.Attributes.class "p-4" ] [ M3e.text "No results" ]

                    matches ->
                        TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-1 p-2" ]
                            (List.map searchResultLink matches)


{-| Case-insensitive substring match against `heading` (falling back to
`title` for a page-level entry, where `heading = Nothing`), RANKED by relevance
and capped at 20 -- see Global Constraints.

The cap used to take the first 20 matches in raw INDEX order, which made the
search unable to find its own components. Searching "button" matched ~2700
entries, and the first 20 in index order were all `/guide/reference` and
`/guide/roundtrip` prose that happens to mention the word; `/components/button`
never appeared at all. A user could not reach a component page by typing its
name.

Ranking, lowest score wins:

1.  the matched text IS the query -- an exact hit;
2.  it STARTS with the query -- "Button < Components < elm-m3e" for "button".
    Page titles here are reverse breadcrumbs (see `breadcrumbTitle`), so a page
    about a thing starts with that thing's name;
3.  a WORD in it starts with the query -- "Filled Button", "Icon button";
4.  it merely contains the query somewhere -- "M3e.Component.ButtonGroup".

Ties break toward page-level entries (`heading = Nothing`) over headings buried
inside a page, then by original index so the order stays deterministic and
stable.

-}
filterSearchEntries : String -> List SearchEntry -> List SearchEntry
filterSearchEntries query entries =
    let
        needle : String
        needle =
            String.toLower (String.trim query)

        matchedText : SearchEntry -> String
        matchedText entry =
            String.toLower (Maybe.withDefault entry.title entry.heading)

        {- Any word starting with the needle, where "word" is a run of
           alphanumerics -- so `.`, `-`, `/` and `<` all count as boundaries and
           "M3e.Component.Button" word-matches "button".
        -}
        hasWordStartingWithNeedle : String -> Bool
        hasWordStartingWithNeedle text =
            text
                |> String.map
                    (\c ->
                        if Char.isAlphaNum c then
                            c

                        else
                            ' '
                    )
                |> String.words
                |> List.any (String.startsWith needle)

        relevance : SearchEntry -> Int
        relevance entry =
            let
                text : String
                text =
                    matchedText entry
            in
            if text == needle then
                0

            else if String.startsWith needle text then
                1

            else if hasWordStartingWithNeedle text then
                2

            else
                3

        {- A page-level entry names a whole page; a heading names a spot inside
           one. At equal textual relevance the page is the more useful answer.
        -}
        depth : SearchEntry -> Int
        depth entry =
            case entry.heading of
                Nothing ->
                    0

                Just _ ->
                    1
    in
    entries
        |> List.filter (\entry -> String.contains needle (matchedText entry))
        |> List.indexedMap (\index entry -> ( ( relevance entry, depth entry, index ), entry ))
        |> List.sortBy Tuple.first
        |> List.take 20
        |> List.map Tuple.second


{-| One result. Primary text is the matched heading when the entry is a
heading, falling back to the page title for a page-level entry (`heading =
Nothing`) -- the mirror image of `filterSearchEntries`' own "match heading,
fall back to title" rule, so what's highlighted is always whichever string
the query actually matched. The page title renders as a secondary line
ONLY for a heading entry (context: "this heading lives on that page"); a
page-level entry has nothing to add below its own title.

This distinction also keeps results from colliding in the accessible tree:
a heading entry named e.g. "Button" (the h1 text) and the page-level entry
named "Button < Components < elm-m3e" (the real `<title>`, a reverse
breadcrumb -- see `Shared.breadcrumbTitle` -- which is never bare "Button")
are two different accessible names, not the same string rendered twice.

Clicking navigates (real `a[href]`, an anchor when the heading has a real
id) and fires `CloseSearch` -- the same "navigate closes the panel"
convention `tocPanel`'s jump-links already follow for `CloseToc`.

-}
searchResultLink : SearchEntry -> Element { s | sharedText : M3e.Kind.Shared, sharedFlow : M3e.Kind.Shared } admittedBy Msg
searchResultLink entry =
    TypedHtml.a
        [ TypedHtml.Attributes.href (entry.url ++ (entry.anchor |> Maybe.map (\a -> "#" ++ a) |> Maybe.withDefault ""))
        , TypedHtml.Attributes.class "flex flex-col gap-0.5 px-3 py-2"
        , TypedHtml.Events.onClick CloseSearch
        ]
        (M3e.text (Maybe.withDefault entry.title entry.heading)
            :: (case entry.heading of
                    Just _ ->
                        [ TypedHtml.div [] [ M3e.text entry.title ] ]

                    Nothing ->
                        []
               )
        )



-- SIDEBAR NAVIGATION (matraic IA)


{-| One top-level section's flat page list for the tree drawer, looked up by
`prefix` (matching `Section.prefix`) in `currentSectionItems`. No title/icon
fields — the tree never labels itself, since it only ever shows the ONE
section the rail already highlights.
-}
type alias NavSection =
    { prefix : String, items : List ( String, String ) }


navSections : List NavSection
navSections =
    [ { prefix = "getting-started"
      , items =
            [ ( "/getting-started/welcome", "Welcome" )
            , ( "/getting-started/installation", "Installation" )
            , ( "/getting-started/browser-support", "Browser Support" )
            ]
      }
    , { prefix = "guide"
      , items =
            [ ( "/guide", "Start here" )
            , ( "/guide/first-component", "Your first component" )
            , ( "/guide/invalid-states", "Invalid states don't compile" )
            , ( "/guide/strictness", "The strictness dial" )
            , ( "/guide/accessible-by-construction", "Accessibility you can't forget" )
            , ( "/guide/accessibility", "Accessibility reference" )
            , ( "/guide/composition-text-field", "Composition, not injection" )
            , ( "/guide/theming", "Theming with tokens" )
            , ( "/guide/motion", "Motion" )
            , ( "/guide/generated-and-inspectable", "Generated & inspectable" )
            , ( "/guide/the-layers", "The layer map" )
            , ( "/guide/seams", "Your own seam" )
            , ( "/guide/tooling-refactors", "The tooling refactors for you" )
            , ( "/guide/troubleshooting", "Troubleshooting" )
            , ( "/guide/how-we-prove-it", "How we prove it" )
            , ( "/guide/cheat-sheet", "Cheat sheet" )
            , ( "/guide/glossary", "Glossary" )
            , ( "/guide/reference", "Full API reference" )
            , ( "/guide/roundtrip", "Round-trip report" )
            ]
      }
    , { prefix = "styles"
      , items =
            [ ( "/styles/color", "Color" )
            , ( "/styles/typography", "Typography" )
            , ( "/styles/shape", "Shape" )
            , ( "/styles/elevation", "Elevation" )
            , ( "/styles/state-layers", "State Layers" )
            , ( "/styles/motion", "Motion" )
            , ( "/styles/density", "Density" )
            ]
      }
    , { prefix = "examples"
      , items =
            [ ( "/examples", "Overview" )
            , ( "/examples/dashboard", "Dashboard" )
            , ( "/examples/shop", "Shop" )
            , ( "/examples/mail", "Mail" )
            , ( "/examples/travel", "Travel" )
            , ( "/examples/settings", "Settings" )
            , ( "/examples/list-detail", "List-detail" )
            , ( "/examples/supporting-pane", "Supporting pane" )
            , ( "/examples/feed", "Feed" )
            ]
      }
    ]


{-| The whole below-app-bar shell: an `m3e-drawer-container` whose `start` panel
is the current section's hierarchical nav-menu, whose `end` panel is the page's
opt-in TOC, and whose default content is the page body. The nav is `NavItem`
links inside `NavMenuItem` groups inside a `NavMenu`.

Both panels' `start`/`end` attributes render `model.treeOpen`/`model.tocOpen`
DIRECTLY. That directness is the fix for the dead-hamburger bug — see
`drawerSideBreakpointPx`. The only qualifier left on `end` is "does this page
have a TOC at all", which cannot collapse into a stuck constant because the TOC
toggle that drives `tocOpen` isn't rendered on a page with no entries either.

Each `M3e.contentPane` carries `w-max` (Tailwind's `width: max-content`)
instead of a fixed `--m3e-drawer-container-width`. `@m3e/web`'s own shadow DOM
sets `::slotted([slot="start"]), ::slotted([slot="end"]) { width:
var(--m3e-drawer-container-width, 22.5rem) }`, which by raw selector
specificity (an attribute selector on a pseudo-element vs. a bare class) should
out-rank `w-max` and force the library's 360px default — but it does not:
verified directly against a live instance (toggling the `w-max` class and
reading `getBoundingClientRect().width`) that `w-max` wins the cascade every
time, sizing each panel to its own content instead. A hand-rolled
`[--m3e-drawer-container-width:<value>]` override is deliberately avoided here
in favor of this generated utility class, since a fixed width turned out to be
unnecessary: content-driven sizing already keeps the column readable at every
tested width (see the `shell-breakpoints.spec.ts` budget comment) and adapts
to whichever section's nav labels are actually on screen, rather than
truncating the longer ones (e.g. Guide's "Accessibility you can't forget") to
fit a number picked for the shortest.

The `end` panel's `*:me-11` looks redundant with `w-max` but is not: `-me-7`
bleeds the panel's background past its own box to the container edge, and
without a matching inward margin on its children the _content_ (not just the
background) bleeds past the viewport's trailing edge too — measured at 1440px
wide, `m3e-toc`'s own right edge sat at 1451px (11px off-screen) with
`*:me-11` removed, and back inside at 1407px with it restored. The `start`
panel has no such compensation because `navMenu`'s own content never
approaches that edge the way `-me-7`'s bleed does on the `end` side.

Nothing here carries compensating bottom padding, and nothing added here
should: `docsNavBar` is a real in-flow flex child of the shell (see `view`),
not `fixed ... bottom-0`, so it cannot cover the end of a scrollable panel
in the first place. The `pb-20 md:pb-0` this used to need on the content
pane, `tocPanel`, AND `navMenu` was exactly the wrong shape of fix: it had
to be remembered separately for every scroll region, and `navMenu`'s copy
went unverified for a while (the one test asserting it,
`shell-breakpoints.spec.ts`'s "does not occlude", drove a route whose tree
was empty and therefore never actually scrollable). If a future scroll
region here ever looks like it needs that padding back, the flex structure
above has broken -- fix that, not this.

-}
drawerShell :
    (Msg -> msg)
    -> Model
    -> { path : UrlPath, route : Maybe Route }
    -> List NavComponent
    -> List (Element childAccepts (TypedHtml.Component.Grouping.DivChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Component.Sectioning.MainIs s) admittedBy msg
drawerShell toMsg model page components body =
    TypedHtml.main_
        [ TypedHtml.Attributes.id "main-content"
        , TypedHtml.Attributes.class "flex-auto relative mx-auto w-full h-0"
        ]
        [ M3e.drawerContainer
            [ M3e.Attributes.id "docs-drawer"
            , M3e.Component.DrawerContainer.startMode Value.auto
            , M3e.Attributes.start model.treeOpen
            , M3e.Component.DrawerContainer.endMode Value.auto
            , M3e.Attributes.end model.tocOpen
            , M3e.Events.onChangeWith (Decode.map toMsg drawerChangeDecoder)
            , TypedHtml.Attributes.class "h-full w-full"
            ]
            [ [ navMenu components page.path ]
                |> M3e.contentPane
                    [ TypedHtml.Attributes.class "w-max m3e-content-pane-container-color-surface-container-low -ms-7" ]
                |> M3e.Component.DrawerContainer.start
            , TypedHtml.div [ TypedHtml.Attributes.class "md:p-4 overflow-y-auto h-full" ]
                body
            , [ tocPanel toMsg ]
                |> M3e.contentPane
                    [ TypedHtml.Attributes.class "w-max m3e-content-pane-container-color-surface-container-low -me-7 *:me-11" ]
                |> M3e.Component.DrawerContainer.end
            ]
        ]


{-| The TOC drawer panel: one `m3e-toc`, pointed at `#main-content` (this
`drawerShell`'s own `<main>`). Unlike the hand-built jump-link list this
replaced, `m3e-toc` discovers its entries itself -- scanning the real
rendered DOM for headings (native `h1`-`h6` and this app's own
`m3e-heading[level]`) rather than needing a page-specific list Elm has to
keep in sync. `end`'s own gate (`drawerShell`) no longer checks emptiness
for the same reason: Elm doesn't know in advance whether a page has any
headings, only `m3e-toc`'s own runtime scan does.

`for="main-content"` also picks up the page's own `Doc.pageHeading`/H1 as a
level-1 entry above its sections -- a minor, known redundancy with the
visible page title, not a bug; excluding it would need `m3e-toc-ignore` on
every page's own H1 (17 routes via `Doc.pageHeading`, ~23 more with their
own local `pageHeading` never routed through it), which is out of scope
here.

`M3e.Events.delegate` is required because `m3e-toc` itself doesn't declare
an `onClick` capability -- only `m3e-toc-item` fires `click`, per its own
`@fires` -- so this relies on that click bubbling up to the element the
listener actually sits on. Closing on ANY click inside the panel (not just
on an item) is an intentional, low-risk approximation of the old
per-link `CloseToc`: below `drawerSideBreakpointPx` the `end` drawer is an
`over`/`push` overlay with the page content `inert` while open, so without
this the user would land on the right heading but be stuck behind the
still-open panel. `update`'s `CloseToc` case is a no-op above that width,
where the panel is `side` and dismissing it would just be taking the TOC
away from someone reading it.

-}
tocPanel : (Msg -> msg) -> Element (M3e.Component.Toc.Is s) admittedBy msg
tocPanel toMsg =
    M3e.toc
        [ M3e.Component.Toc.for "main-content"
        , M3e.Component.Toc.maxDepth 3
        , M3e.Events.delegate (M3e.Events.onClick (toMsg CloseToc))
        ]
        [ M3e.Component.Toc.title (M3e.text "On this page") ]


{-| Decode the `<m3e-drawer-container>` `change` event: `event.target.start`/
`.end` are the reflected boolean properties for the two drawers' open state.
Both are decoded together (not just `start`) because a single scrim click can
close BOTH sides in one `change` event (`_handleScrimClick` sets `this.start`
AND `this.end`, per `@m3e/web/dist/drawer-container.js`) — decoding only
`start` would leave `model.endOpen` desynced from the element after a scrim
dismiss. Change events bubbling up from inner components have a target
without these properties, so the decoder fails and Elm ignores them — exactly
what we want.
-}
drawerChangeDecoder : Decode.Decoder Msg
drawerChangeDecoder =
    Decode.map2 DrawerChanged
        (Decode.at [ "target", "start" ] Decode.bool)
        (Decode.at [ "target", "end" ] Decode.bool)


{-| Decode the search view's `query` event: `event.detail.term` is the
current search term, sent both when the view opens (term = "") and on every
keystroke -- see `SetSearchQuery`.
-}
searchQueryDecoder : Decode.Decoder Msg
searchQueryDecoder =
    Decode.map SetSearchQuery (Decode.at [ "detail", "term" ] Decode.string)


{-| Decode the search view's `toggle` event, but only for a close: `newState`
is a native `ToggleEvent` property (not nested under `.detail`, unlike
`query`). The OPEN direction is never decoded here -- Elm already knows it
opened (it's the one that set `searchOpen = True` to mount the view in the
first place), so decoding that case too would just be an echo. Failing the
decoder for "open" makes Elm ignore that event entirely, the same way
`drawerChangeDecoder` ignores events from a mismatched target.
-}
searchToggleDecoder : Decode.Decoder Msg
searchToggleDecoder =
    Decode.field "newState" Decode.string
        |> Decode.andThen
            (\newState ->
                if newState == "closed" then
                    Decode.succeed CloseSearch

                else
                    Decode.fail "search view opened (Elm already knows)"
            )


{-| The docs sidebar nav, an `M3e.NavMenu` of nested `NavMenuItem` groups. Each
leaf's **label** is a real `a[href]` supplied through the `link` seam (see
`navLeaf`): `config/slots.json` declares `NavMenuItem.label`'s `link` kind, so a
link-kind label slots in cleanly and the item navigates like any anchor — no
`onClick` intercept.

The tree is per-route: it renders ONLY the current top-level section's items
(`currentSectionItems`), not every section stacked together. The rail already
identifies which section is current, so a second, redundant "which section am
I in" affordance inside the tree would just be clutter — and it made the
Components branch, with its 7 category sub-groups sitting alongside 4 other
whole sections, the reason the drawer felt overwhelming rather than a page
tree.

-}
navMenu : List NavComponent -> UrlPath -> Element { s | navMenu : M3e.Kind.Brand } admittedBy msg
navMenu components path =
    let
        currentPath : String
        currentPath =
            normalizePath (UrlPath.toAbsolute path)
    in
    M3e.navMenu [ Aria.label "Primary", TypedHtml.Attributes.class "primary-nav-drawer w-fit flex-auto" ]
        (currentSectionItems components path |> List.map (navLeaf currentPath))


{-| The current top-level section's flat page list, looked up by the route's
first path segment (matching `Section.prefix`). Components' list is derived
from the shared component data — sorted alphabetically by label, with "All
components" pinned first (matching `/components/all`'s kitchen-sink page) —
rather than the static lookup every other section uses, since it isn't known
until `Shared.data` loads it. No section sub-groups: `componentCategories`
still exists for `/components/all`'s own grouping, but the tree itself no
longer nests by category (see `navMenu`).

A path with no matching section falls through to `[]` — there is no section
for the tree to show, so the drawer is legitimately empty (the `start`
attribute above gates on `model.treeOpen`, but an empty list here would just
be a panel with nothing in it). Every route in the app currently belongs to
a section, so this is a defensive fallback rather than a live case today.

-}
currentSectionItems : List NavComponent -> UrlPath -> List ( String, String )
currentSectionItems components path =
    case List.head path of
        Just "components" ->
            ( "/components/all", "All components" )
                :: ( "/components/compose", "Compose" )
                :: (components
                        |> List.sortBy (\c -> String.toLower c.label)
                        |> List.map (\c -> ( "/components/" ++ c.slug, c.label ))
                   )

        Just prefix ->
            navSections
                |> List.filter (\s -> s.prefix == prefix)
                |> List.head
                |> Maybe.map .items
                |> Maybe.withDefault []

        Nothing ->
            []


navLeaf : String -> ( String, String ) -> Element { s | navMenuItem : M3e.Kind.Brand } admittedBy msg
navLeaf currentPath ( path, lbl ) =
    M3e.navMenuItem
        [ M3e.Attributes.selected (path == currentPath) ]
        [ M3e.Component.NavMenuItem.label (TypedHtml.a [ TypedHtml.Attributes.href path ] [ M3e.text lbl ]) ]


{-| The component-nav categories, in display order, each paired with its Material
Symbol glyph. Mirrors the editorial taxonomy in `config/categories.json`.
-}
componentCategories : List ( String, String )
componentCategories =
    [ ( "Actions", "touch_app" )
    , ( "Communication", "notifications" )
    , ( "Containment", "widgets" )
    , ( "Navigation", "explore" )
    , ( "Selection", "checklist" )
    , ( "Text inputs", "edit" )
    , ( "Layout & style", "palette" )
    ]



-- TOP-LEVEL NAV RAIL / NAV BAR


{-| One of the 5 top-level sections the rail/bar switch between. `href` is
where clicking the section navigates to — the section's real landing page
(Guide, Examples) or, for the 3 sections with no landing page yet, its first
real child (see `specs/2026-08-06-nav-rail-migration-design.md`, "Decided
information architecture"). `prefix` is the first URL path segment that
belongs to this section, used only for highlighting which rail/bar item is
current — it is independent of `href` (e.g. Components' `href` is
`/components/button`, but ANY `/components/*` path is "current").
-}
type alias Section =
    { label : String
    , icon : String
    , href : String
    , prefix : String
    }


sections : List Section
sections =
    [ { label = "Start", icon = "rocket_launch", href = "/getting-started/welcome", prefix = "getting-started" }
    , { label = "Guide", icon = "auto_stories", href = "/guide", prefix = "guide" }
    , { label = "Styles", icon = "palette", href = "/styles/color", prefix = "styles" }
    , { label = "Examples", icon = "auto_awesome", href = "/examples", prefix = "examples" }
    , { label = "Components", icon = "widgets", href = "/components/button", prefix = "components" }
    ]


{-| Is this section the one the given route belongs to? Matched on the FIRST
path segment only, so every `/components/*` route (not just `/components/button`
itself) highlights "Components". `UrlPath` is `List String` (`dillonkearns/elm-pages`),
so this is a plain `List.head` check — no string-prefix parsing.
-}
sectionIsCurrent : UrlPath -> Section -> Bool
sectionIsCurrent path section =
    List.head path == Just section.prefix


{-| The current section's plain-text label ("Start", "Guide", ...), used for
BOTH the app bar's title (`appShellBar`) and the document-title breadcrumb
(`breadcrumbTitle`) -- one lookup, so the two can't drift apart.

`Nothing` means the route belongs to no top-level section -- every route this
docs site links to or navigates between belongs to one, so this is a
defensive fallback rather than a live case in normal navigation. (It is a
live case for `/roundtrip-harness`, the transient route
`scripts/roundtrip/gen-harness-route.mjs` generates during `check:roundtrip`
-- that route has no section prefix and is never linked from the site.)

-}
currentSectionLabel : UrlPath -> Maybe String
currentSectionLabel path =
    sections
        |> List.filter (sectionIsCurrent path)
        |> List.head
        |> Maybe.map .label


{-| The document `<title>`: a reverse breadcrumb, most specific first --
e.g. `"Button < Components < elm-m3e"`. `pageTitle` is each route's own bare
name (`View.fromElement`'s argument -- the old hand-typed "· elm-m3e" suffix
was stripped from every route when this was added). The `Head.Seo` title
each route ALSO sets is a separate, deliberately untouched concern
(search-result/social-preview copy, not what shows in the tab).

Every route belongs to one of the 5 top-level sections now (`Route/`'s only
directories are Components, Examples, GettingStarted, Guide, Styles), so
`currentSectionLabel` always resolves to `Just` in practice; the `Nothing`
arm is kept for the same reason `currentSectionLabel` keeps its own -- a
plain exhaustive `case`, not a live special case. (The homepage used to be
the one route with no section, forcing an early return of `pageTitle`
unchanged here; that branch is gone along with `/` itself -- see
`Route.GettingStarted.Welcome`.)

-}
breadcrumbTitle : UrlPath -> String -> String
breadcrumbTitle path pageTitle =
    case currentSectionLabel path of
        Just section ->
            pageTitle ++ " < " ++ section ++ " < elm-m3e"

        Nothing ->
            pageTitle ++ " < elm-m3e"


{-| One rail/bar destination — real `href`-based navigation via `m3e-nav-item`'s
`href` attribute (`config/slots.json`'s `NavItem.actionMap` maps it to elm-pages'
own link handling), not an `onClick`-driven `Msg`. Shared between `docsNavRail`
and `docsNavBar`: both `M3e.NavRail` and `M3e.NavBar` admit `navItem` children
(`config/slots.json`).
-}
railItem : UrlPath -> Section -> Element { s | navItem : M3e.Kind.Brand } admittedBy msg
railItem path section =
    M3e.navItem
        [ M3e.Attributes.href section.href
        , M3e.Attributes.selected (sectionIsCurrent path section)
        ]
        [ M3e.Component.NavItem.icon (M3e.icon [ M3e.Component.Icon.name section.icon ] [])
        , M3e.text section.label
        ]


{-| The search trigger, shared by the rail and the bottom bar -- `size small`,
`extended` with a visible "Search" label, opening the search overlay
(`searchOverlay`). Matches @m3e/web's own nav-rail usage example
(`NavRailElement.d.ts`) composition-for-composition: an icon in the default
slot plus label text in the `label` slot, the same pair of children that
example's own FAB carries (`<m3e-icon>` + `<span slot="label">`) -- an
icon-only FAB was a departure from that reference, not a deliberate choice.

`NavRail` admits `fab` directly in its unnamed slot alongside `navItem`
(`config/slots.json`), so on the rail this is a normal child, not a new slot
to wire. `NavBar`'s `config/slots.json` entry admits ONLY `navItem`, though —
it does not admit `fab` -- so `docsNavBar` below cannot place this inside the
`M3e.navBar` itself; `extraClasses` is how it gets positioned as a floating
sibling instead.

-}
searchFab : String -> msg -> Element { s | fab : M3e.Kind.Brand } admittedBy msg
searchFab extraClasses openMsg =
    M3e.fab
        [ M3e.Attributes.size Value.small
        , M3e.Component.Fab.extended True
        , M3e.Component.Fab.variant Value.secondary
        , M3e.Attributes.class extraClasses
        , Aria.label "Search"
        , M3e.Events.onClick openMsg
        ]
        [ M3e.icon [ M3e.Component.Icon.name "search" ] []
        , M3e.Component.Fab.label (M3e.text "Search")
        ]


{-| Desktop: a persistent full-height rail beside the app bar. Hidden below the
`md` breakpoint, where `docsNavBar` takes over — the same Tailwind-class swap
`Route/Examples/Shop.elm`'s own `navRail`/`navBar` pair already uses.
-}
docsNavRail : (Msg -> msg) -> UrlPath -> Element { s | navRail : M3e.Kind.Brand } admittedBy msg
docsNavRail toMsg path =
    M3e.navRail
        [ Aria.label "Sections"
        , M3e.Attributes.id "nav-rail"
        , TypedHtml.Attributes.class "hidden shrink-0 md:flex flex-col items-stretch w-fit"
        ]
        (M3e.iconButton
            [ Aria.label "Toggle rail width"
            , M3e.Component.IconButton.toggle True
            , TypedHtml.Attributes.class "mx-auto [:not([selected])]:[--m3e-nav-rail-icon-button-inset:auto]"
            ]
            [ M3e.Unsafe.fromHtml (Logo.view Logo.defaultColors)
            , M3e.Component.IconButton.selected (M3e.Unsafe.fromHtml (Logo.view Logo.invertedColors))
            , M3e.navRailToggle [ M3e.Component.NavRailToggle.for "nav-rail" ] []
            ]
            :: M3e.mapMsg toMsg (searchFab "mx-auto" OpenSearch)
            :: List.map (railItem path) sections
        )


{-| Mobile: a bottom nav bar, replacing the rail below the `md` breakpoint.

The bar is a REAL flex child of the shell (`view`'s outer
`flex flex-col md:flex-row`), not `position: fixed` -- so on mobile it takes
its own row at the bottom of the column and can't occlude anything above it.
That is what lets every scrollable region in the shell skip the compensating
`pb-20 md:pb-0` a floating bar would otherwise need, forever, in every
current and future scroll region.

Unlike the rail, `M3e.NavBar` does not admit a `fab` child
(`config/slots.json` only lists `navItem`), so the search FAB is rendered as
a floating sibling positioned above the bar, inside a `display: contents`
wrapper div so it contributes no box of its own -- which is what makes the
bar itself, not the wrapper, the flex child. The FAB stays `fixed`: a
Material FAB floats over content by design, and it sits in the bar's own
gutter (`bottom-20`) rather than displacing content.

-}
docsNavBar : (Msg -> msg) -> UrlPath -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy msg
docsNavBar toMsg path =
    TypedHtml.div
        [ TypedHtml.Attributes.class "contents" ]
        [ M3e.mapMsg toMsg (searchFab "fixed right-4 bottom-20 z-40 md:hidden" OpenSearch)
        , M3e.navBar
            [ Aria.label "Sections", TypedHtml.Attributes.class "shrink-0 md:hidden" ]
            (List.map (railItem path) sections)
        ]
