import { expect, test } from "@playwright/test";

/**
 * App-shell layout contract — pins the CURRENT split between the two branches
 * of `Shared.view`:
 *
 *  - Every docs route (everything except `/examples/*`): `<m3e-theme>` (itself
 *    `display: contents` — it carries no layout classes of its own anymore)
 *    renders a fixed-viewport `<div class="h-dvh flex flex-col md:flex-row">`.
 *    At `md` and up that is a ROW: nav rail on the left, main column on the
 *    right holding the app bar above the drawer/content area. Below `md` the
 *    rail is hidden and the same div is a COLUMN: main column on top, bottom
 *    nav bar as a real in-flow last child. Either way the ONE scroll region
 *    is the content-pane inside the drawer (`overflow-y: auto`); the shell
 *    div itself does not scroll.
 *  - `/examples/*` (full-viewport examples): `<m3e-theme>`'s child is the
 *    example page's OWN root — no docs-shell wrapper, no app bar, no nav —
 *    so double-nav is avoided and the page owns 100% of its own layout.
 *
 * Two failure modes are in scope and both are silent — no compile error, no
 * console warning:
 *
 *  1. Branch collapse. If the docs-shell wrapper is ever rendered for
 *     `/examples/*` too, an example gains a second app bar/nav it never
 *     asked for.
 *  2. A tall example's content becoming unreachable. Each example page is
 *     responsible for its OWN scrolling (internal `overflow-y-auto`, or the
 *     document itself) — nothing in the shared shell provides that for it.
 *     If an example page's root stops being tall enough to scroll (or a
 *     future ancestor re-adds a clipping `overflow: hidden`), content past
 *     the fold silently becomes unreachable rather than erroring.
 */
// An ID, not a class shape. This used to be `m3e-theme > div.h-dvh.flex`,
// which identified the shell only by coincidence: the moment an example route
// adopted the same bounded `h-dvh` + flex layout (`Route/Examples/Shop.elm`),
// that selector matched the example's OWN root too and the "examples skip the
// docs shell" test below started failing on a page that has no docs shell at
// all. Layout classes are shared vocabulary and cannot identify a component;
// `#docs-shell` can.
//
// Note this deliberately does not pin a direction either: the shell is
// `flex-col md:flex-row` (column on mobile, so the nav bar is a real bottom
// flex child instead of a `fixed` overlay). Direction is asserted per viewport
// below, from computed style.
const DOCS_SHELL = "#docs-shell";
const MAIN_COLUMN = `${DOCS_SHELL} > div.flex.flex-1.flex-col`;

// `#docs-drawer` slots the tree (`slot="start"`) and TOC (`slot="end"`) panels
// beside the page's own content. The tree/TOC panels are each wrapped in an
// `m3e-content-pane`, so `#docs-drawer m3e-content-pane` alone is ambiguous,
// and Playwright's CSS engine pierces the drawer container's own shadow root
// for `>` too (matching its internal `.start`/`.content`/`.scrim`/`.end`
// layout divs as if they were direct children), so `div:not([slot])` alone
// is ALSO ambiguous. The `overflow-y-auto` class is unique to
// `Shared.drawerShell`'s own plain wrapper div -- the one bounded scroll
// region.
const MAIN_SCROLL_REGION = "#docs-drawer > div.overflow-y-auto";

// A `/examples/*` route whose content is taller than the viewport, so the
// "content is reachable" assertion is meaningful rather than vacuous.
const TALL_EXAMPLE = "/examples/shop";

test("the docs shell is a fixed-viewport flex row (rail | main column) with one scroll region", async ({
  page,
}) => {
  await page.setViewportSize({ width: 1280, height: 800 });
  await page.goto("/getting-started/welcome");
  await expect(page.locator("#docs-app-bar")).toBeVisible();

  const shell = page.locator(DOCS_SHELL);
  // At `md` and up, `flex-row` places the nav rail on the left and the main
  // column on the right. If this reads `contents` or `block`, the shell has
  // flattened.
  await expect(shell).toHaveCSS("display", "flex");
  await expect(shell).toHaveCSS("flex-direction", "row");

  // The shell itself must NOT be the scroller — the content-pane inside the
  // drawer is the one bounded scroll region (`Shared.drawerShell`).
  await expect(shell).toHaveCSS("overflow-y", "visible");

  const mainColumn = page.locator(MAIN_COLUMN);
  await expect(mainColumn).toHaveCSS("display", "flex");
  await expect(mainColumn).toHaveCSS("flex-direction", "column");

  // Desktop: the rail is the visible section switcher, the bar is gone.
  await expect(page.locator("m3e-nav-rail")).toBeVisible();
  await expect(page.locator("m3e-nav-bar")).toBeHidden();

  await expect(page.locator(MAIN_SCROLL_REGION)).toHaveCSS("overflow-y", "auto");
});

