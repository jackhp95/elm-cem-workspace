// Derive a feature-section name for a mined example. A "section" groups related
// examples under a `### <section>` header in the generated docs. The signal is a
// row of ≥2 sibling elements of the SAME m3e tag that differ by exactly one
// enum-typed attribute (e.g. five buttons differing only by `variant`).

import { parseHTML } from "linkedom";

// attribute htmlName -> section label. Anything not listed here title-cases the
// attribute name (e.g. "header-position" -> "Header Position").
const SECTION_HINTS = {
  variant: "Variants",
  size: "Sizes",
  shape: "Shapes",
  orientation: "Orientation",
  density: "Density",
};

// Title-case a kebab/space-separated attribute name: "header-position" ->
// "Header Position".
function titleCase(name) {
  return String(name)
    .split(/[-\s_]+/)
    .filter(Boolean)
    .map((w) => w[0].toUpperCase() + w.slice(1))
    .join(" ");
}

function sectionFor(htmlName) {
  return SECTION_HINTS[htmlName] ?? titleCase(htmlName);
}

/**
 * @param {string} htmlString - the mined example markup
 * @param {Record<string, any>} oracle - buildOracle() output
 * @returns {string | null} section label, or null if unsectioned
 */
export function deriveSection(htmlString, oracle) {
  let document;
  try {
    ({ document } = parseHTML(`<html><body>${htmlString}</body></html>`));
  } catch {
    return null;
  }

  // Top-level sibling ELEMENTS (ignore text/whitespace nodes).
  const siblings = [...document.body.childNodes].filter(
    (n) => n.nodeType === 1,
  );
  if (siblings.length < 2) return null;

  // All siblings must share one m3e tag known to the oracle.
  const tag = siblings[0].tagName.toLowerCase();
  if (!oracle[tag]) return null;
  if (!siblings.every((el) => el.tagName.toLowerCase() === tag)) return null;

  // Only enum-typed attributes are eligible varying dimensions. Booleans and
  // identity/freeform attrs never count.
  const enumAttrs = (oracle[tag].attributes ?? []).filter(
    (a) => a.kind === "enum",
  );

  // For each enum attribute, collect the distinct values present across
  // siblings (absent attribute contributes no value).
  const varying = [];
  for (const attr of enumAttrs) {
    const values = new Set();
    for (const el of siblings) {
      if (el.hasAttribute(attr.htmlName)) {
        values.add(el.getAttribute(attr.htmlName));
      }
    }
    if (values.size >= 2) varying.push(attr.htmlName);
  }

  // Exactly one enum attribute varies -> that's the section. Zero or multiple
  // (ambiguous) -> unsectioned.
  if (varying.length !== 1) return null;
  return sectionFor(varying[0]);
}
