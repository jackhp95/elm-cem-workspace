# Config-primitive catalog — the vocabulary that generates every brand

**Status:** S2 design, for Jack's checkpoint-2 review (fable-max pass 1).
**Grounding:** `2026-07-20-elm-phantom-refactor-alignment.md` (CONSOLIDATED END-STATE),
the three research docs + `/tmp` prototypes, the IR as authored
(`elm-html-intermediate-representation`, main `f6cb02e`), and two code-grounded scans of
the live `elm-m3e/config/*` vocabulary and the `elm-cem` pipeline (2026-07-20).

**North star:** a small set of general, composable config primitives — a brand package is
*data* expressed in this vocabulary; the generator is a set of *projections* of that data
into module shapes. New design system = new data, same vocabulary. New surface = new
projection, same data. Zero post-codegen tweaks, ever.

---

## 0. The model in one paragraph

A brand is a set of **elements** (from a CEM: tag + attrs + events + slots — m3e's is
upstream truth, native's is a hand-authored manifest). Config layers **curation** over
that truth using ten primitives: what an element *is* (`kind`), what its slots *admit*
(`admits`), where it is *valid* (`parents`), how it *groups* into modules (`home`), the
*named sets* shared by all of the above (`sets`), the enum *value* vocabulary (`values`),
the *required* shape (`require`), the ARIA gate (`roles`), two brand-level *escape flags*
(`delegate`, `legacyHtml`), and *docs*. Everything else — both phantom rows, every
alias, the 2-surface layout, Design-A setter families, event gating, ARIA hybrid,
`delegate`, atoms, review facts — is an **emission rule** (a projection), not config.

The IR contract underneath (already authored + oracle-proven): producers keep `accepts`
open / `admittedBy` closed-iff-restricted; containers demand closed kinds + inject an
open context demand; per-brand `Brand`/`Ctx`/`Role` markers give cross-brand nominal
privacy; `Supported`/`Shared` are the only shared markers.

---

## 1. The ten primitives (config vocabulary)

Config stays `--config-from=config/*.json`, deep-merged, same as today. Brand-wide
primitives are top-level `_`-keys; per-element primitives are fields of the element's
entry (entry key = **constructor name**, `tag` field = DOM tag — one tag may have several
entries, which is load-bearing for R2 and groups).

### P1 `element` — the entity (CEM-side, curated)

The CEM supplies tag, attrs (typed), events, slots. Config curation keeps today's proven
keys unchanged: `_exclude`, `syntheticAttrs`, `attrTypes` (enum overrides),
`staticAttrs`, `events` (decoder overrides), `group` (variant groups), `idWiring`,
`_actions`. These already work; the catalog does not reinvent them.

### P2 `kind` — what the element is

```jsonc
"kind": "private"            // default: the brand's own marker (M3e.Kind.Brand)
"kind": "shared:icon"        // this element IS a shared atom of role icon (Kind.Shared)
```
Today's `tier`, renamed. Drives the produced accepts-row field
(`{ acc | button : Brand }` / `{ s | sharedIcon : Shared }`).

### P3 `admits` — the containment relation (slot → kind set)

```jsonc
"admits": {
  "unnamed": { "kinds": ["shared:text", "shared:icon", "menuTrigger"], "multi": true, "required": true },
  "icon":    { "kinds": ["shared:icon"], "multi": false }
}
```
Today's `slots`, renamed to say what it means. `kinds` entries: `"any"` (kind-permissive
— the container still injects its context demand), `"shared:<role>"`, a constructor name,
or a set reference `"@flow"` (P5). Drives: the closed child-demand row, the slot setters,
`multi`/`required` feed P8 and the review facts.

### The `shared:` vocabulary — the cross-library kind namespace

Every kind name in config is a string, and the **`shared:` prefix is the whole grammar**
that separates two very different things:

| Spelling | Emitted row field | Marker | Who can name it |
|---|---|---|---|
| `"button"` (bare) | `button : Brand` | `<Lib>.Kind.Brand` — nominal, **private** | only this brand |
| `"shared:icon"` | `sharedIcon : Shared` | `HtmlIr.Kind.Shared` — **one type, every package** | every brand, forever |

