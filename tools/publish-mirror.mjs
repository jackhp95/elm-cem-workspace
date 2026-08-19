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

import { execFileSync, spawnSync } from "node:child_process";
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

export function readState(statePath = STATE_PATH) {
  if (!existsSync(statePath)) return {};
  return JSON.parse(readFileSync(statePath, "utf8"));
}

function writeState(state, statePath = STATE_PATH) {
  writeFileSync(statePath, JSON.stringify(state, null, 2) + "\n");
}

// Root cause (2026-08-18, elm-typed-html + elm-html-intermediate-representation
// + elm-m3e all needed manual "Backfilled" notes): writeState() above only
// ever mutated the LOCAL file. Nothing in this script ever committed or
// pushed it back to elm-cem-workspace's own origin — every prior record
// reached origin only via a separate, manual, after-the-fact commit
// (confirmed: `git log --diff-filter=M -- tools/publish-mirror-state.json`
// shows exactly 3 commits, all hand-written "chore: record/backfill publish
// state", never authored by this script). Per repo convention every
// mutating subagent works in an ephemeral git worktree, so an uncommitted
// local write is one process-kill, permission-interrupt, or forgotten
// follow-up away from vanishing without a trace — exactly what happened
// each time. This makes the record durable in the SAME run, synchronously,
// so there is no separate step for a human/agent to forget.
function commitAndPushStateFile({ repoRoot, statePath, message }) {
  const branch = sh("git", ["-C", repoRoot, "rev-parse", "--abbrev-ref", "HEAD"]).trim();
  if (branch === "HEAD") {
    throw new Error(
      `${repoRoot} is in detached HEAD — refusing to auto-commit/push ` +
        `${path.relative(repoRoot, statePath)} from a detached checkout. Commit it manually.`,
    );
  }

  // Only stage the state file itself — never sweep up unrelated in-flight
  // changes that might exist elsewhere in this worktree.
  sh("git", ["-C", repoRoot, "add", "--", statePath]);
  const staged = sh("git", ["-C", repoRoot, "diff", "--cached", "--name-only"]).trim();
  if (staged) {
    sh("git", ["-C", repoRoot, "commit", "-m", message]);
  }

  for (let attempt = 1; attempt <= 2; attempt++) {
    const push = spawnSync("git", ["-C", repoRoot, "push", "origin", `HEAD:${branch}`], {
      encoding: "utf8",
    });
    if (push.status === 0) return;
    if (attempt === 2) {
      throw new Error(
        `git push of ${path.relative(repoRoot, statePath)} to origin/${branch} failed: ` +
          (push.stderr || push.stdout || `exit ${push.status}`),
      );
    }
    // origin/<branch> moved since we started (a concurrent publish of a
    // different package, or unrelated work landing on this branch) — merge
    // it in and retry exactly once. A merge, never a rebase: this process
    // must not rewrite commits it didn't create.
    sh("git", ["-C", repoRoot, "fetch", "origin", branch]);
    const merge = spawnSync("git", ["-C", repoRoot, "merge", "--no-edit", `origin/${branch}`], {
      encoding: "utf8",
    });
    if (merge.status !== 0) {
      spawnSync("git", ["-C", repoRoot, "merge", "--abort"], { encoding: "utf8" });
      throw new Error(
        `origin/${branch} moved and merging it in to push ${path.relative(repoRoot, statePath)} ` +
          `conflicted — resolve manually (the record is still committed locally): ` +
          (merge.stderr || merge.stdout),
      );
    }
  }
}

export function recordPublish({
  repoRoot = REPO_ROOT,
  statePath = STATE_PATH,
  name,
  workspaceSha,
  mirrorSha,
  publishedAt = new Date().toISOString(),
}) {
  const state = readState(statePath);
  state[name] = { publishedWorkspaceSha: workspaceSha, mirrorCommitSha: mirrorSha, publishedAt };
  writeState(state, statePath);
  commitAndPushStateFile({
    repoRoot,
    statePath,
    message: `chore(publish-mirror-state): record ${name}@${mirrorSha.slice(0, 8)} sync`,
  });
}

// Ground truth check: trusting the just-pushed clone's local `rev-parse
// HEAD` is *usually* right, but the only thing check-mirror-drift.mjs (and
// any future publish) actually cares about is what GitHub thinks
// jackhp95/<name>'s main is — so confirm that directly instead of assuming
// the local clone's post-push HEAD matches what landed. Cheap, and removes
// a whole class of "recorded the wrong SHA" drift.
function remoteHeadSha(remote, branch) {
  const out = sh("git", ["ls-remote", remote, `refs/heads/${branch}`]);
  const line = out.trim().split("\n")[0] ?? "";
  return line.split(/\s+/)[0] ?? "";
}

// Common baseline: files this workspace's root owns on behalf of every
// package (single lockfile, single pnpm-workspace.yaml), never mirrored.
const COMMON_EXCLUDE = new Set([
  "package-lock.json",
  "pnpm-lock.yaml",
  "pnpm-workspace.yaml",
]);

