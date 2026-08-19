#!/usr/bin/env node
// elm-cem gen-family-package — generate the `elm-m3e-families` standalone package:
// ONE FLAT module per FAMILY (`M3e.Family.<FAMILY>`) that RE-EXPORTS every member
// element's flat `M3e.Component.*` surface, ADDITIVELY. Nothing in the flat
// `M3e.Component.*` / `M3e.elm` barrel / `elm-m3e-components` package is touched —
// this is a pure additive organizing layer (spec item 4, architecture decision
// 2026-08-14; flat-family shape confirmed by Jack 2026-08-15).
//
// Reads config `_families` (see config/slots.json):
//
//   "_families": {
//     "lib": "M3e",
//     "namespace": "Family",            // module prefix: M3e.Family.*
//     "componentsFrom": "src",          // where the flat M3e/Component/*.elm live
//     "package": { "dir": "elm-m3e-families", "name": "...", "deps": {...} },
//     "families": {
//       "NavMenu": {
//         "root": "NavMenu",            // flat component that is the family root
//         "members": [                  // non-root members, each an element in the family
//           { "component": "NavMenuItem",      "path": "Item" },
//           { "component": "NavMenuItemGroup", "path": "ItemGroup" }
//         ]
//       },
//       "Chip": {                        // word-order-gap family: variant word LEADS
//         "root": "Chip",               // the member name (AssistChip, not ChipAssist)
//         "members": [ { "component": "AssistChip", "path": "Assist" }, ... ]
//       },
//       "Progress": {                    // synthetic family, no root component
//         "root": null,
//         "members": [ { "component": "CircularProgressIndicator", "path": "Circular" }, ... ]
//       }
//     }
//   }
//
// FLAT SHAPE (Jack-confirmed 2026-08-15). For each family F it emits exactly ONE
// module `<lib>.<ns>.<F>`. Every member element E of the family (the root counts
// as a member whose element label is the family name) contributes, all in that one
// module:
//
//   1. an ELEMENT-NAMED constructor `<eCamel>` (e.g. `assist`, `filterSet`, `set`)
//      that delegates to that member's canonical `component` ctor
//      (`<eCamel> = <MemberAlias>.component`). This is the C2 Component ctor — there
//      is NO `el` and NO bare lowercased ctor here.
//   2. ELEMENT-PREFIXED type aliases (`AssistIs`, `AssistAttrs`, `AssistContent`,
//      `AssistVariant`, `FilterIs`, …) re-aliasing each exposed type of the member's
//      Component surface, prefixed by the member's PascalCase element label to dodge
//      the same-name collision across members within the flat module.
//   3. ELEMENT-PREFIXED element-specific typed helpers (`assistVariant`,
//      `assistType_`, `assistHref`, `assistOnClick`, `assistChild`, `assistIcon`, …)
//      re-exporting each exposed value (other than `component`) of the member's
//      Component surface, prefixed by the member's camelCase element label + the
//      helper's Capitalized name.
//
// e.g. `M3e.Family.Chip` exposes `assist`, `filter`, `filterSet`, `input`,
// `inputSet`, `set`, `suggestion` (+ `chip` for the root), each with its own
// `Assist*`/`Filter*`/… types and `assist*`/`filter*`/… helpers.
//
// Each re-alias/re-export is a THIN delegation:
//   - `type alias <E><X> params = <MemberAlias>.<X> params`
//     (every exposed type in the flat surface is a transparent `type alias`,
//     verified: zero opaque `type` declarations across M3e/Component/*.elm, so
//     transparent re-aliasing is always faithful),
//   - `<eCamel><Cap(x)> : <ann> ; <eCamel><Cap(x)> = <MemberAlias>.x`
//     (the annotation is copied from the flat module — `elm make --docs`, which
//     `elm publish` runs, requires an annotation on every exposed value — with its
//     references to the member's OWN exposed types rewritten to the prefixed local
//     names so they resolve against this module's declarations).
//
// Because a family module only re-exports names each member Component already
// exposes, and depends on `elm-m3e-components` as an ordinary package dep, it adds
// zero new logic and cannot drift from the flat surface without a regen.
//
// Called from elm-cem.js after the main Elm codegen step (same hook point as
// gen-icon-module), when config declares `_families.package`.

