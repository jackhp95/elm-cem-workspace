# Mission: A Unified CEM ⋈ Figma ⋈ Tailwind Merge that Auto-Generates Figma Code Connect for @m3e/web (web components, Elm, and Tailwind)

> **Status:** Vision / mission brief for a hand-off. Authored 2026-07-10.
> **Audience:** the next agent — you will own **all** research, architecture decisions, implementation
> planning, phasing, and sequencing. This document deliberately does **not** prescribe scope, order, or
> a phase breakdown. It gives you the *complete* vision, the rationale behind it, the concrete resources,
> the prior art, and the frictions already discovered so you don't retrace them. **Spare no detail when
> you plan — every corner cut here costs everyone downstream.**
>
> **Provenance note (cem-figma-connect):** this file originally lived at
> `~/code/jackhp95/elm-m3e/docs/FIGMA-CODE-CONNECT-UNIFIED-MERGE.md` (untracked) and was deleted from
> there during the review-2026-07 cleanup; restored verbatim into this repo on 2026-07-10. Where this
> brief conflicts with `00-mission-and-decisions.md`, the latter wins (it postdates verification).

---

## 0. How to read this document

You are being handed a broad, multi-repo initiative. Your job is to:

1. **Absorb the full vision** (this doc, end to end) and the resources it points at.
2. **Investigate** the real schemas/configs/manifests in the referenced repos — verify every assumption
   here against ground truth (this brief was written from exploration, but you must confirm).
3. **Produce the research + implementation plan(s)** — the architecture, the algorithm, the phasing, the
   correspondence-table format, the verification harness, the token model. Own the breakdown yourself.
4. Expect your planning documents to be handed to *yet another* agent to implement. Write them to be
   executed by someone without this conversation in their context.

Where this brief says "my recommendation" or "suggested," treat it as a *strong prior from the person who
scoped this*, **not a hard gate**. If deeper investigation says otherwise, choose what's right and explain why.

---

## 1. The one-sentence mission

**Merge three (arguably four) discrete data structures — the `@m3e/web` Custom Elements Manifest (CEM),
the Figma UI-kit component/variant/token graph, and the Tailwind config's full class space — into a single
coherent model, and from that model *automatically generate* Figma Code Connect definitions for the web
components, for the Elm (`M3e.*`) layer, and for the Tailwind layer — reducing human effort to answering a
small number of high-level correspondence questions instead of hand-authoring thousands of bindings.**

Everything else in this document is detail in service of that sentence.

## 2. Why — the payoff

Today, when a developer uses Figma-generated code, **no component relationship is preserved**: they copy
CSS/HTML and hand-convert. The design is visually similar but structurally disconnected from the design
system. Figma **Code Connect** fixes this — it binds a Figma component to the *real* code component, so
Figma's MCP / Dev Mode hands the developer the exact code snippet to use. We want that binding to exist for
`@m3e/web` at three levels, generated from one merge:

- **Web components** — `<m3e-button variant="filled">…` etc. (the foundation; the others render through it).
- **Elm** — the `M3e.*` typed API, so a designer-referenced component yields exact Elm to start building.
- **Tailwind** — the `tailwind-m3e-web` utility/token surface, so you can ask for the Tailwind form too.

Once the merge exists, these outputs (and more) **fall out of it**:

- Figma Code Connect for the web components.
- Figma Code Connect for the Elm modules.
- Figma Code Connect for the Tailwind classes.
- **Hybrid outputs**: "give me the Elm *and* the Tailwind for this component" → the pipeline returns the most
  design-faithful combination automatically, with tokens resolved at the correct level (see §9).

