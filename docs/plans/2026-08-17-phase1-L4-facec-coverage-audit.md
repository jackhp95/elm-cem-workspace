# Phase 1 — L4: Face C sufficiency audit for engine A (coverage matrix)

> Executes L4 of `~/Documents/code/planning/2026-08-17-phase1-html-elm-dedup-plan.md`.
> Audits whether Face C (`elm-api-facts.json`) carries everything engine A's bespoke
> `oracle` needs for the **component-API** layer, per the hybrid split (§3.2): Face C
> owns component-API facts; A keeps DOM-structural rules local. Produces the field
> matrix + an extend-Face-C-vs-keep-local decision per field, and scopes the L5 wall.

## A's oracle entry shape (per component)

From `packages/elm-m3e/docs/scripts/examples-gen/lib/oracle.mjs` (entry built ~L454):
`{ tag, module, kind, childSlotByKind, attributes[{htmlName,setter,kind,enumValues}],
requiredFields[{field,htmlName}], requiredSlots[{field,rawName,kinds}],
slots[{rawName,helper,kinds}], idWiring, group }`.

## Face C `comp` shape (per component)

From `elm-api-facts.json` (already consumed by B): `{ component, module, tokenModule,
actionModule, cemTag, surfaces{top,build,html:{module,entry,form,finalizer,facet}},
setters{attr→setter|null}, enums{setter→{values[{key,elm,token}]}},
setterArgTypes{setter→float|int|bool|…}, slotSetters[fnName] }`.

## Coverage matrix

| A oracle field | Face C source | Decision | Note |
|---|---|---|---|
| `module` + call ctor (`view`) | `surfaces.<key>.module` + `.entry` (`entryOf`) | **Face C owns** | A's `M3e.<Mod>.view` is the stale bug; Face C gives `M3e.Button.component`. |
| `attributes[].setter` | `setters{attr→setter}` (`setterOf`) | **Face C owns** | one-to-one. |
| `attributes[].kind` (enum/bool/number/string) | `enums` presence + `setterArgTypes` (`resolveAttrExpr`) | **Face C owns** | drives enum/number/bool/string branch. |
| `attributes[].kind === "skip"` (array/function/object type) | *(verify)* setter likely `null`/absent | **Keep local (A's degrade-to-comment)** | A emits a `{- dropped -}` comment; Face C has no "unexpressible-type" marker. Low-risk: A's local comment behavior is DOM-doc concern, not a name. |
| `attributes[].enumValues` (CEM tokens) | `enums[setter].values[].key` (`resolveEnumToken`) | **Face C owns** | A's `M3e.Values.camel(value)` is the stale bug (incl. invalid `4SidedCookie`); Face C gives `value4SidedCookie`. |
| `slots[].helper` | `slotSetters` via canonical match (`slotFnOf`) | **Face C owns** | one-to-one. |
| icon opaque-`Name` (R-026) | `icon-names.json` (`iconNameExpr`) | **Face C-adjacent owns** | A has NO icon special-case today (stale); the catalog is a sibling committed fact. |
| action record `= <Mod>.none` | `actionModule` (`actionNoneOf`) | **Face C owns** | A never emits `action` today (stale). |
| surface `form`/`finalizer` (record/pipeline/double-list) | `surfaces.<key>.form/finalizer` (`entryOf`) | **Face C owns** | A only knows the 2-arg `view` shape today (stale). |
| `slots[].kinds` (admission record: text/link/html/element) | — not in Face C | **Keep local** | DOM slot-child producer selection (which content builder type-unifies). Genuinely a type-admission/DOM concern, not a CEM-API name. |
| `childSlotByKind` (bare-child routing by produced kind) | — not in Face C | **Keep local** | DOM child routing (`<m3e-tab-panel>`→`panel` slot). |
| `idWiring` (FormField id↔for) | — not in Face C | **Keep local** | DOM-structural. |
| `requiredFields` / `requiredSlots` (required-ness) | — (required-ness is elm-review) | **Keep local** | A validates presence; the *form* itself is Face C. |
| aria/universal attrs (`ARIA_SETTER`, `UNIVERSAL_ATTR`) | — not in Face C | **Keep local** | DOM universal attrs (settable on any component). |
| plain-HTML routing (phrasing vs flow, void `<br>/<hr>`, `<a>`, `<img>`, `Native.node`) | — not in Face C | **Keep local** | DOM parsing/typing. |
| `group` (variant-group fold) | Face C keys per-tag | **Keep local (mostly obsolete)** | oracle already skips stale groups; current lib emits per-tag modules. |

**Verdict:** Face C is **sufficient for the component-API layer** — every name A needs
(module/entry/form/finalizer, setter, enum token, slot fn, icon Name, action) is present
and already exercised by B through elm-shape's Layer-1 resolvers. **No Face C schema
additions are required** for the hybrid split. The DOM-structural rows correctly stay
local to A. (One minor item to confirm during L5: how Face C represents an
unexpressible-type attr — A currently degrades it to a comment; if Face C simply omits/
nulls the setter, A keeps its local degrade path, no schema change.)

## The L5 wall (scoped, evidence-backed — see also the L0 worklog)

Face C coverage is **not** the blocker. The blocker is that engine A's generation is
**dead against the current library**, so L5's stated gate — "examples-gen compile+elm-
review green; skip rate ≤ L0 baseline" — is unachievable as written without a
revive-and-rewrite that exceeds a facts migration:

1. **No valid baseline.** `gen:examples-config` FATALs from a clean checkout — its
   compile harness (`verify-examples.mjs` `SRC_DIRS`) lists the deleted `docs/kit`
   directory. There is no measurable "L0 baseline skip rate" to hold at or below.
2. **The seam is deleted and is NOT a Face C fact.** A's output must COMPILE against a
   real elm-m3e module. It emits `Kit.text`/`Kit.link`/`Native.node`/`Native.attribute`/
   `TypedHtml.*` — `Kit` and `Native` no longer exist (`docs/kit` gone; `find` shows no
   `Kit.elm`). The current text seam is `M3e.text` (exposed on `src/M3e.elm`), but there
   is no confirmed current equivalent for the `Native.node`/`Native.attribute`/plain-HTML
   carriers A relies on. Per M3.a a userland seam is **not** CEM-derived, so Face C
   cannot supply it — it needs A's config to name **real, existing** modules, which
   requires **Jack's decision** on the current text/native/plain-HTML seam.
3. **A's unit tests enshrine the stale vocabulary.** `lib/to-elm.test.mjs` (the ONLY A
   code gate-all runs — `gen:examples-config` is in neither `build:ci` nor any gate)
   asserts `M3e.Button.view`, `Kit.text`, `Native.attribute`, `M3e.Icon.view`, etc. as
   expected output. Migrating A onto elm-shape/Face C makes its output
   `M3e.Button.component { content, action } […]` — breaking every one of those
   assertions, which must be rewritten to the new (compiling) vocabulary.

**Recommendation (per the plan's discipline — "don't force"):** the B track (L1–L3)
and the drift gate (L6) land the canonical engine and the byte-identical dedup now.
L5 (A's migration) is deferred as its own scoped effort gated on **Decision D-seam**
(what current elm-m3e module is A's text/native/plain-HTML seam) plus the harness
repair (`SRC_DIRS`) and a full `to-elm.test.mjs` re-baseline. This is not a Face C
coverage failure — Face C is ready; the blocker is A's own bit-rot + one seam decision.