"use strict";

const fs = require("fs");
const path = require("path");

module.exports = { run, parseModuleSurface, generateFamilyModule, planModules };

// ── Small naming helpers ──────────────────────────────────────────────────────
function lowerFirst(s) {
  return s.length ? s[0].toLowerCase() + s.slice(1) : s;
}
function upperFirst(s) {
  return s.length ? s[0].toUpperCase() + s.slice(1) : s;
}

// ── Parse the public surface of a generated flat component module ─────────────
//
// Returns { moduleName, exposing: [names in order], types: Map<name, params>,
//           valueAnnotations: Map<name, annotationText> }.
// - `exposing` preserves the exact order/grouping the flat module used, so the
//   re-export's declarations mirror it 1:1.
// - `types` maps each exposed Capitalized name to its type-alias parameter string
//   (e.g. "Is" → "s", "Attrs" → "", "ChildAdmittedBy" → "childAdm").
// - `valueAnnotations` maps each exposed lowercase name to its full annotation
//   type (the text after `name :`), copied verbatim for the re-export.
function parseModuleSurface(src, filePath) {
  // module <Name> exposing ( ... )
  const moduleMatch = src.match(/^module\s+([\w.]+)\s+exposing\s*\(([\s\S]*?)\)/m);
  if (!moduleMatch) throw new Error(`gen-family-package: cannot parse module header in ${filePath}`);
  const moduleName = moduleMatch[1];
  const exposingRaw = moduleMatch[2];

  // Names in exposing order (drop the `(..)` variant-expose form — none of these
  // modules use it, but be defensive and strip a trailing "(..)").
  const exposing = exposingRaw
    .split(",")
    .map((s) => s.trim().replace(/\(\.\.\)$/, "").trim())
    .filter((s) => s.length > 0);

  // Exposed type aliases: capture params. Match `type alias NAME <params> =`.
  const types = new Map();
  const typeRe = /^type alias\s+([A-Z]\w*)((?:\s+\w+)*)\s*=/gm;
  let m;
  while ((m = typeRe.exec(src)) !== null) {
    types.set(m[1], m[2].trim());
  }
  // Guard: a non-alias `type NAME` would break transparent re-aliasing.
  const opaqueRe = /^type\s+([A-Z]\w*)/gm;
  while ((m = opaqueRe.exec(src)) !== null) {
    // `type alias` also matches `type ` prefix — exclude it.
    const at = m.index;
    if (src.startsWith("type alias", at)) continue;
    throw new Error(
      `gen-family-package: ${moduleName} exposes/declares an opaque \`type ${m[1]}\` — ` +
        `transparent re-aliasing is not possible. The family package assumes every ` +
        `exposed type is a \`type alias\`; fix the codegen or exclude this component.`
    );
  }

  // Exposed value annotations: `name :\n    <type...>` up to the value's own
  // definition line `name <args> =` or a blank-line + next decl. Capture the full
  // multiline annotation text verbatim.
  const valueAnnotations = new Map();
  // Match `name :` at column 0, then everything until the definition `name ... =`.
  const annRe = /^([a-z]\w*)\s*:\n([\s\S]*?)\n\1(?:\s|=)/gm;
  while ((m = annRe.exec(src)) !== null) {
    valueAnnotations.set(m[1], m[2].replace(/\s+$/, ""));
  }
  // Single-line annotations `name : Type` (no newline before def) — the flat
  // component modules put every annotation on its own indented multi-line block,
  // but handle the one-line form too for robustness.
  const annRe1 = /^([a-z]\w*)\s*:\s+([^\n]+)\n\1(?:\s|=)/gm;
  while ((m = annRe1.exec(src)) !== null) {
    if (!valueAnnotations.has(m[1])) valueAnnotations.set(m[1], "    " + m[2].trim());
  }

  return { moduleName, exposing, types, valueAnnotations };
}