Both `Brand` and `Shared` are phantom markers with no values; the difference is that each
brand's `Brand` is a *distinct nominal type*, so a foreign package naming the field
`button` still would not unify, whereas `Shared` is re-exported from the IR substrate and
is literally the same type in every brand (`<Lib>.Kind.Shared = HtmlIr.Kind.Shared`).

A `Shared` field is therefore **a contract between packages that never see each other's
source**, and its spelling is the whole contract. The vocabulary is closed
(`Generate.Phantom.Model.sharedAtomVocabulary`) and validated twice — once at resolution,
in config vocabulary, and once at emission, on the row field about to be written:

| Role | Means | Produced by |
|---|---|---|
| `shared:text` | a text leaf | `_atoms: { "text": {} }` in every brand → `<Lib>.text : String -> Element { s \| sharedText : Shared }` |
| `shared:icon` | an icon | `M3e.Icon` (`"kind": "shared:icon"`) |
| `shared:link` | a link | **nothing, today** — see the inhabitation note below |
| `shared:flow` | WHATWG *flow content* | the 31 native flow elements (`Div`, `Section`, `P`, `Ul`, …) |
| `shared:phrasing` | WHATWG *phrasing content* | the 52 native phrasing elements (`Span`, `A`, `Em`, `Button`, …) |

`shared:` is legal in three places, all of which are checked: a slot's `kinds`, a
component's `kind`, and a `_atoms` key. A misspelling is a hard error naming the typo and listing the
vocabulary — it used to be silent, and a silent one mints a field no other brand will
ever name: a private kind wearing cross-library clothes.

**The direction rule: a producer names its NARROWEST category; a slot names EVERY
category it admits.** Row unification is subset-directional — the producer's fields must
all be members of the slot's row — so precision is bought on the producer side and
generosity on the slot side, never the reverse:

```jsonc
// producer: narrowest. <span> is phrasing content; it is also flow content, and
// saying so would make it fit FEWER slots, not more.
"Span": { "kind": "shared:phrasing" }
"Div":  { "kind": "shared:flow" }

// slot: everything it admits. A flow slot names phrasing too, because phrasing ⊆ flow
// and the producer only ever writes one of them.
"AppBar": { "admits": { "title": {
  "kinds": ["shared:text", "heading", "shared:flow", "shared:phrasing"] } } }
```

Native config reaches the same place through a set (P5): `@phrasing` and `@flow` resolve
through their members' `kind`, so `TypedHtml.Kind.Flow` comes out as
`{ sharedFlow, sharedPhrasing, + the handful of tags that kept a per-tag kind }` with no
per-slot restatement.

**Inhabitation is NOT checked, and cannot be locally.** The vocabulary closes the
*namespace*; it says nothing about whether anything in the family actually produces a
given role. A slot may name `shared:link` while no component anywhere declares
`"kind": "shared:link"` — which is the state of the family today (two `M3e` slots name it;
`grep -rn '"shared:link"' */config` finds no producer). That is the same shape as the
`"html"` defect: a slot row reserving a seat nothing can sit in. It is not checkable
inside one brand, because the producer legitimately lives in a *different package* that
this generator run never sees. Treat "is anything producing this role?" as a family-level
review question.

### The crossing theorem — a limit of the encoding, not a gap in the config

> **A producer can be discriminated by its own brand's slots, or admitted by a foreign
> brand's enumerated slots, but not both.**

This has been independently rediscovered three times. It is not a deferral or a missing
feature: it follows directly from subset-directional row unification. Adding a field to a
producer makes it fit **fewer** slots, so the only field that would let a component leave
its brand is the same field that stops its own brand discriminating it.

Both halves are pinned as compiled acid probes against the `mini` fixture brand
(`tests/phantom/acid/bad/`), where `Mini.Chip` keeps its brand kind, `Mini.Icon` declares
`"kind": "shared:icon"`, and `Mini.Button`'s `icon` slot is enumerated over shared atoms
alone (`IconSlot = { sharedIcon : Shared }` — exactly the row a foreign brand would
write, since `Shared` is the only marker two packages can both name).

**Half one — discriminated, therefore not admitted** (`bad/BrandKindIntoSharedSlot.elm`):

```elm
Mini.Button.icon (Mini.chip [] [ Mini.text "not an icon" ])
```
```
-- TYPE MISMATCH
This `chip` call produces:
    Mini.Element (Mini.Chip.Is { a | sharedIcon : HtmlIr.Kind.Shared }) admittedBy msg
But `icon` needs the 1st argument to be:
    HtmlIr.Element.Element Mini.Button.IconSlot admittedBy msg
```

