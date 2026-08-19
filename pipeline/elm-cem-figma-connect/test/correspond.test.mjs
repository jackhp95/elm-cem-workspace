// Task A6: correspondence schema, human-preserving merge, review/confirm.
//
// Run with the file-arg form (bare `node --test` mis-discovers `.d.ts`
// fixtures on this repo's Node, per prior tasks' notes):
//   node --test test/correspond.test.mjs

import { test } from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";

import { loadCem } from "../src/ingest/cem.mjs";
import { loadFigmaExport } from "../src/ingest/figma.mjs";
import { validate } from "../src/lib/validate.mjs";
import {
  buildProposals,
  entriesFromCandidates,
  mergeCorrespondence,
  computeEmitSet,
  readCorrespondence,
  writeCorrespondence,
  runMatch,
  repoRoot,
  applyManualCorrespondence,
  validateManualCorrespondence,
} from "../src/correspond/merge.mjs";
import { loadMatcherConfig } from "../src/match/matcher.mjs";
import {
  renderReviewMarkdown,
  parseAcceptedTags,
  confirmFromReview,
  confirmFromDecisions,
  runReview,
  runConfirm,
} from "../src/correspond/review.mjs";

const here = path.dirname(fileURLToPath(import.meta.url));
const schema = JSON.parse(fs.readFileSync(path.join(here, "..", "src", "correspond", "schema.json"), "utf8"));

const cem = loadCem(
  path.join(here, "fixtures", "cem-facts.m3e-web-2.5.14.json"),
  { log: () => {} }
);
const figma = loadFigmaExport(path.join(here, "fixtures", "figma-export.m3-kit.json"));

// The m3-kit profile's own calibration (finding 2.4) — this fixture IS the
// m3-kit export, so it uses the same matcher.json a real `match` run would.
const m3KitMatcherConfig = loadMatcherConfig(path.join(here, "..", "profiles", "m3-kit"));

// Loaded once — both fixtures are large. Every assertion reads this view.
const proposed = buildProposals(cem, figma, m3KitMatcherConfig);
const byTag = (tag) => proposed.find((e) => e.cemTag === tag);

function tmpPath(name) {
  return path.join(os.tmpdir(), `cem-figma-connect-${name}-${process.pid}-${Date.now()}.json`);
}

// -- schema.json --------------------------------------------------------------

test("schema: the button entry validates", () => {
  const btn = byTag("m3e-button");
  assert.ok(btn, "m3e-button entry present");
  const { valid, errors } = validate(schema, [btn]);
  assert.deepEqual(errors, []);
  assert.equal(valid, true);
});

test("schema: the whole proposed correspondence array validates", () => {
  const { valid, errors } = validate(schema, proposed);
  assert.deepEqual(errors, []);
  assert.equal(valid, true);
});

test("schema: the iconTable entry (m3e-icon) validates and carries a 141-icon table, not 141 entries", () => {
  const icon = byTag("m3e-icon");
  assert.ok(icon);
  assert.equal(icon.kind, "iconTable");
  assert.equal(icon.icons.length, 141);
  assert.equal(proposed.filter((e) => e.cemTag === "m3e-icon").length, 1);
  const { valid } = validate(schema, [icon]);
  assert.equal(valid, true);
});

test("schema: a code-only entry (m3e-tab) validates — figma-side-less CEM tags are not lost", () => {
  const tab = byTag("m3e-tab");
  assert.ok(tab, "m3e-tab (lost the tab/tabs slug collision) still surfaces as its own entry");
  assert.equal(tab.matcherKind, "code-only");
  assert.deepEqual(tab.figmaSets, []);
  assert.equal(tab.provenance, "auto-gap");
  const { valid, errors } = validate(schema, [tab]);
  assert.deepEqual(errors, []);
  assert.equal(valid, true);
});

test("schema: a standalone entry (m3e-rich-tooltip) validates", () => {
  const tooltip = byTag("m3e-rich-tooltip");
  assert.ok(tooltip);
  assert.equal(tooltip.matcherKind, "standalone");
  assert.equal(tooltip.figmaSets.length, 1);
  const { valid, errors } = validate(schema, [tooltip]);
  assert.deepEqual(errors, []);
  assert.equal(valid, true);
});

test("schema: rejects an entry missing a required field", () => {
  const { valid, errors } = validate(schema, [{ provenance: "human", status: "proposed" }]);
  assert.equal(valid, false);
  assert.ok(errors.some((e) => e.includes('missing required property "cemTag"')));
});

test("schema: a correspondence entry with a well-formed slots array (mapped) validates", () => {
  const entry = {
    cemTag: "m3e-test-slot",
    provenance: "auto-exact",
    status: "proposed",
    figmaSets: [],
    axes: [],
    props: [],
    slots: [
      {
        figmaSlotName: "trailing",
        kind: "slot",
        multi: false,
        mappedTo: "trailing-slot"
      }
    ]
  };
  const { valid, errors } = validate(schema, [entry]);
  assert.deepEqual(errors, []);
  assert.equal(valid, true);
});

test("schema: a correspondence entry with a well-formed slots array (unmapped) validates", () => {
  const entry = {
    cemTag: "m3e-test-slot",
    provenance: "auto-exact",
    status: "proposed",
    figmaSets: [],
    axes: [],
    props: [],
    slots: [
      {
        figmaSlotName: "trailing",
        kind: "slot",
        multi: false,
        unmapped: "no CEM counterpart for this slot"
      }
    ]
  };
  const { valid, errors } = validate(schema, [entry]);
  assert.deepEqual(errors, []);
  assert.equal(valid, true);
});

test("schema: rejects a slots entry with an invalid kind", () => {
  const entry = {
    cemTag: "m3e-test-slot",
    provenance: "auto-exact",
    status: "proposed",
    figmaSets: [],
    axes: [],
    props: [],
    slots: [
      {
        figmaSlotName: "trailing",
        kind: "bogus",
        multi: false,
        mappedTo: "trailing-slot"
      }
    ]
  };
  const { valid, errors } = validate(schema, [entry]);
  assert.equal(valid, false);
  assert.ok(errors.some((e) => e.includes("enum") || e.includes("bogus")));
});

test("schema: rejects a slots entry missing a required field (multi)", () => {
  const entry = {
    cemTag: "m3e-test-slot",
    provenance: "auto-exact",
    status: "proposed",
    figmaSets: [],
    axes: [],
    props: [],
    slots: [
      {
        figmaSlotName: "trailing",
        kind: "slot",
        mappedTo: "trailing-slot"
      }
    ]
  };
  const { valid, errors } = validate(schema, [entry]);
  assert.equal(valid, false);
  assert.ok(errors.some((e) => e.includes('missing required property "multi"')));
});

test("schema: rejects a slots entry missing a required field (figmaSlotName)", () => {
  const entry = {
    cemTag: "m3e-test-slot",
    provenance: "auto-exact",
    status: "proposed",
    figmaSets: [],
    axes: [],
    props: [],
    slots: [
      {
        kind: "slot",
        multi: false,
        mappedTo: "trailing-slot"
      }
    ]
  };
  const { valid, errors } = validate(schema, [entry]);
  assert.equal(valid, false);
  assert.ok(errors.some((e) => e.includes('missing required property "figmaSlotName"')));
});

