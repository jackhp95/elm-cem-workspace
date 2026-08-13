#!/usr/bin/env node
// Subcommand dispatcher for cem-figma-connect.
//
// No framework — process.argv parsing only (zero framework/runtime deps in
// core is a stated architecture goal, see plans/01-architecture.md §4).
// Later tasks wire the real subcommand bodies; this task only establishes
// dispatch, usage/exit-code behavior, and validated --profile resolution.
//
// `run()` is ASYNC (task B2): `emit` now goes through src/emit/run.mjs,
// whose emitter registry resolves profile-local emitters via dynamic
// `import()` — an inherently async operation. Every other handler is
// synchronous; `await`-ing a plain (non-Promise) return value is a no-op,
// so this doesn't change their behavior.

import fs from "node:fs";
import path from "node:path";

import { loadCem } from "./ingest/cem.mjs";
import { loadFigmaExport } from "./ingest/figma.mjs";
import { runMatch, repoRoot, loadProfile } from "./correspond/merge.mjs";
import { runReview, runConfirm } from "./correspond/review.mjs";
import { runGapReport } from "./correspond/gap-report.mjs";
import { runEmit } from "./emit/run.mjs";
import { runCheck } from "./publish/check.mjs";
import { publish, unpublish } from "./publish/runner.mjs";

const COMMANDS = [
  "match",
  "review",
  "confirm",
  "gap",
  "extract",
  "emit",
  "publish",
  "unpublish",
  "check",
  "capture",
];

export function usage() {
  return [
    "Usage: cem-figma-connect <command> [--profile <name>] [options]",
    "",
    "Commands:",
    ...COMMANDS.map((c) => `  ${c}`),
    "",
    "Options:",
    "  --profile <name>   Bare profile name, resolved to profiles/<name>/ (never a path)",
    "",
  ].join("\n");
}

// Resolves a bare profile name to its directory. Never accepts a path:
// `--profile` is a name, not a filesystem location.
export function resolveProfileDir(name) {
  if (typeof name !== "string" || name.length === 0) {
    throw new Error("--profile requires a non-empty name");
  }
  if (name.includes("/") || name.includes("\\")) {
    throw new Error(
      `--profile must be a bare name, not a path (got "${name}")`
    );
  }
  if (name === "." || name === "..") {
    throw new Error(`--profile must be a bare name (got "${name}")`);
  }
  return path.join("profiles", name);
}

export function parseArgs(argv) {
  const [command, ...rest] = argv;
  const options = {};
  for (let i = 0; i < rest.length; i++) {
    const arg = rest[i];
    if (arg === "--profile") {
      i += 1;
      options.profile = rest[i];
    } else if (arg === "--from") {
      i += 1;
      options.from = rest[i];
    } else if (arg === "--page") {
      i += 1;
      options.page = rest[i];
    } else if (arg === "--label") {
      i += 1;
      options.label = rest[i];
    } else if (arg === "--file-key") {
      i += 1;
      options.fileKey = rest[i];
    } else if (arg === "--dry-run") {
      options.dryRun = true;
    } else if (arg === "--force-gate") {
      options.forceGate = true;
    } else if (arg.startsWith("--channel=")) {
      options.channel = arg.slice("--channel=".length);
    } else if (arg === "--channel") {
      i += 1;
      options.channel = rest[i];
    } else if (arg.startsWith("--scale=")) {
      options.scale = Number(arg.slice("--scale=".length));
    } else if (arg === "--scale") {
      i += 1;
      options.scale = Number(rest[i]);
    } else if (arg.startsWith("--only=")) {
      options.only = arg.slice("--only=".length);
    } else if (arg === "--only") {
      i += 1;
      options.only = rest[i];
    } else if (arg === "--force") {
      options.force = true;
    }
  }
  return { command, options };
}

function requireProfileDir(options) {
  if (options.profile === undefined) {
    throw new Error("this command requires --profile <name>");
  }
  return resolveProfileDir(options.profile);
}

function requireFileKey(options) {
  if (!options.fileKey) {
    throw new Error("this command requires --file-key <key>");
  }
  return options.fileKey;
}

