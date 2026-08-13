// Comprehensive "everything" review renderer (Phase A render-harness fixes):
// - tight element-bbox / transparent-trim (kills whitespace)
// - representative widths for size-mismatched components
// - tooltip hover emulation; collapse (don't force-open) expandable-list-item
// - Figma renders CACHED (reuse render-cache/coverage-review-all/figma/*) so
//   code-only re-renders are fast and need no bridge; delete a figma png to refresh it
// - `--only tag1,tag2` renders just those (fast iteration)
import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";
const require = createRequire("/Users/jhp/code/jackhp95/cem-figma-connect/package.json");
const { chromium } = require("playwright");
const { PNG } = require("pngjs");

const REPO = "/Users/jhp/code/jackhp95/cem-figma-connect";
const CHANNEL = "cem-504138";
const WC = path.join(REPO, "generated/m3-kit/web-components");
const HARNESS = path.join(REPO, "src/visual/harness");
const OUT = path.join(REPO, "render-cache/coverage-review-all");
const ONLY = (process.argv.find((a) => a.startsWith("--only=")) || "").slice(7).split(",").filter(Boolean);

const { buildBundle } = await import(path.join(HARNESS, "bundle.mjs"));
const { startServer } = await import(path.join(HARNESS, "static-server.mjs"));
const { comparePngFiles, loadThresholds } = await import(path.join(REPO, "src/visual/diff.mjs"));
const { wsQuery } = await import(path.join(REPO, "extract/lib/ws-query.mjs"));
const { readCorrespondence, loadProfile } = await import(path.join(REPO, "src/correspond/merge.mjs"));
const { loadFigmaExport } = await import(path.join(REPO, "src/ingest/figma.mjs"));
const { variantsBySet, findVariantNode } = await import(path.join(REPO, "src/visual/drive.mjs"));

const entries = readCorrespondence(path.join(REPO, "profiles/m3-kit/correspondence.json"));
const entryByTag = new Map(entries.map((e) => [e.cemTag, e]));
const overrides = JSON.parse(fs.readFileSync(path.join(REPO, "profiles/m3-kit/overrides.json"), "utf8"));
const gateByTag = new Map(overrides.map((o) => [o.cemTag, o.gate]));
const profile = loadProfile(path.join(REPO, "profiles/m3-kit"));
const figmaExport = loadFigmaExport(profile.figmaExportPath);
const variantsMap = variantsBySet(figmaExport.data);
const thresholds = await loadThresholds(path.join(REPO, "profiles/m3-kit/visual.json"));
for (const d of ["code", "figma", "diff"]) fs.mkdirSync(path.join(OUT, d), { recursive: true });

