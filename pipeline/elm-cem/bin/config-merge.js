// Pure config-merge helpers for `--config-from` (elm-cem.js's injectConfig).
// Split out of elm-cem.js so this logic is directly unit-testable (G1,
// core/elm-cem/research/2026-08-19-generator-consolidation.md §5) without
// racing the CLI's on-exit temp-file cleanup.

function isPlainObject(v) {
  return v !== null && typeof v === "object" && !Array.isArray(v);
}

// Recursive plain-object merge: arrays and scalars are last-wins at any depth;
// plain objects are merged key-by-key, recursing into nested plain objects
// rather than replacing them wholesale.
function deepMergeObject(a, b) {
  const out = { ...a };
  for (const [k, v] of Object.entries(b)) {
    if (isPlainObject(v) && isPlainObject(out[k])) out[k] = deepMergeObject(out[k], v);
    else out[k] = v;
  }
  return out;
}

// Merge a list of `_config` objects (one per --config-from file) into one.
// Top-level keys (component names, or `_`-prefixed meta keys like
// `_iconModule`/`_families`/`_exclude`) are merged via `deepMergeObject` when
// both sides are plain objects, so a nested-object key set by two different
// files (e.g. `_iconModule.package`) is field-merged at every depth rather
// than being replaced wholesale on collision — the bug that silently dropped
// `_iconModule.package.dir` when a second file only set `package.summary`.
// Array-valued top-level keys (`_exclude`) stay last-wins, unaffected.
function deepMergeConfigs(objs) {
  const out = {};
  for (const o of objs) {
    for (const [comp, fields] of Object.entries(o || {})) {
      if (isPlainObject(fields) && isPlainObject(out[comp])) {
        out[comp] = deepMergeObject(out[comp], fields);
      } else {
        out[comp] = fields;
      }
    }
  }
  return out;
}

module.exports = { isPlainObject, deepMergeObject, deepMergeConfigs };
