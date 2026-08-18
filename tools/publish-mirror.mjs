#!/usr/bin/env node
// tools/publish-mirror.mjs — publish a workspace package to its standalone
// github.com/jackhp95/<name> mirror repo.
//
// Context: elm-cem-workspace absorbed 9 sibling repos in a 2026-08-12 flat
// copy. The intent (docs/plans/2026-08-17-standalone-repo-realignment.md)
// is monorepo-canonical, standalone-repos-are-read-only-mirrors — but no
// tooling ever existed to actually publish workspace state back out. This
// is that tooling. It is DRY-RUN BY DEFAULT: it always shows you the diff
// it would push and never touches the remote unless you pass both --push
// and --yes-i-am-sure.
//
// Usage:
//   node tools/publish-mirror.mjs <name> [--push --yes-i-am-sure] [--cache-dir=<dir>]
//
// Exit codes: 0 = ran (dry-run report, or successful push); 1 = usage/config
// error; 2 = the mirror clone already matches the workspace (nothing to do).

import { execFileSync } from "node:child_process";
import {
  existsSync,
  mkdirSync,
  rmSync,
  cpSync,
  readdirSync,
  readFileSync,
  writeFileSync,
} from "node:fs";
import path from "node:path";

const REPO_ROOT = path.resolve(new URL(".", import.meta.url).pathname, "..");
const STATE_PATH = path.join(REPO_ROOT, "tools", "publish-mirror-state.json");

export function readState() {
  if (!existsSync(STATE_PATH)) return {};
  return JSON.parse(readFileSync(STATE_PATH, "utf8"));
}

function writeState(state) {
  writeFileSync(STATE_PATH, JSON.stringify(state, null, 2) + "\n");
}

// Common baseline: files this workspace's root owns on behalf of every
// package (single lockfile, single pnpm-workspace.yaml), never mirrored.
const COMMON_EXCLUDE = new Set([
  "package-lock.json",
  "pnpm-lock.yaml",
  "pnpm-workspace.yaml",
]);

// Per-repo config. `auditedExclusions: true` means a tools/copy-fidelity-*.sh
// gate already established this repo's authorized-absent set at migration
// time (see that script for the full list — this table only repeats the
// common baseline, not every idiosyncratic entry, so cross-check before
// trusting a "clean" dry-run diff on first use).
const FAMILY = {
  "elm-cem": { srcDir: "packages/elm-cem", auditedExclusions: false },
  "elm-m3e": { srcDir: "packages/elm-m3e", auditedExclusions: true },
  "elm-cem-compose": { srcDir: "packages/elm-cem-compose", auditedExclusions: false },
  "elm-html-intermediate-representation": {
    srcDir: "packages/elm-html-intermediate-representation",
    auditedExclusions: false,
  },
  "elm-review-cem": { srcDir: "packages/elm-review-cem", auditedExclusions: false },
  "elm-typed-html": { srcDir: "packages/elm-typed-html", auditedExclusions: false },
  "m3e-okf": { srcDir: "packages/m3e-okf", auditedExclusions: true },
  "tailwind-m3e-web": { srcDir: "packages/tailwind-m3e-web", auditedExclusions: true },
  "elm-cem-facts": { srcDir: "packages/elm-cem/facts", auditedExclusions: false },
  "cem-figma-connect": { srcDir: "packages/cem-figma-connect", auditedExclusions: true },
};

function sh(cmd, args, opts = {}) {
  return execFileSync(cmd, args, { encoding: "utf8", ...opts });
}

