import { test, expect } from "@playwright/test";
import { fileURLToPath } from "node:url";
import path from "node:path";
import fs from "node:fs";
import { startServer } from "./static-server.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const rootDir = path.join(__dirname, "..");
const shotsDir = path.join(rootDir, "shots");
fs.mkdirSync(shotsDir, { recursive: true });

// file:// does NOT work: Chromium blocks <script type="module"> from opaque
// file:// origins with a CORS error. A tiny local HTTP server is required.
let server;
let harnessUrl;
test.beforeAll(async () => {
  server = await startServer(rootDir);
  harnessUrl = `${server.baseUrl}/harness.html`;
});
test.afterAll(async () => server?.close());

// RUN_TAG lets us produce independent captures across separate `playwright test`
// invocations (run1 / run2) to check cross-run byte stability.
const runTag = process.env.RUN_TAG ?? "run";

async function capture(page, { tag, attrs, text }, outName) {
  const qs = new URLSearchParams();
  qs.set("tag", tag);
  if (attrs) qs.set("attrs", attrs);
  if (text) qs.set("text", text);
  await page.goto(`${harnessUrl}?${qs}`);

  // Wait for: custom element defined + lit first render + document.fonts.ready
  await page.waitForFunction(() => window.__ready !== undefined);
  await page.evaluate(() => window.__ready);

  const el = page.locator(tag);
  await expect(el).toBeVisible();
  const file = path.join(shotsDir, `${outName}-${runTag}.png`);
  await el.screenshot({
    path: file,
    omitBackground: true, // transparent background
    animations: "disabled", // pauses/finishes CSS animations incl. shadow DOM
    scale: "device", // honor deviceScaleFactor 2
  });
  return file;
}

test("m3e-button filled renders headless", async ({ page }) => {
  const file = await capture(
    page,
    { tag: "m3e-button", attrs: "variant:filled", text: "Label" },
    "button-filled",
  );
  const stat = fs.statSync(file);
  expect(stat.size).toBeGreaterThan(1000);

  // Sanity: it actually painted something non-transparent with the expected size
  const box = await page.locator("m3e-button").boundingBox();
  expect(box.height).toBeGreaterThan(30); // M3 button ≥ 40px tall (medium default)
  expect(box.width).toBeGreaterThan(50);
});

test("m3e-switch checked renders headless", async ({ page }) => {
  // NOTE: m3e-switch's on/off attribute is `checked` (CheckedMixin), not
  // `selected` as in Material Web's md-switch.
  const file = await capture(
    page,
    { tag: "m3e-switch", attrs: "checked", text: "" },
    "switch-checked",
  );
  expect(fs.statSync(file).size).toBeGreaterThan(500);

  const checked = await page.locator("m3e-switch").evaluate((el) => el.checked === true);
  expect(checked).toBe(true);
});
