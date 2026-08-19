// <raw-html content="..."> — renders its `content` attribute as DOM so the
// embedded <m3e-*> custom elements upgrade in place. Used by the docs Usage
// previews (Doc.rawPreview). Elm can't set innerHTML via a property under
// elm-pages hydration, so a custom element owns its own subtree instead.
//
// SECURITY CONTRACT: `content` MUST be build-time-constant, author-controlled
// HTML only. This element has exactly ONE caller — Doc.rawPreview, fed by
// docs/data/examples.json, generated at build time from config/*.rich.json.
// Never from user input, URL/query params, or any string fetched or derived at
// runtime. Do NOT route untrusted input here: parsing an arbitrary HTML string
// into the live DOM is a DOM-XSS sink (inline event handlers, <img onerror>,
// etc. execute on adoption). If a future caller needs to render untrusted HTML,
// sanitize it (e.g. DOMPurify) BEFORE it reaches this element, or upgrade this
// element to sanitize internally.
//
// If you are here to render an ICON, you are in the wrong place: register it via
// config/icons.json and m3e's IconRegistry (docs/gen/icons.js), which is a
// validated path-data channel rather than an innerHTML sink.
class RawHtml extends HTMLElement {
  static get observedAttributes() {
    return ["content"];
  }
  connectedCallback() {
    this.render();
  }
  attributeChangedCallback() {
    if (this.isConnected) this.render();
  }
  render() {
    const next = this.getAttribute("content") || "";
    if (this._last === next) return;
    this._last = next;

    // Parse the (build-time-constant) markup in an inert <template> first, then
    // adopt its nodes — makes the "this is authored HTML being materialized as
    // DOM" intent explicit rather than assigning a raw string to innerHTML.
    const tpl = document.createElement("template");
    tpl.innerHTML = next;
    this.replaceChildren(tpl.content.cloneNode(true));
  }
}
if (!customElements.get("raw-html")) customElements.define("raw-html", RawHtml);
