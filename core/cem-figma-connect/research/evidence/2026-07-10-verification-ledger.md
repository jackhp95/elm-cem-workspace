# Verify-now status — FIGMA-CODE-CONNECT-UNIFIED-MERGE planning

Evidence ledger for the seven pre-plan verifications agreed 2026-07-10.
Detail reports live beside this file; this is the roll-up the plan cites.

## ✅ Item 5 — Kit variables/styles dump (file key still pending)

Via live bridge (channel `vsd-cfc42e`, Design mode, file "Material 3 Design Kit (Community)"):

- `kit-variables.json` (1.08 MB): 4 collections, 304 variables.
  - **M3 collection: 32 modes** — Light/Dark × (default/Medium/High contrast) + Monochrome/Pink/Rose/Red/Orange/Yellow/Chartreuse/Green/Teal/Cyan/Blue/Indigo/Purple LT/DT.
  - Variable families: `Schemes/*` (49 color roles), `State Layers/*` (147), `Static/*` (95), `Corner/*` (10, shape), `Tracking/*` (2), `Add-ons` (1).
  - **codeSyntax: 0 of 304** — confirmed the "binding is not in the file" assumption.
  - **No spacing/density variables exist** in the kit — density/spacing lives only in auto-layout geometry. The token plan cannot read density from Figma variables.
- `kit-styles.json` (371 KB): 727 paint styles, 30 text styles, 10 effect styles, 0 grid.
- `kit-doc-info.json`: full page list.
- **File key: NOT obtainable from the plugin sandbox** (`figma.fileKey` empty; no deep links in serializers for these commands). Get it from the user's address bar during the publish session.

## ✅ Item 6a — Expressive delta + icon mechanism (`06a-expressive-delta.md`)

- **Kit IS M3 Expressive.** Buttons: `Size=XSmall..XLarge`, `Type=Round/Square`, `Width=Narrow/Default/Wide`. All 5 Expressive-era components present (button group, split button, FAB menu, loading indicator, toolbar).
- Axis↔CEM map for buttons is 1:1 (`Size`↔ButtonSize, `Type`↔ButtonShape, per-SET `Color`↔ButtonVariant); only `Width` has no code counterpart.
- **Matcher-critical:** color variant is encoded as FIVE sibling sets (`Button`, `Button - text/elevated/outline/tonal`), i.e. set-name↔attribute-value fusion, not a variant axis.
- Delta: 53/121 unique CEM tags matched at name level; 68 CEM-only (~20 real gaps: select, autocomplete, breadcrumb, stepper, tree, paginator…; rest are triggers/infra e.g. ripple). Kit-only true gaps: carousel, time pickers, side sheet, bottom app bar, list-item swipe, 14 XR sets.
- Building blocks: 32 dot-prefixed + 34 non-dot sets; ~half of non-dot have real m3e counterparts (`m3e-button-segment`, `m3e-nav-item`). Icons page: 141 standalone.
- **Icons:** `m3e-icon` takes `name` attr = snake_case Material Symbols name — exactly the names the kit icon components use. `m3e-button` icons are slots (`icon`, `trailing-icon`, `selected-icon`).
- Data-quality: kit has `State=Presssed` typo → fuzzy tier required. CEM: 123 declarations but 121 unique tags (2 dupes).

## ✅ Item 6b — .d.ts inlining coverage (`06b-dts-inlining-coverage.md`)

- elm-cem's inliner replicated against @m3e/web 2.5.14 (505 attrs / 121 elements / 440 .d.ts).
- **72/73 distinct alias names resolve (98.6%).** Only `LinkTarget` rejected — deliberately open (`string & {}`), String fallback is semantically correct.
- Zero enum-ish regex misses that matter; zero alias-of-alias chains; compound forms (`X | undefined`, numeric unions) all resolve.
- 2.5.12→2.5.14: no element changes; +3 boolean `active` attrs on calendar views.
- Verdict: **CEM+.d.ts full-value-space enumeration is proven.**

## ✅ Item 7 — Visual loop feasibility (`07-render-harness/NOTES.md`)

