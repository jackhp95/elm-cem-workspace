# Nav Rail Search Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A FAB at the top of the nav rail/bar opens a real client-side search over page titles and headings, with a Cmd/Ctrl+K shortcut, no server and no external search service.

**Architecture:** A post-build Node script crawls the already-built `dist/**/index.html` (driven by elm-pages' own `dist/all-paths.json` route manifest) to produce `dist/search-index.json` (titles + headings + anchors). The Elm shell lazily fetches that JSON on first open, filters it with a plain case-insensitive substring match, and renders results into an `M3e.searchView` overlay — mounted only while open — triggered by an `M3e.fab` in both `docsNavRail` and `docsNavBar`, or by a Cmd/Ctrl+K shortcut wired through one new port (needed only because `Browser.Events.onKeyDown` cannot call `preventDefault`, and Chrome/Edge bind that shortcut to the address bar).

**Tech Stack:** Elm (elm-pages, `elm/http`), Node.js + `linkedom` (already a `docs` dependency) for the HTML crawl, Playwright for browser tests.

## Global Constraints

- Index scope is **titles and headings only** — no full body/prose text (spec: `specs/2026-08-07-nav-rail-search-design.md`).
- The crawler reads `dist/all-paths.json` for the route list — never globs `dist/**/*.html` directly (that manifest also contains non-route files like `template.html` and `elm-stuff/`).
- Index loading is **lazy**: fetched on first `query` event, not on app boot.
- Results are capped at **20 matches**, in index order.
- The Cmd/Ctrl+K shortcut needs a real incoming port (`Ports.onOpenSearchRequested`) — `Browser.Events.onKeyDown` alone cannot suppress the browser's own binding for that shortcut.
- `/examples/*` routes render with no shell (no rail, no FAB) — this is pre-existing, deliberate, and out of scope to change here.

---

### Task 1: Search index generator

**Files:**
- Create: `docs/scripts/search-index-gen/build-search-index.mjs`
- Create: `docs/scripts/search-index-gen/build-search-index.test.mjs`
- Modify: `docs/package.json` (add `test:search-index-gen`; chain the crawler directly into `build:site`)
- Modify: `package.json` (repo root — add `test:search-index-gen` to `test:fast`'s `run-p` list)

**Interfaces:**
- Produces: `extractEntries(html: string, url: string): Array<{url: string, title: string, heading: string|null, anchor: string|null}>` — a pure function, exported from `build-search-index.mjs`, consumed only by its own test in this task. No other task calls it directly (Task 2 only ever fetches the JSON file this script writes, at `/search-index.json`).
- Produces on disk: `dist/search-index.json` — a flat JSON array of the same shape, written by this script's `main()` after a full `dist/` crawl. Task 2 fetches this at runtime.

- [ ] **Step 1: Write the failing test for `extractEntries`**

Create `docs/scripts/search-index-gen/build-search-index.test.mjs`:

```js
import { test } from "node:test";
import assert from "node:assert/strict";
import { extractEntries } from "./build-search-index.mjs";

test("a page with no #main-content indexes only its title", () => {
  const html = `<html><head><title>Shop · elm-m3e</title></head><body><h1>Shop</h1></body></html>`;
  const entries = extractEntries(html, "/examples/shop");
  assert.deepEqual(entries, [
    { url: "/examples/shop", title: "Shop · elm-m3e", heading: null, anchor: null },
  ]);
});

test("a page with headings inside #main-content indexes the page plus each heading", () => {
  const html = `<html><head><title>Button · elm-m3e</title></head><body>
    <nav><h2>Should not appear (outside main-content)</h2></nav>
    <main id="main-content">
      <h1>Button</h1>
      <h2 id="api">API</h2>
      <h2>No id here</h2>
    </main>
  </body></html>`;
  const entries = extractEntries(html, "/components/button");
  assert.deepEqual(entries, [
    { url: "/components/button", title: "Button · elm-m3e", heading: null, anchor: null },
    { url: "/components/button", title: "Button · elm-m3e", heading: "Button", anchor: null },
    { url: "/components/button", title: "Button · elm-m3e", heading: "API", anchor: "api" },
    { url: "/components/button", title: "Button · elm-m3e", heading: "No id here", anchor: null },
  ]);
});

test("a heading with only whitespace text is skipped", () => {
  const html = `<html><head><title>X</title></head><body>
    <main id="main-content"><h1>   </h1><h2>Real heading</h2></main>
  </body></html>`;
  const entries = extractEntries(html, "/x");
  assert.deepEqual(entries, [
    { url: "/x", title: "X", heading: null, anchor: null },
    { url: "/x", title: "X", heading: "Real heading", anchor: null },
  ]);
});

test("a page with no <title> is skipped entirely (returns no entries)", () => {
  const html = `<html><head></head><body><main id="main-content"><h1>Orphan</h1></main></body></html>`;
  const entries = extractEntries(html, "/orphan");
  assert.deepEqual(entries, []);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `cd docs && node --test scripts/search-index-gen/build-search-index.test.mjs`
Expected: FAIL — `build-search-index.mjs` does not exist yet, so the import throws.

- [ ] **Step 3: Write `extractEntries` and the crawl script**

Create `docs/scripts/search-index-gen/build-search-index.mjs`:

```js
// Builds dist/search-index.json (titles + headings, no body text — see
// specs/2026-08-07-nav-rail-search-design.md) by crawling the already-built
// dist/**/index.html. Runs AFTER `elm-pages build` (chained into
// `build:site`), never before: it reads rendered output, not Elm source.
//
// The route list comes from elm-pages' own dist/all-paths.json manifest, not
// a glob over dist/**/*.html -- that directory also holds non-route files
// (template.html, elm-stuff/) a glob would have to hand-exclude.

import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { parseHTML } from "linkedom";

const here = path.dirname(fileURLToPath(import.meta.url));
const DIST = path.resolve(here, "../../dist");
const ALL_PATHS = path.resolve(DIST, "all-paths.json");
const OUT = path.resolve(DIST, "search-index.json");

const HEADING_SELECTOR = "#main-content h1, #main-content h2, #main-content h3, #main-content h4, #main-content h5, #main-content h6";

/**
 * Pure: given one page's rendered HTML and its route path, returns the
 * search entries for that page (the page itself, heading = null, plus one
 * entry per non-empty heading found inside #main-content). Headings outside
 * #main-content (the rail/app-bar/drawer chrome, identical on every page)
 * are not selected in the first place -- `HEADING_SELECTOR` scopes to
 * `#main-content` directly, so there's nothing to filter out afterward.
 *
 * A page with no #main-content (the `/examples/*` routes, which render with
 * no docs shell at all) indexes its title only -- `document.querySelectorAll`
 * on a missing ancestor simply matches nothing, so this falls out of the
 * selector rather than needing a special case.
 *
 * A page with no <title> returns no entries at all (skipped, not crashed --
 * elm-pages guarantees a title on every real route, so this only guards
 * against a malformed/unexpected file, not the normal case).
 */
export function extractEntries(html, url) {
  const { document } = parseHTML(html);
  const title = document.querySelector("title")?.textContent;
  if (!title) return [];

  const entries = [{ url, title, heading: null, anchor: null }];
  for (const el of document.querySelectorAll(HEADING_SELECTOR)) {
    const heading = el.textContent.trim();
    if (!heading) continue;
    entries.push({ url, title, heading, anchor: el.id || null });
  }
  return entries;
}

function fileForPath(routePath) {
  return routePath === "/"
    ? path.join(DIST, "index.html")
    : path.join(DIST, routePath, "index.html");
}

function main() {
  const routes = JSON.parse(fs.readFileSync(ALL_PATHS, "utf8"));
  const entries = routes.flatMap((routePath) => {
    const file = fileForPath(routePath);
    if (!fs.existsSync(file)) {
      console.warn(`search-index: no HTML file for route ${routePath} (expected ${file}), skipping`);
      return [];
    }
    return extractEntries(fs.readFileSync(file, "utf8"), routePath);
  });
  fs.writeFileSync(OUT, JSON.stringify(entries));
  console.log(`search-index: wrote ${entries.length} entries (${routes.length} routes) to ${OUT}`);
}

// Only run the crawl when executed directly (`node build-search-index.mjs`),
// not when the test file imports `extractEntries`.
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `cd docs && node --test scripts/search-index-gen/build-search-index.test.mjs`
Expected: PASS, 4 tests.

- [ ] **Step 5: Wire the script into `build:site` and the test into the gate**

Modify `docs/package.json`'s scripts (exact current lines, from the top of the `scripts` block):

```json
"build:site": "elm-pages build && node scripts/search-index-gen/build-search-index.mjs",
```

(was `"build:site": "elm-pages build",`)

Add a new script, next to the other `test:*-gen` entries:

```json
"test:search-index-gen": "node --test scripts/search-index-gen/*.test.mjs",
```

Modify root `package.json`: add `"test:search-index-gen": "npm --prefix docs run test:search-index-gen"` next to the existing `"test:icons-gen"` line, and add `test:search-index-gen` to the `run-p` list in `"test:fast"`:

```json
"test:fast": "run-p test:elm test:examples-gen test:samples-gen test:roundtrip test:icons-gen test:search-index-gen",
```

- [ ] **Step 6: Verify the full crawl runs against a real build**

Run: `cd docs && npm run build:site`
Expected: elm-pages build succeeds, then a `search-index: wrote N entries (181 routes) to .../dist/search-index.json` line (N will be in the low hundreds). Confirm the file exists and is valid JSON:

Run: `node -e "const e = require('./docs/dist/search-index.json'); console.log(e.length, e[0])"` (from the repo root)
Expected: prints a count and the first entry, no error.

- [ ] **Step 7: Commit**

```bash
git add docs/scripts/search-index-gen docs/package.json package.json
git commit -m "Add the search-index crawler, chained into build:site"
```

---

### Task 2: Elm wiring — FAB, search overlay, filtering

**Files:**
- Modify: `docs/app/Shared.elm`
- Create: `docs/tests-browser/search.spec.ts` (started here, extended in Task 3)

**Interfaces:**
- Consumes: `dist/search-index.json` (Task 1's output), fetched at runtime as `/search-index.json`. Shape: `List { url : String, title : String, heading : Maybe String, anchor : Maybe String }`.
- Produces: `Msg` cases `OpenSearch`, `CloseSearch`, `SetSearchQuery String`, `GotSearchIndex (Result Http.Error (List SearchEntry))` — Task 3's port subscription dispatches `OpenSearch` the same way the FAB's click does, so it depends on this case existing.
- Produces: `Model` fields `searchOpen : Bool`, `searchQuery : String`, `searchIndex : Maybe (Result Http.Error (List SearchEntry))`.

- [ ] **Step 1: Add `Http` to imports**

In `docs/app/Shared.elm`, add to the import list (alphabetically, after `Html exposing (Html)`):

```elm
import Http
```

- [ ] **Step 2: Add the `SearchEntry` type and its decoder**

Add near `NavComponent` (after its type alias, around line 106):

```elm
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
```

- [ ] **Step 3: Add the three `Model` fields**

Modify the `Model` type alias (around line 88) — add after `settingsOpen : Bool`:

```elm
type alias Model =
    { treeOpen : Bool
    , tocOpen : Bool
    , viewportWidth : Int
    , scheme : Value Value.Scheme
    , seed : String
    , contrast : Value Value.Contrast
    , density : Float
    , dir : TypedHtml.Values.Value TypedHtml.Values.Dir
    , settingsOpen : Bool
    , searchOpen : Bool
    , searchQuery : String
    , searchIndex : Maybe (Result Http.Error (List SearchEntry))
    }
```

Modify `init` (around line 235) — add to the record it returns:

```elm
    ( { treeOpen = treePinsOpen width
      , tocOpen = tocPinsOpen width
      , viewportWidth = width
      , scheme = schemeFromFlags flags
      , seed = "#6750A4"
      , contrast = Value.standard
      , density = 0
      , dir = TypedHtml.Values.ltr
      , settingsOpen = False
      , searchOpen = False
      , searchQuery = ""
      , searchIndex = Nothing
      }
    , Effect.none
    )
```

- [ ] **Step 4: Add the four `Msg` cases**

Modify the `Msg` type (around line 200) — add before `SetScheme`:

```elm
    | OpenSearch
    | CloseSearch
    | SetSearchQuery String
    | GotSearchIndex (Result Http.Error (List SearchEntry))
```

- [ ] **Step 5: Add the `update` cases**

Modify `update` (around line 342) — add before the `SetScheme` case:

```elm
        OpenSearch ->
            ( { model | searchOpen = True }, Effect.none )

        -- Fired by CloseSearch itself, by a result link's click (see
        -- searchResultLink), and by searchToggleDecoder when the search
        -- view's own internal back button closes it -- the same
        -- element-can-close-itself sync `SettingsSheetClosed` already
        -- handles for the bottom sheet.
        CloseSearch ->
            ( { model | searchOpen = False }, Effect.none )

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
```

- [ ] **Step 6: Add the `query`/`toggle` event decoders**

Add near `drawerChangeDecoder` (after it, around line 1040):

```elm
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
```

- [ ] **Step 7: Add the FAB and thread it through `docsNavRail`/`docsNavBar`**

Modify `docsNavRail` and `docsNavBar` (around line 1200) to take a `toMsg` and return a concrete `Msg`-typed element (matching how `appShellBar`/`settingsBottomSheet` are already wrapped at their call sites), and add `searchFab`:

```elm
docsNavRail : (Msg -> msg) -> UrlPath -> Element { s | navRail : M3e.Kind.Brand } admittedBy msg
docsNavRail toMsg path =
    M3e.navRail
        [ Aria.label "Sections", TypedHtml.Attributes.class "hidden shrink-0 md:flex" ]
        (M3e.mapMsg toMsg (searchFab OpenSearch) :: List.map (railItem path) sections)


docsNavBar : (Msg -> msg) -> UrlPath -> Element { s | navBar : M3e.Kind.Brand } admittedBy msg
docsNavBar toMsg path =
    M3e.navBar
        [ Aria.label "Sections", TypedHtml.Attributes.class "fixed inset-x-0 bottom-0 z-30 md:hidden" ]
        (M3e.mapMsg toMsg (searchFab OpenSearch) :: List.map (railItem path) sections)


{-| The search trigger, shared by the rail and the bottom bar -- a plain
icon FAB, `size small` (matching @m3e/web's own nav-rail usage example in
`NavRailElement.d.ts`), opening the search overlay (`searchOverlay`). Both
`NavRail` and `NavBar` admit `fab` directly in their unnamed slot
(`config/slots.json`), alongside `navItem`, so this is a normal child, not a
new slot to wire.
-}
searchFab : msg -> Element { s | fab : M3e.Kind.Brand } admittedBy msg
searchFab openMsg =
    M3e.fab
        [ M3e.Attributes.size Value.small
        , Aria.label "Search"
        , M3e.Events.onClick openMsg
        ]
        [ M3e.icon [ M3e.Icon.name "search" ] [] ]
```

Update the two call sites in `view` (around line 500):

```elm
                [ skipLink
                , TypedHtml.div [ TypedHtml.Attributes.class "h-dvh flex flex-row" ]
                    [ docsNavRail toMsg page.path
                    , TypedHtml.div [ TypedHtml.Attributes.class "flex flex-1 flex-col min-w-0" ]
                        [ M3e.mapMsg toMsg (appShellBar (View.toc pageView))
                        , drawerShell toMsg model page sharedData.components (View.toc pageView) (View.body pageView)
                        ]
                    , docsNavBar toMsg path
                    ]
                , M3e.mapMsg toMsg (settingsBottomSheet model)
                , M3e.mapMsg toMsg (searchOverlay model)
                ]
```

No OUTER `M3e.mapMsg toMsg (...)` around the two rail/bar calls — `docsNavRail`/`docsNavBar` already return `Element ... msg` directly (they apply `toMsg` internally, only to `searchFab`'s one `Msg`-typed child; `railItem`'s results are already polymorphic in `msg` and need no mapping at all). Wrapping them again would be mapping `Msg -> msg` over something that's already `msg`-typed, not `Msg`-typed — a type error, not just redundant.

Note the existing call used the bare local `path` for `docsNavBar`, not `page.path` — keep using that same existing binding, only adding the new `toMsg` argument.

- [ ] **Step 8: Add `searchOverlay` — the conditionally-mounted search view**

Add near `settingsBottomSheet` (after it, before the "SIDEBAR NAVIGATION" section comment):

```elm
{-| The search overlay. Unlike `settingsBottomSheet` (always mounted, toggled
via its own `open` attribute), this is only mounted in the DOM at all while
`model.searchOpen`: `m3e-search-view` renders a persistent, full-width pill
bar whenever it's present and NOT open (verified against a live build --
neither `contained` nor any other attribute suppresses it), and nothing in
this layout wants that pill sitting anywhere -- the FAB is the only visible
trigger. Conditional rendering sidesteps needing to suppress it via CSS.

`mode Value.auto` picks fullscreen on mobile / docked on desktop on its own,
the same responsibility `DrawerContainer`'s own `auto` mode already has.
`open True` is set unconditionally here since the element is never mounted
in any other state.
-}
searchOverlay : Model -> Element (M3e.SearchView.Is s) admittedBy Msg
searchOverlay model =
    if not model.searchOpen then
        M3e.text ""

    else
        M3e.searchView
            [ M3e.SearchView.mode Value.auto
            , M3e.SearchView.open True
            , M3e.Events.onQueryWith searchQueryDecoder
            , M3e.Events.onToggleWith searchToggleDecoder
            ]
            [ M3e.SearchView.input
                (TypedHtml.input
                    [ TypedHtml.Attributes.type_ "text"
                    , TypedHtml.Attributes.placeholder "Search..."
                    , TypedHtml.Attributes.value model.searchQuery
                    ]
                    []
                )
            , M3e.SearchView.child (searchResults model)
            ]


{-| The results list (or an empty-state hint). `filterSearchEntries` never
runs against an unloaded or failed index -- both surface their own message
instead, so a failed fetch is visibly "Search unavailable," not a silently
empty panel.
-}
searchResults : Model -> Element { s | sharedText : M3e.Kind.Shared } admittedBy Msg
searchResults model =
    case model.searchIndex of
        Nothing ->
            TypedHtml.div [ TypedHtml.Attributes.class "p-4 text-on-surface-variant" ] [ M3e.text "Loading..." ]

        Just (Err _) ->
            TypedHtml.div [ TypedHtml.Attributes.class "p-4 text-on-surface-variant" ] [ M3e.text "Search unavailable" ]

        Just (Ok entries) ->
            if String.isEmpty (String.trim model.searchQuery) then
                TypedHtml.div [ TypedHtml.Attributes.class "p-4 text-on-surface-variant" ] [ M3e.text "Type to search" ]

            else
                case filterSearchEntries model.searchQuery entries of
                    [] ->
                        TypedHtml.div [ TypedHtml.Attributes.class "p-4 text-on-surface-variant" ] [ M3e.text "No results" ]

                    matches ->
                        TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-1 p-2" ]
                            (List.map searchResultLink matches)


{-| Case-insensitive substring match against `heading` (falling back to
`title` for a page-level entry, where `heading = Nothing`), capped at the
first 20 matches in index order -- see Global Constraints.
-}
filterSearchEntries : String -> List SearchEntry -> List SearchEntry
filterSearchEntries query entries =
    let
        needle : String
        needle =
            String.toLower (String.trim query)
    in
    entries
        |> List.filter
            (\entry -> String.contains needle (String.toLower (Maybe.withDefault entry.title entry.heading)))
        |> List.take 20


{-| One result. Primary text is the matched heading when the entry is a
heading, falling back to the page title for a page-level entry (`heading =
Nothing`) -- the mirror image of `filterSearchEntries`' own "match heading,
fall back to title" rule, so what's highlighted is always whichever string
the query actually matched. The page title renders as a secondary line
ONLY for a heading entry (context: "this heading lives on that page"); a
page-level entry has nothing to add below its own title.

This distinction also keeps results from colliding in the accessible tree:
a heading entry named e.g. "Button" (the h1 text) and the page-level entry
named "Button · elm-m3e" (the real `<title>`, which is never bare "Button")
are two different accessible names, not the same string rendered twice.

Clicking navigates (real `a[href]`, an anchor when the heading has a real
id) and fires `CloseSearch` -- the same "navigate closes the panel"
convention `tocPanel`'s jump-links already follow for `CloseToc`.
-}
searchResultLink : SearchEntry -> Element { navItem : M3e.Kind.Brand } admittedBy Msg
searchResultLink entry =
    TypedHtml.a
        [ TypedHtml.Attributes.href (entry.url ++ (entry.anchor |> Maybe.map (\a -> "#" ++ a) |> Maybe.withDefault ""))
        , TypedHtml.Attributes.class "flex flex-col gap-0.5 rounded-lg px-3 py-2 hover:bg-surface-container-highest"
        , TypedHtml.Events.onClick CloseSearch
        ]
        (M3e.text (Maybe.withDefault entry.title entry.heading)
            :: (case entry.heading of
                    Just _ ->
                        [ TypedHtml.div [ TypedHtml.Attributes.class "text-on-surface-variant text-sm" ] [ M3e.text entry.title ] ]

                    Nothing ->
                        []
               )
        )
```

`searchResultLink`'s exact return-type row (`{ navItem : M3e.Kind.Brand }`) is a starting guess to satisfy `M3e.SearchView.child`'s admits (`"unnamed": {"kinds": ["any"]}` per `config/slots.json`'s `SearchView` entry — "any" should accept a plain `TypedHtml.a`, matching how `tocPanel` already puts a bare `TypedHtml.a` inside `M3e.DrawerContainer.end`'s "any"-kinded slot). If `elm make` disagrees, adjust the row to whatever it reports — this is exactly the kind of small signature mismatch Step 9 exists to catch.

- [ ] **Step 9: Compile and fix type errors**

Run: `cd docs && npx elm make app/Shared.elm --output=/dev/null`
Expected: eventually `Success!` — work through whatever mismatches the compiler reports one at a time (row-type signatures on `searchOverlay`/`searchResults`/`searchResultLink`/`docsNavRail`/`docsNavBar` are the most likely spots; the plan's signatures are a concrete starting point, not a guarantee).

- [ ] **Step 10: Format**

Run: `cd .. && node_modules/.bin/elm-format --yes docs/app/Shared.elm`

- [ ] **Step 11: Write the first Playwright test**

Create `docs/tests-browser/search.spec.ts`:

```typescript
import { test, expect } from "@playwright/test";

/**
 * The search FAB (top of the rail on desktop, top of the bottom bar on
 * mobile) opens `m3e-search-view`, lazily fetching `/search-index.json` on
 * the first `query` event (fired when the view opens, term = ""). Results
 * are a plain case-insensitive substring match against title/heading,
 * capped at 20 -- see specs/2026-08-07-nav-rail-search-design.md.
 */
test("the FAB opens search, typing filters results, and clicking a result navigates and closes it", async ({
  page,
}) => {
  await page.goto("/");
  await page.getByRole("button", { name: "Search", exact: true }).click();

  const view = page.locator("m3e-search-view");
  await expect(view).toHaveAttribute("open", "");

  const input = view.locator("input");
  await input.fill("button");

  const result = view.getByRole("link", { name: "Button", exact: true });
  await expect(result).toBeVisible();

  await result.click();
  await expect(page).toHaveURL(/\/components\/button$/);
  await expect(page.locator("m3e-search-view")).toHaveCount(0);
});

test("clicking a heading result navigates to that heading's real anchor", async ({ page }) => {
  // /components/button is the one page end-to-end wired with a real anchored
  // heading (`Doc.sectionHeadingWithId "api" "API"`) -- see Route/Components/Name_.elm.
  await page.goto("/");
  await page.getByRole("button", { name: "Search", exact: true }).click();

  const view = page.locator("m3e-search-view");
  await view.locator("input").fill("API");

  const result = view.getByRole("link", { name: "API", exact: true });
  await expect(result).toHaveAttribute("href", "/components/button#api");

  await result.click();
  await expect(page).toHaveURL(/\/components\/button#api$/);
});
```

- [ ] **Step 12: Run it to verify it fails, then build the site and verify it passes**

Run: `cd docs && npm run build:site && PORT=1239 npm run serve &`
Run (separately): `cd docs && npx playwright test tests-browser/search.spec.ts`
Expected: PASS. (If the FAB's accessible role/name doesn't match `getByRole("button", {name: "Search"})`, inspect via `npx playwright test tests-browser/search.spec.ts --debug` and adjust the locator — `m3e-fab` may expose a different implicit role than a plain button; match whatever it actually is, the same way `nav-rail.spec.ts` had to verify `m3e-nav-item`'s real role rather than assume one.)

- [ ] **Step 13: Commit**

```bash
git add docs/app/Shared.elm docs/tests-browser/search.spec.ts
git commit -m "Add the search FAB, overlay, and filtering to the docs shell"
```

---

### Task 3: Cmd/Ctrl+K shortcut, remaining tests, gate

**Files:**
- Modify: `docs/app/Ports.elm`
- Modify: `docs/index.ts`
- Modify: `docs/app/Shared.elm` (subscription only)
- Modify: `docs/tests-browser/search.spec.ts`

**Interfaces:**
- Consumes: `Msg.OpenSearch` (Task 2) — the port subscription dispatches the exact same `Msg` the FAB's `onClick` does.

- [ ] **Step 1: Add the incoming port**

Modify `docs/app/Ports.elm`:

```elm
port module Ports exposing (onOpenSearchRequested, storeScheme)

{-| Client-side ports for the docs app. Wired to the browser in `index.ts`.

@docs onOpenSearchRequested, storeScheme

-}


{-| Persist the chosen color scheme (`"auto"` | `"light"` | `"dark"`) to
`localStorage` so it survives reloads. `index.ts` subscribes and writes it; the
saved value is read back as a flag and applied in `Shared.init`.
-}
port storeScheme : String -> Cmd msg


{-| Fired when the user presses Cmd/Ctrl+K anywhere in the app. `index.ts`
registers a real `document.addEventListener("keydown", ...)` and calls
`event.preventDefault()` before sending on this port -- Chrome and Edge bind
that shortcut to focusing the address bar, and `Browser.Events.onKeyDown`
cannot call `preventDefault` (it only decodes event data), so without this
port our shortcut would fire ALONGSIDE the browser's, not instead of it.
-}
port onOpenSearchRequested : (() -> msg) -> Sub msg
```

- [ ] **Step 2: Send on the port from `index.ts`**

Modify `docs/index.ts` — add inside the `load` function's `config`, after the `storeScheme` subscription:

```typescript
    document.addEventListener("keydown", (event) => {
      const isSearchShortcut = (event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k";
      if (!isSearchShortcut) return;
      event.preventDefault();
      app?.ports?.onOpenSearchRequested?.send(null);
    });
```

(`app.ports.onOpenSearchRequested` is typed as `{ send: (v: null) => void }` by Elm's own generated port typing; the existing `type ElmPagesInit`/`app` cast in this file only names `storeScheme`'s shape today — extend that inline type the same way, or use `as any` for this one send call if the existing cast doesn't cover it. Match whatever the existing file's cast style already does for `storeScheme`.)

- [ ] **Step 3: Subscribe in `Shared.elm`**

Modify `subscriptions` (around line 430):

```elm
subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Sub.batch
        [ Browser.Events.onResize (\w _ -> ViewportResized w)
        , Ports.onOpenSearchRequested (\_ -> OpenSearch)
        ]
```

(`Ports` is already imported in `Shared.elm` — no new import needed.)

- [ ] **Step 4: Verify Cmd/Ctrl+K live, add the remaining Playwright tests**

Add to `docs/tests-browser/search.spec.ts`:

```typescript
test("Cmd/Ctrl+K opens search from an arbitrary route", async ({ page }) => {
  await page.goto("/guide");
  await page.keyboard.press("ControlOrMeta+k");
  await expect(page.locator("m3e-search-view")).toHaveAttribute("open", "");
});

test("a failed index fetch shows an unavailable message, not a silently empty panel", async ({
  page,
}) => {
  await page.route("**/search-index.json", (route) => route.abort());
  await page.goto("/");
  await page.getByRole("button", { name: "Search", exact: true }).click();
  await page.locator("m3e-search-view input").fill("button");
  await expect(page.getByText("Search unavailable")).toBeVisible();
});
```

- [ ] **Step 5: Run the full search suite**

Run: `cd docs && npm run build:site && PORT=1239 npm run serve &` then `npx playwright test tests-browser/search.spec.ts`
Expected: PASS, all 4 tests.

- [ ] **Step 6: `npm run gate` clean pass**

Run (from repo root): `npm run gate`
Expected: `check`, `build:site` (now including the search-index crawl), and the full `test` suite (including `test:search-index-gen` and the new `search.spec.ts`) all pass, 0 failures. Fix anything red before proceeding — this is the same bar every prior task in this project's history has been held to.

- [ ] **Step 7: Commit**

```bash
git add docs/app/Ports.elm docs/index.ts docs/app/Shared.elm docs/tests-browser/search.spec.ts
git commit -m "Add Cmd/Ctrl+K search shortcut; full gate pass"
```
