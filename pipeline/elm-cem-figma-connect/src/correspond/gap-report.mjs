// Gap report (task A7; decision D6 — "code-only/figma-only gaps are a
// first-class report; LOG, never author" — and plans/BRIEF.md §7.4, the
// completeness inversion: Figma only shows what was DRAWN; the CEM's enum
// types define the full possible value space, so gaps are enumerated FROM
// the CEM outward, using Figma only to say what already exists).
//
// Four sections, each a deterministic Markdown table:
//   code-only          — CEM tags with NO Figma counterpart at exact/fuzzy
//                         tier (all CEM tags minus the matcher's bound set).
//   figma-only          — Figma sets/standalones the matcher gapped
//                         (tier:"gap", cemTag:null) — a drawn kit entity
//                         with no CEM counterpart at any tier.
//   valid-but-undrawn   — per MATCHED component: the CEM cartesian value
//                         space over the matcher's own mapped axes/fusion
//                         attribute, minus the combinations the matcher's
//                         captured Figma data can confirm were drawn.
//   unmapped-axes       — Figma VARIANT axes on a matched component that the
//                         matcher could not bind to any CEM enum attribute.
//
// RECONCILIATION vs research/evidence/06a-expressive-delta.md: 06a's
// "53 matched / 68 code-only" is an OPTIMISTIC human name-level read. The
// real auto-matcher (src/match/matcher.mjs) binds only 26 distinct CEM tags
// here (24 exact + 2 fuzzy after Fix 2 — leading-dot sets excluded from
// exact tier) — the doc-URL fuzzy signal is inert on this
// fixture (0 shared m3.material.io URLs either side), FUZZY_ACCEPT_THRESHOLD
// is deliberately conservative (0.50), and abbreviation/semantic-only
// matches (e.g. "Standard button group"/"Connected button group" vs
// m3e-button-group) are deliberately NOT forced through (D6) — they land in
// code-only, for human review, instead. So code-only here measures
// 121-26=95, NOT 68. This is BY DESIGN — see task-A7-report.md — the report
// exists to surface exactly this human-review surface, not to hide it by
// matching harder.
//
// valid-but-undrawn's real, measured finding on this fixture: of the 26
// matched components, only TWO carry any dimension data at all —
// m3e-button (Size/Type from its 2 of 5 fused sibling sets' captured
// `setProperties` — this is the pre-A3 A2 fixture, which only captured 2 of
// 171 kit sets' properties live — PLUS its `variant` fusion attribute, bound
// from sibling SET NAMES rather than setProperties) and m3e-icon-button
// (`variant` only, likewise bound from its 4 sibling sets' NAMES — a fusion
// group's fixedValues need no captured setProperties at all, only the sets'
// own names). The other 24 matched components have zero dimension data and
// are called out rather than silently skipped. For both components that DO
// carry data, every dimension's coverage is complete on this fixture (button:
// shape 2/2, size 5/5, variant 5/5; icon-button: variant 4/4), so the
// measured valid-but-undrawn count is 0 combinations — not a fabricated
// example — see task-A7-report.md.
//
// Zero deps beyond node:fs/node:path + the sibling matcher/merge modules +
// the shared ordinal comparator in ../lib/order.mjs.

import fs from "node:fs";
import path from "node:path";

import { match } from "../match/matcher.mjs";
import { loadProfile } from "./merge.mjs";
import { byString } from "../lib/order.mjs";

// Ordinal (code-unit) compare — deliberately NOT localeCompare, which is
// ICU/locale-sensitive and would threaten byte-stability (same rule
// merge.mjs's byCemTag documents). Shared with matcher.mjs/fusion.mjs/
// merge.mjs via ../lib/order.mjs.
const cmp = byString;

function escapeCell(text) {
  return String(text ?? "")
    .replace(/\r?\n/g, " ")
    .replace(/\|/g, "\\|");
}

function renderTable(headers, rowLines) {
  const head = `| ${headers.join(" | ")} |`;
  const sep = `|${headers.map(() => " --- ").join("|")}|`;
  return [head, sep, ...rowLines].join("\n");
}

// -- code-only ----------------------------------------------------------------

