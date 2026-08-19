# Nav Rail Migration — replacing the drawer nav with a persistent rail + per-section tree/TOC

Date: 2026-08-06
Repo: `elm-m3e`
Status: approved design, not yet planned

## Why

Material 3 has deprecated the nav-drawer pattern the docs shell currently uses
(`M3e.DrawerContainer`'s `start` slot holding `Shared.navMenu`, toggled by a hamburger
button). The replacement is a nav rail: a persistent, always-visible strip of top-level
destinations. Nav rail does not support nesting the way the drawer's `NavMenu`/`NavMenuItem`
tree did, so any section with children (all of them, today) needs somewhere else for its
sub-navigation to live.

## Audit: does every section have a landing page?

Six conceptual sections exist in the current drawer (`Shared.navSections` + `componentsGroup`
+ the `Reference` `navGroup`). Cross-referencing against the actual `Route/` tree:

| Section | Items | Landing route? |
|---|---|---|
| Getting Started | 2 (Installation, Browser Support) | **No** — no `/getting-started` route |
| The Guide | 15 | Yes — `/guide` (`Route/Guide.elm`) |
| Styles | 7 | **No** — no `/styles` route |
| Examples | 9 | Yes — `/examples` (`Route/Examples.elm`) |
| Components | 54 (flat alphabetical today) | **No** — closest is `/components/all`, a 329-example live-demo kitchen-sink page, not a lightweight landing page |
| Reference | 4 | **No**, and it is not a real route subtree — it mixes `/guide/cheat-sheet` + `/guide/glossary` (already inside Guide's own URL space) with two standalone pages (`/reference`, `/roundtrip`) |

Conclusion: this is not a pure layout change. Half the sections have no landing page, and
"Reference" does not correspond to any real URL hierarchy — it is a nav-only grouping.

Two more relevant facts surfaced during the audit:

- `data/reference.json` already splits all 54 nav-eligible components into 7 editorial
  categories (Navigation: 12, Text inputs: 8, Layout & style: 8, Containment: 9, Actions: 7,
  Communication: 5, Selection: 5) via `Shared.componentCategories`. That data is real and
  used elsewhere (`Route/Components/All.elm` orders its sections by it) but is **not**
  wired into the drawer's `componentsGroup`, which renders one flat alphabetical list.
- No TOC pattern exists anywhere in the docs app today. `M3e.Toc`/`M3e.TocItem` are unused
  library components.

## Decided information architecture

**Reference is dissolved.** `/guide/cheat-sheet` and `/guide/glossary` move into Guide's own
tree (they already live under Guide's URL space). `/reference` and `/roundtrip` become
standalone pages linked from Guide's landing content, not their own rail item. This leaves
**5 rail sections**: Getting Started, Guide, Styles, Examples, Components.

**Components' tree groups by category**, using the already-existing `componentCategories` +
each `NavComponent.category`, instead of one flat 54-item list. `/components/all` stays
pinned as its own leaf above the 7 category groups (matching how "All components" already
sits above the flat list today) — kept as a real, deliberately-clicked destination, not
removed.

**No new "index" routes for now.** Getting Started, Styles, and Components have no landing
page and none is created in this pass. The rail's link target for these three sections points
directly at the first real leaf — Getting Started → `/getting-started/installation`, Styles →
`/styles/color`, Components → `componentCategories`' first declared category (`"Actions"`),
that category's first member sorted alphabetically by label (matching the sort key
`componentsGroup` already uses today, just applied per-category instead of globally) —
skipping the pinned "All components" leaf, so the default isn't the heavy kitchen-sink page. Guide and Examples keep
linking to their existing real landing pages, unchanged. Lightweight overview pages for the
other three sections are accepted future follow-up work, explicitly out of scope here — when
they're built, that's when real `/getting-started`, `/styles`, `/components` routes get
created and the rail links get repointed at them.

This avoids needing any redirect mechanism (build-time or client-side) entirely — a real
question the design initially raised and then resolved away.

**Examples stays split in two.** The `/examples` gallery page joins the uniform rail+tree+TOC
shell like every other section. Individual example apps (`/examples/shop`,
`/examples/dashboard`, etc.) keep escaping the docs shell entirely — full viewport, no docs
rail, no docs app bar — exactly as today, because each example simulates a real app with its
own internal chrome (its own app bar, its own nav rail/bar). Wrapping that in a second layer
of rail+tree+TOC would be literal double-nav.

## Layout architecture

The rail runs the full viewport height on the leading edge, as a **sibling** of the app bar —
not, as today, a full-width app bar with the drawer/content below it:

```
Desktop:
┌────┬──────────────────────────────────────┐
│    │ AppBar (spans only the content side) │
│Rail ├────────┬─────────────┬───────────────┤
│    │  Tree   │   Content   │      TOC      │
└────┴──────────────────────────────────────┘

Mobile:
┌──────────────────────────────────────┐
│ AppBar                                │
├────────────────────────────────────────┤
│              Content                  │
├────────────────────────────────────────┤
│              NavBar                   │
└──────────────────────────────────────┘
```

Top-level split changes from today's single `flex-col` (app-bar row, then content row) to
`flex-row` (rail | main-column) on desktop; the main-column is itself `flex-col` (app-bar row,
then tree/content/TOC row). On mobile this collapses to a plain `flex-col` (app-bar, content,
nav-bar) — rail and nav-bar never coexist, matching the M3 rail↔bar breakpoint swap. `Model`
does not need to track this breakpoint itself (see below).

**Section-dispatch logic pattern-matches on `page.path : UrlPath` segments directly**,
replacing today's `String.startsWith` prefix checks. `UrlPath` (`type alias UrlPath = List
String`, from `dillonkearns/elm-pages`, already a dependency and already the type flowing
through `Shared.view`) and `Pages.PageUrl.PageUrl` (already imported in `Shared.elm`) already
model exactly what `lydell/elm-app-url`'s `AppUrl` would add — `path` as segments, `query` as
`Dict String (List String)`, `fragment` as `Maybe String`. Decision: do not add `elm-app-url`
as a dependency; use the existing `UrlPath`/`PageUrl` types. Two libraries modeling the same
"parsed URL" concept with different normalization rules (`AppUrl` drops one trailing slash;
`UrlPath.toSegments` just filters empty segments) would be a source of confusion for no added
capability.

## Tree + TOC are reused `DrawerContainer.start`/`end` slots, not bespoke columns

`M3e.DrawerContainer` (already used for today's nav drawer) supports `startMode`/`endMode`
values of `auto | over | push | side`. `auto` mode uses a built-in `M3eBreakpointObserver` to
switch automatically between `side` (pinned column) and `over`/`push` (temporary overlay)
based on viewport breakpoint — confirmed in `@m3e/web`'s compiled source
(`_M3eDrawerContainerElement_updateMode`, gated on `startMode === "auto"` /
`endMode === "auto"`).

Reusing the exact same component: `start` slot → section tree, `end` slot → TOC, both with
mode `auto`. This gets "pinned column on desktop, temporary overlay on mobile" for **both**
panels with zero custom breakpoint-tracking code in Elm — the `Model.viewportWidth` /
`ViewportResized` / `isMobile` machinery that used to exist for exactly this purpose (removed
in an earlier session) stays removed; the component's own `auto` mode replaces what that used
to do by hand.

## TOC content sourcing

`View` (currently carrying `title`/`body`) gains an optional field — `toc : List { id :
String, label : String }` — that each Route module populates by hand alongside its own
section headings, defaulting to `[]` for pages that don't need one. The end-drawer TOC panel
renders `View.toc pageView` as `<a href="#id">` jump-links; an empty list collapses the panel
rather than rendering an empty column.

**Gap found and needs closing first:** `Doc.sectionHeading` (the `<h2>` helper already used by
every guide/component page) does not assign an `id` today, so there is nowhere for a
`href="#id"` link to land. Smallest fix: add an `id : String` parameter to
`Doc.sectionHeading` (or a sibling variant); each page's `View.toc` entries pair the same ids
with labels. This is a small, contained addition to `Doc.elm` — not a redesign of it.

## Open items — flagged for implementation, not resolved here

These don't change the design's shape and aren't worth blocking the spec on:

- **Trigger affordances** for opening the tree/TOC panels when in overlay mode (mobile, or a
  narrow desktop window). Two independent panels now need two triggers, where today's drawer
  had one. Starting point: plain app-bar icon buttons, matching the existing precedent
  (`settingsButton` already does exactly this for the settings bottom sheet). A floating
  toolbar was raised as an alternative — worth trying only if icon buttons feel cramped once
  real content is in there.
- Whether `DrawerContainer`'s `side` mode still respects the `start`/`end` open boolean (i.e.,
  can a pinned desktop column be dismissed, or is `side` always-visible regardless of the
  attribute) — unverified against the compiled component source, doesn't change the design
  either way.

## Explicitly out of scope

- Rewriting any individual example app's (`Shop.elm`, `Dashboard.elm`, etc.) internal chrome.
- Writing the lightweight overview-page content for Getting Started, Styles, and Components —
  accepted as real future work, not blocking this migration.
- Any redirect mechanism — resolved away; see "no new index routes" above.

## Verification (once implementation lands)

- All 5 rail sections navigate correctly; the active section highlights based on path prefix.
- Components' tree shows 7 category groups (matching `componentCategories`' order) plus the
  pinned "All components" leaf above them; no flat 54-item list remains anywhere in the drawer
  path.
- Clicking a rail item with no further path segments lands on the right default: Guide/Examples
  on their existing landing pages; Getting Started/Styles/Components on their first real leaf.
- `/examples/*` individual example pages render exactly as today — full viewport, no docs rail,
  no docs app bar, no regression versus the current chrome-free behavior.
- Tree and TOC panels are `side` (pinned) at desktop widths and `over`/`push` (temporary,
  triggered) at mobile widths, with no custom viewport-tracking code in `Shared.elm`.
- A `View.toc` entry's jump-link actually scrolls to and highlights the matching heading.
- `npm run test:browser` green; `app-shell.spec.ts` (or its successor) updated to pin the new
  rail/tree/TOC contract the way it currently pins the drawer-based one.
