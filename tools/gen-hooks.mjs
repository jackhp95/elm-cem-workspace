#!/usr/bin/env node
// gen-hooks.mjs — the ONE generator for every package's `hooks/pre-push`.
//
// Fixes Theme 3 of docs/reviews/2026-08-17-thermonuclear-workspace-review.md:
// 7 byte-identical hand-duplicated copies (packages/{elm-cem,
// elm-html-intermediate-representation, elm-review-cem, elm-typed-html,
// m3e-okf, cem-figma-connect}/hooks/pre-push +
// core/elm-cem/templates/pre-push) plus a silently-diverged 176-line
// elm-m3e variant with Netlify auto-deploy logic interleaved and no marker
// separating the shared base from the brand-specific part — so a fix to the
// shared 66-line gate-running logic could never mechanically reach elm-m3e's
// copy.
//
// The shared logic now lives ONCE, in tools/hooks/pre-push-base.sh (between
// its `# --- BODY START ---` / `# --- BODY END ---` markers). Every plain
// target gets that file verbatim. elm-m3e's target gets: its own extended
// header + a short wrapper (recursion guard, $remote_name capture) + the
// SAME body text (sliced from the base file programmatically, not
// re-typed) wrapped in visible BEGIN/END SHARED BASE markers + the
// Netlify-specific addendum from tools/hooks/pre-push-elm-m3e-extra.sh. A
// future fix to the shared base is one edit to pre-push-base.sh + a
// `node tools/gen-hooks.mjs` re-run — it reaches elm-m3e's copy automatically
// instead of needing a second by-hand patch.
//
// Usage:
//   node tools/gen-hooks.mjs           # regenerate every target, write to disk
//   node tools/gen-hooks.mjs --check   # regenerate in memory, byte-compare
//                                       # against committed files, exit 1 on drift
//
// Zero dependencies (plain Node ESM).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const hooksDir = path.join(repoRoot, "tools", "hooks");

const PLAIN_TARGETS = [
    "pipeline/elm-cem/hooks/pre-push",
    "pipeline/elm-cem/templates/pre-push",
    "packages/elm-virtual-dom-intermediate-representation/hooks/pre-push",
    "pipeline/elm-review-cem/hooks/pre-push",
    "brands/html/generated/package/elm-typed-html/hooks/pre-push",
    "brands/m3e/generated/okf/elm-m3e-okf/hooks/pre-push",
    "pipeline/elm-cem-figma-connect/hooks/pre-push",
];
const ELM_M3E_TARGET = "brands/m3e/outputs/elm-m3e/hooks/pre-push";

function extractBody(baseSrc) {
    const start = baseSrc.indexOf("# --- BODY START");
    const end = baseSrc.indexOf("# --- BODY END");
    if (start === -1 || end === -1) throw new Error("gen-hooks: pre-push-base.sh is missing its BODY START/END markers");
    const startLineEnd = baseSrc.indexOf("\n", start) + 1;
    return baseSrc.slice(startLineEnd, end).replace(/\n$/, "");
}

function buildElmM3eHook(base, extra) {
    const body = extractBody(base);
    return `#!/bin/sh
# pre-push — run this repo's own gate before anything leaves the machine, then
# build + commit docs/dist/ so Netlify serves the prebuilt static output.
#
# THIS FILE IS GENERATED (node tools/gen-hooks.mjs) from three pieces:
#   1. this header + the short wrapper below (recursion guard, $remote_name)
#   2. the SHARED BASE section (byte-identical to tools/hooks/pre-push-base.sh's
#      BODY — do not hand-edit between the markers; edit the base and regenerate)
#   3. the elm-m3e-specific Netlify addendum (tools/hooks/pre-push-elm-m3e-extra.sh)
# See docs/reviews/2026-08-17-thermonuclear-workspace-review.md Theme 3 for why
# this split exists: before it, this file was a silently-diverged 176-line
# hand copy of the shared base with no marker separating the two concerns.
#
# Escape hatches, in order of preference:
#   git push --no-verify              one-off bypass (skips gate AND dist auto-commit)
#   SKIP_GATE=1 git push              same, but explicit about what is being skipped
#   PREPUSH_FORCE_DIST_COMMIT=1 …     force the dist commit+self-push in a
#                                     non-interactive/CI context (exits non-zero by design)

set -e

# Recursion guard: the dist self-push in the addendum below re-fires this hook.
# Do nothing then — the tree is already gated and the dist commit is already made.
if [ "\${PREPUSH_GENERATED_SELF:-}" = "1" ]; then
  exit 0
fi

remote_name="$1"

# ============================================================================
# BEGIN SHARED BASE — byte-identical to tools/hooks/pre-push-base.sh's BODY.
# Fix bugs in tools/hooks/pre-push-base.sh, then \`node tools/gen-hooks.mjs\`.
# ============================================================================
${body}
# ============================================================================
# END SHARED BASE
# ============================================================================

${extra}`;
}

function main() {
    const check = process.argv.includes("--check");
    const base = fs.readFileSync(path.join(hooksDir, "pre-push-base.sh"), "utf8");
    const extra = fs.readFileSync(path.join(hooksDir, "pre-push-elm-m3e-extra.sh"), "utf8").replace(/\n$/, "");

    const targets = [...PLAIN_TARGETS.map((rel) => [rel, base]), [ELM_M3E_TARGET, buildElmM3eHook(base, extra)]];

    let drifted = [];
    for (const [rel, content] of targets) {
        const abs = path.join(repoRoot, rel);
        if (check) {
            const committed = fs.existsSync(abs) ? fs.readFileSync(abs, "utf8") : null;
            if (committed !== content) drifted.push(rel);
        } else {
            fs.mkdirSync(path.dirname(abs), { recursive: true });
            fs.writeFileSync(abs, content, { mode: 0o755 });
            console.log(`gen-hooks: wrote ${rel}`);
        }
    }

    if (check) {
        if (drifted.length > 0) {
            console.error(`check-hooks-sync: FAIL — ${drifted.length} hook(s) drifted from tools/hooks/pre-push-base.sh / pre-push-elm-m3e-extra.sh:`);
            for (const rel of drifted) console.error(`  - ${rel}`);
            console.error(`\nRegenerate with: node tools/gen-hooks.mjs`);
            process.exit(1);
        }
        console.log(`check-hooks-sync: OK — all ${targets.length} pre-push hooks match a fresh generation.`);
    }
}

if (import.meta.url === `file://${process.argv[1]}`) {
    main();
}
