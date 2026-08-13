// Node ESM `resolve` hook: retries a failed specifier with a `.js` extension
// appended before giving up.
//
// Workaround for a real upstream bug in @material/material-color-utilities@0.4.0's
// published ESM output — several of its own internal relative imports (e.g.
// scheme/scheme_neutral.js -> ../dynamiccolor/dynamic_scheme, no extension)
// omit the required `.js` extension. Bundlers (Vite, webpack, etc.) resolve
// extensionless specifiers permissively and never hit this; Node's own
// strict ESM loader does not, and throws ERR_MODULE_NOT_FOUND. Confirmed by
// direct `node -e "import('@material/material-color-utilities')"` in this
// repo — plan Task 4's "confirm the API" step read the package's source but
// did not actually execute an import under plain Node, so this gap wasn't
// caught until Task 5. See the friction log for this session.
//
// Scoped as narrowly as possible: only intercepts resolution failures whose
// parent module path contains `@material/material-color-utilities`, and only
// retries once with `.js` appended — anything else passes through untouched.

export async function resolve(specifier, context, nextResolve) {
  try {
    return await nextResolve(specifier, context);
  } catch (err) {
    const parentIsMaterialColorUtils =
      typeof context.parentURL === "string" &&
      context.parentURL.includes("@material/material-color-utilities") &&
      specifier.startsWith(".") &&
      !specifier.endsWith(".js");

    if (err?.code === "ERR_MODULE_NOT_FOUND" && parentIsMaterialColorUtils) {
      return nextResolve(`${specifier}.js`, context);
    }
    throw err;
  }
}
