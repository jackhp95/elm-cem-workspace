// svg-modeled-extract.mjs — the single source of truth for "what the
// elm-typed-svg package ACTUALLY generates today".
//
// Read purely from committed package artifacts (no API cost, no package
// mutation):
//   - manifest svg.cem.json  -> element tagNames + per-element attribute names
//   - config.json `_globals` -> global attribute names + which carry a finite
//                               `type` token list (the typed enums)
//   - Values.elm             -> the phantom-tagged enum type aliases
//   - Attributes.elm         -> the exposed attribute-setter identifiers
//
// Both the permanent gate (tools/check-svg-spec-coverage.mjs) and the
// modeled-index regeneration step call this, so the gate and the committed
// docs/svg-audit/modeled-index.json can never disagree about the package —
// they are derived from the same function against the same files.
//
// Zero dependencies.

import { readFileSync } from "node:fs";
import { join } from "node:path";

export const SVG_PATHS = {
    manifest: "brands/svg/generated/package/elm-typed-svg/manifest/svg.cem.json",
    config: "brands/svg/inputs/config.json",
    attributesElm: "brands/svg/generated/package/elm-typed-svg/src/TypedSvg/Attributes.elm",
    valuesElm: "brands/svg/generated/package/elm-typed-svg/src/TypedSvg/Values.elm",
};

function readJson(repoRoot, rel) {
    return JSON.parse(readFileSync(join(repoRoot, rel), "utf8"));
}

/**
 * Extract the MODELED set from the current package under `repoRoot`.
 *
 * @returns {{
 *   elements: string[],                 // sorted tagNames the package can construct
 *   elementAttributes: Record<string,string[]>, // per-element attribute names, in manifest order
 *   globals: {name:string, typed:boolean, tokens:(string[]|null)}[],
 *   globalAttributeNames: string[],     // just the names, for membership tests
 *   perElementAttributeNames: string[], // sorted union of every per-element attr name
 *   modeledAttributeNames: string[],    // sorted union of globals + per-element
 *   attributeSetters: string[],         // exposed setters from Attributes.elm (in source order)
 *   valuesEnumTypes: string[],          // sorted enum type aliases from Values.elm
 * }}
 */
export function extractModeled(repoRoot) {
    const manifest = readJson(repoRoot, SVG_PATHS.manifest);
    const config = readJson(repoRoot, SVG_PATHS.config);
    const valuesElm = readFileSync(join(repoRoot, SVG_PATHS.valuesElm), "utf8");
    const attributesElm = readFileSync(join(repoRoot, SVG_PATHS.attributesElm), "utf8");

    const decls = (manifest.modules || []).flatMap((m) => m.declarations || []);

    const elementDecls = decls.filter((d) => typeof d.tagName === "string" && d.tagName.length > 0);
    const elements = [...new Set(elementDecls.map((d) => d.tagName))].sort();

    const elementAttributes = {};
    const perElementSet = new Set();
    for (const d of elementDecls) {
        const attrs = (d.attributes || []).map((a) => a.name);
        elementAttributes[d.tagName] = attrs;
        for (const a of attrs) perElementSet.add(a);
    }

    const globals = (config._globals || []).map((g) =>
        typeof g === "string"
            ? { name: g, typed: false, tokens: null }
            : { name: g.name, typed: Array.isArray(g.type), tokens: Array.isArray(g.type) ? g.type : null },
    );
    const globalAttributeNames = globals.map((g) => g.name);
    const globalSet = new Set(globalAttributeNames);

    const modeledAttributeNames = [...new Set([...globalSet, ...perElementSet])].sort();

    // Attributes.elm `module TypedSvg.Attributes exposing ( … )` — the exposing
    // list is everything between the first "exposing (" and the matching ")".
    const attributeSetters = extractExposing(attributesElm);

    const valuesEnumTypes = [...valuesElm.matchAll(/^type alias (\w+) =/gm)]
        .map((m) => m[1])
        .filter((n) => n !== "Value")
        .sort();

    return {
        elements,
        elementAttributes,
        globals,
        globalAttributeNames,
        perElementAttributeNames: [...perElementSet].sort(),
        modeledAttributeNames,
        attributeSetters,
        valuesEnumTypes,
    };
}

/** Parse the identifiers out of the Elm `exposing ( … )` list of a module header. */
function extractExposing(elmSource) {
    const start = elmSource.indexOf("exposing");
    if (start < 0) return [];
    const open = elmSource.indexOf("(", start);
    if (open < 0) return [];
    // Walk to the matching close paren of the exposing list.
    let depth = 0;
    let end = -1;
    for (let i = open; i < elmSource.length; i++) {
        const ch = elmSource[i];
        if (ch === "(") depth++;
        else if (ch === ")") {
            depth--;
            if (depth === 0) {
                end = i;
                break;
            }
        }
    }
    if (end < 0) return [];
    const body = elmSource.slice(open + 1, end);
    // Identifiers are lower-camelCase tokens separated by commas/newlines.
    // Exclude nested (…) groupings' parens by only taking bare word tokens.
    return [...body.matchAll(/[A-Za-z_][A-Za-z0-9_]*/g)].map((m) => m[0]);
}
