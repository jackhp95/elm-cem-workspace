import { expect, test } from "@playwright/test";

/**
 * The tree/TOC drawer panels' open state must be genuinely MODEL-OWNED, and
 * Elm's notion of "narrow" must agree with the one `<m3e-drawer-container>`
 * actually uses.
 *
 * The bug these pin: `Shared.elm` used to render the panels' open state as a
 * per-render FORMULA (`not (isMobile model) || model.showMenu`) against its own
 * `768px` breakpoint, while `DrawerContainer`'s `auto` mode switches
 * `side` -> `push` at `960px` (`Breakpoint.Medium` = `(min-width: 960px)`, see
 * `@m3e/web/dist/core-layout.js`). In the 768-959px band the element
 * auto-CLOSED itself and told Elm so via its `change` event, but Elm's formula
 * still evaluated to the same constant `True` it had already rendered -- so the
 * virtual-DOM diff produced no patch and the panel stayed shut. Every later tap
 * of the hamburger recomputed the same constant, so the button was permanently
 * dead, and resizing back to a wide desktop did not recover it either.
 */

const DRAWER = "#docs-drawer";
const TREE = "#docs-drawer [slot='start']";
const TOC = "#docs-drawer [slot='end']";
// The tree/TOC panels are each wrapped in an `m3e-content-pane` too, and
// Playwright's CSS engine pierces the drawer container's own shadow root for
// `>` as well (matching its internal `.start`/`.content`/`.scrim`/`.end`
// layout divs as if they were direct children) -- the `overflow-y-auto`
// class is unique to `Shared.drawerShell`'s own plain content wrapper div.
const MAIN_SCROLL_REGION = "#docs-drawer > div.overflow-y-auto";

const hamburger = (page: import("@playwright/test").Page) =>
  page.getByRole("button", { name: "Toggle navigation" });
const tocToggle = (page: import("@playwright/test").Page) =>
  page.getByRole("button", { name: "On this page" });

/**
 * 900px is inside the band where Elm used to think "desktop" while the element
 * had already switched to `push` and slammed itself shut.
 */
test("at 900px the hamburger opens the tree on the first tap", async ({ page }) => {
  await page.setViewportSize({ width: 900, height: 900 });
  await page.goto("/components/button");

  // 900 < 960, so the element is in `push`: nothing is pinned open here.
  await expect(page.locator(TREE)).toBeHidden();

  await hamburger(page).click();
  await expect(page.locator(DRAWER)).toHaveAttribute("start", "");
  await expect(page.locator(TREE)).toBeVisible();

  // ...and it is a real toggle, not a one-way latch.
  await hamburger(page).click();
  await expect(page.locator(TREE)).toBeHidden();
});

test("at 900px the TOC toggle exists and opens the TOC panel", async ({ page }) => {
  await page.setViewportSize({ width: 900, height: 900 });
  await page.goto("/components/button");

  await expect(page.locator(TOC)).toBeHidden();
  await expect(tocToggle(page)).toHaveCount(1);

  await tocToggle(page).click();
  await expect(page.locator(TOC)).toBeVisible();
  await expect(page.locator(TOC).getByRole("link", { name: "API" })).toBeVisible();
});

/**
 * The STICKY half of the bug: it is not enough that a fresh load at 900px
 * works. Shrinking a desktop window through the band and growing it back has
 * to restore the pinned tree with no manual toggle -- that round trip is what
 * proved the old formula was stuck on a constant rather than tracking state.
 */
test("the tree survives a desktop -> 900px -> desktop round trip", async ({ page }) => {
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.goto("/guide");
  await expect(page.locator(DRAWER)).toHaveAttribute("start", "");
  await expect(page.locator(TREE)).toBeVisible();

  // Down into the band the element auto-closes; Elm must record that.
  await page.setViewportSize({ width: 900, height: 900 });
  await expect(page.locator(TREE)).toBeHidden();

  // Back up to desktop the tree must re-pin itself, with NO manual toggle.
  await page.setViewportSize({ width: 1440, height: 900 });
  await expect(page.locator(DRAWER)).toHaveAttribute("start", "");
  await expect(page.locator(TREE)).toBeVisible();

  // And the hamburger is still live afterwards (it closes the pinned tree).
  await hamburger(page).click();
  await expect(page.locator(TREE)).toBeHidden();
  await hamburger(page).click();
  await expect(page.locator(TREE)).toBeVisible();
});

/**
 * `DrawerContainer.willUpdate` force-closes `start` when `end` opens (and vice
 * versa) whenever the other panel is not in `side` mode -- WITHOUT dispatching
 * a `change` event. Elm therefore cannot learn about it from the element and
 * has to enforce the same exclusion in its own toggle handlers, or its model
 * drifts and the next hamburger tap is dead.
 */
