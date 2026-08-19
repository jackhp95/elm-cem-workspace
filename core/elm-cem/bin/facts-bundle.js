// facts-bundle.js — Face B (`cem-facts.json`) builder, and the small amount of
// provenance-stamping shared by Face C.
//
// M1.c: elm-cem is the one tool that already reconciles tags and inlines
// `.d.ts` enum unions (bin/elm-cem.js's reconcileTagNames/recordTypeAliases).
// This module turns that same, already-computed state into the Face B object
// docs/facts-bundle/schema.json specifies, plus the alias catalog those two
// passes don't themselves need to keep (they only need the RESOLVED string).
//
// Kept dependency-free (no ajv, no ts-morph): the manifest is already JSON,
// and the small amount of TypeScript-source scanning below is a regex, the
// same technique bin/elm-cem.js already uses for the Face-A pipeline.

const fs = require("fs");
const path = require("path");

const SCHEMA_VERSION = 1;

// ---------------------------------------------------------------------------
// Alias catalog (Face B `faceB.aliases[]`)
//
// Unlike bin/elm-cem.js's `collectLiteralAliases` (which only records CLOSED
// literal unions, because those are the only ones Face A ever turns into an
// Elm enum), Face B must ALSO carry OPEN unions (`LinkTarget`-shaped: some
// literal members plus a `(string & {})` or bare `string` tail) — see
// docs/facts-bundle/coverage-audit.md §5.2. This is therefore a separate,
// slightly richer scan over the same `.d.ts` tree, not a reuse of the Face-A
// pass (which must stay untouched to keep the A/B bar green).
// ---------------------------------------------------------------------------

function stripTsComments(src) {
  return src.replace(/\/\*[\s\S]*?\*\//g, "").replace(/\/\/[^\n]*/g, "");
}

function dtsFiles(dir) {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...dtsFiles(full));
    else if (entry.name.endsWith(".d.ts")) out.push(full);
  }
  return out;
}

// Split a TS union body on top-level `|` (not inside `()`/`{}`/`[]`/`<>`).
function splitUnionTopLevel(body) {
  const parts = [];
  let depth = 0;
  let cur = "";
  for (const ch of body) {
    if ("({[<".includes(ch)) depth++;
    if (")}]>".includes(ch)) depth--;
    if (ch === "|" && depth === 0) {
      parts.push(cur.trim());
      cur = "";
    } else {
      cur += ch;
    }
  }
  if (cur.trim()) parts.push(cur.trim());
  return parts;
}

function parseLiteral(part) {
  const str = part.match(/^"((?:[^"\\]|\\.)*)"$/) || part.match(/^'((?:[^'\\]|\\.)*)'$/);
  if (str) return { literal: true, value: str[1] };
  if (/^-?\d+(?:\.\d+)?$/.test(part)) return { literal: true, value: Number(part) };
  return { literal: false };
}

// Every `type X = <union>` alias in `rootDir`'s `.d.ts` tree that contributes
// at least one literal member, closed or open. `const`-object enums (the
// FAST/Fluent shape bin/elm-cem.js's collectLiteralAliases also harvests) are
// included too, always closed (a const-object enum has no open tail by
// construction).
function collectAliasCatalog(rootDir) {
  const typeRe = /\b(?:export\s+)?(?:declare\s+)?type\s+([A-Za-z_$][\w$]*)\s*=\s*([^;]+);/g;
  const constRe = /\b(?:export\s+)?(?:declare\s+)?const\s+([A-Za-z_$][\w$]*)\s*:\s*\{([^{}]*)\}/g;
  const member = `(?:"[^"]*"|'[^']*'|-?\\d+(?:\\.\\d+)?)`;
  const constMemberRe = new RegExp(`(?:readonly\\s+)?[A-Za-z_$][\\w$]*\\s*:\\s*(${member})\\s*;?`, "g");

  const byName = new Map(); // name -> entry; a `type` alias overwrites a `const`-object of the same name.

  for (const file of dtsFiles(rootDir)) {
    let src;
    try {
      src = fs.readFileSync(file, "utf8");
    } catch {
      continue;
    }
    src = stripTsComments(src);
    const relFile = path.relative(rootDir, file);

    let m;
    typeRe.lastIndex = 0;
    while ((m = typeRe.exec(src))) {
      const name = m[1];
      const body = m[2].replace(/\s+/g, " ").trim();
      const parts = splitUnionTopLevel(body.replace(/^\|\s*/, ""));
      const values = [];
      let open = false;
      for (const p of parts) {
        const lit = parseLiteral(p);
        if (lit.literal) values.push(lit.value);
        else if (p !== "undefined" && p !== "null") open = true;
      }
      if (values.length === 0) continue; // not enum-like (an interface/object/function alias)
      const union = parts
        .map((p) => {
          const lit = parseLiteral(p);
          return lit.literal ? JSON.stringify(lit.value) : p;
        })
        .join(" | ");
      byName.set(name, { name, union, values, closed: !open, source: "dts", file: relFile });
    }

    let cm;
    constRe.lastIndex = 0;
    while ((cm = constRe.exec(src))) {
      const name = cm[1];
      if (byName.has(name)) continue; // shape-1 (type alias) wins over shape-2 (const-object)
      const body = cm[2];
      const values = [];
      let mm;
      constMemberRe.lastIndex = 0;
      while ((mm = constMemberRe.exec(body))) {
        const lit = parseLiteral(mm[1]);
        if (lit.literal) values.push(lit.value);
      }
      const remainder = body.replace(constMemberRe, "").replace(/[\s;,]/g, "");
      if (values.length > 0 && remainder === "") {
        const union = [...new Set(values)].map((v) => JSON.stringify(v)).join(" | ");
        byName.set(name, { name, union, values: [...new Set(values)], closed: true, source: "const-object", file: relFile });
      }
    }
  }

  return [...byName.values()].sort((a, b) => a.name.localeCompare(b.name));
}

