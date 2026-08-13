# Nav Rail Layout — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a persistent 5-item nav rail (Getting Started, Guide, Styles, Examples, Components) beside the app bar on desktop, and a matching bottom nav bar on mobile, without touching the existing hamburger-triggered nav-tree drawer, which stays fully functional and unmodified until Plan 2 replaces its content.

**Architecture:** A pure `Section` list + `sectionIsCurrent : UrlPath -> Section -> Bool` matcher drives both a `M3e.navRail` (desktop, `hidden md:flex`) and a `M3e.navBar` (mobile, `md:hidden`) built from the same `railItem` elements — mirroring the exact rail/bar Tailwind-breakpoint-swap pattern `Route/Examples/Shop.elm` already uses. The shell's top-level layout changes from a single `flex-col` to `flex-row` (rail | main-column), with the existing app-bar-and-drawer content moved into the main-column.

**Tech Stack:** Elm 0.19, elm-pages 3.5, Playwright (`docs/tests-browser/`), Tailwind 4.

**Spec:** `specs/2026-08-06-nav-rail-migration-design.md`

## Global Constraints

- **Do not touch `drawerShell`, `navMenu`, `navSections`, `componentsGroup`, `navGroup`, `navLeaf`, or `componentCategories`.** These still power the existing hamburger-triggered nav-tree drawer, unchanged, until `plans/2026-08-06-nav-rail-tree-toc.md` (blocked on this plan) replaces them.
- **`/examples/*` individual example pages are unaffected.** `Shared.view`'s existing `if String.startsWith "/examples/" absolutePath then View.body pageView` branch already returns early with no shell at all — this plan's rail/layout changes live entirely in the `else` branch and must not touch that branch.
- Every new element (`docsNavRail`, `docsNavBar`, `railItem`) takes no `Msg` — navigation is real `href`-based (`m3e-nav-item`'s `href` attribute, confirmed in `config/slots.json`: `NavItem.actionMap` includes `["href", "link"]`, and `src/M3e/NavItem.elm`'s `Attrs` includes `href : Supported`), not `onClick`-driven state. This is why these three functions are typed `Element ... admittedBy msg` (free in `msg`), exactly like the existing `skipLink`, not `Element ... admittedBy Msg` requiring `M3e.mapMsg toMsg` at the call site.
- The static site must be rebuilt (`npm run build:site`) and re-served (`PORT=1239 npm run serve`, after `pkill -f "PORT=1239"` to kill any prior instance) before any Playwright run — this is a pre-rendered static site, not a live dev server reflecting unsaved changes.

---

### Task 1: `Section` data + rail/bar navigation elements

**Files:**
- Modify: `docs/app/Shared.elm` — add new top-level declarations (suggested placement: right after `componentCategories`, i.e. after line 817 today)
- Test: `docs/tests-browser/nav-rail.spec.ts` (new file)

**Interfaces:**
- Consumes: `UrlPath` (`import UrlPath exposing (UrlPath)`, already imported in `Shared.elm`) as `List String`; `M3e.Icon.name`, `M3e.NavItem.icon`, `M3e.Attributes.href`, `M3e.Attributes.selected` (all already imported/used elsewhere in `Shared.elm`).
- Produces: `type alias Section = { label : String, icon : String, href : String, prefix : String }`; `sections : List Section`; `sectionIsCurrent : UrlPath -> Section -> Bool`; `docsNavRail : UrlPath -> Element { s | navRail : M3e.Kind.Brand } admittedBy msg`; `docsNavBar : UrlPath -> Element { s | navBar : M3e.Kind.Brand } admittedBy msg`. Task 2 consumes `docsNavRail`/`docsNavBar` directly.

- [ ] **Step 1: Write the failing Playwright test**

Create `docs/tests-browser/nav-rail.spec.ts`:

