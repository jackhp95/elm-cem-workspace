// validate-facts-bundle.js — a hand-rolled subset of JSON Schema draft-07,
// just large enough to check a facts bundle against
// docs/facts-bundle/schema.json. No dependency (no ajv): the schema is small,
// fixed, and owned by this monorepo — a general-purpose validator would be a
// lot of surface area for four keywords.
//
// Supported subset: type (string or array-of-strings, incl. "null"), const,
// enum, required, properties, additionalProperties (bool or schema), items
// (schema), and `$ref` to `#/definitions/<Name>` or `#`.
//
// Not supported (schema.json does not use them): oneOf/anyOf/allOf, pattern,
// format, minimum/maximum, patternProperties.

function resolveRef(ref, root) {
  if (ref === "#" || ref === "#/") return root;
  const m = ref.match(/^#\/definitions\/(.+)$/);
  if (!m) throw new Error(`validate-facts-bundle: unsupported $ref ${ref}`);
  const def = root.definitions && root.definitions[m[1]];
  if (!def) throw new Error(`validate-facts-bundle: $ref ${ref} does not resolve`);
  return def;
}

function typeOf(value) {
  if (value === null) return "null";
  if (Array.isArray(value)) return "array";
  return typeof value; // "string" | "number" | "boolean" | "object" | "undefined"
}

function typeMatches(expected, value) {
  const actual = typeOf(value);
  if (expected === "integer") return actual === "number" && Number.isInteger(value);
  if (expected === "number") return actual === "number";
  return actual === expected;
}

/**
 * Validate `value` against `schema` (rooted at `root` for `$ref` resolution).
 * Returns a list of human-readable error strings; empty means valid.
 */
function validateAgainst(schema, value, root, pathStr) {
  if (schema.$ref) {
    return validateAgainst(resolveRef(schema.$ref, root), value, root, pathStr);
  }

  const errors = [];

  if (schema.const !== undefined && value !== schema.const) {
    errors.push(`${pathStr}: expected const ${JSON.stringify(schema.const)}, got ${JSON.stringify(value)}`);
  }

  if (schema.enum && !schema.enum.includes(value)) {
    errors.push(`${pathStr}: ${JSON.stringify(value)} is not one of ${JSON.stringify(schema.enum)}`);
  }

  if (schema.type !== undefined) {
    const expectedTypes = Array.isArray(schema.type) ? schema.type : [schema.type];
    if (!expectedTypes.some((t) => typeMatches(t, value))) {
      errors.push(`${pathStr}: expected type ${JSON.stringify(schema.type)}, got ${typeOf(value)}`);
      return errors; // further structural checks are meaningless on a type mismatch
    }
  }

  if (value === null || value === undefined) return errors;

  if (schema.type === "object" || (schema.properties && typeOf(value) === "object")) {
    for (const key of schema.required || []) {
      if (!(key in value)) errors.push(`${pathStr}: missing required property "${key}"`);
    }
    const props = schema.properties || {};
    for (const key of Object.keys(value)) {
      if (key in props) {
        errors.push(...validateAgainst(props[key], value[key], root, `${pathStr}.${key}`));
      } else if (schema.additionalProperties === false) {
        errors.push(`${pathStr}: unexpected property "${key}" (additionalProperties: false)`);
      } else if (schema.additionalProperties && typeof schema.additionalProperties === "object") {
        errors.push(...validateAgainst(schema.additionalProperties, value[key], root, `${pathStr}.${key}`));
      }
    }
  }

  if (schema.type === "array" && Array.isArray(value) && schema.items) {
    value.forEach((item, i) => {
      errors.push(...validateAgainst(schema.items, item, root, `${pathStr}[${i}]`));
    });
  }

  return errors;
}

/**
 * Validate a full bundle `{ schemaVersion, faceB, faceC }` against
 * `schema` (the parsed docs/facts-bundle/schema.json). Pass `definition` to
 * validate a single face's own object (e.g. "faceB") against its
 * `#/definitions/<definition>` instead of the whole bundle.
 */
function validate(schema, data, definition) {
  const rootSchema = definition ? resolveRef(`#/definitions/${definition}`, schema) : schema;
  const errors = validateAgainst(rootSchema, data, schema, "$");
  return { valid: errors.length === 0, errors };
}

/**
 * Validate a `brand-facts.json` document (schemaVersion 2) against
 * `#/definitions/brandFacts`. Sugar for `validate(schema, data,
 * "brandFacts")` — the spelling every schemaVersion-2 caller (the future
 * producer, check-drift, gate-all) should use instead of repeating the
 * definition-name string.
 */
function validateBrandFacts(schema, data) {
  return validate(schema, data, "brandFacts");
}

module.exports = { validate, validateBrandFacts };