- Code half: @m3e/web renders headless (Playwright Chromium); PNGs **byte-identical across runs** on one machine.
  - Knobs: local Roboto woff2 (m3e inherits host font), DSF 2, omitBackground, reducedMotion+animations disabled, waits = whenDefined→fonts.ready→updateComplete→2×rAF.
  - Gotchas: needs an HTTP server (file:// CORS-blocks modules); needs an esbuild bundle (`@m3e/web/all`, lit/tslib are peerDeps); tokens have baked-in baseline fallbacks (no theme wrapper needed); attr names must come from .d.ts (`m3e-switch` uses `checked`, not `selected`).
- Figma half: bridge `export-png <nodeId>` works per-variant (scale 2), e.g. `btn-57994-2322.png` (Button set, filled, Round/Medium/Enabled).
- Eyeball comparison: same color family/geometry/typography. **Parity requires driving non-variant componentProperties too** (kit default `Show icon=true` renders a leading icon the code side doesn't have) — the diff loop must consume the correspondence table for BOTH variant axes and boolean/text/instance-swap properties.
- Set-level `componentPropertyDefinitions` captured (`kit-props-*.json`): TEXT `Label text#id`, BOOLEAN `Show icon#id`/`Show focus indicator#id`, INSTANCE_SWAP `Icon#id`, VARIANT `Type`/`Size`/`State` (+`Width` on the main set).

## 🔶 Item 3 — fresh-copy key test: PROXY INCONCLUSIVE, direct test redefined

- File key captured: **`KujuFlfJSwHI6ua1b7RZvL`** (user's drafts duplicate of the M3 kit; same file the bridge has open).
- `get_code_connect_map` on the user's duplicate: **empty** for Button set/variant (57994:2227/2322), Checkboxes (51859:5628), Filter chip (53923:28270).
- Control: ADS (`cbhz1J779WAI7gYkjCQwS0`, org-workspace copy) resolves the managed `@mui/material/Button` mapping on 100+ nodes — key-based resolution itself is real.
- Hypotheses for the emptiness: (a) managed UI-kit mappings don't apply to personal-drafts files (ADS is in the org workspace); (b) the current kit's components were re-keyed by kit rebuilds (e.g. V1.21+ Expressive button rebuild) so Figma's managed map targets stale keys. Checkbox/chips being empty too weakens (b)-only.
- **Consequence:** don't rely on the managed-MUI proxy. The property that matters — publish-by-key inheritance — will be tested DIRECTLY: publish our own label on the user's copy → verify it resolves there → duplicate the file fresh → verify the same mapping resolves on the duplicate without republishing.
- Cheap side-experiment if user is willing: move the duplicate from drafts into a team project and re-probe the managed layer (settles hypothesis (a) for the plan's consumption docs).

## ✅ Item 1 — PUBLISH GATE PASSED (2026-07-10)

- `figma connect publish` (dry-run AND real) succeeded from the user's Avetta Dev seat against his DRAFTS copy `KujuFlfJSwHI6ua1b7RZvL`, token via `FIGMA_ACCESS_TOKEN`. Scratch project: `verify/01-publish-gate/` (parser "html", label "Web Components", `M3eButton.figma.ts` bound to Button set 57994:2227).
- `get_code_connect_map` resolves the published mapping with **per-variant evaluated templates**: each variant node returns correct `size`/`shape` values from the `getEnum` maps; `getString("Label text")` pulled the TEXT property default. Names with spaces + `#id` suffixes work via plain name ("Label text").
- Resolution also appeared on `58651:12xxx` nodes not directly published against (key-based resolution catching related variants) — favorable.

## ✅ Item 2 — MULTI-LABEL COEXISTENCE PROVEN

- Second publish with label "Elm" (`verify/02-elm-label/`, same node URL): both labels now resolve on the SAME node, filtered via `codeConnectLabel`. Elm snippet is the `M3e.Button.view` pipeline with per-variant tokens (`M3e.Token.md`, `M3e.Token.rounded`).

## ✅ Item 4 — TAILWIND SHAPE (read-only half) ANSWERED

- `get_design_context` on a FRAME (Examples/Messaging-Mobile 56615:46684): React+Tailwind output; **Figma variable names flow into CSS custom properties** (`var(--schemes\/on-surface,#1d1b20)`, `var(--static\/title-large\/size,22px)`); **spacing is hard px** (`px-[24px]`, `gap-[8px]`) — no spacing tokens exist to reference. Component descriptions + m3.material.io links ride along.
- `get_design_context` on a BOUND node (57994:2322): returns `import M3e.Button` + the Elm snippet inside `<CodeConnectSnippet data-snippet-language="Elm">`, replacing raw markup entirely. Hybrid mechanism = bound instances as our code + unbound context as Tailwind-with-Figma-var-names. (When multiple labels exist, response carried the Elm one; label-selection behavior in design-context TBD.)
- Remaining (mutation half, needs throwaway duplicate + bridge session on it): does `setVariableCodeSyntax("WEB", "var(--md-sys-color-…)")` change the names `get_design_context` emits?

## ✅ Item 3 — FRESH-COPY TEST: DECISIVE NEGATIVE (2026-07-10)

- User duplicated the kit → `iPFL8MH2R1Xphe94j7g809`. Our published mappings do NOT resolve there (empty with and without label filter).
- Root cause proven via bridge key comparison: **duplication mints new component keys** (Button set `4a813eda…` → `ff1de0e4…`). Node IDs ARE preserved (57994:2227 exists in both).
- Retro-explains the empty managed-MUI probe on the user's first duplicate.
- **Plan consequence:** "bind once, drafts copies inherit" is dead. The model is **per-copy republish** — node-id stability makes it a single parameterized CLI run (swap fileKey). The "publish once" story that remains viable is *published-library instances* (consumer files using library components reference the library's keys) — to be exercised in the Avetta phase. ADS's managed-MUI inheritance likely stems from a key-preserving copy mechanism (not drafts-duplicate); irrelevant to our model since we publish per-fileKey anyway.

## ✅ Item 4 — TAILWIND SHAPE: FULLY ANSWERED

- Mutation half (on throwaway Copy, via `use_figma` — **no custom plugin needed for codeSyntax writes**): stamped `WEB` codeSyntax (`var(--md-sys-color-*)`) onto 7 Schemes variables → `get_design_context` immediately emits `var(--md-sys-color-secondary-container,#e8def8)` etc., while untouched variables keep `--static/body-large/*` slugs.
- **Verdict: variable codeSyntax controls the vocabulary of ALL MCP-generated layout code.** The Tailwind leg = token correspondence table → codeSyntax stamping pass (use_figma script) + Code Connect labels for components. Hybrid output falls out: bound instances arrive as snippets, layout arrives speaking `--md-sys-*`.
- codeSyntax stamps left in place on the Copy as a demo.

## Cleanup performed

- Both spike labels unpublished from `KujuFlfJSwHI6ua1b7RZvL` (`figma connect unpublish`, confirmed deleted). Scratch projects kept in `verify/01-publish-gate/` + `verify/02-elm-label/` for instant republish.
- Token stored at `verify/.figma-token` (chmod 600). ⚠️ Token was pasted in chat — recommend rotation after the project's publish tooling stabilizes.

## ⏳ Remaining — blocked on user

1. **Publish gate** (existential): `figma connect publish --dry-run` + one real publish against the user's kit copy. Needs: kit-copy URL (also yields the file key) + `FIGMA_ACCESS_TOKEN` (File content + Code Connect write).
2. **Multi-label coexistence**: publish "Web Components" + "Elm" labels on one component key; verify via `get_code_connect_map` alongside managed MUI React layer.
3. **Fresh-copy key test**: throwaway duplicate of the kit; check managed MUI mapping resolves there (key preservation).
4. **Tailwind shape probe**: `get_design_context` on a frame containing bound components; `setVariableCodeSyntax` on a handful of variables in the THROWAWAY copy; observe emitted layout code.

Authorized write scope (user, 2026-07-10): CC publishes on primary copy (unpublish after); throwaway duplicate is the mutation playground; local work in scratchpad only.

## Decision ledger (from the grill, 2026-07-10)

1. Spike `elm-m3e-figma-code-connect-design.md` = input only; plan re-derives architecture.
2. Align to canonical M3 kit via component keys; first publish = user's unmodified personal copy; decoupled customization/delta mechanism required.
3. Deliverable = complete start-to-finish plan in markdown; verify uncertain claims during planning; no half-steps.
4. Snippets: web component always preferred; Tailwind = layout scaffolding only; Tailwind leg shape decided by item-4 evidence.
5. Elm label surface: configurable, top `M3e.*` default.
6. Gaps: logged as first-class report; no Figma authoring.
7. Match scope: all sets incl. Building Blocks AND the 141 icons.
8. Visual diff = gate for auto-binds; review webapp in scope; WC renders cover all layers.
9. Engine = new private repo `jackhp95/cem-figma-connect` (general CEM+Figma tool); vendors a generalized plugin fork (IP provenance flagged); dump checked in; plans live in this repo, created plans-first (review-2026-07 plan shape; subagent-driven execution; herdr parallelizable).
10. Plan assumes post-review-2026-07 elm-cem/elm-m3e (M3e.Html/Raw/Token; Loose/Record/Build; rules in elm-review-cem; examples-gen shared harness).
11. matraic/m3e upstream PR = follow-up reminder, not a plan phase.
12. Avetta = in-plan second consumer. Endgame: Figma integration for future stack = avetta/ui main + Tailwind v4 + elm-m3e + minor Material branding tweaks; branding deviations must be representable in Figma and code.
13. elm-m3e registry release out of scope (snippets are strings).
