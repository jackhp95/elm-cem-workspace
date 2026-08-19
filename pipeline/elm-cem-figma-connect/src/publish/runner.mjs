// Task B4: per-fileKey, label-scoped publish/unpublish runner
// (plans/plan/B-emitters-publish.md Task B4; plans/00-mission-and-decisions.md
// evidence #5 "Duplication mints new component keys... Node IDs ARE stable"
// -> the per-copy republish consumption model, "Consumption model
// (consequence of #5)").
//
// Pipeline per (label x fileKey):
//   1. kitVersionTag guard (carry-in requirement, Plan A whole-branch review
//      finding WB/m6): refuse outright if the profile's kitVersionTag is
//      still the "unknown-pre-a3-fixture" placeholder.
//   2. FIGMA_ACCESS_TOKEN from process.env ONLY (requireToken, below) — this
//      module contains NO code path that reads a token from a file (e.g. the
//      old spike's `verify/.figma-token`, why this repo's own .gitignore
//      still lists `.figma-token`); a missing env var is a fail-fast error,
//      never a silent fallback to a file.
//   3. `check` (src/publish/check.mjs) must pass — publish refuses on any
//      DRIFT/ORPHAN.
//   4. Publishability guard (D8, made real by Task C7): if src/visual/status.mjs
//      exists, every cemTag the target label's MANIFEST.json lists is classified
//      via its exported `status(entry)` — `pass`/`approved` publish, everything
//      else (`failed`/`rejected`/`pending`) is EXCLUDED from the staged files
//      and listed in the run summary (`results[].gate.blocked`, with the diff
//      artifact path for `failed` entries, via status.mjs's `diffPaths`), while
//      the rest of the label still publishes. `--force-gate` (the `forceGate`
//      option) publishes the blocked entries too, logging a loud per-binding
//      warning and stamping `forced: true` on both the result and the
//      published.json record for that (fileKey, label) — never for CI use. If
//      src/visual/status.mjs does NOT exist at all (a state this repo no longer
//      has, post-C6, but the tests can still simulate via `statusModulePath`),
//      this is a WARN-AND-PASS interim — B intentionally does not hard-depend
//      on C's internals.
//   5. Materialize a staging dir per (label, fileKey): copy the label's
//      generated `*.figma.ts` files, rewriting each `// url=` line to the
//      target fileKey (node-ids intact — see rewriteFigmaTsForFileKey). The
//      on-disk `generated/**` templates stay fileKey-agnostic (carry the
//      profile's own canonical fileKey); only the throwaway staging copy is
//      ever rewritten. Write that staging dir's `figma.config.json`.
//   6. exec `figma connect publish --skip-update-check [--dry-run]`
//      (`execFn` — injected, so tests never need a token or the network;
//      see this module's real `defaultExec`) in the staging dir.
//   7. Record published (fileKey x label x nodeIds) into
//      `profiles/<p>/published.json` (state for unpublish + audits).
//
// `unpublish` shares steps 5-6 (staging -> `figma connect unpublish`) and
// updates the same state file, but does NOT run the kitVersionTag guard or
// the publishability gate — removing a binding is not "shipping new code
// into a designer's Dev Mode panel", so those forward-looking gates don't
// apply to tearing one down.

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { pathToFileURL } from "node:url";
import { spawnSync } from "node:child_process";

import { loadProfile, readCorrespondence, repoRoot as defaultRepoRoot } from "../correspond/merge.mjs";
import { loadEmitters } from "../emit/run.mjs";
import { slugify } from "../emit/emitter-api.mjs";
import { byString } from "../lib/order.mjs";
import { runCheck } from "./check.mjs";

const KIT_VERSION_TAG_PLACEHOLDER = "unknown-pre-a3-fixture";
const PUBLISHABLE_STATUSES = new Set(["pass", "approved"]);

// -- URL rewrite (the per-copy republish mechanism, evidence #5) -------------

