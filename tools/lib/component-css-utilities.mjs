// component-css-utilities.mjs — generic Face-B (CEM facts bundle) -> Tailwind
// v4 `@utility` generator. Reads a bundle's `components[].cssProperties` (any
// brand's reconciled Custom Elements Manifest projection, not just m3e's) and
// derives: a Tailwind v4 utilities stylesheet, a machine-readable name
// manifest (so a lint rule can ask "is `<prefix>-foo-bar` a REAL utility?"
// without parsing CSS), and a Markdown reference doc.
//
// Promoted here (was `tailwind-m3e-web/bin/generate-component-utilities.mjs`)
// per the thermonuclear audit (Theme 6, trapped-generic-modules #2) — the
// transform logic (type inference, extraction, emission) has zero functional
// m3e coupling; only doc-string/output prose mentions "m3e" (paths, headings)
// and is left as-is, same call the audit made for elm-cem's codegen core
// ("all doc-comment examples... none are runtime literals" is the standard
// for what counts as clean here — see Theme 2 of the review). The package
// import stays byte-identical: `tailwind-m3e-web/bin/generate-component-
// utilities.mjs` now re-exports everything from here so its committed
// `generated/*` outputs and existing tests are untouched. Zero dependencies
// (plain Node ESM).

/* ──────────────────────────────────────────────────────────────────
   Type inference

   Each entry: [matcher, type, themeNamespace?]
     - matcher: (name, description) => boolean
     - type: Tailwind v4 --value() type token (e.g. "color", "length")
     - themeNamespace: optional --theme-key prefix that lets call sites
       pass theme keys (e.g. m3e-foo-color-primary → --color-primary)

   First match wins. Order matters — put more specific patterns first.
   ────────────────────────────────────────────────────────────────── */

/* Patterns match "type token followed by - or end". This catches state-
   suffix variants like --foo-color-on-scroll (color with state qualifier
   at end) AND prefixed variants like --foo-hover-container-color. */

const RULES = [
  // Opacity & numeric scalars — checked BEFORE color so names like
  // `*-color-opacity` (which contain `-color-` mid-name but are 0–1 numbers,
  // e.g. --m3e-select-disabled-color-opacity) infer `number`, not `color`.
  [(n) => /-opacity(-|$)/.test(n), "number"],
  [(n) => /-z-index(-|$)/.test(n), "number"],

  // Colors. NOTE: `*-elevation-color` vars intentionally still match here
  // (they are shadow-tint colours), since the elevation rule below is not
  // hoisted above this one.
  [(n) => /-color(-|$)/.test(n), "color", "color"],

  // Radii / shape
  [(n) => /-shape(-|$)/.test(n), "length", "radius"],
  [(n) => /-corner-/.test(n), "length", "radius"],

  // Typography
  [(n) => /-(font-size|text-size)(-|$)/.test(n), "length", "text"],
  [(n) => /-line-height(-|$)/.test(n), "length", "leading"],
  [(n) => /-(tracking|letter-spacing)(-|$)/.test(n), "length", "tracking"],
  [(n) => /-font-weight(-|$)/.test(n), "number", "font-weight"],
  [(n) => /-(font-family|font)(-|$)/.test(n), "*", "font"],

  // Motion
  [(n) => /-duration(-|$)/.test(n), "time", "transition-duration"],
  [(n) => /-easing(-|$)/.test(n), "*", "ease"],
  [(n) => /-transition(-|$)/.test(n), "*"],
  [(n) => /-transform(-|$)/.test(n), "*"],

  // Elevation
  [(n) => /-elevation(-|$)/.test(n), "*", "shadow"],

  // Lengths (catch-all for spatial dims). Component-local — no namespace.
  [
    (n) =>
      /-(size|height|width|spacing|space|offset|thickness|gap|inset|outset|reserved|peek-height|top-space|bottom-space|start-space|end-space)(-|$)/.test(
        n,
      ),
    "length",
  ],
  [(n) => /-(padding|margin)(-[a-z]+)?(-|$)/.test(n), "length"],
  [(n) => /-(min|max)-(width|height|size|inline-size|block-size)(-|$)/.test(n), "length"],
  [(n) => /-(left|right|top|bottom)(-|$)/.test(n), "length"],
];

/* Hand-corrected overrides for ambiguous or non-suffix-fitting names.
   Keyed by full var name; value is [type, themeNamespace?]. */

const OVERRIDES = {
  // The following vars look like colors by suffix but aren't:
  // (none observed yet — extend as needed)
};

export function inferType(name, description = "") {
  if (OVERRIDES[name]) return OVERRIDES[name];
  for (const [matcher, type, ns] of RULES) {
    if (matcher(name, description)) return [type, ns];
  }
  // Fallback — accept any value, no theme namespace.
  return ["*", null];
}

/* ──────────────────────────────────────────────────────────────────
   Facts bundle extraction
   ────────────────────────────────────────────────────────────────── */

/* Returns { byComponent: Map<tag, {description, vars: [{name, description, type, ns}]}>,
             flatUnique: Map<name, {description, type, ns, components: [tag]}> }
   Face B (`bundle.components[]`) is already reconciled to one entry per
   authoritative tag and deduped (`bundle.duplicates`), so there is no
   raw-tagName-collision or split-declaration merge to reimplement here. */