// Resolve a CEM `type.text` against the alias catalog (by exact whole-part
// name match, same convention as bin/elm-cem.js's resolveAlias). Returns the
// faceBTypeInfo + optional faceBAttribute.enum shape.
function resolveType(typeText, catalogByName) {
  if (typeText == null) {
    return { typeInfo: { raw: null, resolved: null, parsed: null, aliasName: null, source: "cem" }, enumInfo: null };
  }
  const parts = typeText.split("|").map((s) => s.trim());
  const aliasPart = parts.find((p) => catalogByName.has(p));
  if (!aliasPart) {
    const inline = inlineUnion(typeText);
    return {
      typeInfo: { raw: typeText, resolved: typeText, parsed: null, aliasName: null, source: "cem" },
      enumInfo: inline,
    };
  }
  const alias = catalogByName.get(aliasPart);
  const resolvedParts = parts.map((p) => (p === aliasPart ? alias.union : p));
  return {
    typeInfo: {
      raw: typeText,
      resolved: resolvedParts.join(" | "),
      parsed: null,
      aliasName: aliasPart,
      source: "dts-alias",
    },
    enumInfo: { values: alias.values, open: !alias.closed },
  };
}

// An inline literal union already spelled out in the CEM's own `type.text`
// (no alias indirection) — e.g. `"filled" | "tonal"`.
function inlineUnion(typeText) {
  if (!typeText.includes("|") && !/^"[^"]*"$/.test(typeText) && !/^-?\d+(?:\.\d+)?$/.test(typeText)) return null;
  const parts = splitUnionTopLevel(typeText);
  const values = [];
  let open = false;
  for (const p of parts) {
    const lit = parseLiteral(p);
    if (lit.literal) values.push(lit.value);
    else if (p !== "undefined" && p !== "null") open = true;
  }
  if (values.length === 0) return null;
  return { values, open };
}

function classifyKind(typeText, enumInfo) {
  if (typeText == null) return "none";
  if (typeText === "boolean") return "boolean";
  if (typeText === "number") return "number";
  if (!enumInfo) return typeText === "string" ? "string" : "other";
  if (enumInfo.open) return "string";
  return enumInfo.values.every((v) => typeof v === "number") ? "enumNumeric" : "enum";
}

// ---------------------------------------------------------------------------
// Face B component projection
// ---------------------------------------------------------------------------

function buildAttribute(raw, catalogByName) {
  const typeText = raw.type ? raw.type.text : null;
  const { typeInfo, enumInfo } = resolveType(typeText, catalogByName);
  // The analyzer's own expansion, when present, is a DIFFERENT reading from
  // our dts-alias resolution — keep both, preferring the alias resolution as
  // `resolved` only when the alias fired; else fall back to parsedType.
  if (raw.parsedType && typeof raw.parsedType.text === "string") {
    typeInfo.parsed = raw.parsedType.text;
    if (typeInfo.source === "cem" && typeInfo.resolved === typeInfo.raw) {
      typeInfo.resolved = raw.parsedType.text;
      typeInfo.source = "cem-parsedType";
    }
  }
  const kind = classifyKind(typeText, enumInfo);
  return {
    name: raw.name,
    fieldName: raw.fieldName || null,
    description: raw.description || null,
    default: raw.default !== undefined ? raw.default : null,
    deprecated: raw.deprecated !== undefined ? raw.deprecated : null,
    kind,
    type: typeInfo,
    enum: enumInfo ? { values: enumInfo.values, open: enumInfo.open } : null,
  };
}

