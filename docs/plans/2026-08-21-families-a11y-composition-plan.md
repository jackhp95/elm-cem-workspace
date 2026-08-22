# Families / composition-tier plan for html + shoelace + svg, grounded in a11y

**Status:** plan only. No code, config, or generated output changed to produce this document.
**Author date:** 2026-08-21.
**Scope target:** the *composition-validity* surface of three brands —
`brands/html/` (`TypedHtml`), `brands/shoelace/` (`Sl`), `brands/svg/` (`TypedSvg`).
**Templates followed:** `docs/plans/2026-08-20-reconciliation-plan.md` and
`docs/plans/2026-08-21-dag-rework-plan.md` (task/step + acceptance-test house style); `writing-plans`
structure; `brainstorming` used up-front (design section §0–§6 is the approved design; §7 is the
task breakdown).
**This plan is NOT executed by its author.** It is handed to a fresh execution agent after Jack
reviews it and resolves the open questions (§9). Several tasks are gated on those answers and say so.
**Companion plans (read first, this plan chains off both):**
`docs/plans/2026-08-21-dag-rework-plan.md` (the tier DAG this feeds) and
`docs/plans/2026-08-21-svg-api-spec-audit-plan.md` (the spec-index this consumes for SVG).

---

## 0. The one-line crux

The "families / composition tier" for a brand is **not primarily a naming façade** — it is the
brand's answer to *"which children may legally sit inside which parent slot."* That answer already
has a home in the pipeline: the per-element **`admits` config → generated `slotKinds` facts → the
`Cem.ValidSlotKind` elm-review rule**. Today that answer is **rich for m3e, half-present for html,
near-empty for shoelace and svg.** This plan fills those three gaps, and it fills them from the right
*source of truth* per brand:

- **html + shoelace** → a **general a11y/HTML-content-model foundation** (WHATWG interactive-content
  nesting rules + WAI-ARIA required-owned/required-context relationships). Shoelace, having *nothing*
  today, is the primary beneficiary and the reason this foundation must be brand-agnostic.
