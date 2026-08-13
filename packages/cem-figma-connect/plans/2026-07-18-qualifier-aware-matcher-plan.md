# Qualifier-Aware Matcher Tier — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a "contains" matcher tier so descriptive-prefixed Figma sets (`Generic avatar`, `Stacked card`, `Connected button group`, `Circular-determinate progress indicator`, …) bind their bare CEM tags, resolving the qualifier to a fixed attribute where the CEM can distinguish it and gapping it otherwise.

**Architecture:** A new CEM-aware grouping module (`src/match/qualifier.mjs`) forms fusion-shaped groups by head-noun (token-subset, longest-CEM-wins), assigning each member set a `value` (its qualifier) so the EXISTING `proposeFusionValues` binds it — matched members via `valueMatch`, the one unresolved member via the leftover rule. `src/match/matcher.mjs` runs this after `detectFusionGroups`, consumes the grouped sets, and binds them at `tier:"contains"` (score 0.95, between exact 1.0 and fuzzy). Pure string helpers live in `src/match/normalize.mjs`.

**Tech Stack:** Node ESM, zero deps (project rule); `node --test`; `pnpm test` (scoped glob). Determinism/byte-stability via `src/lib/order.mjs` (`byString`/`byKey`).

**Spec:** `plans/2026-07-18-qualifier-aware-matcher-design.md`.

**Scope:** the matcher change ONLY. Banking each newly-matched component (gate → confirm → emit → tracer-test updates) is an explicit follow-on, NOT in this plan.

---

## File Structure

- **`src/match/normalize.mjs`** (modify) — add pure token helpers: `slugTokenSet`, `containsSubset`, `pickHeadComponent`, and the `BASE_MARKERS` set. These have one job: decide *which* CEM tag a set's slug contains and which tokens are the qualifier.
- **`src/match/qualifier.mjs`** (create) — `detectQualifierGroups(sets, cemComponents)`: the CEM-aware grouping + three-mode resolution, returning fusion-shaped `ContainsGroup[]`. Depends on normalize.mjs + `bestValueMatch` + `../lib/order.mjs`. No dependency on matcher.mjs (avoids a cycle).
- **`src/match/matcher.mjs`** (modify) — thread the CEM component list into `buildFigmaCandidates`, run `detectQualifierGroups` after `detectFusionGroups`, consume its set ids, and add a `kind:"contains"` branch to the `match()` loop that binds the pre-decided tag at `tier:"contains"` and reuses the fusion proposal assembly.
- **Tests:** `src/match/normalize.test.mjs` (extend), `src/match/qualifier.test.mjs` (create), `src/match/matcher.test.mjs` (extend), plus the existing `test/correspond.test.mjs` A8 tracer must stay green unchanged.

---

## Task 1: Token helpers in `normalize.mjs`

**Files:**
- Modify: `src/match/normalize.mjs` (append after `slugify`/`normalizeName`, before the value section)
- Test: `src/match/normalize.test.mjs`

- [ ] **Step 1: Write the failing tests** (append to `src/match/normalize.test.mjs`)

```js
import { slugTokenSet, containsSubset, pickHeadComponent, BASE_MARKERS } from "./normalize.mjs";

test("slugTokenSet splits a slug into a token Set", () => {
  assert.deepEqual([...slugTokenSet("connected-button-group")].sort(), ["button", "connected", "group"]);
  assert.deepEqual([...slugTokenSet("")], []);
});

test("containsSubset is true when every cem token is present (order-independent)", () => {
  assert.equal(containsSubset(["button", "group"], slugTokenSet("connected-button-group")), true);
  // infix qualifier: circular-progress-indicator ⊆ circular-determinate-progress-indicator
  assert.equal(containsSubset(["circular", "progress", "indicator"], slugTokenSet("circular-determinate-progress-indicator")), true);
  assert.equal(containsSubset(["card"], slugTokenSet("stacked-card")), true);
  assert.equal(containsSubset(["button", "segment"], slugTokenSet("stacked-card")), false);
  assert.equal(containsSubset([], slugTokenSet("stacked-card")), false); // empty cem never matches
});

test("pickHeadComponent returns the longest-slug CEM component whose tokens ⊆ the set, or null", () => {
  const cems = [
    { tag: "m3e-button", slug: "button" },
    { tag: "m3e-button-group", slug: "button-group" },
    { tag: "m3e-group", slug: "group" },
  ];
  const hit = pickHeadComponent("connected-button-group", cems);
  assert.equal(hit.component.tag, "m3e-button-group"); // 2 tokens beats the 1-token candidates
  assert.deepEqual([...hit.qualifier].sort(), ["connected"]);
  assert.equal(pickHeadComponent("totally-unrelated", cems), null);
});

test("pickHeadComponent breaks equal-length ties by ordinal tag order (deterministic)", () => {
  const cems = [{ tag: "m3e-b", slug: "b" }, { tag: "m3e-a", slug: "a" }];
  // "a-b" contains both single-token slugs; equal length -> smallest tag "m3e-a"
  const hit = pickHeadComponent("a-b", cems);
  assert.equal(hit.component.tag, "m3e-a");
});

test("BASE_MARKERS holds the canonical qualifier words", () => {
  for (const w of ["basic", "standard", "plain", "generic", "default"]) assert.ok(BASE_MARKERS.has(w));
});
```

