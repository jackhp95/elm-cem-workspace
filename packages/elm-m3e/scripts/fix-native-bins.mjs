/**
 * pnpm 10 wraps ALL bin entries with `exec node <path>` shell scripts.
 * Native Elm binaries (elm, elm-format) are Mach-O executables — not JS.
 * This script replaces the broken shims with direct symlinks after install.
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
};

for (const [name, relative] of Object.entries(bins)) {
  const target = realpathSync(resolve(root, relative));
  const link = resolve(root, "node_modules/.bin", name);
  try {
    unlinkSync(link);
  } catch {}
  symlinkSync(target, link);
}
