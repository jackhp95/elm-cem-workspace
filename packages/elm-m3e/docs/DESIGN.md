# The design of elm-m3e

How the library is built and why. elm-m3e is a **generated** Elm binding over
matraic's [`@m3e/web`](https://github.com/matraic/m3e-web) Material 3 Expressive
web components: the [`elm-cem`](https://github.com/jackhp95/elm-cem) generator
reads each component's custom-elements manifest (CEM) plus a small hand-authored
`config/slots.json`, and emits the two surfaces described here. Nothing under
`src/M3e/` is hand-written per component — the 130 modules there are regenerated
wholesale. The hand-craft lives in two places only: the **generator** and the
**config**. The escape surfaces themselves — `M3e.Unsafe` / `M3e.Unsafe.Attributes`
— are generated too, so there is no userland adapter module left to hand-write.

The schema for the config is [`CONFIG_SCHEMA.md`](CONFIG_SCHEMA.md); the config
*vocabulary* — the ten primitives every brand is expressed in — is summarized in
§7. This document is the theory of operation. Its companion guides go deeper on
individual axes: [`guides/TheLayers.md`](guides/TheLayers.md) (the surfaces and
the atom layer), [`guides/Seams.md`](guides/Seams.md) (the crossing mechanisms),
and [`guides/Glossary.md`](guides/Glossary.md) (the term dictionary).

Every Elm sample below is copied from, or type-checked against, the current
`src/` (or the sibling `elm-html-intermediate-representation` and `elm-typed-html`
packages this library builds on). Where a signature is abbreviated its shape is
preserved; the source module and definition are named inline so each can be
checked.

## 1. The one substrate: the HtmlIr intermediate representation

The whole library sits on **one phantom-typed HTML intermediate representation**,
published as `jackhp95/elm-html-intermediate-representation` and imported under the
`HtmlIr.*` namespace. This IR is a *superset of `elm/html`*: the same
`node [attrs] [children]` shape, plus two phantom rows that record what an element
*is* and what it *may contain* / *may be contained by*. Because native HTML, m3e,
and any future generated design system all emit the **same** `HtmlIr.Element`
type, their content nests without conversion, and the compiler can still reject a
child in a slot that does not admit it.

The IR is **imported, never injected.** Every generated `M3e.*` module carries
literal `import HtmlIr.*` lines (e.g. `src/M3e/Button.elm` imports
`HtmlIr.Attribute`, `HtmlIr.Element`, `HtmlIr.Internal as Ir`, `HtmlIr.Kind`,
`HtmlIr.Node`, and `HtmlIr.Value`). There is no `Markup.*` runtime and no
`injectRuntime` string-rewrite step — the retired pre-phantom generator used to
splice a runtime copy into every brand; the phantom generator depends on the
published IR like any ordinary Elm package.

### The one idea

**Everything is structural until the render boundary.** A `M3e.button` call does
not build `Html`; it builds an opaque `HtmlIr.Element` — a wrapper around an
untyped `Node` tree carrying phantom rows that are never inspected at runtime. You
can keep composing that tree — add a `slot=` to associate a child with a parent,
map its message type, place it in another component's child list — and every one
of those operations is type-checked by the phantom rows. Opaque `Html` cannot be
composed this way; the IR plus phantom rows can, and they guarantee the
composition is valid.

Only one point is eager: the **render exit** at the app root,

```elm
-- docs/app/Shared.elm:307 — the single eager conversion
Element.toNode >> Node.toHtml
```

where `Element` is `HtmlIr.Element` and `Node` is `HtmlIr.Node`. The two steps are
themselves the safe out-bound direction: `HtmlIr.Element.toNode : Element accepts
admittedBy msg -> Node msg` discards the phantom rows (never re-asserting them),
and `HtmlIr.Node.toHtml : Node msg -> Html msg` collapses the structural tree to
`Html` via `VirtualDom`. Everything before this line is IR.

### The forge and the fence

Minting an `HtmlIr.Element` — inventing its phantom rows out of thin air — is
possible only through the **curated forge**, `HtmlIr.Internal`. It exposes
`fromNode` (invents both element rows), `attribute` / `property` / `on` /
`fromHtmlAttribute` (invent an attribute's capability row), `token` (invents a
value's tag row), and `fromHtml` (wraps raw `Html`). Whoever imports this module
can assert any phantom claim about any content — including smuggling a raw
`<script>` into a slot typed to accept only text. That is the free assertion the
whole fence exists to contain.

Elm's `exposed-modules` gate is binary: `HtmlIr.Internal` **must** be exposed so
that generated brand packages (which live in other packages) can build on the IR,
and once exposed, *any* consumer can import it. There is no "generated-code-only"
visibility in Elm and no compiler-sound alternative (proven — see elm-cem#39). So
the trusted/untrusted line is held by exactly one thing:

> **`NoInternalImportOutsideAllowed`** (from the sibling
> [`elm-review-cem`](https://github.com/jackhp95/elm-review-cem) package) flags any
> import of `HtmlIr.Internal` outside a declared allow-list. In this repo the
> allow-list is `[ "M3e", "TypedHtml", "HtmlIr", "Native", "Layout", "Kit" ]`
> (`review/src/CodegenReviewConfig.elm`): generated brand code and reusable adapter
> namespaces a consuming project may use — application/docs code is never on it,
> because the escapes it needs (`M3e.Unsafe`, `M3e.Unsafe.Attributes`) are generated
> brand code, not a hand-written import of the forge itself. A project that installs
> the rule gets the full element↔attribute, enum,
> and nesting guarantee; a project that does not gets it only for code that stays
> off `HtmlIr.Internal`. Documentation must never claim "compiler-guaranteed"
> without this caveat.

`HtmlIr.Internal` is frozen small — functions and opaque types only, **no data
constructors**, no userland-shaped conveniences — so a human can audit it once.
Opinionated operations (slot placement, kind branding, coercion, event delegation)
are compositions of these levers, built *above* the IR by brand packages.

## 2. The two phantom rows

`HtmlIr.Internal.Element` carries **two** phantom rows plus `msg`:

```elm
-- HtmlIr.Internal:119
type Element accepts admittedBy msg
    = Element (Node msg)
```

- **`accepts` — the kind row (parent → child).** On a *producer* it says "what
  kind I am" (an open row: `M3e.button` produces `{ s | button : Brand }`, ready
  to unify with any slot naming `button`). On a *container's slot* it is the closed
  row of kinds that slot demands.
- **`admittedBy` — the context row (child → parent).** It records which parent
  contexts an element declares itself valid inside. A container injects an open
  demand for its own context into each child's `admittedBy`; a *restricted* element
  closes its `admittedBy` so it only unifies under the parents it names.

Composition unifies **both edges** at once: child-kind ⊆ parent-accepted-kinds
AND parent-context ∈ child-admittedBy. The rule is *producers keep `accepts` open
and `admittedBy` closed; containers demand a closed `accepts` on children and
inject an open demand into their `admittedBy`*. An **open** `admittedBy` on a
producer means "valid anywhere" — enforcement requires the *closed* row, because an
open row unifies with any demand (proven).

The marker vocabulary is split deliberately. The IR ships only the two markers
that *must* be shared across package boundaries for unification to work:

```elm
-- HtmlIr.Kind exposes exactly these two
type Supported = Supported   -- capability/value-row field marker ("admitted here")
type Shared    = Shared      -- the cross-brand atom kind marker
```

Everything else is **per-brand**, minted in the brand's own namespace so Elm's
nominal type system keeps brands distinct at zero runtime cost:

```elm
-- M3e.Kind
type Brand = Brand_   -- this library's private kind marker
type Ctx   = Ctx_     -- this library's private context marker
-- (Available / Used — the pipe-builder's write-once markers; see §4)
```

A private-tier component's `accepts` row carries `M3e.Kind.Brand`, so a closed
slot rejects any element carrying a *different* brand. An atom's `accepts` row
carries `HtmlIr.Kind.Shared` in a role field (`{ s | sharedText : Shared }`), so it
flows into any brand's slot that opts in to that atom. This is the whole of
cross-brand safety: `Shared` unifies everywhere; `Brand` unifies only with its own
library.

## 3. Two surfaces, not five forms

elm-m3e exposes **two coordinated surfaces** over the IR. (The retired
architecture emitted *five* module-forms per component — `M3e.Raw`, `M3e.Html`,
standard, `M3e.Record`, `M3e.Build` — plus a barrel that restated them a sixth
time. Aliasing the closed rows collapsed that to two shapes; the Raw/Html
form-layers, the barrel-as-restatement, and the per-package "facet family" split
are gone.)

Both surfaces return the **identical** `HtmlIr.Element … msg`, so they nest and
interchange freely. Start on the general surface; reach for a per-component module
when you want the *compiler* — not `elm-review` — to enforce required content and
placed-child slot-kinds.

### The general surface — `M3e` + `M3e.Attributes` / `M3e.Events` / `M3e.Values`

`M3e` exposes every component in the `elm/html` call shape: lowercase names, one
import, `constructor [attrs] [children]`. Constructor signatures *reference* each
component's aliases rather than re-inlining the rows — that is what keeps the docs
under cap:

```elm
-- src/M3e.elm — the general constructor delegates to the per-component view
button :
    List (Attr M3e.Button.Attrs msg)
    -> List (Element M3e.Button.Content (M3e.Button.ChildAdmittedBy childAdm) msg)
    -> Element (M3e.Button.Is s) admittedBy msg
button =
    M3e.Button.view
```

Plain text is built in — the one atom that needs no userland producer:

```elm
-- src/M3e.elm
text : String -> Element { s | sharedText : Shared } admittedBy msg
text value_ =
    Ir.fromNode (Ir.text value_)
```

The shared vocabulary lives in three sibling modules:

- **`M3e.Attributes`** — the canonical library-wide attribute setters. Every setter
  is an open producer whose capability row each element's closed `Attrs` decides to
  admit. Enum setters here close over the library-wide **union** of values, so
  cross-component misuse is caught by `elm-review`, by design:

  ```elm
  -- src/M3e/Attributes.elm
  variant : Value M3e.Values.Variant -> Attr { c | variant : Supported } msg
  disabled : Bool -> Attr { c | disabled : Supported } msg
  ```

- **`M3e.Events`** — the event setters, gated as capabilities (§6), plus `delegate`.
- **`M3e.Values`** — the enum value tokens, each minted once against an open row:

  ```elm
  -- src/M3e/Values.elm
  filled : Value { v | filled : Supported }
  filled =
      Ir.token "filled"
  ```

On the general surface, element↔attr validity, enum tokens, and the slot-kind of a
*direct* child are compiler-checked. Three checks are `elm-review` guidance here:
missing-required content, duplicate-singular, and the slot-kind of a child placed
via a slot function (see §5).

### The per-component surface — `M3e.<Component>`, with narrowed values

`M3e.Button`, `M3e.Card`, … each expose the strict shape for one component. Take
`M3e.Button` (`src/M3e/Button.elm`) as the worked example. It aliases its closed
rows once and references them everywhere:

```elm
type alias Is s   = { s | button : Brand }                 -- what m3e-button IS (open)
type alias Attrs  = { class : Supported, disabled : Supported, {- …20… -} variant : Supported }
type alias Content = { sharedText : Shared, sharedIcon : Shared, menuTrigger : Brand, {- … -} }
type alias ChildAdmittedBy childAdm = { childAdm | button : Ctx }   -- context injected into children
```

The **standard** constructor, `view`, takes `[attrs] [children]`:

```elm
-- src/M3e/Button.elm:188
view :
    List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
view attrs children =
    Ir.fromNode (Ir.node "m3e-button" attrs (List.map HtmlIr.Element.toNode children))
```

Value setters are **narrowed** — they admit only *this* component's tokens, closing
the enum tighter than the general union setter:

```elm
-- src/M3e/Button.elm:240 — Variant = { elevated, filled, outlined, text, tonal }
variant : Value Variant -> Attr { c | variant : Supported } msg
variant value_ =
    Ir.attribute "variant" (HtmlIr.Value.toString value_)
```

A real call, drawn from `guides/TheLayers.md` and type-checked against the above:

```elm
M3e.Button.view
    [ M3e.Button.variant M3e.Values.filled ]
    [ M3e.text "Submit" ]
```

`M3e.Button.variant M3e.Values.square` is a compile error (`square` is not in
Button's `Variant` row); an `M3e.Card.view …` placed in Button's child list is a
compile error (`card` is not among Button's `Content` kinds).

**`view { required }` — required content as a record.** When a component is
non-functional without some content or an action, the generator hoists those into a
required record so omission is *unwritable*. `M3e.Button` needs an action, so it
also emits `el`:

```elm
-- src/M3e/Button.elm:198
el :
    { content : Element Content (ChildAdmittedBy childAdm) msg
    , action : M3e.Action.Action ActionCaps msg
    }
    -> List (Attr Attrs msg)
    -> List (Element Content (ChildAdmittedBy childAdm) msg)
    -> Element (Is s) admittedBy msg
```

A component with no required content — `M3e.Card` — has a plain `view` and no `el`
(its default slot is `arbitrary`, so its child row is a free `childAccepts`
variable). Whether a component gets `el` is driven purely by config
(`require` non-empty), not hand-decided.

**`build |> withX |> toElement` — the cardinality pipeline.** For write-once
guarantees the generator emits an opaque `Builder` threaded through a capability
record. A singular setter consumes its capability `Available → Used`, so writing it
twice fails to type-check:

```elm
-- src/M3e/Button.elm:415, :552, :426
build : { content : …, action : M3e.Action.Action ActionCaps msg } -> Builder AttrCaps SlotCaps msg

withVariant :
    Value Variant
    -> Builder { a | variant : Available } slotCaps msg
    -> Builder { a | variant : Used } slotCaps msg

toElement : Builder attrCaps slotCaps msg -> Element (Is s) admittedBy msg
```

Used qualified:

```elm
import M3e.Button as Button

Button.build { content = M3e.text "Save", action = M3e.Action.onClick SaveClicked }
    |> Button.withVariant M3e.Values.filled
    |> Button.toElement
```

Everything the general surface leaves to `elm-review`, the per-component surface
turns into a compile error:

| Mistake | general (`M3e.button`) | per-component (`M3e.Button`) |
|---|---|---|
| invalid enum token | compiler | compiler |
| wrong attr on element | compiler | compiler |
| wrong slot-kind (direct child) | compiler | compiler |
| wrong slot-kind (placed via slot fn) | **elm-review** | compiler |
| missing required content | **elm-review** | compiler (`el` / `build`) |
| duplicate singular slot/attr | **elm-review** | compiler (`build`) |

### Slot placement

`elm/html`'s last-wins resolves duplicate **attributes** (set `disabled` twice, the
last wins). It does **not** apply to **slotted children**: every element carrying a
`slot=` renders, in order — so the AppBar-trailing case (several trailing actions,
all shown) is a first-class pattern, and a genuinely singular slot must be stated
*explicitly* in config, never inferred from HTML.

A slot placer stamps `slot=` and re-forges a free row so the placed element
composes back into a child list. Its *input* is constrained to the slot's kinds:

```elm
-- src/M3e/Button.elm:339 — IconSlot = { loadingIndicator : Brand, sharedIcon : Shared }
icon : Element IconSlot admittedBy msg -> Element free freeAdmittedBy msg
icon element =
    Ir.fromNode (Ir.addAttribute (Ir.attribute "slot" "icon") (HtmlIr.Element.toNode element))
```

Composition is **add-only**: placing a child only adds a `slot=`; it never changes
or removes an attribute, so the types never need to. If an attribute is set twice,
`elm/html`'s natural last-wins gives a predictable result — no dedup machinery.

## 4. Bidirectional `admittedBy` typing — R1 and R2

The `admittedBy` row is what lets a *child* constrain its valid *parents*, the
mirror of the producer-open/consumer-closed trick §2 uses on the kind row. A
container injects an open demand for its own context marker into each child's
`admittedBy`; a restricted element closes its `admittedBy` to the parents it names.
Two generator rules keep this sound, both named in the config-primitive catalog:

- **R1 (shared-alias grouping).** Elm lists are homogeneous, so every element in one
  container's accepted-kind set must reference *one* shared closed `…AdmittedBy`
  alias — slot-mates whose `admittedBy` rows differ would refuse to unify in the same
  child list. The generator groups the set's members by parents-set, emits one
  shared alias per group, and **fails loudly at generation time** naming any
  offenders and the two fixes: widen a member's parents, or apply R2.
- **R2 (per-context split).** When one element's valid-parent set genuinely diverges
  from its slot-mates, split it into *two constructor entries* with different
  parents (the canonical example is native `source`, which is valid in both
  `<audio>`/`<video>` and `<picture>`, versus a `<track>` that is valid only in
  `<audio>`/`<video>` — keeping `<track>` in `<picture>` a compile error). R2 needs
  no new primitive: an entry key that differs from its DOM tag already provides it.

R1/R2 are load-bearing for the **native brand** (`TypedHtml`, from `elm-typed-html`),
where the WHATWG content model genuinely restricts where elements may sit
(`<option>` only under `<select>`/`<optgroup>`, table cells only under rows, and so
on). The m3e brand exercises the *machinery* — every m3e container still injects its
`Ctx` demand, so `M3e.Button` emits `type alias ChildAdmittedBy childAdm = { childAdm
| button : Ctx }` — but currently declares no restricted-parent components (no m3e
component sets `parents` in `config/slots.json`), so m3e elements are valid anywhere.
The context injection is cheap and future-proof: a later config could declare, say,
`m3e-tab` valid only inside `m3e-tabs`, turning that nesting rule into a compile
error with no generator change.

The catalog term for the two rows in the general signature is `Element accepts
admittedBy msg` (the IR names them exactly this). "R1" and "R2" are the two
generator discipline rules that keep a homogeneous child list type-checkable when
its members carry an `admittedBy` row.

## 5. Advisory vs compile-time

Enforcement splits by what each invariant is worth at the type level:

- **Type level, never relaxed:** *kind* and *capability* validity (§2–§3). A wrong
  attribute, a wrong enum token, or a wrong-kind *direct* child is a compile error
  on both surfaces; missing-required and duplicate-singular are compile errors on
  the per-component `el`/`build`.
- **Linter, project-wide:** *cardinality*, *required-presence*, and *placed-child*
  slot-kind on the general surface. A record tax on every component was judged worse
  than the guarantee is worth (`M3e.TreeItem` alone has several icon slots — every
  optional would become a `Maybe` the caller spells `Nothing`), so these are
  codegen-aware `elm-review` rules that read the generated `M3e.Review.Facts` table.

The rules come from the sibling `jackhp95/elm-review-cem` package (namespace `Cem.*`)
plus this repo's project-boundary rules. The correctness set includes
`Cem.ValidEnumValue`, `Cem.RequireSlot`, `Cem.SingularSlot`, `Cem.SingularAttribute`,
`Cem.MissingRequiredAttribute`, `Cem.MissingRequiredSingularSlot`, and
`Cem.ValidSlotKind`; auto-fix rules (`Cem.PreferBarrel`, `Cem.PreferComponentModules`,
`Cem.PreferComponentSetters`) upgrade loose general-surface code to the
component-precise form. Two project rules — `NoInternalImportOutsideAllowed` (§1) and
`NoSeamOutsideAllowedModules` (§6) — fence the crossings. All are wired from
`review/src/ReviewConfig.elm` and `review/src/CodegenReviewConfig.elm`.

`Cem.ValidSlotKind` has two postures. `Lenient` (the shipped default) flags a slot
child only when the child's kind resolves statically and stays quiet where it cannot
— the accepted trade for the ergonomic general surface. `Strict` flags the
unresolved cases too, for a project that wants the linter to hold the full slot-kind
guarantee the per-component surface holds in the type system.

**IR faithfulness underpins all of this:** the generated IR emits exactly what the
caller composed — never silently adding, dropping, deduplicating, or reordering. A
compile error from the phantom rows is not a faithfulness violation; it rejects
invalid input before anything is built, and never rewrites valid input.

## 6. Events, the ARIA hybrid, delegate, and the seam

### Events as capabilities

Event setters are open producers admitted only by elements whose closed `Attrs` row
lists the event, so `onClick` on a non-interactive element is a compile error:

```elm
-- src/M3e/Events.elm
onClick : msg -> Attr { c | onClick : Supported } msg
```

Per-element event ownership comes straight from the `@m3e/web` CEM (each element
lists its own events); the closed `Attrs` row gates it with the same
open-setter-⊆-closed-element unification used for attributes.

### `delegate` — the one loud bubbling escape

Bubbling is a *subtree* relation, but the rows are *direct-edge*, so "a container
listens for a click that bubbles up from an interactive descendant" is not soundly
typeable. Rather than weaken the row, delegation is an explicit, greppable escape:
`delegate` forgets an event's capability so it can be placed on a container:

```elm
-- src/M3e/Events.elm:294
delegate : Attr capability msg -> Attr anyCapability msg
delegate attr =
    Ir.fromHtmlAttribute (HtmlIr.Attribute.toHtmlAttribute attr)
```

It needs no dependency — it is just the events-facing name for the IR's
capability-forget primitive (`fromHtmlAttribute (toHtmlAttribute a)`). A lint rule
enforces pairing it with a real interactive child and a keyboard path.

### The ARIA hybrid

ARIA names — and the whole aria-\* family — are *global HTML attributes*, so m3e does
**not** re-expose them per-brand. They live in one place: the **native brand**,
`TypedHtml.Aria` (from `elm-typed-html`). A universal aria setter carries a fully-open
capability row, so it flows into *any* component's attribute list — you import the
native module once and reach for `Aria.label`/`Aria.describedBy`/… everywhere:

```elm
import TypedHtml.Aria as Aria

M3e.iconButton [ Aria.label "Back" ] []          -- the name, via TypedHtml.Aria
M3e.iconButton [ Aria.describedBy "hint-1" ] []  -- the rest, same module
```

The one place the name is *not* an optional attribute is where it is structurally
required: icon-only controls (FAB, IconButton) take the accessible name as a **required
record field** on the component itself (see §Required content), stamped inline as
`aria-label` — so they cannot be constructed without a name. Everything else is the
open native aria setter. `role` gating is deliberately **not** generated into m3e; it
too lives in `TypedHtml.Aria`.

This composes because a universal ARIA setter carries a **fully-open capability
row** — it demands nothing of the element it lands on:

```elm
-- elm-typed-html/src/TypedHtml/Aria.elm:961
label : String -> Attr c msg
label =
    Ir.attribute "aria-label"
```

The "hybrid" is the split the catalog's `roles` primitive draws: universal aria-*
attributes stay open `String` setters (so they flow into any brand's element), while
*role* gating is typeable per element for the high-value cases —

```elm
-- elm-typed-html/src/TypedHtml/Aria.elm:32
role : Value tags -> Attr { c | role : tags } msg
```

so `role navigation` on a `<div>` compiles while `role tab` does not. m3e gates no
ARIA roles initially (no component sets `roles`); the native brand gates the
high-value set. Because the ARIA setter carries an open row, accessibility is
first-class on *every* m3e component — right where the other attributes go — not a
separate module you must remember to wire.

### The seam boundary

Userland sometimes needs to cross into the IR directly — wrap a raw `Html` value,
re-kind an element for a slot the design system did not anticipate, forge a
third-party custom element the generator never will. Every one of those crossings
now ships *with the library*, fenced into one lint-guarded place: `M3e.Unsafe` and
its attribute-side twin `M3e.Unsafe.Attributes`. There is no userland adapter module
to hand-write and no direct `HtmlIr.Internal` import to justify outside the library's
own generated code — both are fenced, by `NoSeamOutsideAllowedModules` and
`NoInternalImportOutsideAllowed` respectively.

**Atoms flow freely and are *not* a crossing.** `M3e.text` (built in) and
`TypedHtml`'s own producers (`TypedHtml.text`, and elements like `TypedHtml.a` whose
own kind row is open enough to unify with a slot's declared atom) produce or admit
`HtmlIr.Kind.Shared`-typed elements natively — no stamping step, no adapter module.
Any m3e slot that opts in with a matching `shared:<atom>` config entry admits them by
ordinary unification — no cast, no coercion. This is why an app's "text" can be an
i18n key resolving to the user's language and still drop into a button: the
producer carries the row itself, generated code included:

```elm
-- elm-typed-html/src/TypedHtml.elm:1168 — carries Shared natively, no seam required
text : String -> Element { s | sharedText : Shared } admittedBy msg
```

**`M3e.Unsafe.recast` — the general loud crossing.** When userland must move an
element between brand kind rows with no stable semantic identity (a one-off layout
adapter, a temporary foreign integration), `recast` re-stamps the rows. It is loud
(you write it explicitly), greppable (one function name), and review-fenced —
called from a small, named producer kept next to the feature that needs it, not
inline at every call site:

```elm
-- src/M3e/Unsafe.elm:45
recast : Element aAccepts aAdmittedBy msg -> Element bAccepts bAdmittedBy msg
recast element =
    Ir.fromNode (HtmlIr.Element.toNode element)
```

**`M3e.Coerce.*` — config-blessed typed crossings.** When a brand crossing recurs
with a stable identity (a Chip *acting as* a button — a design-system decision, not
an accident), the `_coerce` block in `config/slots.json` declares it and the
generator emits a typed function. Unlike `recast`, its from-kind is *specific*, so
only an element already typed as a Chip passes, and it appears in config so the tool
and reviewers can find every declared crossing:

```elm
-- src/M3e/Coerce.elm:18 (config: _coerce Chip→button, name "asButton")
asButton :
    Element { k | chip : Brand } admittedBy msg
    -> Element { s | button : Brand } admittedBy2 msg
asButton element =
    Ir.fromNode (HtmlIr.Element.toNode element)
```

**`M3e.Unsafe.fromHtml` / `.fromNode` / `.customElement` — the published escapes.**
The exported ways to wrap raw `Html` as an `Element` with fully-free rows, re-assert
rows on an erased `Node`, or forge a tag this library has no generated producer for
(a third-party custom element the CEM never described) — for incremental migration
and genuine foreign integration; every use site is a grep target and a lint finding:

```elm
-- src/M3e/Unsafe.elm:31
fromHtml : Html msg -> Element accepts admittedBy msg

-- src/M3e/Unsafe.elm:59
customElement : String -> List (Attr capability msg) -> List (Element childAccepts childAdmittedBy msg) -> Element accepts admittedBy msg
```

The posture is **permissive-default-you-trim**: a freshly generated component
defaults maximally permissive (everything composes) so teams *subtract* invalid
compositions in config rather than opt into valid ones. When a team believes the
design system is genuinely wrong for their case, `recast` coerces the row — but it
is loud, greppable, and review-fenced, so the design-system owner can audit each use
and either fix the app or fix the config. The escape is a feedback signal, not a
silent hole. See [`guides/Seams.md`](guides/Seams.md) for the full decision table.

## 7. The config vocabulary — ten primitives

A brand is *data* expressed in a small, general vocabulary; the generator is a set
of *projections* of that data into module shapes. New design system = new data,
same vocabulary. New surface = new projection, same data. Zero post-codegen tweaks.
The vocabulary is ten primitives (top-level meta-keys are `_`-prefixed;
per-component primitives are fields of the component's entry, keyed by constructor
name):

1. **`element`** (CEM-side, curated) — tag, attributes, events, and slots come from
   the manifest; config keeps the proven curation keys (`_exclude`, `syntheticAttrs`,
   `attrTypes`, `staticAttrs`, `events`, `group`, `_actions`).
2. **`kind`** — what the element *is*: `"private"` (default → the brand's own
   `M3e.Kind.Brand`) or `"shared:<role>"` (a cross-brand atom → `HtmlIr.Kind.Shared`).
   In the shipped config, `Icon` is `"shared:icon"`.
3. **`admits`** — the containment relation: per slot, the accepted-kind set plus
   `multi` / `required`. Kind entries are `"any"`, `"shared:<role>"`, a constructor
   name, or a `"@set"` reference. (This is the primitive the older `slots.json` key
   `slots` became.)
4. **`parents`** — where the element is valid (the `admittedBy` source): absent → an
   open row (valid anywhere, the default and most m3e components); a closed list →
   restricted to those parents. Drives R1/R2 (§4).
5. **`_sets`** (`_kinds` in the shipped m3e config) — named kind/context sets,
   referenced as `"@name"` from any kind, parent, or role list. One mechanism, three
   uses; membership changes regenerate everywhere.
6. **`values`** — the enum vocabulary, alias-preserving: tokens minted once
   open-rowed in `M3e.Values`, general union setters in `M3e.Attributes`, narrowed
   setters in `M3e.<Component>`, all fed from the same data.
7. **`roles`** — the ARIA gate (§6): a typed role list per element, or absent → an
   open `String` role setter. m3e gates nothing initially.
8. **`require`** — cardinality and required shape: drives which components get an
   `el` entry point, the `build` capability records, and the
   missing-required/duplicate-singular review facts.
9. **`_coerce` + escape flags** — the blessed brand crossings (§6), plus brand flags
   `delegate` (default on → emit `M3e.Events.delegate`) and `legacyHtml` (native
   only → the one loud `fromHtml` escape). The shipped m3e config sets `_legacyHtml`
   and one `_coerce` entry (Chip→button).
10. **`home`** — module granularity: which module a constructor co-locates in. m3e's
    default is one module per component (`M3e.Button`); the native brand groups
    simple siblings and gives complex elements their own home.

Everything else — both phantom rows, every alias, the two-surface layout, the
list/pipe setter families, event gating, the ARIA hybrid, `delegate`, atoms, review
facts — is an **emission rule** (a projection), not config. The generator is
generator-first and TDD: each pseudo-code target is a golden test, and regeneration
emits exactly those shapes with zero hand-editing.

The full JSON schema — the exact key names and shapes the hand-authored
`config/slots.json` uses — is [`CONFIG_SCHEMA.md`](CONFIG_SCHEMA.md). A component
absent from the config gets safe defaults (a free child row, no required fields, no
groups): its default slot degrades to a loose `"arbitrary"` slot, so everything
still composes and the looseness is *visible* in the generated signature (an open
row) rather than silently wrong. Because being wrong in config is cheap — fix the
entry and regenerate — the config is grown by evidence: most entries ride the
permissive defaults until a real composition proves a tighter fact.

## 8. Regeneration

The pipeline is: **`@m3e/web` CEM + `config/slots.json` in, the two surfaces of
§3 out.** The generator reads each component's manifest for its tag, attributes,
events, and slots, applies the config's per-component facts, and emits the
per-component modules, the general `M3e` / `M3e.Attributes` / `M3e.Events` /
`M3e.Values` surface, the `M3e.Kind` / `M3e.Coerce` / `M3e.Unsafe` support modules,
and the `M3e.Review.Facts` table the `elm-review-cem` rules read. The IR
(`HtmlIr.*`) and the native brand (`TypedHtml.*`) are *not* emitted here — they are
imported dependencies. Regeneration is the release gate: nothing under `src/M3e/`
is ever hand-edited, so the generated output must compile clean before publish. See
the `regenerating-elm-m3e` skill for the exact command sequence.

## Performance

**The API/phantom-type design is not the compile bottleneck; the elm-pages docs
build dominates.** A recurring worry is that the phantom-typed IR, the extensible
capability rows, and the general surface that re-exports every component might be
expensive for the Elm compiler. A benchmark run established it is not: the same
corpus authored across the call-site variants compiled identically within noise
(warm medians well under a second), with no phantom-type penalty — because aliasing
pays each closed row *once* and the docs.json keeps aliases unexpanded across
re-exports and package boundaries. The reported "slow docs compile" is the
**elm-pages toolchain** — the prerender/vite pipeline and the `elm-review` pass it
shells out to (which re-parses everything and runs the full codegen-aware rule set)
— not `elm make` and not this library's type-level design.
