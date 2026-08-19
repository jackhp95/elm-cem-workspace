// Turns a component's representative example children (from examples.json) into
// an HTML snippet for the html-label emitter, and validates the config against
// the CEM (every child tag real; every slot a real slot of its parent). Pure,
// zero deps. See plans/2026-07-18-representative-example-emission-design.md.

// Plain HTML tags allowed as example scaffolding (text containers etc.).
const HTML_TAGS = new Set(["span", "div", "p", "img", "input", "button", "label"]);

function esc(s) {
  return String(s ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

// renderChildrenHtml(childSpecs) -> HTML string (no surrounding whitespace).
export function renderChildrenHtml(childSpecs) {
  if (!Array.isArray(childSpecs)) return "";
  return childSpecs.map(renderOne).join("");
}

function renderOne(spec) {
  const slotAttr = spec.slot ? ` slot="${esc(spec.slot)}"` : "";
  const attrs = spec.attrs
    ? Object.entries(spec.attrs).map(([k, v]) => ` ${k}="${esc(v)}"`).join("")
    : "";
  const inner = (spec.text != null ? esc(spec.text) : "") + renderChildrenHtml(spec.children);
  return `<${spec.tag}${slotAttr}${attrs}>${inner}</${spec.tag}>`;
}

// validateSetAttrs(setAttrs, cem) -> throws on the first problem.
//   setAttrs: { [cemTag]: { [setName]: { [attr]: value } } }
//   cem: { tags: Set<string>, attrsByTag: { [tag]: Set<attrName> } }
// Validates that every cemTag exists in the CEM and every attr is a real
// CEM attribute of that tag. SetName correctness is enforced fail-loud at
// emit time (not here), since the correspondence entries are not available
// during config validation.
export function validateSetAttrs(setAttrs, cem) {
  for (const [cemTag, setMap] of Object.entries(setAttrs)) {
    if (!cem.tags.has(cemTag)) {
      throw new Error(`set-attrs.json: unknown cemTag '${cemTag}' (not in CEM)`);
    }
    const tagAttrs = cem.attrsByTag[cemTag] ?? new Set();
    for (const [, attrMap] of Object.entries(setMap)) {
      for (const attrName of Object.keys(attrMap)) {
        if (!tagAttrs.has(attrName)) {
          throw new Error(
            `set-attrs.json: unknown attr '${attrName}' on '${cemTag}' (not a CEM attribute of that tag)`
          );
        }
      }
    }
  }
}

// validateExamples(examples, cem) -> throws on the first problem.
//   cem: { tags: Set<string>, slotsByTag: { [tag]: Set<slotName> } }
export function validateExamples(examples, cem) {
  for (const [parentTag, entry] of Object.entries(examples)) {
    const parentSlots = cem.slotsByTag[parentTag] ?? new Set();
    walk(entry.children, parentTag, parentSlots, cem);
  }
}

function walk(children, parentTag, parentSlots, cem) {
  if (!Array.isArray(children)) return;
  for (const c of children) {
    if (!cem.tags.has(c.tag) && !HTML_TAGS.has(c.tag)) {
      throw new Error(`examples.json: unknown tag '${c.tag}' under '${parentTag}' (not a CEM custom element or allowed HTML tag)`);
    }
    if (c.slot && !parentSlots.has(c.slot)) {
      throw new Error(`examples.json: slot '${c.slot}' is not a slot of '${parentTag}' (child '${c.tag}')`);
    }
    const childSlots = cem.slotsByTag[c.tag] ?? new Set();
    walk(c.children, c.tag, childSlots, cem);
  }
}
