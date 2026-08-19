// Review/confirm CLI machinery (task A6). `review` renders
// profiles/<p>/correspondence.json into a human-readable Markdown table —
// ONE row per component+property decision, never per-variant
// (plans/01-architecture.md §3.5) — and `confirm` reads back either the
// checked `[x]` boxes in that file, or an `overrides.json` decisions array,
// flipping accepted entries to `status:"confirmed"` / `provenance:"human"`
// so a future `match` re-run never touches them again (merge.mjs enforces
// that half; this module only produces/consumes the accept signal).
//
// Zero deps.

import fs from "node:fs";
import path from "node:path";

import { readCorrespondence, writeCorrespondence } from "./merge.mjs";

function escapeCell(text) {
  return String(text ?? "")
    .replace(/\r?\n/g, " ")
    .replace(/\|/g, "\\|");
}

function summarizeSets(entry) {
  if (!entry.figmaSets || entry.figmaSets.length === 0) return "(none — code-only)";
  return entry.figmaSets
    .map((s) => {
      const fixed = Object.entries(s.fixedAttrs ?? {})
        .map(([k, v]) => `${k}=${v}`)
        .join(",");
      return `${s.nodeId} (${s.setName})${fixed ? ` [${fixed}]` : ""}`;
    })
    .join("; ");
}

function summarizeAxes(entry) {
  if (!entry.axes || entry.axes.length === 0) return "(none)";
  return entry.axes
    .map((a) => (a.attr ? `${a.figmaProp}→${a.attr}` : `${a.figmaProp}: unmapped (${a.unmapped})`))
    .join("; ");
}

function summarizeProps(entry) {
  if (!entry.props || entry.props.length === 0) return "(none)";
  return entry.props
    .map((p) => (p.binding ? `${p.figmaProp}→${p.binding}` : `${p.figmaProp}: unmapped`))
    .join("; ");
}

function rowFor(entry) {
  const isIcon = entry.kind === "iconTable";
  const accept = entry.status === "confirmed" ? "[x]" : "[ ]";
  const sets = isIcon ? `icon table (${entry.icons.length} icons)` : summarizeSets(entry);
  const axes = isIcon ? "(n/a — value table)" : summarizeAxes(entry);
  const props = isIcon ? "(n/a — value table)" : summarizeProps(entry);
  const confidence = typeof entry.confidence === "number" ? entry.confidence.toFixed(3) : "";

  return (
    "| " +
    [
      accept,
      `\`${entry.cemTag}\``,
      escapeCell(entry.matcherKind ?? entry.kind ?? "component"),
      escapeCell(sets),
      escapeCell(axes),
      escapeCell(props),
      confidence,
      entry.provenance,
      entry.status,
      escapeCell(entry.rationale ?? ""),
    ].join(" | ") +
    " |"
  );
}

// renderReviewMarkdown(profileName, entries) -> markdown string
export function renderReviewMarkdown(profileName, entries) {
  const header = [
    `# Review — ${profileName}`,
    "",
    "One row per component+property decision, never per-variant " +
      "(plans/01-architecture.md §3.5). Check `[x]` in the Accept column and run " +
      "`confirm --profile <name> --from REVIEW.md` to accept a row — this flips its " +
      "`status` to `confirmed` and `provenance` to `human`; a future `match` re-run will " +
      "never modify it again (new auto data lands as `proposedUpdate` instead).",
    "",
    "| Accept | Tag | Kind | Figma sets | Axis proposals | Property proposals | Confidence | Provenance | Status | Rationale |",
    "|---|---|---|---|---|---|---|---|---|---|",
  ];
  const rows = entries.map(rowFor);
  return [...header, ...rows, ""].join("\n");
}

// -- parsing accepted rows back out of REVIEW.md ------------------------------

