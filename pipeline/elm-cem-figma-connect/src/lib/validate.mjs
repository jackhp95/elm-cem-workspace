// Hand-rolled JSON-schema validator (subset).
//
// Kept dependency-free on purpose: our schemas are small, closed, and
// stable, and this checker is enough to enforce them. If schema needs
// outgrow it (conditionals, $ref, oneOf/anyOf, formats), switch to ajv as a
// **devDependency** with a compiled-validator build step — not before. Do
// not "helpfully" add ajv to fix a gap here; extend this file instead.
//
// Supported keywords: type, enum, required, properties, additionalProperties,
// items.

function typeOf(value) {
  if (value === null) return "null";
  if (Array.isArray(value)) return "array";
  return typeof value; // "string" | "number" | "boolean" | "object" | "undefined"
}

function matchesType(value, type) {
  const actual = typeOf(value);
  if (type === "integer") return actual === "number" && Number.isInteger(value);
  return actual === type;
}

function deepEqual(a, b) {
  if (a === b) return true;
  if (typeof a !== typeof b) return false;
  if (a && b && typeof a === "object") {
    const aKeys = Object.keys(a);
    const bKeys = Object.keys(b);
    if (aKeys.length !== bKeys.length) return false;
    return aKeys.every((key) => deepEqual(a[key], b[key]));
  }
  return false;
}

function validateNode(schema, value, path, errors) {
  if (schema === undefined || schema === null) return;

  if (schema.type !== undefined) {
    const types = Array.isArray(schema.type) ? schema.type : [schema.type];
    if (!types.some((type) => matchesType(value, type))) {
      errors.push(
        `${path || "(root)"}: expected type ${types.join(" | ")}, got ${typeOf(value)}`
      );
      return; // further checks on this node would just be noise
    }
  }

  if (schema.enum !== undefined) {
    if (!schema.enum.some((allowed) => deepEqual(allowed, value))) {
      errors.push(
        `${path || "(root)"}: ${JSON.stringify(value)} not in enum ${JSON.stringify(schema.enum)}`
      );
    }
  }

  if (typeOf(value) === "object") {
    if (schema.required) {
      for (const key of schema.required) {
        if (!(key in value)) {
          errors.push(`${path || "(root)"}: missing required property "${key}"`);
        }
      }
    }

    const knownKeys = schema.properties ? Object.keys(schema.properties) : [];

    if (schema.properties) {
      for (const key of knownKeys) {
        if (key in value) {
          validateNode(schema.properties[key], value[key], `${path}/${key}`, errors);
        }
      }
    }

    if (schema.additionalProperties === false) {
      for (const key of Object.keys(value)) {
        if (!knownKeys.includes(key)) {
          errors.push(`${path || "(root)"}: unexpected additional property "${key}"`);
        }
      }
    } else if (
      schema.additionalProperties &&
      typeof schema.additionalProperties === "object"
    ) {
      for (const key of Object.keys(value)) {
        if (!knownKeys.includes(key)) {
          validateNode(schema.additionalProperties, value[key], `${path}/${key}`, errors);
        }
      }
    }
  }

  if (typeOf(value) === "array" && schema.items) {
    value.forEach((item, index) => {
      validateNode(schema.items, item, `${path}/${index}`, errors);
    });
  }
}

// validate(schema, data) -> { valid: boolean, errors: string[] }
export function validate(schema, data) {
  const errors = [];
  validateNode(schema, data, "", errors);
  return { valid: errors.length === 0, errors };
}
