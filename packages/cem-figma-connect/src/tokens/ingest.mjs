// Loader/normalizer for the kit token dump (Task D1) — the token-side ingest,
// analogous to src/ingest/cem.mjs and src/ingest/figma.mjs (plans/01-architecture.md
// §1, §7 "D — tokens"). Loads research/figma-dumps/kit-variables.json (304
// variables, 4 collections, 32 M3 modes) and research/figma-dumps/kit-styles.json
// (30 TEXT styles), and normalizes both into one shared record shape:
//
//   { id, name, family, collection, type, valuesByModeName, aliasOf?, codeSyntax }
//
// PROBED SHAPE (2026-07-11, `jq '.collections[0], .variables[0]' research/
// figma-dumps/kit-variables.json`) — deliberately different from what
// src/ingest/figma-export.schema.json's "variables" sub-object assumes (that
// schema describes the merged, forward-designed figma-export.json artifact;
// this file ingests the RAW per-file dump directly, per the D1 brief):
//   - collections[].modes[] key is `modeId`, not `id`.
//   - variables[].type carries the resolved type (COLOR|FLOAT|STRING|BOOLEAN);
//     there is NO `resolvedType` field in the raw dump (measured: 0/304 have
//     it — the brief's "resolvedType" reference was aspirational, not real).
//   - variables[].valuesByMode is keyed by modeId; an aliasing variable's
//     value is `{ type: "VARIABLE_ALIAS", id }` instead of a terminal value.
//
// Zero new deps: reuses src/lib/validate.mjs (schema) and src/lib/order.mjs
// (ordinal sort, for determinism) — see plans/01-architecture.md §4.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { validate } from "../lib/validate.mjs";
import { byKey } from "../lib/order.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const VARIABLES_SCHEMA_PATH = path.join(here, "kit-variables.schema.json");
const STYLES_SCHEMA_PATH = path.join(here, "kit-styles.schema.json");

// Modes of record (D1 Step 3): every variable whose OWN collection defines
// these modes MUST resolve both to a defined terminal value. The 13 hue
// themes + contrast tiers (26 more M3 modes) parse into valuesByModeName same
// as any other mode, but are audit-only — never asserted here.
export const MODES_OF_RECORD = ["Light", "Dark"];

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

function validateOrThrow(schema, data, label) {
  const { valid, errors } = validate(schema, data);
  if (!valid) {
    throw new Error(`Invalid ${label}:\n${errors.join("\n")}`);
  }
}

// family = first "/"-separated path segment of a variable/style name, e.g.
// "Schemes/On Surface" -> "Schemes", "State Layers/Primary/Opacity-08" ->
// "State Layers". Measured split (2026-07-11): Schemes 49, State Layers 147,
// Static 95, Corner 10, Tracking 2, Add-ons 1 = 304 total.
export function familyOf(name) {
  return name.split("/")[0];
}

// resolveModeValue(variableId, modeName, ...) -> the TERMINAL value for one
// (variable, mode name) pair, following VARIABLE_ALIAS chains across
// collections (aliasing crosses collection boundaries in the real dump: e.g.
// a Typescale/"Baseline"-mode variable aliases a Font theme variable, whose
// own collection has Baseline+Wireframe — matched by mode NAME, since mode
// ids are collection-local and do not line up across collections).
//
// Returns undefined if: the variable doesn't exist (dangling alias), the
// variable's own collection has no mode with this name, or that mode has no
// entry in valuesByMode. Throws on a cycle (guards against a manufactured or
// future circular alias chain — none exist in the measured dump).
function resolveModeValue(variableId, modeName, byId, collectionsById, visited) {
  if (visited.has(variableId)) {
    const chain = [...visited, variableId].join(" -> ");
    throw new Error(`kit-variables: alias cycle detected resolving mode "${modeName}": ${chain}`);
  }

  const variable = byId.get(variableId);
  if (!variable) return undefined; // dangling alias target

  const collection = collectionsById.get(variable.collectionId);
  const mode = collection?.modes.find((m) => m.name === modeName);
  if (!mode) return undefined; // this variable's own collection has no such mode

  const raw = variable.valuesByMode[mode.modeId];
  if (raw === undefined) return undefined;

  if (raw && typeof raw === "object" && raw.type === "VARIABLE_ALIAS") {
    const nextVisited = new Set(visited);
    nextVisited.add(variableId);
    return resolveModeValue(raw.id, modeName, byId, collectionsById, nextVisited);
  }

  return raw;
}

// immediateAliasOf(variable) -> the raw (un-chased) VARIABLE_ALIAS target(s)
// declared directly on this variable, or undefined if it isn't an alias in
// any mode. Measured reality: every aliasing variable in the dump (45, all
// `Static/*`) has exactly one mode and aliases exactly one target, so the
// common case returns a plain string id. If a future dump ever varies the
// alias target per mode, this degrades to a {modeName: targetId} map instead
// of silently picking one and losing the rest.
function immediateAliasOf(variable, collection) {
  const targetsByModeName = new Map();
  for (const mode of collection.modes) {
    const raw = variable.valuesByMode[mode.modeId];
    if (raw && typeof raw === "object" && raw.type === "VARIABLE_ALIAS") {
      targetsByModeName.set(mode.name, raw.id);
    }
  }
  if (targetsByModeName.size === 0) return undefined;

  const distinctTargets = new Set(targetsByModeName.values());
  if (distinctTargets.size === 1) return [...distinctTargets][0];
  return Object.fromEntries(targetsByModeName);
}

