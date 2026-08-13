import { test, expect } from "@playwright/test";

/**
 * `/components/all` is the kitchen-sink page: every component's Usage section
 * stacked on one page, in drawer category order, each wrapped in an
 * `id`-anchored `.cv-auto` block (e.g. `#button`). The heavy stacked content is
 * gated behind an opt-in overview — the ~1800 custom-element upgrades only
 * happen after clicking "Show all components" (auto-revealed for `#`-fragment
 * deep-links). This is a broad smoke test — the per-component depth (live
 * preview, every API surface, code folds) is already covered by `usage.spec.ts`
 * and `all-components.spec.ts`; here we only confirm the gate reveals and the
 * stacked page mounts cleanly with its anchors.
 */
test("/components/all reveals and renders many components", async ({ page }) => {
  // The kitchen sink stacks all 329 examples on one page (every component's
  // Usage section at once), so first paint + hydration genuinely takes longer
  // than the default 30s Playwright test timeout — this is real render cost,
  // not a flaky wait. Each Usage section now also mounts M3e.Record / M3e.Build
  // rationale tabs (extra `m3e-tab` upgrades) for identical-by-design examples,
  // so the stacked total is ~2200 custom-element upgrades. On the 2-core CI
  // runner this exceeds the previous 90s budget; give it generous headroom
  // (a fast dev machine hydrates the page in ~80s, CI is ~2–3× slower).
  test.setTimeout(240_000);

  const errors: string[] = [];
  page.on("console", (m) => {
    if (m.type() === "error") errors.push(m.text());
  });
  page.on("pageerror", (e) => errors.push(String(e)));

  await page.goto("/components/all");

  // The page loads gated: the heading plus an opt-in overview, no stacked
  // blocks yet. Click "Show all components" to reveal the kitchen sink (this is
  // what defers the ~1800 custom-element upgrades until the user opts in).
  await page.getByRole("button", { name: /show all components/i }).click();

  // Not `waitForLoadState("networkidle")`: the elm-pages dev server holds a
  // long-lived `/stream` SSE connection open, so network idle never fires.
  // The page uses no `.max-w-4xl` wrapper (unlike the per-component pages), so
  // scope the wait to `document.body` and wait for at least one `m3e-*`
  // element to actually upgrade (ran connectedCallback) — after the reveal.
  await page.waitForFunction(() =>
    [...document.body.querySelectorAll("*")].some((el) => {
      const t = el.tagName.toLowerCase();
      if (!t.startsWith("m3e-")) return false;
      const Def = customElements.get(t);
      return Def ? el instanceof Def : false;
    })
  );

  // The page heading and multiple per-component Usage sections render.
  await expect(page.getByRole("heading", { name: "All components" }).first()).toBeVisible();
  const usageCount = await page.getByText("Usage", { exact: true }).count();
  expect(usageCount).toBeGreaterThan(10);

  // Deep-link anchors exist (e.g. the button block, `#button` per
  // `Layout.divWithId component.slug`). Scoped to the `.cv-auto` wrapper, not
  // a bare `#button`: `@m3e/web`'s TooltipElementBase auto-assigns its `for`
  // value as the DOM id of the preceding sibling with no id of its own, and
  // the Tooltip component's usage examples all use `M3e.Tooltip.for "button"`
  // — harmless in isolation on `/components/tooltip`, but on this stacked
  // page it collides with the Button section's own `id="button"` anchor,
  // producing duplicate IDs page-wide — a genuine, pre-existing page bug this
  // test surfaced (flagged separately; not fixed here).
  await expect(page.locator("div.cv-auto#button")).toBeAttached();

  expect(errors, `console errors:\n${errors.join("\n")}`).toEqual([]);
});
