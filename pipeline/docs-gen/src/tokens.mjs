// Brand-agnostic derivation of the docs "token gallery" surface from a design
// system's CSS custom-property manifest. Pure: takes CSS text, returns the docs
// data. The token *taxonomy* (which typescale roles, which corner sizes) is M3's
// here, passed in as arguments so a non-M3 brand can supply its own; the PARSER
// (`customProps`) is fully generic.
//
// This is the reusable core of each brand's `gen-style-tokens` wrapper.

/**
 * Parse all `--<prefix><name>: <value>;` declarations out of CSS text.
 * @param {string} css
 * @param {string} prefix e.g. "md-sys-typescale-"
 * @returns {Map<string,string>} name (minus prefix) -> value (whitespace-collapsed)
 */
export function customProps(css, prefix) {
  const map = new Map();
  const re = new RegExp(`--${prefix}([a-z0-9-]+)\\s*:\\s*([^;]+);`, "gi");
  let m;
  while ((m = re.exec(css)) !== null) map.set(m[1], m[2].trim().replace(/\s+/g, " "));
  return map;
}

const SZ_ABBR = { large: "lg", medium: "md", small: "sm" };

/**
 * Derive a type-scale table: one row per role with its `metrics` string
 * (`font-size / line-height · weight`) and Tailwind class.
 * @param {string} typescaleCss
 * @param {{ families?: string[], sizes?: string[], prefix?: string }} [opts]
 * @returns {{ class: string, metrics: string }[]}
 */
export function deriveTypescale(typescaleCss, opts = {}) {
  const {
    families = ["display", "headline", "title", "body", "label"],
    sizes = ["large", "medium", "small"],
    prefix = "md-sys-typescale-",
  } = opts;
  const ts = customProps(typescaleCss, prefix);
  const out = [];
  for (const family of families) {
    for (const size of sizes) {
      const role = `${family}-${size}`;
      const fs = ts.get(`${role}-font-size`);
      const lh = ts.get(`${role}-line-height`);
      const w = ts.get(`${role}-font-weight`);
      if (!fs || !lh || !w) throw new Error(`deriveTypescale: role "${role}" missing font-size/line-height/font-weight`);
      out.push({ class: `text-${family}-${SZ_ABBR[size] ?? size}`, metrics: `${fs} / ${lh} · ${w}` });
    }
  }
  return out;
}

const titleize = (s) => {
  const words = s.replace(/-/g, " ");
  return words.charAt(0).toUpperCase() + words.slice(1);
};

/**
 * Derive the corner-radius scale: `(utility, label, value)` per size.
 * @param {string} shapeCss
 * @param {string[]} sizes ordered corner sizes (e.g. none..full)
 * @param {{ prefix?: string, valueInfix?: string, utilityPrefix?: string }} [opts]
 * @returns {{ utility: string, label: string, value: string }[]}
 */
export function deriveShapeCorners(shapeCss, sizes, opts = {}) {
  const { prefix = "md-sys-shape-", valueInfix = "corner-value-", utilityPrefix = "rounded-md-corner-" } = opts;
  const shape = customProps(shapeCss, prefix);
  return sizes.map((size) => {
    const value = shape.get(`${valueInfix}${size}`) ?? shape.get(`corner-${size}`);
    if (value === undefined) throw new Error(`deriveShapeCorners: corner "${size}" not found`);
    return { utility: `${utilityPrefix}${size}`, label: titleize(size), value };
  });
}

/**
 * The complete sorted inventory of color-role names present in the manifest.
 * @param {string} colorCss
 * @param {{ prefix?: string }} [opts]
 * @returns {string[]}
 */
export function deriveColorRoleInventory(colorCss, opts = {}) {
  const { prefix = "md-sys-color-" } = opts;
  return [...customProps(colorCss, prefix).keys()].sort();
}
