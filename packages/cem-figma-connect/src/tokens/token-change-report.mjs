// Phase 4 (L7 + L8): token-change-report.md + the bump gate.
//
// Surfaces "required code change" verdicts to a human (Decision 3: report +
// bump-section + gate). Two sources of change:
//   - DELTA classification (classify-delta.mjs) — a before→after design delta.
//   - STANDING required-code-changes — the cross-source token AUDIT's
//     spec-failures (audit.mjs), folded here as tier-attributed rows (L8) so the
//     audit and this report never double-count and always agree.
//
// GATE (Decision 3, v1 = NON-BLOCKING / warn): a bump surfaces token deltas by
// tier/kind. `runGate(..., {strict})` CAN fail on an unabsorbed, un-filed
// BLOCKING required-code-change — but the shipped `bump` wiring runs it
// NON-STRICT (warn, exit 0), because the detector is young (Decision 3: don't
// hard-block a bump yet). Strict mode exists, is tested, and is the one-line
// flip when the detector is trusted.
//
// SEVERITY (Decision 7): the audit's ~20 tone-table approximation-noise rows are
// a documented, accepted approximation — they are ADVISORY (never block), while
// the ~8 genuine derivation bugs (container-tone regression ×4, tertiary/error
// model divergence ×4) + any numeric spec-failure are BLOCKING-band.
//
// Zero new deps (plain Node ESM).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { byKey } from "../lib/order.mjs";
import { runAudit } from "./audit.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
export const repoRoot = path.join(here, "..", "..");

export const DEFAULT_REPORT_PATH = path.join(repoRoot, "profiles", "m3-kit", "token-change-report.md");

// Root-cause → tier + offending file + severity. This IS the Decision-7 split:
// the two derivation-model buckets are blocking; the tone-table noise bucket is
// advisory. Mirrors audit.mjs's own rootCause taxonomy so the two agree.
const ROOTCAUSE_MAP = {
  "container-tone-regression": {
    tier: "system",
    file: "tailwind-m3e-web/src/sys/color.css",
    reason: "alias-repoint",
    severity: "blocking",
    summary: "on-*-container roles alias the wrong tone (sys/color.css derivation is stale)",
  },
  "model-divergence": {
    tier: "reference",
    file: "tailwind-m3e-web/src/ref/palette.css",
    reason: "alias-repoint",
    severity: "blocking",
    summary: "tertiary/error chroma model diverges from the kit (ref/palette.css derivation choice)",
  },
  "tone-table-approximation-noise": {
    tier: "reference",
    file: "tailwind-m3e-web/bin/calibrate-tones.mjs",
    reason: "value-approximation",
    severity: "advisory",
    summary: "tone-table hue-sampling approximation crosses the deltaE tolerance (documented, accepted)",
  },
};

// collectStandingChanges() -> tier-attributed required-code-change rows folded
// from the audit's spec-failures + numeric required-code-changes. One row per
// offending token; `source: "audit"` so a consumer can trace it back. No
// double-count: exactly one row per audit spec-failure / numeric-required row.
export function collectStandingChanges(auditPaths = {}, auditOptions = {}) {
  const { colorRows, numericRows } = runAudit(auditPaths, auditOptions);
  const changes = [];

  for (const row of colorRows) {
    if (row.status !== "spec-failure") continue;
    const map = ROOTCAUSE_MAP[row.rootCause] ?? {
      tier: "system",
      file: "tailwind-m3e-web/src/sys/color.css",
      reason: "alias-repoint",
      severity: "blocking",
      summary: `unclassified spec-failure (${row.rootCause ?? "none"})`,
    };
    // L8: carry the audit's measured evidence so this row is a faithful
    // re-expression of the audit spec-failure (traceable, no re-measurement).
    const deltaE = Math.max(
      row.light?.deLightComputed ?? 0,
      row.dark?.deDarkComputed ?? 0,
      row.light?.deLightFallback ?? 0,
    );
    changes.push({
      source: "audit",
      token: row.md,
      tier: map.tier,
      kind: "required-code-change",
      reason: map.reason,
      severity: map.severity,
      file: map.file,
      rootCause: row.rootCause,
      deltaE: Number(deltaE.toFixed(3)),
      detail: `${map.summary} (max deltaE ${deltaE.toFixed(3)})`,
    });
  }

  for (const row of numericRows) {
    if (row.classification !== "required-code-change") continue;
    changes.push({
      source: "audit",
      token: row.md,
      tier: "system",
      kind: "required-code-change",
      reason: "value-mismatch",
      severity: "blocking",
      file: row.codeFile ? `tailwind-m3e-web/${row.codeFile.replace(/^tailwind-m3e-web\//, "")}` : "tailwind-m3e-web/src/sys/typescale.css",
      rootCause: "numeric-spec-failure",
      detail: row.classificationDetail ?? "numeric spec-failure (exact-match)",
    });
  }

  changes.sort(byKey((c) => `${c.severity} ${c.tier} ${c.file} ${c.token}`));
  return changes;
}

