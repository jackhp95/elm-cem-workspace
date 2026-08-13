// extract-samples.mjs — `npm run gen:samples`.
//
// WHY THIS EXISTS
//   The guide pages teach with Elm source held in `"""…"""` string literals. A
//   string is not code: nothing compiled it, nothing linted it, and in one day
//   three separate pages were found teaching something wrong —
//     · `/guide/tooling-refactors` showed an "after autofix" result that was
//       still an escape hatch (`fromHtmlAttribute (class "…")`) when
//       `TypedHtml.Attributes.class` existed;
//     · `/guide/motion` showed `M3e.Unsafe.customElement (Html.node "avt-snackbar")`,
//       which does not typecheck — `customElement` takes a `String`;
//     · `/guide/seams` showed a paraphrase of a live helper that had drifted from
//       it (the compiled one carried an accessibility fix the displayed one did not).
//   Sample code in a teaching guide is read as instruction. A wrong sample is
//   worse than wrong code, because a reader copies it on purpose.
//
// WHAT IT WRITES  (all committed; `check:drift` re-runs this and byte-compares)
//   docs/src/Guide/Samples.elm     the DERIVED strings — the source text of a
//                                  live, compiled declaration, so a page cannot
//                                  drift from the thing it is showing.
//   docs/samples/good/**.elm       every other Elm sample, as a real module that
//   docs/samples/bad/**.elm        must compile / must fail, per its marker.
//   docs/samples/manifest.json     what is expected of each, and why.
//   docs/samples/review/elm.json   the samples' review project, with its
//                                  dependency pins taken from `review/elm.json`
//                                  so the two can never disagree.
//
// `npm run check:samples` is what judges the result; this script only extracts.
// Keeping generation deterministic and compiler-free is what lets `check:drift`
// re-run it in a scratch copy on every gate.

import { execFileSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  buildSampleModule,
  codeBlockCalls,
  escapeTripleQuoted,
  isElmLang,
  moduleNameOf,
  sampleSources,
  stringDeclarations,
  unescapeTripleQuoted,
} from "./lib/samples.mjs";

const HERE = path.dirname(fileURLToPath(import.meta.url));
const DOCS = path.resolve(HERE, "..", "..");
const REPO = path.resolve(DOCS, "..");

const ROUTE_DIRS = [
  path.join(DOCS, "app", "Route", "Guide"),
  path.join(DOCS, "app", "Route", "GettingStarted"),
];
const DERIVED_OUT = path.join(DOCS, "src", "Guide", "Samples.elm");
const SAMPLES = path.join(DOCS, "samples");
const ELM_FORMAT = firstExisting([
  path.join(DOCS, "node_modules", ".bin", "elm-format"),
  path.join(REPO, "node_modules", ".bin", "elm-format"),
]);

// Where a sample's modules may resolve from. Mirrors docs/samples/elm.json.
const SRC_DIRS = [
  path.join(REPO, "src"),
  path.join(DOCS, "vendor", "elm-foundation"),
  path.join(SAMPLES, "support"),
];
const STDLIB_ROOTS = new Set(["Html", "Json", "VirtualDom", "Basics", "Dict", "Set", "List", "Maybe", "Result", "String", "Char", "Tuple", "Array", "Browser", "Platform", "Process", "Task", "Time", "Debug", "Bitwise"]);

function firstExisting(candidates) {
  return candidates.find((p) => fs.existsSync(p)) || null;
}

function resolves(mod) {
  if (STDLIB_ROOTS.has(mod.split(".")[0])) return true;
  const rel = mod.replace(/\./g, path.sep) + ".elm";
  return SRC_DIRS.some((dir) => fs.existsSync(path.join(dir, rel)));
}

const problems = [];
const fail = (msg) => problems.push(msg);

// ---------------------------------------------------------------------------
// 1. Read every guide route

/** @type {Array<{ file: string, page: string, module: string, source: string }>} */
const routes = [];
for (const dir of ROUTE_DIRS) {
  if (!fs.existsSync(dir)) continue;
  for (const name of fs.readdirSync(dir).sort()) {
    if (!name.endsWith(".elm")) continue;
    const file = path.join(dir, name);
    routes.push({
      file,
      page: name.replace(/\.elm$/, ""),
      module: moduleNameOf(fs.readFileSync(file, "utf8")) || name,
      source: fs.readFileSync(file, "utf8"),
    });
  }
}

// ---------------------------------------------------------------------------
// 2. DERIVED samples: the source text of a live, compiled declaration.