// ── Rewrite a member's annotation to reference the prefixed local type names ──
//
// Within a member's copied annotation, every whole-word occurrence of one of the
// member's OWN exposed types (`Is`, `Attrs`, `Content`, `Variant`, …) must become
// the element-prefixed local alias (`AssistIs`, `AssistAttrs`, …) so it resolves
// against this flat family module's own declarations rather than an ambiguous or
// missing bare name. Types NOT exposed by the member (external tokens such as
// `Attr`, `Element`, `Supported`, `Value`, `Available`) are left untouched — they
// come from the imported IR / M3e.Kind modules.
function prefixTypeRefs(annotationText, exposedTypeNames, elementPascal) {
  let out = annotationText;
  // Longest names first so a prefixed superstring isn't re-hit (defensive; the
  // exposed type names of one component don't nest, but keep it robust).
  const names = [...exposedTypeNames].sort((a, b) => b.length - a.length);
  for (const t of names) {
    // Whole-word match not already preceded by a `.` (so `Orig.Is` style qualified
    // refs, though we don't emit them, are never touched) and not already prefixed.
    const re = new RegExp(`(^|[^.\\w])${t}\\b`, "g");
    out = out.replace(re, (_all, pre) => `${pre}${elementPascal}${t}`);
  }
  return out;
}

