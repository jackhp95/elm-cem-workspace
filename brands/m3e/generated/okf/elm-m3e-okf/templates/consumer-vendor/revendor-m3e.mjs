#!/usr/bin/env node
// revendor-m3e.mjs — the SOLE writer of a consumer's `vendor/` M3e trees.
//
// WHY THIS EXISTS (committed-copy vendoring, per the rollout plan §5.1b)
//   The elm-m3e / elm-cem family is unpublished. External Elm consumers can't
//   list it as an `elm.json` dependency, so they vendor a COMMITTED COPY of the
//   canonical source trees (like a normal pinned dep they happen to copy by
//   hand). A symlink scheme was rejected because symlinks don't survive a
//   CI/deploy clone (Netlify/Cloudflare/cloudflared/GH Actions clone only the
//   consumer repo). A committed copy compiles everywhere with zero extra setup.
//
//   The hazard a committed copy introduces is DRIFT: a consumer hand-edits the
//   vendored copy (diverging from canonical, invisibly), or lets it rot behind
//   canonical. This script is one half of the guard: it is the ONLY sanctioned
//   way `vendor/` changes, and it writes a manifest that the drift gate
//   (check-vendor.mjs, Layer 1) and the elm-review rule (NoHandEditedGeneratedM3e,
//   Layer 2) both read to detect any hand-edit.
//
// WHAT IT DOES
//   Extract the canonical source trees FROM elm-cem-workspace AT A PINNED COMMIT
//   (not "whatever the working tree happens to be") into the consumer's vendor/,
//   then write:
//     - vendor/<dest>/...            the copied trees (this script OWNS these dirs)
//     - vendor/m3e-manifest.json     { schema, algo, source, files:{relpath:{sha256,len}} }
//     - vendor/VENDORED_FROM.json    human-readable pin record (repo + commit + trees)
//
//   Pinning is real: the trees are read via `git archive <commit>:<srcPath>`, so
//   the copy reflects EXACTLY that commit regardless of local edits. Bumping a
//   consumer = re-run with a new --commit, review the vendor/ diff, commit.
//
// SOURCE RESOLUTION (CI-portable, no monorepo leak)
//   1. A co-located elm-cem-workspace checkout (—workspace, $ELM_CEM_WORKSPACE,
//      or ~/Documents/code/elm-cem-workspace). The pinned commit is fetched if
//      not already present.
//   2. Fallback: a shallow fetch of the pinned commit from the published GitHub
//      mirror (https://github.com/jackhp95/elm-cem-workspace.git), cached in tmp.
//      This is the same fallback pattern as elm-review-cem/bin/stage-facts-elm-home.mjs.
//
// USAGE
//   node revendor-m3e.mjs --commit <40-hex-sha> [options]
//     --commit <ref>       Commit-ish to pin: full/short SHA, branch, or tag. It
//                          is EXPANDED to the full 40-char SHA before the manifest
//                          is written (CI mirror fetch-by-SHA only resolves a full
//                          SHA — see expandCommit). Defaults to the resolved
//                          workspace HEAD (with a warning) if omitted.
//     --consumer <path>    consumer repo root (default: cwd) — where vendor/ lives.
//     --workspace <path>   co-located elm-cem-workspace checkout (else env/default/mirror).
//     --trees a,b,c        subset of {elm-m3e,elm-html-ir,cem-facts} (default: all three).
//
//   Importing this module never copies anything — only running it as a script does.
//   check-vendor.mjs imports copyTreesInto/computeManifest from here so the drift
//   gate re-runs the EXACT same copy logic instead of reimplementing the file list.

import {
  existsSync, mkdirSync, readFileSync, readdirSync, rmSync, writeFileSync,
} from "node:fs";
import { createHash } from "node:crypto";
import { homedir, tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath, pathToFileURL } from "node:url";

export const MANIFEST_NAME = "m3e-manifest.json";
export const PROVENANCE_NAME = "VENDORED_FROM.json";
export const MANIFEST_SCHEMA = "m3e-vendor-manifest/1";
export const SOURCE_REPO = "jackhp95/elm-cem-workspace";
export const MIRROR_URL =
  process.env.ELM_CEM_WORKSPACE_GIT_URL || "https://github.com/jackhp95/elm-cem-workspace.git";

