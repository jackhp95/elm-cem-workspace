// Mounts ANY custom element from URL query params. Generalizes the
// 2026-07-10 spike's `?tag=&attrs=&text=` scheme (research/spikes/07-render-harness/harness.html)
// into a per-key scheme so attributes and named slots can be driven
// independently, without a sub-delimiter mini-language:
//
//   ?tag=m3e-button&attr.variant=filled&attr.size=medium&text=Label&slot.icon=m3e-icon:star
//
//   tag=<tagname>              required. The custom element to create.
//   attr.<name>=<value>        repeatable. Sets el.setAttribute(name, value).
//                              Empty value (`attr.disabled=`) still sets the
//                              attribute — that IS "present" for boolean attrs.
//   text=<chars>                Default-slot text content (el.textContent).
//   slot.<slotname>=<tag>:<arg> repeatable. Named-slot content:
//                              `m3e-icon:<name>` -> <m3e-icon slot="<slotname>" name="<name>">
//                              (evidence #12: name is Material Symbols snake_case).
//                              Any other <tag> falls back to a generic
//                              <tag slot="<slotname>"><arg></tag> element.
//
// URLSearchParams decodes values for both `.get()` and iteration, so no
// manual decodeURIComponent is needed here (unlike the spike's comma-joined
// `attrs=` mini-language, which had to decode sub-values itself).
//
// Hidden-by-default components: after mount, reveal.mjs's applyReveal() is
// called so the capture-side screenshot sees a visible element. See reveal.mjs
// for the two rules (popover / open) and their rationale.

import { applyReveal } from "./reveal.mjs";

const SLOT_ELEMENT_BUILDERS = {
  "m3e-icon": (arg) => {
    // arg is "<ms-ligature>" or "<ms-ligature>!filled" — the "!filled" suffix
    // (driver-encoded) sets the Material Symbols FILL axis via m3e-icon's `filled`
    // attribute. MS ligature names never contain "!", so the split is unambiguous.
    const bang = arg.indexOf("!");
    const name = bang === -1 ? arg : arg.slice(0, bang);
    const filled = bang !== -1 && arg.slice(bang + 1) === "filled";
    const el = document.createElement("m3e-icon");
    el.setAttribute("name", name);
    if (filled) el.setAttribute("filled", "");
    return el;
  },
  // RC5 search-bar: the search-bar's `input` slot accepts an <input> element;
  // the arg is the placeholder text (from the "Placeholder text" prop's
  // literalIcon-style text-to-slot binding). <input> is a void element —
  // textContent is meaningless; placeholder= is the right attribute.
  "input": (arg) => {
    const el = document.createElement("input");
    if (arg) el.setAttribute("placeholder", arg);
    return el;
  },
};

function buildSlotElement(tag, arg) {
  const build = SLOT_ELEMENT_BUILDERS[tag];
  if (build) return build(arg);
  const el = document.createElement(tag);
  if (arg) el.textContent = arg;
  return el;
}

const params = new URLSearchParams(location.search);
const tag = params.get("tag");
if (!tag) throw new Error("harness: missing required ?tag=<element-name> param");

// Optional manual-debug hook: a bundle can be loaded by URL for opening
// page.html directly in a real browser via the static server (which also
// mounts /render-cache). Programmatic capture (capture.mjs) instead injects
// the bundle via Playwright's addScriptTag and does not use this param.
const bundleUrl = params.get("bundle");
if (bundleUrl) await import(bundleUrl);

const el = document.createElement(tag);

for (const [key, value] of params) {
  if (key === "tag" || key === "text" || key === "bundle") continue;
  if (key.startsWith("attr.")) {
    el.setAttribute(key.slice("attr.".length), value);
  } else if (key.startsWith("slot.")) {
    const slotName = key.slice("slot.".length);
    const sep = value.indexOf(":");
    const slotTag = sep === -1 ? value : value.slice(0, sep);
    const slotArg = sep === -1 ? "" : value.slice(sep + 1);
    const slotEl = buildSlotElement(slotTag, slotArg);
    slotEl.setAttribute("slot", slotName);
    el.appendChild(slotEl);
  }
}

// Append the default-slot label as a TEXT NODE, never `el.textContent = text`:
// textContent replaces ALL children, which wipes any named-slot elements
// (e.g. slot="icon") appended in the loop above. The gate's default sample
// drives text AND icon together, so clobbering here silently dropped the icon
// from every such render.
const text = params.get("text");
if (text) el.appendChild(document.createTextNode(text));

// Captured Figma bounds: when the gate ran `capture_set` and threaded
// `boundsPx` into the state, `toHarnessUrlParams` serializes it as
// `boundsPx.w` / `boundsPx.h`. Apply as the PRIMARY size (logical px =
// captured px / 2, because captures are at deviceScaleFactor 2). The per-tag
// hand-tuned blocks below become FALLBACK — they fire only when no `boundsPx`
// param is present (i.e., before any capture run, which is the normal state
// today — ZERO behavior change when boundsPx is absent).
const boundsW = params.get("boundsPx.w");
const boundsH = params.get("boundsPx.h");
const hasBounds = Boolean(boundsW && boundsH);
if (hasBounds) {
  el.style.width = `${Number(boundsW) / 2}px`;
  el.style.height = `${Number(boundsH) / 2}px`;
}

