// Unit tests for the hidden-by-default reveal logic in reveal.mjs.
//
// These run in Node (no browser, no DOM): each test simulates a custom element
// using a plain JS object and asserts that applyReveal / needsPopoverReveal /
// needsOpenReveal behave correctly.
//
// Run with:
//   node --test src/visual/harness/reveal.test.mjs

import { test } from "node:test";
import assert from "node:assert/strict";
import {
  needsPopoverReveal,
  needsOpenReveal,
  needsShowMethodReveal,
  needsShadowPopoverReveal,
  applyReveal,
} from "./reveal.mjs";

// ---------------------------------------------------------------------------
// needsPopoverReveal — true only when element has popover attribute
// ---------------------------------------------------------------------------

test("needsPopoverReveal: true when element has popover attribute", () => {
  const el = {
    _attrs: { popover: "manual" },
    hasAttribute(name) { return name in this._attrs; },
  };
  assert.equal(needsPopoverReveal(el), true);
});

test("needsPopoverReveal: false when element has no popover attribute", () => {
  const el = {
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
  };
  assert.equal(needsPopoverReveal(el), false);
});

test("needsPopoverReveal: false for ordinary elements (switch, badge, icon-button simulation)", () => {
  for (const tag of ["m3e-switch", "m3e-badge", "m3e-icon-button"]) {
    const el = {
      tag,
      _attrs: { variant: "filled" },
      hasAttribute(name) { return name in this._attrs; },
    };
    assert.equal(needsPopoverReveal(el), false, `${tag} must not trigger popover reveal`);
  }
});

// ---------------------------------------------------------------------------
// needsOpenReveal — true only when element has open property AND it is false
// ---------------------------------------------------------------------------

test("needsOpenReveal: true when element has open property set to false", () => {
  const el = { open: false };
  assert.equal(needsOpenReveal(el), true);
});

test("needsOpenReveal: false when element has open property set to true", () => {
  const el = { open: true };
  assert.equal(needsOpenReveal(el), false);
});

test("needsOpenReveal: false when element has no open property (ordinary element)", () => {
  const el = { variant: "filled" };
  assert.equal(needsOpenReveal(el), false);
});

test("needsOpenReveal: false for ordinary elements (switch, badge, icon-button simulation)", () => {
  for (const tag of ["m3e-switch", "m3e-badge", "m3e-icon-button"]) {
    const el = { tag, checked: false }; // these have checked, not open
    assert.equal(needsOpenReveal(el), false, `${tag} must not trigger open reveal`);
  }
});

test("needsOpenReveal: false when open is undefined (not a boolean false)", () => {
  const el = { open: undefined };
  assert.equal(needsOpenReveal(el), false);
});

// ---------------------------------------------------------------------------
// applyReveal — integration: combines both rules with side-effects
// ---------------------------------------------------------------------------

test("applyReveal: calls showPopover() on a popover element and returns { popover: true, open: false }", () => {
  let showPopoverCalled = false;
  const el = {
    _attrs: { popover: "manual" },
    hasAttribute(name) { return name in this._attrs; },
    setAttribute(name, value) { this._attrs[name] = value; },
    showPopover() { showPopoverCalled = true; },
  };
  const result = applyReveal(el);
  assert.equal(showPopoverCalled, true, "showPopover() must be called");
  assert.deepEqual(result, { popover: true, open: false, showMethod: false, shadowPopover: false });
});

test("applyReveal: sets open attribute on an open-able element and returns { popover: false, open: true }", () => {
  const el = {
    open: false,
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
    setAttribute(name, value) {
      this._attrs[name] = value;
      if (name === "open") this.open = true; // reflect attribute -> property
    },
  };
  const result = applyReveal(el);
  assert.equal(el._attrs.open, "", "open attribute must be set to empty string");
  assert.deepEqual(result, { popover: false, open: true, showMethod: false, shadowPopover: false });
});

test("applyReveal: both rules fire independently when element is both a popover and open-able", () => {
  // Contrived but valid: an element that sets popover="manual" AND has open:false
  let showPopoverCalled = false;
  const el = {
    open: false,
    _attrs: { popover: "manual" },
    hasAttribute(name) { return name in this._attrs; },
    setAttribute(name, value) { this._attrs[name] = value; },
    showPopover() { showPopoverCalled = true; },
  };
  const result = applyReveal(el);
  assert.equal(showPopoverCalled, true);
  assert.equal(el._attrs.open, "");
  assert.deepEqual(result, { popover: true, open: true, showMethod: false, shadowPopover: false });
});

test("applyReveal: no-ops on an ordinary element (no popover, no open) — returns { popover: false, open: false }", () => {
  const el = {
    variant: "filled",
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
    setAttribute(name, value) { this._attrs[name] = value; },
  };
  const result = applyReveal(el);
  assert.deepEqual(result, { popover: false, open: false, showMethod: false, shadowPopover: false });
  assert.deepEqual(Object.keys(el._attrs), [], "no attributes must be set on an ordinary element");
});

test("applyReveal: swallows an error from showPopover() (e.g. already shown)", () => {
  const el = {
    _attrs: { popover: "manual" },
    hasAttribute(name) { return name in this._attrs; },
    setAttribute(name, value) { this._attrs[name] = value; },
    showPopover() { throw new Error("InvalidStateError: element is already shown"); },
  };
  // Must not throw — the error is intentionally swallowed.
  assert.doesNotThrow(() => applyReveal(el));
  // popover result is still false because the try/catch ate the throw before
  // setting result.popover (it didn't reach the assignment after the call).
  const result = applyReveal(el);
  assert.equal(result.popover, false);
});