// top-layer/overlay components (surface renders outside the host bbox)
const OVERLAY = new Set(["m3e-dialog","m3e-datepicker","m3e-timepicker","m3e-search-view","m3e-menu","m3e-tooltip","m3e-rich-tooltip","m3e-snackbar","m3e-bottom-sheet","m3e-drawer-container","m3e-fab-menu"]);
const NO_REVEAL = new Set(["m3e-expandable-list-item"]); // Figma shows collapsed — don't force-open
const HOVER = new Set([]);  // tooltips now use REVEAL.call:"show" (bare tooltip has no anchor to hover)
const ANIMATE = new Set(["m3e-loading-indicator"]); // let inherently-animated shapes morph (no static frame)
// BACKGROUND PARITY: the code screenshot omits background (transparent); the Figma export keeps
// the node's OWN backdrop. The code side must share that backdrop or the diff is comparing a
// transparent code side against a filled Figma surface (or vice-versa). So composite the code
// render onto the SAME color the Figma node uses behind its content — sampled from the export's
// top-left corner — or keep it transparent when the node's backdrop is transparent. This fixes
// both failure modes at once: transparent-backdrop nodes (shape corners, list gaps, chips) no
// longer diff against white, and surface-backdrop nodes (tabs, menus, drawers) no longer diff a
// transparent code side against a filled surface. Returns null (transparent → keep alpha) | [r,g,b].
function figmaBgColor(figmaPath) {
  try {
    const { data } = PNG.sync.read(fs.readFileSync(figmaPath));
    return data[3] < 16 ? null : [data[0], data[1], data[2]]; // top-left corner = the node's backdrop
  } catch { return null; }
}
// Per-component open logic: the generic reveal (open attr / showPopover / show) doesn't fit
// these — they need specific attrs and/or a no-arg method call. Applied in the render only.
const REVEAL = {
  // nav-menu is a Navigation Drawer: the m3e-nav-menu component paints no surface (that's the
  // drawer container's job), so give the gate render a representative rounded surface matching
  // the Figma node (#f7f2fa surface-container-low, ~360px wide). The emitted binding stays clean.
  "m3e-nav-menu": { style: { width: "360px", background: "#f7f2fa", borderRadius: "16px" } },
  // detents="fit" gives a single content-height detent so the open sheet shows its content
  // (empty detents snap to min(fit,half) but the open→show re-snap collapsed it).
  "m3e-bottom-sheet": { attrs: { open: "", handle: "", detents: "502px" } },
  // drawer needs a bounded box so the "side" end-drawer has room to lay out beside the content.
  "m3e-drawer-container": { attrs: { end: "" }, style: { width: "400px", height: "700px" } },
  // docked search view: open it, bounded to a realistic width so the panel doesn't fill the viewport.
  "m3e-search-view-docked": { attrs: { open: "" }, style: { width: "360px" } },
  // bare tooltips have no anchor — inject one, wire `for`, and show() so the bubble positions.
  "m3e-tooltip": { anchor: true },
  "m3e-rich-tooltip": { anchor: true },
};
// representative render widths (px) for components Figma draws much wider than the code default
const WIDTHS = { "m3e-app-bar": 380, "m3e-linear-progress-indicator": 260, "m3e-menu-item": 300, "m3e-menu": 220, "m3e-list": 320, "m3e-list-item": 360, "m3e-search-bar": 360, "m3e-expandable-list-item": 280 };
// Render-side state: these have a matcher `checked` axis (binding is correct); the gate
// default renders unchecked, so show the selected pole in the render only (not the binding).
const SELECTED = {
  // shape's `name` is a Figma variant axis, emitted as name="${name}" and stripped in render →
  // bare <m3e-shape> is invisible (0% / degenerate). The default variant is Shape=Circle; pin it
  // so the gate renders the real shape. m3e-shape is scaleInvariant, so only shape-type + fill color matter.
  "m3e-shape": { name: "circle", "--m3e-shape-size": "380px" },
  // form-field's supporting text lives in the subscript, hidden by default (hide-subscript:auto until
  // focus). The Figma showcase always shows it, so pin it visible for the gate — a display toggle, not
  // a binding attr (putting it in fixedAttrs would leak "never" into the slug).
  "m3e-form-field": { "hide-subscript": "never" },
  // dialog renders far too wide (content doesn't wrap); constrain the surface to the node's width.
  "m3e-dialog": { "--m3e-dialog-max-width": "312px" },
  // fab-menu-item's pill color normally comes from the parent m3e-fab-menu's variant
  // (background-color: var(--_fab-menu-item-container-color)); standalone it's transparent.
  // The node is a Primary segment → primary-container (#eaddff). Inject it for the gate.
  "m3e-fab-menu-item": { "--_fab-menu-item-container-color": "#eaddff" },
  // bottom-sheet: size the code sheet to the node (~434 wide) so it isn't compared raw-vs-scaled.
  "m3e-bottom-sheet": { "--m3e-bottom-sheet-max-width": "434px" },
  // the "Navigation Rail: Expanded" set renders expanded (horizontal items + extended FAB);
  // mode is a render-representative state (not in the binding — fixedAttrs would break the
  // matcher's byte-stable correspondence.json). Keyed by base slug so only the expanded set gets it.
  "m3e-nav-rail-expanded": { mode: "expanded" },
  "m3e-checkbox": { checked: "" }, "m3e-switch": { checked: "" }, "m3e-date-input": { value: "2025-08-17", type: "date" },
  // icon-button needs NO shape pin: the default shape "rounded" already IS the circular shape the
  // Figma nodes use. (An earlier "circular" pin was invalid — the API only allows rounded|square —
  // and it disabled the rounded default, rendering a soft-square. Removing it fixed 6 icon-buttons.)
  // badge: the node is Size=Large (shows the count); small renders a dot with no number.
  "m3e-badge": { size: "large" },
  // Per-file: render the toggle representatives UNSELECTED (Figma shows the resting/unselected
  // state — lighter surface). null removes the binding's selected="true" for the gate only.
  "m3e-button-toggle-elevated": { selected: null }, "m3e-button-toggle-filled": { selected: null },
  "m3e-button-toggle-outlined": { selected: null }, "m3e-button-toggle-tonal": { selected: null },
  "m3e-icon-button-toggle-filled": { selected: null }, "m3e-icon-button-toggle-outlined": { selected: null },
  "m3e-icon-button-toggle-standard": { selected: null }, "m3e-icon-button-toggle-tonal": { selected: null } };

