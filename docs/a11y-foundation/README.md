# a11y composition foundation

Brand-agnostic accessibility / HTML-content-model / WAI-ARIA foundation for the
**families / composition tier** of the elm-cem brands (`brands/html`,
`brands/shoelace`, `brands/svg`). Produced by **Task 1** of
[`docs/plans/2026-08-21-families-a11y-composition-plan.md`](../plans/2026-08-21-families-a11y-composition-plan.md).

This directory is **data + docs only**. It changes no code, config, or generated
brand output. It is the *source of truth* that later tasks (2–8) read from when
they author each brand's `admits`/`slotKinds` and the new relational rule
`Cem.ValidComposition`.

## Files

| file | purpose |
|------|---------|
| `composition-rules.json` | the foundation itself: interactive-content set, WHATWG per-element content models, WAI-ARIA required-owned + required-context tables, ARIA presentational-children roles, SVG-AAM overlay. Every semantic block carries a `provenanceRef` into the `provenance` map (spec URL + fetch date) per **D-FAM5**. |
| `composition-rules.schema.json` | small closed JSON Schema (draft 2020-12 subset) the data validates against. |
| `validate.mjs` | dependency-free validator (`node docs/a11y-foundation/validate.mjs`), mirroring the repo's `figma-connect` no-dep validator convention. Exit 0 = valid. |

Validate: `node docs/a11y-foundation/validate.mjs`

## How each rule is enforced (the mechanism map)

The plan's core insight (§0, §3): composition validity already has a home — the
per-element `admits` block → generated `slotKinds` facts → the
`Cem.ValidSlotKind` elm-review rule. The foundation splits into two enforcement
layers, tagged per entry by the `enforcedBy` field:

- **`admits/slotKinds`** — *direct-slot, flat allow-list.* Enforced by the
  **existing** `Cem.ValidSlotKind` rule
  (`pipeline/elm-review-cem/src/Cem/ValidSlotKind.elm`). A child placed directly
  in a parent slot must be a kind that slot's flat `slotKinds` list admits. No
  ancestry, no depth. This is where the WAI-ARIA *required-owned* relationships
  that are truly 1:1 direct-child (e.g. `tablist` owns `tab`, `radiogroup` owns
  `radio`) land as authored `admits` entries.
- **`ValidComposition`** — *relational, ancestor/descendant.* Enforced by the
  **new generic rule** `Cem.ValidComposition` (plan Task 6, not built yet). It
  covers the constraints a flat per-slot allow-list structurally *cannot*
  express: interactive-content-descendant at arbitrary depth, `label`'s
  single-labeled-control rule, ARIA *required-context* (a child role needs an
  ancestor of the required container role), and the SVG-AAM no-role-on-non-rendered
  overlay.
- **`advisory`** — documented in the foundation, intentionally **not** gated
  (either genuinely advisory, e.g. some ARIA required-owned relationships where a
  `group` wrapper is legal, or deferred pending **OQ-2** gate-posture).