`Chip.Is` carries `chip : Mini.Kind.Brand`, which is not a member of `IconSlot` — and no
foreign brand could put it there, because `Mini.Kind.Brand` is nominally private, so
naming the field in another package would not make the types unify.

**Half two — admitted, therefore not discriminated** (`bad/SharedAtomHasNoBrandKind.elm`):

```elm
broken : Element { icon : Mini.Kind.Brand } admittedBy msg
broken =
    Mini.icon [] [ Mini.text "star" ]
```
```
-- TYPE MISMATCH
This `icon` call produces:
    Mini.Element (Mini.Icon.Is { a | icon : Mini.Kind.Brand }) admittedBy msg
But the type annotation on `broken` says it should be:
    Element { icon : Mini.Kind.Brand } admittedBy msg
```

`{ icon : Mini.Kind.Brand }` is precisely the row a slot would need in order to say "an
icon of MINE and nothing else". There is no such field: `"kind": "shared:icon"` replaced
it with `sharedIcon : Shared`, which is what buys admission into `Button.icon` and into
any foreign brand's icon slot. Adding the brand field back would break that admission, by
half one. The two halves are one fact.

The consequence, stated once so it is not re-derived a fourth time: **a design-system
component cannot enter a foreign brand's enumerated slot.** The sanctioned answers, none
of which change the theorem:

1. **A kind-permissive container** — `"kinds": ["any"]` emits a free child row. In the
   native brand 34 of 105 containers are already free (`div`, `section`, `article`,
   `header`, `main_`, `form`, …), so ordinary wrappers take foreign children with no
   ceremony. The failure is confined to phrasing-level and table/list-level containers.
2. **A shared atom on both sides** — the `shared:` vocabulary above. This is the channel
   that *does* cross, and it is why `text` and `icon` flow in both directions.
3. **The general loud crossing** — `recast`, generated into every brand's `<Lib>.Unsafe`,
   which re-stamps any `Element a` as any `Element b` with no semantic claim. Correct
   precisely where the crossing is a claim the compiler cannot check, and wrong as a
   default; wrap it in a small, named local function when the same crossing recurs.

What is *not* an answer: making the producer name the shared atom exclusively so it fits
everywhere. That compiles, and it is the disaster case — a component with only
`{ sharedCustomElement : Shared }` fits a foreign phrasing slot *and* its own brand's
menu-item slot, so a Card becomes a legal Menu item. Half two is the local, compiled form
of that argument.

### P4 `parents` — where the element is valid (the admittedBy source)

```jsonc
// absent            → OPEN admittedBy: valid anywhere (the default; most DS components)
"parents": ["select", "optgroup"]     // closed: only valid as a direct child of these
"parents": "@flowContainers"          // closed to a named set
```
**Explicitly a primitive, not a transpose.** A scan of the live model shows why:
appearing in some slot's `kinds` list does not mean restricted-to-it (m3e `button` sits
in ten slots *and* any layout `div`). The WHATWG transpose is merely how native's
manifest-gen *populates* `parents` for the genuinely restricted elements
(option/li/td/legend/summary/dt/dd/track/…). Absent = open row = zero cost.

Emission: closed `parents` → the element's `<Ctor>AdmittedBy` alias over the brand's
`Ctx` marker.

**R1 (generator-enforced config discipline):** within one container slot, every
closed-`parents` member of the kind set must carry an *identical* parents set (Elm lists
are homogeneous). The generator groups elements by parents-set, emits ONE shared
`…AdmittedBy` alias per group, and **fails loudly** naming the offenders and the two
fixes: widen a member's `parents`, or —
**R2:** split the element into two constructor entries with different `parents`
(`source` `{audio,video}` vs `pictureSource` `{picture}`). R2 needs no new primitive:
entry-key-≠-tag already provides it.

### P5 `_sets` — named kind/context sets (one mechanism, three uses)

