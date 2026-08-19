import { expect, test } from "@playwright/test";

/**
 * Soft-navigation attribute ownership between Elm's virtual DOM and the
 * `@m3e/web` custom elements.
 *
 * THE BUG THIS PINS
 *   Several `m3e-*` elements reflect a DEFAULT value onto themselves as an
 *   ATTRIBUTE when they upgrade — `m3e-app-bar` writes `size="small"`,
 *   `m3e-icon-button` writes `size`/`shape`/`width`, `m3e-nav-bar` writes
 *   `mode`, and so on. Elm never authored those attributes, so its virtual DOM
 *   has no record of them.
 *
 *   That is harmless until Elm PATCHES an existing element across a route
 *   change. Going `/examples/settings` -> `/examples/list-detail`, Elm reuses
 *   the same `<m3e-app-bar>` node: the old route authored `size="medium"`, the
 *   new one authors no `size` at all, so Elm removes the attribute it believes
 *   it owns. The element is already upgraded, so nothing re-applies the
 *   default, and the bar collapses from 64px to 24px — and STAYS collapsed for
 *   every subsequent patched route.
 *
 *   A hard reload always looks correct, which is what makes this so easy to
 *   miss: the element upgrades fresh and re-reflects its default.
 *
 * WHY GEOMETRY AND NOT JUST THE ATTRIBUTE
 *   Asserting `size` is non-null would pass if some future fix wrote the
 *   attribute but the element ignored it. Height is the property a reader
 *   actually experiences, so both are asserted.
 *
 * WHY THIS PAIR OF ROUTES
 *   `settings` authors `size="medium"`; `list-detail` authors `M3e.appBar []`
 *   with no size. That is exactly the author-then-omit shape that triggers the
 *   removal. `mail` -> `travel` is the same shape in the source but Elm happens
 *   to REPLACE rather than patch there, so it silently passes — which is why
 *   the bug reads as intermittent and why this spec names the patching pair.
 */

const SOFT_NAV_PAIRS = [
  // [from, to, the `to` route's link text/href, expected height once fixed]
  { from: "/examples/settings", to: "/examples/list-detail" },
  { from: "/examples/list-detail", to: "/examples/supporting-pane" },
];

// `fixme`, not `skip`: this is a KNOWN-FAILING pin on a reproduced defect, not
// a test that is unimportant or flaky. The fix is keyed-node support across
// HtmlIr / elm-typed-html / M3e / elm-cem, handed off in
// `specs/2026-08-08-keyed-nodes-handoff.md` and deliberately NOT attempted in
// this repo. Flip these back to `test(...)` as the acceptance signal when that
// work lands; the first pair currently fails with `Expected "small", got null`.
for (const { from, to } of SOFT_NAV_PAIRS) {
  test.fixme(`${from} -> ${to}: the app bar keeps its size through a soft nav`, async ({
    page,
  }) => {
    await page.setViewportSize({ width: 1280, height: 800 });

    // Baseline: what the destination looks like when loaded directly. This is
    // the contract — a soft nav must not render something different.
    await page.goto(to);
    const fresh = await page.evaluate(() => {
      const ab = document.querySelector("m3e-app-bar")!;
      return {
        size: ab.getAttribute("size"),
        height: Math.round(ab.getBoundingClientRect().height),
      };
    });
    expect(fresh.size, "hard-loaded app bar should carry a size").not.toBeNull();
    expect(fresh.height).toBeGreaterThan(40);

    // Now arrive at the same route via an in-app link instead of a page load.
    await page.goto(from);
    await page.locator(`a[href="${to}"]`).first().click();
    await page.waitForURL(new RegExp(`${to}/?$`));

    const soft = await page.evaluate(() => {
      const ab = document.querySelector("m3e-app-bar")!;
      return {
        size: ab.getAttribute("size"),
        height: Math.round(ab.getBoundingClientRect().height),
      };
    });

    expect(
      soft.size,
      "soft nav dropped the element's reflected default `size` attribute",
    ).toBe(fresh.size);
    expect(
      soft.height,
      "soft-navigated app bar collapsed relative to a hard load",
    ).toBe(fresh.height);
  });
}