// computeCodeOnly(cem, candidates) -> [{ tag, description, rationale }]
//
// All CEM tags MINUS the distinct tags the matcher bound at exact/fuzzy
// tier. A tag the matcher itself surfaced with kind:"code-only" (e.g.
// m3e-tab, which lost the tab/tabs slug collision to m3e-tabs — see
// matcher.mjs's resolveAmbiguousExact) carries ITS OWN rationale; every
// other code-only tag gets a generic one. Sorted by tag (ordinal).
export function computeCodeOnly(cem, candidates) {
  const matchedTags = new Set(
    candidates
      .filter((c) => (c.tier === "exact" || c.tier === "fuzzy" || c.tier === "contains") && c.cemTag)
      .map((c) => c.cemTag)
  );
  const explicitRationale = new Map(
    candidates.filter((c) => c.kind === "code-only").map((c) => [c.cemTag, c.rationale.join(" | ")])
  );

  const rows = cem.components
    .filter((c) => !matchedTags.has(c.tag))
    .map((c) => ({
      tag: c.tag,
      description: c.description,
      rationale:
        explicitRationale.get(c.tag) ??
        "no Figma candidate reached the exact/fuzzy match threshold (D6: abbreviation/semantic-only " +
          "matches are deferred to human review, never auto-forced)",
    }));

  rows.sort((a, b) => cmp(a.tag, b.tag));
  return rows;
}

// -- figma-only ---------------------------------------------------------------

// computeFigmaOnly(candidates) -> [{ page, name, kind, rationale }]
//
// Every matcher candidate at tier:"gap" with cemTag:null (a real Figma
// entity — fusion group, set, standalone, or the icon page — with no CEM
// counterpart at any tier). Sorted by page then name (ordinal).
export function computeFigmaOnly(candidates) {
  const rows = candidates
    .filter((c) => c.tier === "gap" && c.cemTag === null)
    .map((c) => ({
      page: c.page ?? "",
      name: c.figmaName,
      kind: c.kind,
      rationale: c.rationale.join(" | "),
    }));

  rows.sort((a, b) => cmp(a.page, b.page) || cmp(a.name, b.name));
  return rows;
}

// -- valid-but-undrawn (the completeness inversion, BRIEF §7.4) --------------

function attrByName(component, name) {
  return component.attributes.find((a) => a.name === name);
}

// The dimensions a matched candidate's OWN matcher output lets us reason
// about: each MAPPED variant axis, plus (for a fusion) the fixed fusion
// attribute — each paired with the full CEM enum value list (the cartesian
// spine) and the CEM values the matcher's captured Figma data confirms were
// drawn (the axis valueMap / fusion fixedValues). A component with none of
// these (no captured Figma setProperties at all) returns [] — callers must
// treat that as "no data", never as "fully drawn" or "fully undrawn".
export function matchedDimensions(candidate, component) {
  const dims = [];

  for (const axis of candidate.axisProposals ?? []) {
    if (!axis.mapped) continue;
    const attr = attrByName(component, axis.attribute);
    if (!attr || !Array.isArray(attr.values)) continue;
    dims.push({
      label: axis.attribute,
      full: attr.values,
      drawn: new Set(axis.valueMap.map((v) => v.cem)),
    });
  }

  if (candidate.fusion?.attribute) {
    const attr = attrByName(component, candidate.fusion.attribute);
    if (attr && Array.isArray(attr.values)) {
      dims.push({
        label: candidate.fusion.attribute,
        full: attr.values,
        drawn: new Set(candidate.fusion.fixedValues.map((f) => f.cemValue).filter((v) => v != null)),
      });
    }
  }

  return dims;
}

// assertNoDuplicateLabels(dims) — combo objects are built via
// `{ ...combo, [dim.label]: value }` (one JS object key per dimension), so
// two dims sharing a label would silently collapse onto the same key while
// still being iterated independently, distorting the combo count with no
// visible symptom. Not reachable today (a component's fusion attribute name
// happening to equal one of its own mapped axis attribute names), but
// unguarded otherwise — this is a defensive, fail-loud check for that case.
function assertNoDuplicateLabels(dims) {
  const seen = new Set();
  for (const dim of dims) {
    if (seen.has(dim.label)) {
      throw new Error(
        `gap-report: duplicate dimension label "${dim.label}" — a component's fusion attribute name ` +
          "collides with one of its mapped axis attribute names, which would silently collapse two " +
          "independent dimensions onto one object key and distort the cartesian combo count. Refusing to " +
          "compute rather than render a misleading valid-but-undrawn result."
      );
    }
    seen.add(dim.label);
  }
}