function main() {
  const argv = process.argv.slice(2);
  const name = argv.find((a) => !a.startsWith("--"));
  const push = argv.includes("--push");
  const yes = argv.includes("--yes-i-am-sure");
  const cacheDirArg = argv.find((a) => a.startsWith("--cache-dir="));
  const cacheDir = cacheDirArg
    ? cacheDirArg.slice("--cache-dir=".length)
    : path.join(REPO_ROOT, ".cache", "publish-mirror");

  if (!name || !FAMILY[name]) {
    console.error(
      `Usage: node tools/publish-mirror.mjs <name> [--push --yes-i-am-sure] [--cache-dir=<dir>]\n` +
        `Known names: ${Object.keys(FAMILY).join(", ")}`,
    );
    process.exit(1);
  }

  const cfg = FAMILY[name];
  const srcAbs = path.join(REPO_ROOT, cfg.srcDir);
  if (!existsSync(srcAbs)) {
    console.error(`ERROR: ${cfg.srcDir} does not exist in this workspace.`);
    process.exit(1);
  }
  if (!cfg.auditedExclusions) {
    console.warn(
      `WARN: ${name} has no tools/copy-fidelity-${name}.sh gate, so its authorized-` +
        `absent file set has never been audited. This script only excludes the ` +
        `common baseline (lockfiles, pnpm-workspace.yaml) — review the dry-run ` +
        `diff closely before trusting it for this repo.`,
    );
  }

  const remote = `https://github.com/jackhp95/${name}.git`;
  const cloneDir = path.join(cacheDir, name);
  mkdirSync(cacheDir, { recursive: true });

  if (existsSync(cloneDir)) {
    console.log(`Refreshing existing clone at ${cloneDir}...`);
    sh("git", ["-C", cloneDir, "fetch", "origin", "main"]);
    sh("git", ["-C", cloneDir, "reset", "--hard", "origin/main"]);
    sh("git", ["-C", cloneDir, "clean", "-fdx"]);
  } else {
    console.log(`Cloning ${remote} into ${cloneDir}...`);
    sh("git", ["clone", "--depth", "1", remote, cloneDir]);
  }

  // Tracked files only, per the same "compared as GIT-TRACKED SETS, not
  // directory listings" semantics the copy-fidelity gates use — build
  // output and node_modules must never leak into the mirror.
  const trackedRel = sh("git", ["-C", REPO_ROOT, "ls-files", "--", cfg.srcDir])
    .trim()
    .split("\n")
    .filter(Boolean)
    .map((p) => path.relative(cfg.srcDir, p))
    .filter((rel) => !COMMON_EXCLUDE.has(rel));

  // Wipe the clone's tracked tree (keep .git), then repopulate from the
  // workspace's current tracked set — this makes the mirror commit a true
  // reflection of "workspace state right now," not an incremental patch.
  for (const entry of readdirSync(cloneDir)) {
    if (entry === ".git") continue;
    rmSync(path.join(cloneDir, entry), { recursive: true, force: true });
  }
  for (const rel of trackedRel) {
    const from = path.join(srcAbs, rel);
    const to = path.join(cloneDir, rel);
    mkdirSync(path.dirname(to), { recursive: true });
    // verbatimSymlinks: without it, Node resolves a relative symlink
    // target (e.g. packages/elm-cem/elm-html-intermediate-representation ->
    // ../elm-html-intermediate-representation) to an absolute, host-local
    // path before writing it into the mirror clone — corrupting it for
    // anyone who isn't on this machine. Found by the elm-cem publish audit.
    cpSync(from, to, { recursive: true, verbatimSymlinks: true });
  }

  // The workspace root's .gitignore already covers elm-stuff/, node_modules/,
  // etc. for every package, so no individual package tracks its own — but a
  // standalone mirror consumer has no root .gitignore to inherit. Regenerate
  // a minimal one whenever the workspace didn't supply one for this package
  // (found via the elm-cem-facts publish audit, where wiping-then-repopulate
  // was silently deleting the mirror's only .gitignore on every publish).
  if (!existsSync(path.join(cloneDir, ".gitignore"))) {
    writeFileSync(path.join(cloneDir, ".gitignore"), "elm-stuff/\nnode_modules/\n");
  }

  sh("git", ["-C", cloneDir, "add", "-A"]);
  const diffStat = sh("git", ["-C", cloneDir, "diff", "--cached", "--stat"]).trim();

  if (!diffStat) {
    console.log(`Mirror for ${name} already matches the workspace. Nothing to publish.`);
    process.exit(2);
  }

  console.log(`\n=== Dry-run diff: what would be pushed to jackhp95/${name} ===\n`);
  console.log(diffStat);

  const workspaceSha = sh("git", ["-C", REPO_ROOT, "rev-parse", "--short", "HEAD"]).trim();
  const commitMsg = `sync: publish from elm-cem-workspace@${workspaceSha}`;

  if (!push) {
    console.log(
      `\nDry run only — nothing pushed. Re-run with --push --yes-i-am-sure to ` +
        `actually commit and push this to jackhp95/${name}'s main branch.\n` +
        `(Clone left at ${cloneDir} for inspection.)`,
    );
    process.exit(0);
  }

  if (!yes) {
    console.error(
      `ERROR: --push requires --yes-i-am-sure too (this pushes to a public GitHub ` +
        `repo — no accidental pushes).`,
    );
    process.exit(1);
  }

  sh("git", ["-C", cloneDir, "commit", "-m", commitMsg]);
  sh("git", ["-C", cloneDir, "push", "origin", "HEAD:main"]);
  const mirrorSha = sh("git", ["-C", cloneDir, "rev-parse", "HEAD"]).trim();
  console.log(`Pushed to jackhp95/${name}: ${commitMsg} (${mirrorSha})`);

  const state = readState();
  state[name] = {
    publishedWorkspaceSha: sh("git", ["-C", REPO_ROOT, "rev-parse", "HEAD"]).trim(),
    mirrorCommitSha: mirrorSha,
    publishedAt: new Date().toISOString(),
  };
  writeState(state);
  console.log(`Recorded publish state in tools/publish-mirror-state.json — this is what` +
    ` tools/check-mirror-drift.mjs compares the live repo against.`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