// ── Emit one FLAT family module ───────────────────────────────────────────────
//
// familyModuleName : e.g. "M3e.Family.Chip"
// members          : [{ elementPascal, elementCamel, origModuleName, surface }]
//                    one per element in the family (root included, element label =
//                    family name). Order = root first (if any), then config order.
// familyBlurb      : a short line for the module doc comment.
function generateFamilyModule(familyModuleName, members, familyBlurb) {
  // Build, per member, the ordered list of emitted (kind, exposedName, emittedName)
  // triples so the exposing list, @docs, and declarations all agree.
  const emitted = []; // { kind: "type"|"ctor"|"value", emittedName, member, srcName }

  for (const mem of members) {
    const { surface, elementPascal, elementCamel } = mem;
    for (const name of surface.exposing) {
      if (/^[A-Z]/.test(name)) {
        emitted.push({ kind: "type", emittedName: `${elementPascal}${name}`, member: mem, srcName: name });
      } else if (name === "component") {
        // The canonical ctor → element-named constructor.
        emitted.push({ kind: "ctor", emittedName: elementCamel, member: mem, srcName: name });
      } else {
        emitted.push({
          kind: "value",
          emittedName: `${elementCamel}${upperFirst(name)}`,
          member: mem,
          srcName: name,
        });
      }
    }
  }

  // Exposing list (types first, then values — Elm allows any order, but group for
  // readability; keep the emitted[] order stable within each group).
  const typeNames = emitted.filter((e) => e.kind === "type").map((e) => e.emittedName);
  const valueNames = emitted.filter((e) => e.kind !== "type").map((e) => e.emittedName);
  const exposingAll = [...typeNames, ...valueNames];
  const exposingList = exposingAll.join("\n    , ");
  const moduleLine = `module ${familyModuleName} exposing\n    ( ${exposingList}\n    )`;

  const memberList = members
    .map((mem) => `[\`${mem.origModuleName}\`](${mem.origModuleName}) as \`${mem.elementCamel}\``)
    .join(", ");
  const docLines = [
    `{-| ${familyBlurb}`,
    ``,
    `This is the **flat family module** for this family: one module carrying every`,
    `member element as an element-named constructor (delegating to that component's`,
    `\`component\` ctor), with element-prefixed type aliases and element-prefixed`,
    `typed helpers so members never collide. It re-exports:`,
    ``,
    memberList + ".",
    ``,
    `Prefer whichever import reads best — the flat \`M3e.Component.*\` modules and`,
    `this family module are the same elements, same types.`,
    ``,
    `@docs ${exposingAll.join(", ")}`,
    `-}`,
  ].join("\n");

  // Imports: each member's Component module aliased, plus the external token
  // imports its annotations reference. Compute the external-import set from the
  // combined value annotations of ALL members (post-rewrite refs to local prefixed
  // types are not external, so scanning the pre-rewrite text over the fixed
  // external table is correct — the table only lists genuinely external tokens).
  const EXTERNAL_IMPORTS = [
    { line: "import HtmlIr.Attribute exposing (Attr)", tokens: ["Attr"] },
    { line: "import HtmlIr.Element exposing (Element)", tokens: ["Element"] },
    { line: "import HtmlIr.Value exposing (Value)", tokens: ["Value"] },
    { line: "import HtmlIr.Kind exposing (Shared, Supported)", tokens: ["Shared", "Supported"] },
    { line: "import M3e.Kind exposing (Available, Brand, Ctx, Used)", tokens: ["Available", "Brand", "Ctx", "Used"] },
    { line: "import M3e.Action as Ac", tokens: ["Ac.Action"] },
    { line: "import Json.Encode", tokens: ["Json.Encode"] },
    { line: "import Json.Decode", tokens: ["Json.Decode"] },
  ];
  const annBlob = members
    .map((mem) =>
      mem.surface.exposing
        .filter((n) => /^[a-z]/.test(n))
        .map((n) => mem.surface.valueAnnotations.get(n) || "")
        .join("\n")
    )
    .join("\n");
  const importLines = members.map((mem) => `import ${mem.origModuleName} as ${mem.alias}`);
  for (const { line, tokens } of EXTERNAL_IMPORTS) {
    const hit = tokens.some((t) => {
      const re = t.includes(".")
        ? new RegExp(t.replace(/\./g, "\\.").replace(/(\w+)$/, "$1\\b"))
        : new RegExp(`\\b${t}\\b`);
      return re.test(annBlob);
    });
    if (hit) importLines.push(line);
  }
  const imports = importLines.join("\n");

  // Declarations, in emitted[] order.
  const decls = [];
  for (const item of emitted) {
    const { member, srcName, emittedName, kind } = item;
    const { surface, alias, elementPascal, origModuleName } = member;
    const exposedTypeNames = new Set(surface.exposing.filter((n) => /^[A-Z]/.test(n)));

    if (kind === "type") {
      if (!surface.types.has(srcName)) {
        throw new Error(
          `gen-family-package: ${origModuleName} exposes type \`${srcName}\` but no ` +
            `\`type alias ${srcName}\` declaration was found to read its parameters.`
        );
      }
      const params = surface.types.get(srcName);
      const lhs = params ? `${emittedName} ${params}` : emittedName;
      const rhs = params ? `${alias}.${srcName} ${params}` : `${alias}.${srcName}`;
      decls.push(
        [
          `{-| See [\`${origModuleName}.${srcName}\`](${origModuleName}#${srcName}). -}`,
          `type alias ${lhs} =`,
          `    ${rhs}`,
        ].join("\n")
      );
    } else {
      // ctor or value
      if (!surface.valueAnnotations.has(srcName)) {
        throw new Error(
          `gen-family-package: ${origModuleName} exposes value \`${srcName}\` but no type ` +
            `annotation was found for it. \`elm make --docs\` requires an annotation on every exposed value.`
        );
      }
      const rawAnn = surface.valueAnnotations.get(srcName);
      const ann = prefixTypeRefs(rawAnn, exposedTypeNames, elementPascal);
      const doc =
        kind === "ctor"
          ? `{-| The \`${member.elementCamel}\` element of this family — delegates to ` +
            `[\`${origModuleName}.component\`](${origModuleName}#component). -}`
          : `{-| See [\`${origModuleName}.${srcName}\`](${origModuleName}#${srcName}). -}`;
      decls.push([doc, `${emittedName} :`, ann, `${emittedName} =`, `    ${alias}.${srcName}`].join("\n"));
    }
  }

  const sections = [moduleLine, docLines, imports, ...decls];
  return sections.join("\n\n\n") + "\n";
}

