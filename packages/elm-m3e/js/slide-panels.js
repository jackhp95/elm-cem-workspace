// <slide-panels active-index="N"> — the height-sync viewport for the docs' sliding
// code panels (Doc.Slider.slidingPanels). Elm owns the horizontal slide: it mounts
// all panels in a `.sp-track` flex row and sets the track's `transform` inline, and
// CSS animates it (style.css). This element owns only the VERTICAL dimension: it
// keeps its own height locked to the *active* panel's height (via a ResizeObserver)
// so a short surface leaves no empty space, a tall one is never clipped, and the
// height follows fold open/close (stream B2) — CSS transitions the height change.
//
// Graceful degradation: if this element never upgrades, CSS leaves the viewport at
// `height: auto` (it grows to the tallest panel — active content still fully shown)
// and the Elm-driven transform still selects the active panel. No JS is required for
// correctness, only for the tight height fit.
//
// Reduced motion: the height/transform transitions are zeroed by a
// `prefers-reduced-motion` media query in style.css, so no JS branch is needed —
// we always set the height directly and let CSS decide whether to animate it.
class SlidePanels extends HTMLElement {
  static get observedAttributes() {
    return ["active-index"];
  }

  connectedCallback() {
    this._ro = new ResizeObserver(() => this._sync());
    // Wait a frame so the panels have laid out before measuring.
    requestAnimationFrame(() => this._observeActive());
  }

  disconnectedCallback() {
    if (this._ro) this._ro.disconnect();
  }

  attributeChangedCallback(name) {
    if (name === "active-index" && this.isConnected) this._observeActive();
  }

  _panels() {
    const track = this.querySelector(".sp-track");
    return track ? Array.from(track.children) : [];
  }

  _activePanel() {
    const panels = this._panels();
    if (!panels.length) return null;
    let i = parseInt(this.getAttribute("active-index") || "0", 10);
    if (Number.isNaN(i) || i < 0) i = 0;
    if (i >= panels.length) i = panels.length - 1;
    return panels[i];
  }

  _observeActive() {
    const active = this._activePanel();
    if (!active || !this._ro) return;
    // Re-point the observer at the newly-active panel (fires on its resize too).
    this._ro.disconnect();
    this._ro.observe(active);
    this._sync();
  }

  _sync() {
    const active = this._activePanel();
    if (!active) return;
    // Ceil the fractional box height: offsetHeight rounds down, which under the
    // viewport's `overflow: hidden` would clip ~1px off a fractional-height panel.
    this.style.height = Math.ceil(active.getBoundingClientRect().height) + "px";
  }
}

if (!customElements.get("slide-panels")) {
  customElements.define("slide-panels", SlidePanels);
}