// normalizeVariables(data) -> normalized variable[] from an already-parsed +
// already-validated kit-variables.json shape ({collections, variables}).
// Pure (no filesystem access) so cycle-guard / alias-resolution behavior can
// be tested directly against small in-memory fixtures, per the D1 brief's
// "guard against cycles" requirement (no real cycle exists in the measured
// dump — this is defensive).
export function normalizeVariables(data) {
  const collectionsById = new Map(data.collections.map((c) => [c.id, c]));
  const byId = new Map(data.variables.map((v) => [v.id, v]));

  const normalized = data.variables.map((variable) => {
    const collection = collectionsById.get(variable.collectionId);
    if (!collection) {
      throw new Error(
        `kit-variables: variable "${variable.name}" (${variable.id}) references unknown collectionId "${variable.collectionId}"`
      );
    }

    const valuesByModeName = {};
    for (const mode of collection.modes) {
      valuesByModeName[mode.name] = resolveModeValue(
        variable.id,
        mode.name,
        byId,
        collectionsById,
        new Set()
      );
    }

    const aliasOf = immediateAliasOf(variable, collection);

    return {
      id: variable.id,
      name: variable.name,
      family: familyOf(variable.name),
      collection: collection.name,
      type: variable.type,
      valuesByModeName,
      ...(aliasOf !== undefined ? { aliasOf } : {}),
      codeSyntax: variable.codeSyntax,
    };
  });

  // Determinism (architecture ground rule): sort by id with the shared
  // ordinal comparator rather than relying on source-file array order.
  normalized.sort(byKey((v) => v.id));
  return normalized;
}

// assertModesOfRecord(variables) -> throws if any variable whose own
// collection defines a mode of record (Light/Dark — only the M3 collection
// does: Schemes/State Layers/Add-ons, 197 variables) fails to resolve either
// one to a defined terminal value. Variables from collections that don't
// define Light/Dark at all (Static/Corner/Tracking, via Font theme/
// Typescale/Shape) are out of scope and silently skipped — they have no
// Light/Dark modes to assert in the first place.
export function assertModesOfRecord(variables, modes = MODES_OF_RECORD) {
  for (const variable of variables) {
    const inScope = modes.some((m) => m in variable.valuesByModeName);
    if (!inScope) continue;

    for (const modeName of modes) {
      if (!(modeName in variable.valuesByModeName)) {
        throw new Error(
          `kit-variables: variable "${variable.name}" (family ${variable.family}) is missing mode of record "${modeName}"`
        );
      }
      if (variable.valuesByModeName[modeName] === undefined) {
        throw new Error(
          `kit-variables: variable "${variable.name}" (family ${variable.family}) failed to resolve mode of record "${modeName}" to a terminal value`
        );
      }
    }
  }
}

// loadKitVariables(variablesPath) -> { data, collections, variables }
//   data         the raw, validated kit-variables.json
//   collections  data.collections, pass-through (id/name/defaultModeId/modes/variableCount)
//   variables    normalizeVariables(data) output, with Light/Dark asserted
export function loadKitVariables(variablesPath) {
  const schema = readJson(VARIABLES_SCHEMA_PATH);
  const data = readJson(variablesPath);
  validateOrThrow(schema, data, `kit-variables dump at ${variablesPath}`);

  const variables = normalizeVariables(data);
  assertModesOfRecord(variables);

  return { data, collections: data.collections, variables };
}

// normalizeTextStyles(data) -> normalized style[] from an already-parsed +
// already-validated kit-styles.json shape ({paintStyles, textStyles,
// effectStyles}). Only textStyles are normalized (D1 Step 4); paintStyles/
// effectStyles are out of scope. Tagged family: "style:text" per the brief
// (a literal tag, not derived from the style's own "/"-segmented name —
// typescale lives in BOTH variables (Static/*) AND text styles; the family
// tag is what lets downstream code tell the two apart while keeping both).
export function normalizeTextStyles(data) {
  const styles = data.textStyles.map((style) => ({
    id: style.id,
    name: style.name,
    family: "style:text",
    collection: null,
    type: "TEXT",
    valuesByModeName: {
      // Text styles carry no Figma "mode" concept (unlike variables) — a
      // single synthetic "Default" mode name keeps the shared record shape
      // (valuesByModeName) uniform across variables and styles.
      Default: {
        fontFamily: style.fontName.family,
        fontStyle: style.fontName.style,
        fontSize: style.fontSize,
      },
    },
    codeSyntax: {},
  }));

  styles.sort(byKey((s) => s.id));
  return styles;
}

// loadKitTextStyles(stylesPath) -> { data, styles }
export function loadKitTextStyles(stylesPath) {
  const schema = readJson(STYLES_SCHEMA_PATH);
  const data = readJson(stylesPath);
  validateOrThrow(schema, data, `kit-styles dump at ${stylesPath}`);

  return { data, styles: normalizeTextStyles(data) };
}

// loadKitTokens({variablesPath, stylesPath}) -> the combined ingest:
//   { collections, variables, styles, all }
// `all` concatenates variables + styles (still sorted within each group by
// id) — the single list downstream tasks (D2's token correspondence table)
// iterate when the split doesn't matter.
export function loadKitTokens({ variablesPath, stylesPath }) {
  const { collections, variables } = loadKitVariables(variablesPath);
  const { styles } = loadKitTextStyles(stylesPath);
  return { collections, variables, styles, all: [...variables, ...styles] };
}