// ── Plan every FLAT family module the package emits ───────────────────────────
//
// Returns [{ familyModuleName, family, blurb, members: [{ component, elementPascal,
// elementCamel, alias }] }], one entry per family. Validates no duplicate emitted
// module names, no duplicate source components, and — crucially for the flat shape
// — no duplicate element label WITHIN a family (which would collide constructors
// and prefixed types).
function planModules(cfg, lib, ns) {
  const families = [];
  const emittedNames = new Set();
  const usedComponents = new Set();

  const familyPrefix = `${lib}.${ns}`;

  const familyEntries = Object.entries(cfg.families || {});
  if (familyEntries.length === 0) {
    throw new Error("gen-family-package: _families.families is empty — nothing to emit.");
  }

  for (const [family, spec] of familyEntries) {
    const root = spec.root || null;
    const rawMembers = spec.members || [];

    const familyModuleName = `${familyPrefix}.${family}`;
    if (emittedNames.has(familyModuleName)) {
      throw new Error(`gen-family-package: duplicate emitted module name ${familyModuleName}.`);
    }
    emittedNames.add(familyModuleName);

    const members = [];
    const labelsInFamily = new Set();
    const aliasesInFamily = new Set();

    const pushMember = (component, elementPascal) => {
      if (usedComponents.has(component)) {
        throw new Error(
          `gen-family-package: component ${component} is assigned to more than one family/member — ` +
            `a component may belong to at most one family.`
        );
      }
      usedComponents.add(component);
      if (labelsInFamily.has(elementPascal)) {
        throw new Error(
          `gen-family-package: family "${family}" has two members with element label ` +
            `"${elementPascal}" — element labels must be unique within a flat family module ` +
            `(they name the constructor and prefix the types/helpers).`
        );
      }
      labelsInFamily.add(elementPascal);
      // Import alias: `<Pascal>_` (trailing underscore avoids clashing with the
      // local prefixed type names like `Assist`/`AssistIs`).
      let alias = `${elementPascal}_`;
      while (aliasesInFamily.has(alias)) alias += "_";
      aliasesInFamily.add(alias);
      members.push({
        component,
        elementPascal,
        elementCamel: lowerFirst(elementPascal),
        alias,
      });
    };

    // Root counts as a member; its element label is the FAMILY name.
    if (root) pushMember(root, family);

    for (const mem of rawMembers) {
      if (!mem.component || !mem.path) {
        throw new Error(
          `gen-family-package: family "${family}" has a malformed member ${JSON.stringify(mem)} ` +
            `(need { "component": ..., "path": ... }).`
        );
      }
      pushMember(mem.component, mem.path);
    }

    if (members.length === 0) {
      throw new Error(`gen-family-package: family "${family}" has no root and no members — nothing to emit.`);
    }

    families.push({
      familyModuleName,
      family,
      blurb: `The **${family}** family — flat module re-exporting its member elements.`,
      members,
    });
  }

  return families;
}

