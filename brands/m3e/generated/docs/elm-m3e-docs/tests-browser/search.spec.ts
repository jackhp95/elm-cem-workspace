import { test, expect, type Page, type Locator } from "@playwright/test";

/** The repo's standard mobile viewport (see mobile-shell.spec.ts). Below
 * `Breakpoint.XSmall` (600px), so the search view runs in FULLSCREEN mode. */
const MOBILE = { width: 411, height: 761 };

/**
 * Assert an element is inside the visible viewport, not merely `toBeVisible()`.
 *
 * `toBeVisible()` only means "has a non-empty box and isn't `display:none`" --
 * it says nothing about WHERE that box is, and `.click()` auto-scrolls before
 * acting. Together those masked a real shipped bug: `m3e-search-view`'s host is
 * `:host { display: block }` (static flow, unlike `m3e-bottom-sheet`'s fixed
 * host), so mounted after the shell's `h-dvh` box it landed at `y = 900` on a
 * 1400x900 desktop -- entirely below the fold, and all five tests here still
 * passed. This is the assertion that would have caught it.
 */
async function expectWithinViewport(page: Page, locator: Locator) {
  const box = await locator.boundingBox();
  const viewport = page.viewportSize();
  expect(box, "element has no bounding box at all").not.toBeNull();
  expect(viewport).not.toBeNull();
  expect.soft(box!.y, "top edge is above the fold").toBeGreaterThanOrEqual(0);
  expect(box!.y, "top edge is within the viewport height").toBeLessThan(viewport!.height);
  expect(box!.x, "left edge is within the viewport width").toBeLessThan(viewport!.width);
  expect(box!.x + box!.width, "right edge is within the viewport width").toBeGreaterThan(0);
}

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
  await page.goto("/getting-started/welcome");
  await page.getByRole("button", { name: "Search", exact: true }).click();

  const view = page.locator("m3e-search-view");
  await expect(view).toHaveAttribute("open", "");

  const input = view.locator("input");

  // The panel must be ON SCREEN, not just in the DOM -- see
  // `expectWithinViewport`. Checked on the host (whose static-flow box is what
  // the docked popover anchors itself to) and on the input the user types into.
  await expectWithinViewport(page, view);
  await expectWithinViewport(page, input);

  await input.fill("button");

  // A page-level entry (`heading = null`) renders its real `<title>`, which
  // is never the bare component name -- see `searchResultLink`'s doc comment
  // on why that distinction matters for the accessible tree.
  const result = view.getByRole("link", { name: "Button < Components < elm-m3e", exact: true });
  await expect(result).toBeVisible();

  await result.click();
  await expect(page).toHaveURL(/\/components\/button$/);
  await expect(page.locator("m3e-search-view")).toHaveCount(0);
});

/**
 * A heading-level entry (`heading` non-null) renders the matched heading as
 * its primary text and the page's own title as a secondary line -- and
 * navigates to the page the heading lives on when clicked, with a real
 * `#anchor` in the URL.
 *
 * `Doc.sectionHeadingWithId` (used by every Components page, e.g. `#api` on
 * `/components/button` -- see `Route/Components/Name_.elm`) renders a
 * `<m3e-heading id="..." level="...">` CUSTOM element. `build-search-index.mjs`'s
 * `HEADING_SELECTOR` now matches `m3e-heading` in addition to native
 * `h1`-`h6` (fixed in 1488c602), so the crawled index carries a real
 * `heading: "API", anchor: "api"` entry for that page.
 *
 * Every Components page has its own "API" heading, so the query alone
 * returns 20 same-named results (`filterSearchEntries` caps at 20) -- pin
 * the Button one by `href` rather than by accessible name/text, which is
 * ambiguous here on purpose (it's the realistic case this feature has to
 * handle well, not a contrived one).
 */