```jsonc
"_sets": {
  "flow":     ["div", "p", "ul", "blockquote", "…"],
  "phrasing": ["span", "em", "strong", "…"],
  "interactive": ["a", "button", "input", "select", "textarea"]
}
```
Referenced as `"@name"` from any kind list (`admits`), parent list (`parents`), or role
list (`roles`). Emission: each set used in a kind position becomes a kind-row alias; used
in a parent position becomes a context alias (`FlowCtx`); membership changes regenerate
everywhere. This single primitive replaces categories, context aliases, and slot-union
declarations. Native's sets are the WHATWG content categories (manifest-gen emits them);
m3e's are small and hand-curated.

### P6 `values` — the enum vocabulary (alias-preserving)

Upstream truth: CEM attr types. The `inlineTypeAliases` pass is **reversed into
alias-recording**: it still resolves `ButtonVariant` → `"filled"|"tonal"|…` (the enum
classifier needs the union to mint tokens) but now *keeps the alias name* on the attr
(`type.aliasName`), and the emitter names the Elm alias after it. Config keeps
`attrTypes` for overrides. Emission (Design A, both surfaces from the same data):

- tokens minted ONCE, open-rowed, in `Brand.Values`: `filled : Value { v | filled : Supported }`
- general setter closes the **union** across components: `Brand.Attributes.variant : Value Variants -> …` (misuse across components = elm-review, by design)
- specific setter closes the component's own set: `Brand.Button.variant : Value ButtonVariant -> …` (compile-tight)
- pipe family from the same data: `Brand.Button.withVariant : Value ButtonVariant -> Builder { a | variant : Available } s msg -> Builder { a | variant : Used } s msg`

### P7 `roles` — the ARIA hybrid gate

```jsonc
"roles": ["@landmarks", "button", "presentation", "none"]   // typed gate for this element
// absent → open String role setter (today's stance) — the deliberate hybrid
```
Plus brand-wide `_aria`: the role token vocabulary and the enumerated aria-* states
(`aria-checked` tristate etc.) as data. Emission: gated elements pin
`role : <Ctor>Roles` in their attrs alias (element side aliased; token side stays open —
the known error-noise asymmetry is why the long tail stays un-gated); enumerated states
become value-typed setters; universal aria-* stay open; role×state goes to the facts for
lint. Native config gates the high-value set (generic containers + interactive elements);
m3e gates nothing initially.

### P8 `require` — cardinality and required shape

Today's `required`-in-slot + component `required.action` + `requiredAttrs`, unchanged in
meaning. Drives: which components get an `el` entry point (required record), the `build`
capability records, and the missing-required/duplicate-singular review facts.

### P9 two escape flags