- **`none`** — informational overlay only (e.g. SVG default-role mappings, which
  inform the overlay's reasoning but are not themselves a gate).

### Rule → mechanism table

| foundation entry | rule / constraint | enforced by | which rule |
|---|---|---|---|
| `whatwgContentModels[button]` | phrasing, **no interactive-content descendant**, no tabindex descendant | `ValidComposition` | interactive-in-interactive (arbitrary depth) |
| `whatwgContentModels[a]` | transparent, **no interactive / no `a` / no tabindex descendant** | `ValidComposition` | interactive-in-interactive + no-`a`-in-`a` |
| `whatwgContentModels[label]` | phrasing, **no 2nd labelable**, **no nested `label`** | `ValidComposition` | label single-labeled-control |
| `whatwgContentModels[summary]` | phrasing + heading, no interactive descendant | `ValidComposition` | interactive-in-interactive |
| `whatwgContentModels[form]` | flow, **no `form` descendant** | `ValidComposition` | no-form-in-form |
| `interactiveContent` | the exact set (with conditionals) that "interactive-content descendant" resolves to | (input) | feeds every `ValidComposition` interactive rule; conditionals per **OQ-3** (v1 = treat the typed constructor conservatively as interactive) |
| `ariaRequiredOwned[tablist→tab]`, `[radiogroup→radio]` | direct-child ownership | `admits/slotKinds` | `Cem.ValidSlotKind` (flat) |
| `ariaRequiredOwned[listbox/menu/menubar/tree/grid]` | ownership admitting an intermediate `group`/`rowgroup` | `advisory` | not a clean flat direct-child rule; see OQ-2 |
| `ariaRequiredContext[*]` (`option`→`listbox`, `menuitem`→`menu`…, `tab`→`tablist`, `row`→`grid`…) | child role needs an ancestor of the required container role | `ValidComposition` | ARIA required-context (relational) |
| `ariaPresentationalChildren` | roles whose descendants are presentational; nesting other interactive semantics is meaningless/harmful | `ValidComposition` | the ARIA restatement of interactive-in-interactive; covers custom elements exposing only an ARIA role (shoelace) |
| `svgAamOverlay.titleDesc` | `title`/`desc` create no accessible object; name/description source for parent | `advisory` + `admits/slotKinds` | svg `admits` already universally admits `title`/`desc`; precedence is advisory |
| `svgAamOverlay.nonRendered` | `role`/`aria-roledescription` on a non-rendered element (`defs`,`filter`,`clipPath`,`mask`,`pattern`,`animate*`) is a violation | `ValidComposition` | SVG-AAM overlay (svg-only extension) |
| `svgAamOverlay.defaultRoles` | implicit role mapping | `none` | informational; informs the overlay's reasoning |

## Sourcing rule (which brand's data comes from where)

Per plan §3.2 / **D-FAM4**:

- **html** — WHATWG content model + existing `_sets` + the new `!@interactive`
  subtraction primitive (plan Task 2/3). WAI-ARIA is advisory.
- **shoelace** — *derived*: each of the 58 SL components maps to its nearest
  ARIA role (a `roles.json`, plan Task 4), then inherits that role's content
  model + required-owned/required-context from this foundation. ARIA
  presentational-children applies to interactive SL widgets.
- **svg** — spec content model is *primary* (from the SVG-audit `spec-index.json`);
  this foundation's `svgAamOverlay` is the *secondary* a11y layer only (plan §5).

## Provenance & verification

Every semantic block references a key in the top-level `provenance` map, each of
which records the exact spec URL and the UTC date it was fetched live
(**D-FAM5**, same discipline as the SVG spec-index and the facts bundles). All
quotes in `composition-rules.json` were **re-verified live** against the cited
specs on 2026-08-22 during Task 1 — not copied from the plan doc. Two findings
from that re-verification:

1. The **`button` content model has changed** since the plan was written: the
   live WHATWG text now includes a trailing `selectedcontent` clause
   ("If the element is the first child of a `select` element, then it may also
   have one descendant `selectedcontent` element."). The foundation carries the
   current verbatim text; the plan's §2.1 button quote is now slightly stale.
2. `summary` and `form` content models — which the plan *named* but did not quote
   verbatim (§2.3 items 1 and 3) — were fetched and are now recorded verbatim:
   summary = "Phrasing content, optionally intermixed with heading content.";
   form = "Flow content, but with no form element descendants."

### Reviewer spot-check (Task 1 acceptance — 5 entries vs live specs)

Done 2026-08-22 against the live specs (see each entry's `provenanceRef` URL):

1. **`interactiveContent`** — the 12-member set with conditionals matches the
   WHATWG "Interactive content" category verbatim (a[href], audio[controls],
   button, details, embed, iframe, img[usemap], input[type≠hidden], label,
   select, textarea, video[controls]). ✔
2. **`whatwgContentModels[a]`** — "Transparent, but there must be no interactive
   content descendant, a element descendant, or descendant with the tabindex
   attribute specified." matches the live `a` element definition verbatim. ✔
3. **`whatwgContentModels[label]`** — "Phrasing content, but with no descendant
   labelable elements unless it is the element's labeled control, and no
   descendant label elements." matches the live `label` definition verbatim. ✔
4. **`ariaRequiredContext`** — required-context values re-fetched from
   WAI-ARIA 1.2 match: `option`→[listbox,group], `menuitem`→[group,menu,menubar],
   `tab`→[tablist], `treeitem`→[group,tree], `row`→[grid,rowgroup,table,treegrid],
   `radio`→[radiogroup], `listitem`→[group,list]. ✔ (the plan's §2.3.6 summary
   omitted the legal `group` intermediaries — corrected here.)
5. **`ariaPresentationalChildren`** — the 14-role list (button, checkbox, img,
   menuitemcheckbox, menuitemradio, meter, option, progressbar, radio, scrollbar,
   separator, slider, switch, tab) matches WAI-ARIA 1.2, cross-checked against
   W3C ACT rule 307n5z's enumeration verbatim. ✔

Bonus (SVG, lower priority per the task): `svgAamOverlay.nonRendered` "no role
may be applied" and `titleDesc` "no accessible object created" were both
confirmed verbatim against SVG-AAM 1.0.