// The canonical trees a consumer may vendor. `dest` is relative to the consumer
// root; the manifest keys are consumer-root-relative (`vendor/<dest-basename>/...`)
// so the elm-review rule — which globs `vendor/**` relative to the project's
// elm.json — can compare against them with a direct dict lookup.
export const DEFAULT_TREES = [
  { name: "elm-m3e", srcPath: "brands/m3e/generated/package/elm-m3e/src", dest: "vendor/elm-m3e" },
  {
    name: "elm-html-ir",
    srcPath: "core/elm-html-intermediate-representation/src",
    dest: "vendor/elm-html-ir",
  },
  { name: "cem-facts", srcPath: "core/elm-cem/facts/src", dest: "vendor/cem-facts" },
];

const MAX_BUFFER = 1 << 30; // 1 GiB — the elm-m3e src tree is ~138 modules.

// Scrub inherited GIT_DIR/GIT_WORK_TREE/GIT_INDEX_FILE: `-C dir` changes cwd
// for path resolution but does NOT override an inherited GIT_DIR, so when
// this template runs from inside a git hook of the CONSUMER repo that
// vendored it (git sets GIT_DIR for every hook invocation), every `git -C
// <workspaceDir|cacheDir>` call below would silently operate on the
// consumer's OUTER repo instead of the referenced elm-cem-workspace checkout
// or mirror cache — same class of bug fixed in fetch-snapshots.mjs /
// copy-fidelity.mjs (see those files' comments); fixed the same way.
const gitEnv = { ...process.env };
delete gitEnv.GIT_DIR;
delete gitEnv.GIT_WORK_TREE;
delete gitEnv.GIT_INDEX_FILE;

function run(cmd, args, opts = {}) {
  return spawnSync(cmd, args, { maxBuffer: MAX_BUFFER, encoding: "buffer", env: gitEnv, ...opts });
}

function isGitRepo(dir) {
  if (!dir || !existsSync(dir)) return false;
  const r = run("git", ["-C", dir, "rev-parse", "--git-dir"]);
  return r.status === 0;
}

function commitPresent(dir, commit) {
  const r = run("git", ["-C", dir, "cat-file", "-e", `${commit}^{commit}`]);
  return r.status === 0;
}

// Ensure `commit` is an object in `dir`, fetching it from origin if missing.
function ensureCommit(dir, commit) {
  if (commitPresent(dir, commit)) return;
  run("git", ["-C", dir, "fetch", "--depth", "1", "origin", commit], { stdio: "inherit", encoding: "utf8" });
  if (!commitPresent(dir, commit)) {
    throw new Error(
      `commit ${commit} not found in ${dir} and could not be fetched from origin. ` +
        `Pass a commit that exists on the workspace remote, or point --workspace at a checkout that has it.`,
    );
  }
}

// Fallback: shallow-fetch the pinned commit from the published GitHub mirror
// into a tmp cache and return that dir. Models stage-facts-elm-home.mjs.
function mirrorFetch(commit) {
  const cacheDir = join(tmpdir(), "elm-cem-workspace-mirror-cache");
  if (!isGitRepo(cacheDir)) {
    rmSync(cacheDir, { recursive: true, force: true });
    mkdirSync(cacheDir, { recursive: true });
    run("git", ["-C", cacheDir, "init", "-q"], { stdio: "inherit", encoding: "utf8" });
    run("git", ["-C", cacheDir, "remote", "add", "origin", MIRROR_URL], { encoding: "utf8" });
  }
  console.log(`revendor-m3e: fetching pinned commit ${commit} from ${MIRROR_URL} (no co-located workspace)`);
  // Fetch-by-SHA relies on the host allowing reachable-SHA1-in-want (GitHub does).
  // A non-GitHub ELM_CEM_WORKSPACE_GIT_URL may need a branch fetch + checkout instead.
  const f = run("git", ["-C", cacheDir, "fetch", "--depth", "1", "origin", commit], { stdio: "inherit", encoding: "utf8" });
  if (f.status !== 0 || !commitPresent(cacheDir, commit)) {
    throw new Error(`could not fetch ${commit} from ${MIRROR_URL}; set ELM_CEM_WORKSPACE_GIT_URL or use --workspace`);
  }
  return cacheDir;
}

