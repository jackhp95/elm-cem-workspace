// Loader for figma-export.json — the ONE deterministic per-Figma-file JSON
// the whole pipeline consumes (D9, plans/00-mission-and-decisions.md).
//
// Validates the export against figma-export.schema.json (hand-rolled
// validator, src/lib/validate.mjs — zero-dep core), then derives the views
// downstream tasks (matcher, correspondence) actually want: sets /
// standalones / variants, variant names parsed into {prop: value} pairs, and
// variants grouped by page.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { validate } from "../lib/validate.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const SCHEMA_PATH = path.join(here, "figma-export.schema.json");

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

// Figma appends a "#<nodeId>" suffix to non-variant component property names
// (e.g. "Label text#58653:0"); VARIANT property names never carry one. Code
// Connect's getString/getBoolean/etc. consume the *display* name ("Label
// text" worked live against a real publish, evidence #2).
//
// Guard: only strip the suffix when it is a real Figma nodeId (digits:digits),
// not when `#` appears as a literal display character (e.g. "# of lines" — the
// snackbar axis that uses `#` as part of its human-readable name). A trailing
// nodeId suffix is ALWAYS of the form "#\d+:\d+" (e.g. "#58653:0"); any `#`
// not followed by that pattern is part of the display name itself.
const NODEID_SUFFIX_RE = /#\d+:\d+$/;
export function displayNameOf(rawName) {
  const hashIndex = rawName.lastIndexOf("#");
  if (hashIndex === -1) return rawName;
  // Only strip if the substring from the last `#` onward is a nodeId suffix.
  if (NODEID_SUFFIX_RE.test(rawName.slice(hashIndex))) return rawName.slice(0, hashIndex);
  return rawName;
}

export function isVariantName(name) {
  return name.includes("=");
}

// Parses a variant COMPONENT's name, e.g.
// "Type=Square, Size=XLarge, State=Enabled" -> { Type: "Square", Size:
// "XLarge", State: "Enabled" }. Segments are comma-separated "Prop=Value"
// pairs; split on the FIRST "=" per segment. Malformed segments (no "=") are
// skipped defensively rather than thrown — isVariantName() already gates on
// at least one "=" being present, but a name could mix a malformed segment
// with a valid one.
export function parseVariantName(name) {
  const props = {};
  for (const segment of name.split(",")) {
    const trimmed = segment.trim();
    const eq = trimmed.indexOf("=");
    if (eq === -1) continue;
    const key = trimmed.slice(0, eq).trim();
    const value = trimmed.slice(eq + 1).trim();
    props[key] = value;
  }
  return props;
}

// loadFigmaExport(exportPath) -> {
//   data,            // the raw, validated export
//   sets,            // COMPONENT_SET components, enriched with .properties
//                     // (rawName/displayName added) when setProperties has
//                     // an entry for that set id — absent otherwise, per the
//                     // optional-per-set contract (A3 fills all 171 later)
//   standalones,     // COMPONENT components whose name has no "="
//   variants,         // COMPONENT components whose name contains "=", each
//                     // with .props = parsed {prop: value}
//   variantsByPage,   // variants grouped by their .page
// }
export function loadFigmaExport(exportPath) {
  const schema = readJson(SCHEMA_PATH);
  const data = readJson(exportPath);

  const { valid, errors } = validate(schema, data);
  if (!valid) {
    throw new Error(
      `Invalid figma-export at ${exportPath}:\n${errors.join("\n")}`
    );
  }

  const sets = [];
  const standalones = [];
  const variants = [];
  const variantsByPage = {};

  for (const component of data.components) {
    if (component.type === "COMPONENT_SET") {
      const properties = data.setProperties[component.id];
      if (properties === undefined) {
        sets.push(component);
      } else {
        sets.push({
          ...component,
          properties: properties.map((prop) => ({
            ...prop,
            rawName: prop.name,
            displayName: displayNameOf(prop.name),
          })),
        });
      }
      continue;
    }

    // component.type === "COMPONENT"
    if (isVariantName(component.name)) {
      const variant = { ...component, props: parseVariantName(component.name) };
      variants.push(variant);
      if (!variantsByPage[component.page]) variantsByPage[component.page] = [];
      variantsByPage[component.page].push(variant);
    } else {
      standalones.push(component);
    }
  }

  return { data, sets, standalones, variants, variantsByPage };
}
