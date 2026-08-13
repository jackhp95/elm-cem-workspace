// Playwright PROGRAMMATIC API (not the test runner) for headless rendering of
// any custom element registered by a profile's kit bundle. Launches chromium
// once per createRenderer() call; renderOne() can be called repeatedly against
// that one browser/context. All determinism knobs below are ported verbatim
// from research/evidence/07-render-harness-notes.md (the 2026-07-10 spike
// that proved byte-identical PNGs across 3 separate playwright-test runs).
import { chromium } from "playwright";
import { fileURLToPath } from "node:url";
import fs from "node:fs/promises";
import path from "node:path";
import { startServer } from "./static-server.mjs";
import { buildBundle } from "./bundle.mjs";

const harnessDir = path.dirname(fileURLToPath(import.meta.url));

// Context options pinned exactly as in research/spikes/07-render-harness/playwright.config.js.
const CONTEXT_OPTIONS = {
  viewport: { width: 800, height: 600 },
  deviceScaleFactor: 2,
  reducedMotion: "reduce", // m3e reads prefers-reduced-motion internally
  colorScheme: "light",
  timezoneId: "UTC",
  locale: "en-US",
};

// Screenshot options pinned exactly as in the spike's tests/render.spec.js.
const SCREENSHOT_OPTIONS = {
  omitBackground: true, // transparent background (page CSS also sets background: transparent)
  animations: "disabled", // pauses/finishes CSS animations incl. shadow DOM
  scale: "device", // honor deviceScaleFactor 2
};

/**
 * @param {Record<string,string>} urlParams e.g.
 *   { tag: "m3e-button", "attr.variant": "filled", text: "Label" }
 * @returns {URLSearchParams}
 */
function toSearchParams(urlParams) {
  const qs = new URLSearchParams();
  for (const [key, value] of Object.entries(urlParams)) qs.set(key, value);
  return qs;
}

/**
 * @param {string} profileName e.g. "m3-kit" — which profiles/<name>/harness.json
 *   entry to bundle and inject.
 * @returns {Promise<{ renderOne: (urlParams: Record<string,string>) => Promise<Buffer>, close: () => Promise<void> }>}
 */
export async function createRenderer(profileName = "m3-kit") {
  const [{ baseUrl, close: closeServer }, { code: bundleCode }] = await Promise.all([
    startServer([{ mount: "/", dir: harnessDir }]),
    buildBundle(profileName),
  ]);

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext(CONTEXT_OPTIONS);

  async function renderOne(urlParams) {
    if (!urlParams.tag) throw new Error("renderOne: urlParams.tag is required");
    const qs = toSearchParams(urlParams);
    const page = await context.newPage();
    try {
      await page.goto(`${baseUrl}/page.html?${qs}`);
      // Inject the bundled kit as an inline module script (self-contained ESM,
      // no external imports — safe to inline rather than serve over HTTP).
      await page.addScriptTag({ content: bundleCode, type: "module" });

      // Wait ladder (research/evidence/07-render-harness-notes.md):
      // customElements.whenDefined -> document.fonts.ready -> el.updateComplete
      // (lit) -> double rAF. page.mjs exposes this as window.__ready.
      await page.waitForFunction(() => window.__ready !== undefined);
      await page.evaluate(() => window.__ready);

      const tag = urlParams.tag;
      const locator = page.locator(tag).first();
      await locator.waitFor({ state: "visible" });
      const buffer = await locator.screenshot(SCREENSHOT_OPTIONS);
      return buffer;
    } finally {
      await page.close();
    }
  }

  async function close() {
    await context.close();
    await browser.close();
    await closeServer();
  }

  return { renderOne, close };
}

// --- CLI mode -------------------------------------------------------------
// One render per process invocation (used by selfcheck.mjs to get a fresh
// chromium launch per sample — the spike's determinism check ran fully
// separate `playwright test` invocations, not repeated calls in one process).
//
//   node capture.mjs --profile=m3-kit --tag=m3e-button --attr.variant=filled \
//     --text=Label --out=/tmp/button.png
function parseCliArgs(argv) {
  const urlParams = {};
  let profile = "m3-kit";
  let out;
  for (const arg of argv) {
    const eq = arg.indexOf("=");
    if (!arg.startsWith("--") || eq === -1) continue;
    const key = arg.slice(2, eq);
    const value = arg.slice(eq + 1);
    if (key === "profile") profile = value;
    else if (key === "out") out = value;
    else urlParams[key] = value;
  }
  if (!out) throw new Error("capture.mjs CLI: --out=<path> is required");
  return { profile, out, urlParams };
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const { profile, out, urlParams } = parseCliArgs(process.argv.slice(2));
  const { renderOne, close } = await createRenderer(profile);
  try {
    const buffer = await renderOne(urlParams);
    await fs.mkdir(path.dirname(out), { recursive: true });
    await fs.writeFile(out, buffer);
  } finally {
    await close();
  }
}
