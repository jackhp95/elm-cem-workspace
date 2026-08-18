#!/usr/bin/env node
// tools/hooks-install.mjs — set core.hooksPath to this workspace's ONE root
// hooks/ directory, using an ABSOLUTE path.
//
// Fixes findings 1.2/1.3 of docs/reviews/2026-08-17-thermonuclear-workspace-review.md:
// seven folded-in packages each shipped a `hooks:install` writing
// `git config core.hooksPath hooks` (a RELATIVE path) from their own package
// directory — whichever ran last silently won, discarding the others. There
// is exactly one git repository here, so an absolute path removes the
// ambiguity structurally: every package's `hooks:install` script now calls
// this same file (see each package.json), so no matter which one a human or
// agent runs out of old muscle memory, the result converges on the same
// value instead of contending over it.

import { execFileSync } from "node:child_process";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const hooksDir = path.join(repoRoot, "hooks");

execFileSync("git", ["config", "core.hooksPath", hooksDir], { stdio: "inherit" });
console.log(
  `hooks-install: core.hooksPath set to ${hooksDir} — the workspace-root hook, which runs ` +
    `\`node tools/gate-all.mjs\` on every push (see hooks/pre-push).`,
);