test("clicking a heading result navigates to the page and its anchor", async ({ page }) => {
  await page.goto("/getting-started/welcome");
  await page.getByRole("button", { name: "Search", exact: true }).click();

  const view = page.locator("m3e-search-view");
  await view.locator("input").fill("API");

  const result = view.locator('a[href="/components/button#api"]');
  await expect(result).toBeVisible();
  // The secondary line is the page's own title, not the heading text.
  await expect(result.getByText("Button < Components < elm-m3e")).toBeVisible();

  await result.click();
  await expect(page).toHaveURL(/\/components\/button#api$/);
  await expect(page.locator("m3e-search-view")).toHaveCount(0);
});

/**
 * A heading match with no anchor is a real, still-valid case elsewhere in
 * the index (not every heading the crawler visits renders as `m3e-heading`
 * with an id) -- this keeps that shape covered alongside the anchor case
 * above.
 */
test("clicking a heading result with no anchor navigates to the page it lives on", async ({ page }) => {
  await page.goto("/getting-started/welcome");
  await page.getByRole("button", { name: "Search", exact: true }).click();

  const view = page.locator("m3e-search-view");
  await view.locator("input").fill("renders nothing");

  const result = view.getByRole("link", { name: "A class renders nothing" });
  await expect(result).toBeVisible();
  await expect(result).toHaveAttribute("href", "/guide/troubleshooting");
  // The secondary line is the page's own title, not the heading text.
  await expect(result.getByText("Troubleshooting < Guide < elm-m3e")).toBeVisible();

  await result.click();
  await expect(page).toHaveURL(/\/guide\/troubleshooting$/);
  await expect(page.locator("m3e-search-view")).toHaveCount(0);
});

test("Cmd/Ctrl+K opens search from an arbitrary route", async ({ page }) => {
  await page.goto("/guide");
  await page.keyboard.press("ControlOrMeta+k");
  await expect(page.locator("m3e-search-view")).toHaveAttribute("open", "");
});

/**
 * Mobile (below `Breakpoint.XSmall` = 600px), where the view runs in
 * FULLSCREEN mode. This is the regression test for the bug that shipped past
 * five green desktop-only tests:
 *
 * `mode="auto"` installs an `M3eBreakpointObserver` whose callback fires once
 * on install. Below 600px it computed `fullscreen`, saw that differed from the
 * `docked` default AND that `open` was already true (we mount the element
 * pre-opened), and set `this.open = false` -- WITHOUT dispatching `toggle`.
 * Elm never heard about it, so `model.searchOpen` stayed `true` forever: the
 * panel never opened, and because no later FAB tap changed the model, no
 * re-render ever asked the element to open again. The FAB was dead after one
 * tap. `Shared.searchModeFor` now drives `mode` explicitly from
 * `model.viewportWidth`, so no observer is installed and there is no race.
 *
 * Both halves matter -- "it opens at all" and "it still opens the SECOND
 * time" -- so both are asserted here.
 */
test("on mobile the FAB opens search fullscreen, and still works after it is closed", async ({
  page,
}) => {
  await page.setViewportSize(MOBILE);
  await page.goto("/getting-started/welcome");

  const fab = page.getByRole("button", { name: "Search", exact: true });
  await fab.click();

  const view = page.locator("m3e-search-view");
  await expect(view).toHaveAttribute("open", "");
  // Explicit, not `auto` -- `auto` is the race described above.
  await expect(view).toHaveAttribute("mode", "fullscreen");

  // Present in the DOM is not enough: assert it is actually on screen, and
  // that the query path really ran (the index only loads on the `query` event
  // the element fires when it opens, so results prove the panel opened).
  await expectWithinViewport(page, view);
  const input = view.locator("input");
  await expectWithinViewport(page, input);
  await input.fill("button");
  await expect(view.getByRole("link", { name: "Button < Components < elm-m3e", exact: true })).toBeVisible();

  // Close it through the element's OWN back button (in shadow DOM -- Playwright
  // CSS pierces open shadow roots), the path that dispatches `toggle` ->
  // `CloseSearch` -> unmount. Elm dropping the element is what proves the two
  // stayed in sync. It has to be a REAL click: `#handleCloseClick` closes by
  // re-focusing the input with a `closeOnInputFocus` flag set, so it only
  // works if focus actually left the input first.
  await view.locator("m3e-icon-button.close").click();
  await expect(view).toHaveCount(0);

  // The second tap is the assertion the old code could not pass.
  await fab.click();
  await expect(view).toHaveAttribute("open", "");
  await expectWithinViewport(page, view);
});

/**
 * `/examples/*` routes render with NO docs shell (Shared.view short-circuits
 * to the bare page body), so there is no FAB and nothing for `searchOpen` to
 * mount. `Shared.subscriptions` gates the Cmd/Ctrl+K port on `hasDocsShell`
 * for exactly that reason: without the gate the shortcut set
 * `searchOpen = true` with nothing rendered to show for it, and the flag then
 * survived until the next `PageChanged` -- popping the overlay open,
 * unrequested, on whatever route the user navigated to next.
 */
test("Cmd/Ctrl+K on an /examples/* route opens nothing, and does not leak into the next route", async ({
  page,
}) => {
  await page.goto("/examples/dashboard");
  await page.keyboard.press("ControlOrMeta+k");
  await expect(page.locator("m3e-search-view")).toHaveCount(0);

  await page.goto("/guide");
  await expect(page.locator("m3e-search-view")).toHaveCount(0);
});

/**
 * `PageChanged` re-pins `treeOpen`/`tocOpen` on every route change so a
 * mobile overlay cannot survive the navigation it triggered. The search
 * overlay is that same kind of overlay and is closed there too -- this covers
 * the path that does NOT go through `searchResultLink`'s own `CloseSearch`
 * (which is what the navigation tests above exercise).
 */
test("navigating with search open closes it, and does not leave a stale query behind", async ({
  page,
}) => {
  await page.goto("/getting-started/welcome");
  // An in-app route change first, so the step back below is an SPA history
  // pop (which fires `PageChanged`) rather than a full document reload.
  await page.getByRole("link", { name: "Guide", exact: true }).first().click();
  await expect(page).toHaveURL(/\/guide$/);

  const view = page.locator("m3e-search-view");
  await page.getByRole("button", { name: "Search", exact: true }).click();
  await view.locator("input").fill("button");
  await expect(view.getByRole("link", { name: "Button < Components < elm-m3e", exact: true })).toBeVisible();

  // Navigate WITHOUT clicking a search result, so nothing but `PageChanged`
  // can be what closes the overlay. (The open panel holds the rest of the page
  // `inert`, so a nav-rail click is not available here -- browser history is.)
  await page.goBack();
  await expect(page).toHaveURL(/\/getting-started\/welcome$/);
  await expect(view).toHaveCount(0);

  // Reopening starts from an empty query, not the one from the last route.
  await page.getByRole("button", { name: "Search", exact: true }).click();
  await expect(view.locator("input")).toHaveValue("");
});

test("a failed index fetch shows an unavailable message, not a silently empty panel", async ({
  page,
}) => {
  await page.route("**/search-index.json", (route) => route.abort());
  await page.goto("/getting-started/welcome");
  await page.getByRole("button", { name: "Search", exact: true }).click();
  await page.locator("m3e-search-view input").fill("button");
  await expect(page.getByText("Search unavailable")).toBeVisible();
});