const derived = [];
for (const route of routes) {
  for (const src of sampleSources(route.source)) {
    derived.push({
      ...src,
      page: route.page,
      routeModule: route.module,
      file: path.relative(REPO, route.file),
    });
  }
}
derived.sort((a, b) => a.exportName.localeCompare(b.exportName));

const seenExports = new Set();
for (const d of derived) {
  if (seenExports.has(d.exportName)) fail(`two @sample-source markers both claim \`${d.exportName}\``);
  seenExports.add(d.exportName);
}

if (derived.length) {
  const doc = [
    "module Guide.Samples exposing",
    "    ( " + derived.map((d) => d.exportName).join("\n    , "),
    "    )",
    "",
    "{-| GENERATED by `npm run gen:samples` — do not edit.",
    "",
    "Guide pages that render a live helper AND show its code get the shown code",
    "from here: each string below is the *source text of that helper*, lifted out",
    "of the route module it lives in. A page and the thing it is teaching cannot",
    "drift apart, because there is only one of them.",
    "",
    "Marked at the source with `-- @sample-source <name>`.",
    "",
    ...derived.map((d) => `@docs ${d.exportName}`),
    "",
    "-}",
    "",
    "",
  ];
  const bodies = derived.map((d) => {
    const code = d.code.replace(/\s+$/, "");
    return [
      `{-| \`${d.declName}\`, from \`${d.file}\`.`,
      "-}",
      `${d.exportName} : String`,
      `${d.exportName} =`,
      `    """${escapeTripleQuoted(code)}"""`,
    ].join("\n");
  });
  write(DERIVED_OUT, doc.join("\n") + bodies.join("\n\n\n") + "\n");
  if (ELM_FORMAT) execFileSync(ELM_FORMAT, ["--yes", DERIVED_OUT], { stdio: "pipe" });
} else if (fs.existsSync(DERIVED_OUT)) {
  fs.rmSync(DERIVED_OUT);
}

// ---------------------------------------------------------------------------
// 3. EXTRACTED samples: every other Elm block, as a module that must compile.

/** @type {Array<object>} */
const manifest = [];
const moduleNames = new Set();

for (const route of routes) {
  const decls = stringDeclarations(route.source);
  const blocks = codeBlockCalls(route.source);

  for (const { lang, arg } of blocks) {
    if (!isElmLang(lang)) continue;

    if (arg === '"""') {
      fail(
        `${path.relative(REPO, route.file)}: an Elm code block is written inline. ` +
          `Elm samples must be a named \`String\` declaration so they can carry a ` +
          `\`-- @sample\` marker and be extracted; hoist it out of the view.`,
      );
      continue;
    }
    // A qualified argument is a DERIVED sample (`Samples.seamsTwoColumn`), which
    // is verified by the docs app's own compile — it IS the compiled helper.
    if (arg.includes(".")) {
      const name = arg.split(".").pop();
      if (!seenExports.has(name)) {
        fail(`${path.relative(REPO, route.file)}: \`${arg}\` is not a generated sample export`);
      }
      manifest.push({ page: route.page, sample: name, disposition: "derived", reason: "source text of a live, compiled declaration in the route module" });
      continue;
    }

    const decl = decls.get(arg);
    if (!decl) {
      fail(`${path.relative(REPO, route.file)}: no \`${arg} : String\` declaration for an Elm code block`);
      continue;
    }

    const marker = decl.marker;
    const kind = marker ? marker.kind : "verify";
    const code = unescapeTripleQuoted(decl.text).trim();
    const provenance = `\`${route.module}.${arg}\``;
    const entry = {
      page: route.page,
      sample: arg,
      disposition: kind,
      reason: marker ? marker.reason : "",
    };

    if (kind === "skip") {
      if (!entry.reason) fail(`${route.module}.${arg}: \`@sample skip\` must carry a reason`);
      manifest.push(entry);
      continue;
    }
    if (!["verify", "expect-compile-error", "expect-review"].includes(kind)) {
      fail(`${route.module}.${arg}: unknown \`@sample ${kind}\` marker`);
      continue;
    }
    if (kind === "expect-review" && !marker.rule) {
      fail(`${route.module}.${arg}: \`@sample expect-review\` must name the rule it expects`);
      continue;
    }
    if (kind !== "verify" && !entry.reason) {
      fail(`${route.module}.${arg}: \`@sample ${kind}\` must carry a reason`);
      continue;
    }

    const bucket = kind === "expect-compile-error" ? "bad" : "good";

    // A sample that shows a WHOLE MODULE (the `Main.elm` on the installation
    // page) is already an Elm file — writing it verbatim is the only faithful
    // thing to do, so its module header is what names the file.
    const wholeModule = /^module[ \t]+([A-Za-z0-9_.]+)/.exec(code);
    const moduleName = wholeModule ? wholeModule[1] : `Sample.${route.page}.${pascal(arg)}`;
    if (wholeModule && moduleNames.has(moduleName)) {
      fail(`${route.module}.${arg}: two samples both declare \`module ${moduleName}\``);
      continue;
    }
    moduleNames.add(moduleName);

    const file = path.join(SAMPLES, bucket, moduleName.replace(/\./g, path.sep) + ".elm");
    write(
      file,
      wholeModule
        ? code.replace(
            /\n/,
            `\n\n-- GENERATED by \`npm run gen:samples\` from ${provenance} — do not edit.\n`,
          ) + "\n"
        : buildSampleModule({ moduleName, code, provenance, resolves }),
    );

    entry.module = moduleName;
    entry.file = path.relative(SAMPLES, file);
    if (marker && marker.rule) entry.rule = marker.rule;
    manifest.push(entry);
  }
}