test("below `md` the same shell is a flex COLUMN, with the nav bar as its last in-flow child", async ({
  page,
}) => {
  await page.setViewportSize({ width: 411, height: 761 });
  await page.goto("/getting-started/welcome");
  await expect(page.locator("#docs-app-bar")).toBeVisible();

  const shell = page.locator(DOCS_SHELL);
  await expect(shell).toHaveCSS("display", "flex");
  await expect(shell).toHaveCSS("flex-direction", "column");
  await expect(shell).toHaveCSS("overflow-y", "visible");

  // The rail is gone below `md`, so it takes no flex slot; the bar takes over.
  await expect(page.locator("m3e-nav-rail")).toBeHidden();
  const bar = page.locator("m3e-nav-bar");
  await expect(bar).toBeVisible();

  // The bar is a REAL flex child, not a `fixed` overlay. `position: static`
  // is the whole point: an out-of-flow bar occludes whatever is beneath it,
  // which is what forced compensating `pb-20 md:pb-0` on every scroll region.
  await expect(bar).toHaveCSS("position", "static");

  // ...and being in flow, it sits BELOW the main column rather than on top of
  // it: the column's box ends where the bar's begins, with no overlap.
  const mainBox = await page.locator(MAIN_COLUMN).boundingBox();
  const barBox = await bar.boundingBox();
  if (!mainBox || !barBox) throw new Error("shell children have no box");
  expect(mainBox.y + mainBox.height).toBeLessThanOrEqual(barBox.y + 1);
  expect(barBox.y + barBox.height).toBeLessThanOrEqual(761 + 1);

  // The single-scroll-region invariant survives the direction flip: the
  // document itself still doesn't scroll, only the drawer's inner pane.
  const docScroll = await page.evaluate(() => ({
    scrollable: document.documentElement.scrollHeight - window.innerHeight,
  }));
  expect(docScroll.scrollable).toBeLessThanOrEqual(1);
  await expect(page.locator(MAIN_SCROLL_REGION)).toHaveCSS("overflow-y", "auto");
});

test("a full-viewport example route skips the docs shell entirely", async ({ page }) => {
  await page.goto(TALL_EXAMPLE);

  // No docs-shell wrapper, no docs app bar, no docs nav main landmark — the
  // example owns its own chrome instead of getting a second one layered on.
  await expect(page.locator(DOCS_SHELL)).toHaveCount(0);
  await expect(page.locator("#docs-app-bar")).toHaveCount(0);
  await expect(page.locator("#main-content")).toHaveCount(0);
});

test("a tall example's content is reachable, not clipped off past the fold", async ({
  page,
}) => {
  await page.goto(TALL_EXAMPLE);

  // The page's own footer strip (`ExampleNav.footer`) sits at the very end of
  // its content — reachable only if SOMETHING scrolls (the document itself,
  // or the page's own internal scroll region; the shared shell contract
  // doesn't care which).
  const footerLink = page.getByRole("link", { name: "← Back to examples" });
  await expect(footerLink).not.toBeInViewport();

  await footerLink.scrollIntoViewIfNeeded();
  await expect(footerLink).toBeInViewport();
});

test("a component page composes rail, tree, content, and TOC together", async ({ page }) => {
  await page.goto("/components/button");

  // Rail: present, Components selected. `m3e-nav-item` is upgraded to
  // role="link" (href is set on every rail item — see nav-rail.spec.ts).
  await expect(
    page.locator("m3e-nav-rail").getByRole("link", { name: "Components", exact: true }),
  ).toHaveAttribute("selected", "");

  // Tree: pinned open on desktop, showing the (per-route, flat) Components
  // list -- see nav.spec.ts for the per-route contract itself.
  await expect(page.locator("#docs-drawer")).toHaveAttribute("start", "");
  await expect(
    page.locator("#docs-drawer [slot='start']").getByRole("link", { name: "Button", exact: true }),
  ).toBeVisible();

  // Content: the page's own heading renders in the main scroll region.
  await expect(
    page.locator(MAIN_SCROLL_REGION).getByRole("heading", { name: "Button" }),
  ).toBeVisible();

  // TOC: pinned open on desktop (no toggle button needed — see toc.spec.ts),
  // the API jump-link is visible in the end drawer slot.
  await expect(
    page.locator("#docs-drawer [slot='end']").getByRole("link", { name: "API" }),
  ).toBeVisible();
});

test("the shell carries the document direction", async ({ page }) => {
  await page.goto("/getting-started/welcome");
  await expect(page.locator("#docs-app-bar")).toBeVisible();

  const theme = page.locator("m3e-theme").first();
  // `dir` lives on the `m3e-theme` host itself (part of elm-cem's open-row
  // `_globals` axis), so direction must resolve there and inherit down to the
  // app bar and drawer. A missing `dir` would leave the RTL control in the
  // settings sheet with nothing to flip.
  await expect(theme).toHaveAttribute("dir", /^(ltr|rtl|auto)$/);
  await expect(theme).toHaveCSS("direction", "ltr");
});