// cartesianMinusDrawn(dims) -> [{ [label]: value, ... }]
//
// Every combination across the full cartesian product where AT LEAST ONE
// coordinate's value has no confirmed drawn Figma instance anywhere the
// matcher's own axis/fusion data reaches. This is a MARGINAL (per-axis)
// notion of "drawn", not a true per-instance combination check — the export
// shape carries no parent link from a drawn variant COMPONENT back to which
// sibling SET it belongs (see task-A7-report.md), so per-axis coverage is
// the finest granularity available from these interfaces.
export function cartesianMinusDrawn(dims) {
  assertNoDuplicateLabels(dims);

  let combos = [{}];
  for (const dim of dims) {
    const next = [];
    for (const combo of combos) {
      for (const value of dim.full) next.push({ ...combo, [dim.label]: value });
    }
    combos = next;
  }
  return combos.filter((combo) => dims.some((dim) => !dim.drawn.has(combo[dim.label])));
}

// computeValidButUndrawn(cem, candidates) -> {
//   rows: [{ cemTag, combo, rationale }],   // sorted by cemTag then combo
//   noData: [cemTag, ...],                  // matched components with zero
//                                            // axis/fusion data to reason
//                                            // about — a fixture-completeness
//                                            // limitation, not a design gap
// }
export function computeValidButUndrawn(cem, candidates) {
  const byTag = new Map(cem.components.map((c) => [c.tag, c]));
  const rows = [];
  const noData = [];

  const matched = candidates.filter((c) => (c.tier === "exact" || c.tier === "fuzzy" || c.tier === "contains") && c.cemTag);
  for (const candidate of matched) {
    const component = byTag.get(candidate.cemTag);
    if (!component) continue;

    const dims = matchedDimensions(candidate, component);
    if (dims.length === 0) {
      noData.push(candidate.cemTag);
      continue;
    }

    for (const combo of cartesianMinusDrawn(dims)) {
      rows.push({
        cemTag: candidate.cemTag,
        combo,
        rationale:
          `cartesian over ${dims.map((d) => d.label).join(" × ")} (sizes: ` +
          dims.map((d) => `${d.label}=${d.full.length}`).join(", ") +
          `) includes this combination, but no captured Figma axis/fusion data confirms it was drawn`,
      });
    }
  }

  rows.sort((a, b) => cmp(a.cemTag, b.cemTag) || cmp(JSON.stringify(a.combo), JSON.stringify(b.combo)));
  noData.sort(cmp);
  return { rows, noData };
}

// -- unmapped-axes --------------------------------------------------------------

// computeUnmappedAxes(candidates) -> [{ cemTag, figmaProp, reason }]
//
// Every VARIANT axis on a MATCHED candidate's set/fusion the matcher could
// not bind to any CEM enum attribute (axisProposals[].mapped === false).
// Sorted by cemTag then figmaProp.
export function computeUnmappedAxes(candidates) {
  const rows = [];
  for (const candidate of candidates) {
    if (!((candidate.tier === "exact" || candidate.tier === "fuzzy" || candidate.tier === "contains") && candidate.cemTag)) continue;
    for (const axis of candidate.axisProposals ?? []) {
      if (axis.mapped) continue;
      rows.push({ cemTag: candidate.cemTag, figmaProp: axis.axis, reason: axis.reason });
    }
  }
  rows.sort((a, b) => cmp(a.cemTag, b.cemTag) || cmp(a.figmaProp, b.figmaProp));
  return rows;
}

// -- assembly + rendering -------------------------------------------------------

