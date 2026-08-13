// Standalone render tool: screenshot raw custom-element markup to a PNG.
//
// Usage:
//   node scripts/render-example.mjs '<markup>' out.png
//
// Example:
//   node scripts/render-example.mjs \
//     '<m3e-segmented-button><m3e-button-segment>Label</m3e-button-segment></m3e-segmented-button>' \
//     /tmp/seg.png
//
// Loads the m3e bundle exactly as capture.mjs does (same buildBundle path,
// same addScriptTag injection), awaits the same readiness ladder (customElements
// upgrade + document.fonts.ready + 2 rAF), and screenshots the #stage element.
// Reuses CONTEXT_OPTIONS and SCREENSHOT_OPTIONS from capture.mjs's constants.
import { chromium } from "playwright";
import { fileURLToPath } from "node:url";
import fs from "node:fs/promises";
import path from "node:path";
import { startServer } from "../src/visual/harness/static-server.mjs";
import { buildBundle } from "../src/visual/harness/bundle.mjs";
import { revealStage } from "../src/visual/harness/reveal-stage.mjs";

const harnessDir = path.join(path.dirname(fileURLToPath(import.meta.url)), "..", "src", "visual", "harness");

// Identical to capture.mjs's CONTEXT_OPTIONS.
const CONTEXT_OPTIONS = {
  viewport: { width: 800, height: 600 },
  deviceScaleFactor: 2,
  reducedMotion: "reduce",
  colorScheme: "light",
  timezoneId: "UTC",
  locale: "en-US",
};

// Identical to capture.mjs's SCREENSHOT_OPTIONS.
const SCREENSHOT_OPTIONS = {
  omitBackground: true,
  animations: "disabled",
  scale: "device",
};

function usage() {
  console.error("Usage: node scripts/render-example.mjs '<markup>' <out.png>");
  process.exit(1);
}

const [,, markup, outPath] = process.argv;
if (!markup || !outPath) usage();

const profileName = "m3-kit";

const [{ baseUrl, close: closeServer }, { code: bundleCode }] = await Promise.all([
  startServer([{ mount: "/", dir: harnessDir }]),
  buildBundle(profileName),
]);

const browser = await chromium.launch({ headless: true });
const context = await browser.newContext(CONTEXT_OPTIONS);
const page = await context.newPage();

try {
  await page.goto(`${baseUrl}/page.html`);
  await page.addScriptTag({ content: bundleCode, type: "module" });

  // Set the stage content directly — bypass page.mjs's URL-param mounting.
  // We wait for the bundle's custom elements to be available first, then
  // inject the markup and run the same readiness ladder as capture.mjs.
  await page.evaluate((html) => {
    document.getElementById("stage").innerHTML = html;
  }, markup);

  // Derive the top-level tag name from the markup to await its upgrade.
  const tagMatch = markup.match(/^<([\w-]+)/);
  if (!tagMatch) throw new Error("render-example: could not parse a tag name from the markup");
  const tag = tagMatch[1];

  // Readiness ladder matching page.mjs's window.__ready:
  // customElements.whenDefined -> all fonts loaded -> document.fonts.ready -> 2 rAF.
  await page.waitForFunction(async (t) => {
    await customElements.whenDefined(t);
    const el = document.querySelector(t);
    if (el && el.updateComplete) await el.updateComplete;
    await Promise.all([...document.fonts].map((f) => f.load().catch(() => {})));
    await document.fonts.ready;
    await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
    return true;
  }, tag);

  // Hidden-by-default reveal: run the SAME applyReveal() rules the gate path
  // (page.mjs) uses so previews of popover/open/show()-driven components come
  // out visible instead of blank. See src/visual/harness/reveal-stage.mjs.
  await revealStage(page);

  // Screenshot the whole viewport, not just the #stage box: revealed overlays
  // (snackbar, dialog, menu, fab-menu, tooltip) render in the top layer /
  // position:fixed, OUTSIDE #stage's bounding box — a #stage-clipped shot would
  // miss them entirely. omitBackground keeps the surrounding area transparent.
  const stage = page.locator("#stage");
  await stage.waitFor({ state: "visible" });
  const buffer = await page.screenshot({ ...SCREENSHOT_OPTIONS, fullPage: false });

  await fs.mkdir(path.dirname(path.resolve(outPath)), { recursive: true });
  await fs.writeFile(outPath, buffer);
  console.log(path.resolve(outPath));
} finally {
  await page.close();
  await context.close();
  await browser.close();
  await closeServer();
}