// A6 (task A6; src/correspond/merge.mjs + review.mjs): real match/review/
// confirm handlers, wired against the profile's own cem + figma-export
// inputs. A7 (src/correspond/gap-report.mjs) adds the real `gap` handler.
// Every other command remains a stub — later tasks (B+) replace them.
function runMatchCommand(options) {
  const profileDir = requireProfileDir(options);
  const entries = runMatch({ profileDir, loadCem, loadFigmaExport });
  console.log(`match: wrote ${entries.length} entries to ${path.join(profileDir, "correspondence.json")}`);
  return 0;
}

function runReviewCommand(options) {
  const profileDir = requireProfileDir(options);
  runReview({ profileDir });
  console.log(`review: wrote ${path.join(profileDir, "REVIEW.md")}`);
  return 0;
}

function runConfirmCommand(options) {
  const profileDir = requireProfileDir(options);
  const from = options.from ? path.join(profileDir, options.from) : undefined;
  const entries = runConfirm({ profileDir, from });
  const confirmed = entries.filter((e) => e.status === "confirmed").length;
  console.log(`confirm: ${confirmed}/${entries.length} entries confirmed`);
  return 0;
}

function runGapCommand(options) {
  const profileDir = requireProfileDir(options);
  const { counts } = runGapReport({ profileDir, loadCem, loadFigmaExport });
  console.log(
    `gap: wrote ${path.join(profileDir, "gap-report.md")} ` +
      `(matched ${counts.matched}, code-only ${counts.codeOnly}, figma-only ${counts.figmaOnly}, ` +
      `valid-but-undrawn ${counts.validButUndrawn}, unmapped-axes ${counts.unmappedAxes})`
  );
  return 0;
}

// B2: general emit runner (src/emit/run.mjs) — resolves every emitter in
// the profile's `emitters` array (built-in `html-label` + dynamic-imported
// profile-local emitters), emits every `status:"confirmed"` (minus
// suppressed) entry into `generated/<profile>/<label-slug>/`, deterministically
// ordered, and writes each label's MANIFEST.json. `--page <name>` narrows to
// entries whose figma sets live on that kit page.
async function runEmitCommand(options) {
  const profileDir = requireProfileDir(options);
  const results = await runEmit({ profileDir, profileName: options.profile, page: options.page });
  for (const result of results) {
    console.log(
      `emit: wrote ${result.fileCount} file(s) to ${path.join("generated", options.profile, result.labelSlug)} (${result.label})`
    );
  }
  return 0;
}

// B4: `check` (CI drift/orphan gate, src/publish/check.mjs) — re-emits in
// memory and diffs code-only against committed `generated/**`. Exit code 1
// (not 2 — this isn't an arg/usage error) on any DRIFT/ORPHAN.
async function runCheckCommand(options) {
  const profileDir = requireProfileDir(options);
  const { ok, drift, orphan } = await runCheck({
    profileDir,
    profileName: options.profile,
    page: options.page,
  });
  for (const d of drift) console.error(`DRIFT  [${d.label}] ${d.path}: ${d.reason}`);
  for (const o of orphan) console.error(`ORPHAN [${o.label}] ${o.path}`);
  if (!ok) {
    console.error(`check: FAILED — ${drift.length} drift, ${orphan.length} orphan (see above)`);
    return 1;
  }
  console.log(
    `check: OK — generated/${options.profile}/** matches correspondence.json (0 drift, 0 orphan)`
  );
  return 0;
}

// B4/C7: `publish --profile <p> [--label <l>] --file-key <k> [--dry-run]
// [--force-gate]` (src/publish/runner.mjs) — per-fileKey staging + `figma
// connect publish`. Omitting --label publishes every label in the profile's
// emitters[]. Task C7: only `pass`/`approved` cemTags publish; blocked ones
// (`gate.blocked`) are printed, never staged, unless `--force-gate` is
// passed (never for CI — publish() itself logs a loud per-binding warning
// when forcing; this print is just the run summary).
async function runPublishCommand(options) {
  const profileDir = requireProfileDir(options);
  const fileKey = requireFileKey(options);
  const { results, warnAndPass } = await publish({
    profileDir,
    profileName: options.profile,
    label: options.label,
    fileKey,
    dryRun: options.dryRun === true,
    forceGate: options.forceGate === true,
  });
  if (warnAndPass) {
    console.log("publish: (warn-and-pass — src/visual/status.mjs not present yet, pre-Plan-C interim)");
  }
  for (const r of results) {
    if (r.skipped) {
      console.log(`publish: ${r.label} -> fileKey ${r.fileKey} — SKIPPED (nothing publishable per the visual gate)`);
    } else {
      console.log(
        `publish: ${r.dryRun ? "[dry-run] " : ""}${r.gate?.forced ? "[forced] " : ""}${r.label} -> ` +
          `fileKey ${r.fileKey} (${r.files.length} file(s))`
      );
      if (r.stdout && r.stdout.trim()) console.log(r.stdout.trim());
    }
    if (r.gate?.blocked?.length > 0) {
      for (const b of r.gate.blocked) {
        const diffNote = b.diffs?.length > 0 ? ` (diff: ${b.diffs.join(", ")})` : "";
        console.log(`publish:   blocked: ${b.cemTag} (${b.status})${diffNote}`);
      }
    }
  }
  return 0;
}

