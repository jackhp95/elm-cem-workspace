# Manual-correspondence injection + bank m3e-tab — Design + Plan

**Status:** approved-to-proceed (Jack 2026-07-19: "tab now"). Corrects the false "tab unbankable" — real Figma tab sets exist but the matcher can't reach them.

**Goal:** Bank `m3e-tab` by a representative example, via a small, LOW-RISK manual-correspondence mechanism (the matcher structurally cannot claim the tab sets, and a matcher fix is high-blast-radius). Grows banked **31 → 32**.

---

## Root cause (why the matcher misses the tab sets)
- Real Figma COMPONENT_SETs exist: "Primary tabs/{Icon and label, Icon only, Label only}" (`54563:40142/40209/40268`) + "Secondary tabs/{Label only, Icon and label}" (`54563:40319/40366`). They sit as GAPS.
- `m3e-tabs` exact-matched "Tabs" (`54563:40023`). Slug normalization stems `tabs→tab`, so "tab" is an `exactMatchSlug`.
- `matcher.mjs:524` excludes a contains qualifier-group when its head-noun slug is an `exactMatchSlug`. The "Primary tabs/*" groups stem to head-noun "tab" → excluded → gaps. `m3e-tab` itself is `code-only` (lost the `tab` slug collision to the container `m3e-tabs`).
- Fixing line 524 / the tie-break touches the SHARED contains logic → risks shifting the 31 existing banks' correspondence (avatar/card/button-group/progress/menu-item/nav-item/tooltip are contains-tier). Rejected for blast radius.

## Design — `manual-correspondence.json`, merged at MATCH time
A new `profiles/m3-kit/manual-correspondence.json`: `cemTag → { figmaSets: [{nodeId, setName, fixedAttrs}], note }`. After the matcher builds the correspondence, a merge step applies each manual entry:
- **Only onto an UNBOUND cemTag** (current status/kind is `code-only` or `gap`). If the manual cemTag is already exact/contains/fusion-bound, THROW (a manual entry must never mask or override a real match — fail-loud).
- Replaces that entry with `{ cemTag, matcherKind:"manual", figmaSets, axes:[], props:[], confidence:0.9, provenance:"manual", rationale, status:"proposed" }`, preserving sort position.
- **Deterministic** → `match` reproduces it every run → the A8 byte-stable tracer holds. **Local** → only cemTags named in the file change; the 31 banks stay BYTE-IDENTICAL.
- **Validate** (a `validateManualCorrespondence`): each cemTag is a real CEM tag; each nodeId exists as a COMPONENT_SET in the figma export; each setName matches.

For m3e-tab, inject ONE representative set — "Primary tabs/Icon and label" (`54563:40142`) — the richest (icon + label). The other 4 sets stay gaps (documented follow-on; icon-only/label-only need different examples — out of scope).

## examples.json + bank
- `examples.json` `m3e-tab`: `[{tag:"m3e-icon", slot:"icon", attrs:{name:"favorite"}}, {tag:"span", text:"Favorites"}]` — the standalone tab already render-verified (heart + "Favorites", selected-purple).
- `overrides.json`: confirm m3e-tab (`gate:"example-verified"`, note).
- `confirm → gap → emit` → 1 web-component file `m3e-tab-primary-tabs-icon-and-label.figma.ts` with `<m3e-tab><m3e-icon slot="icon" name="favorite"></m3e-icon><span>Favorites</span></m3e-tab>`. Elm: m3e-tab not in elm-facts → skip (0 elm). AF-07 render-verify the emitted markup. `check` 0-drift.
- Tracers 31→32 (correspond CONFIRMED_TAGS+length; smoke wc manifest +1 key + file + wrote-count; html-label confirmedTags +1; emitter-api Buttons unaffected).

## Architecture / units
- `profiles/m3-kit/manual-correspondence.json` (new).
- `src/correspond/merge.mjs` `loadProfile` — load it (missing → `{}`).
- `src/correspond/matcher.mjs` (or runMatch) — the merge step (post-build, unbound-only, fail-loud) + `validateManualCorrespondence`.
- `profiles/m3-kit/examples.json` — m3e-tab entry.
- `profiles/m3-kit/overrides.json` — confirm m3e-tab.

## Tasks (TDD)
- **T1** — config + loader + validate + merge. Unit tests: merge onto a code-only entry replaces it (manual figmaSets, provenance:"manual"); merge onto an already-bound cemTag THROWS; a non-existent nodeId fails validation; the 31 banks' correspondence stays byte-identical (re-match → A8 holds). Create the real manual-correspondence.json (m3e-tab → 54563:40142).
- **T2** — bank m3e-tab: examples.json + overrides + confirm/emit + AF-07 (controller renders) + tracers + check 0-drift + full suite + commit. 31→32.

## Scope / out
- **In:** manual-correspondence mechanism + bank m3e-tab (1 representative set).
- **Out:** a matcher fix (blast radius); the other 4 tab sets (follow-on, need per-content examples); the live-5; elm m3e-tab (not in elm-facts). Byte-stability of the 31 banks is a HARD gate.
