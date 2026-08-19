// <avt-snackbar> — a declarative custom-element wrapper over @m3e/web's
// imperative `M3eSnackbar.open(...)` API. This is what `Ui.Snackbar.view`
// renders: Elm owns visibility (render it when you want a snackbar shown),
// and this element drives the imperative singleton on connect.
//
// Attributes (all read from the element): message, action, dismissible,
// close-label, duration, id.
//
// When the action button is pressed it dispatches a bubbling, composed
// `avt-snackbar-action` CustomEvent whose `detail.id` is this element's id,
// so Elm can round-trip the action back to a Msg via a port/subscription.
//
// Requires @m3e/web's snackbar to be registered first (it sets
// globalThis.M3eSnackbar). Import this module after "@m3e/web/all" (or
// "@m3e/web/snackbar").

class AvtSnackbar extends HTMLElement {
  connectedCallback() {
    // Defer one microtask so all attributes are present and M3eSnackbar is ready.
    queueMicrotask(() => this.#open());
  }

  #open() {
    const M = globalThis.M3eSnackbar;
    if (!M || typeof M.open !== "function") return;

    const message = this.getAttribute("message") || "";
    const action = this.getAttribute("action");
    const dismissible = this.hasAttribute("dismissible");
    const id = this.getAttribute("id") || "";

    const options = {
      actionCallback: () => {
        this.dispatchEvent(
          new CustomEvent("avt-snackbar-action", {
            bubbles: true,
            composed: true,
            detail: { id },
          })
        );
      },
    };
    const duration = this.getAttribute("duration");
    if (duration != null) options.duration = Number(duration);
    const closeLabel = this.getAttribute("close-label");
    if (closeLabel) options.closeLabel = closeLabel;

    // Always pass the action slot explicitly (undefined when absent) so a
    // no-action toast doesn't shift `dismissible` into the `action` argument.
    M.open(message, action || undefined, dismissible, options);
  }
}

if (!customElements.get("avt-snackbar")) {
  customElements.define("avt-snackbar", AvtSnackbar);
}

// Small convenience for imperative/demo use: create + flash an <avt-snackbar>
// from a plain attributes object (the wrapper opens the m3e singleton, then the
// wrapper element removes itself).
globalThis.avtSnackbarShow = (attrs = {}) => {
  const el = document.createElement("avt-snackbar");
  for (const [k, v] of Object.entries(attrs)) {
    if (v != null && v !== false) el.setAttribute(k, v === true ? "" : String(v));
  }
  (document.querySelector("m3e-theme") || document.body).appendChild(el);
  setTimeout(() => el.remove(), 50);
};
