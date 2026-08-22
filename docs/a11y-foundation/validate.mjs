#!/usr/bin/env node
// Dependency-free validator for docs/a11y-foundation/composition-rules.json
// against composition-rules.schema.json.
//
// Kept dependency-free on purpose, mirroring
// pipeline/elm-cem-figma-connect/src/lib/validate.mjs: the schema is small,
// closed, and committed alongside the data. This checker supports exactly the
// JSON-Schema keywords the schema uses: type, const, enum, pattern, format
// (date + uri, lightweight), required, properties, additionalProperties,
// patternProperties, minProperties, minItems, items, and $ref/$defs (local
// pointers only). If the schema outgrows this, switch to ajv as a
// devDependency with a compiled-validator step — do not silently add a dep.
//
// Usage: node docs/a11y-foundation/validate.mjs   (exit 0 = valid, 1 = invalid)

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const schema = JSON.parse(readFileSync(join(here, "composition-rules.schema.json"), "utf8"));
const data = JSON.parse(readFileSync(join(here, "composition-rules.json"), "utf8"));

const DATE_RE = /^\d{4}-\d{2}-\d{2}$/;
const URI_RE = /^[a-z][a-z0-9+.-]*:\/\/.+/i;

function typeOf(v) {
  if (v === null) return "null";
  if (Array.isArray(v)) return "array";
  if (Number.isInteger(v)) return "integer-or-number";
  return typeof v;
}
function matchesType(v, t) {
  const a = typeOf(v);
  if (t === "integer") return a === "integer-or-number";
  if (t === "number") return a === "integer-or-number" || typeof v === "number";
  if (t === "object") return a === "object";
  return a === t;
}

function resolveRef(ref) {
  if (!ref.startsWith("#/")) throw new Error("only local $ref supported: " + ref);
  const parts = ref.slice(2).split("/");
  let node = schema;
  for (const p of parts) node = node[p.replace(/~1/g, "/").replace(/~0/g, "~")];
  if (node === undefined) throw new Error("unresolved $ref: " + ref);
  return node;
}

function validate(s, v, path, errors) {
  if (s == null) return;
  if (s.$ref) return validate(resolveRef(s.$ref), v, path, errors);

  if (s.type !== undefined) {
    const types = Array.isArray(s.type) ? s.type : [s.type];
    if (!types.some((t) => matchesType(v, t))) {
      errors.push(`${path}: expected type ${types.join("|")}, got ${typeOf(v)}`);
      return;
    }
  }
  if (s.const !== undefined && v !== s.const) errors.push(`${path}: expected const ${JSON.stringify(s.const)}`);
  if (s.enum !== undefined && !s.enum.includes(v)) errors.push(`${path}: ${JSON.stringify(v)} not in enum`);
  if (s.pattern !== undefined && typeof v === "string" && !new RegExp(s.pattern).test(v))
    errors.push(`${path}: ${JSON.stringify(v)} fails pattern ${s.pattern}`);
  if (s.format === "date" && typeof v === "string" && !DATE_RE.test(v)) errors.push(`${path}: not a date`);
  if (s.format === "uri" && typeof v === "string" && !URI_RE.test(v)) errors.push(`${path}: not a uri`);

  if (typeOf(v) === "object") {
    if (Array.isArray(s.required)) for (const k of s.required) if (!(k in v)) errors.push(`${path}: missing required "${k}"`);
    if (typeof s.minProperties === "number" && Object.keys(v).length < s.minProperties)
      errors.push(`${path}: fewer than ${s.minProperties} properties`);
    const props = s.properties || {};
    const patterns = Object.entries(s.patternProperties || {}).map(([re, sub]) => [new RegExp(re), sub]);
    for (const [k, val] of Object.entries(v)) {
      const kp = `${path}/${k}`;
      if (props[k] !== undefined) validate(props[k], val, kp, errors);
      else {
        const pm = patterns.find(([re]) => re.test(k));
        if (pm) validate(pm[1], val, kp, errors);
        else if (s.additionalProperties === false) errors.push(`${kp}: additional property not allowed`);
      }
    }
  }

  if (Array.isArray(v)) {
    if (typeof s.minItems === "number" && v.length < s.minItems) errors.push(`${path}: fewer than ${s.minItems} items`);
    if (s.items) v.forEach((el, i) => validate(s.items, el, `${path}[${i}]`, errors));
  }
}

const errors = [];
validate(schema, data, "$", errors);
if (errors.length) {
  console.error("composition-rules.json INVALID against schema:");
  for (const e of errors) console.error("  - " + e);
  process.exit(1);
}
console.log("composition-rules.json OK — validates against composition-rules.schema.json");
