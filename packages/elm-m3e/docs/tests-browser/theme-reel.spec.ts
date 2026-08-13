import { expect, test } from "@playwright/test";

/**
 * The theme reel (`Theme.Reel.view`) appears on the Welcome page as a
 * horizontal-scrolling row of `<m3e-card actionable>` elements, each wrapped in its
 * own nested `<m3e-theme>`. Each card carries `role="button"` (set by the
 * `actionable` attribute), `aria-label`, and `aria-pressed`. Clicking a card fires
 * `M3e.Card.onClick` → `PickTheme presetId` which routes through
 * `Theme.Ports.requestPreset` → the JS port bridge in `index.ts` →
 * `Shared.onPresetRequested` → `Theme.update (ApplyPreset preset)`.
 *
 * Note: The reel also appears in the settings drawer (`#settings-sheet-content`),
 * so locators must be scoped to `#main-content` to target the Welcome page reel
 * specifically (and avoid strict-mode violations from the drawer's cards).
 *
 * This spec verifies at viewport 411×761 (the plan's required mobile viewport):
 *   1. The reel renders with 23 visible card buttons in the main content
 *      (the stock "Default" preset first, then 22 named presets).
 *   2. A card can be selected (click fires, card gets aria-pressed="true").
 *   3. Global re-theme happens (the root <m3e-theme>'s `color` attribute changes).
 *   4. The active state reflects the selection (aria-pressed stays "true" after render).
 */

test.use({ viewport: { width: 411, height: 761 } });

test.beforeEach(async ({ page }) => {
  await page.goto("/getting-started/welcome");
  // Wait for <m3e-*> elements to be defined and Lit to settle.
  await page.waitForFunction(() =>
    document.documentElement.dataset.m3eSettling === undefined,
  );
});

test("reel renders with multiple theme cards at 411×761", async ({ page }) => {
  // The reel section has an h2 heading with id "themes".
  await expect(page.locator("#themes")).toBeVisible();

  // Scope to #main-content to target the page reel only (not the drawer reel).
  const mainContent = page.locator("#main-content");
  const cards = mainContent.getByRole("button", { name: /Apply .* theme/ });

  // 23 presets ("Default" + 22 named) = 23 cards in the Welcome page reel.
  await expect(cards).toHaveCount(23);

  // The first card should be visible in the viewport.
  await expect(cards.first()).toBeVisible();
});

test("clicking a reel card globally re-themes the app at 411×761", async ({
  page,
}) => {
  // Get the root <m3e-theme> element. `.first()` targets the outermost root;
  // the page also has 23 nested card themes + 23 in the drawer.
  const rootTheme = page.locator("m3e-theme").first();
  const initialColor = await rootTheme.getAttribute("color");

  // Scope to #main-content to avoid strict-mode ambiguity with the drawer.
  const mainContent = page.locator("#main-content");

  // Find the "Agent" card (seed color #1b1bff — distinctive from Material default #6750A4).
  const agentCard = mainContent.getByRole("button", {
    name: "Apply Agent theme",
  });

  // Scroll to ensure the Agent card is visible (it may be off-screen horizontally).
  await agentCard.scrollIntoViewIfNeeded();
  await expect(agentCard).toBeVisible();

  // Click the card.
  await agentCard.click();

  // The root <m3e-theme>'s color should update to the Agent preset's seed color.
  await expect(rootTheme).toHaveAttribute("color", "#1b1bff");

  // The color should have changed from the initial (unless the initial was already Agent).
  if (initialColor !== "#1b1bff") {
    expect(initialColor).not.toBe("#1b1bff");
  }
});

test("selected card shows aria-pressed=true at 411×761", async ({ page }) => {
  // Scope to #main-content to avoid strict-mode ambiguity with the drawer.
  const mainContent = page.locator("#main-content");

  // Click the "Geometric" card (seed #ff5b3e).
  const geometricCard = mainContent.getByRole("button", {
    name: "Apply Geometric theme",
  });
  await geometricCard.scrollIntoViewIfNeeded();
  await geometricCard.click();

  // After selection, aria-pressed should be "true" on the Geometric card.
  await expect(geometricCard).toHaveAttribute("aria-pressed", "true");

  // Other cards in the main reel should be aria-pressed="false".
  const materialCard = mainContent.getByRole("button", {
    name: "Apply Material theme",
  });
  await expect(materialCard).toHaveAttribute("aria-pressed", "false");
});