// One `// url=` header line, exactly as html-label.mjs/elm.mjs emit it:
//   // url=https://www.figma.com/design/<fileKey>/<slug>?node-id=<dashed-id>
// Captures the dashed node-id (group 2) so it survives the rewrite
// unchanged; the fileKey (group 1) and the file-name slug are both replaced
// — the slug with the literal "x" placeholder (the URL still resolves via
// node-id regardless of the path segment; the brief's exact staging form).
const URL_LINE_RE =
  /^\/\/ url=https:\/\/www\.figma\.com\/design\/([^/]+)\/[^?]*\?node-id=([A-Za-z0-9-]+)\s*$/gm;

// rewriteFigmaTsForFileKey(contents, fileKey) -> contents with every
// `// url=` line's fileKey swapped, node-id intact. Fail-loud (never
// silently no-op) if a staged file has no such line at all — that would
// mean staging a file Code Connect cannot bind to any node, which must
// never happen quietly.
export function rewriteFigmaTsForFileKey(contents, fileKey) {
  let matched = false;
  const rewritten = contents.replace(URL_LINE_RE, (_full, _oldFileKey, nodeId) => {
    matched = true;
    return `// url=https://www.figma.com/design/${fileKey}/x?node-id=${nodeId}`;
  });
  if (!matched) {
    throw new Error(
      'rewriteFigmaTsForFileKey: no "// url=" line found — refusing to stage a file with no publishable node URL'
    );
  }
  return rewritten;
}

// -- staging materialization --------------------------------------------------

// materializeStaging({ repoRoot, profileName, labelSlug, fileKey, stagingRoot, allowedFiles }) ->
//   { dir, files, sourceDir }
//
// Copies every `*.figma.ts` from the committed `generated/<profile>/<label-slug>/`
// into a fresh staging directory (a temp dir by default; `stagingRoot`
// override lets tests inspect a known path), rewriting each file's URL line
// per `fileKey`. Never touches `generated/**` itself — the staging copy is
// the ONLY thing that ever carries a non-canonical fileKey.
//
// `allowedFiles` (task C7, the visual gate): an optional Set<string> of
// filenames (MANIFEST.json's own values) to narrow staging to — the caller
// (`publish`, below) computes this from which cemTags are actually
// publishable, so a blocked binding's `.figma.ts` file is never even copied
// into staging, let alone published. `undefined`/`null` (every pre-C7 call
// site, and every direct test of this function) means "no filter — stage
// everything", preserving prior behavior exactly.
export function materializeStaging({
  repoRoot: root = defaultRepoRoot,
  profileName,
  labelSlug,
  fileKey,
  stagingRoot,
  allowedFiles,
}) {
  const sourceDir = path.join(root, "generated", profileName, labelSlug);
  if (!fs.existsSync(sourceDir)) {
    throw new Error(
      `materializeStaging: no generated output at "${sourceDir}" — run \`emit\` for this profile/label first`
    );
  }

  let sourceFiles = fs
    .readdirSync(sourceDir)
    .filter((f) => f.endsWith(".figma.ts"))
    .sort(byString);
  if (allowedFiles) {
    sourceFiles = sourceFiles.filter((f) => allowedFiles.has(f));
  }
  if (sourceFiles.length === 0) {
    const gateNote = allowedFiles
      ? " (every candidate file was excluded by the visual gate's allowedFiles filter)"
      : "";
    throw new Error(`materializeStaging: "${sourceDir}" has no .figma.ts files to publish${gateNote}`);
  }

  const dir = stagingRoot ?? fs.mkdtempSync(path.join(os.tmpdir(), "cem-figma-connect-staging-"));
  fs.mkdirSync(dir, { recursive: true });

  const files = [];
  for (const name of sourceFiles) {
    const contents = fs.readFileSync(path.join(sourceDir, name), "utf8");
    const rewritten = rewriteFigmaTsForFileKey(contents, fileKey);
    fs.writeFileSync(path.join(dir, name), rewritten, "utf8");
    files.push(name);
  }

  return { dir, files, sourceDir };
}

// writeFigmaConfig(stagingDir, label) -> configPath. The exact shape proven
// live (research/spikes/01-publish-gate/figma.config.json,
// research/spikes/02-elm-label/figma.config.json), plus an explicit (empty)
// `exclude` for shape completeness with the brief's documented config shape.
export function writeFigmaConfig(stagingDir, label) {
  const config = {
    codeConnect: {
      parser: "html",
      include: ["*.figma.ts"],
      exclude: [],
      label,
    },
  };
  const configPath = path.join(stagingDir, "figma.config.json");
  fs.writeFileSync(configPath, `${JSON.stringify(config, null, 2)}\n`, "utf8");
  return configPath;
}