function resolveVariantNode(setNodeId) {
  const sp = figmaExport.data.setProperties[setNodeId] ?? [];
  const expected = {};
  for (const ax of sp) if (ax.type === "VARIANT") expected[ax.name] = ax.defaultValue;
  try { if (Object.keys(expected).length) return findVariantNode(figmaExport, setNodeId, expected).nodeId; } catch {}
  const list = variantsMap.get(setNodeId);
  return list && list.length ? list[0].id : setNodeId;
}
async function exportFigmaNode(nodeId, scale = 2) {
  const res = await wsQuery("export_node_as_image", { nodeId, scale }, { channel: CHANNEL, timeoutMs: 60000 });
  if (!res || res.error || !res.imageData) throw new Error(`export ${nodeId}: ${res && res.error}`);
  return Buffer.from(res.imageData, "base64");
}
// crop transparent margins and composite onto white (for top-layer full-page shots)
// bg: null → keep straight RGBA (transparent stays transparent, for transparent-backdrop nodes);
// [r,g,b] → composite onto that backdrop color (opaque out), to match a filled Figma surface.
function trimToContent(buf, pad = 10, bg = [255, 255, 255]) {
  const png = PNG.sync.read(buf);
  const { width, height, data } = png;
  let minX = width, minY = height, maxX = 0, maxY = 0, found = false;
  for (let y = 0; y < height; y++) for (let x = 0; x < width; x++) {
    if (data[(y * width + x) * 4 + 3] > 16) { found = true; if (x < minX) minX = x; if (x > maxX) maxX = x; if (y < minY) minY = y; if (y > maxY) maxY = y; }
  }
  if (!found) return buf;
  minX = Math.max(0, minX - pad); minY = Math.max(0, minY - pad); maxX = Math.min(width - 1, maxX + pad); maxY = Math.min(height - 1, maxY + pad);
  const w = maxX - minX + 1, h = maxY - minY + 1;
  const out = new PNG({ width: w, height: h });
  for (let y = 0; y < h; y++) for (let x = 0; x < w; x++) {
    const si = ((y + minY) * width + (x + minX)) * 4, di = (y * w + x) * 4;
    if (bg === null) {
      out.data[di] = data[si]; out.data[di + 1] = data[si + 1]; out.data[di + 2] = data[si + 2]; out.data[di + 3] = data[si + 3];
    } else {
      const a = data[si + 3] / 255;
      out.data[di] = Math.round(data[si] * a + bg[0] * (1 - a));
      out.data[di + 1] = Math.round(data[si + 1] * a + bg[1] * (1 - a));
      out.data[di + 2] = Math.round(data[si + 2] * a + bg[2] * (1 - a));
      out.data[di + 3] = 255;
    }
  }
  return PNG.sync.write(out);
}
// WRAP: a few Figma nodes are a COMPOSITION the bound element sits INSIDE (the "Input date picker"
// modal wraps the date field in a dialog; the open FAB menu has a FAB beside it). The emitted
// .figma.ts binding stays the bare element; the review render wraps it here so the gate compares
// like-for-like. Keyed by base slug. Inline styles are fine — this is the throwaway renderer, NOT
// the committed binding. (Gate representative context, exactly like the drawer surface / nav-rail mode.)
const WRAP = {
  "m3e-date-input-modal": (inner) =>
    `<m3e-dialog style="--m3e-dialog-max-width:360px">` +
      `<div slot="header" style="display:flex;flex-direction:column;gap:16px">` +
        `<span style="font:400 14px Roboto">Select date</span>` +
        `<div style="display:flex;align-items:center;justify-content:space-between;gap:24px"><span style="font:400 32px Roboto">Enter date</span><m3e-icon-button><m3e-icon name="calendar_today"></m3e-icon></m3e-icon-button></div>` +
      `</div>` +
      `<m3e-form-field variant="outlined"><label slot="label">Date</label>${inner}</m3e-form-field>` +
      `<div slot="actions" style="display:flex;gap:8px;justify-content:flex-end"><m3e-button variant="text"><span>Cancel</span></m3e-button><m3e-button variant="text"><span>OK</span></m3e-button></div>` +
    `</m3e-dialog>`,
  // NOTE: fab-menu is NOT wrapped here — the node has a FAB at the bottom that the menu expands
  // from, and a naive sibling FAB lands at the top (the open menu portals, so flow order doesn't
  // place it). It needs the real FAB + m3e-fab-menu-trigger composition AND a harness change to
  // open the sibling menu (reveal only opens the root). Left as-is (55%) rather than made worse.
};

