# Plan E — breadth triage (2026-07-13)

## Decisions resolved (2026-07-13, user)
- **Composites/shells (RC3, was ⚑#1)**: NO synthetic content. Work **atoms-up** —
  support every sub-component first, then composites render from the REAL
  sub-components (list←list-item, tabs←tab, segmented-button←buttons,
  fab-menu←fab, menu←menu-item, split-button←buttons). Keep 100% real. Defer
  composites until their atoms pass.
- **Standalone (RC4)**: YES — add single-node render path, no axis driving
  (rich-tooltip, shape).
- **m3e-shape**: REAL Code Connect target (publishable).
- **fab `Size=Default`**: map `Default` → NO size attr (component's own default).
- Still open items → **RESOLVED 2026-07-14** (below).

## Decisions resolved (2026-07-14, user)
- **assist-chip branded icon**: **OMIT** it — the default `Branded icon` is a brand logo, not a
  Material Symbol; don't force it into the 141-icon Symbol table. Gate/bank the rest of assist-chip.
- **checkbox multi-attr axis**: build a real **codegen capability** — one Figma axis → MULTIPLE
  CEM attrs (`Type` → `checked` + `indeterminate`). NO hand-authored override ("we're building a
  codegen tool; manual fixes are antithetical"). Schema + matcher + drive + emit all learn it.
- **app-bar/toolbar shell content (RC3) — CORRECTS "no synthetic content"**: the rule is no fake
  *components*. Non-component **example content** (a title string, static markup) IS fine — and is
  the most faithful output. Inject representative content: real sub-components in their slots (via
  the declarative/nestedProps path) + non-component example content (text) for baked-in bits.
- **composite declarative-emit-mode**: build atoms FIRST, then refactor the emit internals so the
  SAME atom code serves both standalone and slotted placement (shared internals → no drift; the
  ancestor owning the slot is invisible to the end user). Defer the declarative mode until atoms
  are banked, then build it.
- **Gate threshold (2026-07-14 Q1)**: TIERED — pixel-exact **0.02** for icon/shape-only
  components; relaxed **~0.10** for TEXT-BEARING components (cross-renderer font AA benignly
  exceeds 0.02 while renders are visually identical). Lets text components (badge, chips, snackbar,
  checkbox, search-bar) auto-pass + bank.
- **Un-pixel-matchable (2026-07-14 Q2)**: **SKIP for now** — app-bar, toolbar, rich-tooltip (baked
  Figma sub-layer content, not in the dump) + the 6 composites (need declarative mode). Structural-only
  mode NOT built. Finish the pixel-matchable set only; revisit these later. Supersedes the "build
  declarative mode" step for this pass.

## BANKED so far (2026-07-14, autonomous session) — do NOT redo
Confirmed + emit-clean on BOTH surfaces (web-components + Elm), gate-verified:
**m3e-button** (prior), **m3e-list-item** (0.006), **m3e-shape** (0.000),
**m3e-switch** (0.000/0.000, RC1 boolean-axis). Elm boolean-axis branch now
unit-tested. NOT published (needs an org/enterprise Figma account). The ~21
remaining matched components are blocked THIS session on: (a) the **pixel gate**
— needs the Figma-desktop plugin running + a read token (bridge down); (b) **open
decisions** (assist-chip branded icon, checkbox multi-attr override, app-bar/
toolbar shell, named-slot composites → new declarative emit mode). See
`plans/AUTONOMOUS-SESSION-FRICTIONS.md` (AF-01/AF-02). Landscape below is unchanged.

## Session progress (2026-07-14, live bridge cem-7e8c65)
BANKED (gate-passed + confirmed): button, list-item, shape, switch, **icon-button** (RC2
default-slot icon, ≤0.0008). Driver infra landed (standalone path, null→omit-attr, displayNameOf
`#` fix). NOT banked — need more: **fab** (0.48 render mismatch — color/icon/variant, needs
investigation), **rich-tooltip** + **snackbar** (render EMPTY as bare tags → need representative
content injection, decision #3). Finding: most remaining shells/chips render empty without
content — **content-injection is the pivotal next capability**.

Per-component work breakdown for publishing all matched m3-kit components (not
just the m3e-button tracer). Produced from the first full visual-gate landscape
run against the live 171-set dump. **The gate is the verification**: a component
whose code render (driven by its mapping) pixel-matches its Figma variant has a
correct binding.

## What's proven / done (do NOT redo)
- **Infrastructure end-to-end**: A3-live extraction (real dump + kitVersionTag),
  render harness, correspondence-driven state driver, native-2x Figma export
  (plugin `constraint` fix), diff pipeline (trim + gated scale-normalize),
  review webapp, publish runner. All committed on `main`.
- **Profile now targets the live dump** (`figmaExportPath` → `research/figma-dumps/`,
  `fileKey UtwpUdPiOZEuxp8Nq1d5yQ`), re-matched so all 25 entries carry real axes.
- **m3e-button**: confirmed + human-gate-approved (8/10 states pixel-pass;
  elevated=clipped-shadow, xsmall=proportion — both benign). Publish-ready
  EXCEPT the cross-cutting emit-side icon fix (below) + a fresh PAT.
- **Scope reality**: the publishable universe is **25 matched components** (both a
  code element and a Figma set). ~95 CEM tags are code-only; 235 Figma sets have
  no code. Everything below is those 25.

## Landscape (25 matched, default-state gate)
- **✅ pass (3)**: `m3e-button` (0.000, approved), `m3e-list-item` (0.006), `m3e-shape` (0.000)
- **🟡 small diff (5)**: `badge` 0.05, `filter-chip` 0.11, `suggestion-chip` 0.12, `input-chip` 0.13, `loading-indicator` 0.24
- **🔴 big diff (7)**: `icon-button` 0.59, `bottom-sheet` 0.62, `search-bar` 0.77, `switch` 0.78, `toolbar` 0.85, `checkbox` 0.94, `app-bar` 0.99
- **⛔ driver/data error (4)**: `assist-chip`, `fab`, `snackbar`, `rich-tooltip`
- **⏱ composite render-timeout (6)**: `fab-menu`, `list`, `menu`, `segmented-button`, `split-button`, `tabs`

## Cross-cutting (do these once, they unblock many)
1. **Emit-side icon resolution** (blocks ALL publishes, incl. button). Published
   `.figma.ts` resolves the icon via raw `instance.getPropertyValue("Icon")` (not
   a Material Symbols ligature). Touches `src/emit/run.mjs` (thread iconTable),
   `html-label.mjs` (`buildSlotBooleanBlock`, line ~174-181), `elm.mjs`.
   **DECIDED (2026-07-14, spike-first analysis): approach A — inline `getEnum`.**
   - The parent OWNS the slotted tag and binds the glyph via a per-file enum:
     `const glyph = instance.getEnum("Icon", { <figmaName>: \`name="<symbol>"[ filled]\`, …141 })`
     then `<m3e-icon slot="icon" ${glyph}></m3e-icon>`. Keys = iconTable
     `figmaName`; values carry `symbolName` (+ ` filled` when the row's `filled`).
   - **Approach B (`getInstanceSwap` + nested icon CC) was REJECTED** — proven
     unworkable OFFLINE (no PAT spent): Code Connect nesting inserts the child's
     FULL self-contained render into a content position (`getInstanceSwap()?.
     executeTemplate().example`) with NO attribute injection / no attr-merge
     (`html/parser.js` throws on duplicate attrs). So a nested `<m3e-icon>` can
     never carry the parent's `slot="icon"`, and button/chip/app-bar icons live
     in NAMED slots. A wrapper (`<span slot="icon">…`) breaks `::slotted(m3e-icon)`
     styling + is non-idiomatic. Shared-map import to dedupe the 141 is ALSO
     impossible in CC 1.4.9 (`assertOnlyFigmaImports`: templates import only
     `figma`; "other module imports … future version"). So the 141-enum inlines
     per icon-bearing file — generated + deterministic, byte bloat not maint debt.
   - Key nuance for B-later: nesting works fine for DEFAULT slots — the atoms-up
     composite plan (list←list-item, tabs←tab, menu←menu-item, segmented-button)
     is UNAFFECTED. Only NAMED-slot placement (icons) needs the parent to own the
     tag. B stays viable only for standalone bare-icon CC (default-slot usage).
   - Offline step-1 CONFIRMED the swap targets ARE iconTable nodes: button `Icon`
     prop `defaultValue "54616:25409"` == iconTable `stars_filled` (symbolName
     `stars`, filled true); `preferredValues: []` (no hard restriction).
   - Still TODO on A: implement (TDD via `html-label.test.mjs`), regen `generated/`,
     then LIVE-verify one published file via `get_code_connect_map` (fresh PAT).
2. **Variant-controlled slot visibility** (blocks the chip family + likely more).
   Chips have NO `Show icon` boolean; icon presence is driven by the
   `Configuration` VARIANT (`Label only` / `With leading icon` / …). The model
   only understands boolean-gated slots (button's `Show icon`), so it renders the
   default instanceSwap icon even when the sampled variant is `Label only` →
   false diff. Needs: map variant values → which slots they show, and drive the
   code side to match. Affects `filter-chip`, `input-chip`, `suggestion-chip`,
   `assist-chip` (4).
3. **render-cache test footgun** (quality-of-life). `status.test.mjs` /
   `publish-check.test.mjs` read the real `render-cache/results/`; any local gate
   run makes them fail spuriously. Isolate those assertions from the working
   render-cache (e.g. inject an empty resultsDir) so Plan-E gate runs don't
   redden the suite. Non-blocking.

## Per-component work items
### Ready (verify + confirm + publish)
- **badge** — benign diff (red "3" both sides). Ready for human gate-review → confirm → publish.
- **list-item**, **shape** — auto-pass. `shape` ⚑ AMBIGUOUS: is it a real Code
  Connect target or a design-token/utility? (user decision).

### Chip family (do cross-cutting #2 first)
- **filter-chip / input-chip / suggestion-chip** — Configuration→slot-visibility.
- **assist-chip** — same, PLUS its `Branded icon` default instance isn't in the
  141-icon iconTable (brand/logo glyph, not a Material Symbol) → iconTable
  coverage or a fallback.

### Driver/data fixes (mechanical, per-component)
- **fab** — Figma `Size=Default` has no CEM valueMap entry (fab size enum lacks
  `Default`). Decide the mapping (`Default`→? or exclude that axis value).
- **snackbar** — sampled axis `# of lines` not in the entry's mapped axes
  (mismatch between sample + correspondence axes). Reconcile.
- **rich-tooltip** — the matched Figma node has no captured setProperties in the
  dump (it's a `standalone` match, not a set). Confirm the match target; may need
  a different node or is a false match.

### Big-diff investigations (render vs Figma; likely wrong node OR real render gap)
- **icon-button** 0.59, **bottom-sheet** 0.62, **search-bar** 0.77, **switch**
  0.78, **toolbar** 0.85, **checkbox** 0.94, **app-bar** 0.99. Each needs a
  code-vs-Figma eyeball: is the driver picking the wrong variant node, does the
  component render differently (e.g. switch/checkbox default state), or is it a
  false match? Bring screenshots to the user where the match looks questionable.
  (app-bar/toolbar near-total mismatch → most suspect; switch/checkbox → likely a
  default-state issue, e.g. off vs on.)

### Composite components (DEFERRED per user — do after the above)
- `fab-menu`, `list`, `menu`, `segmented-button`, `split-button`, `tabs` — render
  empty (no visible size) → timeout. Need representative example children to
  render + gate, OR a structural (non-pixel) publish, OR skip. ⚑ user decision on approach.

## Suggested sequencing
1. Cross-cutting #1 (emit-side icon) — unblocks button publish + all icon components.
2. `badge` → confirm + publish (first breadth binding beyond button).
3. Cross-cutting #2 (chip Configuration modeling) → 4 chips.
4. Driver/data fixes (fab, snackbar, rich-tooltip) — mechanical.
5. Big-diff investigations — triage false-matches vs real render gaps.
6. Composites — after the user picks an approach.
7. Cross-cutting #3 (test footgun) — whenever it gets annoying.

Each is an atomic unit: investigate → fix/confirm → gate → (human verify) →
commit. The gate result is the pass/fail signal; the human verifies borderline
diffs in the review webapp.

---

## Diagnosis (2026-07-13, sonnet-agent investigation)

Every big-diff is a **correct match** (right Figma node, no false positives). The
failures cluster into ~6 root causes; several are systemic (one fix → many
components):

**RC1 — matcher only maps ENUM CEM attrs to axes, never BOOLEAN** (`matcher.mjs`
`enumAttributes()`/`proposeAxis()`). So boolean-controlled axes go `unmapped`, the
code stays at its HTML default, and the sampler picked the *other* Figma default →
big diff. NOT rendering bugs.
- `switch` (0.78): `Selected` axis → `checked` boolean; clean 2/2. **Fix: teach the matcher to consider boolean attrs as 2-option axes.** Should pass after.
- `bottom-sheet` `Modal` → `modal` boolean (same gap).
- `checkbox` (0.94): `Type` (6 options) needs a COMPOSITE map (Selected→`checked`, Indeterminate→`indeterminate`); boolean-matcher alone is 2/6=0.33 < the 0.6 gate → **human override** (schema can't do multi-attr axes).

**RC2 — content/icon props wrongly marked `unmapped`** (should bind to slots):
- `icon-button` (0.59): `Icon` instanceSwap → should map to the **default (unnamed) slot** via the iconTable (same mechanism as button, but unnamed slot). Cleanest RC2 fix.
- `app-bar` (0.99): `Image`/`Show Nth trailing action` → slots (mechanical), BUT the "Label" title is baked-in Figma example content, not a componentProperty (see RC3).
- `search-bar` (0.77): `Placeholder text` is bound to `content` but m3e-search-bar has NO default slot — only `leading`/`input`/`trailing`; should bind `slot:input`. `Show * icon` booleans gate FIXED (non-swap) icons → schema gap (RC5).
- `bottom-sheet` (0.62): ALSO `open` never driven → mounts closed → blank (code-wrong-default-state). Pin `open`=true; map `handle` boolean, `Modal`→`modal`.

**RC3 — shell/container components need synthetic content or structural-only
comparison** (⚑ USER DECISION #1, same as composites): `app-bar`, `toolbar`
(+ the 6 composites). Their Figma masters show baked-in example content
(title/icons/children) unreachable via componentProperties. Either inject
representative default slot content on the code side, or exclude from strict
pixel diffing (structural-only). `toolbar` also needs RC5 (`kind:"slot"` handler).

**RC4 — standalone components (no setProperties, can't be axis-driven)**:
`rich-tooltip` (COMPONENT "Rich Tooltip", not a SET), likely `shape` too. Driver
needs a **standalone path**: render the single node, no axis driving.

**RC5 — harness/schema gaps**:
- `drive.mjs` has no `kind:"slot"` case (toolbar's `Content (standard)` SLOT prop).
- `page.mjs` needs an `<input>` slot builder (search-bar `slot:input` w/ placeholder).
- verify empty-name slot (`slot=""`) lands in the default slot (icon-button).
- boolean-gated FIXED (non-swappable) icon convention (search-bar menu/search icons) — ⚑ needs a schema decision (literal icon name field).

**RC6 — driver/data value gaps**:
- `fab`: Figma `Size=Default` (the standard FAB) has no valueMap entry; @m3e/web fab has no "default" size → map `Default`→(no size attr) ⚑ decision.
- `snackbar`: all 3 axes have `figmaAxis: null` (fully-unmapped) → sampler/validator mismatch; needs the matcher to still name unmapped axes.
- `assist-chip`: default `Branded icon` = `.Building Blocks/Colourful logo` (brand logo, not a Material Symbol) → branded-icon handling + RC-chips (Configuration).

**High-leverage fix order:** RC1 matcher boolean-axis (→ switch + bottom-sheet-modal
+ groundwork) → RC2 icon-button (clean) → chips Configuration modeling → RC5 harness
gaps → RC3/RC4 (need decisions). Scratch diagnosis PNGs were under /tmp/*-diag/.