test("schema: rejects a slots entry with additionalProperties", () => {
  const entry = {
    cemTag: "m3e-test-slot",
    provenance: "auto-exact",
    status: "proposed",
    figmaSets: [],
    axes: [],
    props: [],
    slots: [
      {
        figmaSlotName: "trailing",
        kind: "slot",
        multi: false,
        mappedTo: "trailing-slot",
        extraField: "should not be here"
      }
    ]
  };
  const { valid, errors } = validate(schema, [entry]);
  assert.equal(valid, false);
  assert.ok(errors.some((e) => e.includes("additional") || e.includes("extraField")));
});

// -- buildProposals: mapping fidelity ----------------------------------------

test("buildProposals: button figmaSets carry nodeId/setName/fixedAttrs, sourced from the fusion", () => {
  const btn = byTag("m3e-button");
  assert.equal(btn.figmaSets.length, 5);
  const bySetId = Object.fromEntries(btn.figmaSets.map((s) => [s.nodeId, s]));
  assert.equal(bySetId["58651:11237"].setName, "Button - tonal");
  assert.deepEqual(bySetId["58651:11237"].fixedAttrs, { variant: "tonal" });
  // The bare "Button" set carries the unclaimed-leftover value, "filled".
  assert.deepEqual(bySetId["57994:2227"].fixedAttrs, { variant: "filled" });
});

test("buildProposals: button axes carry figmaProp/attr/valueMap (mapped) and figmaProp/unmapped (State)", () => {
  const btn = byTag("m3e-button");
  const size = btn.axes.find((a) => a.figmaProp === "Size");
  assert.equal(size.attr, "size");
  assert.equal(size.valueMap.XSmall, "extra-small");
  assert.equal(size.valueMap.XLarge, "extra-large");

  const state = btn.axes.find((a) => a.figmaProp === "State");
  assert.equal(state.attr, undefined);
  assert.match(state.unmapped, /no CEM enum attribute shares its value set/);
});

test("buildProposals: button props map TEXT->content, BOOLEAN/INSTANCE_SWAP icon props ->slot:icon, unmapped props keep figmaProp+kind+unmapped", () => {
  const btn = byTag("m3e-button");
  const byProp = Object.fromEntries(btn.props.map((p) => [p.figmaProp, p]));
  assert.equal(byProp["Label text"].kind, "text");
  assert.equal(byProp["Label text"].binding, "content");
  assert.equal(byProp["Show icon"].kind, "boolean");
  assert.equal(byProp["Show icon"].binding, "slot:icon");
  assert.equal(byProp["Icon"].kind, "instanceSwap");
  assert.equal(byProp["Icon"].binding, "slot:icon");
  assert.equal(byProp["Show focus indicator"].binding, undefined);
  assert.match(byProp["Show focus indicator"].unmapped, /no CEM counterpart/);
});

test("buildProposals: provenance derives from matcher tier (auto-exact/auto-fuzzy/auto-gap)", () => {
  assert.equal(byTag("m3e-button").provenance, "auto-exact");
  const assist = proposed.find((e) => e.rationale.includes("Assistive chip") || e.cemTag === "m3e-assist-chip");
  assert.ok(assist);
  assert.equal(assist.provenance, "auto-fuzzy");
  assert.equal(byTag("m3e-tab").provenance, "auto-gap");
});

test("buildProposals: every entry starts status:'proposed' and is sorted by cemTag", () => {
  assert.ok(proposed.every((e) => e.status === "proposed"));
  const tags = proposed.map((e) => e.cemTag);
  assert.deepEqual(tags, [...tags].sort((a, b) => a.localeCompare(b)));
});

test("buildProposals: cemTag:null Figma-only gaps never leak into correspondence entries", () => {
  assert.ok(proposed.every((e) => e.cemTag !== null && e.cemTag !== undefined));
});

test("buildProposals: byte-stable across repeated runs on the same inputs", () => {
  const again = buildProposals(cem, figma, m3KitMatcherConfig);
  assert.equal(JSON.stringify(again), JSON.stringify(proposed));
});

test("buildProposals: the real m3-kit merge has zero same-cemTag collisions (27 distinct tags)", () => {
  const tags = proposed.map((e) => e.cemTag);
  assert.equal(new Set(tags).size, tags.length);
});

test("entriesFromCandidates: two candidates binding the SAME non-null cemTag throw loud instead of silently collapsing", () => {
  const stubFigma = { sets: [], standalones: [] };
  const candidateA = {
    cemTag: "m3e-synthetic-collision",
    kind: "standalone",
    figmaSetIds: ["1:1"],
    figmaName: "Synthetic A",
    page: "Test Page",
    rationale: ["synthetic candidate A for collision test"],
    score: 1,
  };
  const candidateB = {
    cemTag: "m3e-synthetic-collision",
    kind: "set",
    figmaSetIds: ["2:2"],
    figmaName: "Synthetic B",
    page: "Test Page",
    rationale: ["synthetic candidate B for collision test — a fuzzy hit landing on an already-bound tag"],
    score: 0.42,
  };

  assert.throws(
    () => entriesFromCandidates([candidateA, candidateB], stubFigma),
    (err) =>
      err instanceof Error &&
      err.message.includes("m3e-synthetic-collision") &&
      err.message.includes("Synthetic A") &&
      err.message.includes("Synthetic B")
  );

  // A single candidate for that tag (no collision) must NOT throw.
  assert.doesNotThrow(() => entriesFromCandidates([candidateA], stubFigma));
});

// -- mergeCorrespondence: human-preserving merge -----------------------------

test("merge: a fresh cemTag with no existing entry is added as-is", () => {
  const merged = mergeCorrespondence([], proposed);
  assert.equal(JSON.stringify(merged), JSON.stringify(proposed));
});

test("merge: an existing non-protected (auto, not-confirmed) entry is replaced outright by the fresh proposal", () => {
  const stale = { ...byTag("m3e-button"), rationale: "STALE — should be replaced" };
  const merged = mergeCorrespondence([stale], proposed);
  const btn = merged.find((e) => e.cemTag === "m3e-button");
  assert.notEqual(btn.rationale, "STALE — should be replaced");
  assert.equal(btn.rationale, byTag("m3e-button").rationale);
});

test("merge: provenance:'human' survives a re-merge UNCHANGED; new auto data lands as proposedUpdate, never overwrites", () => {
  const freshButton = byTag("m3e-button");
  // Simulate a human correction: flip provenance to "human" AND hand-edit an
  // axis mapping (so the fresh proposal provably differs from what's stored).
  const humanButton = {
    ...freshButton,
    provenance: "human",
    status: "proposed",
    axes: freshButton.axes.map((a) => (a.figmaProp === "Size" ? { ...a, attr: "size-HUMAN-OVERRIDE" } : a)),
  };

  const merged = mergeCorrespondence([humanButton], proposed);
  const btn = merged.find((e) => e.cemTag === "m3e-button");

  // The stored human entry itself is untouched.
  assert.equal(btn.provenance, "human");
  assert.equal(btn.axes.find((a) => a.figmaProp === "Size").attr, "size-HUMAN-OVERRIDE");

  // The fresh auto data lands alongside as proposedUpdate, not in place.
  assert.ok(btn.proposedUpdate, "proposedUpdate present since the fresh proposal differs");
  assert.equal(btn.proposedUpdate.axes.find((a) => a.figmaProp === "Size").attr, "size");
  assert.equal(btn.proposedUpdate.provenance, "auto-exact");
});