// ── Write the standalone elm-m3e-families package tree ────────────────────────
function writePackageTree(repoRoot, pkg, moduleFiles, exposedModules) {
  const pkgDir = path.join(repoRoot, pkg.dir);

  // Clean the generated module tree first. This generator OWNS `src/M3e/Family/`
  // entirely (it is a fully-derived artifact), so any file left there from a
  // previous run must go — otherwise a shape change (e.g. the flat-family reshape
  // that replaced the per-element sub-modules `M3e/Family/Chip/Assist.elm` with a
  // single flat `M3e/Family/Chip.elm`) would leave orphan modules that break
  // `elm make`/`check:drift`. Only the derived `src/` subtree is cleared —
  // elm.json / README / LICENSE are handled below.
  const nsPrefix = exposedModules[0] ? exposedModules[0].split(".").slice(0, 2) : [];
  const genSrcRoot =
    nsPrefix.length === 2 ? path.join(pkgDir, "src", nsPrefix[0], nsPrefix[1]) : path.join(pkgDir, "src");
  if (fs.existsSync(genSrcRoot)) fs.rmSync(genSrcRoot, { recursive: true, force: true });

  // src/<Module/Path>.elm for each emitted module
  for (const { newModuleName, src } of moduleFiles) {
    const relPath = path.join(...newModuleName.split(".")) + ".elm";
    const outPath = path.join(pkgDir, "src", relPath);
    fs.mkdirSync(path.dirname(outPath), { recursive: true });
    fs.writeFileSync(outPath, src, "utf8");
  }
  console.log(`elm-cem: wrote ${moduleFiles.length} family module(s) → ${path.join(pkgDir, "src")}`);

  // elm.json
  const elmJson = {
    type: "package",
    name: pkg.name,
    summary: pkg.summary,
    license: "BSD-3-Clause",
    version: pkg.version,
    "exposed-modules": exposedModules,
    "elm-version": "0.19.0 <= v < 0.20.0",
    dependencies: pkg.deps,
    "test-dependencies": {},
  };
  const elmJsonPath = path.join(pkgDir, "elm.json");
  fs.writeFileSync(elmJsonPath, JSON.stringify(elmJson, null, 4) + "\n", "utf8");
  console.log(`elm-cem: wrote ${elmJsonPath}`);

  // README.md — minimal banner (only if absent, like gen-icon-module)
  const readmePath = path.join(pkgDir, "README.md");
  if (!fs.existsSync(readmePath)) {
    const readme = [
      `# ${pkg.name}`,
      ``,
      `${pkg.summary}`,
      ``,
      `This package is a standalone sub-package of [elm-m3e](https://github.com/jackhp95/elm-m3e).`,
      `It is a **purely additive** re-organization: each module here is a **flat**`,
      `family module that re-exports the member elements of one family from the flat`,
      `\`M3e.Component.*\` surface — element-named constructors (\`M3e.Family.Chip.assist\``,
      `delegates to \`M3e.Component.AssistChip.component\`) plus element-prefixed types`,
      `(\`AssistIs\`, \`AssistAttrs\`) and element-prefixed helpers (\`assistVariant\`) —`,
      `so nothing built against the flat surface regresses. Depends on`,
      `\`jackhp95/elm-m3e-components\` — it adds no logic of its own.`,
      ``,
      `**Generated file.** Do not edit \`src/\` by hand — run \`npm run gen:src\` in the`,
      `elm-m3e repo to regenerate from the \`_families\` config (\`config/slots.json\`).`,
      ``,
      `## Usage`,
      ``,
      `\`\`\`elm`,
      `import M3e.Family.Chip as Chip`,
      ``,
      `Chip.set [] [ Chip.child (Chip.assist [] [ Chip.assistChild ... ]) ]`,
      `\`\`\``,
      ``,
      `## License`,
      ``,
      `BSD-3-Clause — see [LICENSE](LICENSE).`,
    ].join("\n") + "\n";
    fs.writeFileSync(readmePath, readme, "utf8");
    console.log(`elm-cem: wrote ${readmePath}`);
  } else {
    console.log(`elm-cem: README.md already exists, skipping → ${readmePath}`);
  }

  // LICENSE — copy from repo root if present
  const licenseSrc = path.join(repoRoot, "LICENSE");
  const licenseDst = path.join(pkgDir, "LICENSE");
  if (!fs.existsSync(licenseDst)) {
    if (fs.existsSync(licenseSrc)) {
      fs.copyFileSync(licenseSrc, licenseDst);
      console.log(`elm-cem: copied LICENSE → ${licenseDst}`);
    } else {
      console.warn(`elm-cem: no root LICENSE found at ${licenseSrc}, skipping LICENSE copy`);
    }
  } else {
    console.log(`elm-cem: LICENSE already exists, skipping → ${licenseDst}`);
  }
}