function parseFile(file) {
  const src = fs.readFileSync(path.join(WC, file), "utf8");
  const url = src.match(/node-id=([0-9]+)-([0-9]+)/);
  const nodeId = url ? `${url[1]}:${url[2]}` : null;
  const tagM = src.match(/\*\s+(m3e-[a-z0-9-]+)(?:,| ->| )/);
  const cemTag = tagM ? tagM[1] : file.replace(/\.figma\.ts$/, "");
  const setM = src.match(/bound to Figma set "([^"]+)"/);
  const setName = setM ? setM[1] : "";
  const exM = src.match(/example:\s*figma\.code`([\s\S]*?)`,/);
  let markup = exM ? exM[1].replace(/\s+[\w-]+="\$\{[^}]*\}"/g, "").replace(/\$\{[^}]*\}/g, "") : "";
  const base = file.replace(/\.figma\.ts$/, "");
  const wrap = WRAP[base] || WRAP[cemTag];
  if (wrap) markup = wrap(markup);
  const rootM = markup.match(/^<([a-z0-9-]+)/);
  return { cemTag, setName, nodeId, markup, rootTag: rootM ? rootM[1] : cemTag };
}

let files = fs.readdirSync(WC).filter((f) => f.endsWith(".figma.ts"))
  .filter((f) => !(f.startsWith("m3e-icon-") && !f.startsWith("m3e-icon-button-"))).sort();
if (ONLY.length) files = files.filter((f) => ONLY.some((t) => f.startsWith(t)));

const PAGE = `<!doctype html><meta charset=utf-8><style>
@font-face{font-family:"Roboto";font-weight:400;src:url("/fonts/roboto-latin-400-normal.woff2") format("woff2");}
@font-face{font-family:"Roboto";font-weight:500;src:url("/fonts/roboto-latin-500-normal.woff2") format("woff2");}
@font-face{font-family:"Roboto";font-weight:700;src:url("/fonts/roboto-latin-700-normal.woff2") format("woff2");}
@font-face{font-family:"Material Symbols Outlined";font-weight:100 700;src:url("/fonts/material-symbols-outlined-latin-full-normal.woff2") format("woff2-variations");}
html,body{margin:0;background:transparent;}body{font-family:"Roboto",sans-serif;-webkit-font-smoothing:antialiased;}
*,*::before,*::after{transition:none!important;animation:none!important;caret-color:transparent!important;}
dialog::backdrop,::backdrop{background:transparent!important;}
/* Kill overlay scrims (CSS custom props pierce shadow DOM) so full-page trim crops
   to the surface, not a full-viewport dim layer. Review-render only. */
html{ --m3e-dialog-scrim-opacity:0; --m3e-search-view-docked-scrim-opacity:0; --m3e-drawer-container-scrim-opacity:0; --m3e-bottom-sheet-scrim-opacity:0; }
#stage{display:inline-block;padding:0;}</style><div id=stage></div>`;
const pageDir = path.join(OUT, "_page"); fs.mkdirSync(pageDir, { recursive: true });
fs.writeFileSync(path.join(pageDir, "index.html"), PAGE);
const revealSrc = `(el)=>{try{if(el.hasAttribute&&el.hasAttribute('popover')&&el.showPopover)el.showPopover();}catch{}try{if('open' in el&&el.open===false)el.setAttribute('open','');}catch{}try{if(typeof el.show==='function')el.show(el);}catch{}}`;

