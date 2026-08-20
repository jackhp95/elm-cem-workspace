// Hidden-by-default reveal helpers: pure, browser-agnostic logic that
// page.mjs (the gate/capture path) and the preview render scripts
// (scripts/render-batch.mjs, scripts/render-example.mjs) call after mount.
// Extracted here so every rule can be unit-tested with plain JS objects
// (no DOM needed) and so the rationale lives in one self-contained place.
//
// Four independent, guarded rules (each no-ops rather than throwing when it
// doesn't apply, the component is already shown, or the API is unavailable):
//
//   Rule 1 — popover:        host has [popover]  -> el.showPopover().
//     Covers components that set popover="manual" on the HOST in their
//     connectedCallback: m3e-snackbar, m3e-menu, m3e-fab-menu.
//     (Verified in @m3e/web/dist: snackbar.js sets popover in connectedCallback;
//      fab-menu.js line ~187 does likewise; menu.js line ~516 likewise.)
//
//   Rule 2 — open:           "open" in el && el.open === false -> set open attr.
//     Covers reflected boolean `open` properties whose setter shows the
//     component: m3e-dialog (dialog.js `set open` -> this.show() -> showModal),
//     m3e-bottom-sheet.
//
//   Rule 3 — show() method:  typeof el.show === "function" (and NOT already
//     covered by rule 1/2) -> el.show(el). Covers overlays revealed via an
//     imperative method rather than a popover attr on the host or an `open`
//     property. m3e-fab-menu's `show(trigger)` anchors + opens; passing the
//     element itself as the trigger is a harmless self-anchor for a static
//     preview. dialog.show() ignores the extra arg and is idempotent, but the
//     rule is gated OFF for it anyway (rule 2 already handled it). Kept generic:
//     any future single-arg `show()` overlay is picked up for free.
//
//   Rule 4 — shadow popover: host has no [popover] but its shadowRoot contains
//     an element with [popover] -> call showPopover() on that inner node.
//     Covers components whose popover lives on an internal shadow node rather
//     than the host: m3e-rich-tooltip / m3e-tooltip render
//     <div class="base" popover="manual"> (tooltip.js). Their public show()
//     bails without a `for=` control, so this inner-node reveal is what makes
//     a standalone (control-less) tooltip render its content in a preview.
//
// needs*Reveal are exposed separately from applyReveal so tests can assert each
// predicate independently against duck-typed plain objects.

/** @param {{ hasAttribute?: (name: string) => boolean }} el */
export function needsPopoverReveal(el) {
  return typeof el.hasAttribute === "function" && el.hasAttribute("popover");
}

/** @param {object} el — any object; tested duck-typed against `open` */
export function needsOpenReveal(el) {
  return "open" in el && el.open === false;
}

/**
 * True when the element exposes an imperative `show()` method AND is not
 * already handled by the popover/open rules (so show() isn't double-fired on a
 * host-popover or open-able element). Distinct enough to unit-test alone.
 * @param {object} el
 */
export function needsShowMethodReveal(el) {
  return typeof el.show === "function" && !needsPopoverReveal(el) && !needsOpenReveal(el);
}

/**
 * True when the host itself is not a popover but its shadow root contains a
 * popover node to reveal (rich-tooltip / tooltip internal `.base`).
 * @param {{ shadowRoot?: { querySelector?: (s: string) => unknown } }} el
 */
export function needsShadowPopoverReveal(el) {
  if (needsPopoverReveal(el)) return false; // host popover already handled by rule 1
  const root = el.shadowRoot;
  if (!root || typeof root.querySelector !== "function") return false;
  return Boolean(root.querySelector("[popover]"));
}

/**
 * Applies all reveal rules to an element in place.
 *
 * Returns a plain object describing what was attempted (for testing and
 * debugging — production callers can ignore the return value):
 *   { popover: boolean, open: boolean, showMethod: boolean, shadowPopover: boolean }
 *
 * @param {{ hasAttribute?: (n:string)=>boolean, showPopover?: ()=>void,
 *           setAttribute?: (n:string,v:string)=>void, open?: boolean,
 *           show?: (trigger?: unknown)=>unknown, shadowRoot?: object }} el
 */
export function applyReveal(el) {
  const result = { popover: false, open: false, showMethod: false, shadowPopover: false };

  if (needsPopoverReveal(el)) {
    try {
      if (typeof el.showPopover === "function") el.showPopover();
      result.popover = true;
    } catch (_) {
      // already open or Popover API unsupported — intentionally silent
    }
  }

  if (needsOpenReveal(el)) {
    try {
      el.setAttribute("open", "");
      result.open = true;
    } catch (_) {
      // read-only property or unsupported — intentionally silent
    }
  }

  if (needsShowMethodReveal(el)) {
    try {
      // Pass the element itself as the trigger/control arg: methods that
      // anchor (fab-menu.show(trigger)) get a valid self-anchor; methods that
      // ignore the arg (dialog.show()) are unaffected. show() may be async —
      // we don't await it (reveal is sync); a late rejection is swallowed
      // rather than left unhandled.
      const maybe = el.show(el);
      if (maybe && typeof maybe.then === "function") maybe.then(undefined, () => {});
      result.showMethod = true;
    } catch (_) {
      // needs a control/anchor we can't supply, or unsupported — silent
    }
  }

  if (needsShadowPopoverReveal(el)) {
    try {
      const inner = el.shadowRoot.querySelector("[popover]");
      if (inner && typeof inner.showPopover === "function") inner.showPopover();
      result.shadowPopover = true;
    } catch (_) {
      // inner node not upgraded/paintable yet or unsupported — silent
    }
  }

  return result;
}
