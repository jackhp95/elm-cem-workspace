# Nav Rail Tree + TOC — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Repurpose the existing hamburger-drawer's `start`/`end` slots into pinned-on-desktop, overlay-on-mobile tree and TOC panels; dissolve the "Reference" nav-only grouping; regroup the Components tree by category; add a `View.toc` field pages can opt into.

**Architecture:** `M3e.DrawerContainer.startMode`/`endMode` move from `over` to `auto` (confirmed in `@m3e/web`'s compiled source: `auto` picks `side`/`push`/`over` per breakpoint, but never touches the `start`/`end` open **boolean** itself — that stays entirely our responsibility, same as today). Restoring viewport-width tracking (removed in an earlier session, needed again now) drives the correct default: open (pinned) on desktop, closed (collapsed) on mobile. Components' flat 54-item list becomes 7 `navGroup` sub-groups (reusing the existing `navGroup` helper unmodified) driven by the already-existing `componentCategories` data. `View` gains an additive `toc` field defaulting to `[]`, and `Doc.sectionHeadingWithId` is added alongside (not replacing) `Doc.sectionHeading` so only pages that opt in need any change.

**Tech Stack:** Elm 0.19, elm-pages 3.5, Playwright (`docs/tests-browser/`), Tailwind 4.

**Spec:** `specs/2026-08-06-nav-rail-migration-design.md`

## Global Constraints

- **Blocked on `plans/2026-08-06-nav-rail-layout.md`.** That plan adds `docsNavRail`/`docsNavBar`/`Section` and restructures `view`'s top-level layout to `flex-row`; this plan only touches `drawerShell`'s internals (the `start`/`end` slots) and does not re-touch the outer layout.
- **`DrawerContainer`'s `start`/`end` open booleans are not automatically managed by `auto` mode.** Verified against `@m3e/web/dist/drawer-container.js`'s `_updateMode`: it only ever sets `this.start = false` / `this.end = false` when shrinking from `side` into `push`/`over` (`autoCloseStart`/`autoCloseEnd`); it never sets either to `true`, on mount or on a mobile→desktop resize. Task 1 restores the Elm-side tracking this requires.
- **This restores infrastructure that existed before and was removed.** `git show fba5f46e -- '*Shared.elm'` (2026-06-25, an earlier iteration of this shell, predating the `Ui.*` → `M3e.*` rename) shows the original `viewportWidth`/`ViewportResized`/`isMobile`/`mdBreakpointPx` shape. Task 1 rebuilds the same shape against the current `M3e.DrawerContainer` API, not a line-for-line port (the component API has changed since).
- `initialViewportWidth : Pages.Flags.Flags -> Int` already exists (`Shared.elm:138-146`) and is currently dead code (unused — one of the 4 pre-existing `elm-review` findings). Task 1 wires it into `init`, which resolves that finding as a side effect.
- The static site must be rebuilt (`npm run build:site`) and re-served (`PORT=1239 npm run serve`, after `pkill -f "PORT=1239"`) before any Playwright run.

---

### Task 1: Restore viewport-width tracking

**Files:**
- Modify: `docs/app/Shared.elm` — `Model` (`:69-77`), `Msg` (`:96-106`), `init` (`:109-132`), `update` (`:169-211`), `subscriptions` (`:217-219`)
- Test: `docs/tests-browser/nav-rail.spec.ts` (extend)

**Interfaces:**
- Consumes: `initialViewportWidth : Pages.Flags.Flags -> Int` (already exists).
- Produces: `Model.viewportWidth : Int`; `mdBreakpointPx : Int`; `isMobile : Model -> Bool`; `Msg.ViewportResized Int`. Task 2's `drawerShell` changes consume `isMobile model`.

- [ ] **Step 1: Write the failing test**

Add to `docs/tests-browser/nav-rail.spec.ts`:

```ts
test("tree panel is open (pinned) by default on desktop, closed by default on mobile", async ({
  page,
}) => {
  await page.goto("/guide");
  await expect(page.locator("#docs-drawer")).toHaveAttribute("start", "");

  await page.setViewportSize({ width: 411, height: 761 });
  await page.goto("/guide");
  await expect(page.locator("#docs-drawer")).not.toHaveAttribute("start", "");
});
```

- [ ] **Step 2: Build, serve, run it to verify it fails**

```bash
cd docs
npm run build:site
pkill -f "PORT=1239" 2>/dev/null; (PORT=1239 npm run serve > /tmp/serve.log 2>&1 &); sleep 2
BASE_URL=http://localhost:1239 npx playwright test tests-browser/nav-rail.spec.ts -g "pinned"
```

Expected: FAIL — `#docs-drawer`'s `start` attribute is currently driven by `model.showMenu`, which defaults to `False` unconditionally (`Shared.elm:123`), so the desktop assertion fails.

- [ ] **Step 3: Add `viewportWidth`/`isMobile` to `Model` and wire `init`**

In `docs/app/Shared.elm`, `Model` (currently `:69-77`):

```elm
type alias Model =
    { showMenu : Bool
    , viewportWidth : Int
    , scheme : Value Value.Scheme
    , seed : String
    , contrast : Value Value.Contrast
    , density : Float
    , dir : TypedHtml.Values.Value TypedHtml.Values.Dir
    , settingsOpen : Bool
    }
```

Add, right after `NavComponent`/`Data` and before `Msg` (i.e. before today's `:96`):

```elm
{-| The Tailwind `md` breakpoint — kept in Elm only because the tree/TOC
drawer panels' `start`/`end` open state is a Lit JS property, not CSS state,
so Elm has to decide up front whether they start pinned-open (desktop) or
collapsed (mobile). `DrawerContainer`'s own `auto` mode only picks WHICH
visual mode (`side`/`push`/`over`) applies at a breakpoint — verified against
`@m3e/web/dist/drawer-container.js`'s `_updateMode`, it never sets the
`start`/`end` boolean itself except to auto-CLOSE when shrinking into
`push`/`over`. Restored from `fba5f46e` (2026-06-25), removed since, needed
again for this reason.
-}
mdBreakpointPx : Int
mdBreakpointPx =
    768


isMobile : Model -> Bool
isMobile model =
    model.viewportWidth < mdBreakpointPx
```

`Msg` (currently `:96-106`), add `ViewportResized Int`:

```elm
type Msg
    = MenuClicked
    | CloseMenu
    | ToggleSettings
    | SettingsSheetClosed
    | DrawerChanged Bool
    | ViewportResized Int
    | SetScheme (Value Value.Scheme)
    | SetSeed String
    | SetContrast (Value Value.Contrast)
    | SetDensity Float
    | SetDirection (TypedHtml.Values.Value TypedHtml.Values.Dir)
```

`init` (currently `:122-132`), add `viewportWidth`:

```elm
init flags _ =
    ( { showMenu = False
      , viewportWidth = initialViewportWidth flags
      , scheme = schemeFromFlags flags
      , seed = "#6750A4"
      , contrast = Value.standard
      , density = 0
      , dir = TypedHtml.Values.ltr
      , settingsOpen = False
      }
    , Effect.none
    )
```

- [ ] **Step 4: Handle `ViewportResized` in `update` and subscribe in `subscriptions`**

`update` (currently `:169-211`), add a case (placement doesn't matter — suggested right after `DrawerChanged`):

```elm
        ViewportResized width ->
            ( { model | viewportWidth = width }, Effect.none )
```

`subscriptions` (currently `:217-219`):

```elm
subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Browser.Events.onResize (\w _ -> ViewportResized w)
```

(`Browser.Events` is already imported at `Shared.elm:19` — it was unused until now, clearing another of the 4 pre-existing `elm-review` findings as a side effect.)

- [ ] **Step 5: Wire `isMobile`/`showMenu` into the drawer's `start` attribute**

This is a preview of Task 2's fuller `drawerShell` change — just enough here to make Step 1's test pass. In `drawerShell` (currently `:714-720`), change:

```elm
        [ M3e.drawerContainer
            [ M3e.Attributes.id "docs-drawer"
            , M3e.DrawerContainer.startMode Value.over
            , M3e.Attributes.start model.showMenu
```

to:

```elm
        [ M3e.drawerContainer
            [ M3e.Attributes.id "docs-drawer"
            , M3e.DrawerContainer.startMode Value.auto
            , M3e.Attributes.start (not (isMobile model) || model.showMenu)
```

(`drawerShell` already receives `model` as a parameter — no signature change needed.)

- [ ] **Step 6: Rebuild, re-serve, run the test to verify it passes**

Same commands as Step 2. Expected: PASS.

- [ ] **Step 7: Run the full browser suite to confirm no regressions**

```bash
BASE_URL=http://localhost:1239 npx playwright test
```

- [ ] **Step 8: Commit**

```bash
git add docs/app/Shared.elm docs/tests-browser/nav-rail.spec.ts
git commit -m "Restore viewport-width tracking; tree panel pins open on desktop"
```

---

### Task 2: Dissolve Reference; regroup Components by category

**Files:**
- Modify: `docs/app/Shared.elm` — `navSections` (`:635-690`), `navMenu` (`:749-756`), `componentsGroup` (`:762-777`)
- Modify: `docs/app/Route/Guide.elm` — `view` (the `chapterLink` list near the end of the function)
- Test: `docs/tests-browser/nav.spec.ts` (extend — this is the file `plans` for nav content already live in)

**Interfaces:**
- Consumes: `componentCategories : List ( String, String )` (already exists, `Shared.elm:808-817`); `navGroup` (already exists, `Shared.elm:780-795`, reused unmodified).
- Produces: nothing new consumed by later tasks — this task's output is directly user-visible nav content.

- [ ] **Step 1: Write the failing test**

Add to `docs/tests-browser/nav.spec.ts` (which already has one test from the earlier nav-flattening fix — see its header comment):

```ts
test("drawer groups components by category, and Reference is dissolved into Guide", async ({
  page,
}) => {
  await page.goto("/components/button");
  await page.getByRole("button", { name: "Toggle navigation" }).click();

  // Components: category headers now render, not a flat 54-item list.
  for (const category of [
    "Actions",
    "Communication",
    "Containment",
    "Navigation",
    "Selection",
    "Text inputs",
    "Layout & style",
  ]) {
    await expect(page.getByText(category, { exact: true })).toBeVisible();
  }

  // Reference is gone as its own group (a non-interactive `NavMenuItem.label`
  // group title, hence a text check, not a role check); its 4 links live
  // under Guide instead, as real `navLeaf` anchors (role "link" is correct
  // here — `navLeaf` renders a genuine `TypedHtml.a [ href ]`, unlike the
  // rail's `m3e-nav-item`, which is role "button" — see nav-rail-layout.md
  // Task 1).
  await expect(page.getByText("Reference", { exact: true })).toHaveCount(0);
  await expect(
    page.getByRole("link", { name: "Full API reference", exact: true }),
  ).toBeVisible();
  await expect(page.getByRole("link", { name: "Round-trip report", exact: true })).toBeVisible();
});
```

- [ ] **Step 2: Build, serve, run it to verify it fails**

```bash
cd docs
npm run build:site
pkill -f "PORT=1239" 2>/dev/null; (PORT=1239 npm run serve > /tmp/serve.log 2>&1 &); sleep 2
BASE_URL=http://localhost:1239 npx playwright test tests-browser/nav.spec.ts
```

Expected: FAIL — no category headers exist yet; `Reference` group still exists.

- [ ] **Step 3: Add the 4 Reference items to Guide's `navSections` entry**

In `docs/app/Shared.elm`, `navSections`'s Guide entry (currently `:644-663`), append 4 items:

```elm
    , { title = "The Guide"
      , icon = "auto_stories"
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
            , ( "/reference", "Full API reference" )
            , ( "/roundtrip", "Round-trip report" )
            ]
      }
```

- [ ] **Step 4: Delete the `Reference` `navGroup` from `navMenu`**

In `docs/app/Shared.elm`, `navMenu` (currently `:749-756`):

```elm
navMenu : List NavComponent -> String -> Element { s | navMenu : M3e.Kind.Brand } admittedBy msg
navMenu components currentPath =
    M3e.navMenu [ Aria.label "Primary", TypedHtml.Attributes.class "primary-nav-drawer" ]
        (List.map (\s -> navGroup currentPath s.icon s.title s.items) navSections
            ++ [ componentsGroup components currentPath ]
        )
```

(Deletes the trailing `, navGroup currentPath "menu_book" "Reference" [...]` list item.)

- [ ] **Step 5: Regroup `componentsGroup` by category**

Replace `componentsGroup` (currently `:762-777`) with:

```elm
{-| The top-level **Components** nav group, holding "All components" (pinned,
matching `/components/all`'s kitchen-sink page) plus one `navGroup` sub-group
per `componentCategories` entry — reusing `navGroup` unmodified, since a
category is exactly "a labelled group of navLeaf items", the same shape
`navGroup` already builds for Getting Started/Guide/Styles/Examples. Only the
category actually holding the current route auto-opens (`navGroup`'s own
`open`-when-current-route-matches logic), so navigating within Components
doesn't force all 7 categories open at once.
-}
componentsGroup : List NavComponent -> String -> Element { s | navMenuItem : M3e.Kind.Brand } admittedBy msg
componentsGroup components currentPath =
    M3e.navMenuItem
        (if String.startsWith "/components/" currentPath then
            [ M3e.Attributes.open True ]

         else
            []
        )
        (M3e.NavMenuItem.label (M3e.text "Components")
            :: M3e.NavMenuItem.icon (M3e.icon [ M3e.Icon.name "widgets" ] [])
            :: navLeaf currentPath ( "/components/all", "All components" )
            :: List.map (categoryGroup components currentPath) componentCategories
        )


{-| One category sub-group within Components — its members, sorted
alphabetically by label (the same sort key the old flat list used, just
applied per-category instead of globally).
-}
categoryGroup : List NavComponent -> String -> ( String, String ) -> Element { s | navMenuItem : M3e.Kind.Brand } admittedBy msg
categoryGroup components currentPath ( category, glyph ) =
    navGroup currentPath
        glyph
        category
        (components
            |> List.filter (\c -> c.category == category)
            |> List.sortBy (\c -> String.toLower c.label)
            |> List.map (\c -> ( "/components/" ++ c.slug, c.label ))
        )
```

- [ ] **Step 6: Add the two new links to `Route/Guide.elm`'s landing page**

In `docs/app/Route/Guide.elm`, the `view` function already has a `chapterLink` row for Cheat sheet/Glossary. Find:

```elm
                    , TypedHtml.div [ TA.class "flex flex-wrap gap-3" ]
                        [ chapterLink "/guide/cheat-sheet" "Cheat sheet"
                        , chapterLink "/guide/glossary" "Glossary"
                        ]
```

Replace with:

```elm
                    , TypedHtml.div [ TA.class "flex flex-wrap gap-3" ]
                        [ chapterLink "/guide/cheat-sheet" "Cheat sheet"
                        , chapterLink "/guide/glossary" "Glossary"
                        , chapterLink "/reference" "Full API reference"
                        , chapterLink "/roundtrip" "Round-trip report"
                        ]
```

- [ ] **Step 7: Rebuild, re-serve, run the test to verify it passes**

Same commands as Step 2. Expected: PASS.

- [ ] **Step 8: Run the full browser suite to confirm no regressions**

```bash
BASE_URL=http://localhost:1239 npx playwright test
```

- [ ] **Step 9: Commit**

```bash
git add docs/app/Shared.elm docs/app/Route/Guide.elm docs/tests-browser/nav.spec.ts
git commit -m "Dissolve Reference into Guide; regroup Components tree by category"
```

---

### Task 3: TOC — `View.toc` field, `Doc.sectionHeadingWithId`, wired into the `end` drawer slot

**Files:**
- Modify: `docs/app/View.elm` — add `toc`/`withToc`
- Modify: `docs/src/Doc.elm` — add `sectionHeadingWithId` alongside `sectionHeading` (`:176-182`)
- Modify: `docs/app/Shared.elm` — `Model` (add `endOpen`), `Msg` (add `ToggleToc`), `update` (add its case), `appShellBar` (add the TOC-toggle trailing action, gated on non-empty `tocEntries`), `drawerShell` (add the `end` slot + panel), `view` (update both the `appShellBar` and `drawerShell` call sites)
- Modify: `docs/app/Route/Components/Name_.elm` — one real page opting into `View.toc`, proving the mechanism end-to-end
- Test: `docs/tests-browser/toc.spec.ts` (new file)

**Interfaces:**
- Consumes: `Model.isMobile`/`viewportWidth` (Task 1); `appShellBar` and its `view` call site (Plan 1's Task 2 — this task changes `appShellBar`'s signature from taking no arguments to taking `List View.TocEntry`).
- Produces: `View.toc : View msg -> List { id : String, label : String }`; `View.withToc : List { id : String, label : String } -> View msg -> View msg`; `Doc.sectionHeadingWithId : String -> String -> Element (M3e.Heading.Is s) admittedBy msg` (id, then text — matching the existing `sectionHeading : String -> Element ...` order with the id prepended); `Msg.ToggleToc`.

- [ ] **Step 1: Write the failing test**

Create `docs/tests-browser/toc.spec.ts`:

```ts
import { expect, test } from "@playwright/test";

/**
 * A page that opts into `View.toc` gets a jump-link list rendered into the
 * drawer's `end` slot; a page that doesn't (the vast majority today) gets no
 * TOC panel content at all — `View.toc` defaults to `[]`.
 */
test("a component page's TOC jump-link scrolls to its matching heading", async ({ page }) => {
  await page.goto("/components/button");
  const tocLink = page.locator("#docs-drawer [slot='end']").getByRole("link", { name: "API" });
  await expect(tocLink).toBeVisible();

  const heading = page.locator("#api");
  await expect(heading).not.toBeInViewport();
  await tocLink.click();
  await expect(heading).toBeInViewport();
});

test("on mobile, the TOC toggle button opens the panel", async ({ page }) => {
  await page.setViewportSize({ width: 411, height: 761 });
  await page.goto("/components/button");

  const tocPanel = page.locator("#docs-drawer [slot='end']");
  await expect(tocPanel).toBeHidden();

  await page.getByRole("button", { name: "On this page" }).click();
  await expect(tocPanel).toBeVisible();
  await expect(tocPanel.getByRole("link", { name: "API" })).toBeVisible();
});

test("a page with no toc entries shows no TOC toggle button", async ({ page }) => {
  await page.goto("/guide");
  await expect(page.getByRole("button", { name: "On this page" })).toHaveCount(0);
});
```

- [ ] **Step 2: Build, serve, run it to verify it fails**

```bash
cd docs
npm run build:site
pkill -f "PORT=1239" 2>/dev/null; (PORT=1239 npm run serve > /tmp/serve.log 2>&1 &); sleep 2
BASE_URL=http://localhost:1239 npx playwright test tests-browser/toc.spec.ts
```

Expected: FAIL — `#docs-drawer` has no `end` slot content at all yet, and `#api` doesn't exist (no heading carries that id).

- [ ] **Step 3: Add `toc` to `View`**

In `docs/app/View.elm`, add `toc`/`withToc` to the exposing list (currently `:1-7`):

```elm
module View exposing
    ( View
    , fromElement, fromElements
    , title, body, toc, withToc
    , map
    , Freezable, freeze, freezableToHtml, htmlToFreezable
    )
```

Add a type alias near the top (after the module doc comment, before `type View`):

```elm
{-| One TOC jump-link: `id` matches a heading's `id` attribute
(`Doc.sectionHeadingWithId`); `label` is the link text.
-}
type alias TocEntry =
    { id : String, label : String }
```

Change the internal record (currently `:43-47`) to add a `toc` field:

```elm
type View msg
    = View
        { title : String
        , body : List (M3e.Html.Node msg)
        , toc : List TocEntry
        }
```

`fromElements` (currently `:60-65`) defaults it to `[]`:

```elm
fromElements : String -> List (M3e.Html.Element accepts admittedBy msg) -> View msg
fromElements pageTitle elements =
    View
        { title = pageTitle
        , body = List.map M3e.Html.toNode elements
        , toc = []
        }
```

Add the getter and the pipe-style setter (after `title`, before `body`):

```elm
{-| The page's TOC entries — `[]` for the vast majority of pages that don't
opt in.
-}
toc : View msg -> List TocEntry
toc (View view) =
    view.toc


{-| Attach TOC entries to a view: `View.fromElement "Title" el |> View.withToc
[ { id = "api", label = "API" } ]`.
-}
withToc : List TocEntry -> View msg -> View msg
withToc entries (View view) =
    View { view | toc = entries }
```

`map` (currently `:90-95`) must carry `toc` through unchanged (it doesn't touch `msg`):

```elm
map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn (View view) =
    View
        { title = view.title
        , body = List.map (M3e.Html.mapNode fn) view.body
        , toc = view.toc
        }
```

- [ ] **Step 4: Add `Doc.sectionHeadingWithId`**

In `docs/src/Doc.elm`, add to the exposing list (alongside `sectionHeading`) and add the function right after `sectionHeading` (currently `:176-182`):

```elm
{-| Like `sectionHeading`, but carries an `id` so a `View.toc` jump-link
(`href="#id"`) has something to land on. A sibling function, not a changed
signature on `sectionHeading` — 37 existing call sites across 12 files don't
need to change for the ~handful of headings that opt into a TOC.
-}
sectionHeadingWithId : String -> String -> Element (M3e.Heading.Is s) admittedBy msg
sectionHeadingWithId id s =
    M3e.heading
        [ M3e.Heading.variant Value.headline
        , M3e.Heading.size Value.small
        , M3e.Attributes.level 2
        , M3e.Attributes.id id
        ]
        [ M3e.text s ]
```

(`M3e.Attributes.id` — confirm `M3e.Heading.Attrs` admits `id`; every other `M3e.*` element seen in this codebase does, e.g. `M3e.Attributes.id "docs-app-bar"` on `M3e.appBar` — if the compiler rejects it, check `src/M3e/Heading.elm`'s `Attrs` alias for the exact admitted attribute name.)

- [ ] **Step 5: Add `endOpen` to `Model` and wire the `end` drawer slot in `drawerShell`**

`Model` (from Task 1's shape), add `endOpen : Bool`:

```elm
type alias Model =
    { showMenu : Bool
    , endOpen : Bool
    , viewportWidth : Int
    , scheme : Value Value.Scheme
    , seed : String
    , contrast : Value Value.Contrast
    , density : Float
    , dir : TypedHtml.Values.Value TypedHtml.Values.Dir
    , settingsOpen : Bool
    }
```

`init`, add `endOpen = False`. This only gates the **mobile** overlay state — trace the visibility formula below: on desktop (`isMobile model == False`), `not (isMobile model) || model.endOpen` is `True` regardless of `endOpen`, so a page with real `tocEntries` shows its TOC pinned-open automatically, same as the tree. `endOpen` only matters on mobile, where it starts closed until the trigger added in Step 5a opens it:

```elm
init flags _ =
    ( { showMenu = False
      , endOpen = False
      , viewportWidth = initialViewportWidth flags
      , scheme = schemeFromFlags flags
      , seed = "#6750A4"
      , contrast = Value.standard
      , density = 0
      , dir = TypedHtml.Values.ltr
      , settingsOpen = False
      }
    , Effect.none
    )
```

`drawerShell`'s signature needs the current page's `View msg` (to read its `toc`), so it can no longer take pre-extracted `body : List (Element ...)` alone — thread the full `pageView` through instead. Current signature and call site:

```elm
drawerShell :
    (Msg -> msg)
    -> Model
    -> { path : UrlPath, route : Maybe Route }
    -> List NavComponent
    -> List (Element childAccepts (M3e.ContentPane.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.MainIs s) admittedBy msg
```

called as `drawerShell toMsg model page sharedData.components (View.body pageView)` from `view`.

Change the last parameter from the pre-extracted body list to the TOC entries directly (simpler than threading the whole `View msg` type through, and `view` already has both `pageView` and can call `View.toc`/`View.body` itself):

```elm
drawerShell :
    (Msg -> msg)
    -> Model
    -> { path : UrlPath, route : Maybe Route }
    -> List NavComponent
    -> List View.TocEntry
    -> List (Element childAccepts (M3e.ContentPane.ChildAdmittedBy childAdm) msg)
    -> Element (TypedHtml.Sectioning.MainIs s) admittedBy msg
drawerShell toMsg model page components tocEntries body =
    let
        currentPath : String
        currentPath =
            normalizePath (UrlPath.toAbsolute page.path)
    in
    TypedHtml.main_
        [ TypedHtml.Attributes.id "main-content"
        , TypedHtml.Attributes.class "flex-auto relative mx-auto w-full h-0"
        ]
        [ M3e.drawerContainer
            [ M3e.Attributes.id "docs-drawer"
            , M3e.DrawerContainer.startMode Value.auto
            , M3e.Attributes.start (not (isMobile model) || model.showMenu)
            , M3e.DrawerContainer.endMode Value.auto
            , M3e.Attributes.end (not (List.isEmpty tocEntries) && (not (isMobile model) || model.endOpen))
            , M3e.Events.onChangeWith (Decode.map toMsg drawerChangeDecoder)
            , TypedHtml.Attributes.class "h-full w-full"
            ]
            [ M3e.DrawerContainer.start (navMenu components currentPath)
            , M3e.contentPane
                [ TypedHtml.Attributes.class "m3e-content-pane-container-color-surface-container-lowest"
                , TypedHtml.Attributes.class "overflow-y-auto mx-auto h-full w-full max-w-5xl md:p-4 md:pt-1"
                ]
                body
            , M3e.DrawerContainer.end (tocPanel tocEntries)
            ]
        ]
```

Add `tocPanel` right after `drawerShell`:

```elm
{-| The TOC drawer panel: a jump-link per `View.toc` entry. Empty `tocEntries`
means an empty panel, but the `end` attribute above is already `False` in
that case, so `auto`/`side` mode never shows it — this only renders when
there is something to show.
-}
tocPanel : List View.TocEntry -> Element (TypedHtml.Grouping.DivIs s) admittedBy msg
tocPanel tocEntries =
    TypedHtml.nav
        [ Aria.label "On this page", TypedHtml.Attributes.class "flex flex-col gap-2 p-4" ]
        (List.map
            (\entry ->
                TypedHtml.a
                    [ TypedHtml.Attributes.href ("#" ++ entry.id) ]
                    [ M3e.text entry.label ]
            )
            tocEntries
        )
```

Update `view`'s call site (`Shared.elm`, the `else` branch inside the `flex flex-col min-w-0` div from Plan 1's Task 2 — search for `drawerShell toMsg model page sharedData.components`):

```elm
                        , drawerShell toMsg model page sharedData.components (View.toc pageView) (View.body pageView)
```

- [ ] **Step 5a: Add a mobile trigger for the TOC panel**

`endOpen` is otherwise write-only — nothing in the app ever sets it to `True`, so on mobile the TOC panel would be permanently unreachable even on a page with real `tocEntries`. Add a `Msg` case and an app-bar icon button, matching the existing `settingsButton`/`ToggleSettings` pattern (`Shared.elm:366-370`).

`Msg` (from Task 1's shape), add `ToggleToc`:

```elm
type Msg
    = MenuClicked
    | CloseMenu
    | ToggleSettings
    | SettingsSheetClosed
    | DrawerChanged Bool
    | ViewportResized Int
    | ToggleToc
    | SetScheme (Value Value.Scheme)
    | SetSeed String
    | SetContrast (Value Value.Contrast)
    | SetDensity Float
    | SetDirection (TypedHtml.Values.Value TypedHtml.Values.Dir)
```

`update`, add a case (anywhere — suggested right after `ViewportResized`):

```elm
        ToggleToc ->
            ( { model | endOpen = not model.endOpen }, Effect.none )
```

`appShellBar` (`Shared.elm:326-340`) gains a trailing action, only rendered when there's something for it to toggle — it needs the current page's `tocEntries`, so its signature grows a parameter:

```elm
appShellBar : List View.TocEntry -> Element (M3e.AppBar.Is s) admittedBy Msg
appShellBar tocEntries =
    M3e.appBar
        [ M3e.AppBar.size Value.small
        , M3e.Attributes.id "docs-app-bar"
        ]
        ([ M3e.AppBar.leading
            (M3e.iconButton [ Aria.label "Toggle navigation", M3e.Events.onClick MenuClicked ]
                [ M3e.icon [ M3e.Icon.name "menu" ] [] ]
            )
         , M3e.AppBar.title (M3e.text "elm-m3e")
         , M3e.AppBar.subtitle (M3e.text "Material 3 Expressive for Elm")
         ]
            ++ (if List.isEmpty tocEntries then
                    []

                else
                    [ M3e.AppBar.trailing
                        (M3e.iconButton [ Aria.label "On this page", M3e.Events.onClick ToggleToc ]
                            [ M3e.icon [ M3e.Icon.name "toc" ] [] ]
                        )
                    ]
               )
            ++ [ M3e.AppBar.trailing githubLink
               , M3e.AppBar.trailing settingsButton
               ]
        )
```

Update `view`'s call site (search for `M3e.mapMsg toMsg appShellBar` — added in Plan 1's Task 2):

```elm
                        [ M3e.mapMsg toMsg (appShellBar (View.toc pageView))
```

- [ ] **Step 6: Wire one real page — `Route/Components/Name_.elm`'s API section**

Find the API section heading in `docs/app/Route/Components/Name_.elm` (currently uses a plain heading around the `"API"` section — search for `M3e.heading` near where `[ M3e.text "API" ]` appears, in the function building the API-reference section). Replace that heading's construction to use `Doc.sectionHeadingWithId "api" "API"` in place of the existing un-anchored heading, and change the route's final `View.fromElement`/`View.fromElements` call to pipe through `|> View.withToc [ { id = "api", label = "API" } ]`.

(This task only wires ONE page end-to-end to prove the mechanism per the design spec's scope — adding `View.toc` to every other page that could use one is explicitly out of scope, same as the design spec's "Explicitly out of scope" section.)

- [ ] **Step 7: Rebuild, re-serve, run the TOC test to verify it passes**

Same commands as Step 2. Expected: PASS.

- [ ] **Step 8: Run the full browser suite to confirm no regressions**

```bash
BASE_URL=http://localhost:1239 npx playwright test
```

- [ ] **Step 9: Commit**

```bash
git add docs/app/View.elm docs/src/Doc.elm docs/app/Shared.elm docs/app/Route/Components/Name_.elm docs/tests-browser/toc.spec.ts
git commit -m "Add View.toc + Doc.sectionHeadingWithId; wire the end drawer slot as a TOC panel"
```

---

### Task 4: `npm run gate` clean pass

**Files:** none new — verification only.

- [ ] **Step 1: Run the full gate**

```bash
npm run gate
```

- [ ] **Step 2: Fix any new `elm-review`/`elm-format` findings introduced by this plan's changes**

The `Browser.Events` and `initialViewportWidth` pre-existing findings should now be resolved as a side effect of Task 1 — confirm they no longer appear. The two duplicate-`class`-attribute findings (`Shared.elm:268`, `Shared.elm:723`) predate this plan and are not this task's responsibility.

- [ ] **Step 3: Commit any formatting fixes**

```bash
git add -u
git commit -m "elm-format"
```