// -- token safety --------------------------------------------------------------

// requireToken(env) -> the token string, or throws. Reads `FIGMA_ACCESS_TOKEN`
// from the given env object ONLY (defaults to `process.env`) — this
// function, and this module as a whole, contain no fs.readFileSync call
// aimed at any token/credentials file. Never logs the token value itself;
// callers must not either (see `publish`/`unpublish` below — command lines
// logged never include env, only argv).
export function requireToken(env = process.env) {
  const token = env.FIGMA_ACCESS_TOKEN;
  if (typeof token !== "string" || token.length === 0) {
    throw new Error(
      "FIGMA_ACCESS_TOKEN is not set in the environment. This tool reads the token from the " +
        "environment ONLY — it refuses to read a token from any file (e.g. a `.figma-token`). " +
        "Set FIGMA_ACCESS_TOKEN in your shell and retry."
    );
  }
  return token;
}

// -- token redaction (review fix, token safety) -------------------------------
//
// The token is in scope at every call site below (requireToken's return
// value) — this scrubs it out of any figma-CLI stdout/stderr/spawn-error
// text BEFORE that text ever lands in a thrown Error's message or a
// console log (cli.mjs's success-path `console.log(r.stdout)` and
// top-level `console.error(err.message)` both just echo what this module
// hands them, so redacting here — the one place the token is authoritative
// — covers both without cli.mjs needing to know the token itself). Guards
// against `@figma/code-connect` ever echoing auth material back verbatim;
// the brief's requirement is the token never appears "in output parsing,
// not in errors" — this is the errors/output half of that.
export function redact(text, token) {
  if (typeof text !== "string") return text;
  return token ? text.replaceAll(token, "***") : text;
}

// -- exec (injected — real implementation only used outside tests) -----------

const FIGMA_BIN = path.join(defaultRepoRoot, "node_modules", ".bin", "figma");

// defaultExec({ cwd, args, env }) -> { status, stdout, stderr }
//
// The one real (network-capable) exec path — `figma connect publish`/
// `unpublish` IS the publisher (package.json's one sanctioned runtime dep).
// Every test in test/publish-check.test.mjs injects a fake `execFn` instead
// of this, per the task's offline constraint — this function is never
// exercised by the test suite.
export function defaultExec({ cwd, args, env }) {
  const result = spawnSync(FIGMA_BIN, args, { cwd, env, encoding: "utf8" });
  return { status: result.status, stdout: result.stdout ?? "", stderr: result.stderr ?? "", error: result.error };
}

// -- publishability guard (D8 — B does not hard-depend on C) -----------------

// resolveVisualModule({ repoRoot, statusModulePath }) -> Promise<{mod, modPath}|null>
//
// The shared module-resolution step behind both `resolveStatusFn` (the gate
// decision itself) and, as of task C7, the run summary's diff-artifact
// lookup for `failed` bindings (see `diffPathsForBlockedEntry`, below) —
// both need the SAME resolved module object, so this is factored out rather
// than duplicated. `null` means "the module file does not exist at all"
// (the pre-Plan-C/warn-and-pass state; the tests simulate it via a
// deliberately nonexistent `statusModulePath`).
async function resolveVisualModule({ repoRoot: root, statusModulePath }) {
  const modPath = statusModulePath ?? path.join(root, "src", "visual", "status.mjs");
  if (!fs.existsSync(modPath)) {
    return null;
  }
  const mod = await import(pathToFileURL(modPath).href);
  return { mod, modPath };
}

