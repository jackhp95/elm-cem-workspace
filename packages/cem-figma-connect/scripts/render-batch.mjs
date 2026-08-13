// Batch render tool: screenshot many raw custom-element markups, reusing one
// browser + bundle + server (much faster than N render-example.mjs invocations).
//
// Usage:
//   node scripts/render-batch.mjs specs.json outdir/
//
// specs.json is an array of { name, markup }. Each renders to outdir/<name>.png
// using the SAME bundle load + readiness ladder as render-example.mjs / capture.mjs.
import { chromium } from "playwright";
import { fileURLToPath } from "node:url";
import fs from "node:fs/promises";
import path from "node:path";
import { startServer } from "../src/visual/harness/static-server.mjs";
import { buildBundle } from "../src/visual/harness/bundle.mjs";
import { revealStage } from "../src/visual/harness/reveal-stage.mjs";

const harnessDir = path.join(path.dirname(fileURLToPath(import.meta.url)), "..", "src", "visual", "harness");

const CONTEXT_OPTIONS = {
  viewport: { width: 800, height: 600 },
  deviceScaleFactor: 2,
  reducedMotion: "reduce",
  colorScheme: "light",
  timezoneId: "UTC",
  locale: "en-US",
};
const SCREENSHOT_OPTIONS = { omitBackground: true, animations: "disabled", scale: "device" };

const [,, specsPath, outDir] = process.argv;
if (!specsPath || !outDir) {
  console.error("Usage: node scripts/render-batch.mjs specs.json outdir/");
  process.exit(1);
}

const specs = JSON.parse(await fs.readFile(specsPath, "utf8"));
await fs.mkdir(path.resolve(outDir), { recursive: true });

const profileName = "m3-kit";
const [{ baseUrl, close: closeServer }, { code: bundleCode }] = await Promise.all([
  startServer([{ mount: "/", dir: harnessDir }]),
  buildBundle(profileName),
]);

const browser = await chromium.launch({ headless: true });

try {
  for (const { name, markup, js } of specs) {
    const context = await browser.newContext(CONTEXT_OPTIONS);
    const page = await context.newPage();
    try {
      await page.goto(`${baseUrl}/page.html`);
      await page.addScriptTag({ content: bundleCode, type: "module" });
      await page.evaluate((html) => { document.getElementById("stage").innerHTML = html; }, markup);
      // Optional post-mount JS to imperatively reveal components shown via a
      // JS API (menu.show(), snackbar.show(), tooltip visibility) rather than an attr.
      if (js) {
        await page.evaluate((code) => {
          // eslint-disable-next-line no-new-func
          return (async () => { await new Promise((r) => setTimeout(r, 50)); return new Function(code)(); })();
        }, js).catch((e) => console.log(`  js(${name}) threw: ${e.message}`));
      }
      // Await EVERY custom element in the stage (hyphenated tag = custom element),
      // not just the top tag — a wrapper <div> around an m3e-* must still wait for
      // the inner element to upgrade + lay out before screenshotting.
      await page.waitForFunction(async () => {
        const els = [...document.querySelectorAll("#stage *")].filter((e) => e.tagName.includes("-"));
        await Promise.all(els.map((e) => customElements.whenDefined(e.tagName.toLowerCase())));
        await Promise.all(els.map((e) => e.updateComplete).filter(Boolean));
        await Promise.all([...document.fonts].map((f) => f.load().catch(() => {})));
        await document.fonts.ready;
        await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
        return true;
      }, { timeout: 15000 }).catch(() => { /* render anyway — capture whatever is there */ });
      // Hidden-by-default reveal: run the SAME applyReveal() rules the gate path
      // (page.mjs) uses, so previews of popover/open/show()-driven components
      // (snackbar, fab-menu, dialog, menu, tooltip, bottom-sheet) come out
      // visible instead of blank. page.html serves from the harness dir, so the
      // dynamic import resolves to the same reveal.mjs page.mjs imports.
      await revealStage(page);
      // Screenshot the whole page body (not just #stage) so portaled/overlay
      // components (dialog, menu, tooltip) that mount outside #stage are captured.
      const buffer = await page.screenshot({ ...SCREENSHOT_OPTIONS, fullPage: false });
      await fs.writeFile(path.join(outDir, `${name}.png`), buffer);
      console.log(`ok   ${name}`);
    } catch (err) {
      console.log(`FAIL ${name}: ${err.message}`);
    } finally {
      await page.close();
      await context.close();
    }
  }
} finally {
  await browser.close();
  await closeServer();
}
