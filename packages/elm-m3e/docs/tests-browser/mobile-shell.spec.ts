import { test, expect } from "@playwright/test";

/**
 * Mobile app-shell contract (Jack's rule: every UI-facing change ships a
 * Playwright test at the 411×761 mobile viewport before merge).
 *
 * What this pins:
 *  1. Content is still reachable — a page taller than the viewport must have
 *     a scrollable inner scroller (else content would be clipped).
 *  2. FOUC guard — the `:not(:defined)` rule ships (custom elements stay hidden
 *     until upgraded) and nothing is left stuck undefined after load.
 *  3. feedback-fab (dev-only) — present + upgraded with the right repo when the
 *     dev build injected it. Gated on EXPECT_FAB so the prod dist (no fab) still
 *     passes in CI.
 *
 * html/body are no longer forced `overflow: hidden` — the document scrolling
 * (and the mobile URL-bar collapse that comes with it) is accepted, not
 * fought, so there's no "document is pinned" assertion here anymore.
 */

const MOBILE = { width: 411, height: 761 };
// A guaranteed-tall route so the inner-scroll assertion is meaningful.
const LONG_ROUTE = "/guide/reference";

test.use({ viewport: MOBILE });

test("mobile shell: content scrolls in a bounded inner region (nothing clipped)", async ({ page }) => {
  // `/guide/reference` renders every component's full API in one page (5000+
  // `m3e-card` custom elements to upgrade) -- a cold context can take longer
  // than the default 30s timeout just to load and hydrate it.
  test.setTimeout(60_000);
  await page.goto(LONG_ROUTE);
  await expect(page.locator("#docs-app-bar")).toBeVisible();

  // Find the effective scroller for the main content, piercing shadow roots
  // (the m3e-drawer-container scrolls its content in shadow DOM). We assert at
  // least one descendant is a real overflow scroller with content taller than
  // its box, and that setting scrollTop actually moves it.
  const scroll = await page.evaluate(() => {
    const scrollers: Element[] = [];
    const visit = (root: Document | ShadowRoot) => {
      for (const el of Array.from(root.querySelectorAll("*"))) {
        const cs = getComputedStyle(el);
        const oy = cs.overflowY;
        if (
          (oy === "auto" || oy === "scroll") &&
          el.scrollHeight - el.clientHeight > 20
        ) {
          scrollers.push(el);
        }
        if ((el as HTMLElement).shadowRoot) visit((el as HTMLElement).shadowRoot!);
      }
    };
    visit(document);
    if (scrollers.length === 0) return { found: false, moved: 0, max: 0 };
    // Drive the deepest/largest scroller and confirm it actually moves.
    const target = scrollers.sort(
      (a, b) => b.scrollHeight - b.clientHeight - (a.scrollHeight - a.clientHeight),
    )[0];
    target.scrollTop = 300;
    return {
      found: true,
      moved: target.scrollTop,
      max: target.scrollHeight - target.clientHeight,
    };
  });

  expect(scroll.found).toBe(true);
  expect(scroll.max).toBeGreaterThan(20);
  expect(scroll.moved).toBeGreaterThan(0);
});

test("FOUC guard is shipped and nothing stays undefined after load", async ({ page }) => {
  await page.goto("/getting-started/welcome");
  await expect(page.locator("#docs-app-bar")).toBeVisible();

  // The `:not(:defined)` hide rule is present in a loaded stylesheet.
  const hasGuard = await page.evaluate(() => {
    for (const ss of Array.from(document.styleSheets)) {
      let rules: CSSRuleList;
      try {
        rules = ss.cssRules;
      } catch {
        continue; // cross-origin sheet — skip
      }
      for (const r of Array.from(rules)) {
        const sel = (r as CSSStyleRule).selectorText;
        if (sel && sel.includes(":not(:defined)")) return true;
      }
    }
    return false;
  });
  expect(hasGuard).toBe(true);

  // After load, the themed shell is upgraded (not stuck hidden).
  const undefinedCount = await page.evaluate(
    () => document.querySelectorAll(":not(:defined)").length,
  );
  expect(undefinedCount).toBe(0);
  const themeOpacity = await page
    .locator("m3e-theme")
    .first()
    .evaluate((el) => getComputedStyle(el).opacity);
  expect(themeOpacity).toBe("1");
});

// Dev-only: the widget is compiled out of the prod build, so only assert it when
// the run targets a dev server (EXPECT_FAB=1).
test("feedback-fab is present and upgraded in dev", async ({ page }) => {
  test.skip(!process.env.EXPECT_FAB, "prod build strips the dev-only feedback-fab");
  await page.goto("/getting-started/welcome");
  const fab = page.locator("feedback-fab");
  await expect(fab).toHaveCount(1);
  await expect(fab).toHaveAttribute("repo", "jackhp95/elm-m3e");
  // The widget bundle is injected as a dynamically-created <script> (async, not
  // parser-`defer`ed), so upgrade is not synchronous with page load — wait for
  // the bundle to load and register the custom element.
  await page.waitForFunction(
    () => document.querySelector("feedback-fab")?.matches(":defined") === true,
    { timeout: 15000 },
  );
});