// Per-repo config, read from tools/family.json — the single manifest of
// "which packages exist, where, and what mirror/bundle-copy/copy-fidelity
// gates apply to them" (Theme 3 of the 2026-08-17 audit, "the manifest
// move" — this file used to carry its own independently-invented copy of
// this table). `mirror.auditedExclusions: true` means a `copyFidelity` block
// in family.json (checked by tools/copy-fidelity.mjs) already established
// this repo's authorized-absent set at migration time — cross-check
// tools/family.json + docs/copy-fidelity-notes.md before trusting a "clean"
// dry-run diff on first use for a package where it's false.
const rawFamily = JSON.parse(readFileSync(path.join(REPO_ROOT, "tools", "family.json"), "utf8")).packages;
const FAMILY = Object.fromEntries(
  Object.entries(rawFamily).map(([name, cfg]) => [
    name,
    { srcDir: cfg.srcDir, auditedExclusions: cfg.mirror?.auditedExclusions ?? false },
  ]),
);

function sh(cmd, args, opts = {}) {
  return execFileSync(cmd, args, { encoding: "utf8", ...opts });
}

// Finding 1.5 (docs/reviews/2026-08-17-thermonuclear-workspace-review.md):
// this script had no gate precondition at all — nothing stopped publishing a
// red/stale tree, and check-mirror-drift.mjs only ever catches that AFTER the
// fact (and only if the publish state was committed). A real `--push` run
// now refuses unless `tools/gate-all.mjs` — "the ONE command that proves the
// whole workspace is green" — passes first. This runs the FULL workspace
// gate, not just the one package being published, because a mirror publish
// is a public, hard-to-reverse action (this pushes to a real GitHub repo)
// and the family's own facts-bundle fan-out means packages are not
// independently verifiable in isolation anyway.
function assertGateAllPasses() {
  if (process.env.SKIP_GATE === "1") {
    console.warn(
      "WARN: SKIP_GATE=1 — publishing WITHOUT running tools/gate-all.mjs first. " +
        "This is exactly the gap that let the 2026-08-12->17 mirror-fork incident " +
        "happen undetected (finding 1.5). Only use this if gate-all has already " +
        "been verified green through another path in this same run.",
    );
    return;
  }
  console.log("\n=== Gate precondition: running `node tools/gate-all.mjs` before publishing ===\n");
  const gate = spawnSync(process.execPath, [path.join(REPO_ROOT, "tools", "gate-all.mjs")], {
    stdio: "inherit",
    cwd: REPO_ROOT,
  });
  if (gate.status !== 0) {
    console.error(
      "\nERROR: tools/gate-all.mjs failed — refusing to publish a red/stale tree " +
        "(finding 1.5's gate precondition). Fix the gate and re-run, or set " +
        "SKIP_GATE=1 to override deliberately (not recommended).",
    );
    process.exit(1);
  }
  console.log("\n=== Gate precondition passed — proceeding with publish ===\n");
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

  // Gate precondition (finding 1.5) — run BEFORE any clone/wipe work below, so
  // a red tree fails fast instead of after several minutes of mirror setup.
  // Only a real `--push --yes-i-am-sure` run pays for this; a dry run does
  // not push anywhere, so there is nothing to gate.
  if (push && yes) assertGateAllPasses();

  const cfg = FAMILY[name];
  const srcAbs = path.join(REPO_ROOT, cfg.srcDir);
  if (!existsSync(srcAbs)) {
    console.error(`ERROR: ${cfg.srcDir} does not exist in this workspace.`);
    process.exit(1);
  }
  if (!cfg.auditedExclusions) {
    console.warn(
      `WARN: ${name} has no copyFidelity block in tools/family.json (no ` +
        `\`node tools/copy-fidelity.mjs ${name}\` gate), so its authorized-absent ` +
        `file set has never been audited. This script only excludes the ` +
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

  // Confirm what GitHub actually has, not just what our local clone thinks
  // it just pushed.
  const liveSha = remoteHeadSha(remote, "main");
  if (liveSha !== mirrorSha) {
    console.error(
      `FATAL: push to jackhp95/${name} reported success, but \`git ls-remote\` shows main ` +
        `is at ${liveSha || "(nothing)"}, not the pushed ${mirrorSha}. Refusing to record a ` +
        `state entry that doesn't match reality — investigate the mirror directly before retrying.`,
    );
    process.exit(1);
  }
  console.log(`Pushed to jackhp95/${name}: ${commitMsg} (${mirrorSha}) — verified via ls-remote.`);

  const workspaceShaFull = sh("git", ["-C", REPO_ROOT, "rev-parse", "HEAD"]).trim();
  const publishedAt = new Date().toISOString();
  try {
    recordPublish({ name, workspaceSha: workspaceShaFull, mirrorSha, publishedAt });
  } catch (err) {
    console.error(
      `\nFATAL: mirror push for ${name} SUCCEEDED and is verified live at jackhp95/${name}@` +
        `${mirrorSha} — but recording + pushing that fact to tools/publish-mirror-state.json ` +
        `failed, so it is NOT yet durable:\n  ${err.message}\n\n` +
        `Do NOT re-run --push (that republishes, harmlessly, but won't fix this). Instead, ` +
        `manually add this record, then commit + push tools/publish-mirror-state.json yourself:\n` +
        `  "${name}": {\n` +
        `    "publishedWorkspaceSha": "${workspaceShaFull}",\n` +
        `    "mirrorCommitSha": "${mirrorSha}",\n` +
        `    "publishedAt": "${publishedAt}",\n` +
        `    "note": "Backfilled — mirror push succeeded but publish-mirror.mjs's own state-commit failed: ${err.message}"\n` +
        `  }`,
    );
    process.exit(1);
  }
  console.log(
    `Recorded + pushed publish state for ${name} to origin — tools/publish-mirror-state.json ` +
      `now durably reflects this publish (this is what tools/check-mirror-drift.mjs compares ` +
      `the live repo against). No manual follow-up needed.`,
  );
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
