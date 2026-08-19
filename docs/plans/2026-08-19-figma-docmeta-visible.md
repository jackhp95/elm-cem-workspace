# Feature — Figma docMeta, wired + visible (2026-08-19)

**Origin:** deferred item from `docs/reviews/2026-08-19-tools-scripts-caching-audit.md` (gen-figma-config
orphaned). Jack chose "Full — make it visible."
**Worktree:** `/Users/jack/.paseo/worktrees/3ov4grvm/feat-figma-docmeta` · branch `feat/figma-docmeta` (off main `85568e2`).
**Manager:** this session (gauntlet, inline).

## Goal + acceptance
Each component's reference page in the docs shows a "View in Figma" affordance linking to that
component's node in the public **M3 Design Kit (Community)** file, sourced end-to-end from
cem-figma-connect's correspondence. Verified with `check:drift` green + a Playwright screenshot at
411×761 showing the link, on a clean toolchained tree.

## Architecture (the flow)
```
core/cem-figma-connect/profiles/m3-kit/figma-links.json (+ faceC)
  └─ tools/gen-figma-config.mjs ─▶ brands/m3e/inputs/cem/config/figma.generated.json
        (per-constructor { docMeta: { figmaUrl, figmaStatus } })
  └─ --config-from=config/figma.generated.json  (elm-m3e/config is a symlink to inputs/cem/config)
        └─ elm-cem gen:src ─▶ M3e/**/*.elm doc comment gains
              <!-- elm-cem:docmeta figmaUrl=…; figmaStatus=… -->   (Docs.elm docMetaMarker)
        └─ extract-reference.mjs: PARSE the marker (today it DROPS it) ─▶ reference.json entry.figma = {url,status}
              └─ docs app Route/Components/Name_.elm ─▶ Doc.anchorPill "View in Figma"
```

## Key facts established (verified, not assumed)
- **URLs are PUBLIC** (M3 Design Kit Community file) → safe to publish. figmaStatus ∈ {approved, example-verified, …}.
- **elm-cem already consumes `docMeta`** (`Generate/Config.elm` `opt "docMeta" (keyValuePairs string)`; `Docs.elm:82` `docMetaMarker`). No codegen-core change.
- **Facts bundle (Face B/C) carries NO docMeta** (verified: elm-api-facts.json + cem-facts.json per-component keys) → **zero consumer-bundle drift**. Only Face A (elm-m3e/src, families) changes.
- `figma.generated.json` exists + is populated; `elm-m3e/config` → symlink → `inputs/cem/config`.
- `extract-reference.mjs:319` `overview()` currently strips `<!-- … -->` lines (drops the marker).
- Marker format: `\n\n<!-- elm-cem:docmeta k=v; k=v -->`, values escaped by `Docs.elm escapeMarker`.
- Config-from list is smeared (arch-review candidate 1). Face-A sites that must include the new config:
  `gen:src`, `check:cem`, `check:families`. Facts-only sites (regen.mjs GEN_CONFIG_ARGS, examples-gen/lib/facts.mjs)
  do NOT get it — docMeta doesn't affect facts, and adding it there is semantically wrong + risks noise.
  ab-elm-cem.sh / ab-elm-m3e-split.sh: include for Face-A byte-identity consistency (they usually SKIP).

## Leaves
| # | Leaf | Acceptance |
|---|---|---|
| L1 | Config wiring: add `--config-from=config/figma.generated.json` to gen:src, check:cem, check:families (+ ab-*.sh). | edits in place |
| L2 | Un-orphan + gate the generator: add `--check` mode to gen-figma-config.mjs; add `gen:figma-config` (before gen:src) + `check:figma-config` to elm-m3e; wire into gen chain + `check`. | `gen:figma-config` writes; `check:figma-config` byte-compares |
| L3 | Regenerate elm-m3e/src (+ families) → docMeta markers. Commit the (large, mechanical) generated diff. | marker present in a sample module; check:cem green |
| L4 | extract-reference.mjs: parse the docmeta marker → `figma:{url,status}` on the entry (keep it out of prose). Regenerate reference.json. | reference.json entries carry `figma`; check:drift green |
| L5 | Docs UI: Name_.elm decode `figma` + render "View in Figma" pill (Doc.anchorPill). | elm compiles; Playwright screenshot shows the link |
| L6 | Verify recompose (check:drift, elm-m3e check subset, Playwright) + commit. | captured evidence |

## Decisions log
- (execution below)
