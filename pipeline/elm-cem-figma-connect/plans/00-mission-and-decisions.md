# 00 — Mission, decisions, and verified ground truth

> Companion to the original vision brief: [`BRIEF.md`](BRIEF.md) (2026-07-10 — restored
> into this repo after its original home, `elm-m3e/docs/FIGMA-CODE-CONNECT-UNIFIED-MERGE.md`,
> was deleted during the review-2026-07 cleanup).
> This doc records what was DECIDED and what was PROVEN after that brief was written.
> Where the two disagree, this doc wins — the brief was written before verification.

## Mission (one sentence)

Merge the `@m3e/web` CEM (+ `.d.ts`), the Figma M3-kit component/variant/token graph, and
the `tailwind-m3e-web` token surface into one correspondence model, and auto-generate from
it: Figma Code Connect for web components and Elm, a token/codeSyntax bridge that makes
Figma-generated layout code speak our vocabulary, and a visual verification gate — packaged
as a **general tool** any CEM+Figma project can adopt.

## Decision ledger (user decisions, 2026-07-10 grill)

| # | Decision |
|---|---|
| D1 | The VOLT-2003 spike (`elm-m3e-figma-code-connect-design.md`) is **input only**; architecture re-derived here (its verified facts carry over as evidence). |
| D2 | Align to the **canonical M3 kit**; first publish target = the user's unmodified drafts copy (`KujuFlfJSwHI6ua1b7RZvL`). A decoupled customization/delta mechanism is required for downstream brand deviations. |
| D3 | Plan is complete start-to-finish; **all uncertain claims verified before planning** (done — see evidence ledger); no half-steps. |
| D4 | Snippet philosophy: **web component always preferred** — if an attribute models it, never a utility class. Tailwind = layout scaffolding + token vocabulary only. |
| D5 | Elm label surface: **configurable, top `M3e.*` default**. |
| D6 | Code-only / Figma-only gaps are **logged as a first-class report**; **no code-driven Figma content authoring, ever** — permanent, not scoped to this plan or any session. Mechanically enforced; see note below the table. |
| D7 | Match scope: **all component sets including Building Blocks AND the 141 icons**. |
| D8 | **Visual diff is a gate**: a match graduates to a published binding only after its renders pass (or a human approves the flagged diff). Review webapp in scope. |
| D9 | Engine = **this repo** (`jackhp95/cem-figma-connect`), private until release; a general tool; vendors a generalized extraction path; the Figma dump is checked in as deterministic input. |
| D10 | Plans assume the **post-review-2026-07** state of elm-cem/elm-m3e (namespaces `M3e.Html`/`M3e.Raw`/`M3e.Token`, forms Loose/Record/Build, rules in elm-review-cem, examples-gen shared harness). |
| D11 | Upstream `matraic/m3e` PR = **follow-up reminder** at the end, not a plan phase. |
| D12 | **Avetta is the in-plan second consumer.** Endgame: Figma integration for the future Avetta stack = `avetta/ui` main + Tailwind v4 + elm-m3e + minor Material branding tweaks. |
| D13 | elm-m3e registry release is out of scope (snippets are strings; nothing blocks on package adoption). |
| D14 | (2026-08-18) Correspondence stays **external to CEM config**; any Figma association surfaced inside elm-cem's `--config-from` channel is a **derived-only** projection (`figma-links.json` → generated `docMeta`), never hand-authored there. The apparent D2 fileKey conflict is **two roles, not a conflict**: `profile.json`'s `fileKey` is the extraction anchor (settled); the `--file-key` passed to `publish` is a separate, still-open publish-target choice, resolved by one `--dry-run` whenever live Figma access returns — see `plans/2026-08-17-figma-elm-config-integration-design.md`. |

> ⛔ **D6 enforcement.** Mechanically blocked by `tools/check-figma-write-block.mjs`
> (wired as a `PreToolUse` hook), which stops `use_figma` writes, `create_new_file`, and
> `generate_figma_design` outright — regardless of plan or session. This does not cover
> `send_code_connect_mappings`, `add_code_connect_map`, or this package's own
> `publish`/`unpublish` CLI, which are the sanctioned, gated Code Connect bridge.

> ℹ️ **D2 fileKey — resolved as a role split, not a conflict (D14).** D2's
> `KujuFlfJSwHI6ua1b7RZvL` and `profiles/m3-kit/profile.json`'s `UtwpUdPiOZEuxp8Nq1d5yQ`
> were never actually disputing the same value — the profile's `fileKey` pins the
> **extraction anchor** (the epoch every node-id in `correspondence.json` was matched
> against), while D2 named a candidate **publish target**, a separate `--file-key` passed
> to `publish` at run time. See `STATUS.md` and `docs/USAGE.md` → "Two different fileKeys,
> two different roles" for the full account, including the second publish-target candidate
> (`iPFL8MH2R1Xphe94j7g809`) surfaced 2026-08-04.

## Verified ground truth (2026-07-10) — what the plans may rely on

Full detail: [`../research/evidence/2026-07-10-verification-ledger.md`](../research/evidence/2026-07-10-verification-ledger.md).

**Publishing / Code Connect mechanics (proven live):**
1. `figma connect publish` works from the user's Avetta **Dev seat** against his **drafts**
   copy, with `parser: "html"` template files. Dry-run and real publish both green.
2. Templates are **evaluated per variant node**: `getEnum`/`getString` maps produce the
   correct attribute values in each variant's snippet. Property names with spaces
   ("Label text") work.
3. **Multiple labels coexist** on one node ("Web Components" + "Elm"), filterable via
   `codeConnectLabel`.
