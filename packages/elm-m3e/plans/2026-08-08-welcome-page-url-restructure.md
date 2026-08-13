# Welcome Page + URL Restructure — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the current homepage (`/`) into the Start section as "Welcome" (`/getting-started/welcome`), and move `/reference` and `/roundtrip` under `/guide/` — so every page in the docs app lives under its section's `/<prefix>/<slug>` URL, with no bare top-level exceptions.

**Architecture:** elm-pages derives each route's URL purely from its module's file path (`Route/Guide/Reference.elm` -> `/guide/reference`), so moving a route is a `git mv` + a `module` line rename, not a rewrite. The docs site is a fully static build deployed via Netlify (`docs/elm-pages.config.mjs` -> `elm-pages/adapter/netlify.js`); `docs/netlify.toml` already has a real precedent for a moved-URL redirect (`/getting-started/overview -> /guide`, real 301 at Netlify's edge, `force = true`) — this plan adds three more entries in the same block, no client-side JS redirect needed. `Shared.elm`'s `sections`/`navSections` are the single source of truth the rail, tree, and `currentSectionLabel`'s breadcrumb/title logic all read from; once `/reference`/`/roundtrip` carry the `guide` prefix natively, the special-case in `currentSectionLabel` that hardcodes them can be deleted outright.

**Tech Stack:** Elm 0.19, elm-pages 3.5 (file-based routing), Netlify redirects, Playwright (`docs/tests-browser/`).

## Global Constraints

- Every internal link uses the NEW path — no route may ship an internal `href`/`a` pointing at an old, now-redirect-only URL (an internal 301 hop is a broken-link smell, not a fix).
- `docs/netlify.toml`'s `[[redirects]]` entries use `status = 301` and `force = true`, matching the existing `/getting-started/overview` entry exactly.
- `View.fromElement`'s title argument is the route's own bare page name only (no `" · elm-m3e"`/`" < ..."` suffix) — `Shared.breadcrumbTitle` adds the reverse-breadcrumb suffix automatically for every route except `path == []` (the old homepage exception, which goes away entirely once there is no `path == []` route left to special-case).
- Run `npm run gate` (from the repo root) after every task; it must pass before moving to the next task.

---

### Task 1: Move `/reference` and `/roundtrip` under `/guide/`

**Files:**
- Move: `docs/app/Route/Reference.elm` -> `docs/app/Route/Guide/Reference.elm`
- Move: `docs/app/Route/Roundtrip.elm` -> `docs/app/Route/Guide/Roundtrip.elm`
- Modify: `docs/app/Route/Guide.elm` (chapter links, lines 99-100)
- Modify: `docs/app/Shared.elm` (`currentSectionLabel`, `navSections`)
- Modify: `docs/netlify.toml` (add two `[[redirects]]` entries)
- Modify: `docs/tests-browser/shell-breakpoints.spec.ts`, `docs/tests-browser/mobile-shell.spec.ts` (route string)

**Interfaces:**
- Consumes: nothing new — this is a pure move of two existing, self-contained routes (each already has `canonicalUrlOverride = Nothing`, so neither hardcodes its own path anywhere internally).
- Produces: `/guide/reference` and `/guide/roundtrip` as the only working URLs for this content; `Shared.currentSectionLabel` no longer special-cases anything.

- [ ] **Step 1: Move the two route files and rename their modules**

  ```bash
  cd docs
  git mv app/Route/Reference.elm app/Route/Guide/Reference.elm
  git mv app/Route/Roundtrip.elm app/Route/Guide/Roundtrip.elm
  ```

  Then, in `app/Route/Guide/Reference.elm`, change line 1 from:

  ```elm
  module Route.Reference exposing (ActionData, Data, Model, Msg, route)
  ```

  to:

  ```elm
  module Route.Guide.Reference exposing (ActionData, Data, Model, Msg, route)
  ```

  And in `app/Route/Guide/Roundtrip.elm`, change line 1 from:

  ```elm
  module Route.Roundtrip exposing (ActionData, Data, Model, Msg, route)
  ```

  to:

  ```elm
  module Route.Guide.Roundtrip exposing (ActionData, Data, Model, Msg, route)
  ```

  Nothing else in either file references its own path (`canonicalUrlOverride = Nothing` in both `Seo.summary` calls), so no other line changes in these two files.

- [ ] **Step 2: Update the two internal links in `app/Route/Guide.elm`**

  Current (lines 96-101):

  ```elm
                    , TypedHtml.div [ TA.class "flex flex-wrap gap-3" ]
                        [ chapterLink "/guide/cheat-sheet" "Cheat sheet"
                        , chapterLink "/guide/glossary" "Glossary"
                        , chapterLink "/reference" "Full API reference"
                        , chapterLink "/roundtrip" "Round-trip report"
                        ]
  ```

  Change to:

  ```elm
                    , TypedHtml.div [ TA.class "flex flex-wrap gap-3" ]
                        [ chapterLink "/guide/cheat-sheet" "Cheat sheet"
                        , chapterLink "/guide/glossary" "Glossary"
                        , chapterLink "/guide/reference" "Full API reference"
                        , chapterLink "/guide/roundtrip" "Round-trip report"
                        ]
  ```

- [ ] **Step 3: Update `navSections` in `app/Shared.elm`**

  Current (in the `"guide"` section's `items`, near the end of the list):

  ```elm
            , ( "/reference", "Full API reference" )
            , ( "/roundtrip", "Round-trip report" )
  ```

  Change to:

  ```elm
            , ( "/guide/reference", "Full API reference" )
            , ( "/guide/roundtrip", "Round-trip report" )
  ```

- [ ] **Step 4: Delete the `currentSectionLabel` special-case in `app/Shared.elm`**

  Current:

  ```elm
  currentSectionLabel : UrlPath -> Maybe String
  currentSectionLabel path =
      case List.head path of
          Just "reference" ->
              Just "Guide"

          Just "roundtrip" ->
              Just "Guide"

          _ ->
              sections
                  |> List.filter (sectionIsCurrent path)
                  |> List.head
                  |> Maybe.map .label
  ```

  Change to:

  ```elm
  currentSectionLabel : UrlPath -> Maybe String
  currentSectionLabel path =
      sections
          |> List.filter (sectionIsCurrent path)
          |> List.head
          |> Maybe.map .label
  ```

  Also update its doc comment immediately above (currently explains the `/reference`/`/roundtrip` exception) to drop that paragraph, since both routes now carry the real `guide` prefix and need no special-casing.

- [ ] **Step 5: Add the two Netlify redirects**

  In `docs/netlify.toml`, immediately after the existing `/getting-started/overview` redirect block, add:

  ```toml
  [[redirects]]
    from = "/reference"
    to = "/guide/reference"
    status = 301
    force = true

  [[redirects]]
    from = "/roundtrip"
    to = "/guide/roundtrip"
    status = 301
    force = true
  ```

- [ ] **Step 6: Update the two Playwright tests that use `/reference` as a tall route**

  In `docs/tests-browser/shell-breakpoints.spec.ts`, the test at line ~153 (`"the mobile bottom nav bar does not occlude the end of the page content"`) has `await page.goto("/reference");` — change to `await page.goto("/guide/reference");`.

  In `docs/tests-browser/mobile-shell.spec.ts`, the `LONG_ROUTE` constant is `const LONG_ROUTE = "/reference";` — change to `const LONG_ROUTE = "/guide/reference";`.

- [ ] **Step 7: Run the gate**

  ```bash
  cd /Users/jhp/code/jackhp95/elm-m3e-nav-rail-search
  npm run gate
  ```

  Fix anything it flags (in particular, `check:nav`'s drawer-link-resolution check and `check-data-drift` reading `data/reference.json` — unrelated to this move, but confirm they still pass) before moving to Task 2.

- [ ] **Step 8: Commit**

  ```bash
  git add -A
  git commit -m "Move /reference and /roundtrip under /guide/, with 301 redirects from the old URLs"
  ```

---

### Task 2: Move the homepage into Start as `/getting-started/welcome`

**Files:**
- Move: `docs/app/Route/Index.elm` -> `docs/app/Route/GettingStarted/Welcome.elm`
- Modify: `docs/app/Shared.elm` (`sections`, `navSections`)
- Modify: `docs/netlify.toml` (add one `[[redirects]]` entry)

**Interfaces:**
- Consumes: nothing new.
- Produces: `/getting-started/welcome` as the canonical Start landing page; `/` as a 301 redirect to it; "Welcome" as the first item in the Start section's tree.

- [ ] **Step 1: Move the route file and rename its module**

  ```bash
  cd docs
  git mv app/Route/Index.elm app/Route/GettingStarted/Welcome.elm
  ```

  In `app/Route/GettingStarted/Welcome.elm`, change line 1 from:

  ```elm
  module Route.Index exposing (ActionData, Data, Model, Msg, route)
  ```

  to:

  ```elm
  module Route.GettingStarted.Welcome exposing (ActionData, Data, Model, Msg, route)
  ```

- [ ] **Step 2: Retitle the page to "Welcome"**

  Current `view` (the `View.fromElement` call):

  ```elm
  view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
  view app _ =
      View.fromElement "elm-m3e · type-safe Material 3 Expressive for Elm"
          (Doc.pane
              [ hero
              , highlights app.data.componentCount
              , statusGrid
              ]
          )
  ```

  Change the title argument to the route's own bare page name, matching every other route in the app (`Shared.breadcrumbTitle` adds the `" < Start < elm-m3e"` suffix automatically now that this route has a real section):

  ```elm
  view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
  view app _ =
      View.fromElement "Welcome"
          (Doc.pane
              [ hero
              , highlights app.data.componentCount
              , statusGrid
              ]
          )
  ```

  Leave the `head`/`Seo.summary` title ("elm-m3e · type-safe Material 3 Expressive for Elm") and `description` untouched — that is SEO/social-preview copy, a deliberately separate concern from the browser-tab breadcrumb title (see `Shared.breadcrumbTitle`'s own doc comment).

  Leave `hero`, `highlights`, `statusGrid`, and every other function in the file untouched — only the module line and the `view` title argument change.

- [ ] **Step 3: Make "Welcome" the Start section's landing page in `app/Shared.elm`**

  Current (`sections`):

  ```elm
      [ { label = "Start", icon = "rocket_launch", href = "/getting-started/installation", prefix = "getting-started" }
  ```

  Change to:

  ```elm
      [ { label = "Start", icon = "rocket_launch", href = "/getting-started/welcome", prefix = "getting-started" }
  ```

- [ ] **Step 4: Add "Welcome" as the first item in the Start section's tree**

  Current (`navSections`, the `"getting-started"` section's `items`):

  ```elm
    [ { prefix = "getting-started"
      , items =
            [ ( "/getting-started/installation", "Installation" )
            , ( "/getting-started/browser-support", "Browser Support" )
            ]
      }
  ```

  Change to:

  ```elm
    [ { prefix = "getting-started"
      , items =
            [ ( "/getting-started/welcome", "Welcome" )
            , ( "/getting-started/installation", "Installation" )
            , ( "/getting-started/browser-support", "Browser Support" )
            ]
      }
  ```

- [ ] **Step 5: Add the root redirect**

  In `docs/netlify.toml`, add (alongside the other three from Task 1):

  ```toml
  [[redirects]]
    from = "/"
    to = "/getting-started/welcome"
    status = 301
    force = true
  ```

  Verify this does NOT also try to redirect every other path (Netlify's `from = "/"` matches only the exact root path, not a prefix — unlike `from = "/*"`).

- [ ] **Step 6: Run the gate**

  ```bash
  cd /Users/jhp/code/jackhp95/elm-m3e-nav-rail-search
  npm run gate
  ```

  `check-nav`'s drawer-link-resolution check will now also verify `/getting-started/welcome` resolves. Fix anything else it flags.

- [ ] **Step 7: Commit**

  ```bash
  git add -A
  git commit -m "Move the homepage into Start as /getting-started/welcome, with a redirect from /"
  ```

---

### Task 3: Manual verification + final gate pass

**Files:** none (verification only).

- [ ] **Step 1: Start the dev server and manually verify in a browser**

  ```bash
  cd docs && npm run dev
  ```

  Visit `/getting-started/welcome` — confirm: page title is "Welcome", document `<title>` reads "Welcome < Start < elm-m3e", the "Start" rail item is highlighted/selected, and the Start tree drawer shows "Welcome" as the first item, followed by "Installation" and "Browser Support".

  Visit `/guide/reference` and `/guide/roundtrip` — confirm both render their full content, the "Guide" rail item is highlighted, and both appear in the Guide tree drawer in their existing positions (last two items).

  Note: Netlify redirects (`/` -> `/getting-started/welcome`, `/reference` -> `/guide/reference`, `/roundtrip` -> `/guide/roundtrip`, plus the pre-existing `/getting-started/overview` -> `/guide`) only take effect on a real Netlify deploy or `netlify dev` — the plain `elm-pages dev` server does not read `netlify.toml`, so `/`, `/reference`, and `/roundtrip` will 404 (or simply not exist) against the dev server. That is expected; it is not a regression to chase here.

- [ ] **Step 2: Full gate pass**

  ```bash
  cd /Users/jhp/code/jackhp95/elm-m3e-nav-rail-search
  npm run gate
  ```

  Must pass with 0 failures before this plan is considered done.