Brand flags, unrelated to each other: `"delegate": true` (default — emit
`Brand.Events.delegate`, the capability-forget escape) and `"legacyHtml": true` (native
only — emit the ONE loud `TypedHtml.Unsafe.fromHtml` legacy-interop escape over
`fromNode << fromHtml`). There is no config-declared kind-crossing primitive: every
brand's generated `Unsafe` module already carries `recast = fromNode << toNode`
unconditionally, with no config gate — see [Retired outright](#retired-outright) for
why a narrower, config-declared `_coerce` primitive was tried here and then removed.

### P10 `home` — module granularity (the learning-surface axis)

```jsonc
"home": "Table"        // this constructor co-locates in Brand.Table
// absent → DS default: own module per component (M3e.Button); native manifest sets
// homes per the IA taxonomy (composition families own a module; category siblings group)
```
Emission: a home module holds its members' constructors + element-unique attrs +
co-located re-exports of the shared attrs its members admit (one-liner aliases; the
canonical definition lives in `Brand.Attributes` — the confirmed canonical-attr rule) +
its `<Ctor>Roles` aliases. `transparent: true` on an entry (a/ins/del) emits the
row-threading signature (own kind row = children's accepts row) instead of fixed rows.

### `_renames` — identifier override escape hatch

```jsonc
"_renames": {
  "ButtonElement": { "attr:with-icon": "iconAttr" },     // per-component attr rename
  "_events":   { "custom-click": "onCustomClick" },      // brand-level event rename
  "_tokens":   { "AUTO": "autoUpper" },                   // brand-level token rename
  "_elements": { "my-text": "textEl" }                    // brand-level element ctor rename
}
```

When identifier collisions on the deterministic rules would silently delete real API or
force ugly renames for aesthetic reasons, `_renames` provides an escape hatch: override a
**raw CEM source** (attribute name, event name, token string, element tag) to a new Elm
identifier **before** the collision-resolution rules run. The override is **final** — the
deterministic rules then see the renamed identifier and build all projections (setter,
builder, handler pair, etc.) from it.

**Per-component renames** (`"ButtonElement": { "attr:with-icon": "..." }`):
- Key = constructor name (derived from tag, e.g. `"my-button"` → `"Button"`).
- Value object maps `"attr:<htmlName>"` → new setter/row-field elm name.

**Brand-level renames**:
- `"_events"`: raw event name → handler identifier (the `on<X>` base name; both `on<X>`
  and `on<X>With` pair rename together).
- `"_tokens"`: raw token string (e.g. `"AUTO"`, `"_top"`) → token ident (e.g.
  `"autoUpper"`). Raw token payload to `Ir.token` stays unchanged.
- `"_elements"`: tag name → barrel constructor ident (e.g. `"fluent-text"` →
  `"fluentText"`).

**Validation (fail-loud):** a rename referencing a nonexistent source (unknown tag, unknown
attr on that tag, unknown event/token/element name) causes generation to exit non-zero with
a clear error naming the unknown source.

### `_controlled` — attributes whose LIVE state is a DOM property

```jsonc
"_controlled": {
  "value":    { "companion": "defaultValue",    "elements": ["input"] },
  "checked":  { "companion": "defaultChecked",  "elements": ["input"] },
  "selected": { "companion": "defaultSelected", "elements": ["option"],
                "resyncs": false, "resyncWith": "change" },
  "muted":    { "companion": "defaultMuted",    "elements": ["audio", "video"],
                "resyncs": false, "resyncWith": "volumechange" }
}
```

Keyed by the **content-attribute name**, which for every member of this roster is also
the IDL property name. A member emits `Ir.property` instead of `Ir.attribute`, plus a
`default<Name>` companion that writes the content attribute — mirroring HTML's own
live/default IDL split. The companion **claims the base capability row**
(`defaultValue` is `{ c | value : Supported }`), so no element's `Attrs` record grows a
field. This roster replaced a hardcoded `[ "value", "checked", "selected" ]` list
inside the emitter that silently outranked the per-component `attrForm` override.

**`elements` is the element SCOPE, and omitting it is a sharp edge.** Without it the
entry covers every element declaring the attribute — which is a claim about
`HTMLElement`, and `value` is not one attribute. In `elm-typed-html`'s manifest seven
elements declare a `value` content attribute at **three** IDL types: `DOMString` on
`<button>`/`<data>`/`<option>`, `long` on `<li>`, and `double` on
`<meter>`/`<progress>`. Web IDL rejects a non-finite `double` with a **TypeError**, and
`elm/virtual-dom` applies property facts inside `_VirtualDom_applyFacts` — during
patch — so `TypedHtml.Text.value "abc"` on a `<progress>` aborted the patch and took
the whole render loop with it. Only `<input>` genuinely needs the property form (its
dirty-value flag makes the live value diverge from the content attribute); the other
six **reflect**, so the content attribute is both correct and SSR-visible. Scope every
entry to the elements whose live state actually diverges.

Scoping also removes a misleading `default*`: HTML gives `HTMLOptionElement` and
`HTMLButtonElement` no `defaultValue` at all, and once they are out of scope their
plain `value` setter writes the content attribute those elements do want — under the
name HTML gives it.

**When one name ends up in both forms**, the shared `<Lib>.Attributes` canonical takes
the **content-attribute** form. That surface is admitted by every element whose row
carries the field, so when one body cannot be right for all of them it must be the one
that cannot crash: `Ir.attribute "value"` is at worst STALE on an `<input>` (issue
#41), while `Ir.property "value"` on a `<progress>` throws. The live setter stays
reachable — and is the only form — in the element's own module, and the shared
setter's generated docs name it. A stderr info note names the split.

`resyncs` defaults to `true` and may only truthfully be claimed by `value` and
`checked`: `elm/virtual-dom`'s controlled-input machinery is hardcoded to those two
NAMES, so every other property fact is compared by identity and an unchanged value is
skipped forever. The property form fixes INERTNESS, not RESYNC; `resyncs: false` makes
the emitter document that and name `resyncWith` as the event to listen to.

`companion` may be `false`/omitted when nothing in the brand has a backing content
attribute. Per element, `propertyOnly: ["<attr>"]` keeps the property setter and drops
the companion (`<output>`'s `defaultValue` is a property with no content attribute at
all); `attrForm: { "<attr>": "attribute" }` opts one element back out entirely.

**Validation (fail-loud):** an `elements` name matching no element, or an element that
does not declare the attribute, or an empty `elements` list, or a malformed one, or
`propertyOnly` on an element outside the scope (there is no live property there to
keep), or two elements of ONE `home` module ending up at different forms (one module
cannot expose one setter in two forms, and the wrong one is a silent runtime bug rather
than a type error).

### `_variants` — extra setter types for one attribute

```jsonc
"_variants": {
  "step":   [ { "name": "stepAsNumber",  "type": "float" } ],
  "coords": [ { "name": "coordsAsInts",  "type": "ints", "separator": "," } ],
  "value":  [ { "name": "valueAsNumber", "type": "float" } ]
}
```

Keyed by the **base attribute's HTML name**. Each variant is an extra setter in
`<Lib>.Attributes` (re-exported by the home / per-component modules like any other) that
writes the **same DOM fact** as the base — same name, same attribute-vs-property form —
differing only in the Elm type it accepts.

A variant **claims the base attribute's capability row**: `stepAsNumber` is
`Float -> Attr { c | step : Supported } msg`, so **no element's `Attrs` record grows a
field**. An element that admits `step` admits every way of writing it; one that does not
already rejects them all. Same discipline as a `_controlled` `default*` companion.

This is for attributes whose **spec-correct type is a string** but whose common case is
narrower. HTML does exactly this itself — `HTMLInputElement` has `value`, `valueAsNumber`
and `valueAsDate` — and the base must keep the wider type or legal values become
unexpressible: `step="any"` is a keyword no `Float` writes, and `coords="0,0,82,126"` is a
comma-separated list. **Never narrow the base and call the variant a replacement.**

`type` is a closed set — `float` (via `String.fromFloat`), `int` (`String.fromInt`), `ints`
(a `List Int` joined with `separator`, default `","`). Anything else fails LOUD rather than
degrading to a string setter.

**Validation (fail-loud):** a `base` no component in the brand declares exits non-zero —
otherwise the variant would emit nothing at all, silently. The variant's `name` shares the
`<Lib>.Attributes` namespace and is collision-checked there.

**Not expressible:** a variant needing a JS object (HTML's `valueAsDate` wants a `Date`).
`Json.Encode` cannot construct one, so such a setter is unreachable from Elm; there is
deliberately no `type` for it.

### (docs) P1-adjacent, unchanged

`examples.*.json`, `native-mdn.json`, `categories.json` keep their shapes; the examples
regenerate against the new surfaces (the two dead forms' examples drop).

---

## 2. Emission rules (projections — the generator's contract)

**E1 — two-row constructors.** Per entry: producer-open accepts row (`Is s`-style alias),
closed child demands from `admits` (+ context-demand injection `{ childAdm | <ctor> :
Ctx }`), closed `<Ctor>AdmittedBy` from `parents` when present, R1 grouping + loud
failure, `transparent` threading. Atoms (`kind: shared:*`) emit open-adm producers.

**E2 — alias everything, preserve everything.** `<Ctor>Attrs`, per-slot rows,
`<Ctor>AdmittedBy` (+ shared per-parents-set aliases), set aliases (`FlowCtx`…) in
`Brand.Kind`, `<Alias>`-named value rows from P6, `<Ctor>Roles`. Every emitted signature
references aliases by name; nothing is ever re-inlined. (Docs-cap + error-cleanliness
both hang on this — probe-proven.)

**E3 — the 2-surface projection.**
- General: `Brand` (constructors, elm/html-shaped, + shared atoms `text`/…),
  `Brand.Attributes` (canonical shared + global attrs, union value setters),
  `Brand.Events` (capability-gated events + `delegate`), `Brand.Values` (tokens),
  `Brand.Kind` (markers `Brand`/`Ctx`/`Role` + set aliases). Re-export doc-comments are
  ONE line ("See `Brand.Table.tr`.") — doc mass is the cap driver.
- Specific: `Brand.<Component|Home>` — `view` always; `el` iff `require` non-empty;
  `build` + `with*` pipe setters (cardinality); narrowed value setters; co-located
  re-exports; composition helpers for family homes.

**E4 — events as capabilities.** Per-element CEM events (m3e) / `@interactive` set +
per-element lists (native) close each element's capability row; `onClick` on a
non-interactive element is a compile error (oracle-proven on the IR). Bubbling =
`delegate`, nothing else.

**E5 — facts projection.** The same model emits `Brand.Review.Facts` (schema extended
for: descendant rules, role×state, general-surface value-union misuse). elm-review-cem
stays lockstep.

**E6 — docs projection.** Examples/MDN summaries into doc-comments; unchanged mechanism.

**Retired outright:** `injectRuntime` + the `Markup→lib` rename + `ownsRuntime` (the IR
is imported: `import HtmlIr.Internal`), the Raw/Html/Record/Build module quintet (2
shapes replace 5), the barrel-as-6th-restatement (the general surface IS the terse
surface), `_seams`/Seam (atoms are first-class; the only crossing is `recast`, plus
the `delegate`/`legacyHtml` flags), `inlineTypeAliases`-as-expansion (becomes
alias-recording), and `_coerce` (P9's `Brand.Coerce.<name>` crossings) — the
`coerceModule` generator function that would have emitted `Brand.Coerce.elm` was
written but never wired into the emitter's output list, so it never actually shipped
despite this doc once describing it as current (§1 P9, §2 the crossing-theorem answer
list). Removed outright rather than wired up: `recast`, generated unconditionally into
every brand's `Unsafe` module, already covers the same ground without a second,
config-only escape surface for reviewers to track.

---

## 3. Pseudo-code targets (the golden-test specs)

These are the S3 golden tests — the generator is done when it emits exactly these shapes
from exactly this config. (Abridged here to the type-bearing lines; the golden files pin
the full text.)

### 3.1 `M3e.Button` (specific surface) ← config

```jsonc
"Button": {
  "admits": { "unnamed": { "kinds": ["shared:text", "shared:icon", "menuTrigger"],
                            "multi": true, "required": true },
              "icon":    { "kinds": ["shared:icon"], "multi": false } },
  "required": { "action": "action:click,link,menuTrigger" }
  // kind: private (default) · parents: absent → open admittedBy · home: own (default)
}
```

```elm
module M3e.Button exposing
    ( view, el, build, toElement
    , Attrs, Content, IconSlot, Is
    , variant, withVariant, Variant, icon, withIcon, …
    )

type alias Is s = { s | button : M3e.Kind.Brand }
type alias Attrs = { class : Supported, disabled : Supported, …, variant : Supported, onClick : Supported, slot : Supported }
type alias Content = { sharedText : Kind.Shared, sharedIcon : Kind.Shared, menuTrigger : M3e.Kind.Brand }
type alias Variant = { filled : Supported, tonal : Supported, outlined : Supported, elevated : Supported, text : Supported }

view : List (Attr Attrs msg) -> List (Element Content { childAdm | m3eButton : M3e.Kind.Ctx } msg) -> Element (Is s) admittedBy msg
el   : { content : Element Content …, action : Action … } -> List (Attr Attrs msg) -> Element (Is s) admittedBy msg
build : { content : …, action : … } -> Builder AttrCaps SlotCaps msg
variant : Value Variant -> Attr { c | variant : Supported } msg          -- narrowed (compile-tight)
withVariant : Value Variant -> Builder { a | variant : Available } s msg -> Builder { a | variant : Used } s msg
```

### 3.2 General surface excerpts ← same data, no extra config

```elm
-- M3e.elm
button : List (Attr M3e.Button.Attrs msg) -> List (Element M3e.Button.Content { childAdm | m3eButton : M3e.Kind.Ctx } msg) -> Element (M3e.Button.Is s) admittedBy msg
text : String -> Element { s | sharedText : Kind.Shared } admittedBy msg    -- atom, re-exported

-- M3e.Attributes.elm (union setter; cross-component misuse = elm-review)
variant : Value M3e.Values.Variants -> Attr { c | variant : Supported } msg

-- M3e.Events.elm
onClick : msg -> Attr { c | onClick : Supported } msg
delegate : Attr capability msg -> Attr anyCapability msg                    -- the loud escape

-- M3e.Values.elm (tokens minted once, open rows)
filled : Value { v | filled : Supported }
```

### 3.3 `TypedHtml.Table` home (composition family, R1 visible) ← native manifest

```jsonc
"table": { "home": "Table", "admits": { "unnamed": { "kinds": ["caption", "colgroup", "thead", "tbody", "tfoot", "tr"] } } },
"tr":    { "home": "Table", "parents": ["table", "thead", "tbody", "tfoot"],
           "admits": { "unnamed": { "kinds": ["td", "th"] } } },
"td":    { "home": "Table", "parents": ["tr"], "admits": { "unnamed": { "kinds": ["@flow"] } } },
"th":    { "home": "Table", "parents": ["tr"], "admits": { "unnamed": { "kinds": ["@phrasing"] } } }
```

```elm
module TypedHtml.Table exposing (table, tr, td, th, thead, …, colspan, rowspan, TrAdmittedBy, CellAdmittedBy, …)

type alias CellAdmittedBy = { tr : TypedHtml.Kind.Ctx }                 -- td+th share it (R1 group)
tr : List (Attr TrAttrs msg) -> List (Element { td : Kind, th : Kind } { childAdm | tr : Ctx } msg) -> Element { acc | tr : Kind } TrAdmittedBy msg
colspan : Int -> Attr { c | colspan : Supported } msg                    -- canonical in TypedHtml.Attributes; re-exported here (one-liner)
```

Acid tests carried as goldens: option-in-div fails · td-in-div fails · `<track>` in
`<picture>` fails while `source` works in both (R2 split) · zero call-site annotations on
a full table (`/tmp/htmlia` before/after pair, verbatim).

### 3.4 ARIA hybrid excerpt ← `roles` + `_aria`

```elm
-- TypedHtml.Grouping (home): type alias DivRoles = { navigation : Role, region : Role, presentation : Role, none : Role, … }
-- TypedHtml.Aria (concern axis): role : Value roleTags -> Attr { c | role : Supported } msg ; navigation : Value { r | navigation : Role } ; checked : Tristate -> …
-- div [ Aria.role Aria.navigation ] ✓ · div [ Aria.role Aria.tab ] ✗ · checked "sortof" ✗
```

---

## 4. Why this vocabulary is the composable one (the checkpoint-2 argument)

- **Ten primitives, three of them new** (`parents`, `_sets`, `roles`; `kind`/`admits`/
  `home` are renames of proven keys; the rest carry over verbatim). Everything the design
  demands — both rows, R1/R2, ARIA hybrid, Design A, 2-surface, delegate, atoms, recast,
  facts — falls out as projections. No feature-shaped config anywhere: shoelace needs
  *data* under the same keys, nothing else.
- **Orthogonality:** kind (what) ⊥ admits (contains) ⊥ parents (contained-by) ⊥ home
  (where taught) ⊥ values (enums) ⊥ roles (ARIA). Each varies independently; sets factor
  the shared vocabulary out of all of them.
- **Post-hoc tweaks are config edits:** wrong nesting rule → `parents`/`admits`; noisy
  module → `home`; missing gate → `roles`; kind-crossing the design system genuinely
  needs → `recast`, not a config edit at all. Never code.
- **Failure surfaces are generation-time and loud** (R1 grouping, unknown set refs,
  alias-name collisions) — the config is type-checked by the generator before Elm ever
  sees it.

## 5. Open questions for Jack (checkpoint 2)

1. **`M3e.Kind.Ctx` context fields for DS containers** — m3e containers inject
  `{ childAdm | m3eButton : Ctx }`-style demands. Cheap and future-proof (lets a later
  config declare restricted-parent DS elements, e.g. m3e-tab → m3e-tabs). Emit the
  demand always (recommended, zero user-visible cost), or only when some element's
  `parents` references the container?
2. **General-surface constructors reference specific aliases** (`M3e.Button.Attrs` in
  `M3e.button`'s signature) — one definition, docs stay deduped, but the general module
  publicly depends on every component module. Alternative: re-alias in the general
  module (+130 tiny aliases). Recommended: reference (measured stance of the probes).
3. **Native brand naming:** `TypedHtml` as both package brand-prefix and general module
  (`TypedHtml`, `TypedHtml.Attributes`, …) per the prompt. Package name for its dev home
  (e.g. `jackhp95/elm-typed-html`) — pick at S4.
4. **`_actions` carry-over:** kept as-is for m3e (it's proven config). Reframe into a
  general primitive only if a second brand needs it (shoelace likely doesn't).