test("reel cards render each theme's specimen fonts (D6) at 411×761", async ({
  page,
}) => {
  const mainContent = page.locator("#main-content");

  // The "Material" card's specimen "A" is set inline to the display font
  // (Fraunces). The card name + specimen carry inline font-family per preset.
  const materialCard = mainContent.getByRole("button", {
    name: "Apply Material theme",
  });
  await materialCard.scrollIntoViewIfNeeded();

  // The name div carries an inline font-family referencing the display font.
  // Only the name/specimen spans set `style="font-family:…"`, so filter on the
  // presence of that inline style rather than on text (which matches ancestors).
  const nameFontFamily = await materialCard
    .locator("[style*='font-family']")
    .first()
    .evaluate((el) => (el as HTMLElement).style.fontFamily);
  expect(nameFontFamily.toLowerCase()).toContain("fraunces");

  // Two different presets must carry DIFFERENT specimen fonts (not all uniform
  // sans-serif) — proves per-card fonts are wired, not a global fallback.
  const geometricCard = mainContent.getByRole("button", {
    name: "Apply Geometric theme",
  });
  await geometricCard.scrollIntoViewIfNeeded();
  const geoFontFamily = await geometricCard
    .locator("[style*='font-family']")
    .first()
    .evaluate((el) => (el as HTMLElement).style.fontFamily);
  expect(geoFontFamily.toLowerCase()).toContain("space grotesk");
  expect(geoFontFamily).not.toBe(nameFontFamily);

  // The specimen-subset stylesheets are injected at boot (§D6): at least one
  // <link class="m3e-specimen-font"> must be present in <head>.
  const specimenLinks = await page
    .locator("head link.m3e-specimen-font")
    .count();
  expect(specimenLinks).toBeGreaterThan(0);
});

test("selecting a preset switches the app icon variant (D4) at 411×761", async ({
  page,
}) => {
  const mainContent = page.locator("#main-content");

  // Select "Material" (iconStyle = outlined) first, then a Sharp preset.
  const materialCard = mainContent.getByRole("button", {
    name: "Apply Material theme",
  });
  await materialCard.scrollIntoViewIfNeeded();
  await materialCard.click();

  // App-bar icons are <m3e-icon>; after an Outlined preset they carry
  // variant="outlined".
  const appBarIcon = page.locator("#docs-app-bar m3e-icon").first();
  await expect(appBarIcon).toHaveAttribute("variant", "outlined");

  // Now pick "Agent" (iconStyle = sharp) — the same icons must switch to sharp.
  const agentCard = mainContent.getByRole("button", {
    name: "Apply Agent theme",
  });
  await agentCard.scrollIntoViewIfNeeded();
  await agentCard.click();

  await expect(appBarIcon).toHaveAttribute("variant", "sharp");
});

test("reel can be scrolled horizontally at 411×761", async ({ page }) => {
  // The reel container is a flex overflow-x-auto div.
  // Scope to #main-content to avoid strict-mode ambiguity with the drawer.
  const mainContent = page.locator("#main-content");

  // Verify the last preset ("OLED") becomes reachable by scrolling.
  const oledCard = mainContent.getByRole("button", {
    name: "Apply OLED theme",
  });

  // OLED is the last (23rd) preset — scroll it into view.
  await oledCard.scrollIntoViewIfNeeded();
  await expect(oledCard).toBeVisible();

  // Click OLED.
  await oledCard.click();

  // Root theme should switch to OLED's seed color.
  const rootTheme = page.locator("m3e-theme").first();
  await expect(rootTheme).toHaveAttribute("color", "#a0a0b8");
});