4. `get_design_context` on a bound node returns the snippet **verbatim, with imports**,
   inside `<CodeConnectSnippet>` — replacing raw markup. On frames it returns React+Tailwind
   whose CSS vars carry **Figma variable names**; spacing is **hard px**.
5. **Duplication mints new component keys** (Button set `4a813eda…` → `ff1de0e4…` in a fresh
   copy) — published mappings do NOT follow drafts duplicates. **Node IDs ARE stable.**
   ⇒ The consumption model is **per-copy republish** (one parameterized CLI run per fileKey),
   not "bind once, copies inherit". Published-library instance resolution remains the
   candidate "publish once" story — exercised in the Avetta phase (Plan F).
6. Variable **codeSyntax controls the vocabulary** of all MCP-generated layout code: stamping
   `WEB: var(--md-sys-color-…)` onto kit variables makes `get_design_context` emit those
   names (with resolved fallbacks) immediately. `use_figma` can write codeSyntax — **no
   custom plugin needed** for that pass.

**The data (measured):**
7. CEM @m3e/web 2.5.12–2.5.14: 439–440 modules, **121 unique tags** (123 declarations, 2
   dupes). 505 attributes. Named-union resolution requires the sibling `.d.ts` files; the
   elm-cem inliner approach resolves **72/73 alias names (98.6%)** — the one miss
   (`LinkTarget`) is deliberately open-string, String fallback correct.
8. The kit **is M3 Expressive** (Buttons: `Size=XSmall..XLarge`, `Type=Round/Square`,
   `Width=Narrow/Default/Wide`; button group/split button/FAB menu/loading indicator/toolbar
   all present).
9. **Set-name↔attribute-value fusion is real**: the button's color variant is five sibling
   SETS (`Button`, `Button - text/elevated/outline/tonal`), not a variant axis. The
   correspondence model must support one CEM component ↔ N Figma sets.
10. Set-level `componentPropertyDefinitions`: TEXT (`Label text#id`), BOOLEAN
    (`Show icon#id`), INSTANCE_SWAP (`Icon#id`), VARIANT axes. Non-variant properties are
    part of parity (Figma default `Show icon=true` renders an icon the code default lacks).
11. Name-level match landscape: **53/121** CEM tags have kit counterparts; 68 CEM-only
    (~20 real gaps: select, autocomplete, breadcrumb, stepper, tree, paginator…; the rest
    triggers/infra). Kit-only: carousel, time pickers, side sheet, bottom app bar, XR sets.
    Kit data has typos (`State=Presssed`) — fuzzy matching required.
12. Icons: `m3e-icon` takes `name` = snake_case **Material Symbols** name — exactly the names
    the kit's 141 icon components use.
13. Kit variables: 4 collections; `M3` has **32 modes**; 304 variables (Schemes 49, State
    Layers 147, Static 95, Corner 10); **0 codeSyntax** shipped; 727/30/10 paint/text/effect
    styles; **no spacing/density variables** — density is code-side only.
14. Headless rendering of @m3e/web is **byte-stable** across runs (Playwright + esbuild
    bundle + pinned Roboto + HTTP server); Figma-side `export-png <nodeId>` works per
    variant. Visual-diff loop is feasible; parity requires driving **componentProperties,
    not just variant axes**, on both sides.

**Existing machinery to reuse (mapped in investigation):**
- VOLT-2003: annotation-driven generator (`ExtractUiComponents` elm-review rule →
  `lib.mjs`/`generate.mjs` → `.figma.ts`), drift+orphan `--check` CI gate, publish flow,
  footguns (no `/branch/` URLs, case-sensitive `getEnum` keys, Prettier must not touch
  generated files). Mechanics proven; its annotation-in-source model does NOT fit generated
  code — our correspondence lives in config (Plan A).
- elm-cem: CEM→Elm codegen with `.d.ts` alias inlining (`bin/elm-cem.js`), per-consumer
  `--config-from` deep-merge channel, per-component fact tables.
- elm-m3e docs: working **html→elm** mapper (`docs/scripts/examples-gen/lib/to-elm.mjs`,
  post-review-2026-07: shared harness) — the Elm-snippet derivation path.
- tailwind-m3e-web: CEM-driven utility codegen already exists (2,254 utilities, 94
  components, `generated/CSS_CUSTOM_PROPERTIES.md` manifest); tokens are `--md-*` 3-tier
  cascade; density = `density-0..3` scope utilities.
- akg-synapse: VSD plugin + WS relay (bun) extraction infra + runbook; `get_variables`,
  `get_styles`, `export-png`, `get_component_properties` all proven this session.

## Consumption model (consequence of #5)

The tool treats **(fileKey, correspondence, labels)** as the publish unit:
- Anyone adopting: duplicate the kit (or point at your own library file) → run the tool's
  publish command with your fileKey + token → all labels appear in YOUR file. Node-id
  stability across duplicates of the same kit version makes the canonical correspondence
  file portable; component keys are resolved fresh per file at publish time.
- Brand/custom deviations: a **delta config** overlays the canonical correspondence
  (add/override/suppress per component) — same mechanism serves Avetta (Plan F) and any
  third party.

## Human checkpoints (expected, batched)

- Figma desktop sessions for extraction (plugin bridge) and `use_figma` runs.
- `FIGMA_ACCESS_TOKEN`-gated publishes.
- Visual-diff review webapp sessions (only above-threshold diffs).
- ⚠️ The current token was pasted in chat on 2026-07-10 — rotate it once publish tooling
  stabilizes.