// buildGapReport(cem, candidates) -> { codeOnly, figmaOnly, validButUndrawn,
//   unmappedAxes, counts } — every section computed exactly once, so the
// counts header and the tables below it can never drift apart.
export function buildGapReport(cem, candidates) {
  const codeOnly = computeCodeOnly(cem, candidates);
  const figmaOnly = computeFigmaOnly(candidates);
  const validButUndrawn = computeValidButUndrawn(cem, candidates);
  const unmappedAxes = computeUnmappedAxes(candidates);

  const matchedTags = new Set(
    candidates
      .filter((c) => (c.tier === "exact" || c.tier === "fuzzy" || c.tier === "contains") && c.cemTag)
      .map((c) => c.cemTag)
  );
  const exactCount = candidates.filter((c) => c.tier === "exact" && c.cemTag).length;
  const fuzzyCount = candidates.filter((c) => c.tier === "fuzzy" && c.cemTag).length;
  const containsCount = candidates.filter((c) => c.tier === "contains" && c.cemTag).length;

  const counts = {
    cemTagsTotal: cem.components.length,
    matched: matchedTags.size,
    exact: exactCount,
    fuzzy: fuzzyCount,
    contains: containsCount,
    codeOnly: codeOnly.length,
    figmaOnly: figmaOnly.length,
    validButUndrawn: validButUndrawn.rows.length,
    validButUndrawnNoData: validButUndrawn.noData.length,
    unmappedAxes: unmappedAxes.length,
  };

  return { codeOnly, figmaOnly, validButUndrawn, unmappedAxes, counts };
}

function comboLabel(combo) {
  return Object.entries(combo)
    .map(([k, v]) => `${k}=${v}`)
    .join(", ");
}

// renderGapReportMarkdown(profileName, cem, candidates) -> markdown string
export function renderGapReportMarkdown(profileName, cem, candidates) {
  const { codeOnly, figmaOnly, validButUndrawn, unmappedAxes, counts } = buildGapReport(cem, candidates);

  const lines = [];
  lines.push(`# Gap report — ${profileName}`);
  lines.push("");
  lines.push(
    "D6: this report LOGS gaps for human review — it never auto-authors a correspondence entry from a " +
      "guess. See plans/BRIEF.md §7.4 (the completeness inversion) and " +
      "research/evidence/06a-expressive-delta.md for the name-level estimate this reconciles against."
  );
  lines.push("");
  lines.push("## Counts");
  lines.push("");
  lines.push(`- CEM tags total: ${counts.cemTagsTotal}`);
  lines.push(`- Matched (distinct CEM tags): ${counts.matched} (${counts.exact} exact, ${counts.fuzzy} fuzzy, ${counts.contains} contains)`);
  lines.push(`- code-only: ${counts.codeOnly}`);
  lines.push(`- figma-only: ${counts.figmaOnly}`);
  lines.push(`- valid-but-undrawn combinations: ${counts.validButUndrawn} (${counts.validButUndrawnNoData} matched component(s) have no axis/fusion data to evaluate — see the section below)`);
  lines.push(`- unmapped axes: ${counts.unmappedAxes}`);
  lines.push("");
  lines.push(
    "**Reconciliation vs 06a:** research/evidence/06a-expressive-delta.md's human, name-level read of this " +
      `same fixture estimated 53 matched / 68 code-only. The auto-matcher measured here binds only ${counts.matched} ` +
      `distinct CEM tags (${counts.exact} exact + ${counts.fuzzy} fuzzy + ${counts.contains} contains), so code-only measures ${counts.codeOnly}, not 68. ` +
      "This is BY DESIGN, not a defect: the doc-URL fuzzy signal is inert on this fixture (0 shared " +
      "m3.material.io URLs on either side), `FUZZY_ACCEPT_THRESHOLD` (0.50) is deliberately conservative, and " +
      "abbreviation/semantic-only matches (e.g. \"Standard button group\"/\"Connected button group\" vs " +
      "`m3e-button-group`) are deliberately NOT forced through (D6) — the gap between 06a's optimistic estimate " +
      "and the measured code-only count IS the human-review surface this report exists to produce."
  );
  lines.push("");

  lines.push("## code-only");
  lines.push("");
  lines.push(
    "CEM tags with NO Figma counterpart at exact/fuzzy tier — computed as all CEM tags MINUS the distinct " +
      "tags the matcher bound."
  );
  lines.push("");
  lines.push(
    renderTable(
      ["CEM tag", "Description", "Rationale"],
      codeOnly.map((r) => `| \`${r.tag}\` | ${escapeCell(r.description)} | ${escapeCell(r.rationale)} |`)
    )
  );
  lines.push("");

  lines.push("## figma-only");
  lines.push("");
  lines.push(
    "Figma sets/standalone components the matcher gapped (`cemTag: null`) — a drawn kit entity with no CEM " +
      "counterpart at any tier."
  );
  lines.push("");
  lines.push(
    renderTable(
      ["Page", "Figma name", "Kind", "Rationale"],
      figmaOnly.map(
        (r) => `| ${escapeCell(r.page)} | ${escapeCell(r.name)} | ${escapeCell(r.kind)} | ${escapeCell(r.rationale)} |`
      )
    )
  );
  lines.push("");

  lines.push("## valid-but-undrawn");
  lines.push("");
  lines.push(
    "Per MATCHED component: the CEM cartesian value space over the matcher's own mapped axes / fusion " +
      "attribute, minus the combinations the matcher's captured Figma data confirms were drawn — the " +
      "completeness inversion (plans/BRIEF.md §7.4)."
  );
  lines.push("");
  lines.push(
    "**Coverage caveat (always applies, not just when data is missing):** coverage is checked PER-AXIS " +
      "(marginal), not per-joint-combination, because the figma-export carries no variant→owning-set parent " +
      "link — this cannot detect a combination whose individual axis values are each drawn elsewhere but never " +
      "drawn TOGETHER. Treat an empty result for a component as \"no axis value was individually undrawn,\" " +
      "NOT as proof of full combinatorial coverage."
  );
  lines.push("");
  if (validButUndrawn.noData.length > 0) {
    lines.push(
      `> **Data limitation, not a design gap:** ${validButUndrawn.noData.length} of the ${counts.matched} matched ` +
        `component(s) (${validButUndrawn.noData.map((t) => `\`${t}\``).join(", ")}) carry zero axis/fusion data on ` +
        "this pre-A3 fixture (only 2 of 171 kit sets' `setProperties` were captured live — the button's bare and " +
        "elevated sibling sets — and these components have no fusion sibling sets to fall back on either). This " +
        "section can only reason about the component(s) that DO carry dimension data; A3's live extractor unlocks " +
        "the rest."
    );
    lines.push("");
  }
  lines.push(
    renderTable(
      ["CEM tag", "Combination", "Rationale"],
      validButUndrawn.rows.map(
        (r) => `| \`${r.cemTag}\` | ${escapeCell(comboLabel(r.combo))} | ${escapeCell(r.rationale)} |`
      )
    )
  );
  lines.push("");

  lines.push("## unmapped-axes");
  lines.push("");
  lines.push(
    "Figma VARIANT axes on a matched component's set/fusion that the matcher could not bind to any CEM enum " +
      "attribute — never silently dropped (plans/01-architecture.md §3 item 4)."
  );
  lines.push("");
  lines.push(
    renderTable(
      ["CEM tag", "Figma axis", "Reason"],
      unmappedAxes.map((r) => `| \`${r.cemTag}\` | ${escapeCell(r.figmaProp)} | ${escapeCell(r.reason)} |`)
    )
  );
  lines.push("");

  return lines.join("\n");
}

