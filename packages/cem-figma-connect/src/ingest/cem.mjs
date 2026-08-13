// Loader/projector for elm-cem's canonical facts bundle Face B
// (`cem-facts.json`, docs/facts-bundle/schema.json's `faceB`) — the
// structural spine of the whole tool ("CEM as the spine; nothing else can
// answer what CAN exist", plans/01-architecture.md).
//
// M3.a: this module used to parse a raw custom-elements.json itself and
// inline `.d.ts` string-literal-union aliases via the sibling dts-inline.mjs
// port. elm-cem now does both of those (tag reconciliation + `.d.ts` alias
// inlining) upstream of every consumer and publishes the result as Face B,
// so this module's job shrinks to: read that JSON, project it onto the
// small shape the rest of this repo (matcher.mjs, merge.mjs, gap-report.mjs,
// tokens/derive.mjs) already consumes. dts-inline.mjs stays as a tracked,
// still-unit-tested module (test/cem-ingest.test.mjs) — nothing in this
// pipeline calls it anymore.
//
// M5 (R-013) reconsidered this and reaffirmed KEEP, not delete: dts-inline.mjs
// is small (~100 lines), zero-runtime-dep, has no maintenance cost, and is
// still exercised by real (non-synthetic) unit tests against small inline
// fixtures — deleting it would mean deleting that whole test file too, for
// no gain besides a smaller file count. This workspace's standing rule for
// exactly this situation is "when in doubt about uniqueness, keep and flag
// rather than delete." Revisit only if it starts costing something (a dep
// bump it forces, a real bug in dead code, etc.) — line count alone isn't a
// reason.
//
// Zero runtime deps: only node:fs.

import fs from "node:fs";

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

// Pure classifier kept for its own sake (dts-inline.mjs's small-fixture
// tests still exercise it) — no longer part of loadCem's pipeline, since
// Face B already ships a resolved `kind` per attribute. Mirrors elm-cem's
// own classification exactly, applied to a raw (pre-inline) CEM attribute.
const LITERAL = /^("[^"]*"|-?\d+(?:\.\d+)?)$/;
const NULLISH = /^(null|undefined)$/;

function litValue(part) {
  return part[0] === '"' || part[0] === "'" ? part.slice(1, -1) : Number(part);
}

export function classifyAttribute(attr) {
  if (!attr.type || typeof attr.type.text !== "string") return { kind: "none" };

  const text = attr.type.text.trim();
  if (text.includes("=>")) return { kind: "other" };

  const parts = text.split("|").map((p) => p.trim()).filter(Boolean);
  const core = parts.filter((p) => !NULLISH.test(p));
  if (core.length === 0) return { kind: "other" };

  if (core.length === 1 && core[0] === "boolean") return { kind: "boolean" };
  if (core.length === 1 && core[0] === "number") return { kind: "number" };

  if (core.every((p) => LITERAL.test(p))) {
    return { kind: "enum", values: core.map(litValue) };
  }

  if (core.some((p) => p.includes("[]"))) return { kind: "other" };

  if (core.length === 1 && core[0] === "string") return { kind: "string" };
  if (core.every((p) => /^[A-Za-z_$][\w$]*$/.test(p))) return { kind: "string" };

  return { kind: "other" };
}

// Face B's `kind` taxonomy is a superset of the one this loader's consumers
// understand (`enumNumeric` is a numeric-literal-union special case matcher.mjs
// and gap-report.mjs don't need to distinguish from a string enum — both read
// `attr.values` the same way). Collapse it here so every consumer keeps
// matching on the same four buckets it always has: boolean | enum | string |
// number | none | other.
function projectKind(kind) {
  return kind === "enumNumeric" ? "enum" : kind;
}

function buildAttribute(attr) {
  // Face B's `enum` is present for BOTH closed unions (kind enum/enumNumeric)
  // and open ones (kind string, `enum.open: true` — LinkTarget's "known
  // members" list). Consumers (matcher.mjs's enumAttributes()) select on
  // `kind === "enum"`, so only surface `values` when the kind actually is
  // one — otherwise an open union would look like a closed enum axis to
  // any caller that reads `values` without also checking `kind`.
  const isEnumKind = attr.kind === "enum" || attr.kind === "enumNumeric";
  const values = isEnumKind && attr.enum ? attr.enum.values : undefined;
  return {
    name: attr.name,
    fieldName: attr.fieldName ?? null,
    description: attr.description ?? "",
    default: attr.default ?? null,
    type: attr.type ? attr.type.resolved ?? attr.type.raw ?? null : null,
    kind: projectKind(attr.kind),
    ...(values !== undefined ? { values } : {}),
  };
}

function buildComponent(c) {
  return {
    tag: c.tag,
    description: c.description ?? "",
    module: c.modulePath,
    attributes: (c.attributes || []).map(buildAttribute),
    slots: c.slots || [],
    events: c.events || [],
    cssProperties: c.cssProperties || [],
  };
}

// loadCem(bundlePath) -> {
//   components,  // components: tag, description, module, attributes
//                // (classified + resolved value sets), slots, events,
//                // cssProperties — the SAME shape this loader always
//                // returned, now projected from Face B instead of measured
//                // from a raw manifest + a live `.d.ts` scan.
//   dupes,       // tags Face B's own producer-side reconciliation dropped
//                // (faceB.duplicates[].tag) — post-reconciliation, so this
//                // is almost always empty: a genuine duplicate registration,
//                // not an analyzer tagName bug (elm-cem now fixes those
//                // upstream instead of silently merging them).
//   aliases,     // faceB.aliases verbatim — the literal-alias catalog.
//   stats: {
//     totalDeclarations, uniqueTags, totalAttributesRaw, totalAttributes,
//     fullyInlined,
//   },
// }
//
// `opts.log` overrides the dupe-tag logger (default: console.warn). The old
// `opts.dtsDir` no longer applies — Face B is already `.d.ts`-resolved — and
// is accepted-but-ignored so existing call sites that still pass it (profile
// configs carrying a legacy `dtsDir` key) don't need to change in lockstep.
export function loadCem(bundlePath, opts = {}) {
  const { log = (msg) => console.warn(msg) } = opts;

  const faceB = readJson(bundlePath);
  const components = (faceB.components || []).map(buildComponent);
  const totalAttributes = components.reduce((sum, c) => sum + c.attributes.length, 0);
  const dupes = (faceB.duplicates || []).map((d) => d.tag);
  for (const tag of dupes) {
    log(`cem: duplicate tagName "${tag}" — dropped by the facts-bundle producer, keeping "${
      faceB.duplicates.find((d) => d.tag === tag)?.keptDeclarationName ?? "?"
    }"`);
  }

  return {
    components,
    dupes,
    aliases: faceB.aliases || [],
    stats: {
      // Face B is already deduped to unique, authoritative tags — there is
      // no separate "raw declaration count" left to report (faceB.stats
      // .declarations counts ALL scanned class declarations, including
      // non-custom-element ones, so it is not the same figure the old
      // pre-dedupe loader reported here).
      totalDeclarations: components.length,
      uniqueTags: components.length,
      totalAttributesRaw: totalAttributes,
      totalAttributes,
      fullyInlined: faceB.stats?.attributesResolvedFromAlias ?? 0,
    },
  };
}
