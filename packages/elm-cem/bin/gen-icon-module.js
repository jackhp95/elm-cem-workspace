#!/usr/bin/env node
// elm-cem gen-icon-module — generate M3e.Icon (or <Lib>.Icon) from an icon catalog.
//
// Reads a config/icons-catalog.json with a `names` array of snake_case ligature
// names, emits a <Lib>.Icon Elm module with one element-helper per name plus a
// `custom` escape, and writes it to the --output directory.
//
// When the config declares `_iconModule.package`, ALSO writes a standalone
// `elm-m3e-icons/` package tree (src/M3e/Icon.elm + elm.json + README.md +
// LICENSE) with the same self-contained module, rooted at the elm-m3e worktree
// root (one level above the --output=src dir).
//
// Called from elm-cem.js after the main Elm codegen step when config declares
// `_iconModule: { "catalogFrom": "...", "iconComp": "Icon" }`.
//
// The generated module is SELF-CONTAINED: it imports only IR + elm/html, NOT
// M3e.Component.Icon, so it compiles as a standalone package with no components
// dependency. Each helper emits an m3e-icon node directly via HtmlIr.Internal,
// mirroring the loose producer pattern from M3e.Html (spec §1.2).
//
// Identifier mapping (total, documented):
//   snake_case → camelCase (arrow_back → arrowBack)
//   leading digit → "icon" prefix (10k → icon10k, 123 → icon123)
//   Elm reserved words → trailing underscore (type → type_, class → class_)
//   A collision fails loudly via process.exit(1), never silently drops an icon.
//
// Elm reserved words reference: https://github.com/elm/compiler/blob/master/compiler/src/Parse/Keyword.hs

"use strict";

const fs = require("fs");
const path = require("path");

module.exports = { run, generateIconModule };

// Elm reserved words — any identifier that exactly matches one of these must be
// renamed. Sourced from elm/compiler Parse/Keyword.hs (all reserved keywords).
const ELM_RESERVED = new Set([
  "if", "then", "else",
  "case", "of",
  "let", "in",
  "type",
  "module", "where",
  "import", "exposing",
  "as",
  "port",
  // Additionally: these are not keywords but are top-level names we emit ourselves
  // (custom, and — in the "names" shape — the `icon` renderer) so they must not
  // collide. `Name` needs no guard: toElmIdentifier always produces a
  // lowercase-initial identifier, so no ligature can ever shadow the type.
  "custom",
  "icon",
]);

// Convert a snake_case ligature name to an Elm identifier.
//
// Rules (total + documented):
//   1. snake_case → camelCase: split on `_`, join with first letter of each
//      subsequent part capitalised.
//   2. Leading digit: prefix with "icon" (10k → icon10k). The digit check
//      runs on the SNAKE name before camelCase conversion, since a snake name
//      starting with a digit can never start a valid Elm identifier.
//   3. Elm reserved word or "custom" collision: append trailing underscore.
//   4. Any two snake names that produce the same identifier → LOUD FAILURE.
//
// The `custom` name is reserved because we emit it as the escape hatch; appending
// an underscore keeps the icon accessible while signalling the collision.
function snakeToCamel(snake) {
  const parts = snake.split("_");
  return parts[0] + parts.slice(1).map((p) => p.charAt(0).toUpperCase() + p.slice(1)).join("");
}

function toElmIdentifier(snake) {
  // Rule 2: leading digit
  const hasLeadingDigit = /^\d/.test(snake);
  const camel = hasLeadingDigit ? "icon" + snakeToCamel(snake) : snakeToCamel(snake);
  // Rule 3: reserved word or "custom" collision
  return ELM_RESERVED.has(camel) ? camel + "_" : camel;
}

