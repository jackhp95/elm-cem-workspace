import { expect, test } from "@playwright/test";

/**
 * `Shared.tocPanel` mounts a single `m3e-toc` pointed at the content
 * container; it discovers headings from the real rendered DOM at runtime
 * (`M3e.Toc.for "main-content"`), rendering one `m3e-toc-item` (role
 * "link", no `href`) per heading found.
 */
test("a component page's TOC jump-link scrolls to its matching heading", async ({
  page,
}) => {
  await page.goto("/components/button");
  const tocLink = page
    .locator("#docs-drawer [slot='end']")
    .getByRole("link", { name: "API" });
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

/**
 * The toggle is unconditional now — `Shared.appShellBar` has no advance list
 * of headings to gate on (`m3e-toc` discovers them from the live DOM), so
 * even a page that never called the old `View.withToc` still gets a button,
 * and its panel still finds real headings. At the default (>= 1200px) test
 * viewport the TOC is pinned open already (`Shared.tocPinBreakpointPx`), so
 * `/guide` — which never opted into the old hand-built TOC — should surface
 * its own "The Guide" / "Chapters" headings without any click.
 */
test("a page that never opted into the old hand-built TOC still shows the toggle and real headings", async ({
  page,
}) => {
  await page.goto("/guide");
  await expect(page.getByRole("button", { name: "On this page" })).toBeVisible();

  const tocPanel = page.locator("#docs-drawer [slot='end']");
  await expect(tocPanel.getByRole("link", { name: "The Guide" })).toBeVisible();
  await expect(tocPanel.getByRole("link", { name: "Chapters" })).toBeVisible();
});

/**
 * At or above `Shared.tocPinBreakpointPx` (1200) the TOC is pinned open beside
 * the tree. The toggle button still renders there -- `model.tocOpen` is the
 * single authority for the panel at EVERY width now, so the button collapses
 * the pinned panel (handing its 280px back to the content column) instead of
 * being the focusable no-op it would have been under the old
 * width-dependent visibility formula.
 */
test("on a wide desktop, the TOC is pinned open and its toggle collapses it", async ({
  page,
}) => {
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.goto("/components/button");

  const tocPanel = page.locator("#docs-drawer [slot='end']");
  await expect(tocPanel).toBeVisible();

  const toggle = page.getByRole("button", { name: "On this page" });
  await toggle.click();
  await expect(tocPanel).toBeHidden();
  await toggle.click();
  await expect(tocPanel).toBeVisible();
});

/**
 * Between 960 and 1200 there is a rail (96px) plus at most one 280px panel on
 * screen, so the content column keeps ~580px. Pinning the TOC there too would
 * leave it ~300px -- one word per line. The TOC is toggle-driven instead, and
 * opening it closes the tree (`Shared.panelsExclusive`).
 */
test("at 1024px the TOC is not pinned and opening it closes the tree", async ({
  page,
}) => {
  await page.setViewportSize({ width: 1024, height: 900 });
  await page.goto("/components/button");

  const tree = page.locator("#docs-drawer [slot='start']");
  const tocPanel = page.locator("#docs-drawer [slot='end']");
  await expect(tree).toBeVisible();
  await expect(tocPanel).toBeHidden();

  await page.getByRole("button", { name: "On this page" }).click();
  await expect(tocPanel).toBeVisible();
  await expect(tree).toBeHidden();
});

/**
 * A jump-link's native `href="#id"` scrolls the page, but on mobile the `end`
 * drawer is an `over`/`push` overlay with the main content `inert` while
 * open -- without an explicit close, the user would land on the heading but
 * stay stuck behind the still-open panel. Regression test for the bug where
 * `tocPanel`'s links had no way to close the panel on click.
 */
test("on mobile, clicking a TOC jump-link closes the panel", async ({
  page,
}) => {
  await page.setViewportSize({ width: 411, height: 761 });
  await page.goto("/components/button");

  const tocPanel = page.locator("#docs-drawer [slot='end']");
  await page.getByRole("button", { name: "On this page" }).click();
  await expect(tocPanel).toBeVisible();

  await tocPanel.getByRole("link", { name: "API" }).click();
  await expect(tocPanel).toBeHidden();
  await expect(page.locator("#api")).toBeInViewport();
});

/**
 * `<m3e-drawer-container>`'s scrim click closes BOTH the start and end
 * drawers in a single `change` event (`_handleScrimClick` in
 * `@m3e/web/dist/drawer-container.js` sets `this.start = false` AND
 * `this.end = false`). Regression test for the bug where `drawerChangeDecoder`
 * only read `event.target.start`, leaving `model.endOpen` desynced from the
 * element after a scrim dismiss -- the next tap of the toggle button would
 * compute the state the element was already in (a dead tap), requiring a
 * second tap to actually reopen it.
 */
test("on mobile, the TOC panel reopens on the first tap after being dismissed via the scrim", async ({
  page,
}) => {
  await page.setViewportSize({ width: 411, height: 761 });
  await page.goto("/components/button");

  const toggle = page.getByRole("button", { name: "On this page" });
  const tocPanel = page.locator("#docs-drawer [slot='end']");

  await toggle.click();
  await expect(tocPanel).toBeVisible();

  // Dismiss via the drawer's scrim, not the toggle button -- clicking near
  // the top-left corner, which the `end` (right-hand) panel doesn't cover.
  await page.locator("#docs-drawer .scrim").click({ position: { x: 5, y: 5 } });
  await expect(tocPanel).toBeHidden();

  // A single subsequent tap must reopen it. Before the fix, `endOpen` was
  // still `True` from before the scrim dismiss, so this tap computed `False`
  // -- matching the already-closed state, so nothing visibly happened.
  await toggle.click();
  await expect(tocPanel).toBeVisible();
});