// resolveStatusFn({ repoRoot, statusModulePath }) -> Promise<Function|null>
//
// `null` means "src/visual/status.mjs does not exist" -> warn-and-pass (the
// pre-Plan-C interim this task's brief calls for). `statusModulePath`
// override exists purely for tests: exercising the "module present" branch
// without ever creating a real (even temporary) file at the real
// src/visual/status.mjs path, which does NOT exist yet by design.
export async function resolveStatusFn({ repoRoot: root = defaultRepoRoot, statusModulePath } = {}) {
  const resolved = await resolveVisualModule({ repoRoot: root, statusModulePath });
  if (resolved === null) {
    return null;
  }
  const { mod, modPath } = resolved;
  const statusFn = mod.status ?? mod.default;
  if (typeof statusFn !== "function") {
    throw new Error(
      `resolveStatusFn: "${modPath}" exists but does not export a \`status\` function (via \`status\` or \`default\`)`
    );
  }
  return statusFn;
}

// diffPathsForBlockedEntry(visualModule, entry, resultsDir) -> string[]
//
// Task C7's run-summary requirement: "for `failed` — the diff artifact path
// (from the results record)". Calls the resolved visual module's OWN
// `diffPaths(entry, options)` export (src/visual/status.mjs, added
// alongside `status()` for this task) if present; `[]` for any module that
// doesn't export one (e.g. this suite's synthetic `b4-status-*.mjs`
// fixtures, which stand in for a real status.mjs but carry no results-file
// reading logic of their own — a missing diff path is a harmless
// degradation, never a crash) or when `visualModule` itself is null
// (warn-and-pass mode, where nothing is ever "blocked" to begin with).
function diffPathsForBlockedEntry(visualModule, entry, resultsDir) {
  if (!visualModule || typeof visualModule.diffPaths !== "function" || !entry) {
    return [];
  }
  return visualModule.diffPaths(entry, resultsDir ? { resultsDir } : {});
}

// nodeIdsFor(entry) -> string[] — the component-shape's figmaSets[].nodeId,
// or the iconTable shape's icons[].figmaNodeId; [] for an entry not found
// at all (shouldn't happen for a real manifest cemTag, but never throw over
// state-recording bookkeeping).
function nodeIdsFor(entry) {
  if (!entry) return [];
  if (Array.isArray(entry.figmaSets)) return entry.figmaSets.map((s) => s.nodeId);
  if (Array.isArray(entry.icons)) return entry.icons.map((i) => i.figmaNodeId);
  return [];
}

// -- published.json state ------------------------------------------------------

export function readPublished(publishedJsonPath) {
  if (!fs.existsSync(publishedJsonPath)) return {};
  return JSON.parse(fs.readFileSync(publishedJsonPath, "utf8"));
}

// Deterministic write (sorted keys) — published.json is runtime STATE, not
// a byte-stable generated artifact (timestamps are expected to change), but
// keeping key order stable still makes diffs reviewable.
export function writePublished(publishedJsonPath, state) {
  fs.mkdirSync(path.dirname(publishedJsonPath), { recursive: true });
  const sorted = {};
  for (const fileKey of Object.keys(state).sort(byString)) {
    const labels = state[fileKey];
    const sortedLabels = {};
    for (const label of Object.keys(labels).sort(byString)) sortedLabels[label] = labels[label];
    sorted[fileKey] = sortedLabels;
  }
  fs.writeFileSync(publishedJsonPath, `${JSON.stringify(sorted, null, 2)}\n`, "utf8");
}

// -- kitVersionTag guard (carry-in requirement, Plan A whole-branch review WB/m6) --

function assertRealKitVersionTag(profile) {
  if (profile.kitVersionTag === KIT_VERSION_TAG_PLACEHOLDER) {
    throw new Error(
      `publish: refusing — profile.json's kitVersionTag is still the placeholder ` +
        `"${KIT_VERSION_TAG_PLACEHOLDER}". A real Figma extraction (Plan A3 live re-extraction) ` +
        `must stamp a real, dated kit version tag onto this profile before it can be published. ` +
        `See plans/plan/A-engine-core.md (Task A3) and ` +
        `research/evidence/2026-07-10-verification-ledger.md.`
    );
  }
}

// -- publish -------------------------------------------------------------------

