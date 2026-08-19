# Nav rail search — design

**Status:** Approved, ready for planning.

## Context

Follow-up to the nav-rail migration (`specs/2026-08-06-nav-rail-migration-design.md`).
While fixing the rail's clipping labels and making the tree drawer per-route,
the idea of adding a FAB at the top of the rail came up — matching
m3.material.io's own rail, which has a search entry point pinned above its
section items. This spec covers that FAB and the search feature it triggers.

## Goal

A FAB at the top of `docsNavRail`/`docsNavBar` opens a real, working
client-side search over page titles and headings — no server, no external
search service.

## What's already available

`@m3e/web` already ships the entire UI shell this needs, and elm-cem has
already generated typed Elm modules for all of it:

- `M3e.Fab` (`src/M3e/Fab.elm`) — the trigger. `NavRail`'s admits list
  (`config/slots.json`) already includes `fab` alongside `navItem`/
  `iconButton`, so it's a normal child, not a new slot to wire.
- `M3e.SearchBar` / `M3e.SearchView` (`src/M3e/SearchBar.elm`,
  `src/M3e/SearchView.elm`) — the search surface. `m3e-search-view` manages
  its own open/closed lifecycle, emits `query` (on open AND on every
  keystroke, carrying the current term) and `clear` events, and has a
  `mode` of `docked | fullscreen | auto` — `auto` picks the right one by
  viewport width, the same responsibility `DrawerContainer`'s own `auto`
  mode already has.
- `elm/http` is already an `docs/elm.json` dependency, and `Effect.fromCmd`
  (`docs/app/Effect.elm`) already exists as a generic `Cmd msg` escape hatch
  (used today for `Ports.storeScheme`). Fetching a runtime JSON index needs
  nothing new in `Effect`.

So this is an index + matching problem, not a UI-building problem.

## Architecture

The FAB is a pure trigger, not a search host. It sits in `docsNavRail`
(before the section items, matching m3.material.io's own layout) and only
flips `model.searchOpen`. It doesn't hold the input or results — the rail is
a fixed 96px column, too narrow for either.

The same FAB also goes in `docsNavBar` (the mobile bottom bar): Cmd/Ctrl+K
doesn't exist on a touch device, so without a mobile trigger, search would
be desktop-only. Both rails render the identical component with the same
`OpenSearch` click handler — one function, two call sites, no new UI.

The actual search surface, an `M3e.searchView`, mounts at the shell root as
a sibling of `settingsBottomSheet` in `Shared.view` — the same pattern
already established there: an overlay component keyed off one model
boolean, toggled by a trigger that lives elsewhere in the shell.
`M3e.SearchView.mode Value.auto` picks fullscreen-on-mobile /
docked-on-desktop on its own.

## Index scope and pipeline

**Scope:** page titles and headings only — no full body/prose text. Matches
"jump to a page or section by name," not "find this phrase buried in a
paragraph." Keeps the index small (an estimated tens of KB across ~130
routes) and the matching trivial (plain substring, no fuzzy-matching
library needed).

**Build step:** a new `docs/scripts/build-search-index.mjs`, chained onto
the end of `docs/package.json`'s `build:site`:

```json
"build:site": "elm-pages build && node scripts/build-search-index.mjs"
```

It runs against the just-built `dist/**/*.html` (crawling rendered output,
not Elm source — this needs no per-route opt-in, unlike `View.toc`, which
only a handful of routes currently populate). For each route it collects:

- the page `<title>`
- every `h1`–`h6` element inside `#main-content` (excluding the rail/app-bar/
  drawer chrome, which is identical on every page and would otherwise
  pollute every single entry)

A heading that carries a real `id` attribute (currently only pages using
`Doc.sectionHeadingWithId`) gets an anchor a search result can deep-link to
(`/page#id`); a heading without one just links to the page itself, no
anchor. This is a real, visible-but-acceptable degradation: as more pages
adopt `sectionHeadingWithId`, more search results gain in-page anchors,
with no change needed to the search feature itself.

Output: `dist/search-index.json`, a flat JSON array:

```json
[{ "url": "/guide", "title": "The Guide", "heading": null, "anchor": null },
 { "url": "/components/button", "title": "Button", "heading": "API", "anchor": "api" }]
```

Because this runs inside `build:site`, it's covered by the pre-push gate
fix already in place (`gate` runs `build:site` explicitly; `test:browser`'s
`pretest:browser` hook guarantees a fresh rebuild) — the index can't go
stale in the same way the old webServer-reuse gap risked for the site
itself.

## Elm wiring

`Shared.Model` gains:

- `searchOpen : Bool`
- `searchQuery : String`
- `searchIndex : Maybe (Result Http.Error (List SearchEntry))` — `Nothing`
  means "not yet requested." Loaded on the FIRST open, not eagerly on app
  boot (chosen over eager loading to avoid a request on visits that never
  touch search).

```elm
type alias SearchEntry =
    { url : String
    , title : String
    , heading : Maybe String
    , anchor : Maybe String
    }
```

`Msg` gains `OpenSearch`, `CloseSearch`, `SetSearchQuery String`,
`GotSearchIndex (Result Http.Error (List SearchEntry))`.

Opening (FAB click, or the new keyboard shortcut) sets `searchOpen = True`;
if `searchIndex == Nothing`, it also fires
`Http.get { url = "/search-index.json", expect = Http.expectJson GotSearchIndex searchEntryListDecoder }`
via `Effect.fromCmd`. A failed fetch stores `Just (Err ...)`, and the
results panel shows a plain "Search unavailable" message rather than
silently looking empty.

**Keyboard shortcut:** Cmd/Ctrl+K opens search from anywhere in the shell.
Chrome and Edge already bind Ctrl/Cmd+K to focusing the address bar; without
calling `preventDefault()` on the native keydown event, our shortcut would
fire ALONGSIDE that browser action rather than instead of it (both compete
for focus, breaking the shortcut). `Browser.Events.onKeyDown` only decodes
event data — it cannot call `preventDefault`. So this needs one incoming
port, `Ports.onOpenSearchRequested`, and a `document.addEventListener`
registered in `index.ts` that checks for Ctrl/Cmd+K, calls
`event.preventDefault()`, and sends on the port — the mirror image of the
existing outgoing `Ports.storeScheme` in the same file. Elm subscribes to
it in `Shared.subscriptions` exactly like any other subscription.

**Matching:** case-insensitive substring match against `heading` (falling
back to `title` when an entry has no heading), capped at the first 20
matches (in index order) so a broad query (e.g. a single common letter)
can't render an unbounded list.

**Results:** each match renders as a link (title, and heading as a
secondary line when present) inside the search view's default slot.
Clicking one navigates and closes the view — the same convention
`tocPanel`'s jump-links already follow for `CloseToc`.

**Scope note:** `/examples/*` routes render with no shell at all (no rail,
no app bar — a deliberate, already-decided exception from the nav-rail
migration). Search is therefore unavailable there, consistent with every
other piece of shell chrome (settings, theme controls) already being
unavailable on those routes.

## Testing

`docs/tests-browser/search.spec.ts`:

- the FAB opens the search view
- typing a query filters results to matching titles/headings
- Cmd/Ctrl+K opens the view from an arbitrary route
- clicking a result navigates to the right page (and anchor, when the
  matched heading has one) and closes the view
- a simulated fetch failure renders the "Search unavailable" state, not a
  silently empty panel