test("applyReveal: swallows an error from setAttribute('open') (read-only property)", () => {
  const el = {
    open: false,
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
    setAttribute(name, value) {
      if (name === "open") throw new Error("TypeError: setting open is read-only");
    },
  };
  assert.doesNotThrow(() => applyReveal(el));
  const result = applyReveal(el);
  assert.equal(result.open, false); // setAttribute threw, so result.open stays false
});

test("applyReveal: does not touch open when already true (element already open)", () => {
  const calls = [];
  const el = {
    open: true,
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
    setAttribute(name, value) { calls.push([name, value]); },
  };
  applyReveal(el);
  assert.deepEqual(calls, [], "setAttribute must not be called when element is already open");
});

// ---------------------------------------------------------------------------
// needsShowMethodReveal — true only when element exposes a show() method AND is
// not already handled by the popover/open rules (fab-menu simulation).
// ---------------------------------------------------------------------------

test("needsShowMethodReveal: true when element has show() and no popover attr / no open prop", () => {
  const el = {
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
    show() {},
  };
  assert.equal(needsShowMethodReveal(el), true);
});

test("needsShowMethodReveal: false when element has no show() method", () => {
  const el = {
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
  };
  assert.equal(needsShowMethodReveal(el), false);
});

test("needsShowMethodReveal: false when a host popover already covers the element", () => {
  // A host-popover element (e.g. m3e-menu / m3e-fab-menu) may ALSO expose show();
  // the popover rule handles it, so the show-method rule must stand down to avoid
  // double-firing.
  const el = {
    _attrs: { popover: "manual" },
    hasAttribute(name) { return name in this._attrs; },
    show() {},
  };
  assert.equal(needsShowMethodReveal(el), false);
});

test("needsShowMethodReveal: false when an open property already covers the element", () => {
  const el = {
    open: false,
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
    show() {},
  };
  assert.equal(needsShowMethodReveal(el), false);
});

test("needsShowMethodReveal: false for ordinary elements (switch, badge, icon-button simulation)", () => {
  for (const tag of ["m3e-switch", "m3e-badge", "m3e-icon-button"]) {
    const el = {
      tag,
      _attrs: {},
      hasAttribute(name) { return name in this._attrs; },
    };
    assert.equal(needsShowMethodReveal(el), false, `${tag} must not trigger show-method reveal`);
  }
});

// ---------------------------------------------------------------------------
// needsShadowPopoverReveal — true when host is not a popover but its shadow root
// contains a popover node (rich-tooltip / tooltip internal `.base` simulation).
// ---------------------------------------------------------------------------

test("needsShadowPopoverReveal: true when shadowRoot has a [popover] node and host is not a popover", () => {
  const el = {
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
    shadowRoot: { querySelector(sel) { return sel === "[popover]" ? { showPopover() {} } : null; } },
  };
  assert.equal(needsShadowPopoverReveal(el), true);
});

test("needsShadowPopoverReveal: false when host itself is a popover (rule 1 handles it)", () => {
  const el = {
    _attrs: { popover: "manual" },
    hasAttribute(name) { return name in this._attrs; },
    shadowRoot: { querySelector() { return { showPopover() {} }; } },
  };
  assert.equal(needsShadowPopoverReveal(el), false);
});

test("needsShadowPopoverReveal: false when there is no shadowRoot", () => {
  const el = {
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
  };
  assert.equal(needsShadowPopoverReveal(el), false);
});

test("needsShadowPopoverReveal: false when shadowRoot has no [popover] node", () => {
  const el = {
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
    shadowRoot: { querySelector() { return null; } },
  };
  assert.equal(needsShadowPopoverReveal(el), false);
});

// ---------------------------------------------------------------------------
// applyReveal — new-rule integration
// ---------------------------------------------------------------------------

test("applyReveal: calls show(el) on a show()-only element and returns showMethod: true", () => {
  let showArg;
  const el = {
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
    setAttribute(name, value) { this._attrs[name] = value; },
    show(trigger) { showArg = trigger; },
  };
  const result = applyReveal(el);
  assert.equal(showArg, el, "show() must be called with the element itself as the trigger/control");
  assert.deepEqual(result, { popover: false, open: false, showMethod: true, shadowPopover: false });
});

test("applyReveal: swallows a synchronous throw from show() (e.g. needs a control)", () => {
  const el = {
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
    show() { throw new Error("needs a `for=` control"); },
  };
  assert.doesNotThrow(() => applyReveal(el));
  const result = applyReveal(el);
  assert.equal(result.showMethod, false, "a thrown show() leaves showMethod false");
});

test("applyReveal: swallows a rejected promise from an async show() and still reports showMethod: true", () => {
  const el = {
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
    show() { return Promise.reject(new Error("late anchor failure")); },
  };
  // Must not throw synchronously; the rejection is attached a no-op catch so it
  // is not left unhandled.
  const result = applyReveal(el);
  assert.equal(result.showMethod, true);
});

test("applyReveal: reveals a shadow-DOM popover (rich-tooltip simulation) and returns shadowPopover: true", () => {
  let innerShown = false;
  const inner = { showPopover() { innerShown = true; } };
  const el = {
    _attrs: {},
    hasAttribute(name) { return name in this._attrs; },
    shadowRoot: { querySelector(sel) { return sel === "[popover]" ? inner : null; } },
  };
  const result = applyReveal(el);
  assert.equal(innerShown, true, "the inner [popover] node's showPopover() must be called");
  assert.deepEqual(result, { popover: false, open: false, showMethod: false, shadowPopover: true });
});