function buildProperty(raw, catalogByName) {
  const typeText = raw.type ? raw.type.text : null;
  const { typeInfo } = resolveType(typeText, catalogByName);
  if (raw.parsedType && typeof raw.parsedType.text === "string") {
    typeInfo.parsed = raw.parsedType.text;
  }
  return {
    name: raw.name,
    kind: raw.kind === "method" ? "method" : "field",
    privacy: raw.privacy || null,
    static: raw.static !== undefined ? raw.static : null,
    readonly: raw.readonly !== undefined ? raw.readonly : null,
    description: raw.description || null,
    default: raw.default !== undefined ? raw.default : null,
    type: typeInfo,
    attribute: raw.attribute || null,
    inheritedFrom: raw.inheritedFrom && raw.inheritedFrom.name ? raw.inheritedFrom.name : null,
  };
}

// Reconciled component list + duplicates[], from a CEM already post-
// reconcileTagNames (bin/elm-cem.js overwrote decl.tagName with the
// registration-export truth in place). Grouping here is what recovers a
// dedupe DECISION rather than a silent drop (coverage-audit.md §5.5).
function reconcileAndDedupe(cem) {
  const byTag = new Map();
  const duplicates = [];
  for (const m of cem.modules || []) {
    for (const decl of m.declarations || []) {
      if (!decl.customElement || !decl.tagName) continue;
      const tag = decl.tagName;
      if (!byTag.has(tag)) {
        byTag.set(tag, { decl, modulePath: m.path });
      } else {
        const kept = byTag.get(tag);
        duplicates.push({
          tag,
          declarationName: decl.name,
          modulePath: m.path,
          keptDeclarationName: kept.decl.name,
        });
      }
    }
  }
  return { byTag, duplicates };
}

// The tag-reconciliation report: registration-export count + which
// declarations carried a WRONG jsdoc tag. Computed against the ORIGINAL
// (pre-reconciliation) CEM, because bin/elm-cem.js's reconcileTagNames
// overwrites `decl.tagName` with the registration truth in place — the
// mismatch is only visible before that pass runs.
function tagReconciliationFromOriginal(origCem) {
  let definitionCount = 0;
  const mismatches = [];
  const findDeclaration = (declName, declModule) => {
    if (declModule) {
      const mm = (origCem.modules || []).find((m) => m.path === declModule);
      if (mm) {
        const d = (mm.declarations || []).find((x) => x.name === declName);
        if (d) return { decl: d, modulePath: mm.path };
      }
    }
    for (const m of origCem.modules || []) {
      const d = (m.declarations || []).find((x) => x.name === declName);
      if (d) return { decl: d, modulePath: m.path };
    }
    return null;
  };
  for (const m of origCem.modules || []) {
    for (const e of m.exports || []) {
      if (e.kind !== "custom-element-definition") continue;
      definitionCount++;
      const declName = e.declaration && e.declaration.name;
      const tag = e.name;
      if (!declName || !tag) continue;
      const found = findDeclaration(declName, e.declaration.module);
      if (!found || !found.decl.customElement) continue;
      if (found.decl.tagName !== tag) {
        mismatches.push({
          declarationName: declName,
          declarationModule: found.modulePath,
          declaredTagName: found.decl.tagName || null,
          registrationTag: tag,
          componentDir: found.modulePath ? found.modulePath.split("/")[1] || null : null,
        });
      }
    }
  }
  return { definitionCount, mismatches };
}

function componentDirOf(modulePath) {
  const segs = (modulePath || "").split("/");
  return segs.length > 1 ? segs[1] : null;
}