- [ ] **Step 2: Run to verify they fail**

Run: `node --test src/match/normalize.test.mjs`
Expected: FAIL — `slugTokenSet is not a function` (and the others).

- [ ] **Step 3: Implement the helpers** (append to `src/match/normalize.mjs`, after `normalizeName`)

```js
// -- token-subset containment (qualifier tier) -------------------------------

// The slug's tokens as a Set. slug is already lowercase-kebab-singularized.
export function slugTokenSet(slug) {
  return new Set(String(slug ?? "").split("-").filter(Boolean));
}

// True when EVERY cem token is present in the set's token Set (order-
// independent subset). An empty cem token list never matches (would match
// everything). Handles infixed qualifiers (circular-DETERMINATE-progress-…).
export function containsSubset(cemTokens, setTokenSet) {
  if (!Array.isArray(cemTokens) || cemTokens.length === 0) return false;
  return cemTokens.every((t) => setTokenSet.has(t));
}

// Recognised "this is the unqualified/base variant" qualifier words. A set
// whose sole qualifier is one of these is the canonical member of its group
// (Basic dialog, Standard slider) — see the design's mode 3.
export const BASE_MARKERS = new Set(["basic", "standard", "plain", "generic", "default"]);

// pickHeadComponent(setSlug, cems) -> { component, qualifier: Set } | null
//   cems: [{ tag, slug }, ...] (slug = normalizeName(tag))
// Returns the MOST-SPECIFIC contain-match: the cem whose slug has the most
// tokens all present in the set slug. Ties (equal token count) break by
// ordinal tag order for determinism. `qualifier` = the set tokens NOT in the
// winning cem slug. Returns null when no cem contain-matches.
export function pickHeadComponent(setSlug, cems) {
  const setTokens = slugTokenSet(setSlug);
  let best = null; // { component, cemTokens }
  for (const c of cems) {
    const cemTokens = String(c.slug ?? "").split("-").filter(Boolean);
    if (!containsSubset(cemTokens, setTokens)) continue;
    if (
      best === null ||
      cemTokens.length > best.cemTokens.length ||
      (cemTokens.length === best.cemTokens.length && c.tag < best.component.tag)
    ) {
      best = { component: c, cemTokens };
    }
  }
  if (!best) return null;
  const winning = new Set(best.cemTokens);
  const qualifier = new Set([...setTokens].filter((t) => !winning.has(t)));
  return { component: best.component, qualifier };
}
```

- [ ] **Step 4: Run to verify they pass**

Run: `node --test src/match/normalize.test.mjs`
Expected: PASS (all, including the pre-existing normalize tests).

- [ ] **Step 5: Commit**

```bash
git add src/match/normalize.mjs src/match/normalize.test.mjs
git commit -m "feat(match): token-subset containment helpers (qualifier tier groundwork)"
```

---

## Task 2: `qualifier.mjs` — grouping + sole-set mode

**Files:**
- Create: `src/match/qualifier.mjs`
- Test: `src/match/qualifier.test.mjs`

