# 01 — Architecture (re-derived, evidence-backed)

The vision brief (§5) offered three unified-model candidates and a strong prior. Per
decision D1 this was re-derived after verification. The prior survives — but now for
measured reasons, and with one structural addition the brief didn't anticipate
(set-fusion, see §3).

## 1. The unified model: CEM spine, per-concern authority

**(A) CEM as the structural spine — adopted.**

- The CEM+`.d.ts` side is *complete and enumerable*: 121 components, 505 attributes, 98.6%
  of enum value-spaces resolvable (evidence #7). Nothing else in the system can answer
  "what CAN exist."
- Figma is *materialized-only* (what was drawn), carries per-file-mutable identity
  (component keys re-mint on duplicate, evidence #5), but is **authoritative for design
  intent**: tokens, visual truth, and axes code doesn't model (`Width=Narrow/Default/Wide`).
- Tailwind (when present) is a *derived projection* — tailwind-m3e-web already generates its
  utility surface FROM the CEM, confirming the direction of derivation.

Rejected alternatives, for the record:
- **(B) fresh source-agnostic IR**: adds a third schema to maintain; the CEM already *is* a
  standardized, tool-supported interchange format, and the post-review elm-m3e stack
  (elm-cem fact tables, `M3e.Review` facts) already treats it as the hub. B duplicates that.
- **(C) Figma as spine**: loses enumerability (5,354 drawn variants vs the full cartesian
  space), and Figma identity is unstable across copies — a spine whose primary keys re-mint
  on duplication cannot anchor a deterministic pipeline.

**Per-concern authority** (who wins on conflict):

| Concern | Authority | Evidence |
|---|---|---|
| Component/attribute/value space | CEM + `.d.ts` | #7 |
| Which combinations exist visually; visual truth | Figma | #8, #14 |
| Design tokens & theming vocabulary | Figma variables (names/modes) ↔ code tokens via the token table; Figma wins on intent, code wins on mechanism | #6, #13 |
| Spacing/density | **Code** (tailwind-m3e-web density scopes) — Figma has no density tokens | #13 |
| Naming for generated code | Code (via codeSyntax stamping, we *push* our vocabulary into Figma) | #6 |

## 2. Pipeline dataflow

```
                    ┌──────────────────────────────────────────────────────┐
   INPUTS           │                 cem-figma-connect                    │          OUTPUTS
                    │                                                      │
 custom-elements.json ─► cem-ingest ─┐                                     │
 dist/**/*.d.ts     ─► (alias inline)│                                     │
                    │                ├─► MATCHER ─► correspondence.json ◄──┼── overrides / delta configs
 figma-export.json ─► figma-ingest ──┘      │           (checked in)       │      (consumer-owned)
 (components, props,│                       ▼                              │
  variables, styles)│                  gap-report.md ──────────────────────┼─► code-only / figma-only / undrawn
                    │                       │                              │
                    │                       ▼                              │
                    │   ┌── emit: .figma.ts (label "Web Components") ──────┼─► <m3e-button …> snippets
                    │   ├── emit: .figma.ts (label "Elm", via consumer     │
                    │   │        emitter profile)───────────────────────────┼─► M3e.Button.view … snippets
                    │   ├── emit: codeSyntax stamp script (use_figma) ─────┼─► Figma vars speak --md-sys-*
                    │   └── emit: figma.config.json per label ─────────────┼─► publish units
                    │                       │                              │
                    │                       ▼                              │
                    │   VISUAL GATE: render-harness (Playwright, code side)│
                    │                 ⋈ export-png (Figma side)            │
                    │                 ⋈ diff + review webapp ──────────────┼─► pass/fail per binding
                    │                       │                              │
                    │                       ▼                              │
                    │   publish runner: figma connect publish per          │
                    │   (fileKey × label), gated on visual pass ───────────┼─► Code Connect live in file
                    └──────────────────────────────────────────────────────┘
```

Everything deterministic and re-runnable; all inputs checked in (the Figma export is a
committed artifact, refreshed by a documented extraction session).

## 3. The correspondence model (the heart)

One checked-in file per consumer profile (canonical: `profiles/m3-kit/correspondence.json`),
merged from: auto-matcher output ⊕ persisted human overrides ⊕ consumer delta configs.
Re-runs are deterministic: the matcher never overwrites a human decision (provenance field).

Structural requirements proven by evidence:

1. **1:N set fusion** (#9): one CEM component ↔ several Figma sets, each set contributing a
   *fixed* attribute value (`Button - tonal` ⇒ `variant="tonal"`).
2. **Axis maps with value maps** (#2): Figma VARIANT axis → attribute, plus per-value map
   (`XSmall → extra-small`), tolerant of kit typos via fuzzy tier (`Presssed`).
3. **Non-variant property maps** (#10): TEXT → content slot/attr, BOOLEAN → slot-presence or
   attribute, INSTANCE_SWAP → icon slot (Material Symbols name pass-through, #12).
4. **Figma-only axes** (`Width`, `State`) — explicitly marked `unmapped`, with policy
   (ignore / doc-note). Never silently dropped: they appear in the gap report.
5. **Confidence + provenance** per binding: `auto-exact | auto-fuzzy | human`, with
   rationale string. Human review happens at component+property level, never per-variant.
6. **Identity by node-id + set name** per fileKey epoch (#5): component keys are recorded
   but treated as per-file cache, refreshed at publish time; node-ids are the stable anchor
   within a kit version; kit version is pinned in the profile.

Exact schema is Plan A's deliverable (with JSON Schema + validating loader).

## 4. Package shape (genericity contract)

Node CLI (ESM `.mjs`, zero framework deps in core), npm-publishable, private repo until
release. Layout sketch (final in Plan A):

```
src/
  ingest/cem.mjs            # reads the shared facts bundle (Face B/C) produced by elm-cem;
                            #   .d.ts alias inlining moved upstream into elm-cem as of M3.a
                            #   (dts-inline.mjs stays for a documented exception — see its header)
  ingest/figma.mjs          # figma-export.json loader + schema validation
  match/…                   # normalization, tiers, fusion detection
  correspond/…              # merge auto ⊕ overrides ⊕ delta; schema
  emit/html-label.mjs       # built-in web-component emitter (any CEM project gets this)
  emit/emitter-api.mjs      # emitter plugin interface (consumer-provided labels, e.g. Elm)
  tokens/…                  # token table + codeSyntax stamp-script generator
  publish/…                 # figma.config.json gen + publish/unpublish/check per fileKey
  visual/…                  # render harness + export-png orchestration + diff + review app
extract/                    # generalized Figma extraction (vendored plugin fork + runbook;
                            #   REST + use_figma documented as alternates)
profiles/m3-kit/            # first consumer: @m3e/web ⋈ M3 kit (correspondence, tokens, elm emitter cfg)
profiles/<consumer>/        # deltas overlay a base profile (Avetta in Plan F)
```

**Nothing m3e-specific in `src/`.** The m3e knowledge lives in `profiles/m3-kit/` + the Elm
emitter config. The Elm emitter itself consumes the post-review elm-m3e machinery (html→elm
mapper, fact tables) rather than reimplementing Elm knowledge here.

⚠️ IP note (flagged 2026-07-10): `extract/` generalizes the VSD plugin from
`avetta/akg-synapse` (itself adapted from MIT-licensed cursor-talk-to-figma-mcp). Treat as a
deliberate port with provenance headers; the user owns the call on licensing before release.

## 5. Label strategy

- **"Web Components"** — built-in emitter, universal for any CEM consumer.
- **"Elm"** — consumer emitter (elm-m3e profile), surface-configurable (top `M3e.*` default,
  Build/Record/Html/Raw selectable) per D5.
- **No third "Tailwind" label** (D4 + evidence #4/#6): Tailwind's integration is the token
  table + codeSyntax stamping (layout code vocabulary) — not per-component snippets. Hybrid
  output emerges from the MCP naturally: bound instances → snippets; surrounding layout →
  Tailwind-with-our-token-names.

## 6. Visual gate placement (D8)

The gate sits between *correspondence* and *publish*: a binding is publishable when its
sampled variant renders diff within threshold (or a human approved the flagged diff in the
review webapp). Sampling policy, thresholds, and the parity-driving contract (variant axes
AND componentProperties on both sides, #14) are Plan C.

## 7. What Plan letters own

| Plan | Owns |
|---|---|
| A — engine core | repo scaffold, ingest (CEM+dts, figma export schema + extraction), matcher, correspondence schema, gap report |
| B — emitters & publish | html-label emitter, emitter API, Elm emitter (via elm-m3e), figma.config gen, publish/check/unpublish runner, drift guards |
| C — visual gate | render harness productization, export-png batching, diff pipeline, review webapp, gate wiring |
| D — tokens | token correspondence table, codeSyntax stamping, density policy, mismatch classification (naming vs spec failure) |
| E — consumer: elm-m3e | full-breadth m3-kit profile, icons, committed artifacts + CI drift checks in elm-m3e |
| F — consumer: Avetta | published-library resolution test, ADS delta profile, branding tokens, stale `Ui.*` mapping retirement |
