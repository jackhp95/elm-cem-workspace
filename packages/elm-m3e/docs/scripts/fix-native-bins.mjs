/**
 * pnpm 10 wraps ALL bin entries with `exec node <path>` shell scripts.
 * Native binaries (elm, elm-format, lamdera) are Mach-O executables — not JS.
 * This script replaces the broken shims with direct symlinks after install.
 *
 * docs/ used to be an npm-managed subproject (its own package-lock.json),
 * where npm's plain symlink bins never hit this problem. Now that it is a
 * pnpm workspace member (matched by the root pnpm-workspace.yaml packages
 * glob), it needs the same fix elm-m3e's own scripts/fix-native-bins.mjs
 * applies.
 */
import { symlinkSync, unlinkSync, realpathSync } from "node:fs";
import { resolve } from "node:path";

const root = resolve(import.meta.dirname, "..");
// Resolved via the package's own node_modules/<pkg>/bin/<pkg> — that path is
// always correct regardless of where pnpm's content-addressable store actually
// lives (a standalone repo's own node_modules/.pnpm, or a workspace root's,
// when this package is installed as a workspace member).
const bins = {
  elm: "node_modules/elm/bin/elm",
  "elm-format": "node_modules/elm-format/bin/elm-format",
  lamdera: "node_modules/lamdera/bin/lamdera",
};

for (const [name, relative] of Object.entries(bins)) {
  const target = realpathSync(resolve(root, relative));
  const link = resolve(root, "node_modules/.bin", name);
  try {
    unlinkSync(link);
  } catch {}
  symlinkSync(target, link);
}