// m3e-shape renders transparent without a container color because the component
// draws nothing without --m3e-shape-container-color. Inject a solid fill so
// the code side shows a visible, filled shape matching the Figma variants
// (which are all filled). Material 3 primary (#6750A4) matches Figma's default
// filled-shape color for the Shape page's light-theme variants.
if (tag === "m3e-shape") {
  el.style.setProperty("--m3e-shape-container-color", "#6750A4");
  // m3e-shape has no intrinsic size (it fills its box). The Shape-page Figma
  // variants export in a 760px frame but the actual shape is 640px — 60px
  // transparent whitespace padding each side (measured). Size the element to
  // 320px so the code shape renders 640px @ deviceScaleFactor 2, matching the
  // Figma shape's trimmed content (not the padded frame).
  // FALLBACK: only apply when no boundsPx param is present.
  if (!hasBounds) {
    el.style.width = "320px";
    el.style.height = "320px";
  }
}

// m3e-search-bar: code renders 556px wide (intrinsic fill), but Figma's search
// bar fills a 720px frame (720 @2x = 360 logical px). Constrain width so the
// code side matches the Figma export width. Height is intrinsic.
// FALLBACK: only apply when no boundsPx param is present.
if (tag === "m3e-search-bar" && !hasBounds) {
  el.style.width = "360px";
}

// m3e-list-item: renders fully transparent because the component requires slotted
// content to show anything — there are no default-content fallbacks. Inject a
// representative list item matching the Figma default: overline, headline (default
// slot), supporting text, leading icon, and trailing shortcut + chevron.
// Slots (from CEM): "" (default), "leading", "overline", "supporting-text", "trailing".
if (tag === "m3e-list-item") {
  // Figma list-item content width is 478px @2x (239 logical px). Without an
  // explicit width the element fills the stage and renders ~395–466px @2x,
  // which mismatches the Figma export. Pin to 239 logical px so the code
  // render matches the Figma content width at deviceScaleFactor 2.
  // FALLBACK: only apply when no boundsPx param is present.
  if (!hasBounds) el.style.width = "239px";

  const overline = document.createElement("span");
  overline.setAttribute("slot", "overline");
  overline.textContent = "Overline";
  el.appendChild(overline);

  el.appendChild(document.createTextNode("Label text"));

  const supporting = document.createElement("span");
  supporting.setAttribute("slot", "supporting-text");
  supporting.textContent = "Supporting line text";
  el.appendChild(supporting);

  const leadingIcon = document.createElement("m3e-icon");
  leadingIcon.setAttribute("slot", "leading");
  leadingIcon.setAttribute("name", "account_circle");
  el.appendChild(leadingIcon);

  const trailing = document.createElement("span");
  trailing.setAttribute("slot", "trailing");
  trailing.textContent = "⌘C";
  el.appendChild(trailing);
}

// m3e-bottom-sheet: applyReveal() already sets `open`, but without explicit
// dimensions the sheet collapses to a narrow strip because the component's JS
// sets --_bottom-sheet-height from its ResizeObserver caches (which may be
// stale at first open). Figma default is 868×1004 @2x (434×502 logical).
//
// Fix: inject a <style> with `!important` to pin --_bottom-sheet-height at
// 502px (which, being a stylesheet rule with !important, beats the component's
// inline style.setProperty call per the CSS cascade). Also constrain width
// (FALLBACK — skipped when boundsPx is present) and inject representative
// slotted content so the interior is not empty.
// Slots (from CEM): "" (default content), "header".
if (tag === "m3e-bottom-sheet") {
  if (!hasBounds) el.style.width = "434px";

  // Force the internal height CSS custom property via !important stylesheet rule.
  // The component uses --_bottom-sheet-height on .base { height: var(...) } in
  // shadow DOM; setting it !important on the host element overrides the
  // component's own style.setProperty() call (inline-style cascade tier).
  const bsStyle = document.createElement("style");
  bsStyle.textContent = "m3e-bottom-sheet { --_bottom-sheet-height: 502px !important; }";
  document.head.appendChild(bsStyle);

  const header = document.createElement("div");
  header.setAttribute("slot", "header");
  header.style.padding = "16px";
  header.style.fontFamily = "sans-serif";
  header.style.fontSize = "22px";
  header.style.fontWeight = "500";
  header.textContent = "Title";
  el.appendChild(header);

  const content = document.createElement("div");
  content.style.padding = "16px";
  content.style.fontFamily = "sans-serif";
  content.style.fontSize = "14px";
  content.textContent = "Sheet content";
  el.appendChild(content);
}

// m3e-fab: CSS width/height clips the icon (the icon is sized by the `size`
// attribute + internal layout, not the container box, so shrinking the box cuts
// the icon off). Figma's "Default" fab is the smaller standard FAB — driven via
// the Size axis (Default -> small in correspondence) so the icon scales with it.
// No CSS force-size here.

document.getElementById("stage").appendChild(el);

// Readiness signal for the capture side: element defined + upgraded + fonts
// loaded + lit's first update committed + two RAFs so paint has happened.
window.__ready = (async () => {
  await customElements.whenDefined(tag);
  if (el.updateComplete) await el.updateComplete;

  // Hidden-by-default components: make them visible so the gate's screenshot
  // captures their rendered state. applyReveal() runs two independent rules
  // (see reveal.mjs). Both are purely additive: switch/badge/icon-button have
  // no popover attr and no open property, so they are completely unaffected.
  applyReveal(el);
  if (el.updateComplete) await el.updateComplete;

  // Explicitly load every registered @font-face THEN await ready. document.fonts.ready
  // alone can resolve before a large variable font (e.g. Material Symbols Outlined,
  // ~4MB) that a shadow-DOM glyph only requests after the element upgrades finishes
  // loading — the screenshot then captures blank icons (FF-C1). Forcing + awaiting
  // each face closes that race; failures are swallowed so a missing face can't hang.
  await Promise.all([...document.fonts].map((f) => f.load().catch(() => {})));
  await document.fonts.ready;
  await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));
  return true;
})();