// Generate the full Elm source for the <Lib>.Icon module.
//
// Self-contained producer — imports ONLY IR + elm/html, not M3e.Component.Icon.
//
// TWO SHAPES, selected by `_iconModule.shape`:
//
//   "names" (DEFAULT, the published shape) — one opaque `Name` value per icon,
//   rendered by a single `icon` function:
//       type Name = Name String
//       icon : Name -> List (Attr attrs msg) -> List (Element ...) -> Element ...
//       menu : Name
//       menu = Name "menu"
//
//   "functions" (retained, NOT published) — the original one-element-helper-per-icon
//   surface, for anyone vendoring the module and wanting the terser `Icon.menu []
//   []` call site:
//       menu : List (Attr attrs msg) -> List (Element ...) -> Element ...
//       menu attrs kids = Ir.fromNode (Ir.node "m3e-icon" ...)
//
// WHY "names" is the published default (R-026 / publish-runbook O-3): the Elm
// registry rejects any package whose `docs.json` exceeds 768,000 bytes. Under
// "functions", each of the 4083 icons carries a 162-byte fully-qualified type
// signature — 661,625 B, 61.5% of the file — and the package compiled to
// 1,075,308 B = 140% of the cap. Elm EXPANDS type aliases in `docs.json`, so the
// repetition cannot be factored out with a `type alias`; annotating every icon
// with one measured 1,077,621 B, i.e. WORSE than the baseline. Trimming doc
// comments cannot close the gap either: empty comments plus single-letter type
// variables still lands at 779,233 B, over the cap with no headroom. Under
// "names" the per-entry type is `M3e.Icon.Name` (15 B) and the package fits with
// ~60% of the cap to spare. `Name` is also strictly more expressive — an icon
// becomes a first-class value that can live in a Model or a List, which a
// six-type-variable function could not.
//
// Both shapes emit `custom` as the escape hatch for unenumerated ligatures.
//
// `tag` and `iconFamily` are brand config, NOT hardcoded here (finding 2.1 of
// the 2026-08-17 thermonuclear review): `tag` is the DOM custom-element name
// the generated `icon`/helpers emit (e.g. "m3e-icon"), `iconFamily` is the
// prose name of the icon set used in doc comments (e.g. "Material Symbols").
// `attribution` is optional free-form doc text inserted before the
// "N icons total." tail; when omitted it falls back to a generic sentence
// derived from `iconFamily` so a brand that doesn't supply one still gets
// truthful (if plain) prose instead of someone else's vendor name.
function generateIconModule(lib, names, shape = "names", tag, iconFamily, attribution) {
  if (shape !== "names" && shape !== "functions") {
    console.error(
      `elm-cem gen-icon-module: unknown _iconModule.shape "${shape}" — expected "names" (default) or "functions"`
    );
    process.exit(1);
  }
  if (!tag || !iconFamily) {
    console.error(
      `elm-cem gen-icon-module: _iconModule.tag and _iconModule.iconFamily are both required ` +
      `(got tag=${JSON.stringify(tag)}, iconFamily=${JSON.stringify(iconFamily)}) — ` +
      `without them the generator has no brand-neutral way to name the emitted element or the icon set in doc prose.`
    );
    process.exit(1);
  }
  const attributionLines = (attribution || `Source: ${iconFamily} ligature names.`).split("\n");
  // Collision check — fail loudly
  const seen = new Map(); // identifier → first snake name
  for (const snake of names) {
    const id = toElmIdentifier(snake);
    if (seen.has(id)) {
      console.error(
        `elm-cem gen-icon-module: COLLISION — "${snake}" and "${seen.get(id)}" both map to Elm identifier "${id}". ` +
        `Fix the identifier mapping in bin/gen-icon-module.js before proceeding.`
      );
      process.exit(1);
    }
    seen.set(id, snake);
  }

  const allIds = names.map((s) => toElmIdentifier(s));
  const namesShape = shape === "names";

  // Exposed surface. The "names" shape additionally exposes the `Name` type
  // (opaque — the constructor is NOT exposed) and the single `icon` renderer.
  const exposingList = (namesShape ? ["Name", "icon", "custom", ...allIds] : ["custom", ...allIds])
    .join("\n    , ");

  const moduleLine = `module ${lib}.Icon exposing\n    ( ${exposingList}\n    )`;

  const headlineDoc = namesShape
    ? [
        `{-| Type-safe icon names for the full ${iconFamily} ligature set.`,
        ``,
        `Every ligature is a \`Name\` value, and \`icon\` renders one as an \`${tag}\``,
        `element with the ligature pre-filled as the \`name\` attribute, using the IR`,
        `directly — no components dependency. So`,
        `\`${lib}.Icon.icon ${lib}.Icon.menu attrs kids\` emits an \`${tag}\` element`,
        `with \`name="menu"\` prepended to \`attrs\`.`,
        ``,
        `\`Name\` is an ordinary opaque value, so an icon can be stored in a model, held`,
        `in a list, or taken as a function argument.`,
        ``,
        `Use \`custom\` for any ligature not enumerated here — teams updating the`,
        `underlying font or using app-specific icons should reach for \`custom\`.`,
        ``,
        `Elm's dead-code elimination prunes every name you do not reference, so`,
        `importing this module has no size cost beyond what you use.`,
      ]
    : [
        `{-| Type-safe icon element helpers for the full ${iconFamily} ligature set.`,
        ``,
        `Each helper produces an \`${tag}\` element with the icon name pre-filled`,
        `as the \`name\` attribute, using the IR directly — no components dependency.`,
        `So \`${lib}.Icon.menu attrs kids\` emits an \`${tag}\` element with`,
        `\`name="menu"\` prepended to \`attrs\`.`,
        ``,
        `Use \`custom\` for any name not enumerated here — teams updating the underlying`,
        `font or using app-specific icons should reach for \`custom\`.`,
        ``,
        `Elm's dead-code elimination prunes every helper you do not call, so importing`,
        `this module has no size cost beyond what you use.`,
      ];

  const moduleDoc = [
    ...headlineDoc,
    ``,
    ...attributionLines.slice(0, -1),
    `${attributionLines[attributionLines.length - 1]} ${names.length} icons total.`,
    ``,
    // `elm make --docs` (what `elm publish` runs) requires a `@docs` entry for
    // EVERY exposed value, not just a representative one — `@docs custom` alone
    // left every per-icon helper undocumented, failing the registry-faithful
    // compile with a DOCS MISTAKE per icon (batch-4 hardening: this is exactly
    // the class of bug `registry-check`'s package-shaped `elm make --docs`
    // compile exists to catch, once it is actually run against this module —
    // see registry-check.js's --nested-pkg addition, same batch).
    namesShape
      ? `@docs Name, icon, custom, ${allIds.join(", ")}`
      : `@docs custom, ${allIds.join(", ")}`,
    `-}`,
  ].join("\n");

  const imports = [
    `import Html`,
    `import HtmlIr.Attribute exposing (Attr)`,
    `import HtmlIr.Element exposing (Element)`,
    `import HtmlIr.Internal as Ir`,
    `import HtmlIr.Node`,
  ].join("\n");

  // Open-rowed loose producer signature — same form as M3e.Html.icon (spec §1.2).
  // Type variables are fully open rows (no component-module constraints).
  const sigParts = [
    `List (Attr attrs msg)`,
    `List (Element children childAdmittedBy msg)`,
    `Element produced admittedBy msg`,
  ];

  // Format a function signature: `name : T1 -> T2 -> ... -> TResult`
  // with each type on its own indented line after the first.
  function formatSig(name, firstArgTypes, returnType) {
    const allTypes = [...firstArgTypes, returnType];
    const lines = [`${name} :`];
    lines.push(`    ${allTypes[0]}`);
    for (let i = 1; i < allTypes.length; i++) {
      lines.push(`    -> ${allTypes[i]}`);
    }
    return lines.join("\n");
  }

  // The element producer itself. Identical IR call in both shapes — the only
  // difference is where the ligature string comes from (an unwrapped `Name`, or
  // the closed-over literal in a per-icon helper).
  const produce = (ligatureExpr) =>
    `    Ir.fromNode (Ir.node "${tag}" (Ir.attribute "name" ${ligatureExpr} :: attrs) (List.map HtmlIr.Element.toNode kids))`;

  // Shape-specific preamble + per-icon declarations.
  const preambleDecls = [];
  let iconDecls;

  if (namesShape) {
    preambleDecls.push(
      [
        `{-| An opaque ${iconFamily} ligature name.`,
        ``,
        `Construct one from the enumerated values below, or with \`custom\`.`,
        `-}`,
        `type Name`,
        `    = Name String`,
      ].join("\n"),
      [
        `{-| Render an icon \`Name\` as an \`${tag}\` element.`,
        `-}`,
        formatSig("icon", ["Name", ...sigParts.slice(0, 2)], sigParts[2]),
        `icon (Name ligature) attrs kids =`,
        produce("ligature"),
      ].join("\n"),
      [
        `{-| Use any ligature name not enumerated below — for teams updating the`,
        `underlying font or using app-specific icons.`,
        `-}`,
        `custom : String -> Name`,
        `custom =`,
        `    Name`,
      ].join("\n")
    );

    iconDecls = names.map((snake) => {
      const id = toElmIdentifier(snake);
      return [
        `{-| The \`${snake}\` Material Symbol icon. -}`,
        `${id} : Name`,
        `${id} =`,
        `    Name "${snake}"`,
      ].join("\n");
    });
  } else {
    preambleDecls.push(
      [
        `{-| Use any ligature name not enumerated above — for teams updating the`,
        `underlying font or using app-specific icons.`,
        `-}`,
        formatSig("custom", ["String", ...sigParts.slice(0, 2)], sigParts[2]),
        `custom ligature attrs kids =`,
        produce("ligature"),
      ].join("\n")
    );

    iconDecls = names.map((snake) => {
      const id = toElmIdentifier(snake);
      return [
        `{-| The \`${snake}\` Material Symbol icon. -}`,
        formatSig(id, sigParts.slice(0, 2), sigParts[2]),
        `${id} attrs kids =`,
        produce(`"${snake}"`),
      ].join("\n");
    });
  }

  const sections = [moduleLine, moduleDoc, imports, ...preambleDecls, ...iconDecls];
  return sections.join("\n\n\n") + "\n";
}