Data shapes (match the existing fusion `FusionGroup`, so the matcher's fusion path consumes them unchanged):

```
ContainsGroup = {
  boundTag,        // the CEM tag this group binds (e.g. "m3e-card")
  base,            // display base (the head component's tag, for rationale)
  baseSlug,        // head component slug
  buildingBlock,   // null (contains sets are never building-block-prefixed here)
  page,            // first member's page
  setIds,          // [id, ...]
  members,         // [{ id, name, set, value }]  value = qualifier string | null
  variantAxes,     // merged from members (reuse fusion's mergedVariantAxes shape)
  nonVariantProps, // merged (reuse fusion's mergedNonVariantProps shape)
  mode,            // "sole" | "attr" | "canonical" (rationale only)
}
```

- [ ] **Step 1: Write the failing test** (create `src/match/qualifier.test.mjs`)

```js
import { test } from "node:test";
import assert from "node:assert/strict";
import { detectQualifierGroups } from "./qualifier.mjs";

// Minimal CEM component fixtures (only the fields the grouper reads).
const CEMS = [
  { tag: "m3e-avatar", slug: "avatar", attributes: [] },
  { tag: "m3e-card", slug: "card", attributes: [
    { name: "orientation", kind: "enum", values: ["vertical", "horizontal"] },
  ] },
];

// A fake Figma set: id, name, page, and no captured properties (properties
// optional, like the un-captured fusion siblings).
const set = (id, name, page = "Components") => ({ id, name, page, properties: null });

test("sole-set head-noun binds directly with value=null (Generic avatar -> m3e-avatar)", () => {
  const groups = detectQualifierGroups([set("1:1", "Generic avatar")], CEMS);
  assert.equal(groups.length, 1);
  const g = groups[0];
  assert.equal(g.boundTag, "m3e-avatar");
  assert.equal(g.mode, "sole");
  assert.deepEqual(g.setIds, ["1:1"]);
  assert.equal(g.members.length, 1);
  assert.equal(g.members[0].value, null); // no fixed attr for a sole set
});

test("a set that contain-matches nothing yields no group", () => {
  const groups = detectQualifierGroups([set("9:9", "Totally unrelated widget")], CEMS);
  assert.deepEqual(groups, []);
});

test("leading-dot internal sets are skipped", () => {
  const groups = detectQualifierGroups([set("2:2", ".Building Blocks/Generic avatar")], CEMS);
  // slugify strips the Building-Blocks prefix, but the leading dot marks it
  // internal -> excluded from the contains tier (parity with exact tier).
  assert.deepEqual(groups, []);
});

test("a set whose slug IS an exact CEM slug is left to the exact tier (no contains group)", () => {
  const cems = [{ tag: "m3e-filter-chip", slug: "filter-chip", attributes: [] }];
  const groups = detectQualifierGroups([set("8:8", "Filter chip")], cems);
  assert.deepEqual(groups, []); // slug "filter-chip" == an exact CEM slug -> belongs to exact tier
});
```

- [ ] **Step 2: Run to verify it fails**

Run: `node --test src/match/qualifier.test.mjs`
Expected: FAIL — `Cannot find module './qualifier.mjs'`.

- [ ] **Step 3: Implement grouping + sole-set** (create `src/match/qualifier.mjs`)

```js
// CEM-aware "contains" grouping (design: plans/2026-07-18-qualifier-aware-matcher-design.md).
// Groups not-exact-matched Figma sets under the most-specific CEM tag whose
// slug tokens are a subset of the set slug, then decides how the qualifier
// binds (sole / attr / canonical). Produces fusion-shaped groups so matcher.mjs
// reuses proposeFusionValues + the emitter's one-file-per-set path.
//
// Zero deps beyond the sibling normalize module + the ordinal comparator.

import { slugify, pickHeadComponent, BASE_MARKERS, bestValueMatch } from "./normalize.mjs";
import { byString } from "../lib/order.mjs";

// Merge helpers mirror fusion.mjs (kept local; the two modules stay independent).
function mergedVariantAxes(members) {
  const withProps = members.find((m) => m.set.properties);
  if (!withProps) return [];
  return withProps.set.properties
    .filter((p) => p.type === "VARIANT")
    .map((p) => ({ name: p.displayName, options: p.variantOptions ?? [], defaultValue: p.defaultValue }));
}
function mergedNonVariantProps(members) {
  const byName = new Map();
  for (const m of members) {
    if (!m.set.properties) continue;
    for (const p of m.set.properties) {
      if (p.type === "VARIANT") continue;
      if (!byName.has(p.displayName)) byName.set(p.displayName, { name: p.displayName, type: p.type, defaultValue: p.defaultValue });
    }
  }
  return [...byName.values()];
}

function makeGroup(boundTag, comp, members, mode) {
  return {
    boundTag,
    base: comp.tag,
    baseSlug: comp.slug,
    buildingBlock: null,
    page: members[0].set.page,
    setIds: members.map((m) => m.id),
    members,
    variantAxes: mergedVariantAxes(members),
    nonVariantProps: mergedNonVariantProps(members),
    mode,
  };
}

// detectQualifierGroups(sets, cems) -> ContainsGroup[]
//   sets: Figma sets NOT consumed by exact match or fusion; each { id, name, page, properties? }
//   cems: [{ tag, slug, attributes:[{name,kind,values?}] }, ...]
export function detectQualifierGroups(sets, cems) {
  // 1. Assign each eligible set to its most-specific head component.
  const assignments = new Map(); // tag -> { comp, members:[{id,name,set,value,qualifier}] }
  const cemSlugs = new Set(cems.map((c) => c.slug));
  for (const set of sets) {
    if (set.name.startsWith(".")) continue; // leading-dot internal, parity with exact tier
    const { slug } = slugify(set.name);
    if (cemSlugs.has(slug)) continue; // slug IS an exact CEM tag -> belongs to the exact tier
    const hit = pickHeadComponent(slug, cems);
    if (!hit) continue;
    const tag = hit.component.tag;
    if (!assignments.has(tag)) assignments.set(tag, { comp: hit.component, members: [] });
    assignments.get(tag).members.push({ id: set.id, name: set.name, set, qualifier: [...hit.qualifier] });
  }

  // 2. Resolve each group by mode. (attr + canonical land in Tasks 3-4.)
  const groups = [];
  for (const { comp, members } of assignments.values()) {
    if (members.length === 1) {
      const m = members[0];
      groups.push(makeGroup(comp.tag, comp, [{ id: m.id, name: m.name, set: m.set, value: null }], "sole"));
      continue;
    }
    const resolved = resolveMulti(comp, members); // Tasks 3-4
    if (resolved) groups.push(resolved);
  }

  // 3. Deterministic order by page then boundTag.
  groups.sort((a, b) => (a.page === b.page ? byString(a.boundTag, b.boundTag) : byString(a.page, b.page)));
  return groups;
}

// Placeholder until Task 3/4 — multi-member groups resolve to null (no bind) for now.
function resolveMulti(comp, members) {
  return null;
}
```

- [ ] **Step 4: Run to verify it passes**

Run: `node --test src/match/qualifier.test.mjs`
Expected: PASS (3/3).

- [ ] **Step 5: Commit**

```bash
git add src/match/qualifier.mjs src/match/qualifier.test.mjs
git commit -m "feat(match): qualifier grouping + sole-set mode (contains tier)"
```

---

## Task 3: `qualifier.mjs` — attr-resolvable mode (fusion leftover)

**Files:**
- Modify: `src/match/qualifier.mjs` (replace the `resolveMulti` placeholder)
- Test: `src/match/qualifier.test.mjs`

Rule (design mode 2): pick the head component's enum/boolean attribute that the members' qualifiers *collectively* resolve. A member's single-token qualifier resolves to an ENUM value via `bestValueMatch`, or to a BOOLEAN by folded name-equality (`indeterminate` token == `indeterminate` attr → true). Bind ALL members when every member resolves, OR when exactly one member is unresolved and that attribute has a unique leftover value/pole (that member becomes the bare `value:null` — `proposeFusionValues` assigns it the leftover downstream).

- [ ] **Step 1: Write the failing tests** (append to `src/match/qualifier.test.mjs`)

```js
const CARD = { tag: "m3e-card", slug: "card", attributes: [
  { name: "orientation", kind: "enum", values: ["vertical", "horizontal"] },
] };
const BG = { tag: "m3e-button-group", slug: "button-group", attributes: [
  { name: "variant", kind: "enum", values: ["standard", "connected"] },
] };
const PROG = { tag: "m3e-circular-progress-indicator", slug: "circular-progress-indicator", attributes: [
  { name: "indeterminate", kind: "boolean" },
] };

test("attr mode: all qualifiers value-match an enum (Connected/Standard -> variant)", () => {
  const groups = detectQualifierGroups(
    [set("3:1", "Connected button group"), set("3:2", "Standard button group")], [BG]);
  assert.equal(groups.length, 1);
  const g = groups[0];
  assert.equal(g.boundTag, "m3e-button-group");
  assert.equal(g.mode, "attr");
  const byId = Object.fromEntries(g.members.map((m) => [m.id, m.value]));
  // qualifier tokens come from slugify (lowercased); proposeFusionValues folds
  // case anyway, so lowercase value-matches the enum + is functionally correct.
  assert.equal(byId["3:1"], "connected");
  assert.equal(byId["3:2"], "standard");
});

test("attr mode with leftover: one member unresolved becomes bare value=null (Stacked=leftover)", () => {
  const groups = detectQualifierGroups(
    [set("4:1", "Horizontal card"), set("4:2", "Stacked card")], [CARD]);
  const g = groups[0];
  assert.equal(g.mode, "attr");
  const byId = Object.fromEntries(g.members.map((m) => [m.id, m.value]));
  assert.equal(byId["4:1"], "horizontal");       // value-matches orientation:horizontal (lowercase slug token)
  assert.equal(byId["4:2"], null);               // no match -> bare -> leftover (vertical) downstream
});

test("attr mode boolean: determinate/indeterminate -> indeterminate boolean (name-affinity + leftover)", () => {
  const groups = detectQualifierGroups(
    [set("5:1", "Circular-indeterminate progress indicator"), set("5:2", "Circular-determinate progress indicator")], [PROG]);
  const g = groups[0];
  assert.equal(g.mode, "attr");
  const byId = Object.fromEntries(g.members.map((m) => [m.id, m.value]));
  assert.equal(byId["5:1"], "indeterminate"); // folds to the boolean attr name -> the resolving member
  assert.equal(byId["5:2"], null);            // the other -> bare -> false downstream
});
```

- [ ] **Step 2: Run to verify they fail**

Run: `node --test src/match/qualifier.test.mjs`
Expected: FAIL — the new multi-member cases return no group (placeholder `resolveMulti` returns null).

- [ ] **Step 3: Implement `resolveMulti` attr mode** (replace the placeholder in `src/match/qualifier.mjs`; canonical fallback lands in Task 4)

```js
function foldWord(s) {
  return String(s ?? "").toLowerCase().replace(/[^a-z0-9]+/g, "");
}

// Does a member's qualifier resolve against `attr`? Returns the resolving word
// (the raw qualifier token) or null. Enum: any qualifier token value-matches an
// attr value. Boolean: any qualifier token folds to the attr's own name.
function resolveMemberToAttr(member, attr) {
  for (const q of member.qualifier) {
    if (attr.kind === "enum" && Array.isArray(attr.values)) {
      if (bestValueMatch(q, attr.values)) return q;
    } else if (attr.kind === "boolean") {
      if (foldWord(q) === foldWord(attr.name)) return q;
    }
  }
  return null;
}

// Multi-member: bind on the attribute the qualifiers collectively resolve.
// Returns a ContainsGroup (mode "attr") or null (Task 4 adds canonical).
function resolveMulti(comp, members) {
  const attrs = (comp.attributes || []).filter((a) => a.kind === "enum" || a.kind === "boolean");
  let best = null; // { attr, resolved: Map<memberId, word>, unresolved: [member] }
  for (const attr of attrs) {
    const resolved = new Map();
    const unresolved = [];
    for (const m of members) {
      const w = resolveMemberToAttr(m, attr);
      if (w !== null) resolved.set(m.id, w);
      else unresolved.push(m);
    }
    if (resolved.size === 0) continue;
    if (best === null || resolved.size > best.resolved.size) best = { attr, resolved, unresolved };
  }

  if (best) {
    // Accept when every member resolves, OR exactly one is unresolved (it takes
    // the leftover value/pole downstream via proposeFusionValues, as bare null).
    if (best.unresolved.length <= 1) {
      const outMembers = members.map((m) => ({
        id: m.id, name: m.name, set: m.set,
        value: best.resolved.has(m.id) ? best.resolved.get(m.id) : null,
      }));
      return makeGroup(comp.tag, comp, outMembers, "attr");
    }
  }
  return resolveCanonical(comp, members); // Task 4
}

// Placeholder until Task 4.
function resolveCanonical(comp, members) {
  return null;
}
```

- [ ] **Step 4: Run to verify they pass**

Run: `node --test src/match/qualifier.test.mjs`
Expected: PASS (all Task 2 + Task 3 tests).

- [ ] **Step 5: Commit**

```bash
git add src/match/qualifier.mjs src/match/qualifier.test.mjs
git commit -m "feat(match): attr-resolvable mode with fusion leftover (contains tier)"
```

---

## Task 4: `qualifier.mjs` — canonical-only mode + gap

**Files:**
- Modify: `src/match/qualifier.mjs` (replace the `resolveCanonical` placeholder)
- Test: `src/match/qualifier.test.mjs`

Rule (design mode 3): when the qualifiers do NOT collectively resolve to one attribute, bind ONLY the member whose qualifier is a `BASE_MARKERS` word (Basic dialog, Standard slider) as a sole plain bind; the other members are dropped from the group (they surface as gaps). If there is not exactly one base-marker member, bind nothing.

- [ ] **Step 1: Write the failing tests** (append to `src/match/qualifier.test.mjs`)

```js
const DIALOG = { tag: "m3e-dialog", slug: "dialog", attributes: [
  { name: "open", kind: "boolean" }, // no enum whose values are basic/list/scrollable
] };

test("canonical mode: bind only the base-marker set, gap the rest (Basic dialog -> m3e-dialog)", () => {
  const groups = detectQualifierGroups(
    [set("6:1", "Basic dialog"), set("6:2", "List dialog"), set("6:3", "Scrollable dialog")], [DIALOG]);
  assert.equal(groups.length, 1);
  const g = groups[0];
  assert.equal(g.boundTag, "m3e-dialog");
  assert.equal(g.mode, "canonical");
  assert.deepEqual(g.setIds, ["6:1"]); // only Basic; List/Scrollable dropped -> gap
  assert.equal(g.members[0].value, null);
});

test("no base marker + no attr resolution -> bind nothing (all gap)", () => {
  const groups = detectQualifierGroups(
    [set("7:1", "List dialog"), set("7:2", "Scrollable dialog")], [DIALOG]);
  assert.deepEqual(groups, []);
});
```

- [ ] **Step 2: Run to verify they fail**

Run: `node --test src/match/qualifier.test.mjs`
Expected: FAIL — canonical cases return null (placeholder).

- [ ] **Step 3: Implement `resolveCanonical`** (replace the placeholder in `src/match/qualifier.mjs`; also import `BASE_MARKERS` — already imported in Task 2)

```js
function resolveCanonical(comp, members) {
  const canon = members.filter((m) => m.qualifier.length === 1 && BASE_MARKERS.has(m.qualifier[0].toLowerCase()));
  if (canon.length !== 1) return null; // 0 or >1 base markers -> no unambiguous canonical -> gap all
  const m = canon[0];
  return makeGroup(comp.tag, comp, [{ id: m.id, name: m.name, set: m.set, value: null }], "canonical");
}
```

- [ ] **Step 4: Run to verify they pass**

Run: `node --test src/match/qualifier.test.mjs`
Expected: PASS (all Task 2-4 tests).

- [ ] **Step 5: Commit**

```bash
git add src/match/qualifier.mjs src/match/qualifier.test.mjs
git commit -m "feat(match): canonical-only mode + gap fallback (contains tier)"
```

---

## Task 5: Integrate the contains tier into `matcher.mjs`

**Files:**
- Modify: `src/match/matcher.mjs` (`indexCem`, `buildFigmaCandidates`, `match()` loop)
- Test: `src/match/matcher.test.mjs`

The `match()` function already builds `{ bySlug, enriched }` and calls `buildFigmaCandidates(figma)`. Thread a `cems` list (each `{ tag, slug, attributes }`) into candidate assembly; run `detectQualifierGroups` on the sets NOT consumed by `detectFusionGroups`; emit `kind:"contains"` candidates; bind them in the loop.

- [ ] **Step 1: Write the failing test** (append to `src/match/matcher.test.mjs`, using the real loaders)

```js
import { match } from "./matcher.mjs";
import { loadCem } from "../ingest/cem.mjs";
import { loadFigmaExport } from "../ingest/figma.mjs";
import fs from "node:fs";
import path from "node:path";

function realMatch() {
  const prof = JSON.parse(fs.readFileSync(path.join(process.cwd(), "profiles/m3-kit/profile.json"), "utf8"));
  const cem = loadCem(prof.cem);
  const figma = loadFigmaExport(prof.figmaExportPath);
  return match(cem, figma);
}

test("contains tier: the clean qualifier components bind at tier:contains", () => {
  const { candidates } = realMatch();
  const byTag = (t) => candidates.filter((c) => c.cemTag === t);
  for (const tag of ["m3e-avatar", "m3e-tooltip", "m3e-radio", "m3e-button-group", "m3e-card",
                      "m3e-circular-progress-indicator", "m3e-linear-progress-indicator"]) {
    const hits = byTag(tag);
    assert.ok(hits.length >= 1, `${tag} should be matched`);
    assert.ok(hits.some((c) => c.tier === "contains"), `${tag} should bind at tier:contains`);
  }
});

test("contains tier does NOT let m3e-chip grab the exact-matched specific chips", () => {
  const { candidates } = realMatch();
  // The specific chips keep their exact bindings; m3e-chip does not own their sets.
  for (const specific of ["m3e-filter-chip", "m3e-input-chip", "m3e-suggestion-chip", "m3e-assist-chip"]) {
    const hit = candidates.find((c) => c.cemTag === specific);
    assert.ok(hit && hit.tier === "exact", `${specific} stays exact`);
  }
});

test("un-resolvable structural variants stay gaps (List dialog / Range slider)", () => {
  const { candidates } = realMatch();
  const listDialog = candidates.find((c) => c.figmaName === "List dialog");
  const rangeSlider = candidates.find((c) => c.figmaName === "Range slider");
  assert.ok(!listDialog || listDialog.tier === "gap", "List dialog not bound");
  assert.ok(!rangeSlider || rangeSlider.tier === "gap", "Range slider not bound");
});
```

- [ ] **Step 2: Run to verify it fails**

Run: `node --test src/match/matcher.test.mjs`
Expected: FAIL — no candidate has `tier:"contains"` yet.

- [ ] **Step 3: Implement the integration** (`src/match/matcher.mjs`)

3a. Import at the top (near the fusion import):

```js
import { detectQualifierGroups } from "./qualifier.mjs";
```

3b. In `indexCem`, also return a `cems` array carrying attributes for the qualifier grouper (the `enriched` entries already have `{ component, slug }`; expose a slim view):

```js
// inside indexCem, after building `enriched`:
const cems = enriched.map(({ component, slug }) => ({ tag: component.tag, slug, attributes: component.attributes }));
return { bySlug, enriched, cems };
```

3c. Change `buildFigmaCandidates(figma)` to accept `cems` and run the qualifier grouper on unconsumed sets, AFTER fusion consumes its sets and BEFORE the singleton-set loop. Add its set ids to `consumed`, and push a `kind:"contains"` candidate per group:

```js
function buildFigmaCandidates(figma, cems) {
  const groups = detectFusionGroups(figma.sets);
  const consumed = new Set(groups.flatMap((g) => g.setIds));

  const candidates = [];
  for (const group of groups) {
    candidates.push({
      kind: "fusion", name: group.base, slug: group.baseSlug, buildingBlock: group.buildingBlock,
      page: group.page, setIds: group.setIds, group,
      descTokens: descriptionTokens(pickGroupDescription(group)), docUrls: docUrls(pickGroupDescription(group)),
    });
  }

  // Contains tier: group remaining sets by head-noun (design 2.x).
  const remainingSets = figma.sets.filter((s) => !consumed.has(s.id));
  const qualGroups = detectQualifierGroups(remainingSets, cems);
  for (const g of qualGroups) {
    for (const id of g.setIds) consumed.add(id);
    candidates.push({
      kind: "contains", name: g.base, slug: g.baseSlug, buildingBlock: g.buildingBlock,
      page: g.page, setIds: g.setIds, boundTag: g.boundTag, group: g,
      descTokens: new Set(), docUrls: new Set(),
    });
  }

  for (const set of figma.sets) {
    if (consumed.has(set.id)) continue;
    // ... UNCHANGED existing singleton-set candidate code ...
```

(Keep the rest of `buildFigmaCandidates` — singleton sets, standalones, icon page — exactly as-is.)

3d. Update the call site in `match()`:

```js
const { bySlug, enriched, cems } = indexCem(cem);
const figmaCandidates = buildFigmaCandidates(figma, cems);
```

3e. In the `match()` loop, add a `kind:"contains"` branch that binds the pre-decided tag. Put it BEFORE the `exactHits` block:

```js
for (const candidate of figmaCandidates) {
  let component = null;
  let tier = "gap";
  let score = 0;
  const rationale = [];

  if (candidate.kind === "contains") {
    const hit = bySlug.get(normalizeName(candidate.boundTag));
    component = hit ? hit.find((c) => c.tag === candidate.boundTag) : null;
    if (component) {
      tier = "contains";
      score = 0.95; // below exact's 1.0, above the 0.5 fuzzy floor
      rationale.push(
        `contains tier: set(s) [${candidate.setIds.join(", ")}] contain-match CEM tag '${candidate.boundTag}' ` +
        `(mode ${candidate.group.mode}); qualifier bound as fixed value(s)`
      );
    }
  } else {
    // Tier 1: exact — normalized names equal.
    const exactHits = bySlug.get(candidate.slug);
    // ... UNCHANGED existing exact + fuzzy code ...
  }

  // ... UNCHANGED existing `if (!component)` gap rationale + fusion rationale unshift ...
```

3f. Reuse the fusion proposal assembly for contains candidates. In the result-assembly block, change the fusion guard so `contains` groups (which are fusion-shaped) run the same proposals:

```js
if (component && (candidate.kind === "fusion" || candidate.kind === "contains")) {
  result.axisProposals = candidate.group.variantAxes.map((axis) => proposeAxis(axis, component));
  result.fusion = proposeFusionValues(candidate.group, component);
  result.propertyProposals = candidate.group.nonVariantProps.map((p) => proposeProperty(p, component));
} else if (component && candidate.kind === "set" && candidate.set.properties) {
  // ... UNCHANGED ...
```

Note: `proposeFusionValues` reads `group.members[*].value` and `group.base` — the ContainsGroup provides both. A `value` that is a raw qualifier word (e.g. `"Connected"`) is folded/value-matched by `proposeFusionValues` exactly as a fusion suffix value is; a `null` member takes the leftover.

- [ ] **Step 4: Run to verify it passes**

Run: `node --test src/match/matcher.test.mjs`
Expected: PASS — the 7 clean tags bind at `tier:"contains"`, chips stay exact, List dialog / Range slider stay gaps.

- [ ] **Step 5: Commit**

```bash
git add src/match/matcher.mjs src/match/matcher.test.mjs
git commit -m "feat(match): wire the contains tier into match() (qualifier-aware binding)"
```

---

## Task 6: Regression — byte-stability, confirmed set, full suite

**Files:**
- No production code. Verification + a possible `correspondence.json` regeneration review.

- [ ] **Step 1: Regenerate the correspondence and inspect the delta**

Run: `node src/cli.mjs match --profile m3-kit`
Then: `git diff --stat profiles/m3-kit/correspondence.json`
Expected: the file gains `proposed` entries for the newly-matched tags (avatar, tooltip, radio, button-group, card, both progress indicators) at `tier:"contains"`. The 13 existing `confirmed` entries MUST be unchanged (the merge is human-protective; confirmed entries never regress). If any confirmed entry changed, STOP — that's a regression.

- [ ] **Step 2: Verify the confirmed set is untouched**

```bash
node -e '
const fs=require("fs");
const arr=JSON.parse(fs.readFileSync("profiles/m3-kit/correspondence.json","utf8"));
const conf=arr.filter(e=>e.status==="confirmed").map(e=>e.cemTag).sort();
console.log(conf.length, conf.join(","));
'
```
Expected: `13` and exactly the banked set (assist-chip, badge, button, checkbox, fab, filter-chip, icon-button, input-chip, list-item, search-bar, shape, suggestion-chip, switch).

- [ ] **Step 3: Run the A8 tracer + full suite**

Run: `rm -rf render-cache/results && pnpm test 2>&1 | grep -E '^# (tests|pass|fail)'`
Expected: all pass. The A8 tracer (`test/correspond.test.mjs`) asserts the confirmed set is exactly 13 and that re-running `match` reproduces `correspondence.json` byte-for-byte — both must hold (the contains tier only ADDS proposed entries; it must be deterministic so the byte-stable re-match still passes).

- [ ] **Step 4: Commit the regenerated correspondence**

```bash
git add profiles/m3-kit/correspondence.json profiles/m3-kit/gap-report.md
git commit -m "chore(match): regenerate correspondence with contains-tier proposals (7 new components matched)"
```

---

## Self-Review

**Spec coverage:** §2.1 token-subset longest-wins → Task 1 (`containsSubset`/`pickHeadComponent`). §2.2 three modes → Tasks 2 (sole), 3 (attr+leftover), 4 (canonical). §2.3 fusion-shaped groups + reuse `proposeFusionValues`/emitter → Task 2 shape + Task 5 (3f). §2.4 integration point → Task 5. §3 guarantees: false-positive (exact-consumed + longest-match) → Task 5 (3c consumes fusion first; remaining excludes exact via the singleton loop already skipping consumed) + Task 1 longest-wins; determinism → `byString`/`byKey`, Task 6 byte-stable. §4 coverage table → Task 5 integration test. §5 testing → Tasks 1-6 tests. §6 out-of-scope (banking, content-modeling, sub-parts) → not tasked (correct).

**One coverage nuance to verify during Task 5:** the design excludes exact-matched sets from the contains tier. `buildFigmaCandidates` consumes fusion sets explicitly, but exact matching happens later in the `match()` loop, not at candidate-build time — so a set that WILL exact-match is still passed to `detectQualifierGroups`. This is safe because such a set's slug EQUALS a CEM slug, so `pickHeadComponent` would return that same CEM tag as a (degenerate, zero-qualifier) contain-match. **Guard (APPLIED in Task 2):** `detectQualifierGroups` skips any set whose slug is itself an exact CEM slug (`cemSlugs.has(slug)`) — it belongs to the exact tier, not contains. Task 2 Step 1 includes the `Filter chip` → no-group test.

**Placeholder scan:** the `resolveMulti`/`resolveCanonical` placeholders are intentional TDD scaffolding, each replaced in the next task (2→3→4) with complete code. No `TBD` remains in shipped code.

**Type consistency:** `ContainsGroup` fields (`boundTag`, `base`, `baseSlug`, `page`, `setIds`, `members:[{id,name,set,value}]`, `variantAxes`, `nonVariantProps`, `mode`) are produced by `makeGroup` (Task 2) and consumed by matcher.mjs Task 5 (3c reads `boundTag`/`base`/`baseSlug`/`page`/`setIds`/`group`; 3f reads `group.variantAxes`/`group.members`/`group.nonVariantProps`). `proposeFusionValues` reads `group.members[*].value` + `group.base` — both present. `pickHeadComponent` returns `{ component, qualifier:Set }`; Task 2 consumes `hit.component.tag` + `[...hit.qualifier]`. Consistent.

**Known consideration for execution (not a blocker):** contains-group members may have *incompatible* internal variant-axis signatures (unlike fusion siblings, which `detectFusionGroups` checks). `mergedVariantAxes` picks the first member with captured properties, so the emitted per-set axis mapping is a best-effort merge; any real mismatch surfaces at bank time (the gate + human review catch it before a component is confirmed). Banking is out of scope here, so this is acceptable for the matching change.
