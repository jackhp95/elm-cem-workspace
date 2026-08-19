import { test, expect } from "@playwright/test";

/**
 * The per-component Usage section renders a live preview plus the derived Elm
 * across the available API surfaces, switched by a per-example tab strip.
 *
 * Two rendering facts shape these assertions:
 *  - the code is syntax-highlighted, so a token like `M3e.Button.view` is split
 *    across multiple spans (no single leaf holds it contiguously), and
 *  - long code blocks fold into `<details class="cf-fold">`, which render OPEN
 *    by default as of Phase C, so their text is present and visible; every
 *    surface's panel is mounted at once (the tab strip slides between them, with
 *    inactive panels `inert`/off-screen).
 * So we assert code *presence* (`toBeAttached`) for surfaces behind inactive tabs,
 * reserve visibility checks for stable, unfolded anchors (the Usage heading and
 * the tab strip), and separately assert the `open` attribute on every fold.
 *
 * NOTE (phantom substrate migration): The barrel (M3e.button), middle
 * (M3e.Html.Button.button), and bottom (M3e.Raw.Button.button) surfaces are
 * not generated in the phantom substrate (gen-barrel and gen-record-build are
 * no-ops; M3e.Html and M3e.Raw layers retired). The top surface (M3e.Button.view)
 * and raw HTML are always present; Record/Build show a rationale tab.
 */
test("/components/button shows a live Usage section with preview + code", async ({
  page,
}) => {
  const errors: string[] = [];
  page.on("console", (m) => {
    if (m.type() === "error") errors.push(m.text());
  });
  page.on("pageerror", (e) => errors.push(String(e)));

  await page.goto("/components/button");
  // Not `waitForLoadState("networkidle")`: the elm-pages dev server holds a
  // long-lived `/stream` SSE connection open, so network idle never fires.
  await page.waitForFunction(() => {
    const hosts = [...document.querySelectorAll("raw-html")];
    return hosts
      .flatMap((h) => [...h.querySelectorAll("m3e-button")])
      .some((el) => (el as HTMLElement & { shadowRoot: unknown }).shadowRoot);
  });

  // (1) Usage heading present.
  await expect(page.getByText("Usage", { exact: true }).first()).toBeVisible();

  // (2) The live preview populated and upgraded.
  const upgraded = await page.evaluate(() => {
    const hosts = [...document.querySelectorAll("raw-html")];
    return hosts
      .flatMap((h) => [...h.querySelectorAll("m3e-button")])
      .some((el) => Boolean((el as HTMLElement & { shadowRoot: unknown }).shadowRoot));
  });
  expect(upgraded).toBe(true);

  // (3) The derived M3e (Standard) code is rendered (attached; may be folded).
  // The barrel form (M3e.button) is not generated in the phantom substrate;
  // the top surface uses the qualified form M3e.Button.view.
  await expect(page.getByText("M3e.Button.view").first()).toBeAttached();

  // Code folds render OPEN by default (Phase C). Assert with count queries
  // (race-free vs a per-fold loop): at least one fold exists and none lack `open`.
  await expect(page.locator("details.cf-fold").first()).toBeAttached();
  await expect
    .poll(async () => page.locator("details.cf-fold:not([open])").count())
    .toBe(0);

  expect(errors, `console errors:\n${errors.join("\n")}`).toEqual([]);
});

test("/components/button renders code for the available API surfaces", async ({
  page,
}) => {
  await page.goto("/components/button");
  // Wait for the Standard (top) surface code to be rendered. Barrel form
  // (M3e.button) is not generated in the phantom substrate; top uses M3e.Button.view.
  await page.waitForFunction(() =>
    [...document.querySelectorAll("code.elmsh")].some((c) =>
      (c.textContent || "").includes("M3e.Button.view"),
    ),
  );

  // Each surface's panel is mounted. Top (M3e.Button.view) and raw HTML are
  // always present. Mid/bottom (M3e.Html.*/M3e.Raw.*) are null in the phantom
  // substrate, so their tabs are absent. Match on text present in the rendered page.
  for (const code of [
    "M3e.Button.view", // M3e top surface (Standard form)
    "<m3e-button", // raw HTML
  ]) {
    await expect(page.getByText(code).first()).toBeAttached();
  }

  // The layer tab strip is rendered. Only "M3e" and "HTML" tabs are guaranteed
  // present in the phantom substrate (mid/bottom retired). Check "M3e" tab.
  const m3eTab = page.getByText("M3e", { exact: true }).first();
  await expect(m3eTab).toBeVisible();
});