test("merge: status:'confirmed' also protects an entry even with auto provenance", () => {
  const confirmedButton = { ...byTag("m3e-button"), status: "confirmed" };
  const merged = mergeCorrespondence([confirmedButton], proposed);
  const btn = merged.find((e) => e.cemTag === "m3e-button");
  assert.equal(btn.status, "confirmed");
  assert.deepEqual(btn.figmaSets, confirmedButton.figmaSets);
});

test("merge: a protected entry with NO drift from the fresh proposal gets no proposedUpdate noise", () => {
  const humanButton = { ...byTag("m3e-button"), provenance: "human" };
  const merged = mergeCorrespondence([humanButton], proposed);
  const btn = merged.find((e) => e.cemTag === "m3e-button");
  assert.equal(btn.proposedUpdate, undefined);
});

test("merge: a cemTag the matcher no longer proposes is kept as-is, never silently deleted", () => {
  const vanished = { ...byTag("m3e-button"), cemTag: "m3e-totally-vanished", provenance: "human" };
  const merged = mergeCorrespondence([vanished], proposed);
  assert.ok(merged.some((e) => e.cemTag === "m3e-totally-vanished"));
});

test("merge: re-running the merge twice is byte-stable (deterministic)", () => {
  const existing = [{ ...byTag("m3e-button"), provenance: "human" }];
  const first = mergeCorrespondence(existing, proposed);
  const second = mergeCorrespondence(existing, proposed);
  assert.equal(JSON.stringify(first), JSON.stringify(second));
  // Sorted by cemTag.
  const tags = first.map((e) => e.cemTag);
  assert.deepEqual(tags, [...tags].sort((a, b) => a.localeCompare(b)));
});

// -- delta overlay (add | override | suppress) -------------------------------

test("delta: suppress removes a tag from the emit set WITHOUT deleting its entry", () => {
  const emit = computeEmitSet(proposed, [{ cemTag: "m3e-button", action: "suppress" }]);
  assert.ok(!emit.some((e) => e.cemTag === "m3e-button"), "suppressed from the emit set");
  // The source entries array is untouched — the entry itself is not deleted.
  assert.ok(proposed.some((e) => e.cemTag === "m3e-button"), "still present in the stored entries");
});

test("delta: override shallow-merges fields onto the base entry for emission only", () => {
  const emit = computeEmitSet(proposed, [
    { cemTag: "m3e-button", action: "override", entry: { status: "confirmed" } },
  ]);
  const btn = emit.find((e) => e.cemTag === "m3e-button");
  assert.equal(btn.status, "confirmed");
  // The base stored entry is untouched.
  assert.equal(byTag("m3e-button").status, "proposed");
});

test("delta: add appends a wholly new entry not present in the base entries", () => {
  const newEntry = {
    cemTag: "m3e-consumer-only",
    matcherKind: "standalone",
    figmaSets: [],
    axes: [],
    props: [],
    confidence: 1,
    provenance: "human",
    rationale: "consumer-authored, not from the matcher",
    status: "confirmed",
  };
  const emit = computeEmitSet(proposed, [{ cemTag: "m3e-consumer-only", action: "add", entry: newEntry }]);
  assert.ok(emit.some((e) => e.cemTag === "m3e-consumer-only"));
  assert.ok(!proposed.some((e) => e.cemTag === "m3e-consumer-only"));
});

test("delta: suppress wins over add for the same cemTag", () => {
  const newEntry = { cemTag: "m3e-consumer-only", provenance: "human", status: "confirmed" };
  const emit = computeEmitSet(proposed, [
    { cemTag: "m3e-consumer-only", action: "add", entry: newEntry },
    { cemTag: "m3e-consumer-only", action: "suppress" },
  ]);
  assert.ok(!emit.some((e) => e.cemTag === "m3e-consumer-only"));
});

// -- review.mjs: REVIEW.md rendering + confirm round-trip --------------------