// publish({ profileDir, profileName, label, fileKey, dryRun, forceGate, ... }) ->
//   Promise<{ results, warnAndPass, publishedJsonPath }>
//
// Omitting `label` iterates every label in the profile's emitters[]
// (publish-all). Every fs-adjacent dependency an offline test needs to
// override is a named option with a real-usage default: `repoRoot`,
// `execFn`, `env`, `stagingRoot`, `publishedJsonPath`, `statusModulePath`,
// `resultsDir`, `now`.
//
// -- The D8 visual gate (task C7) ---------------------------------------------
//
// Per (label x fileKey), every cemTag the label's MANIFEST.json lists is
// classified via `statusFn(entry)`:
//   - `pass`/`approved` -> publishable; its file(s) are staged and published.
//   - `failed`/`rejected`/`pending` -> BLOCKED: excluded from staging (never
//     even copied into the staging dir, let alone published), and recorded
//     into `results[].gate.blocked` as `{ cemTag, status, diffs }` (`diffs`
//     is the `failed`-only diff-artifact path list, via status.mjs's
//     `diffPaths`; always `[]` for `rejected`/`pending`, which have no
//     "here's the mismatch" artifact to point at).
// A label with SOME blocked cemTags still publishes the rest — this is a
// per-binding gate, not an all-or-nothing refusal (the pre-C7 behavior,
// which threw and published nothing at all the moment ANY cemTag in the
// label was unpublishable; that was too blunt for a label that mixes proven
// and unproven bindings, per this task's brief).
//
// `forceGate: true` is the escape hatch: every blocked cemTag publishes
// anyway. Each one gets a LOUD `console.warn` naming it, its status, and
// (for `failed`) its diff path, plus the plain-language "NEVER use in CI"
// reminder. The published.json record AND `results[].gate.forced` are both
// stamped `forced: true` for that (fileKey, label) run — a per-run flag, not
// per-cemTag: once ANY blocked binding is force-published into a given
// label's staging batch, that whole `figma connect publish` invocation (and
// therefore every nodeId it just bound) is a forced run; a reader auditing
// published.json cannot assume an unflagged sibling binding in the SAME
// batch was independently verified apart from the ones actually blocked
// (see `results[].gate.blocked` for exactly which cemTags needed forcing).
// A label with NO blocked cemTags is entirely unaffected by `forceGate`
// (nothing to force) and is never stamped.
// If a label ends up with ZERO publishable cemTags (every one blocked) and
// `forceGate` is not set, staging/exec are skipped entirely for that label
// (nothing to publish) — its `results[]` entry reports `skipped: true` and
// an empty `nodeIds`/`files`, with the full blocked list still present for
// the summary. `warnAndPass` mode (src/visual/status.mjs absent) disables
// the gate entirely, exactly as pre-C7 — every cemTag is treated as
// publishable and `gate.blocked` is always `[]`.
export async function publish({
  profileDir,
  profileName,
  label,
  fileKey,
  dryRun = false,
  forceGate = false,
  repoRoot: root = defaultRepoRoot,
  execFn = defaultExec,
  env = process.env,
  stagingRoot,
  publishedJsonPath,
  statusModulePath,
  resultsDir,
  now = () => new Date().toISOString(),
}) {
  if (!fileKey) throw new Error("publish: --file-key is required");

  const profile = loadProfile(profileDir);
  assertRealKitVersionTag(profile);

  const token = requireToken(env); // fail fast before any fs/exec work

  const checkResult = await runCheck({ profileDir, profileName, repoRoot: root });
  if (!checkResult.ok) {
    const lines = [
      ...checkResult.drift.map((d) => `DRIFT  [${d.label}] ${d.path}: ${d.reason}`),
      ...checkResult.orphan.map((o) => `ORPHAN [${o.label}] ${o.path}`),
    ];
    throw new Error(`publish: refusing — \`check\` failed:\n${lines.join("\n")}`);
  }

  const emitters = await loadEmitters(profile);
  const targets = label ? emitters.filter((e) => e.label === label) : emitters;
  if (label && targets.length === 0) {
    throw new Error(
      `publish: no emitter with label "${label}" in profile "${profileName}" ` +
        `(available: ${emitters.map((e) => e.label).join(", ") || "(none)"})`
    );
  }

  const correspondence = readCorrespondence(path.join(profileDir, "correspondence.json"));
  const byTag = new Map(correspondence.map((e) => [e.cemTag, e]));

  const statusFn = await resolveStatusFn({ repoRoot: root, statusModulePath });
  const warnAndPass = statusFn === null;
  if (warnAndPass) {
    console.warn(
      "publish: src/visual/status.mjs not found — warn-and-pass (pre-Plan-C interim): treating " +
        "every confirmed entry as publishable. This is a temporary gate; Plan C makes it real (D8)."
    );
  }
  // Only needed to look up diffPaths for `failed` cemTags below — never
  // resolved (or imported) at all in warn-and-pass mode.
  const visualModule = warnAndPass
    ? null
    : (await resolveVisualModule({ repoRoot: root, statusModulePath }))?.mod ?? null;

  const publishedJson = publishedJsonPath ?? path.join(profileDir, "published.json");
  const state = readPublished(publishedJson);
  const results = [];

  for (const emitterDef of targets) {
    const labelSlug = slugify(emitterDef.label);
    const manifestPath = path.join(root, "generated", profileName, labelSlug, "MANIFEST.json");
    const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
    const cemTags = Object.keys(manifest).sort(byString);

    // -- classify every cemTag: publishable vs. blocked (D8) ----------------
    const publishableTags = [];
    const blocked = []; // { cemTag, status, diffs }
    if (warnAndPass) {
      publishableTags.push(...cemTags);
    } else {
      for (const tag of cemTags) {
        const entry = byTag.get(tag);
        const entryStatus = entry ? statusFn(entry) : "pending";
        if (PUBLISHABLE_STATUSES.has(entryStatus)) {
          publishableTags.push(tag);
        } else {
          const diffs =
            entryStatus === "failed" ? diffPathsForBlockedEntry(visualModule, entry, resultsDir) : [];
          blocked.push({ cemTag: tag, status: entryStatus, diffs });
        }
      }
    }

    const forced = forceGate && blocked.length > 0;
    const publishTags = forced ? cemTags : publishableTags;

    for (const b of blocked) {
      const diffNote = b.diffs.length > 0 ? ` — diff: ${b.diffs.join(", ")}` : "";
      if (forced) {
        console.warn(
          `publish: FORCE-GATE — "${b.cemTag}" is NOT publishable per the visual gate ` +
            `(status "${b.status}")${diffNote}; publishing anyway because --force-gate was passed. ` +
            `NEVER use --force-gate in CI.`
        );
      } else {
        console.warn(
          `publish: skipping "${b.cemTag}" — not publishable per the visual gate ` +
            `(status "${b.status}")${diffNote}. Listed in the run summary, not published.`
        );
      }
    }

    if (publishTags.length === 0) {
      // Nothing publishable (and not forced) — skip staging/exec entirely
      // for this label; still report it in the summary.
      results.push({
        label: emitterDef.label,
        labelSlug,
        fileKey,
        dryRun,
        skipped: true,
        files: [],
        nodeIds: [],
        stdout: "",
        gate: { forced: false, published: [], blocked },
      });
      continue;
    }

    const allowedFiles = new Set(publishTags.flatMap((tag) => manifest[tag]));

    const { dir: stagingDir, files } = materializeStaging({
      repoRoot: root,
      profileName,
      labelSlug,
      fileKey,
      stagingRoot,
      allowedFiles,
    });
    writeFigmaConfig(stagingDir, emitterDef.label);

    const args = ["connect", "publish", "--skip-update-check"];
    if (dryRun) args.push("--dry-run");

    // Never log `env` — only the argv (no secret material lives there).
    const execResult = execFn({ cwd: stagingDir, args, env: { ...env, FIGMA_ACCESS_TOKEN: token } });
    if (execResult.status !== 0) {
      const output = redact(execResult.stderr || execResult.stdout || "", token) || "(no output)";
      // Fix 3: surface a spawn-level failure (e.g. ENOENT — the `figma`
      // binary missing) instead of letting it collapse into an
      // uninformative "(no output)"; redacted too, though a spawn error
      // (a Node-generated message, never CLI stdout/stderr) won't contain
      // the token in practice.
      const spawnErrPart = execResult.error?.message
        ? `\nspawn error: ${redact(execResult.error.message, token)}`
        : "";
      throw new Error(
        `publish: \`figma ${args.join(" ")}\` failed in "${stagingDir}" (exit ${execResult.status}):\n` +
          output + spawnErrPart
      );
    }

    const nodeIds = [...new Set(publishTags.flatMap((tag) => nodeIdsFor(byTag.get(tag))))].sort(byString);

    state[fileKey] = state[fileKey] ?? {};
    state[fileKey][emitterDef.label] = {
      publishedAt: now(),
      dryRun,
      nodeIds,
      ...(forced ? { forced: true } : {}),
    };

    results.push({
      label: emitterDef.label,
      labelSlug,
      fileKey,
      dryRun,
      stagingDir,
      files,
      nodeIds,
      // Redacted here (not in cli.mjs) — this is the one place the token
      // is authoritative; cli.mjs's success-path `console.log(r.stdout)`
      // just echoes what it's handed, so redacting at the source covers it.
      stdout: redact(execResult.stdout, token),
      gate: { forced, published: publishTags, blocked },
    });
  }

  // WB-review N4 fix: a dry run must not persist state. `figma connect
  // publish --dry-run` never actually binds anything in Figma, so recording
  // it into published.json would let a LATER real `unpublish` act on a
  // binding that was never made, and would let an audit misread the dry
  // run as a real publish. The dry run still computes/returns `results`
  // (nodeIds, stdout, etc.) above — it just skips the fs write.
  if (!dryRun) writePublished(publishedJson, state);

  return { results, warnAndPass, publishedJsonPath: publishedJson };
}

