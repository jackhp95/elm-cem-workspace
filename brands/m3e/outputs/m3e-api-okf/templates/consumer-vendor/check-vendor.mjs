#!/usr/bin/env node
// check-vendor.mjs — Layer 1 anti-drift gate (the gate of record, per plan §5.2).
//
// Deterministic, language-agnostic, CI-portable. Runs in a consumer's pre-push /
// CI. FAILS if the committed vendor/ has drifted from canonical@pin in either
// direction:
//
//   (A) manifest honesty  — the committed vendor/ files must match the committed
//       vendor/m3e-manifest.json. Catches a file edited (or added/deleted) without
//       re-running revendor, and a manifest tampered to hide it.
//
//   (B) currency vs pin   — the committed manifest must match a FRESH extraction
//       of canonical AT THE PINNED COMMIT. Catches a hand-edit that also updated
//       the manifest to be self-consistent (A passes, B fails), since canonical@pin
//       is the third independent reference.
//
//   Transitively: committed files == committed manifest == canonical@pin.
//
// The DEFAULT check is PINNED-COMMIT-SCOPED: it must NOT spuriously fail every
// consumer on every upstream commit — upgrades are reviewed pin bumps (like
// `npm update`), not a moving target. `--check-stale` additionally compares the
// pin against the workspace's current HEAD and reports (non-fatally) if canonical
// has moved ahead, i.e. "a bump is available."
//
// CI portability: when no workspace is co-located, canonical@pin is fetched from
// the published GitHub mirror (see revendor-m3e.mjs resolveWorkspace) — self-
// contained, no monorepo checkout leaked into the pipeline.
//
// Reuses copyTreesInto/computeManifest from revendor-m3e.mjs (single source of
// the copy logic), exactly as docs/scripts/check-vendor-drift.mjs reuses
// vendor-foundation.mjs's copyFoundationInto.

import { existsSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import {
  MANIFEST_NAME, computeManifest, copyTreesInto, resolveWorkspace,
} from "./revendor-m3e.mjs";

function fail(msg) {
  console.error(`check:vendor: FAIL — ${msg}`);
  process.exit(1);
}

function parseArgs(argv) {
  const args = { consumer: process.cwd(), workspace: null, checkStale: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === "--consumer") args.consumer = resolve(argv[++i]);
    else if (a === "--workspace") args.workspace = resolve(argv[++i]);
    else if (a === "--check-stale") args.checkStale = true;
    else fail(`unknown argument: ${a}`);
  }
  return args;
}

// Compare two {key:{sha256,len}} maps. Returns { added, removed, changed }.
//   added   — keys in `have` not in `want`
//   removed — keys in `want` not in `have`
//   changed — shared keys whose sha256 differs
function diffManifests(have, want) {
  const haveKeys = new Set(Object.keys(have));
  const wantKeys = new Set(Object.keys(want));
  const added = [...haveKeys].filter((k) => !wantKeys.has(k)).sort();
  const removed = [...wantKeys].filter((k) => !haveKeys.has(k)).sort();
  const changed = [...haveKeys]
    .filter((k) => wantKeys.has(k) && have[k].sha256 !== want[k].sha256)
    .sort();
  return { added, removed, changed };
}

function isClean(d) {
  return d.added.length === 0 && d.removed.length === 0 && d.changed.length === 0;
}

function report(title, d, { addedNote, removedNote, changedNote }) {
  const lines = [`check:vendor: ${title}`];
  if (d.changed.length) lines.push(`  ${changedNote}`, ...d.changed.map((k) => `    ~ ${k}`));
  if (d.added.length) lines.push(`  ${addedNote}`, ...d.added.map((k) => `    + ${k}`));
  if (d.removed.length) lines.push(`  ${removedNote}`, ...d.removed.map((k) => `    - ${k}`));
  return lines.join("\n");
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const manifestPath = join(args.consumer, "vendor", MANIFEST_NAME);
  if (!existsSync(manifestPath)) {
    fail(
      `no vendor/${MANIFEST_NAME} in ${args.consumer}. This consumer is not managed by revendor-m3e, ` +
        `or the manifest was deleted. Run \`node scripts/revendor-m3e.mjs --commit <sha>\`.`,
    );
  }

  let manifest;
  try {
    manifest = JSON.parse(readFileSync(manifestPath, "utf8"));
  } catch (e) {
    fail(`vendor/${MANIFEST_NAME} is not valid JSON: ${e.message}`);
  }
  const committedFiles = manifest.files || {};
  const trees = manifest.source?.trees;
  const commit = manifest.source?.commit;
  if (!Array.isArray(trees) || !commit) {
    fail(`vendor/${MANIFEST_NAME} is missing source.trees / source.commit — regenerate with revendor-m3e.`);
  }

  // --- (A) manifest honesty: committed files vs committed manifest ---
  const committedActual = computeManifest(args.consumer, trees);
  const dA = diffManifests(committedActual, committedFiles);
  if (!isClean(dA)) {
    console.error(
      report("committed vendor/ does not match its own manifest (hand-edit / manifest tamper):", dA, {
        changedNote: "hand-edited files (content differs from the recorded hash):",
        addedNote: "files present in vendor/ but NOT in the manifest (added by hand):",
        removedNote: "files in the manifest but MISSING from vendor/ (deleted by hand):",
      }),
    );
    fail("vendored M3e was hand-edited — never edit vendor/ by hand; run `node scripts/revendor-m3e.mjs --commit <sha>`.");
  }

  // --- (B) currency vs canonical@pin: committed manifest vs a fresh extraction ---
  const { dir: workspaceDir, kind } = resolveWorkspace({ workspace: args.workspace, commit });
  const scratch = mkdtempSync(join(tmpdir(), "m3e-check-vendor-"));
  process.on("exit", () => rmSync(scratch, { recursive: true, force: true }));
  try {
    copyTreesInto(scratch, { workspaceDir, commit, trees });
  } catch (e) {
    fail(`could not re-extract canonical@${commit.slice(0, 12)} for comparison: ${e.message}`);
  }
  const canonical = computeManifest(scratch, trees);
  const dB = diffManifests(committedFiles, canonical);
  if (!isClean(dB)) {
    console.error(
      report(`committed vendor/ diverges from canonical @ pinned commit ${commit.slice(0, 12)} (${kind}):`, dB, {
        changedNote: "hand-edited files (differ from canonical@pin):",
        addedNote: "files vendored but not present in canonical@pin (added by hand / stale tree):",
        removedNote: "files in canonical@pin but not vendored (deleted by hand / stale tree):",
      }),
    );
    fail(`vendored M3e diverges from canonical@pin — run \`node scripts/revendor-m3e.mjs --commit ${commit}\` and commit.`);
  }

  // --- optional: is a newer canonical available? (non-fatal) ---
  let staleNote = "";
  if (args.checkStale && kind === "local") {
    const head = spawnSync("git", ["-C", workspaceDir, "rev-parse", "HEAD"], { encoding: "utf8" });
    const headSha = head.stdout?.trim();
    if (headSha && headSha !== commit) {
      staleNote =
        `\ncheck:vendor: NOTE — pin ${commit.slice(0, 12)} is behind workspace HEAD ${headSha.slice(0, 12)}; ` +
        `a reviewed bump is available (re-run revendor-m3e with --commit ${headSha.slice(0, 12)}).`;
    }
  }

  const n = Object.keys(committedFiles).length;
  console.log(
    `check:vendor: OK — ${n} vendored file(s) across ${trees.length} tree(s) match canonical@${commit.slice(0, 12)} ` +
      `(${kind}); manifest is honest.${staleNote}`,
  );
}

main();