test("review: renders exactly one row per entry (component+property decision), never per-variant", () => {
  const markdown = renderReviewMarkdown("m3-kit", proposed);
  const dataRows = markdown.split("\n").filter((l) => /^\|\s*\[/.test(l));
  assert.equal(dataRows.length, proposed.length);
});

test("review: every row's Accept column reflects status, and the tag is backtick-quoted for parsing", () => {
  const markdown = renderReviewMarkdown("m3-kit", proposed);
  assert.match(markdown, /\| \[ \] \| `m3e-button` \|/);
});

test("review + confirm: checking a row's box flips that entry's status/provenance; others are untouched", () => {
  const markdown = renderReviewMarkdown("m3-kit", proposed);
  const checked = markdown.replace("| [ ] | `m3e-button` |", "| [x] | `m3e-button` |");

  const accepted = parseAcceptedTags(checked);
  assert.ok(accepted.has("m3e-button"));
  assert.ok(!accepted.has("m3e-checkbox"));

  const updated = confirmFromReview(proposed, checked);
  const btn = updated.find((e) => e.cemTag === "m3e-button");
  assert.equal(btn.status, "confirmed");
  assert.equal(btn.provenance, "human");

  const checkbox = updated.find((e) => e.cemTag === "m3e-checkbox");
  assert.equal(checkbox.status, "proposed");
  assert.equal(checkbox.provenance, "auto-exact");
});

test("confirm: overrides.json-shaped decisions flip status/provenance for matching cemTags only", () => {
  const decisions = [
    { cemTag: "m3e-button", status: "rejected" },
    { cemTag: "m3e-does-not-exist", status: "confirmed" },
  ];
  const updated = confirmFromDecisions(proposed, decisions);
  const btn = updated.find((e) => e.cemTag === "m3e-button");
  assert.equal(btn.status, "rejected");
  // Fix round: a decision that sets `status` (even without an explicit
  // `provenance` field, as here) MUST also stamp provenance:"human" — this
  // is what makes merge.mjs's isProtected() cover rejections too (see the
  // re-match regression test below).
  assert.equal(btn.provenance, "human");
  assert.ok(!updated.some((e) => e.cemTag === "m3e-does-not-exist"), "unknown cemTags are not invented as new entries");
});

test("WB-fix round regression: a pure visual-gate approval ({gate:'approved', note}, no status) must NOT stamp provenance:'human' via confirmFromDecisions, and must NOT protect the entry from a later match", () => {
  // This is exactly the shape src/visual/review/server.mjs's approve() now
  // writes into overrides.json post-fix: a C6 gate decision that carries no
  // Plan A `status` at all — a human eyeballed a pixel diff in the visual
  // review webapp; they never ran the binding-confirm flow.
  const gateOnlyDecision = [{ cemTag: "m3e-button", gate: "approved", note: "known AA fringe" }];

  const confirmed = confirmFromDecisions(proposed, gateOnlyDecision);
  const btn = confirmed.find((e) => e.cemTag === "m3e-button");

  // The bug: confirmFromDecisions used to read `decision.provenance` off ANY
  // decision missing `status` and stamp it onto the entry. Post-fix, gate
  // decisions never carry `provenance` in the first place, so there is
  // nothing to stamp — the entry's own (auto) provenance survives untouched.
  assert.equal(btn.provenance, byTag("m3e-button").provenance, "gate-only decision must not touch provenance");
  assert.notEqual(btn.provenance, "human");
  assert.equal(btn.status, "proposed", "gate-only decision must not touch status either");

  // Prove it via merge.mjs's isProtected() (provenance==="human" ||
  // status==="confirmed"): a NOT-protected entry is replaced outright by a
  // fresh proposal, never preserved/never turned into a no-op proposedUpdate.
  // Hand-edit a substantive field on the "confirmed" (but not actually
  // protected) entry, then re-run match — if it were spuriously protected,
  // the hand-edit would survive as-is with the fresh data parked in
  // proposedUpdate; since it's NOT protected, the fresh proposal wins
  // outright and the stale hand-edit is gone.
  const staleConfirmed = confirmed.map((e) =>
    e.cemTag === "m3e-button" ? { ...e, rationale: "STALE — must be replaced, not protected" } : e
  );
  const merged = mergeCorrespondence(staleConfirmed, proposed);
  const mergedBtn = merged.find((e) => e.cemTag === "m3e-button");
  assert.equal(
    mergedBtn.rationale,
    byTag("m3e-button").rationale,
    "a gate-only approval must not protect the entry — a later match still updates it outright"
  );
  assert.equal(mergedBtn.proposedUpdate, undefined, "not protected, so no proposedUpdate parking either — outright replacement");
});

test("merge: a human rejection survives re-match — stays 'rejected'/'human', no proposedUpdate churn (Fix round regression test)", () => {
  // Simulate the exact bug report: overrides.json rejects m3e-button via a
  // decision that sets ONLY `status` (no `provenance`) — the same shape
  // confirmFromDecisions is exercised with above.
  const rejectedEntries = confirmFromDecisions(proposed, [{ cemTag: "m3e-button", status: "rejected" }]);
  const rejectedButton = rejectedEntries.find((e) => e.cemTag === "m3e-button");
  assert.equal(rejectedButton.status, "rejected");
  assert.equal(rejectedButton.provenance, "human");

  // A subsequent `match` re-run produces fresh auto-proposals (same
  // fixtures here, so substantively identical to what's already stored).
  const merged = mergeCorrespondence(rejectedEntries, proposed);
  const btn = merged.find((e) => e.cemTag === "m3e-button");

  assert.equal(btn.status, "rejected", "human rejection must NOT silently revert to 'proposed'");
  assert.equal(btn.provenance, "human", "provenance stamp must survive the re-match untouched");
  assert.equal(btn.proposedUpdate, undefined, "no substantive drift from the fresh proposal — no proposedUpdate noise");
});

// -- end-to-end CLI machinery, redirected to a temp path ---------------------
//
// Exercises the exact `match --profile m3-kit` wiring (real profile.json,
// real cem + figma-export) but with correspondencePath overridden to a temp
// file. Since A8, profiles/m3-kit/correspondence.json IS checked in (the
// generated + human-confirmed tracer artifact) — this test now asserts the
// complementary invariant: a temp-redirected runMatch call never disturbs
// that checked-in real file (no accidental double-write into the profile
// dir when a caller passes an explicit correspondencePath).

test("CLI machinery: runMatch against the real m3-kit profile writes ONLY to the redirected temp path", () => {
  const profileDir = path.join(repoRoot, "profiles", "m3-kit");
  const realCorrespondencePath = path.join(profileDir, "correspondence.json");
  const tmp = tmpPath("correspondence");

  assert.ok(fs.existsSync(realCorrespondencePath), "profiles/m3-kit/correspondence.json is the A8 tracer artifact and must be checked in");
  const realBefore = fs.readFileSync(realCorrespondencePath, "utf8");

  const entries = runMatch({ profileDir, correspondencePath: tmp, loadCem, loadFigmaExport });
  assert.ok(entries.length > 0);
  assert.ok(fs.existsSync(tmp));

  assert.equal(
    fs.readFileSync(realCorrespondencePath, "utf8"),
    realBefore,
    "runMatch with an explicit correspondencePath must not have touched the real checked-in file"
  );

  const reloaded = readCorrespondence(tmp);
  assert.equal(JSON.stringify(reloaded), JSON.stringify(entries));

  fs.rmSync(tmp);
});

// A8 tracer acceptance: the real, checked-in profiles/m3-kit/correspondence.json
// has EXACTLY the 11 gate-banked entries confirmed (status:"confirmed"/provenance:"human"),
// every other entry stays "proposed", and re-running match against the real
// profile is byte-identical to what's on disk (the human confirmation is
// preserved, not reverted, and no proposedUpdate churn is introduced).
//
// Confirmed set (banked 2026-07-14): m3e-badge, m3e-button, m3e-icon-button, m3e-switch.
// Confirmed set (banked 2026-07-14): m3e-assist-chip, m3e-filter-chip, m3e-input-chip, m3e-suggestion-chip (#5-#8).
// Confirmed set (banked 2026-07-14): m3e-checkbox (#9).
// Confirmed set (banked 2026-07-14): m3e-search-bar (#10, RC5 — literalIcon+text→slot:input shapes).
// Confirmed set (banked 2026-07-14): m3e-list-item (#11, text-tier 0.0777 < 0.10 — minimal bare file, all axes unmapped).
// Confirmed set (banked 2026-07-14): m3e-shape (#12, Elm emitter digit-name canon fix).
// Confirmed set (banked 2026-07-18): m3e-fab (#13, benignAa tier 0.0985 < 0.10 — curved-shape + icon-glyph AA, offline capture).
// Confirmed set (banked 2026-07-18): m3e-avatar (#14, monogram-variant pin — Style fixedAttrs; gate 0.0000, contains-tier).
// Confirmed set (banked 2026-07-18): m3e-segmented-button (#15, representative example — 3 m3e-button-segment children, validateExamples verified).
// Confirmed set (banked 2026-07-18): m3e-split-button (#16, representative example — leading m3e-button + trailing m3e-icon-button chevron, validateExamples + render eyeball verified).
// Confirmed set (banked 2026-07-18): m3e-button-group (#17, representative example — 2 outlined m3e-button children, validateExamples + render eyeball verified).
// Confirmed set (banked 2026-07-18): m3e-card (#18, representative example — header/content spans + text action button, validateExamples + render eyeball verified).
// Confirmed set (banked 2026-07-18): m3e-menu-item (#19, representative example — settings icon + label, render eyeball verified).
// Confirmed set (banked 2026-07-18): m3e-nav-item (#20, representative example — home icon + label, render eyeball verified).
// Confirmed set (banked 2026-07-18): m3e-app-bar (#21, representative example — leading menu icon-button + title + trailing overflow, render eyeball verified).
// Confirmed set (banked 2026-07-19): m3e-dialog (#22, representative example — header span + content span + Cancel/Reset action buttons, render-verified in open state).
// Confirmed set (banked 2026-07-19): m3e-list (#23, representative example — 3 m3e-list-item children, render eyeball verified).
// Confirmed set (banked 2026-07-19): m3e-tabs (#24, representative example — 3 m3e-tab children, first selected, render eyeball verified).
// Confirmed set (banked 2026-07-19): m3e-toolbar (#25, representative example — 3 icon-buttons bold/italic/underline, render eyeball verified).
// Confirmed set (banked 2026-07-19): m3e-menu (#26, representative example — 3 m3e-menu-item children with cut/copy/paste icons, render eyeball verified via force-open).
// Confirmed set (banked 2026-07-19): m3e-tooltip (#27, standard emit — preserves Supporting-text->content binding; render eyeball verified via force-open).
// Confirmed set (banked 2026-07-19): m3e-rich-tooltip (#28, representative example — subhead + body + Action button, render eyeball verified via force-open).
// Confirmed set (banked 2026-07-19): m3e-circular-progress-indicator (#29, per-set example attrs — value=70 determinate arc + indeterminate=true binding; web-components only).
// Confirmed set (banked 2026-07-19): m3e-linear-progress-indicator (#30, per-set example attrs — mode=determinate value=70 bar + mode=indeterminate binding; web-components only).
// Confirmed set (banked 2026-07-19): m3e-icon (#31, iconTable — 141 per-icon Code Connect bindings; web-components only, not in elm-facts).
// Confirmed set (banked 2026-07-19): m3e-tab (#32, manual-correspondence to Primary tabs/Icon and label; representative example — favorite icon + label).
// Reverted (FALSE PASSES — 2026-07-14): m3e-snackbar.
const CONFIRMED_TAGS = ["m3e-app-bar", "m3e-assist-chip", "m3e-avatar", "m3e-badge", "m3e-bottom-sheet", "m3e-button", "m3e-button-group", "m3e-button-segment", "m3e-card", "m3e-checkbox", "m3e-chip-set", "m3e-circular-progress-indicator", "m3e-date-input", "m3e-datepicker", "m3e-dialog", "m3e-drawer-container", "m3e-expandable-list-item", "m3e-fab", "m3e-fab-menu", "m3e-fab-menu-item", "m3e-filter-chip", "m3e-form-field", "m3e-icon", "m3e-icon-button", "m3e-input-chip", "m3e-linear-progress-indicator", "m3e-list", "m3e-list-item", "m3e-loading-indicator", "m3e-menu", "m3e-menu-item", "m3e-nav-bar", "m3e-nav-item", "m3e-nav-menu", "m3e-nav-rail", "m3e-radio", "m3e-rich-tooltip", "m3e-search-bar", "m3e-search-view", "m3e-segmented-button", "m3e-shape", "m3e-slider", "m3e-snackbar", "m3e-split-button", "m3e-suggestion-chip", "m3e-switch", "m3e-tab", "m3e-tabs", "m3e-timepicker", "m3e-timepicker-input-period-toggle", "m3e-toolbar", "m3e-tooltip"];

test("A8 tracer acceptance: real m3-kit correspondence.json has exactly the banked confirmed set, and re-matching is byte-stable", () => {
  const profileDir = path.join(repoRoot, "profiles", "m3-kit");
  const realCorrespondencePath = path.join(profileDir, "correspondence.json");

  const onDisk = readCorrespondence(realCorrespondencePath);

  const confirmed = onDisk.filter((e) => e.status === "confirmed");
  assert.equal(confirmed.length, 52, `exactly 52 entries should be confirmed`);
  assert.equal(confirmed.length, CONFIRMED_TAGS.length, `exactly ${CONFIRMED_TAGS.length} entries should be confirmed`);
  assert.deepEqual(
    confirmed.map((e) => e.cemTag).sort(),
    [...CONFIRMED_TAGS].sort(),
    "confirmed set must be exactly the 52 confirmed tags"
  );
  assert.ok(confirmed.every((e) => e.provenance === "human"), "all confirmed entries must have provenance:human");

  // Per-entry assertions for m3e-button (original tracer — must be unchanged)
  const button = onDisk.find((e) => e.cemTag === "m3e-button");
  assert.equal(button.figmaSets.length, 9, "button: 5 primary fused sets + 4 appended toggle 2nd-sets");
  const axisAttrs = button.axes.map((a) => a.attr ?? null);
  assert.deepEqual(axisAttrs.filter(Boolean).sort(), ["shape", "size"]);
  const stateAxis = button.axes.find((a) => a.figmaProp === "State");
  assert.ok(stateAxis && stateAxis.unmapped, "State axis must be present and unmapped");
  assert.equal(button.props.length, 4, "button has 4 non-variant Figma props (3 bound + 1 null-binding)");
  const unboundProp = button.props.find((p) => p.unmapped);
  assert.equal(unboundProp.figmaProp, "Show focus indicator");
  assert.equal(button.proposedUpdate, undefined, "no proposedUpdate noise on the confirmed entry");

  // Per-entry assertions for the newly-banked tags
  const badge = onDisk.find((e) => e.cemTag === "m3e-badge");
  assert.equal(badge.status, "confirmed");
  assert.equal(badge.provenance, "human");

  const iconButton = onDisk.find((e) => e.cemTag === "m3e-icon-button");
  assert.equal(iconButton.status, "confirmed");
  assert.equal(iconButton.provenance, "human");

  const sw = onDisk.find((e) => e.cemTag === "m3e-switch");
  assert.equal(sw.status, "confirmed");
  assert.equal(sw.provenance, "human");

  // Per-entry assertions for chip tier (#7-#10, banked 2026-07-14)
  const filterChip = onDisk.find((e) => e.cemTag === "m3e-filter-chip");
  assert.equal(filterChip.status, "confirmed");
  assert.equal(filterChip.provenance, "human");

  const inputChip = onDisk.find((e) => e.cemTag === "m3e-input-chip");
  assert.equal(inputChip.status, "confirmed");
  assert.equal(inputChip.provenance, "human");

  const suggestionChip = onDisk.find((e) => e.cemTag === "m3e-suggestion-chip");
  assert.equal(suggestionChip.status, "confirmed");
  assert.equal(suggestionChip.provenance, "human");

  const assistChip = onDisk.find((e) => e.cemTag === "m3e-assist-chip");
  assert.equal(assistChip.status, "confirmed");
  assert.equal(assistChip.provenance, "human");

  const checkbox = onDisk.find((e) => e.cemTag === "m3e-checkbox");
  assert.equal(checkbox.status, "confirmed");
  assert.equal(checkbox.provenance, "human");

  const listItem = onDisk.find((e) => e.cemTag === "m3e-list-item");
  assert.equal(listItem.status, "confirmed");
  assert.equal(listItem.provenance, "human");

  const shape = onDisk.find((e) => e.cemTag === "m3e-shape");
  assert.equal(shape.status, "confirmed");
  assert.equal(shape.provenance, "human");

  const fab = onDisk.find((e) => e.cemTag === "m3e-fab");
  assert.equal(fab.status, "confirmed");
  assert.equal(fab.provenance, "human");

  // Per-entry assertions for m3e-avatar (#14, banked 2026-07-18 — Style fixedAttrs pin)
  const avatar = onDisk.find((e) => e.cemTag === "m3e-avatar");
  assert.equal(avatar.status, "confirmed");
  assert.equal(avatar.provenance, "human");
  assert.deepEqual(avatar.figmaSets[0].fixedAttrs, { Style: "Monogram" }, "avatar's figmaSets[0].fixedAttrs must pin Style to Monogram");

  // Per-entry assertions for m3e-segmented-button (#15, banked 2026-07-18 — representative example)
  const segmentedButton = onDisk.find((e) => e.cemTag === "m3e-segmented-button");
  assert.equal(segmentedButton.status, "confirmed");
  assert.equal(segmentedButton.provenance, "human");

  // Per-entry assertions for m3e-split-button (#16, banked 2026-07-18 — representative example)
  const splitButton = onDisk.find((e) => e.cemTag === "m3e-split-button");
  assert.equal(splitButton.status, "confirmed");
  assert.equal(splitButton.provenance, "human");

  // Per-entry assertions for m3e-button-group (#17, banked 2026-07-18 — representative example)
  const buttonGroup = onDisk.find((e) => e.cemTag === "m3e-button-group");
  assert.equal(buttonGroup.status, "confirmed");
  assert.equal(buttonGroup.provenance, "human");

  // Per-entry assertions for m3e-card (#18, banked 2026-07-18 — representative example)
  const card = onDisk.find((e) => e.cemTag === "m3e-card");
  assert.equal(card.status, "confirmed");
  assert.equal(card.provenance, "human");

  // Per-entry assertions for m3e-menu-item (#19, banked 2026-07-18 — representative example)
  const menuItem = onDisk.find((e) => e.cemTag === "m3e-menu-item");
  assert.equal(menuItem.status, "confirmed");
  assert.equal(menuItem.provenance, "human");

  // Per-entry assertions for m3e-nav-item (#20, banked 2026-07-18 — representative example)
  const navItem = onDisk.find((e) => e.cemTag === "m3e-nav-item");
  assert.equal(navItem.status, "confirmed");
  assert.equal(navItem.provenance, "human");

  // Per-entry assertions for m3e-app-bar (#21, banked 2026-07-18 — representative example)
  const appBar = onDisk.find((e) => e.cemTag === "m3e-app-bar");
  assert.equal(appBar.status, "confirmed");
  assert.equal(appBar.provenance, "human");

  // Per-entry assertions for m3e-dialog (#22, banked 2026-07-19 — representative example)
  const dialog = onDisk.find((e) => e.cemTag === "m3e-dialog");
  assert.equal(dialog.status, "confirmed");
  assert.equal(dialog.provenance, "human");

  // Per-entry assertions for m3e-list (#23, banked 2026-07-19 — representative example)
  const list = onDisk.find((e) => e.cemTag === "m3e-list");
  assert.equal(list.status, "confirmed");
  assert.equal(list.provenance, "human");

  // Per-entry assertions for m3e-tabs (#24, banked 2026-07-19 — representative example)
  const tabs = onDisk.find((e) => e.cemTag === "m3e-tabs");
  assert.equal(tabs.status, "confirmed");
  assert.equal(tabs.provenance, "human");

  // Per-entry assertions for m3e-toolbar (#25, banked 2026-07-19 — representative example)
  const toolbar = onDisk.find((e) => e.cemTag === "m3e-toolbar");
  assert.equal(toolbar.status, "confirmed");
  assert.equal(toolbar.provenance, "human");

  // Per-entry assertions for m3e-menu (#26, banked 2026-07-19 — representative example)
  const menu = onDisk.find((e) => e.cemTag === "m3e-menu");
  assert.equal(menu.status, "confirmed");
  assert.equal(menu.provenance, "human");

  // Per-entry assertions for m3e-tooltip (#27, banked 2026-07-19 — standard emit)
  const tooltip = onDisk.find((e) => e.cemTag === "m3e-tooltip");
  assert.equal(tooltip.status, "confirmed");
  assert.equal(tooltip.provenance, "human");

  // Per-entry assertions for m3e-rich-tooltip (#28, banked 2026-07-19 — representative example)
  const richTooltip = onDisk.find((e) => e.cemTag === "m3e-rich-tooltip");
  assert.equal(richTooltip.status, "confirmed");
  assert.equal(richTooltip.provenance, "human");

  // Per-entry assertions for m3e-circular-progress-indicator (#29, banked 2026-07-19 — per-set example attrs, web-components only)
  const circularProgress = onDisk.find((e) => e.cemTag === "m3e-circular-progress-indicator");
  assert.equal(circularProgress.status, "confirmed");
  assert.equal(circularProgress.provenance, "human");

  // Per-entry assertions for m3e-linear-progress-indicator (#30, banked 2026-07-19 — per-set example attrs, web-components only)
  const linearProgress = onDisk.find((e) => e.cemTag === "m3e-linear-progress-indicator");
  assert.equal(linearProgress.status, "confirmed");
  assert.equal(linearProgress.provenance, "human");

  // Per-entry assertions for m3e-icon (#31, banked 2026-07-19 — iconTable, 141 per-icon bindings, web-components only)
  const icon = onDisk.find((e) => e.cemTag === "m3e-icon");
  assert.equal(icon.status, "confirmed");
  assert.equal(icon.provenance, "human");
  assert.equal(icon.kind, "iconTable", "m3e-icon entry must be kind:iconTable");
  assert.equal(icon.icons.length, 141, "m3e-icon iconTable must have 141 rows");

  // Per-entry assertions for m3e-tab (#32, banked 2026-07-19 — manual-correspondence to Primary tabs/Icon and label)
  const tab = onDisk.find((e) => e.cemTag === "m3e-tab");
  assert.equal(tab.status, "confirmed");
  assert.equal(tab.provenance, "human");
  assert.equal(tab.matcherKind, "manual", "m3e-tab entry must have matcherKind:'manual'");
  assert.equal(tab.figmaSets.length, 5, "m3e-tab: 3 primary (icon-and-label, icon-only, label-only) + 2 secondary (icon-label, label-only)");
  assert.equal(tab.figmaSets[0].nodeId, "54563:40142", "m3e-tab figmaSet nodeId must be 54563:40142");
  assert.equal(tab.figmaSets[0].setName, "Primary tabs/Icon and label");

  const others = onDisk.filter((e) => !CONFIRMED_TAGS.includes(e.cemTag));
  assert.ok(others.every((e) => e.status === "proposed"), "every non-confirmed entry must remain proposed");

  // Byte-stability / provenance-respecting: re-running match against a COPY
  // of the real on-disk file (never overwriting the checked-in artifact
  // itself here — that's covered manually/by the CLI, this proves the pure
  // mechanism) must reproduce it byte-for-byte.
  const tmp = tmpPath("a8-rerun-correspondence");
  fs.copyFileSync(realCorrespondencePath, tmp);
  const rerun = runMatch({ profileDir, correspondencePath: tmp, loadCem, loadFigmaExport });
  assert.equal(
    JSON.stringify(rerun),
    JSON.stringify(onDisk),
    "re-running match must reproduce the checked-in correspondence.json byte-for-byte (JSON-value-identical)"
  );

  fs.rmSync(tmp);
});

test("CLI machinery: runReview + runConfirm round-trip, redirected to temp paths", () => {
  const profileDir = path.join(repoRoot, "profiles", "m3-kit");
  const corrTmp = tmpPath("correspondence-rc");
  const reviewTmp = tmpPath("review").replace(/\.json$/, ".md");

  writeCorrespondence(corrTmp, proposed);

  const markdown = runReview({ profileDir, correspondencePath: corrTmp, reviewPath: reviewTmp });
  assert.match(markdown, /# Review — m3-kit/);
  assert.ok(fs.existsSync(reviewTmp));

  const checkedMarkdown = fs
    .readFileSync(reviewTmp, "utf8")
    .replace("| [ ] | `m3e-button` |", "| [x] | `m3e-button` |");
  fs.writeFileSync(reviewTmp, checkedMarkdown, "utf8");

  const confirmed = runConfirm({ profileDir, correspondencePath: corrTmp, from: reviewTmp });
  const btn = confirmed.find((e) => e.cemTag === "m3e-button");
  assert.equal(btn.status, "confirmed");
  assert.equal(btn.provenance, "human");

  // profiles/m3-kit/correspondence.json IS checked in since A8 (the tracer
  // artifact) but this test's own runReview/runConfirm calls above were all
  // redirected to corrTmp/reviewTmp — assert the real files are untouched
  // by this test, not that they don't exist.
  const realCorrespondencePath = path.join(profileDir, "correspondence.json");
  const realReviewPath = path.join(profileDir, "REVIEW.md");
  assert.ok(fs.existsSync(realCorrespondencePath), "the A8 tracer artifact should exist");
  assert.ok(!fs.existsSync(realReviewPath), "REVIEW.md was never generated for the real profile (confirm used overrides.json)");

  fs.rmSync(corrTmp);
  fs.rmSync(reviewTmp);
});

test("writeCorrespondence rejects invalid entries (schema-guarded I/O — pristine output)", () => {
  const bad = tmpPath("bad");
  assert.throws(() => writeCorrespondence(bad, [{ status: "proposed" }]), /Invalid correspondence entries/);
  assert.ok(!fs.existsSync(bad));
});

// -- T1: manual-correspondence mechanism --------------------------------------

// Synthetic fixtures for manual-correspondence unit tests.
const syntheticFigma = {
  data: {
    components: [
      { id: "54563:40142", name: "Primary tabs/Icon and label", type: "COMPONENT_SET", page: "Tabs" },
      { id: "99:1", name: "Button", type: "COMPONENT_SET", page: "Buttons" },
    ],
  },
  sets: [
    { id: "54563:40142", name: "Primary tabs/Icon and label" },
    { id: "99:1", name: "Button" },
  ],
  standalones: [],
};

const syntheticCem = { tags: new Set(["m3e-tab", "m3e-tabs", "m3e-button"]) };

test("manual-correspondence: merge onto a code-only entry replaces it with manual figmaSets + provenance:'manual' + status:'proposed'", () => {
  const codeOnlyEntry = {
    cemTag: "m3e-tab",
    matcherKind: "code-only",
    figmaSets: [],
    axes: [],
    props: [],
    confidence: 0,
    provenance: "auto-gap",
    rationale: "code-only: lost slug collision",
    status: "proposed",
  };

  const manual = {
    "m3e-tab": {
      figmaSets: [{ nodeId: "54563:40142", setName: "Primary tabs/Icon and label", fixedAttrs: {} }],
      note: "Manual: representative binding. 2026-07-19.",
    },
  };

  const entries = [codeOnlyEntry];
  const result = applyManualCorrespondence(entries, manual);

  const tab = result.find((e) => e.cemTag === "m3e-tab");
  assert.ok(tab, "m3e-tab entry present after manual merge");
  assert.equal(tab.matcherKind, "manual");
  assert.equal(tab.provenance, "manual");
  assert.equal(tab.status, "proposed");
  assert.equal(tab.confidence, 0.9);
  assert.deepEqual(tab.figmaSets, [{ nodeId: "54563:40142", setName: "Primary tabs/Icon and label", fixedAttrs: {} }]);
  assert.deepEqual(tab.axes, []);
  assert.deepEqual(tab.props, []);
  assert.match(tab.rationale, /manual-correspondence/);
});

test("manual-correspondence (path-1): explicit axes/props pass through instead of forcing [] — enables variant-driven bindings for matcher-unreachable tags", () => {
  const codeOnlyEntry = {
    cemTag: "m3e-timepicker",
    matcherKind: "code-only",
    figmaSets: [],
    axes: [],
    props: [],
    confidence: 0,
    provenance: "auto-gap",
    rationale: "code-only",
    status: "proposed",
  };
  const manual = {
    "m3e-timepicker": {
      figmaSets: [{ nodeId: "52949:27916", setName: "Dial picker", fixedAttrs: { mode: "dial" } }],
      axes: [{ figmaProp: "Format", attr: "format", valueMap: { "12 hour": "12", "24 hour": "24" } }],
      props: [{ figmaProp: "Foo", kind: "boolean", binding: "bar" }],
      note: "path-1 axis test",
    },
  };
  const result = applyManualCorrespondence([codeOnlyEntry], manual);
  const tp = result.find((e) => e.cemTag === "m3e-timepicker");
  assert.deepEqual(tp.axes, [{ figmaProp: "Format", attr: "format", valueMap: { "12 hour": "12", "24 hour": "24" } }], "explicit manual axes pass through");
  assert.deepEqual(tp.props, [{ figmaProp: "Foo", kind: "boolean", binding: "bar" }], "explicit manual props pass through");
  // Absent axes/props still default to [] (representative-only), unchanged.
  const rep = applyManualCorrespondence(
    [{ ...codeOnlyEntry, cemTag: "m3e-radio" }],
    { "m3e-radio": { figmaSets: [{ nodeId: "51739:4608", setName: "Radio buttons", fixedAttrs: {} }] } }
  );
  assert.deepEqual(rep.find((e) => e.cemTag === "m3e-radio").axes, [], "no explicit axes -> [] (representative-only)");
});

test("manual-correspondence: sort position is preserved after merge (find-and-replace in place)", () => {
  const entries = [
    { cemTag: "m3e-button", matcherKind: "set", figmaSets: [{ nodeId: "99:1", setName: "Button", fixedAttrs: {} }], axes: [], props: [], confidence: 1, provenance: "auto-exact", rationale: "exact", status: "proposed" },
    { cemTag: "m3e-tab", matcherKind: "code-only", figmaSets: [], axes: [], props: [], confidence: 0, provenance: "auto-gap", rationale: "code-only", status: "proposed" },
    { cemTag: "m3e-tabs", matcherKind: "set", figmaSets: [], axes: [], props: [], confidence: 1, provenance: "auto-exact", rationale: "exact", status: "proposed" },
  ];

  const manual = {
    "m3e-tab": {
      figmaSets: [{ nodeId: "54563:40142", setName: "Primary tabs/Icon and label", fixedAttrs: {} }],
      note: "Manual: 2026-07-19.",
    },
  };

  const result = applyManualCorrespondence(entries, manual);
  const tags = result.map((e) => e.cemTag);
  // m3e-tab should remain at position 1 (between button and tabs)
  assert.equal(tags[0], "m3e-button");
  assert.equal(tags[1], "m3e-tab");
  assert.equal(tags[2], "m3e-tabs");
});

test("manual-correspondence: merge onto an already-confirmed/bound cemTag THROWS", () => {
  const confirmedEntry = {
    cemTag: "m3e-button",
    matcherKind: "set",
    figmaSets: [{ nodeId: "99:1", setName: "Button", fixedAttrs: {} }],
    axes: [],
    props: [],
    confidence: 1,
    provenance: "human",
    rationale: "exact tier",
    status: "confirmed",
  };

  const manual = {
    "m3e-button": {
      figmaSets: [{ nodeId: "99:1", setName: "Button", fixedAttrs: {} }],
      note: "Manual: should not override.",
    },
  };

  assert.throws(
    () => applyManualCorrespondence([confirmedEntry], manual),
    (err) => err instanceof Error && err.message.includes("manual-correspondence") && err.message.includes("m3e-button") && err.message.includes("already matched")
  );
});

test("manual-correspondence: merge onto a 'proposed' entry with real figmaSets (matcher-bound) THROWS", () => {
  // Proposed but matcher-bound (not code-only / auto-gap) — must also throw
  const matcherBound = {
    cemTag: "m3e-tabs",
    matcherKind: "set",
    figmaSets: [{ nodeId: "99:1", setName: "Tabs", fixedAttrs: {} }],
    axes: [],
    props: [],
    confidence: 1,
    provenance: "auto-exact",
    rationale: "exact tier",
    status: "proposed",
  };

  const manual = {
    "m3e-tabs": {
      figmaSets: [{ nodeId: "99:1", setName: "Tabs", fixedAttrs: {} }],
      note: "Attempting manual override of real match — must throw.",
    },
  };

  assert.throws(
    () => applyManualCorrespondence([matcherBound], manual),
    (err) => err instanceof Error && err.message.includes("manual-correspondence") && err.message.includes("m3e-tabs") && err.message.includes("already matched")
  );
});

test("manual-correspondence: validateManualCorrespondence — a nodeId of a non-bindable type (e.g. FRAME) fails", () => {
  const nonBindableFigma = {
    data: {
      components: [
        { id: "99:2", name: "A Frame", type: "FRAME", page: "Page" },
      ],
    },
  };

  const manual = {
    "m3e-tab": {
      figmaSets: [{ nodeId: "99:2", setName: "A Frame", fixedAttrs: {} }],
      note: "Bad: nodeId is a FRAME, not a COMPONENT_SET or COMPONENT.",
    },
  };

  assert.throws(
    () => validateManualCorrespondence(manual, { cem: syntheticCem, figma: nonBindableFigma }),
    (err) => err instanceof Error && err.message.includes("99:2") && err.message.includes("COMPONENT_SET")
  );
});

test("manual-correspondence: validateManualCorrespondence — a COMPONENT (standalone) node is accepted (dividers etc. are standalones, not sets)", () => {
  const standaloneFigma = {
    data: {
      components: [
        { id: "88:1", name: "Horizontal/Full-width", type: "COMPONENT", page: "Dividers" },
      ],
    },
  };
  const manual = {
    "m3e-tab": {
      figmaSets: [{ nodeId: "88:1", setName: "Horizontal/Full-width", fixedAttrs: {} }],
      note: "Standalone COMPONENT (a divider) — must be accepted, not only COMPONENT_SETs.",
    },
  };
  assert.doesNotThrow(
    () => validateManualCorrespondence(manual, { cem: syntheticCem, figma: standaloneFigma })
  );
});

test("manual-correspondence: validateManualCorrespondence — a nodeId that does not exist in figma export fails", () => {
  const manual = {
    "m3e-tab": {
      figmaSets: [{ nodeId: "00:0000", setName: "Nonexistent", fixedAttrs: {} }],
      note: "Bad: nodeId not in export.",
    },
  };

  assert.throws(
    () => validateManualCorrespondence(manual, { cem: syntheticCem, figma: syntheticFigma }),
    (err) => err instanceof Error && err.message.includes("00:0000")
  );
});

test("manual-correspondence: validateManualCorrespondence — setName mismatch throws", () => {
  const manual = {
    "m3e-tab": {
      figmaSets: [{ nodeId: "54563:40142", setName: "Wrong Name", fixedAttrs: {} }],
      note: "Bad: setName does not match the node's actual name.",
    },
  };

  assert.throws(
    () => validateManualCorrespondence(manual, { cem: syntheticCem, figma: syntheticFigma }),
    (err) => err instanceof Error && err.message.includes("setName") && err.message.includes("Wrong Name")
  );
});

test("manual-correspondence: validateManualCorrespondence — unknown cemTag throws", () => {
  const manual = {
    "m3e-nope": {
      figmaSets: [{ nodeId: "54563:40142", setName: "Primary tabs/Icon and label", fixedAttrs: {} }],
      note: "Bad: m3e-nope is not a real CEM tag.",
    },
  };

  assert.throws(
    () => validateManualCorrespondence(manual, { cem: syntheticCem, figma: syntheticFigma }),
    (err) => err instanceof Error && err.message.includes("m3e-nope") && err.message.includes("not a CEM tag")
  );
});

test("manual-correspondence: validateManualCorrespondence — valid config passes without throwing", () => {
  const manual = {
    "m3e-tab": {
      figmaSets: [{ nodeId: "54563:40142", setName: "Primary tabs/Icon and label", fixedAttrs: {} }],
      note: "Valid: real CEM tag + real COMPONENT_SET + correct setName.",
    },
  };

  assert.doesNotThrow(() =>
    validateManualCorrespondence(manual, { cem: syntheticCem, figma: syntheticFigma })
  );
});

test("manual-correspondence A8: m3e-tab on disk is matcherKind:manual, and all 51 confirmed entries are untouched", () => {
  const profileDir = path.join(repoRoot, "profiles", "m3-kit");
  const realCorrespondencePath = path.join(profileDir, "correspondence.json");

  const onDisk = readCorrespondence(realCorrespondencePath);

  // m3e-tab must be present on disk and carry the manual-correspondence data
  const tab = onDisk.find((e) => e.cemTag === "m3e-tab");
  assert.ok(tab, "m3e-tab entry must be present on disk");
  assert.equal(tab.matcherKind, "manual", "m3e-tab matcherKind must be 'manual'");
  assert.ok(tab.figmaSets.length > 0, "m3e-tab must have at least one figmaSet after manual merge");
  assert.equal(tab.figmaSets[0].nodeId, "54563:40142");
  assert.equal(tab.figmaSets[0].setName, "Primary tabs/Icon and label");

  // The confirmed entries must all be untouched (status:confirmed, provenance:human).
  // m3e-tab + the 4 later manual banks (radio/chip-set/nav-bar/nav-rail) keep
  // matcherKind:"manual" but become provenance:"human" on confirm.
  const confirmedOnDisk = onDisk.filter((e) => e.status === "confirmed");
  assert.equal(confirmedOnDisk.length, 52, "exactly 52 confirmed entries must be on disk");
  assert.ok(
    confirmedOnDisk.every((e) => e.provenance === "human"),
    "all confirmed entries must have provenance:human"
  );

  // Byte-stability: re-running match against a copy of the real on-disk file reproduces it byte-for-byte
  const tmp = tmpPath("manual-a8-rerun-correspondence");
  fs.copyFileSync(realCorrespondencePath, tmp);
  const rerun = runMatch({ profileDir, correspondencePath: tmp, loadCem, loadFigmaExport });
  assert.equal(
    JSON.stringify(rerun),
    JSON.stringify(onDisk),
    "re-running match must reproduce the checked-in correspondence.json byte-for-byte (JSON-value-identical)"
  );
  fs.rmSync(tmp);
});