test("on mobile, opening the TOC closes the tree and the hamburger reopens it on the first tap", async ({
  page,
}) => {
  await page.setViewportSize({ width: 411, height: 761 });
  await page.goto("/components/button");

  await hamburger(page).click();
  await expect(page.locator(TREE)).toBeVisible();

  await tocToggle(page).click();
  await expect(page.locator(TOC)).toBeVisible();
  // The element force-closed the tree behind Elm's back.
  await expect(page.locator(TREE)).toBeHidden();

  // ONE tap has to bring it back. Before the fix `showMenu` was still `True`,
  // so this tap computed `False` -- matching the already-closed element.
  await hamburger(page).click();
  await expect(page.locator(TREE)).toBeVisible();
  // ...and opening the tree closes the TOC, mirroring the element.
  await expect(page.locator(TOC)).toBeHidden();
});

/**
 * Chrome budget: the rail is compact (~96px) by default, and each drawer
 * panel now sizes to its own content (`w-max` in `Shared.drawerShell`)
 * instead of the library's fixed 360px default -- so the exact chrome width
 * varies by section (e.g. ~246px for Components' short labels, ~310px for
 * Guide's longest, "Accessibility you can't forget"). The worst measured
 * case -- Guide's longest labels, one panel open, 960px viewport -- still
 * leaves ~542px of content, comfortably above this test's 500px floor. With
 * no minimum content width and nothing gating the TOC, the pre-fix shell put
 * 96 + 360 + 360 = 816px of chrome on screen at every width >= 768, leaving
 * 144-208px of content at a 960-1024px viewport -- one word per line, code
 * blocks clipped.
 */
for (const width of [960, 1024, 1280, 1440]) {
  test(`the content column stays readable at ${width}px`, async ({ page }) => {
    await page.setViewportSize({ width, height: 900 });
    await page.goto("/components/button");

    // Wait for the shell to settle before measuring.
    await expect(page.locator("#docs-app-bar")).toBeVisible();

    const contentWidth = await page
      .locator(MAIN_SCROLL_REGION)
      .evaluate((el) => el.getBoundingClientRect().width);

    expect(contentWidth).toBeGreaterThanOrEqual(500);
  });
}

/**
 * `docsNavBar` is a real in-flow flex child of the shell's `flex-col` mobile
 * layout, so it sits BELOW the scroll region rather than floating over it and
 * structurally cannot cover the end of the page. This test is the regression
 * guard on that: if the bar ever goes back to `fixed inset-x-0 bottom-0`, the
 * last ~68px of every page becomes visible-looking but unreadable and
 * unclickable again, and no amount of per-region `pb-20` reliably prevents it
 * (it has to be remembered for each new scroll region, and once wasn't).
 */
test("the mobile bottom nav bar does not occlude the end of the page content", async ({
  page,
}) => {
  // `/guide/reference` renders every component's full API in one page (5000+
  // `m3e-card` custom elements to upgrade) -- a cold context can take longer
  // than the default 30s timeout just to load and hydrate it.
  test.setTimeout(60_000);
  await page.setViewportSize({ width: 411, height: 761 });
  await page.goto("/guide/reference");

  const bar = page.locator("m3e-nav-bar");
  await expect(bar).toBeVisible();
  const barBox = await bar.boundingBox();
  if (!barBox) throw new Error("nav bar has no box");

  // Scroll the real scroller (`.scroll-container`, inside m3e-content-pane's
  // shadow root) to the very bottom, then measure the deepest, last-rendered
  // element in document order -- NOT `:scope > *:last-child` (the panel's
  // single wrapping child, e.g. `m3e-nav-menu`). That wrapper's own bottom
  // edge, once its scroller is driven to `scrollHeight`, is mathematically
  // pinned to the scroller's own bottom edge regardless of how much trailing
  // padding the wrapper carries -- padding only grows how far you have to
  // scroll to reach it, never where the fully-scrolled wrapper's box ends up.
  // The deepest descendant (e.g. the link inside the last nav-menu item) is
  // the actual last piece of content a user would try to read or tap, and
  // its position DOES shift clear of the bar as trailing padding increases.
  const last = await page
    .locator("#main-content m3e-content-pane")
    .first()
    .evaluate((el) => {
      const sc = el.shadowRoot?.querySelector(".scroll-container");
      if (!sc) throw new Error("no scroll-container");
      sc.scrollTop = sc.scrollHeight;
      const nodes = el.querySelectorAll("*");
      const lastNode = nodes[nodes.length - 1];
      if (!lastNode) throw new Error("content pane has no descendants");
      const rect = lastNode.getBoundingClientRect();
      return { bottom: rect.bottom, width: rect.width, height: rect.height };
    });

  // Guard against a vacuous pass: if the last-in-document-order node were a
  // zero-size or `display:none` trailing element, its position would satisfy
  // the assertion below without actually measuring any visible content.
  expect(last.width > 0 || last.height > 0).toBe(true);
  expect(last.bottom).toBeLessThanOrEqual(barBox.y);
});