// Returns { dir, kind: "local" | "mirror" }. `dir` is a workspace checkout with
// `commit` present, ready for `git archive`.
export function resolveWorkspace({ workspace, commit } = {}) {
  const candidates = [
    workspace,
    process.env.ELM_CEM_WORKSPACE,
    join(homedir(), "Documents", "code", "elm-cem-workspace"),
  ].filter(Boolean);
  for (const c of candidates) {
    if (isGitRepo(c)) {
      ensureCommit(c, commit);
      return { dir: resolve(c), kind: "local" };
    }
  }
  return { dir: mirrorFetch(commit), kind: "mirror" };
}

// Resolve any commit-ish (full/short SHA, branch, tag, HEAD) to its full 40-char
// commit SHA, verified present in `workspaceDir`. The manifest MUST store the
// FULL SHA: check-vendor.mjs (and any CI drift gate) fetches canonical@pin from
// the public GitHub mirror BY SHA, and GitHub's fetch-by-SHA
// (uploadpack.allowReachableSHA1InWant) only resolves a full 40-char SHA — a
// short SHA fails "couldn't find remote ref". Expanding here is the single choke
// point that guarantees a full SHA regardless of what the caller passed
// (rollout plan §11.7).
export function expandCommit(workspaceDir, ref) {
  const r = run("git", ["-C", workspaceDir, "rev-parse", "--verify", "--quiet", `${ref}^{commit}`], {
    encoding: "utf8",
  });
  const full = (r.stdout || "").toString().trim();
  if (r.status !== 0 || !/^[0-9a-f]{40}$/.test(full)) {
    throw new Error(
      `could not resolve "${ref}" to a full 40-char commit SHA in ${workspaceDir}. ` +
        `Pass a commit-ish that exists there (SHA, branch, tag, or HEAD).` +
        (r.stderr ? `\n${r.stderr.toString().trim()}` : ""),
    );
  }
  return full;
}

// Extract the tree at <commit>:<srcPath> into destDir (files land relative to
// the subtree root). Pins to the exact commit, ignoring the working tree.
function extractTreeAt(workspaceDir, commit, srcPath, destDir) {
  mkdirSync(destDir, { recursive: true });
  const archive = run("git", ["-C", workspaceDir, "archive", "--format=tar", `${commit}:${srcPath}`]);
  if (archive.status !== 0) {
    throw new Error(`git archive ${commit}:${srcPath} failed:\n${archive.stderr?.toString() || ""}`);
  }
  const tarRes = spawnSync("tar", ["-x", "-C", destDir], { input: archive.stdout, maxBuffer: MAX_BUFFER });
  if (tarRes.status !== 0) {
    throw new Error(`tar extract into ${destDir} failed:\n${tarRes.stderr?.toString() || ""}`);
  }
}

// Copy each configured tree into consumerRoot/<dest>, wiping the dest first so
// upstream deletions propagate. Owns ONLY the configured dest dirs.
export function copyTreesInto(consumerRoot, { workspaceDir, commit, trees }) {
  for (const t of trees) {
    const destAbs = join(consumerRoot, t.dest);
    rmSync(destAbs, { recursive: true, force: true });
    extractTreeAt(workspaceDir, commit, t.srcPath, destAbs);
  }
}

function sha256(buf) {
  return createHash("sha256").update(buf).digest("hex");
}

// Every file under `dir`, as { rel, abs }, sorted, rel using forward slashes.
function walkFiles(dir, relBase = "") {
  const out = [];
  if (!existsSync(dir)) return out;
  for (const entry of readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
    const abs = join(dir, entry.name);
    const rel = relBase ? `${relBase}/${entry.name}` : entry.name;
    if (entry.isDirectory()) out.push(...walkFiles(abs, rel));
    else out.push({ rel, abs });
  }
  return out;
}

// Build the manifest `files` map from the vendored trees under consumerRoot.
// Keys are consumer-root-relative (`<dest>/<relWithinTree>`). Per file:
//   sha256 — over raw bytes (Layer 1 / check-vendor authority + external verify).
//   len    — the .length of the UTF-8-decoded content. This is the JS String
//            length; at review time elm-review runs on Node and hands the rule
//            the identical JS string, so Elm's `String.length` equals this by
//            construction — a parity-safe content-change signal for Layer 2 that
//            needs no sha256 implementation in Elm. (Byte-exactness stays Layer 1's job.)
export function computeManifest(consumerRoot, trees) {
  /** @type {Record<string, {sha256: string, len: number}>} */
  const files = {};
  for (const t of trees) {
    const destAbs = join(consumerRoot, t.dest);
    for (const { rel, abs } of walkFiles(destAbs)) {
      const key = `${t.dest}/${rel}`;
      const bytes = readFileSync(abs);
      files[key] = { sha256: sha256(bytes), len: bytes.toString("utf8").length };
    }
  }
  // Deterministic key order for a stable, diffable manifest.
  return Object.fromEntries(Object.keys(files).sort().map((k) => [k, files[k]]));
}