const { baseUrl, close: closeServer } = await startServer([{ mount: "/", dir: pageDir }, { mount: "/fonts", dir: path.join(HARNESS, "fonts") }]);
const { code: bundleCode } = await buildBundle("m3-kit");
const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({ viewport: { width: 1000, height: 800 }, deviceScaleFactor: 2, reducedMotion: "reduce", colorScheme: "light", timezoneId: "UTC", locale: "en-US" });

// preserve existing items.json (so --only updates only its subset)
const itemsPath = path.join(OUT, "items.json");
const prev = fs.existsSync(itemsPath) ? JSON.parse(fs.readFileSync(itemsPath, "utf8")).items : [];
const itemByBase = new Map(prev.map((i) => [i.stateId.split(" · ")[0], i]));

let ok = 0, figOk = 0;
for (const file of files) {
  const base = file.replace(/\.figma\.ts$/, "");
  const { cemTag, setName, nodeId, markup, rootTag } = parseFile(file);
  const overlay = OVERLAY.has(rootTag);
  const codePath = path.join(OUT, "code", `${base}.png`);
  const figmaPath = path.join(OUT, "figma", `${base}.png`);
  let figmaOk = false, diffPath = null, diffRatio = null, threshold = null, note = "";
  // Per-file (base slug) config overrides per-cemTag config. Base keys and cemTag keys
  // live in the SAME maps (they never collide — base slugs carry a set suffix).
  const cfgSelected = { ...(SELECTED[cemTag] || {}), ...(SELECTED[base] || {}) };
  const cfgWidth = WIDTHS[base] ?? WIDTHS[cemTag];
  const cfgReveal = REVEAL[base] ?? REVEAL[cemTag] ?? null;
  const cfgNoReveal = NO_REVEAL.has(base) || NO_REVEAL.has(cemTag);
  const cfgHover = HOVER.has(base) || HOVER.has(cemTag);
  const page = await context.newPage();
  try {
    await page.goto(`${baseUrl}/index.html`);
    await page.addScriptTag({ content: bundleCode, type: "module" });
    await page.evaluate(async ({ markup, revealSrc, noReveal, width, selected, reveal }) => {
      const stage = document.getElementById("stage");
      stage.innerHTML = markup;
      const root = stage.firstElementChild;
      if (width && root) root.style.width = width + "px";
      if (selected && root) for (const [k, v] of Object.entries(selected)) { if (k.startsWith("--")) root.style.setProperty(k, v); else if (v === null) root.removeAttribute(k); else root.setAttribute(k, v); }
      const tags = [...new Set([...stage.querySelectorAll("*")].map((e) => e.tagName.toLowerCase()).filter((t) => t.includes("-")))];
      await Promise.all(tags.map((t) => customElements.whenDefined(t).catch(() => {})));
      if (reveal && root) {
        // Per-component open logic (specific attrs + no-arg method call + optional box style).
        if (reveal.style) for (const [k, v] of Object.entries(reveal.style)) root.style[k] = v;
        if (reveal.anchor) {
          // Bare tooltip has no anchor — inject one, wire `for`, attach + show so it positions.
          const anchor = document.createElement("button");
          anchor.id = "tt-anchor"; anchor.textContent = "Anchor";
          anchor.style.cssText = "margin:24px;padding:8px 14px;font:inherit;border:1px solid #ccc;border-radius:8px;background:#eee;";
          stage.insertBefore(anchor, root);
          // Plain tooltip text is a stripped Figma prop → inject a placeholder so the bubble isn't empty.
          if (!root.textContent.trim() && !root.querySelector("*")) root.textContent = "Tooltip";
          root.setAttribute("for", "tt-anchor");
          await new Promise((r) => requestAnimationFrame(r));
          try { root.attach && root.attach(anchor); } catch {}
          try { root.show && root.show(); } catch {}
          await new Promise((r) => requestAnimationFrame(r));
          // Hide the anchor (keep layout so the tooltip stays positioned) — the full-page
          // trim crops to OPAQUE pixels, so a transparent anchor drops out and only the
          // tooltip bubble is captured (user: "screenshot just the tooltip, not the anchor").
          anchor.style.visibility = "hidden";
        } else {
          if (reveal.attrs) for (const [k, v] of Object.entries(reveal.attrs)) root.setAttribute(k, v);
          await new Promise((r) => requestAnimationFrame(r));
          if (reveal.call && typeof root[reveal.call] === "function") { try { root[reveal.call](); } catch {} }
        }
      } else if (!noReveal) {
        (0, eval)(revealSrc)(root);
      }
      await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
    }, { markup, revealSrc, noReveal: cfgNoReveal, width: cfgWidth, selected: Object.keys(cfgSelected).length ? cfgSelected : null, reveal: cfgReveal });
    if (cfgHover) { try { await page.locator("#stage *").first().hover(); await page.waitForTimeout(200); } catch {} }
    await page.evaluate(() => document.fonts.ready);
    await page.waitForTimeout(150);
    // loading-indicator is an inherently-animated shape-morph: animations:"disabled"
    // pins its infinite morph to frame 0 (a square). Let it animate and capture a real
    // morph frame (a cookie/flower polygon) instead — the shape varies run-to-run, which
    // is fine for an animated component (there IS no single static state).
    const animate = ANIMATE.has(cemTag);
    if (animate) await page.waitForTimeout(500);
    // Uniform: full-page transparent screenshot → trim to content → composite white.
    // Works for inline (only the component is opaque) and force-opened surfaces
    // (incl. modal dialogs, since ::backdrop is forced transparent above). Fullscreen
    // surfaces legitimately fill the viewport and stay large.
    const raw = await page.screenshot({ omitBackground: true, animations: animate ? "allow" : "disabled" });
    const fbg = fs.existsSync(figmaPath) ? figmaBgColor(figmaPath) : null;
    fs.writeFileSync(codePath, trimToContent(raw, 10, fbg));
    ok++;
  } catch (e) { note = `code render failed: ${e.message}`; } finally { await page.close(); }
  if (nodeId) {
    if (fs.existsSync(figmaPath)) { figmaOk = true; figOk++; }               // reuse cached Figma render
    else { try { fs.writeFileSync(figmaPath, await exportFigmaNode(resolveVariantNode(nodeId))); figmaOk = true; figOk++; } catch (e) { note = `figma export failed: ${e.message}`; } }
  }
  if (figmaOk && fs.existsSync(codePath)) {
    try {
      const rec = await comparePngFiles({ entryId: cemTag, stateId: base, codePath, figmaPath, thresholds, entry: entryByTag.get(cemTag) });
      diffRatio = rec.diffRatio; threshold = rec.threshold;
      if (rec.diffPng) { diffPath = path.join(OUT, "diff", `${base}.png`); fs.writeFileSync(diffPath, PNG.sync.write(rec.diffPng)); }
    } catch { note = (note ? note + "; " : "") + "diff skipped"; }
  }
  const img = (p) => (p && fs.existsSync(p) ? `/api/image?path=${encodeURIComponent(p)}` : null);
  itemByBase.set(base, {
    cemTag, stateId: `${base}${setName ? " · " + setName : ""}`, nodeId,
    diffRatio: diffRatio ?? 0, threshold: threshold ?? 0,
    matcherKind: entryByTag.get(cemTag)?.matcherKind ?? "?",
    rationale: `gate=${gateByTag.get(cemTag) ?? "?"} · ${setName || cemTag}${note ? " — " + note : ""}`,
    artifacts: { code: img(codePath), figma: img(figmaOk ? figmaPath : null), diff: img(diffPath) },
  });
}
await context.close(); await browser.close(); await closeServer();
const items = [...itemByBase.values()].sort((a, b) => a.stateId < b.stateId ? -1 : 1);
fs.writeFileSync(itemsPath, JSON.stringify({ runId: "coverage-review-all", items }, null, 2));
console.log(`rendered ${files.length}${ONLY.length ? " (--only)" : ""}: code ok ${ok}, figma ok ${figOk}; items.json now ${items.length}`);
