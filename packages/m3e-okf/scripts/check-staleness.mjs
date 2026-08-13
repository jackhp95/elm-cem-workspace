// check-staleness.mjs — is the pinned m3e SHA still current?
//
// Compares the SHA in data/sources.json against upstream main. Prints how far
// behind we are and whether to regenerate. Exit 0 = current, 1 = stale,
// 2 = couldn't determine (network/tooling).
//
// Also reports a second, FAMILY-LEVEL signal (M4.b): whether the workspace's
// single `@m3e/web` pin (tools/check-single-m3e-web-pin.mjs) is behind the
// latest version published to npm. This is a different axis than the SHA
// check above — the SHA tracks matraic/m3e's SOURCE repo (what this package
// extracted its docs/guidance from), the npm check tracks the PUBLISHED
// package every elm-cem consumer actually installs and generates against.
// Both report on the outside world moving past a pin this workspace holds,
// so both stay NON-BLOCKING: `package.json`'s `check` script already
// excludes this whole script (`"check:!(staleness)"`), and `gate` does not
// call it either. This reports; it never fails a gate.
//
//   node scripts/check-staleness.mjs

import fs from "node:fs";
import path from "node:path";
import { execSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(fileURLToPath(import.meta.url), "../..");
const REPO_ROOT = path.resolve(ROOT, "..", "..");
const REPO = "matraic/m3e";
const pinned = JSON.parse(fs.readFileSync(path.join(ROOT, "data/sources.json"), "utf8")).sha;

const sh = (cmd) => execSync(cmd, { encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] }).trim();

function checkM3eWebNpmStaleness() {
    let workspacePin;
    try {
        const pkg = JSON.parse(fs.readFileSync(path.join(REPO_ROOT, "packages", "tailwind-m3e-web", "package.json"), "utf8"));
        workspacePin = pkg.devDependencies?.["@m3e/web"] || pkg.dependencies?.["@m3e/web"];
    } catch {
        console.log("ℹ️  family signal: could not read the workspace's @m3e/web pin — skipped.");
        return;
    }
    if (!workspacePin) {
        console.log("ℹ️  family signal: no @m3e/web pin found — skipped.");
        return;
    }
    let latest;
    try {
        latest = sh("npm view @m3e/web version");
    } catch {
        console.log("ℹ️  family signal: could not reach npm to check @m3e/web's latest version — skipped.");
        return;
    }
    if (latest === workspacePin) {
        console.log(`✅ family signal: workspace @m3e/web pin (${workspacePin}) matches npm's latest (${latest}).`);
    } else {
        console.log(
            `🔄 family signal: workspace @m3e/web pin is ${workspacePin}; npm's latest is ${latest}. ` +
                `Non-blocking — this reports on the outside world, not this tree. Run \`pnpm run bump -- ${latest}\` to update.`,
        );
    }
}

checkM3eWebNpmStaleness();

function upstreamHead() {
  // prefer gh (authed, gives commit metadata); fall back to git ls-remote
  try {
    return sh(`gh api repos/${REPO}/commits/main --jq .sha`);
  } catch {
    try {
      return sh(`git ls-remote https://github.com/${REPO}.git refs/heads/main`).split(/\s+/)[0];
    } catch {
      return null;
    }
  }
}

const head = upstreamHead();
if (!head) {
  console.error("⚠️  Could not reach upstream (need `gh` auth or network). Skipping staleness check.");
  process.exit(2);
}

if (head === pinned) {
  console.log(`✅ Up to date. Pinned SHA matches ${REPO}@main (${pinned.slice(0, 10)}).`);
  process.exit(0);
}

// how far behind + whether component sources changed
let detail = "";
try {
  const cmp = JSON.parse(sh(`gh api repos/${REPO}/compare/${pinned}...${head}`));
  const files = (cmp.files || []).map((f) => f.filename);
  const touched = files.filter((f) => f.startsWith("packages/web/src/") || f.startsWith("packages/web/docs") || f.startsWith("docs/"));
  detail =
    `   ${cmp.ahead_by} commit(s) ahead.\n` +
    `   ${touched.length} doc/source file(s) changed` +
    (touched.length ? `:\n     ${touched.slice(0, 15).join("\n     ")}${touched.length > 15 ? `\n     …and ${touched.length - 15} more` : ""}` : ".");
} catch {
  detail = "   (couldn't fetch the diff; run a compare manually).";
}

console.log(`🔄 STALE — upstream has moved.
   pinned:   ${pinned}
   upstream: ${head}
${detail}

To update: re-clone m3e at the new SHA, regenerate the manifest, then run
extract.mjs → guidance.mjs → build-examples.mjs → build-skill.mjs, and review
data/report.md for newly introduced drift. See README.md.`);
process.exit(1);