export function extractCssProperties(bundle) {
  const byComponent = new Map();
  const flatUnique = new Map();

  for (const comp of bundle.components || []) {
    if (!comp.cssProperties?.length) continue;
    const tag = comp.tag;
    const compEntry = { description: comp.description || "", vars: [] };
    for (const prop of comp.cssProperties) {
      const [type, ns] = inferType(prop.name, prop.description);
      const entry = {
        name: prop.name,
        description: prop.description || "",
        type,
        ns,
      };
      compEntry.vars.push(entry);

      const existing = flatUnique.get(prop.name);
      if (existing) {
        if (!existing.components.includes(tag)) existing.components.push(tag);
        // Keep the first description we saw (they're usually identical).
      } else {
        flatUnique.set(prop.name, { ...entry, components: [tag] });
      }
    }
    byComponent.set(tag, compEntry);
  }

  return { byComponent, flatUnique };
}

/* ──────────────────────────────────────────────────────────────────
   Emit utilities.css
   ────────────────────────────────────────────────────────────────── */

function buildUtilityRule(entry) {
  // Utility class is the var name without the leading "--".
  // E.g. --m3e-button-container-color → @utility m3e-button-container-color-*
  const cls = entry.name.replace(/^--/, "");
  const valueExpr = entry.ns
    ? `--value([${entry.type}], --${entry.ns}-*)`
    : `--value([${entry.type}])`;
  return `@utility ${cls}-* {\n  ${entry.name}: ${valueExpr};\n}`;
}

export function emitUtilities(flatUnique) {
  const names = [...flatUnique.keys()].sort();
  const header = `/*
 * AUTO-GENERATED — DO NOT EDIT
 *
 * Generated by bin/generate-component-utilities.mjs from
 * data/cem-facts.json (elm-cem's Face B facts bundle).
 *
 * One @utility rule per public --m3e-* CSS custom property in the
 * m3e manifest (${names.length} rules). Each rule lets call sites pass
 * either an arbitrary value or a Tailwind v4 theme key.
 *
 * INERT UNTIL TAILWIND v4. @utility is unrecognized syntax in v3;
 * the v3 build and prettier silently ignore the entire file.
 */
`;
  const body = names.map((n) => buildUtilityRule(flatUnique.get(n))).join("\n\n");
  return `${header}\n${body}\n`;
}

/* ──────────────────────────────────────────────────────────────────
   Emit utilities.json — the machine-readable companion to utilities.css
   ────────────────────────────────────────────────────────────────── */

/**
 * The same utility set as `utilities.css`, as data rather than CSS syntax.
 *
 * Consumers need to answer "is `m3e-foo-bar-baz` a REAL utility?" and cannot do
 * that against the CSS without parsing it. The concrete consumer today is
 * elm-m3e's `NoProprietaryDsClasses` lint rule, which permits `m3e-*` classes as
 * the sanctioned styling bridge — it previously accepted anything starting with
 * `m3e-`, so a typo like `m3e-crd-padding-4` passed review and then rendered
 * nothing. Exactly the dead-class failure that rule exists to catch.
 *
 * Names are emitted WITHOUT the trailing `-*`: `@utility m3e-card-padding-*`
 * becomes `"m3e-card-padding"`. A call site is a match when it equals a name or
 * starts with `name + "-"`, which is what Tailwind's `-*` means.
 */
export function emitUtilityManifest(flatUnique) {
  const utilities = [...flatUnique.keys()]
    .map((n) => n.replace(/^--/, ""))
    .sort();
  return `${JSON.stringify(
    {
      $comment:
        "AUTO-GENERATED — DO NOT EDIT. Written by bin/generate-component-utilities.mjs from data/cem-facts.json, alongside generated/utilities.css. Utility name prefixes WITHOUT the trailing `-*`; a class matches when it equals a name or starts with name + '-'.",
      count: utilities.length,
      utilities,
    },
    null,
    2,
  )}\n`;
}

/* ──────────────────────────────────────────────────────────────────
   Emit CSS_CUSTOM_PROPERTIES.md
   ────────────────────────────────────────────────────────────────── */

export function emitDoc(byComponent, flatUnique) {
  const lines = [];
  lines.push("<!-- AUTO-GENERATED — DO NOT EDIT. Regenerate via:");
  lines.push("     node bin/generate-component-utilities.mjs -->");
  lines.push("");
  lines.push("# M3e CSS Custom Properties");
  lines.push("");
  lines.push(
    "Structured reference for every public CSS custom property exposed by m3e web components, grouped by component, with inferred Tailwind v4 type and (where applicable) the theme namespace used by the matching `@utility` setter class.",
  );
  lines.push("");
  lines.push(
    `Total: **${flatUnique.size} unique** public vars across **${byComponent.size} components**.`,
  );
  lines.push("");

  // Table of contents
  lines.push("## Components");
  lines.push("");
  const tags = [...byComponent.keys()].sort();
  for (const tag of tags) {
    lines.push(`- [\`${tag}\`](#${tag.replace(/[^a-z0-9]/g, "-")})`);
  }
  lines.push("");

  // Per-component sections
  for (const tag of tags) {
    const { description, vars } = byComponent.get(tag);
    lines.push(`## \`${tag}\``);
    lines.push("");
    if (description) {
      lines.push(description);
      lines.push("");
    }
    lines.push("| Var | Type | Theme namespace | Description |");
    lines.push("|---|---|---|---|");
    for (const v of vars.sort((a, b) => a.name.localeCompare(b.name))) {
      const ns = v.ns ? `\`--${v.ns}-*\`` : "—";
      const desc = (v.description || "").replace(/\|/g, "\\|").replace(/\n/g, " ");
      lines.push(`| \`${v.name}\` | \`${v.type}\` | ${ns} | ${desc} |`);
    }
    lines.push("");
  }

  return lines.join("\n");
}