// B4: `unpublish --profile <p> [--label <l>] --file-key <k>`.
async function runUnpublishCommand(options) {
  const profileDir = requireProfileDir(options);
  const fileKey = requireFileKey(options);
  const { results } = await unpublish({
    profileDir,
    profileName: options.profile,
    label: options.label,
    fileKey,
  });
  for (const r of results) {
    console.log(`unpublish: ${r.label} -> fileKey ${r.fileKey} (${r.files.length} file(s))`);
  }
  return 0;
}

// SP1 Task 3: `capture --profile <p> --channel <ch> [--only <id,...>] [--force] [--scale <n>]`
// Iterates the profile's 171 set node IDs from the dump, calls `capture_set` over
// the bridge via runCapture, writes PNGs + incremental sidecar to profiles/<p>/.
async function runCaptureCommand(options) {
  const profileDir = requireProfileDir(options);
  if (!options.channel) {
    process.stderr.write("capture requires --channel=<cem-xxxx>\n");
    process.exit(2);
  }
  const { runCapture, bridgeCaptureSet } = await import("../extract/capture.mjs");
  const profile = loadProfile(profileDir);
  const dump = JSON.parse(fs.readFileSync(profile.figmaExportPath, "utf8"));
  const dd = dump.data || dump;
  const allSetIds = Object.keys(dd.setProperties || {});
  const only = options.only ? String(options.only).split(",") : null;
  const setNodeIds = only ? allSetIds.filter((id) => only.includes(id)) : allSetIds;
  const scale = Number(options.scale || 2);
  const { skipped } = await runCapture({
    setNodeIds,
    profile: path.basename(profileDir),
    scale,
    sidecarPath: path.join(repoRoot, profileDir, "figma-captures.json"),
    rendersRoot: path.join(repoRoot, profileDir, "captures"),
    captureSet: bridgeCaptureSet(options.channel, scale),
    force: !!options.force,
  });
  const skipMsg = skipped.length ? ` (${skipped.length} skipped: ${skipped.map((s) => s.setNodeId).join(", ")})` : "";
  process.stdout.write(`capture: done (${setNodeIds.length} sets)${skipMsg}\n`);
  return 0;
}

// Remaining subcommands are stubs until their owning task (A2+/B+) replaces
// this dispatch table with real handlers.
function runStub(command, options) {
  const profileDir =
    options.profile !== undefined ? resolveProfileDir(options.profile) : undefined;
  const suffix = profileDir ? ` (profile: ${profileDir})` : "";
  console.log(`${command}: not yet implemented${suffix}`);
  return 0;
}

const HANDLERS = {
  match: runMatchCommand,
  review: runReviewCommand,
  confirm: runConfirmCommand,
  gap: runGapCommand,
  emit: runEmitCommand,
  check: runCheckCommand,
  publish: runPublishCommand,
  unpublish: runUnpublishCommand,
  capture: runCaptureCommand,
};

export async function run(argv) {
  const { command, options } = parseArgs(argv);

  if (!command || !COMMANDS.includes(command)) {
    console.error(usage());
    return 2;
  }

  try {
    const handler = HANDLERS[command];
    return handler ? await handler(options) : runStub(command, options);
  } catch (err) {
    console.error(err.message);
    return 2;
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  run(process.argv.slice(2)).then((code) => process.exit(code));
}