function stableJson(obj) {
  return JSON.stringify(obj, null, 2) + "\n";
}

export function writeManifest(consumerRoot, { commit, trees, files, kind }) {
  const source = {
    repo: SOURCE_REPO,
    commit,
    vendoredVia: kind,
    vendoredAt: new Date().toISOString(),
    trees: trees.map(({ name, srcPath, dest }) => ({ name, srcPath, dest })),
  };
  const manifest = { schema: MANIFEST_SCHEMA, algo: "sha256", source, files };
  writeFileSync(join(consumerRoot, "vendor", MANIFEST_NAME), stableJson(manifest));

  const provenance = {
    sourceRepo: SOURCE_REPO,
    commit,
    vendoredVia: kind,
    vendoredAt: source.vendoredAt,
    trees: source.trees,
    note:
      "Committed copy of unpublished elm-cem-workspace source. DO NOT hand-edit vendor/. " +
      "Re-run scripts/revendor-m3e.mjs with a new --commit to update; check-vendor + " +
      "the NoHandEditedGeneratedM3e elm-review rule enforce this.",
  };
  writeFileSync(join(consumerRoot, "vendor", PROVENANCE_NAME), stableJson(provenance));
}

function parseArgs(argv) {
  const args = { trees: null, commit: null, consumer: process.cwd(), workspace: null };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--commit") args.commit = argv[++i];
    else if (a === "--consumer") args.consumer = resolve(argv[++i]);
    else if (a === "--workspace") args.workspace = resolve(argv[++i]);
    else if (a === "--trees") args.trees = argv[++i];
    else throw new Error(`unknown argument: ${a}`);
  }
  return args;
}

function selectTrees(spec) {
  if (!spec) return DEFAULT_TREES;
  const names = spec.split(",").map((s) => s.trim()).filter(Boolean);
  const picked = names.map((n) => {
    const t = DEFAULT_TREES.find((d) => d.name === n);
    if (!t) throw new Error(`unknown tree "${n}"; known: ${DEFAULT_TREES.map((d) => d.name).join(", ")}`);
    return t;
  });
  return picked;
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const trees = selectTrees(args.trees);

  // resolveWorkspace guarantees the requested commit-ish is present (local:
  // ensureCommit; mirror: mirrorFetch throws otherwise). Whatever was passed
  // (short SHA / branch / tag / HEAD) is then EXPANDED to the full 40-char SHA
  // before anything is written — the manifest must pin a full SHA so the CI
  // mirror fetch-by-SHA can resolve it (see expandCommit).
  const requested = args.commit || "HEAD";
  const { dir: workspaceDir, kind } = resolveWorkspace({ workspace: args.workspace, commit: requested });
  const commit = expandCommit(workspaceDir, requested);
  if (!args.commit) {
    console.warn(
      `revendor-m3e: WARNING — no --commit given; pinning to workspace HEAD ${commit}. ` +
        `Pass --commit explicitly for reproducible vendoring.`,
    );
  }

  mkdirSync(join(args.consumer, "vendor"), { recursive: true });
  copyTreesInto(args.consumer, { workspaceDir, commit, trees });
  const files = computeManifest(args.consumer, trees);
  writeManifest(args.consumer, { commit, trees, files, kind });

  const n = Object.keys(files).length;
  console.log(
    `revendor-m3e: OK — vendored ${trees.length} tree(s), ${n} file(s) from ${SOURCE_REPO}@${commit.slice(0, 12)} ` +
      `(${kind}) into ${args.consumer}/vendor/. Review the diff and commit.`,
  );
}

// CLI guard: importing this module (check-vendor.mjs does) must not copy anything.
if (import.meta.url === pathToFileURL(process.argv[1] || "").href) {
  try {
    main();
  } catch (e) {
    console.error(`revendor-m3e: FAIL — ${e.message}`);
    process.exit(1);
  }
}