function run(argv, configFromPaths, outputDir) {
  // Read _families config from the same --config-from files that drove the main gen.
  let cfg = null;
  let brand = null;
  for (const p of configFromPaths) {
    if (!/\.json$/.test(p)) continue;
    try {
      const c = JSON.parse(fs.readFileSync(path.resolve(process.cwd(), p), "utf8"));
      if (c && typeof c === "object") {
        if (c._families) cfg = c._families;
        if (c._brand) brand = c._brand;
      }
    } catch {
      /* skip unreadable configs */
    }
  }

  if (!cfg || !cfg.package) {
    // No _families config — nothing to do, but say so (a silent no-op here is
    // exactly the bug class bin-entrypoints tests exist to catch).
    console.error(
      "elm-cem gen-family-package: no _families config with a `package` block found — nothing to do"
    );
    return;
  }

  const lib = cfg.lib || brand || "M3e";
  const ns = cfg.namespace || "Family";

  // Where the flat component modules live. Default: the same --output=src dir the
  // main gen just wrote (so families always re-export the freshly generated flat
  // surface). Config `componentsFrom` may override (relative to cwd).
  const componentsRoot = cfg.componentsFrom
    ? path.resolve(process.cwd(), cfg.componentsFrom)
    : path.resolve(process.cwd(), outputDir);

  const componentPrefix = `${lib}.Component`;
  const plan = planModules(cfg, lib, ns);

  const moduleFiles = [];
  for (const fam of plan) {
    // Load + parse each member's flat Component surface.
    const members = fam.members.map((mem) => {
      const origModuleName = `${componentPrefix}.${mem.component}`;
      const flatPath = path.join(componentsRoot, ...origModuleName.split(".")) + ".elm";
      if (!fs.existsSync(flatPath)) {
        console.error(
          `elm-cem gen-family-package: source component module not found: ${flatPath} ` +
            `(for family module ${fam.familyModuleName}). Check the _families config component names.`
        );
        process.exit(1);
      }
      const flatSrc = fs.readFileSync(flatPath, "utf8");
      const surface = parseModuleSurface(flatSrc, flatPath);
      return { ...mem, origModuleName, surface };
    });

    const src = generateFamilyModule(fam.familyModuleName, members, fam.blurb);
    moduleFiles.push({ newModuleName: fam.familyModuleName, src });
  }

  const exposedModules = moduleFiles.map((m) => m.newModuleName).sort();

  const repoRoot = path.dirname(path.resolve(process.cwd(), outputDir));
  writePackageTree(repoRoot, cfg.package, moduleFiles, exposedModules);

  console.log(
    `elm-cem: generated ${moduleFiles.length} flat family module(s) across ${Object.keys(cfg.families).length} families → ${cfg.package.dir}`
  );
}

// Direct invocation support (mirror elm-cem.js --config-from parsing + --output).
if (require.main === module) {
  const argv = process.argv.slice(2);
  const configFromPaths = [];
  let outputDir = "src";
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith("--config-from=")) configFromPaths.push(a.slice("--config-from=".length));
    else if (a === "--config-from" && argv[i + 1]) { configFromPaths.push(argv[i + 1]); i++; }
    else if (a.startsWith("--output=")) outputDir = a.slice("--output=".length);
    else if (a === "--output" && argv[i + 1]) { outputDir = argv[i + 1]; i++; }
  }
  run(argv, configFromPaths, outputDir);
}
