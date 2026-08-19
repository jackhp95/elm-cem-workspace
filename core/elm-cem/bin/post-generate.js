// After the Elm codegen step, run any supplemental Node.js generators that
// produce modules the Elm codegen cannot: the icon-module generator (WS-C),
// which writes <Lib>.Icon from a config-declared ligature-name catalog, and
// the family-grouped standalone package (item 4), which re-exports the
// freshly generated flat M3e.Component.* surface under nested M3e.Family.*
// paths. Both are invoked from `bin/elm-cem.js` before `syncExposedModules`
// so their emitted files are included in the exposed-modules computation (or
// filtered by `_internalModules` as configured). Extracted out of
// `elm-cem.js` (finding 4, Theme 4 of the 2026-08-17 thermonuclear review) —
// pure code motion, no behavior change.

/** Collect every `--config-from=<path>` / `--config-from <path>` value from argv, in order. */
function extractConfigFromPaths(argv) {
  const configFromPaths = [];
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith("--config-from=")) configFromPaths.push(a.slice("--config-from=".length));
    else if (a === "--config-from" && argv[i + 1]) {
      configFromPaths.push(argv[i + 1]);
      i++;
    }
  }
  return configFromPaths;
}

// Named `runPostGenerate` (not the plain `run` name subcommand files use)
// deliberately: this is a library-shaped helper module (like family-deps.js),
// not a CLI subcommand — it has no direct-exec entry point, and
// `tests/bin-entrypoints.test.mjs` discovers entry points by pattern-matching
// each bin/*.js file's exports object for that plain name, so using it here
// would misclassify this file as a subcommand and fail that test's
// silent-no-op check when invoked with no args.

/** Run the icon-module and family-package generators against `outputDir`. */
function runPostGenerate(argv, outputDir) {
  const configFromPaths = extractConfigFromPaths(argv);
  require("./gen-icon-module").run(argv, configFromPaths, outputDir);
  // Runs AFTER the flat gen so it re-exports the current surface; purely
  // additive (a separate package tree), never touches the flat src just written.
  require("./gen-family-package").run(argv, configFromPaths, outputDir);
}

module.exports = { runPostGenerate, extractConfigFromPaths };