```ts
import { expect, test } from "@playwright/test";

/**
 * The 5-item nav rail (desktop) / nav bar (mobile) that replaces top-level
 * hamburger-drawer navigation. `selected` reflects which of the 5 sections
 * the current route belongs to, matched by first path segment — NOT by
 * exact path, so e.g. /components/button and /components/tooltip both
 * select "Components".
 *
 * Locators below use `getByRole("button", ...)` for `m3e-nav-item`, NOT
 * "link" — confirmed against @m3e/web's compiled source
 * (`node_modules/@m3e/web/dist/nav-bar.js`): `M3eNavItemElement` extends
 * `Role(LitElement, "button")`, so its ARIA role is "button" even with
 * `href` set (it synthesizes a temporary real `<a>` to perform actual
 * navigation on click, but the accessible role of the component itself
 * never changes).
 */
const SECTIONS: { label: string; href: string }[] = [
  { label: "Getting Started", href: "/getting-started/installation" },
  { label: "The Guide", href: "/guide" },
  { label: "Styles", href: "/styles/color" },
  { label: "Examples", href: "/examples" },
  { label: "Components", href: "/components/button" },
];

test("rail renders all 5 sections with correct hrefs", async ({ page }) => {
  await page.goto("/guide");
  const rail = page.locator("m3e-nav-rail");
  await expect(rail).toHaveCount(1);
  for (const { label, href } of SECTIONS) {
    const item = rail.getByRole("button", { name: label, exact: true });
    await expect(item).toHaveAttribute("href", href);
  }
});

test("rail highlights the section matching the current route", async ({ page }) => {
  await page.goto("/components/button");
  const rail = page.locator("m3e-nav-rail");
  await expect(rail.getByRole("button", { name: "Components", exact: true })).toHaveAttribute(
    "selected",
    "",
  );
  await expect(rail.getByRole("button", { name: "The Guide", exact: true })).not.toHaveAttribute(
    "selected",
    "",
  );
});

test("no section is selected on a route outside all 5", async ({ page }) => {
  await page.goto("/");
  const rail = page.locator("m3e-nav-rail");
  await expect(rail).toHaveCount(1);
  for (const { label } of SECTIONS) {
    await expect(rail.getByRole("button", { name: label, exact: true })).not.toHaveAttribute(
      "selected",
      "",
    );
  }
});

test("mobile viewport shows the nav bar instead of the rail", async ({ page }) => {
  await page.setViewportSize({ width: 411, height: 761 });
  await page.goto("/guide");
  await expect(page.locator("m3e-nav-rail")).toBeHidden();
  const bar = page.locator("m3e-nav-bar");
  await expect(bar).toBeVisible();
  await expect(bar.getByRole("button", { name: "The Guide", exact: true })).toHaveAttribute(
    "selected",
    "",
  );
});
```

- [ ] **Step 2: Build, serve, and run the test to verify it fails**

```bash
cd docs
npm run build:site
pkill -f "PORT=1239" 2>/dev/null; (PORT=1239 npm run serve > /tmp/serve.log 2>&1 &); sleep 2
BASE_URL=http://localhost:1239 npx playwright test tests-browser/nav-rail.spec.ts
```

Expected: FAIL — `m3e-nav-rail` / `m3e-nav-bar` do not exist yet (locator count 0).

- [ ] **Step 3: Add the `Section` type, data, and matcher to `Shared.elm`**

Append after `componentCategories` (currently ending at line 817):

```elm


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
    [ { label = "Getting Started", icon = "rocket_launch", href = "/getting-started/installation", prefix = "getting-started" }
    , { label = "The Guide", icon = "auto_stories", href = "/guide", prefix = "guide" }
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
        [ M3e.NavItem.icon (M3e.icon [ M3e.Icon.name section.icon ] [])
        , M3e.text section.label
        ]


{-| Desktop: a persistent full-height rail beside the app bar. Hidden below the
`md` breakpoint, where `docsNavBar` takes over — the same Tailwind-class swap
`Route/Examples/Shop.elm`'s own `navRail`/`navBar` pair already uses.
-}
docsNavRail : UrlPath -> Element { s | navRail : M3e.Kind.Brand } admittedBy msg
docsNavRail path =
    M3e.navRail
        [ Aria.label "Sections", TypedHtml.Attributes.class "hidden shrink-0 md:flex" ]
        (List.map (railItem path) sections)


{-| Mobile: a fixed bottom nav bar, replacing the rail below the `md` breakpoint.
-}
docsNavBar : UrlPath -> Element { s | navBar : M3e.Kind.Brand } admittedBy msg
docsNavBar path =
    M3e.navBar
        [ Aria.label "Sections", TypedHtml.Attributes.class "fixed inset-x-0 bottom-0 z-30 md:hidden" ]
        (List.map (railItem path) sections)
```