// Anchors on the checkbox + backtick-quoted cemTag at the start of a row —
// robust to arbitrary `|` in later cells (escaped by escapeCell above, but
// parsing never trusts that on the way back in).
const ROW_RE = /^\|\s*\[( |x|X)\]\s*\|\s*`([^`]+)`\s*\|/;

export function parseAcceptedTags(markdown) {
  const accepted = new Set();
  for (const line of markdown.split("\n")) {
    const m = ROW_RE.exec(line);
    if (m && m[1].toLowerCase() === "x") accepted.add(m[2]);
  }
  return accepted;
}

// confirmFromReview(entries, markdown) -> entries[] (new array; accepted
// entries flip to status:"confirmed"/provenance:"human", everything else is
// returned unchanged). Already satisfies "a human touching status always
// stamps provenance:human" (see confirmFromDecisions below) since the only
// status flip here (-> "confirmed") is always paired with provenance:"human"
// in the same object literal.
export function confirmFromReview(entries, markdown) {
  const accepted = parseAcceptedTags(markdown);
  return entries.map((entry) =>
    accepted.has(entry.cemTag) ? { ...entry, status: "confirmed", provenance: "human" } : entry
  );
}

// confirmFromDecisions(entries, decisions) -> entries[]
//
// decisions: [{ cemTag, status?, provenance? }] — the overrides.json shape.
// Only cemTags present in `entries` are touched; unknown cemTags are
// ignored (never invented as new entries here — that's the `add` delta in
// merge.mjs's computeEmitSet, a distinct concern from confirming a decision
// on an EXISTING proposal).
//
// Any decision that sets `status` (accept -> confirmed OR reject ->
// rejected) is, by definition, a human touching this entry — so it ALWAYS
// stamps provenance:"human" too, regardless of what (if anything) the
// decision itself put in `provenance`. This is what makes merge.mjs's
// isProtected() (provenance==="human" || status==="confirmed") also cover
// rejected entries: without this stamp, a "rejected"+"auto-*" entry is
// unprotected and a later `match` silently reverts the human's rejection
// back to "proposed" (see task-A6-report.md, Fix round).
export function confirmFromDecisions(entries, decisions) {
  const byTag = new Map(decisions.map((d) => [d.cemTag, d]));
  return entries.map((entry) => {
    const decision = byTag.get(entry.cemTag);
    if (!decision) return entry;
    return {
      ...entry,
      ...(decision.status ? { status: decision.status, provenance: "human" } : {}),
      ...(!decision.status && decision.provenance ? { provenance: decision.provenance } : {}),
    };
  });
}

// -- overrides.json I/O (shared by runConfirm above AND task C6's visual
// gate, src/visual/status.mjs + src/visual/review/server.mjs) ----------------
//
// overrides.json is ONE decisions array, keyed by cemTag, shared by two
// independent concerns that both write human decisions onto it:
//   - Plan A's binding confirm/reject: { cemTag, status, provenance }
//     (consumed by confirmFromDecisions above, correspondence.json-facing).
//   - Plan C's visual gate approve/reject/retarget: { cemTag, gate, note }
//     (consumed by src/visual/status.mjs, results-facing).
// Neither reads fields it doesn't recognize, so one cemTag's decision object
// can carry BOTH a `status` (binding confirm) and a `gate` (visual gate)
// without either concern clobbering the other — upsertOverride below
// shallow-merges a patch onto whatever's already there for that cemTag
// rather than replacing the whole object, which is what makes that
// coexistence safe.
//
// WB-fix round: `provenance` USED to be written by BOTH flows, which meant a
// pure visual-gate approve/reject (no `status`) still carried
// `provenance:"human"` — and confirmFromDecisions above stamps a decision's
// bare `provenance` straight onto the correspondence entry when `status` is
// absent. That silently protected a binding via merge.mjs's isProtected()
// purely because a human eyeballed a pixel diff, never confirmed the
// binding. Fix: C6's approve/reject (src/visual/review/server.mjs) no longer
// write `provenance` at all — only Plan A's own binding-confirm flow does.
// `provenance` on a decision object now always belongs to Plan A.

// readOverrides(overridesPath) -> decisions[] ([] if the file doesn't exist
// yet — no overrides recorded is a normal, not-yet-reviewed state).
export function readOverrides(overridesPath) {
  if (!fs.existsSync(overridesPath)) return [];
  return JSON.parse(fs.readFileSync(overridesPath, "utf8"));
}

const byCemTag = (a, b) => (a.cemTag < b.cemTag ? -1 : a.cemTag > b.cemTag ? 1 : 0);

// upsertOverride(overridesPath, cemTag, patch) -> decisions[] (also written
// back to overridesPath, sorted by cemTag for reviewable diffs).
//
// Writes IMMEDIATELY (task C6's "no bulk-save to lose" requirement) and
// touches ONLY the matching cemTag's entry: an existing decision object gets
// `patch`'s fields shallow-merged on top (so a `status`/`provenance` field
// from a prior binding-confirm decision on the SAME cemTag survives a later
// gate decision, and vice versa); a cemTag with no prior decision gets a
// fresh `{cemTag, ...patch}` object appended. This is the same
// "never blindly overwrite the whole file, key on cemTag" merge discipline
// merge.mjs's mergeCorrespondence established for correspondence.json —
// reused here for overrides.json rather than reimplemented.
export function upsertOverride(overridesPath, cemTag, patch) {
  const decisions = readOverrides(overridesPath);
  const idx = decisions.findIndex((d) => d.cemTag === cemTag);
  const updated =
    idx === -1
      ? [...decisions, { cemTag, ...patch }]
      : decisions.map((d, i) => (i === idx ? { ...d, ...patch } : d));
  updated.sort(byCemTag);

  fs.mkdirSync(path.dirname(overridesPath), { recursive: true });
  fs.writeFileSync(overridesPath, `${JSON.stringify(updated, null, 2)}\n`, "utf8");
  return updated;
}

// clearGateDecision(overridesPath, cemTag) -> decisions[] (also written back
// to overridesPath, same atomic-write discipline as upsertOverride above).
//
// The visual gate's "retarget" primitive (src/visual/review/server.mjs) —
// REMOVES a prior gate decision entirely rather than writing a new one, so a
// cemTag whose binding a human is mid-editing falls back to
// results-derivation (src/visual/status.mjs's status()) instead of being
// stuck reading whatever gate value was last written. This is the fix for a
// bug where retarget wrote a STICKY {gate:"pending"} override: status()
// checks the override branch BEFORE consulting results (see status.mjs's
// derivation-order comment), so that sticky value permanently stranded the
// entry in "pending" — even after a fully-passing re-render — because
// nothing ever cleared it, and buildQueue (server.mjs) only lists `failed`
// items, so a stranded entry could never even reappear in the review queue
// to be un-stuck.
//
// Clears `gate` and `note` unconditionally — those are the only two fields
// the visual gate ever writes (WB-fix round: gate decisions no longer write
// `provenance` at all, see the overrides.json header comment above, so
// there's no "gate-owned provenance" left to reason about here). A
// coexisting Plan A `status`/`provenance` decision on the SAME cemTag object
// belongs entirely to that other concern and is never touched.
//
// If clearing leaves nothing but `{cemTag}`, the whole decision object is
// removed from the array (an empty decision is pointless to keep around).
// Never touches any OTHER cemTag's entry. A cemTag with no existing
// override at all is a no-op (nothing to clear).
export function clearGateDecision(overridesPath, cemTag) {
  const decisions = readOverrides(overridesPath);
  const idx = decisions.findIndex((d) => d.cemTag === cemTag);
  if (idx === -1) return decisions;

  const current = decisions[idx];
  const cleared = { ...current };
  delete cleared.gate;
  delete cleared.note;

  const hasRemainingFields = Object.keys(cleared).some((key) => key !== "cemTag");
  const updated = hasRemainingFields
    ? decisions.map((d, i) => (i === idx ? cleared : d))
    : decisions.filter((_, i) => i !== idx);

  fs.mkdirSync(path.dirname(overridesPath), { recursive: true });
  fs.writeFileSync(overridesPath, `${JSON.stringify(updated, null, 2)}\n`, "utf8");
  return updated;
}

// -- CLI-facing orchestration --------------------------------------------------

// runReview({ profileDir, correspondencePath, reviewPath }) -> markdown string
// (also written to reviewPath, default profileDir/REVIEW.md).
export function runReview({ profileDir, correspondencePath, reviewPath }) {
  const corrPath = correspondencePath ?? path.join(profileDir, "correspondence.json");
  const entries = readCorrespondence(corrPath);
  const profileName = path.basename(profileDir);
  const markdown = renderReviewMarkdown(profileName, entries);

  const outPath = reviewPath ?? path.join(profileDir, "REVIEW.md");
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, markdown, "utf8");
  return markdown;
}

// runConfirm({ profileDir, correspondencePath, from, overridesPath }) ->
// entries[] (also written back to correspondencePath).
//
// `from`: path to a REVIEW.md-shaped file to read accepted `[x]` rows from.
// Omit it to fall back to `overridesPath`'s decisions array (default
// profileDir/overrides.json).
export function runConfirm({ profileDir, correspondencePath, from, overridesPath }) {
  const corrPath = correspondencePath ?? path.join(profileDir, "correspondence.json");
  const entries = readCorrespondence(corrPath);

  let updated;
  if (from) {
    const markdown = fs.readFileSync(from, "utf8");
    updated = confirmFromReview(entries, markdown);
  } else {
    const decisionsPath = overridesPath ?? path.join(profileDir, "overrides.json");
    const decisions = readOverrides(decisionsPath);
    updated = confirmFromDecisions(entries, decisions);
  }

  return writeCorrespondence(corrPath, updated);
}