The deeper win: once we express the relationship between these schemas as a **repeatable algorithm**, we stop
doing thousands of manual translations and only answer the *high-level* questions a human is actually needed
for ("the Buttons page corresponds to `m3e-button`"; "Figma calls this token X, Tailwind calls it Y, they're
the same thing"). The algorithm handles the rest and *surfaces* the cases that are genuine discrepancies.

## 3. The players — repos and their roles

All under `~/code` unless noted. (Verify versions/paths; they drift.)

| Repo | Owner | Role in this mission |
|---|---|---|
| **`matraic/m3e`** (GitHub) | not us | Upstream `@m3e/web` — Material 3 **Expressive** web components. **Final home** for the CEM ⋈ Figma Code Connect work (upstream a PR). |
| `~/code/forks/m3e-upstream` | fork | Local fork of the above. |
| **`jackhp95/elm-m3e`** | us | The curated, phantom-typed `M3e.*` Elm layer over `@m3e/web` ("Make-Impossible-States-Impossible", introspectable IR). **Interim host** for the CEM⋈Figma Code Connect work until `matraic/m3e` accepts it, **and** the host for the Elm⋈Figma Code Connect. **This doc lives here.** |
| **`jackhp95/tailwind-m3e-web`** | us | Tailwind v4 utility surface for `@m3e/web`. **Final home** for the Figma Code Connect ⋈ Tailwind work. |
| `jackhp95/elm-cem-m3e` | us | *Generated* `Cem.M3e.*` Elm atoms, produced by `elm-cem` from the CEM. |
| `jackhp95/elm-cem` / `elm-cem-decoder` / `elm-cem-template` | us | The modular CEM→Elm toolchain: decode CEM JSON→Elm types; generate `Cem.<Lib>.*` bindings; scaffold a bindings package. (These were split out of the archived `jackhp95/elm-custom-elements-manifest` monorepo, which still holds reference CEMs for 9 libraries.) |
| `jackhp95/m3e-builder` | us | Elm application workspace around the m3e layer. |
| `jackhp95/m3e-docs` | us | Generates a verified Claude Code skill for `@m3e/web`. |
| `jackhp95/gren-m3e` | us | Gren port (peripheral). |
| **`avetta/ui.VOLT-2003`** | Avetta | **Prior art** — already has a *working* Elm→Figma Code Connect generator (see §11). Different driver (`Ui.*` via elm-review) and different Figma target, but the mechanics are proven here. |
| `avetta/akg-synapse` | Avetta | Knowledge graph; has curated nodes on the Figma substrate, the plugin, and prior code-connect research (see §15). |
| **`dillonkearns/elm-tailwind-classes-demo`** (GitHub) | Dillon Kearns | Reference for the Tailwind-completeness mechanism — consumes **`elm-tailwind-modules`**, which reads a Tailwind config and generates the *entire* type-safe class surface as Elm. This is the model for "know all *possible* variations, not just the ones someone drew." |

## 4. The data sources and their shapes

### 4.1 The CEM — `@m3e/web` custom-elements.json (the completeness spine)
- Location (any of the pnpm copies): e.g. `jackhp95/elm-cem-m3e/node_modules/@m3e/web/dist/custom-elements.json`.
  Version observed: **@m3e/web 2.5.12**, CEM `schemaVersion 1.0.0`, **439 modules**, **123 real custom elements**
  (`tagName != null`). (Copies range 2.5.7–2.5.14 across repos — pin one.)
- Shape: each custom element declaration carries `tagName`, `attributes[]`, `members[]`, `cssProperties[]`,
  `slots[]`, `events[]`. Attributes have a `type.text` — often a **named union type** (e.g. attribute
  `orientation: "CollapsibleOrientation"`), whose member value-set is defined in a *separate* type declaration.
- **Critical for completeness:** to enumerate an attribute's full value space you must **resolve the named
  type to its union members**, not just read `type.text`. The CEM is the only source that defines the *full*
  component + attribute + value surface — i.e. what's *possible*, independent of what anyone drew in Figma.

### 4.2 The Figma UI kit — Material 3 Design Kit (Community) (actuality + tokens + node keys)
- **Chosen target** (see §13): the **"Material 3 Design Kit (Community)"** file — the canonical/public M3 kit,
  the clean pairing for `@m3e/web` (generic, decoupled from Avetta's internal ADS customizations, so the
  algorithm stays reusable and could later be re-pointed at the ADS catalog).
- What we extracted this session (via the private plugin — see §10): **5,770 component nodes** = **171
  component *sets*** (variant families = the real DS components) + **245 standalone** components (of which
  **141 are icons**) + **5,354 variants**, across **33 pages** (one per component family).
  - ~**60 of the 171 sets are `.Building Blocks/…`** — *internal composition parts* (nav items, list content,
    snackbar-action, progress segments), **not** things you'd drop on a canvas. The plan must separate
    **public components** from Building Blocks.
  - Each variant COMPONENT node encodes its variant properties in its **name** as `Property=Value` pairs. The
    component-set is the family; its children are the materialized variant combinations.
  - Nodes carry `id`, `name`, `type` (COMPONENT / COMPONENT_SET), `key`, `description`, `page`. The **`key`**
    is what Code Connect binds to; the node URL (`?node-id=…`) is what a `.figma.ts` file points at.
- **Tokens/variables:** the M3 token system lives in Figma *variables* (collections/modes/values) and *styles*
  (paint/text/effect/grid). ⚠️ In the sibling ADS dump, **0 variables carried `codeSyntax`** — i.e. the Figma
  side does *not* embed the code binding for tokens; the actual token↔code binding lives in Code Connect
  published data (`get_code_connect_map`) and the code repos. Assume the same here and verify.

### 4.3 The Tailwind config → full class space (the styling-completeness leg)
- `jackhp95/tailwind-m3e-web` (Tailwind v4). The completeness mechanism to study is **`elm-tailwind-modules`**
  (see `dillonkearns/elm-tailwind-classes-demo`): read the Tailwind **config** and enumerate the *complete*
  set of possible utility classes — the same "all possibilities, not just what's grepped/drawn" property the
  CEM gives the component layer. Tailwind v4's config model differs from v3 (CSS-first `@theme`); confirm how
  to enumerate the full surface under v4.

### 4.4 `elm-m3e`'s introspectable IR (a pre-existing candidate model)
- `elm-m3e` already exposes an **introspectable IR** and phantom-typed slots. Consider reusing it as the
  unified model rather than inventing a rival IR (see §5).

## 5. The unified model — a strong suggestion, yours to revise

The person scoping this favors **(A) CEM as the structural spine, with per-concern resolution priority** —
but explicitly wants you to **investigate and choose** what's right after you understand the schemas:

- **CEM is the spine** — it defines the complete, enumerable component/attribute/value space (§4.1). It answers
  "what *can* exist."
- **Figma attaches as a binding** — it supplies node `key`s + URLs (for the Code Connect files) and the
  *materialized* variant names, and it is **authoritative for design tokens and visual intent**.
- **Tailwind attaches as a styling projection** — utility/token surface, its own completeness via config.
- **Resolution priority is per-concern, not global:** CEM wins on *component API/props*; Figma wins on
  *design tokens & visual truth*; Tailwind is *derived*. This scopes "Figma should be the most correct" to
  the concern where it actually is (design), while keeping code authoritative for the API surface.

Alternatives you should weigh and reject/accept with reasons: **(B)** a fresh source-agnostic canonical IR all
three map into (more neutral, but risks competing with `elm-m3e`'s existing IR); **(C)** Figma as the spine
(loses enumerability — Figma only has materialized variants).

## 6. The deliverable layers (what "falls out" of the merge)

The scoping conversation identified these layers and their homes. **You decide how/when to build them.**

- **Layer 1 — `@m3e/web` (CEM) ⋈ Figma → Code Connect (web components).** The foundation; the others render
  through the same DOM. **Upstream home:** `matraic/m3e` (PR). **Interim host until accepted:** `elm-m3e`.
- **Layer 2a — Figma Code Connect ⋈ Tailwind.** **Home:** `tailwind-m3e-web`. Ensures the tokens we define
  correspond to the Figma representation; enables the token-level correctness of §9.
- **Layer 2b — Elm ⋈ Figma Code Connect.** *Derived* from Layer 1: run the `@m3e/web` HTML through the
  **html→elm pipeline**, emit the **elm-review-configured default with reasonable fallbacks**. **Home:**
  `elm-m3e`. (Largely mechanical once Layer 1 exists.)
- **Hybrid outputs** — combine Elm + Tailwind for a component into the most design-friendly result, tokens at
  the correct level (§9).

## 7. The matching algorithm — the crux (approach agreed, details yours)

**Goal:** bind each CEM component/attribute to its Figma component/variant-property, automatically where
confident, and surface only high-level ambiguities to a human.

1. **Normalize both sides to a canonical slug**, then match **identity first, then properties**:
   - CEM: `tagName` (`m3e-button`) + declared `attributes`/`members`/`cssProperties`.
   - Figma: component-set name + variant properties (parsed from `Property=Value` variant names).
   - Strip noise: `m3e-` prefix, `.Building Blocks/`, case/kebab/space differences.
2. **Confidence tiers:** exact normalized match → **auto-bind**; fuzzy → **propose**; none → **flag as gap**
   (Expressive-only-in-code, or Figma-only). Fuzzy lever: M3/ADS components often carry **keyword-synonym
   descriptions** (e.g. `check_box → "approved, box, check, control, form…"`) — a strong matching signal.
3. **Human-in-the-loop at the high level only.** Emit a **correspondence table**
   (`CEM entity ↔ Figma entity ↔ confidence ↔ rationale`). The human reviews/overrides at the *component +
   property* level, never per-variant. **Overrides persist in a checked-in mapping file** so re-runs are
   deterministic and manual answers are never re-typed.
4. **Completeness inversion (the key idea).** Figma contains only *materialized* variants (what was drawn).
   The CEM defines each attribute's **type** → resolve its union members → the *full* possible variant space is
   the cartesian product. So **variant enumeration is driven from the CEM** (and, for utilities, from the
   Tailwind config à la `elm-tailwind-modules`); **Figma is used only to bind the combinations that exist**;
   unmaterialized combinations are logged as "valid-but-undrawn" or genuine gaps. This inverts Figma's
   grep-limited view into a complete one.

## 8. The visual verification loop (a first-class part of the plan)

Name-matching says two things share a label; **only pixels prove they're the same component.** Build a loop:

1. **Render the Figma side** to an image: the private plugin's WS bridge exposes `export-png <nodeId>`
   (working this session) — rasterize any component/variant node.
2. **Render the code side** with **Playwright**: mount the actual `@m3e/web` custom element (and/or the Elm /
   Tailwind render, which bottoms out in the same web-component DOM), driven to the *same* variant/state, and
   screenshot it.
3. **Diff** with Playwright's built-in visual comparison (`expect(page).toHaveScreenshot()`), perceptual
   threshold. **Exact/near-exact → auto-approve silently; only above-threshold diffs surface** to a local
   **human-in-the-loop review web page** that shows the two images + the diff, lets the human describe the
   problem, and feeds it back so the agent iterates the mapping/generator.
4. This cleanly separates the two failure classes the scoper cares about: **naming discrepancies** (visually
   fine, matched by other signals) vs **spec failures** (visually wrong — Figma likely the more-correct
   source; may require changing our lingo/tokens/sizing to conform — see §9).

**Caveats to design around (not blockers):** raster-vs-DOM is never pixel-exact (fonts, anti-aliasing,
sub-pixel, DPI, background) → normalize render conditions (fixed viewport/scale, transparent background,
pinned fonts, matched **density** state) and use a perceptual threshold. Both sides must be driven to the same
variant/state → the visual loop is coupled to the correspondence table (§7).

## 9. Tokens — the other hard half (Material's layered, density-sensitive model)

Tokens are as nuanced as components, and are where the three vocabularies diverge most ("token" means slightly
different things in Figma, in Tailwind, and in code). Requirements:

- **Emit tokens at the correct layer.** Material describes three tiers: **reference** (raw hex/primitives) →
  **system** (semantic roles) → **component** (component-scoped). Prefer the **highest meaningful level** —
  a component-level token when one exists, falling back to system, then reference — so outputs stay semantic
  and themeable rather than hard-coding primitives.
- **Density-sensitivity is mandatory.** Material's spacing scale is **density-sensitive**: hard-coding "12px"
  between two buttons is wrong, because changing density must change that spacing. Represent spacing (and other
  density-affected values) as the **density-sensitive token/formula**, not a literal.
- **Cross-vocabulary reconciliation.** Establish correspondence Figma-token ↔ Tailwind-token ↔ code-token, and
  classify every mismatch as either a **reasonable naming discrepancy** (map it) or a **spec failure** (one
  source is wrong). Default assumption: **Figma is the most-correct source for design intent**; where our code
  diverges we may need to *change our lingo/tokens/sizing to conform*, and the generator should surface those
  required changes at the algorithmic level rather than silently papering over them.
- **Context-aware compositions.** With the tier model + density model understood, Figma should be able to hand
  back *context-aware* compositions (correct spacing for the active density, correct token tier), which is what
  makes the hybrid Elm+Tailwind output "design-friendly."

## 10. The private-plugin constraint and the Figma-extraction infra (already built)

Our Figma plugin is **private / not exposed** as a public Figma plugin, so the pipeline cannot call a hosted
plugin at build time. **Therefore the CEM-side script must consume an offline export:** get the **entire kit
JSON as one file**, then derive a **subset containing only what the merge needs**, and run *that* against the
CEM. This session we stood up and proved the extraction infra that produces those files:

- **Architecture:** `figma-ws-client.mjs` (node) ↔ WS relay `socket.ts` (:3055, **requires `bun`**) ↔ the
  self-hosted **VSD Design System Dumper** plugin running inside Figma desktop (executes `figma.*` Plugin API).
  Lives in `avetta/akg-synapse/scripts/ingest/figma-plugin/` (plugin) and `.../figma-ws/` (relay + client).
- **Why the plugin and not the Desktop MCP:** the Desktop MCP has a *per-account daily rate limit* on free
  seats; the Plugin-API WS bridge has none and gives whole-file breadth.
- **Full runbook + all frictions** are documented at
  `avetta/akg-synapse/operations/2026-07-10-figma-ws-component-extraction-handoff.md` — **read it before
  touching the extraction.**
- **What "one file" and "subset" likely need** (you decide the exact schema): the full dump = components +
  component-sets (with `key`, variant `Property=Value`, `page`, `description`) + variables/collections/modes
  + styles + per-node geometry/structure as needed. The **subset** for matching probably = per public
  component: `{ setName, key, nodeUrl, variantProperties:{name:[values]}, keywordDescription, tokenRefs }`.
  Commands available on the bridge include `get-doc`, `get-components` (→ `get_local_components`), `get-styles`,
  `get-variables`, `get-node-tree`, `get-node-fills/typography/effects/css`, `get-component-properties`,
  `export-png`. **Caveat:** `get_local_components` returns only components *defined in the open file* — fine
  here because the Community kit is a master, but Figma's Plugin API has **no** "enumerate a whole team library"
  call, so always confirm you're on the master file.

## 11. Prior art — study before reinventing

**`avetta/ui.VOLT-2003` already has a working Elm→Figma Code Connect generator.** It differs from our target
(it's driven by Avetta's `Ui.*` modules via an elm-review rule, and points at the ADS design file — not the
CEM / Community kit / `M3e.*`), **but the mechanics are proven and directly instructive**:

- `code-connect/*.figma.ts` — **22** generated files (e.g. `Ui.Chip.Input.figma.ts`, `Ui.Avatar.figma.ts`).
- `code-connect/generate.mjs` — the generator.
- `figma.config.json` — `{ codeConnect: { parser: "html", include: ["code-connect/**/*.figma.ts"], label: "Elm" } }`.
- Driver: an **elm-review rule `DesignSystem.ExtractUiComponents`** extracts the Elm component taxonomy
  (entry points + `withX` builders + their types), which `generate.mjs` turns into `.figma.ts` bindings that
  reference the Figma node URL and use `figma.code\`…\`` templates + `instance.getBoolean(...)` etc.
- **Reusable insight:** the `parser: "html"` + `label: "Elm"` trick is how non-web-component code (Elm) is
  expressed through Code Connect. Our Layer 2b (Elm) should mirror this pattern, but derive from the CEM/HTML
  pipeline rather than the `Ui.*` elm-review extraction.

Also relevant: the whole `jackhp95` CEM→Elm toolchain (`elm-cem-decoder` → `elm-cem` → `elm-cem-m3e` →
`elm-m3e`) already turns the CEM into Elm; the Elm↔Figma leg should compose with it, not duplicate it.

## 12. Frictions & blockers already hit (do NOT retrace these)

From standing up the extraction infra and exploring the repos this session:

1. **The relay requires `bun`.** `socket.ts` uses `Bun.serve()` and imports from `"bun"`; **node cannot run it**
   (even node 24 type-stripping won't help — it's a runtime API, not syntax). Installed via `mise use -g bun`
   → bun 1.3.14. Don't waste time on `node socket.ts`.
2. **The plugin's `code.js` contains a NUL byte** (~offset 61220) → ripgrep silently treats the file as binary
   and returns *nothing*, which reads as "no matches." Use `rg -a` / `grep -a` to search it as text.
3. **`get_local_components` is local-only** and Figma's Plugin API has **no team-library component enumeration**
   (the `teamLibrary` API exposes *variables* only). Always confirm you're on the kit **master** file.
4. **Dev mode = read-only bridge** — auto-discovery rejects a Dev-mode bridge as non-writable; the file must be
   in **Design mode**. (Per-id variable getters also throw in Dev mode.)
5. **Plugin reload gotcha:** `code.js` only reloads when the plugin *instance* is re-run from Plugins →
   Development; restarting the relay/bridge alone keeps old code in memory (tell: an unchanged channel id).
6. **Plugin VM is ES2019** — no `??` / `?.` in `code.js`; they fail to *parse* and silently break the whole
   plugin. Use explicit `x == null ? a : b`.
7. **`get_node_info` returns geometry/names only** — for visual detail use `get_node_fills/typography/effects/css`.
8. **`@m3e/web` is Material 3 *Expressive*; the Community kit is closer to *baseline* M3.** The 2026 community
   kit *probably* carries the Expressive update, but **verify** — an Expressive/baseline mismatch is a real
   source of unmatched components (Expressive-only in code, or Figma-only). Don't assume parity.
   *(Post-verification: the kit IS Expressive — see evidence #8.)*
9. **Figma variables carry no `codeSyntax`** in the dumps seen — the token↔code binding is *not* in the export;
   it lives in Code Connect published data (`get_code_connect_map`, a *paid Dev-Mode* feature) and the code
   repos. Plan the token binding accordingly.
10. **CEM attribute types are named unions**, not inline enums — resolving the full value set requires following
    the type reference to its declaration (see §4.1). Naive reads under-count the variant space.
    *(Post-verification: the type modules are EMPTY in the CEM — resolution requires the sibling `.d.ts`
    files; see evidence #7.)*

## 13. Decisions made during scoping (with rationale)

- **Figma target = M3 Community kit** (not the ADS Material Rebrand catalog `W1IBQUWis2VKLb726llMXu`, nor the
  ADS design file `cbhz1J779WAI7gYkjCQwS0`). Rationale: the `jackhp95` m3e repos are *generic* `@m3e/web`
  tooling, decoupled from Avetta's internal ADS; pairing with the canonical public kit keeps the algorithm
  reusable and re-pointable at ADS later.
- **Unified model = CEM spine + per-concern resolution priority** — a strong suggestion, **not a gate**; the
  agent may revise after investigation (§5).
- **Matching = identity→properties, confidence tiers, keyword-synonym fuzzing, high-level human-in-the-loop via
  a persisted correspondence/override table, CEM-driven completeness inversion** (§7) — endorsed.
- **Visual-diff verification loop** (Figma `export-png` ⋈ Playwright `toHaveScreenshot`, auto-approve exact,
  surface only diffs to a review page) — endorsed, first-class (§8).
- **Scope/sequencing/phasing = explicitly the next agent's to own.** No subset, no ordering imposed here.

## 14. Open questions & research the next agent must own

- **Baseline vs Expressive:** does the current Community kit include M3 Expressive? Quantify the component/variant
  delta against the CEM's 123 elements. What's the policy for code-only and Figma-only components?
- **Public vs Building Blocks:** define the rule that separates the ~111 public sets from the ~60
  `.Building Blocks/` internal parts; decide whether internal parts get bindings at all.
- **Correspondence table format & storage:** exact schema, where it's checked in, how overrides merge with
  auto-matches on re-run, how conflicts are shown.
- **CEM type resolution:** implement full union-member resolution for attribute value spaces; handle boolean,
  enum, string, numeric, and slotted attributes distinctly.
- **The "one file" + "subset" schemas** (§10): finalize exactly what the full Figma export contains and what the
  matcher-facing subset keeps.
- **Token model:** concrete representation of the ref/system/component tiers and the density-sensitive spacing
  scale; how to detect the tier a Figma value belongs to; how to reconcile Figma↔Tailwind↔code token vocab; how
  to emit "required code changes" when Figma is authoritative and we diverge.
- **Tailwind v4 full-class enumeration:** how to get `elm-tailwind-modules`-style completeness under Tailwind v4's
  CSS-first config.
- **Elm derivation (Layer 2b):** confirm the html→elm pipeline + the elm-review "configured default with
  fallbacks," and how it composes with the existing `elm-cem`/`elm-m3e` generation.
- **Playwright render harness:** how to mount `@m3e/web` (Lit + floating-ui deps) headless, drive it to an exact
  variant/state, and normalize for stable diffs; how to render the Elm and Tailwind forms through the same DOM.
- **Code Connect for non-web-component targets:** confirm the `parser: "html"` + `label` approach (per VOLT-2003)
  is the right vehicle for the Elm and Tailwind labels, and whether multiple labels can coexist on one node.
- **Upstreaming to `matraic/m3e`:** what shape/format the upstream maintainer will accept; interim hosting in
  `elm-m3e` in the meantime.

## 15. Concrete resource index

**Repos:** `~/code/jackhp95/{elm-m3e, tailwind-m3e-web, elm-cem-m3e, elm-cem, elm-cem-decoder, elm-cem-template,
m3e-builder, m3e-docs}`, `~/code/forks/{m3e-upstream, material-web, tailwindcss}`,
`~/code/avetta/ui.VOLT-2003`, `~/code/avetta/akg-synapse`. GitHub: `matraic/m3e`,
`jackhp95/tailwind-m3e-web`, `jackhp95/elm-m3e`, `dillonkearns/elm-tailwind-classes-demo`, `elm-tailwind-modules`.

**CEM:** `jackhp95/elm-cem-m3e/node_modules/@m3e/web/dist/custom-elements.json` (@m3e/web 2.5.12, 439 modules,
123 custom elements). Newer copy: `jackhp95/elm-m3e/docs/node_modules/.pnpm/@m3e+web@2.5.14/.../custom-elements.json`.

**Figma target:** "Material 3 Design Kit (Community)" (get the file key from the live file/URL — not captured
here). This session's dump: `avetta/akg-synapse/scripts/research/cache/figma-components.json` (raw, 5,770 nodes)
+ `.../m3-kit-component-inventory.md` (grouped list). ⚠️ `scripts/research/cache/` is **git-ignored/ephemeral** —
regenerate via the runbook if missing. *(Post-verification: canonical fileKey = `KujuFlfJSwHI6ua1b7RZvL`;
the dump is checked into this repo at `research/figma-dumps/m3-kit-components.json`.)*

**Extraction runbook + frictions:** `avetta/akg-synapse/operations/2026-07-10-figma-ws-component-extraction-handoff.md`.

**Prior code-connect art:** `avetta/ui.VOLT-2003/{figma.config.json, code-connect/*.figma.ts, code-connect/generate.mjs}`.

**akg knowledge nodes** (query via `bash avetta/akg-synapse/scripts/audit/graph-query.sh`):
`knowledge/tools/figma.md`, `knowledge/tools/vsd-figma-plugin.md` (plugin runtime findings),
`scripts/ingest/figma-plugin/README.md` (B-WS-vs-MCP), `knowledge/figma-files/elm-code-connect.md`
(the ADS elm-code-connect catalog + the "0 codeSyntax / binding lives in Code Connect" finding).

**Live infra state (this session, may be gone):** relay running in a herdr pane on `:3055` (bun); Figma bridge
channel `vsd-cfc42e` against the Community kit. Restart per the runbook if needed.

## 16. Your mandate, restated

Take this vision and produce the research and the implementation plan(s) to realize it — the unified model, the
matching algorithm, the completeness/enumeration strategy, the visual-verification harness, the token model, and
the three Code Connect outputs (web components, Elm, Tailwind) plus hybrid outputs. **You own the breakdown,
phasing, and sequencing.** Verify every assumption in this brief against the real schemas. Plan comprehensively —
this is meant to be handed to an implementer, so leave nothing implicit.