This does not yet render anywhere — `docsNavRail`/`docsNavBar` are unused until Task 2 wires them into `view`. Elm will **not** error on unused top-level values (only `elm-review`'s `NoUnused.Variables` rule does, and only for genuinely dead code after the whole module is considered) — Task 2 lands in the same PR before any review/gate run, so this is not a real intermediate-state problem.

- [ ] **Step 4: Rebuild, re-serve, run the test again to verify it still fails the same way**

Same commands as Step 2. Expected: still FAIL, `m3e-nav-rail`/`m3e-nav-bar` still don't exist — `docsNavRail`/`docsNavBar` are defined but not yet placed in `view`. This confirms Step 3 didn't accidentally make the test pass for the wrong reason.

- [ ] **Step 5: Commit**

```bash
git add docs/app/Shared.elm docs/tests-browser/nav-rail.spec.ts
git commit -m "Add Section data + docsNavRail/docsNavBar, not yet wired into view"
```

---

### Task 2: Restructure the shell layout and wire in the rail/bar

**Files:**
- Modify: `docs/app/Shared.elm` — `view` (the non-`/examples/*` branch, currently lines 286–292)
- Test: `docs/tests-browser/nav-rail.spec.ts` (extend)

**Interfaces:**
- Consumes: `docsNavRail`, `docsNavBar` (Task 1); `skipLink`, `appShellBar`, `drawerShell`, `settingsBottomSheet` (existing, unchanged).
- Produces: nothing new consumed by later tasks in this plan; Plan 2 (tree/TOC) modifies `drawerShell`'s internals, not this layout wrapper.

- [ ] **Step 1: Extend the Playwright test to assert the corrected layout**

Add to `docs/tests-browser/nav-rail.spec.ts`:

```ts
test("rail sits beside the app bar, not above it", async ({ page }) => {
  await page.goto("/guide");
  const rail = page.locator("m3e-nav-rail");
  const appBar = page.locator("#docs-app-bar");
  const railBox = await rail.boundingBox();
  const appBarBox = await appBar.boundingBox();
  if (!railBox || !appBarBox) throw new Error("rail or app bar has no box");

  // The rail spans (close to) the full viewport height...
  const viewportHeight = page.viewportSize()?.height ?? 0;
  expect(railBox.height).toBeGreaterThan(viewportHeight - 5);
  // ...while the app bar starts to the right of the rail, not above it.
  expect(appBarBox.x).toBeGreaterThanOrEqual(railBox.x + railBox.width - 1);
  expect(appBarBox.y).toBeLessThanOrEqual(railBox.y + 1);
});
```

- [ ] **Step 2: Run it to verify it fails**

Same build/serve/run commands as Task 1. Expected: FAIL — today's shell is still `flex-col` (app bar spans full width above everything), so `appBarBox.x` is `0`, not `>= railBox.x + railBox.width`.

- [ ] **Step 3: Restructure `view`'s non-examples branch**

Current code (`docs/app/Shared.elm`, inside the `else` branch, today's lines 286–292):

```elm
                [ skipLink
                , TypedHtml.div [ TypedHtml.Attributes.class "h-dvh flex flex-col" ]
                    [ M3e.mapMsg toMsg appShellBar
                    , drawerShell toMsg model page sharedData.components (View.body pageView)
                    ]
                , M3e.mapMsg toMsg (settingsBottomSheet model)
                ]
```

Replace with:

```elm
                [ skipLink
                , TypedHtml.div [ TypedHtml.Attributes.class "h-dvh flex flex-row" ]
                    [ docsNavRail page.path
                    , TypedHtml.div [ TypedHtml.Attributes.class "flex flex-1 flex-col min-w-0" ]
                        [ M3e.mapMsg toMsg appShellBar
                        , drawerShell toMsg model page sharedData.components (View.body pageView)
                        ]
                    , docsNavBar page.path
                    ]
                , M3e.mapMsg toMsg (settingsBottomSheet model)
                ]
```

`docsNavBar` is placed here (a sibling in the `flex-row`, not inside the `flex-col` main column) because it's `position: fixed` in its own right (Tailwind class `fixed inset-x-0 bottom-0`, set in Task 1) — its position in the element tree doesn't affect its visual placement, but it must not be `display: none`-d by an ancestor, and placing it outside the scrollable main-column avoids that risk entirely.

- [ ] **Step 4: Rebuild, re-serve, run the full nav-rail spec to verify it passes**

```bash
cd docs
npm run build:site
pkill -f "PORT=1239" 2>/dev/null; (PORT=1239 npm run serve > /tmp/serve.log 2>&1 &); sleep 2
BASE_URL=http://localhost:1239 npx playwright test tests-browser/nav-rail.spec.ts
```

Expected: PASS — all 5 tests (4 from Task 1, 1 from this task).

- [ ] **Step 5: Run the full existing browser suite to confirm no regressions**

```bash
BASE_URL=http://localhost:1239 npx playwright test
```

Expected: same pass count as before this plan started, plus the 5 new `nav-rail.spec.ts` tests. The existing hamburger-drawer nav (`nav.spec.ts`) must still pass unmodified — this plan does not touch `drawerShell`'s internals.

- [ ] **Step 6: Commit**

```bash
git add docs/app/Shared.elm docs/tests-browser/nav-rail.spec.ts
git commit -m "Restructure shell layout: rail beside app bar, not above it"
```

---

### Task 3: `npm run gate` clean pass

**Files:** none new — verification only.

**Interfaces:** none.

- [ ] **Step 1: Run the full gate**

```bash
cd docs/.. && npm run gate
```

- [ ] **Step 2: Fix any new `elm-review`/`elm-format` findings introduced by this plan's changes**

Pre-existing findings unrelated to this plan (unused `Browser.Events` import, unused `initialViewportWidth`, the two duplicate-`class`-attribute calls at `Shared.elm:268` and `Shared.elm:723`, all pre-dating this plan) are **not** this task's responsibility — do not fix them here, they're tracked separately. Only fix findings that reference `Section`, `sections`, `sectionIsCurrent`, `railItem`, `docsNavRail`, `docsNavBar`, or the restructured `view` body.

- [ ] **Step 3: Commit any formatting fixes**

```bash
git add -u
git commit -m "elm-format"
```