// Write the elm-m3e-icons standalone package tree.
//
// Writes:
//   <repoRoot>/<pkg.dir>/src/M3e/Icon.elm  — the self-contained module
//   <repoRoot>/<pkg.dir>/elm.json           — package manifest
//   <repoRoot>/<pkg.dir>/README.md          — minimal banner
//   <repoRoot>/<pkg.dir>/LICENSE            — copied from repo root
function writePackageTree(repoRoot, pkg, elmSrc, lib, shape = "names") {
  const pkgDir = path.join(repoRoot, pkg.dir);

  // src/M3e/Icon.elm
  const modPath = path.join(pkgDir, "src", ...lib.split("."), "Icon.elm");
  fs.mkdirSync(path.dirname(modPath), { recursive: true });
  fs.writeFileSync(modPath, elmSrc, "utf8");
  console.log(`elm-cem: wrote standalone module → ${modPath}`);

  // elm.json
  const elmJson = {
    type: "package",
    name: pkg.name,
    summary: pkg.summary,
    license: "BSD-3-Clause",
    version: pkg.version,
    "exposed-modules": [`${lib}.Icon`],
    "elm-version": "0.19.0 <= v < 0.20.0",
    dependencies: pkg.deps,
    "test-dependencies": {},
  };
  const elmJsonPath = path.join(pkgDir, "elm.json");
  fs.writeFileSync(elmJsonPath, JSON.stringify(elmJson, null, 4) + "\n", "utf8");
  console.log(`elm-cem: wrote ${elmJsonPath}`);

  // README.md — minimal banner
  const readmePath = path.join(pkgDir, "README.md");
  if (!fs.existsSync(readmePath)) {
    const readme = [
      `# ${pkg.name}`,
      ``,
      `${pkg.summary}`,
      ``,
      `This package is a standalone sub-package of [elm-m3e](https://github.com/jackhp95/elm-m3e).`,
      `It depends ONLY on \`elm/html\` and \`jackhp95/elm-html-intermediate-representation\``,
      `— no \`elm-m3e-components\` dependency. Suitable for projects that need only icons`,
      `without the full component library.`,
      ``,
      `**Generated file.** Do not edit \`src/\` by hand — run \`npm run gen:src\` in the`,
      `elm-m3e repo to regenerate from the icon catalog (\`config/icons-catalog.json\`).`,
      ``,
      `## Usage`,
      ``,
      `\`\`\`elm`,
      `import ${lib}.Icon`,
      ``,
      ...(shape === "names"
        ? [
            `-- A named icon`,
            `${lib}.Icon.icon ${lib}.Icon.menu [] []`,
            ``,
            `-- A custom / app-specific icon`,
            `${lib}.Icon.icon (${lib}.Icon.custom "my_custom_icon") [] []`,
            ``,
            `-- \`Name\` is an ordinary value, so icons can be stored and passed around`,
            `favourites : List ${lib}.Icon.Name`,
            `favourites =`,
            `    [ ${lib}.Icon.menu, ${lib}.Icon.search, ${lib}.Icon.settings ]`,
          ]
        : [
            `-- A named icon`,
            `${lib}.Icon.menu [] []`,
            ``,
            `-- A custom / app-specific icon`,
            `${lib}.Icon.custom "my_custom_icon" [] []`,
          ]),
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
  // Read _iconModule config from the same --config-from files that drove the main gen.
  let lib = null;
  let iconComp = null;
  let catalogPath = null;
  let pkg = null; // optional `package` sub-object for standalone package emission
  let shape = "names"; // "names" (published, under the docs.json cap) | "functions"
  let tag = null; // required — DOM tag the generated element/helpers emit (e.g. "m3e-icon")
  let iconFamily = null; // required — prose name of the icon set (e.g. "Material Symbols")
  let attribution = null; // optional — free-form "Source: ..." doc text, see generateIconModule

  for (const p of configFromPaths) {
    if (!/\.json$/.test(p)) continue;
    try {
      const c = JSON.parse(fs.readFileSync(path.resolve(process.cwd(), p), "utf8"));
      if (c && typeof c === "object" && c._iconModule) {
        const m = c._iconModule;
        if (m.lib) lib = m.lib;
        if (m.iconComp) iconComp = m.iconComp;
        if (m.catalogFrom) catalogPath = m.catalogFrom;
        if (m.package && typeof m.package === "object") pkg = m.package;
        if (m.shape) shape = m.shape;
        if (m.tag) tag = m.tag;
        if (m.iconFamily) iconFamily = m.iconFamily;
        if (m.attribution) attribution = m.attribution;
      }
      // Also read _brand as fallback for lib
      if (!lib && c._brand) lib = c._brand;
    } catch {
      /* skip unreadable configs */
    }
  }

  if (!lib || !iconComp || !catalogPath) {
    // No _iconModule config — nothing to do, but say so (a silent no-op here
    // is exactly the bug tests/bin-entrypoints.test.mjs exists to catch).
    console.error(
      "elm-cem gen-icon-module: no _iconModule config found (pass --config-from=<file.json> declaring _iconModule.lib/iconComp/catalogFrom) — nothing to do"
    );
    return;
  }

  if (!tag || !iconFamily) {
    // finding 2.1 (2026-08-17 thermonuclear review): a brand opting into
    // _iconModule without supplying its own tag/iconFamily used to silently
    // get M3E's "m3e-icon"/"Material Symbols" baked into its output. Fail
    // loud instead — the caller must say what element and icon family they mean.
    console.error(
      "elm-cem gen-icon-module: _iconModule.tag and _iconModule.iconFamily are both required " +
      "(e.g. \"tag\": \"my-icon\", \"iconFamily\": \"My Icon Set\") — nothing to do"
    );
    process.exit(1);
  }

  // Load catalog
  let names;
  try {
    const cat = JSON.parse(fs.readFileSync(path.resolve(process.cwd(), catalogPath), "utf8"));
    names = cat.names;
    if (!Array.isArray(names) || names.length === 0) {
      console.error(`elm-cem gen-icon-module: catalog at ${catalogPath} has no "names" array`);
      process.exit(1);
    }
  } catch (e) {
    console.error(`elm-cem gen-icon-module: could not read catalog at ${catalogPath}: ${e.message}`);
    process.exit(1);
  }

  const src = generateIconModule(lib, names, shape, tag, iconFamily, attribution);

  // Write to <outputDir>/M3e/Icon.elm (flat src — internal, unexposed artifact)
  const outDir = path.resolve(process.cwd(), outputDir);
  // Module path: lib is e.g. "M3e", iconComp is "Icon" → M3e/Icon.elm
  const modRelPath = path.join(...lib.split("."), "Icon.elm");
  const outPath = path.join(outDir, modRelPath);
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, src, "utf8");

  console.log(
    `elm-cem: generated ${lib}.Icon (${names.length} ligatures + custom, shape="${shape}") → ${outPath}`
  );

  // Optionally write the standalone package tree (config-declared, spec §3.1B).
  // The repo root is one level above the --output=src dir.
  if (pkg) {
    const repoRoot = path.dirname(outDir);
    writePackageTree(repoRoot, pkg, src, lib, shape);
  }
}

// Direct invocation support
if (require.main === module) {
  // Mirror bin/elm-cem.js's own --config-from parsing so a direct invocation
  // with real flags behaves the same as going through the CLI dispatcher.
  const argv = process.argv.slice(2);
  const configFromPaths = [];
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith("--config-from=")) configFromPaths.push(a.slice("--config-from=".length));
    else if (a === "--config-from" && argv[i + 1]) { configFromPaths.push(argv[i + 1]); i++; }
  }
  run(argv, configFromPaths, "src");
}