// -- unpublish -----------------------------------------------------------------

// unpublish({ profileDir, profileName, label, fileKey, ... }) ->
//   Promise<{ results, publishedJsonPath }>
//
// Same staging mechanism as publish (steps 5-6 of the header doc); no
// kitVersionTag guard, no check gate, no publishability gate — tearing a
// binding down is not a forward-looking "ship this" decision.
export async function unpublish({
  profileDir,
  profileName,
  label,
  fileKey,
  repoRoot: root = defaultRepoRoot,
  execFn = defaultExec,
  env = process.env,
  stagingRoot,
  publishedJsonPath,
}) {
  if (!fileKey) throw new Error("unpublish: --file-key is required");

  const profile = loadProfile(profileDir);
  const token = requireToken(env);

  const emitters = await loadEmitters(profile);
  const targets = label ? emitters.filter((e) => e.label === label) : emitters;
  if (label && targets.length === 0) {
    throw new Error(
      `unpublish: no emitter with label "${label}" in profile "${profileName}" ` +
        `(available: ${emitters.map((e) => e.label).join(", ") || "(none)"})`
    );
  }

  const publishedJson = publishedJsonPath ?? path.join(profileDir, "published.json");
  const state = readPublished(publishedJson);
  const results = [];

  for (const emitterDef of targets) {
    const labelSlug = slugify(emitterDef.label);
    const { dir: stagingDir, files } = materializeStaging({
      repoRoot: root,
      profileName,
      labelSlug,
      fileKey,
      stagingRoot,
    });
    writeFigmaConfig(stagingDir, emitterDef.label);

    const args = ["connect", "unpublish", "--skip-update-check"];
    const execResult = execFn({ cwd: stagingDir, args, env: { ...env, FIGMA_ACCESS_TOKEN: token } });
    if (execResult.status !== 0) {
      const output = redact(execResult.stderr || execResult.stdout || "", token) || "(no output)";
      const spawnErrPart = execResult.error?.message
        ? `\nspawn error: ${redact(execResult.error.message, token)}`
        : "";
      throw new Error(
        `unpublish: \`figma ${args.join(" ")}\` failed in "${stagingDir}" (exit ${execResult.status}):\n` +
          output + spawnErrPart
      );
    }

    if (state[fileKey]) {
      delete state[fileKey][emitterDef.label];
      if (Object.keys(state[fileKey]).length === 0) delete state[fileKey];
    }

    results.push({
      label: emitterDef.label,
      labelSlug,
      fileKey,
      stagingDir,
      files,
      stdout: redact(execResult.stdout, token),
    });
  }

  writePublished(publishedJson, state);

  return { results, publishedJsonPath: publishedJson };
}