// ---------------------------------------------------------------------------
// 4. Sweep stale modules, then write the manifest and the review project.

const live = new Set(manifest.filter((m) => m.file).map((m) => path.join(SAMPLES, m.file)));
for (const bucket of ["good", "bad"]) {
  pruneTo(path.join(SAMPLES, bucket), live);
}

manifest.sort((a, b) => (a.page + a.sample).localeCompare(b.page + b.sample));
write(path.join(SAMPLES, "manifest.json"), JSON.stringify(manifest, null, 2) + "\n");

// The samples' review project reuses the docs review config's dependency pins
// AND its escape-discipline rule list verbatim — copied here by machine so a
// version bump, or a change to what counts as an escape, cannot leave one of the
// two behind. `check:drift` re-runs this and byte-compares, so a stale copy is a
// gate failure rather than a slow divergence. Only the source-directories are
// rewritten, for the extra depth.
copy(
  path.join(REPO, "review", "src", "CodegenReviewConfig.elm"),
  path.join(SAMPLES, "review", "src", "CodegenReviewConfig.elm"),
);
const reviewElm = JSON.parse(fs.readFileSync(path.join(REPO, "review", "elm.json"), "utf8"));
write(
  path.join(SAMPLES, "review", "elm.json"),
  JSON.stringify(
    {
      type: "application",
      // `src` is this project's own ReviewConfig; the rest mirror
      // review/elm.json's entries, re-rooted from docs/samples/review/.
      "source-directories": ["src"].concat(
        reviewElm["source-directories"]
          .filter((d) => d !== "src")
          .map((d) => path.posix.join("../../..", d.replace(/^\.\.\//, ""))),
      ),
      "elm-version": reviewElm["elm-version"],
      dependencies: reviewElm.dependencies,
      "test-dependencies": reviewElm["test-dependencies"],
    },
    null,
    4,
  ) + "\n",
);

// ---------------------------------------------------------------------------

if (problems.length) {
  console.error("gen:samples: FAIL — a displayed Elm sample could not be extracted:\n");
  for (const p of problems) console.error(`  - ${p}`);
  console.error(
    "\nEvery Elm code block on a guide page must be a named `String` declaration,\n" +
      "either derived from a compiled helper (`-- @sample-source`) or extractable\n" +
      "(optionally with a `-- @sample skip: <reason>` opt-out). See docs/samples/README.md.",
  );
  process.exit(1);
}

const counts = manifest.reduce((acc, m) => ({ ...acc, [m.disposition]: (acc[m.disposition] || 0) + 1 }), {});
console.log(
  `samples: ${manifest.length} Elm block(s) — ` +
    Object.entries(counts)
      .sort()
      .map(([k, n]) => `${n} ${k}`)
      .join(", "),
);

// ---------------------------------------------------------------------------

function pascal(name) {
  return name.charAt(0).toUpperCase() + name.slice(1);
}

function copy(from, to) {
  write(to, fs.readFileSync(from, "utf8"));
}

function write(file, contents) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const prior = fs.existsSync(file) ? fs.readFileSync(file, "utf8") : null;
  if (prior !== contents) fs.writeFileSync(file, contents);
}

function pruneTo(dir, keep) {
  if (!fs.existsSync(dir)) return;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      pruneTo(full, keep);
      if (fs.readdirSync(full).length === 0) fs.rmdirSync(full);
    } else if (entry.name.endsWith(".elm") && !keep.has(full)) {
      fs.rmSync(full);
    }
  }
}
