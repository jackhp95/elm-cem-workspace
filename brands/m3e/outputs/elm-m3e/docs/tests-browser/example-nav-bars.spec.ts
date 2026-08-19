import { expect, test } from "@playwright/test";

/**
 * Mobile bottom-nav contract, shared by every full-viewport example route.
 *
 * These pages each own 100% of their own layout (they deliberately skip the
 * docs shell — see `app-shell.spec.ts`), so nothing else pins this for them.
 * Before this contract existed, each bar was `position: fixed inset-x-0
 * bottom-0`: out of flow, floating over the scroll region beneath it, and
 * therefore requiring a compensating `pb-24` on every scrollable region that
 * might reach the viewport bottom.
 *
 * That compensation is the bug this guards against. It has to be remembered
 * separately for every current AND future scroll region, it is invisible when
 * forgotten (content looks fine until you scroll to the very end), and it was
 * in fact forgotten more than once — `Settings.elm` had it on the content
 * wrapper but not on the sibling `exampleFooter`, and the docs shell shipped a
 * drawer region without it.
 *
 * An in-flow bar cannot occlude anything above it, by construction. These
 * assertions pin that structural property rather than the padding workaround,
 * so a regression to `fixed` fails here instead of silently hiding content.
 *
 * Every full-viewport example route is covered. `/examples/dashboard` was the
 * last holdout — a `sticky bottom-0` bar over a `min-h-screen`
 * document-scrolling page. `sticky` did reserve its own space, so it was not
 * the occlusion bug, but it put the bar at the end of a long *document*
 * instead of the bottom of a bounded pane. It is now bounded like the rest.
 */
const MOBILE = { width: 411, height: 761 };

const ROUTES = [
  "/examples/dashboard",
  "/examples/shop",
  "/examples/mail",
  "/examples/feed",
  "/examples/settings",
  "/examples/list-detail",
  "/examples/supporting-pane",
  "/examples/travel",
];

for (const route of ROUTES) {
  test(`${route}: the mobile bottom nav bar is a real in-flow flex child`, async ({
    page,
  }) => {
    await page.setViewportSize(MOBILE);
    await page.goto(route);

    const bar = page.locator("m3e-nav-bar");
    await expect(bar).toBeVisible();

    const result = await page.evaluate(() => {
      const barEl = document.querySelector("m3e-nav-bar")!;

      // `position` is checked on the bar AND on every ancestor up to <body>:
      // several of these routes wrap the bar in a `<nav>` or `<div>` that
      // carries the layout classes, so asserting only the custom element
      // would miss a wrapper that went back to `fixed`.
      const positions: string[] = [];
      for (let el: Element | null = barEl; el && el !== document.body; el = el.parentElement) {
        positions.push(getComputedStyle(el).position);
      }

      const before = barEl.getBoundingClientRect().top;

      // Drive every scroller on the page to its end, then re-measure the bar.
      // An in-flow bar in a bounded layout must not move; a `fixed` one would
      // also not move, which is why the overlap and viewport-flush checks
      // below are what actually distinguish them.
      const scrollers = Array.from(document.querySelectorAll("*")).filter((el) => {
        const oy = getComputedStyle(el).overflowY;
        return (oy === "auto" || oy === "scroll") && el.scrollHeight - el.clientHeight > 1;
      });
      for (const s of scrollers) s.scrollTop = s.scrollHeight;
      window.scrollTo(0, document.documentElement.scrollHeight);

      const box = barEl.getBoundingClientRect();

      // The deepest, last-rendered element inside each scroller is the last
      // thing a user would try to read or tap. None of them may end up under
      // the bar once fully scrolled.
      let worstOverlap = 0;
      for (const s of scrollers) {
        const nodes = s.querySelectorAll("*");
        const last = nodes[nodes.length - 1];
        if (!last) continue;
        const r = last.getBoundingClientRect();
        if (r.width === 0 && r.height === 0) continue;
        worstOverlap = Math.max(worstOverlap, r.bottom - box.top);
      }

      return {
        positions,
        movedWhileScrolling: Math.abs(barEl.getBoundingClientRect().top - before),
        barTop: box.top,
        barBottom: box.bottom,
        viewportHeight: window.innerHeight,
        worstOverlap,
        scrollerCount: scrollers.length,
      };
    });

    // No `fixed` anywhere on the bar's ancestor chain — that is the whole point.
    expect(result.positions).not.toContain("fixed");

    // The bar ends flush with the bottom of the visible viewport, so it is
    // genuinely a bottom bar and not merely somewhere in the document.
    expect(Math.abs(result.barBottom - result.viewportHeight)).toBeLessThanOrEqual(1);

    // It stays put while the page's scrollers are driven to their end — a bar
    // at the bottom of a long *document* would scroll away instead.
    expect(result.movedWhileScrolling).toBeLessThanOrEqual(1);

    // Nothing is left underneath it once everything is scrolled to the end.
    expect(result.worstOverlap).toBeLessThanOrEqual(0);
  });
}

test("at desktop width the example bottom bars are gone entirely", async ({ page }) => {
  await page.setViewportSize({ width: 1280, height: 800 });

  for (const route of ROUTES) {
    await page.goto(route);
    // `md:hidden` may sit on the custom element or on a wrapper, so assert on
    // rendered geometry rather than the element's own computed `display`:
    // getComputedStyle on a child of a `display: none` parent still reports
    // the child's own value, which would pass vacuously.
    await expect(page.locator("m3e-nav-bar")).toBeHidden();
  }
});