function buildComponent(decl, modulePath, catalogByName) {
  const attributes = (decl.attributes || []).map((a) => buildAttribute(a, catalogByName));
  const properties = (decl.members || [])
    .filter((mem) => mem.kind === "field" || mem.kind === "method")
    .map((p) => buildProperty(p, catalogByName));
  return {
    tag: decl.tagName,
    declarationName: decl.name,
    modulePath,
    sourceFile: modulePath,
    componentDir: componentDirOf(modulePath),
    description: decl.description || null,
    summary: decl.description ? decl.description.split("\n")[0] : null,
    deprecated: decl.deprecated !== undefined ? decl.deprecated : null,
    superclass: decl.superclass
      ? { name: decl.superclass.name, module: decl.superclass.module || null, package: decl.superclass.package || null }
      : null,
    attributes,
    properties,
    slots: (decl.slots || []).map((s) => ({ name: s.name || "", description: s.description || null })),
    events: (decl.events || [])
      .filter((e) => !!e.name)
      .map((e) => ({
        name: e.name,
        description: e.description || null,
        type: e.type ? resolveType(e.type.text, catalogByName).typeInfo : { raw: null, resolved: null, parsed: null, aliasName: null, source: "cem" },
      })),
    cssProperties: (decl.cssProperties || []).map((c) => ({
      name: c.name,
      description: c.description || null,
      default: c.default !== undefined ? c.default : null,
      syntax: c.syntax || null,
    })),
    cssParts: (decl.cssParts || []).map((c) => ({ name: c.name, description: c.description || null })),
    cssStates: (decl.cssStates || []).map((c) => ({ name: c.name, description: c.description || null })),
  };
}

// The producer-side degradation assertion coverage-audit.md §5.2 calls for: a
// `.d.ts`-less publish must be a visible stat collapse, not a silent one.
function computeStats(cem, components, catalog, dtsFileCount) {
  let attributes = 0;
  let enumAttributes = 0;
  let openUnionAttributes = 0;
  let attributesResolvedFromAlias = 0;
  let cssProperties = 0;
  for (const c of components) {
    attributes += c.attributes.length;
    cssProperties += c.cssProperties.length;
    for (const a of c.attributes) {
      if (a.kind === "enum" || a.kind === "enumNumeric") enumAttributes++;
      if (a.enum && a.enum.open) openUnionAttributes++;
      if (a.type.source === "dts-alias") attributesResolvedFromAlias++;
    }
  }
  return {
    declarations: (cem.modules || []).reduce((n, m) => n + (m.declarations || []).length, 0),
    components: components.length,
    attributes,
    enumAttributes,
    openUnionAttributes,
    aliasesCollected: catalog.length,
    attributesResolvedFromAlias,
    cssProperties,
    dtsFilesScanned: dtsFileCount,
  };
}

/**
 * Build the Face B object from:
 *  - `cem` — the CEM AFTER bin/elm-cem.js's reconcileTagNames +
 *    recordTypeAliases have run (tags are authoritative; enum-alias `type.text`
 *    is already inlined for the Elm pipeline — Face B recomputes its OWN
 *    resolution from `origCem` + the alias catalog, so it isn't coupled to
 *    Face A's temp-file rewriting).
 *  - `origCem` — the CEM exactly as read from disk, before any rewriting pass,
 *    used only to detect tag-reconciliation MISMATCHES (the wrong declared tag
 *    is only visible pre-rewrite).
 *  - `opts.dtsDir` — root the `.d.ts` alias catalog is scanned from.
 *  - `opts.provenance` — the faceBProvenance object (built by the CLI, which
 *    knows package/version/paths the manifest itself does not).
 */
function buildFaceB(cem, origCem, opts) {
  const catalog = collectAliasCatalog(opts.dtsDir);
  const catalogByName = new Map(catalog.map((a) => [a.name, a]));

  const { byTag, duplicates } = reconcileAndDedupe(cem);
  const components = [...byTag.entries()]
    .map(([, { decl, modulePath }]) => buildComponent(decl, modulePath, catalogByName))
    .sort((a, b) => a.tag.localeCompare(b.tag));

  const dtsFileCount = dtsFiles(opts.dtsDir).length;

  return {
    schemaVersion: SCHEMA_VERSION,
    provenance: opts.provenance,
    cem: {
      ...(cem.schemaVersion ? { schemaVersion: cem.schemaVersion } : {}),
      readme: cem.readme || null,
      ...(cem.package
        ? { package: { name: cem.package.name, version: cem.package.version, description: cem.package.description || null } }
        : {}),
    },
    tagReconciliation: tagReconciliationFromOriginal(origCem),
    duplicates,
    aliases: catalog.map((a) => ({
      name: a.name,
      union: a.union,
      values: a.values,
      closed: a.closed,
      source: a.source,
      file: a.file,
    })),
    components,
    stats: computeStats(cem, components, catalog, dtsFileCount),
  };
}

module.exports = {
  buildFaceB,
  collectAliasCatalog,
  dtsFiles,
};