// changesFromVerdict(verdict) -> change row(s) for a classify-delta verdict, so
// a live before→after delta feeds the same report/gate as the standing audit
// rows. A required-code-change is blocking-band (a name/edge/emitter change);
// a retheme yields no rows.
export function changesFromVerdict(verdict) {
  if (verdict.kind !== "required-code-change") return [];
  const file = verdict.files[0] ?? verdict.outputs[0]?.key ?? "(unknown)";
  const token = verdict.outputs.map((o) => o.surface).join(", ") || verdict.files.join(", ") || "(delta)";
  return [
    {
      source: "delta",
      token,
      tier: verdict.tier,
      kind: "required-code-change",
      reason: verdict.reason,
      severity: "blocking",
      file,
      detail: verdict.detail,
    },
  ];
}

// -- gate --------------------------------------------------------------------

// runGate(changes, {strict}) -> { blocking, blockingChanges, advisoryChanges }
// A change is BLOCKING-band iff severity==="blocking" AND it has no filed
// follow-up. In v1 (strict=false) nothing blocks — the gate only WARNS.
export function runGate(changes, { strict = false, followUps = new Set() } = {}) {
  const unfiledBlocking = changes.filter(
    (c) => c.kind === "required-code-change" && c.severity === "blocking" && !followUps.has(c.token),
  );
  const advisory = changes.filter((c) => c.severity === "advisory");
  return {
    blocking: strict && unfiledBlocking.length > 0,
    blockingChanges: unfiledBlocking,
    advisoryChanges: advisory,
  };
}

// -- render ------------------------------------------------------------------

export function renderReport(changes) {
  const blocking = changes.filter((c) => c.severity === "blocking");
  const advisory = changes.filter((c) => c.severity === "advisory");
  const byTier = {};
  for (const c of changes) byTier[c.tier] = (byTier[c.tier] ?? 0) + 1;

  const lines = [];
  lines.push("# m3-kit token-change report — tier-attributed required code changes (Phase 4)");
  lines.push("");
  lines.push(
    "Generated by `node src/tokens/token-change-report.mjs`. Every row is a delta that " +
      "re-theming CANNOT absorb — it forces a code change — attributed to a **tier**, an **owner file**, " +
      "and a **reason**. Standing rows are folded from the cross-source token audit " +
      "(`token-audit.md`) so the two never double-count.",
  );
  lines.push("");
  lines.push(
    "**Gate policy (Decision 3): NON-BLOCKING in v1.** A bump surfaces these rows in its report and " +
      "warns; it does not yet fail on an unfiled blocking change (the detector is young). Strict mode " +
      "(`runGate(..., {strict:true})`) is tested and is the one-line flip when trusted.",
  );
  lines.push("");
  lines.push(
    "**Severity (Decision 7):** the tone-table approximation-noise rows are a documented, accepted " +
      "approximation — **advisory** (never block). The genuine derivation bugs (container-tone " +
      "regression, tertiary/error model divergence) + numeric spec-failures are **blocking-band**.",
  );
  lines.push("");
  lines.push("## Summary");
  lines.push("");
  lines.push(`- Required code changes: **${changes.length}** (blocking **${blocking.length}**, advisory **${advisory.length}**)`);
  for (const tier of Object.keys(byTier).sort()) lines.push(`  - ${tier}-tier: **${byTier[tier]}**`);
  lines.push("");

  const section = (title, rows) => {
    lines.push(`## ${title} (${rows.length})`);
    lines.push("");
    if (rows.length === 0) {
      lines.push("_None._");
      lines.push("");
      return;
    }
    lines.push("| token | tier | reason | owner file | detail |");
    lines.push("|---|---|---|---|---|");
    for (const c of rows) {
      lines.push(`| \`${c.token}\` | ${c.tier} | ${c.reason} | \`${c.file}\` | ${c.detail} |`);
    }
    lines.push("");
  };

  section("Blocking-band required code changes", blocking);
  section("Advisory required code changes (tone-table approximation noise, Decision 7)", advisory);

  return lines.join("\n");
}

export function serializeReport(changes) {
  return `${renderReport(changes)}\n`;
}

// -- CLI / --check -----------------------------------------------------------

function main(argv) {
  const check = argv.includes("--check");
  const changes = collectStandingChanges();
  const fresh = serializeReport(changes);

  if (check) {
    const existing = fs.existsSync(DEFAULT_REPORT_PATH) ? fs.readFileSync(DEFAULT_REPORT_PATH, "utf8") : null;
    if (existing !== fresh) {
      process.stderr.write(
        `token-change-report.mjs --check: ${DEFAULT_REPORT_PATH} is stale. ` +
          `Run \`node src/tokens/token-change-report.mjs\` to refresh it.\n`,
      );
      process.exitCode = 1;
      return;
    }
    const gate = runGate(changes, { strict: false });
    process.stdout.write(
      `token-change-report.mjs --check: byte-stable ` +
        `(${changes.length} required-code-change rows: ${gate.blockingChanges.length} blocking, ${gate.advisoryChanges.length} advisory; gate NON-BLOCKING per Decision 3).\n`,
    );
    return;
  }

  fs.mkdirSync(path.dirname(DEFAULT_REPORT_PATH), { recursive: true });
  fs.writeFileSync(DEFAULT_REPORT_PATH, fresh, "utf8");
  process.stdout.write(`token-change-report.mjs: wrote ${DEFAULT_REPORT_PATH} (${changes.length} rows).\n`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main(process.argv.slice(2));
}