// -- CLI-facing orchestration --------------------------------------------------

// runGapReport({ profileDir, loadCem, loadFigmaExport, outPath }) -> {
//   markdown, counts, outPath
// }
//
// Runs the matcher fresh against the profile's own cem + figma-export inputs
// (never persists a correspondence decision — that's match/review/confirm's
// job) and writes the rendered report. `outPath` defaults to
// profileDir/gap-report.md but is overridable so tests never write into a
// checked-in profile dir. `loadCem`/`loadFigmaExport` are injected (same
// pattern as merge.mjs's runMatch) so this stays a thin, testable
// orchestration layer over the real ingest loaders.
export function runGapReport({ profileDir, loadCem, loadFigmaExport, outPath }) {
  const profile = loadProfile(profileDir);
  const cem = loadCem(profile.cemManifestPath, { dtsDir: profile.cemDtsDir, log: () => {} });
  const figma = loadFigmaExport(profile.figmaExportPath);
  const { candidates } = match(cem, figma, profile.matcherConfig);

  const profileName = path.basename(profileDir);
  const markdown = renderGapReportMarkdown(profileName, cem, candidates);

  const resolvedOutPath = outPath ?? path.join(profileDir, "gap-report.md");
  fs.mkdirSync(path.dirname(resolvedOutPath), { recursive: true });
  fs.writeFileSync(resolvedOutPath, markdown, "utf8");

  const { counts } = buildGapReport(cem, candidates);
  return { markdown, counts, outPath: resolvedOutPath };
}