- **svg** → **its own spec content model** (the SVG-audit plan's `spec-index.json`), with the a11y
  layer (SVG-AAM roles, `title`/`desc`, ARIA-on-SVG constraints) as a **secondary overlay**, never a
  replacement for the spec's parent/child rules.

The composition config shape **already exists and is already brand-agnostic** (verified §2). The work
is (a) authoring the missing admittance data from the right sources, (b) teaching the config one new
expressive primitive it lacks (**set subtraction**, needed for "phrasing content *minus* interactive
content"), and (c) making the a11y/spec foundation a *gate* so the data can't silently rot.

---

## 1. Verified current state (the problem, precisely)

Every claim re-derived from the live worktree at base `8094b504`.

### P1 — The composition mechanism already exists and is brand-agnostic

`Cem.ValidSlotKind` (`pipeline/elm-review-cem/src/Cem/ValidSlotKind.elm:1-70`) is a *correctness*
elm-review rule: a child placed in a parent's content list must be a **kind the enclosing
component's slot actually accepts** (`slotKinds`), resolved through `slotRewrites`/`slotUpgrades`.
It consumes generated `Cem.Facts` — so the composition-validity check is **already wired**, needing
only the *data* (`slotKinds`) to be populated.

The **input** to those facts is the per-element `admits` block, whose shape is identical across
brands:

```jsonc
// brands/html/inputs/config.json  — "Button"
"admits": { "unnamed": { "kinds": ["@phrasing", "shared:text", "shared:icon"], "multi": true } }
// brands/svg/inputs/config.json   — "G"
"admits": { "unnamed": { "kinds": ["any"], "multi": true } }
```

`{ <slotName>: { kinds: [<token>...], multi: bool } }`. Token grammar today: bare kind (`"col"`),
category `@<set>` (`"@phrasing"`), `shared:<x>` (`shared:text`, `shared:icon`, `shared:phrasing`),
and the escape hatch `"any"`. This is the composition config. It is **not** m3e-specific.

### P2 — `slotKinds` population per brand (the measured gap)

Grepping the generated `*/Review/Facts.elm` for populated vs empty `slotKinds`:

| brand    | elements | `admits` authored?                               | composition validation today |
|----------|----------|--------------------------------------------------|------------------------------|
| **m3e**    | 130      | rich (`Card.leading = [button, iconButton, shared:icon]`, …) | **full** — the reference     |
| **html**   | 112      | **partial** — content-model categories via `@phrasing`/`@flow`/`_sets`, but **no interactive-nesting exclusion** | category-level only, a11y-blind |
| **shoelace** | 58     | **none** — every element `slotKinds = []`        | **zero**                     |
| **svg**    | 27       | **near-none** — only `title`/`desc`/`stop`/`tspan` families; all containers (`g`, `defs`, `symbol`, `switch`, `pattern`, `clipPath`, `mask`, `marker`) are `kinds: ["any"]` | almost none (matches SVG-audit finding) |

### P3 — The a11y foundation is *inexpressible* in today's config

`brands/html/inputs/config.json` `_sets` defines the exact HTML content categories
(`flow, phrasing, interactive, heading, sectioning, metadata, embedded`) — and `_sets.phrasing`
**includes `button`, `a`, `input`, `select`, `textarea`, `label`** (all interactive). So today
`Button.admits = ["@phrasing"]` **admits a `button` inside a `button`** — the precise a11y violation
Jack named. There is **no subtraction/exclusion syntax** anywhere in the config
(`grep` for `"exclude"`, `"-@"`, `"not"` → none). "Phrasing content, but no interactive content
descendant" — the literal WHATWG button content model — **cannot be written today.** This is the one
new config primitive this plan must add (Task 2).

### P4 — Relationship to the two companion plans

- **DAG-rework (`2026-08-21-dag-rework-plan.md`):** Components + Builders are **re-sourced from the
  composition config**, not the CEM ("Components already derive from `_families`… the tightest tier
  Builders pins its `accepts` phantom to the family's *admitted set*", §T4). **That admitted set is
  exactly `slotKinds`.** The DAG plan's Task-4 materialize step makes the composition config *the*
  source for Builders — so **the value of a strong `slotKinds` compounds**: a Builder can only accept
  children the composition config says are legal, and *this* plan is what makes that legal-set
  a11y-correct for html/shoelace and spec-correct for svg. The DAG plan explicitly lists shoelace as
  "no family tier → degenerate single-member families" and html/svg as "exempt (follow-up)". **This
  plan is a large part of that html/svg follow-up** and it hardens shoelace's degenerate families
  with real admittance data so their Builders aren't `any`-typed.
- **SVG-audit (`2026-08-21-svg-api-spec-audit-plan.md`):** it produces `docs/svg-audit/spec-index.json`
  (74 SVG-2 elements, attribute families, `appliesTo`) and a coverage gate. Its Task-4 acceptance
  explicitly says *"content-model `admits` reviewed (a `<circle>` still can't nest a `<div>` except
  via `foreignObject`)"* — i.e. it *touches* `admits` but treats content-model correctness as
  "reviewer judgment, not gate" (§2.3 honesty clause). **This plan supplies the missing gate:** it
  turns the spec-index's implicit parent/child content model into authored `admits` + a
  `NoInvalidComposition`-style rule, so SVG composition validity is *enforced*, not just reviewed.

---

## 2. The general a11y foundation (researched, cited)

All sources fetched live 2026-08-21 for this plan (provenance-stamped like the repo's facts bundles).

### 2.1 The interactive-content-nesting rule (spec-level, not convention)

From the **WHATWG HTML Standard** (`html.spec.whatwg.org`, content models quoted verbatim):

- **`<button>` content model:** *"Phrasing content, but there must be **no interactive content
  descendant** and no descendant with the `tabindex` attribute specified."*
  (`multipage/form-elements.html#the-button-element`)
- **`<a>` content model:** *"Transparent, but there must be **no interactive content descendant, a
  element descendant, or descendant with the `tabindex` attribute** specified."*
  (`multipage/text-level-semantics.html#the-a-element`)
- **`<label>` content model:** *"Phrasing content, but with **no descendant labelable elements**
  unless it is the element's labeled control, and **no descendant `label` elements**."*
  (`multipage/forms.html#the-label-element`)

These are **normative content-model constraints in the HTML spec itself**, not merely ARIA advice —
which is why they belong in the *content model* (`admits`/`slotKinds`), the same layer that already
says "`colgroup` admits only `col`".

### 2.2 What "interactive content" *is* (the exact set, with conditions)

**Interactive content** category (WHATWG + MDN cross-check):

- **Always interactive:** `button`, `details`, `embed`, `iframe`, `label`, `select`, `textarea`.
- **Conditionally interactive:** `a` (iff `href` present), `audio` (iff `controls`), `img` (iff
  `usemap`), `input` (iff `type` ≠ `hidden`), `object` (iff `usemap`), `video` (iff `controls`).

The conditional cases matter for how strict the gate can be (§9 OQ-3): at codegen time we usually
can't know whether a given `a` call carries `href`, so the safe default is to treat the *typed
constructor* conservatively (an `a` builder is "potentially interactive").

### 2.3 The other general constraints (beyond Jack's one example)

Jack gave one example; the fuller rule set actually relevant to how these brands compose:

1. **Interactive-in-interactive** (§2.1) — the headline. Applies to `button`, `a`, `label`,
   `summary`, plus any custom element with an interactive ARIA role.
2. **`<label>` labelable-descendant** (§2.1) — a labelable control may nest in a `label` **only** as
   its own labeled control; no second labelable, no nested `label`.
3. **`<form>` may not nest a `form`** (WHATWG: form content model excludes descendant `form`).
4. **Heading content** = `h1`–`h6`, `hgroup` (MDN) — `hgroup` admits only headings + script-supporting.
5. **Sectioning content** = `article`, `aside`, `nav`, `section` — relevant to landmark/heading
   outline correctness (advisory tier, not hard-fail).
6. **WAI-ARIA required-owned / required-context** (`w3.org/TR/wai-aria-1.2/`) — the ARIA analog of
   `_families` + admittance, and the part shoelace most needs because its widgets are ARIA-shaped:

   | container role | required owned child roles                         |
   |----------------|----------------------------------------------------|
   | `listbox`      | `option` (or `group` of options)                   |
   | `menu`/`menubar` | `menuitem` / `menuitemcheckbox` / `menuitemradio` |
   | `tablist`      | `tab`                                              |
   | `tree`         | `treeitem`                                          |
   | `grid`         | `row` → (`gridcell` / `columnheader`)              |
   | `radiogroup`   | `radio`                                            |

   And the inverse **required context** (`option`→`listbox`, `menuitem`→`menu`/`menubar`,
   `tab`→`tablist`, `treeitem`→`tree`, `row`→`grid`/`table`/`treegrid`, `listitem`→`list`).

7. **ARIA presentational-children** (`wai-aria-1.2`): *"The DOM descendants are presentational. User
   agents SHOULD NOT expose descendants of this element…"* — roles like `button`, `checkbox`,
   `option`, `tab` have **presentational children**, meaning nesting *other interactive semantics*
   inside them is meaningless/harmful. This is the ARIA restatement of §2.1 and covers custom
   elements that only expose an ARIA role.

### 2.4 SVG's accessibility overlay (secondary, for svg only)

From **SVG Accessibility API Mappings 1.0** (`w3.org/TR/svg-aam-1.0/`):

- **Default roles:** `svg`→`graphics-document`; shapes (`rect`,`circle`,`path`,…)→`graphics-symbol`;
  `g`/`foreignObject`→`group`; `image`→`img`; `a[href]`→`link`; `symbol`/`use`→`graphics-object`.
- **`title`/`desc`:** *no accessible object created* — they are **name/description sources** for
  their **parent** (priority: `aria-labelledby` → `aria-label` → child `title` → text). This is why
  the current svg `admits` already special-cases `title`/`desc` as universally-admitted children.
- **Non-rendered elements** (`animate`, `defs`, `filter`, `mask`, `pattern`, `clipPath`, …):
  *"no accessible object created; no role may be applied"* and `aria-roledescription` **MUST NOT** be
  exposed. This is an a11y constraint that **complements** the spec content model — e.g. it reinforces
  that `defs`/`filter` are structural, not content, containers.

**Key framing (Jack's, preserved):** for SVG the **spec content model is primary** (what may sit in
`g` vs `defs` vs a filter's primitive list is *spec-defined structure*), and SVG-AAM is a **secondary
overlay** — it adds `role`/`aria-*`/`title`/`desc` *validity* on top, it does not decide parent/child
containment.

---

## 3. The design — composition config as the single artifact

### 3.1 Reuse the existing shape; add exactly one primitive

**Decision D-FAM1 — do NOT invent a new config artifact.** The `admits` block (§P1) is already
brand-agnostic and already feeds `slotKinds` → `Cem.ValidSlotKind`. Reuse it verbatim for all three
brands. The `_families` block (`{ root, members:[{component,path}] }`) is a **naming/co-location**
concern (the DAG plan owns it) and is **orthogonal** to admittance — keep them separate. This plan
touches `admits`/`_sets`, not `_families`.

**Decision D-FAM2 — add set-subtraction to the kind grammar** (the only new primitive, §P3). Extend
the `kinds` token grammar with an exclusion token so the WHATWG constraints are expressible:

```jsonc
// Button — "phrasing content, but no interactive content descendant"
"admits": { "unnamed": { "kinds": ["@phrasing", "!@interactive"], "multi": true } }
// a — transparent minus interactive/a/tabindex
"admits": { "unnamed": { "kinds": ["@transparent", "!@interactive", "!a"], "multi": true } }
```

Token grammar becomes: `@set` (include a category), `!@set` (exclude a category), `!kind` (exclude a
single kind), plus existing `shared:*`, bare kind, `any`. Resolution: `include-set − exclude-set`,
computed in the emitter when it flattens `admits`→`slotKinds`, so the *generated facts stay a flat
allow-list* and `Cem.ValidSlotKind` needs **no change** (it still just checks membership). This keeps
the whole a11y foundation as **config + one emitter tweak**, no rule rewrite. *(Emitter change ⇒
triggers the Face-A bundle re-baseline per `MEMORY.md` `generator-change-d046-rebaseline` — see Task
sequencing.)*

### 3.2 Sourcing rule (which brand's admittance comes from where)

| brand    | primary source of `admits`                    | secondary overlay                          |
|----------|-----------------------------------------------|--------------------------------------------|
| **html** | WHATWG content model + `_sets` (already there) + the **new `!@interactive` subtraction** | WAI-ARIA (advisory) |
| **shoelace** | **derived** — map each SL component to its nearest HTML/ARIA role, inherit that role's content model + required-owned/required-context (§2.3.6) | ARIA presentational-children |
| **svg**  | **SVG-audit `spec-index.json`** parent/child content model (Task depends on that artifact) | **SVG-AAM** (`title`/`desc` always-admit; `role`/`aria-*` validity; non-rendered-no-role) |

### 3.3 Shared vs per-brand tooling

**Decision D-FAM3 — one brand-agnostic composition rule, brand-specific data.** `Cem.ValidSlotKind`
already *is* the brand-agnostic gate (it takes facts as input). We do **not** fork it per brand. What
differs per brand is:

- **the data** (`admits` authored from the right source — §3.2);
- **an optional second rule, `Cem.ValidComposition` (new, generic)**, that enforces the *relational*
  a11y constraints `slotKinds` can't express as a flat allow-list: interactive-in-interactive across
  *arbitrary depth* (not just direct child), `label` single-labeled-control, and ARIA
  required-context (a `tab` must have a `tablist` ancestor). `ValidSlotKind` is *direct-slot*
  membership; `ValidComposition` is *ancestor/descendant* relational. Both are generic and
  fact-driven; both serve all three brands. (This mirrors how the repo already ships
  `NoFamilyMemberDrift` (structural) + `ValidSlotKind` (semantic) as two complementary generic
  rules.)
- **svg additionally** gets the SVG-audit's own coverage gate (`check-svg-spec-coverage.mjs`, that
  plan's Task 6) — orthogonal, it checks *element/attr presence vs spec*, not *composition validity*.
  This plan adds composition validity *on top of* that.

So: **html + shoelace share everything** (same generic HTML/ARIA foundation, same two generic rules,
differing only in authored data); **svg reuses the same two generic rules** but its data comes from
the spec-index and it carries the extra SVG-AAM overlay + the audit's presence gate.

---

## 4. Shoelace-specific plan

Shoelace is the acid test: it has **58 components, zero authored `admits`, no `_families`** — nothing
today. Its `slots.json` holds only `_phantom`, `_brand`, `_atoms`.

- **Does shoelace have family-grouped components today?** **No.** (Verified — no `_families`.) Its CEM
  (`brands/shoelace/inputs/cem/custom-elements.json`) has 58 flat custom elements. Some are clearly
  relational (`sl-menu`/`sl-menu-item`, `sl-select`/`sl-option`, `sl-tab-group`/`sl-tab`/`sl-tab-panel`,
  `sl-tree`/`sl-tree-item`, `sl-radio-group`/`sl-radio`) — i.e. the **ARIA required-owned relationships
  of §2.3.6 map almost 1:1 onto shoelace's real component set.** That is precisely why the *generic*
  ARIA foundation is the right generator for shoelace: we don't hand-author 58 content models, we map
  each SL component to an ARIA role and *inherit* the role's content model.
- **Plan:** build a small **role-map** (`brands/shoelace/inputs/cem/roles.json`: `sl-menu →
  role menu`, `sl-menu-item → role menuitem`, `sl-button → role button`, `sl-tab-group → role
  tablist`, …). The emitter (or a pre-pass script) expands each role into its `admits` from a shared,
  brand-agnostic **ARIA composition table** (§2.3.6 + §2.1 interactive rules), yielding shoelace's
  `slotKinds` for free. Components with no clean ARIA role (`sl-card`, `sl-divider`) fall back to a
  permissive `@flow`-analog with `!@interactive` where they're interactive themselves.
- **Result:** shoelace goes from `slotKinds=[]` (58×) to real admittance, and — once the DAG rework
  lands — its degenerate single-member Builders carry a real `accepts` set instead of `any`.

---

## 5. SVG-specific plan

- **Source of truth = the SVG-audit `spec-index.json`** (that plan's Task 1). It already enumerates
  74 SVG-2 elements with family tags and `appliesTo`. This plan adds a **content-model field** to (or
  a sibling of) that index: for each container element, its admitted child element set per the SVG-2
  content-model tables (`g`/`svg`/`a`/`switch` admit "any container/shape/text/… descriptive/…";
  `defs` admits non-rendered defs children; `filter` admits only `fe*` primitives + `animate`/`set`;
  `feMerge` admits only `feMergeNode`; `text` admits `tspan`/`textPath`/`a`; `clipPath` admits only
  shapes+`text`+`use`; gradients admit `stop`+descriptive; etc.).
- **Replace the current `kinds:["any"]` containers** (`g`, `defs`, `symbol`, `switch`, `pattern`,
  `clipPath`, `mask`, `marker` — all `any` today, §P2) with spec-derived kind lists.
- **a11y overlay (secondary):** (1) keep `title`/`desc` as universally-admitted first children
  (already true) and encode the SVG-AAM name/description precedence as advisory; (2) add a small
  `role`/`aria-*` **validity** check for SVG — a `role` on a non-rendered element (`defs`, `filter`,
  `clipPath`, `mask`, `pattern`, `animate*`) is an SVG-AAM violation ("no role may be applied"); this
  is a *`ValidComposition`* extension, not an `admits` change.
- **Ordering:** this SVG work is **gated on the SVG-audit's spec-index existing** (its Task 1). If run
  before that lands, Task 5.1 below stands up a minimal content-model fixture as a stopgap and the two
  reconcile later (flagged OQ-5).

---

## 6. HTML-specific plan

HTML is the *most* complete of the three but a11y-blind: it has content-model categories but admits
interactive-in-interactive (§P3). Its gap is **narrow and precise**:

- Apply the new `!@interactive` subtraction (D-FAM2) to the elements whose WHATWG content model
  carries the constraint: `button`, `a`, `label` (plus `summary`, and `label`'s labelable-descendant
  rule via `ValidComposition`). This is a **handful of `admits` edits**, not a rewrite.
- Everything else in html's `admits` is already correct category-level content model — **leave it.**
- **Shared with shoelace?** **Yes — html and shoelace share the entire generic foundation** (the ARIA
  composition table, the `!@interactive` primitive, both generic rules). They diverge only in that
  html *authors* `admits` directly (its elements *are* HTML elements) while shoelace *derives* them
  through the role-map (§4). No tooling divergence.

---

## 7. Task breakdown (gauntlet-shaped, atomic leaves with acceptance tests)

House style = reconciliation/DAG plans: numbered Tasks, `- [ ]` Steps, per-step acceptance, identity
guard, green-tree milestones, dependency graph. **Expected model tier (informational):** Tasks 0–2
opus@medium (config primitive + research encoding); Tasks 3–6 sonnet workers under opus orchestration
(mechanical `admits` authoring + verify); Tasks 7–8 opus@medium (rule + gate wiring).

### Decisions carried into this plan

- **D-FAM1** — reuse the existing `admits`→`slotKinds`→`ValidSlotKind` mechanism; author data, don't
  invent an artifact. `_families` untouched (DAG plan owns it).
- **D-FAM2** — add `!@set` / `!kind` subtraction to the kind grammar (emitter-side flatten; facts
  stay a flat allow-list; `ValidSlotKind` unchanged).
- **D-FAM3** — one generic direct-slot rule (`ValidSlotKind`, exists) + one new generic relational
  rule (`ValidComposition`); brand-specific *data*, not brand-specific *rules*.
- **D-FAM4** — sourcing: html/shoelace from the a11y/ARIA foundation, svg from its spec content model
  with a11y as overlay (§3.2).
- **D-FAM5** — the a11y/ARIA foundation table is **provenance-stamped** (spec URL + fetch date), same
  discipline as the SVG spec-index and the facts bundles.
- **D-FAM6** — IDENTITY GUARD before every commit: `git config user.name`/`user.email` ==
  `JackHP95`/`git@jackhpeterson.com`.
- **D-FAM7** — the D-FAM2 emitter change triggers a Face-A bundle re-baseline + all-brand regen +
  phantom re-bless (`MEMORY.md` `generator-change-d046-rebaseline`); this is an explicit last task,
  not assumed folded into `gate-all`.
- **D-FAM8** — gate posture (hard-fail vs warn) is **OQ-2**; until resolved, `ValidComposition`
  defaults to **warn** (like `ValidSlotKind`'s `Lenient`), and the content-model `ValidSlotKind`
  data stays hard where it already is for m3e.

### Task 0: Baseline + identity guard

- [ ] **0.1** From repo root run `npm run gate:all` (`tools/gate-all.mjs`); save the green baseline to
      `/tmp/families-a11y-baseline-gate.log`. If red, STOP and surface.
- [ ] **0.2** `git status --short` empty before starting.
- [ ] **0.3 — IDENTITY GUARD (D-FAM6).** `git config user.name && git config user.email` ==
      `JackHP95` / `git@jackhpeterson.com`; `env | grep -iE 'GIT_AUTHOR|GIT_COMMITTER'` empty. Abort
      if not.
- [ ] **0.4** Record the P2 `slotKinds`-population table (per brand) as the "before" snapshot the
      final task diffs against.
- **Acceptance:** baseline gate green + saved; identity confirmed; before-snapshot recorded.
- **Blocks:** everything.

### Task 1: Encode the a11y/ARIA composition foundation (research → data)

- [ ] **1.1** Author `docs/a11y-foundation/composition-rules.json`: the interactive-content set
      (§2.2, with conditions), the WHATWG per-element constraints (§2.1: button/a/label/summary/form),
      the WAI-ARIA required-owned + required-context table (§2.3.6), and the presentational-children
      role list (§2.3.7). Provenance-stamped (spec URL + fetch date per entry — D-FAM5).
- [ ] **1.2** Author `docs/a11y-foundation/README.md` mapping each rule to *which config mechanism
      enforces it* (`admits`/`slotKinds` for direct-slot; `ValidComposition` for relational).
- **Acceptance:** JSON validates against a small committed schema; a reviewer spot-checks 5 entries
      against the live specs; every entry carries provenance.
- **Blocks:** Tasks 2–8. **No code/config change to any brand yet.**

### Task 2: Add the `!@set` / `!kind` subtraction primitive (emitter) — *gated on OQ-1*

- [ ] **2.1** Extend the `admits`→`slotKinds` flatten in the emitter (the pass that resolves `@set`
      today) to compute `include − exclude` when a `!@set`/`!kind` token is present. Facts output
      stays a flat allow-list.
- [ ] **2.2** Add a codegen unit test: `admits:{unnamed:{kinds:["@phrasing","!@interactive"]}}` on a
      fixture element flattens to phrasing-minus-interactive (button/a/input/… absent), and a wrong
      inclusion (`button` present) fails the test.
- [ ] **2.3** Confirm `Cem.ValidSlotKind` needs **zero** change (it still checks flat membership);
      run its existing test suite green.
- **Acceptance:** flatten test green; `ValidSlotKind` tests unchanged + green; a golden fixture shows
      the subtracted allow-list. **Verify:** `elm-test` on `pipeline/elm-review-cem/tests`.
- **Blocks:** Tasks 3, 4, 5. **Blocked by:** OQ-1 (confirm subtraction-in-config vs a dedicated rule).

### Task 3: HTML — apply the interactive-nesting subtraction (§6)

- [ ] **3.1** In `brands/html/inputs/config.json`, add `!@interactive` to the `admits.kinds` of
      `button`, `a`, `label`, `summary` (and `!a` to `a` per §2.1); leave all other `admits` intact.
- [ ] **3.2** Regenerate html through the generator; **zero post-codegen edits**.
- [ ] **3.3** Add a `verify`/spike consumer: a `button` containing a `button` (or an `a`) now trips
      `ValidSlotKind`/`ValidComposition`; a `button` containing `span`/`text`/`icon` stays clean.
- **Acceptance:** regen-diff green (pure generator output); the generated `TypedHtml/Review/Facts.elm`
      `slotKinds` for `button`/`a`/`label` exclude interactive kinds; the negative consumer trips the
      rule, the positive one doesn't.
- **Blocks:** Task 8.

### Task 4: Shoelace — role-map → derived `admits` (§4)

- [ ] **4.1** Author `brands/shoelace/inputs/cem/roles.json`: each of the 58 SL components → nearest
      ARIA role (or `none` fallback), reviewer-checked against Shoelace's own docs + the CEM.
- [ ] **4.2** Add an emitter pre-pass (or small script) that expands `roles.json` × the Task-1 ARIA
      table → per-component `admits`, written into shoelace's config the same shape as html's.
- [ ] **4.3** Regenerate shoelace; **zero post-codegen edits**.
- [ ] **4.4** Verify consumer: `Sl.menu` admits `Sl.menuItem` but not `Sl.card`; `Sl.tabGroup` admits
      `Sl.tab`/`Sl.tabPanel`; a `menuitem` outside a `menu` trips `ValidComposition` (required-context).
- **Acceptance:** all 58 `slotKinds` populated (0 remaining `[]` except intentionally-permissive
      leaves, listed with rationale); regen-diff green; the required-owned/required-context consumers
      behave as specified.
- **Blocks:** Task 8. **Note:** dovetails with DAG-rework Task 7 (shoelace degenerate families) — if
      that has landed, confirm the Builders' `accepts` set now reflects these `slotKinds`.

### Task 5: SVG — spec-content-model `admits` + a11y overlay (§5) — *gated on SVG-audit spec-index*

- [ ] **5.1** Consume `docs/svg-audit/spec-index.json` (SVG-audit Task 1). If absent, stand up a
      minimal content-model fixture as a documented stopgap (OQ-5). Extend it with per-container child
      sets from the SVG-2 content-model tables.
- [ ] **5.2** Replace the `kinds:["any"]` containers (`g`, `defs`, `symbol`, `switch`, `pattern`,
      `clipPath`, `mask`, `marker`, and — once the audit lands them — `filter`/`fe*`) with spec-derived
      kind lists in `brands/svg/inputs/config.json`. Keep `title`/`desc` universally admitted.
- [ ] **5.3** Add the SVG-AAM overlay to `ValidComposition`: `role`/`aria-roledescription` on a
      non-rendered element (`defs`,`filter`,`clipPath`,`mask`,`pattern`,`animate*`) is a violation.
- [ ] **5.4** Regenerate svg; **zero post-codegen edits**.
- **Acceptance:** no svg container is `kinds:["any"]` except documented exceptions; regen-diff green;
      a `<circle>` inside `<defs>`-only context and a `role` on `<defs>` both trip a rule; `<title>`
      still admits everywhere. Reconciles with SVG-audit Task-4's `admits`-review acceptance.
- **Blocks:** Task 8. **Blocked by:** SVG-audit spec-index (soft — stopgap allowed via OQ-5).

### Task 6: The generic relational rule `Cem.ValidComposition` (new elm-review rule)

- [ ] **6.1** Author `pipeline/elm-review-cem/src/Cem/ValidComposition.elm`: fact-driven,
      brand-agnostic. Enforces (a) interactive-content-descendant (arbitrary depth, from the Task-1
      interactive set), (b) `label` single-labeled-control + no-nested-label, (c) ARIA
      required-context (child role needs an ancestor of the required container role), (d) the SVG-AAM
      no-role-on-non-rendered overlay. Posture `Lenient|Strict` like `ValidSlotKind` (D-FAM8).
- [ ] **6.2** Author `pipeline/elm-review-cem/tests/src/ValidCompositionTest.elm` covering each of
      (a)–(d) with a passing and a failing case.
- **Acceptance:** rule compiles; all four constraint families have red+green tests; posture default
      is `Lenient` (warn) pending OQ-2.
- **Blocks:** Task 7.

### Task 7: Wire the composition gate into `gate:all`

- [ ] **7.1** Register `ValidComposition` (and confirm `ValidSlotKind`) in the elm-review config each
      brand's gate runs; add to `tools/gate-all.mjs` + `tools/gate-all-expected-steps.json`.
- [ ] **7.2** Mutation proof: hand-insert a `button`-in-`button` (html), a `menuitem`-outside-`menu`
      (shoelace), a `role` on `<defs>` (svg) into a fixture — each must turn the gate red; removing it
      returns green.
- **Acceptance:** gate green on the clean tree; the three mutations each go red; `gate-all`
      step-membership tests pass.
- **Blocks:** Task 8.

### Task 8: Face-A bundle re-baseline + phantom re-bless + final gate (D-FAM7)

- [ ] **8.1** Re-baseline `tools/snapshots/elm-cem-generator.bundle` from the final emitter (D-FAM2
      changed shared emitter code).
- [ ] **8.2** All-brand regen (m3e, html, shoelace, svg); confirm m3e unchanged (it authored real
      `slotKinds` already; the subtraction primitive is additive and m3e uses no `!@` tokens).
- [ ] **8.3** Phantom re-bless where affected.
- [ ] **8.4** Full `npm run gate:all` green; diff vs Task 0.1 baseline — every delta explained
      (shoelace/svg/html `slotKinds` growth + the new rule), nothing spurious. Identity guard; commit.
- **Acceptance:** re-run emits zero diff; gate-all green; P2 table now shows shoelace/svg populated,
      html a11y-correct.

### Task 9: Close-out (doc-only)

- [ ] **9.1** Note in `MEMORY.md` that html/shoelace/svg now have composition validity
      (a11y-sourced for html/shoelace, spec-sourced for svg), enforced by `ValidComposition` +
      `ValidSlotKind`, with the a11y foundation at `docs/a11y-foundation/`.
- [ ] **9.2** Record the hand-off to the DAG rework: these `slotKinds` are the `accepts` set the
      Builders tier pins once §T4 lands.
- **Acceptance:** memory + hand-off recorded; `git status` clean except intended files.

---

## 8. Sequencing / blast radius

- **Tasks 0–1** read-only (research + doc) — safe anytime.
- **Task 2** is a **shared-emitter change** (the `admits` flatten) → per D-FAM7 it drags the Face-A
  re-baseline (Task 8). This is the single highest-blast-radius step; it is additive (no `!@` token ⇒
  identical output), so m3e/existing brands regen byte-identically — **prove that first** (Task 8.2).
- **Tasks 3/4/5** are **independent, per-brand `admits` authoring** — parallelizable in worktrees,
  each contained to `brands/<brand>/**` + regen. None touches shared emitter code (they only *use* the
  Task-2 primitive).
- **Task 6** touches `pipeline/elm-review-cem/**` only; **Task 7** touches `tools/` + gate wiring.
- **Cross-plan ordering:** Task 5 (svg) is **soft-gated on the SVG-audit spec-index** (stopgap allowed).
  Nothing here blocks or is blocked by the DAG rework's *materialize* — but the two **compound**: land
  this first and the DAG rework's Builders inherit correct `accepts`; land DAG first and this hardens
  the already-degenerate families. Either order works (OQ-4).

---

## 9. Open questions for Jack (do not guess)

- **OQ-1 — Where does the interactive-nesting rule live: config subtraction or a dedicated rule?**
  Recommended **config subtraction (D-FAM2)** for the *direct-slot* case (keeps `ValidSlotKind`
  untouched, facts stay flat) **plus** `ValidComposition` for the *arbitrary-depth* case (a `button`
  three levels down still illegal). Confirm you're happy with the two-layer split rather than folding
  everything into one relational rule.
- **OQ-2 — Gate posture: hard-fail or warn?** The interactive-in-interactive rule is a *spec*
  violation (arguably hard-fail); the ARIA required-context rules are *strongly advisory* (a `tab`
  with no `tablist` ancestor is often a real bug but sometimes intentional composition). Recommended:
  **hard-fail the WHATWG content-model violations (button/a/label), warn the ARIA relational ones**
  initially, tighten later. Your call on the initial strictness.
- **OQ-3 — Conditional-interactive elements (`a[href]`, `input[type≠hidden]`, `audio[controls]`):**
  treat the *typed constructor* as unconditionally interactive (conservative, may over-warn on a
  decorative `a` without `href`), or attempt attribute-aware analysis (harder, needs the rule to read
  attrs)? Recommended **conservative** for v1.
- **OQ-4 — Sequencing vs the DAG rework:** run this **before**, **after**, or **parallel** to
  `2026-08-21-dag-rework-plan.md`? They compound either way (§8). Recommended **parallel** — this plan
  is m3e-independent and the DAG plan is composition-config-independent until its materialize step.
- **OQ-5 — SVG hard dependency on the SVG-audit spec-index:** wait for the SVG-audit's Task-1
  `spec-index.json` to land before starting Task 5, or proceed with the documented content-model
  stopgap and reconcile? Recommended **wait if the audit is already queued; stopgap only if svg
  composition is urgent.**
- **OQ-6 — Shoelace role-map authority:** derive `roles.json` purely from Shoelace's published CEM +
  ARIA-role annotations, or allow reviewer override where Shoelace's DOM differs from its ARIA role?
  Recommended **CEM/ARIA-first with a small reviewer-override list** (some SL components wrap multiple
  roles).

---

## 10. Deliverables summary

| artifact | task | purpose |
|---|---|---|
| `docs/a11y-foundation/composition-rules.json` (+ README, schema) | 1 | provenance-stamped a11y/ARIA foundation, brand-agnostic |
| `admits` subtraction primitive (emitter) | 2 | makes "phrasing − interactive" expressible |
| html `admits` edits (`button`/`a`/`label`/`summary`) | 3 | a11y-correct HTML content model |
| `brands/shoelace/inputs/cem/roles.json` + derived `admits` | 4 | shoelace's first-ever composition validity |
| svg spec-content-model `admits` + SVG-AAM overlay | 5 | svg composition from spec, a11y as overlay |
| `pipeline/elm-review-cem/src/Cem/ValidComposition.elm` (+ tests) | 6 | generic relational composition rule |
| `gate-all` wiring + mutation proofs | 7 | the permanent composition gate |
| bundle re-baseline + phantom re-bless | 8 | shared-emitter change made durable |
