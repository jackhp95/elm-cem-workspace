// Node-side glue shared by the preview render scripts (render-batch.mjs,
// render-example.mjs) to run the browser-side reveal rules after mount.
//
// The preview scripts bypass page.mjs's URL-param mounting (they inject markup
// via `#stage.innerHTML = ...`), so page.mjs's post-mount applyReveal() never
// runs for them. This helper closes that gap: it evaluates in the page context,
// dynamically imports the SAME reveal.mjs that page.mjs imports (page.html is
// served from the harness dir, so the relative specifier resolves to the served
// /reveal.mjs), and applies the rules to every custom element mounted in #stage.
//
// Applying to EVERY custom element in #stage (not just the top-level one) is
// safe because every applyReveal rule is guarded and no-ops on elements it
// doesn't match — nested items (m3e-menu-item, etc.) are simply untouched.

/**
 * Runs applyReveal() against each custom element in #stage, awaiting each
 * element's updateComplete before and after so the reveal is painted.
 * @param {import("playwright").Page} page
 */
export async function revealStage(page) {
  await page.evaluate(async () => {
    const { applyReveal } = await import("./reveal.mjs");
    const els = [...document.querySelectorAll("#stage *")].filter((e) => e.tagName.includes("-"));
    for (const el of els) {
      try {
        await customElements.whenDefined(el.tagName.toLowerCase());
        if (el.updateComplete) await el.updateComplete;
        applyReveal(el);
        if (el.updateComplete) await el.updateComplete;
      } catch (_) {
        // one element failing to reveal must not abort the rest
      }
    }
    // Let any freshly-shown popover/overlay lay out + paint before the shot.
    await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
  });
}
