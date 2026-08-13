import { test, expect } from "@playwright/test";
import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";

const here = path.dirname(fileURLToPath(import.meta.url));

/**
 * Generic per-component contract — runs against EVERY component demo page
 * (every slug in the generated `data/reference.json`), closing the
 * verification gap (#36): the old harness hand-picked ~5 components, so a
 * broken element on any other page shipped green.
 *
 * Each demo page is asserted for the runtime facts `Test.Html` cannot see:
 *   1. No console errors / uncaught exceptions while the page mounts.
 *   2. Every `<m3e-*>` tag in the demo content is a REGISTERED custom element
 *      (catches a hallucinated/typo'd tag — the element bundle never defined it).
 *   3. At least one `<m3e-*>` element actually upgraded (has a shadowRoot or is
 *      `display:contents`), i.e. the demo really mounted live components.
 *
 * The deeper per-component facts (accessible names, value round-trips, open/close
 * behaviour) stay in `contract.spec.ts`; this file is the broad safety net.
 */

// The component-page content lives in the `.max-w-4xl` container; the app shell
// (app bar, drawer) sits outside it. Scope assertions to the demo content.
const CONTENT = ".max-w-4xl";

const reference: Array<{ slug: string; name: string }> = JSON.parse(
  fs.readFileSync(path.join(here, "..", "data", "reference.json"), "utf8")
);

// Primitives that are documented but have no interactive demo page of their own
// would be skipped here; the reference only contains component modules, so every
// slug has a `/components/<slug>` route (Route.Components.Name_ covers them all).
const slugs = reference.map((c) => c.slug).sort();

test.describe("every component demo upgrades and mounts cleanly", () => {
  for (const slug of slugs) {
    test(`/components/${slug}`, async ({ page }) => {
      const errors: string[] = [];
      page.on("console", (m) => {
        // Ignore resource-load 404s: some example previews reference placeholder
        // assets (e.g. an avatar `src="face.jpg"` that demonstrates icon
        // fallback). That's a missing demo asset, not a component/JS error.
        if (m.type() === "error" && !/Failed to load resource/.test(m.text())) {
          errors.push(m.text());
        }
      });
      page.on("pageerror", (e) => errors.push(String(e)));

      await page.goto(`/components/${slug}`);
      // Wait for the demo to actually mount its live components. NOT
      // `waitForLoadState("networkidle")`: the elm-pages dev server holds a
      // long-lived `/stream` SSE connection open for live-reload, so the page
      // never reaches network idle and the wait would hang until timeout.
      // Instead wait deterministically for at least one m3e element to upgrade
      // (the same condition assertion (3) below verifies).
      await page.waitForFunction((sel) => {
        const root = document.querySelector(sel) ?? document.body;
        return [...root.querySelectorAll("*")].some((el) => {
          const t = el.tagName.toLowerCase();
          if (!t.startsWith("m3e-")) return false;
          const Def = customElements.get(t);
          return Def ? el instanceof Def : false;
        });
      }, CONTENT);

      // (2) every m3e-* tag in the demo content is a registered custom element.
      const unregistered = await page.evaluate((sel) => {
        const root = document.querySelector(sel) ?? document.body;
        const tags = new Set<string>();
        root.querySelectorAll("*").forEach((el) => {
          const t = el.tagName.toLowerCase();
          if (t.startsWith("m3e-")) tags.add(t);
        });
        return [...tags].filter((t) => !customElements.get(t));
      }, CONTENT);
      expect(
        unregistered,
        `unregistered m3e-* tags on /components/${slug}`
      ).toEqual([]);

      // (3) at least one m3e element actually upgraded.
      const upgraded = await page.evaluate((sel) => {
        const root = document.querySelector(sel) ?? document.body;
        return [...root.querySelectorAll("*")].some((el) => {
          const t = el.tagName.toLowerCase();
          if (!t.startsWith("m3e-")) return false;
          const Def = customElements.get(t);
          // upgraded === instance of its definition (ran connectedCallback);
          // covers both shadow-DOM and display:contents elements.
          return Def ? el instanceof Def : false;
        });
      }, CONTENT);
      expect(
        upgraded,
        `/components/${slug} should mount at least one upgraded m3e element`
      ).toBe(true);

      // (1) clean mount.
      expect(errors, `console errors on /components/${slug}`).toEqual([]);
    });
  }
});
