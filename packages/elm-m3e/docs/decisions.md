# Decisions

> **Reconciliation banner (pass 2, 2026-07-21).** The **elm-phantom refactor** (merged) has
> superseded several decisions below. In particular: the shared runtime is now the
> **`HtmlIr.*`** IR published as `elm-html-intermediate-representation` and **imported, not
> injected** — there is no `Markup.*` runtime, and `injectRuntime` / string-rewrite copying is
> retired. The **facet-family packaging** (CX11) and **copy-only publish mirrors** (CX12) are
> retired: elm-m3e ships as a **single** `jackhp95/elm-m3e` package with **two surfaces**
> (general `M3e`/`M3e.Attributes`/`M3e.Events`/`M3e.Values` + per-component `M3e.<Component>`),
> not a 5-form/multi-package stack. The kind/atom/seam/coercion *reasoning* below still holds;
> only the runtime name (`Markup.*`→`HtmlIr.*`) and the packaging (facets→one package) changed.
> This trail is preserved for the "why"; trust `src/`, `elm.json`, and the reconciled guides
> for current names.

This is the living record of the durable design decisions behind elm-m3e —
the "why is it built this way?" answers that don't live comfortably in the code
or the reference docs. It is a companion to [`DESIGN.md`](DESIGN.md), which is
the theory of operation; this file is the reasoning trail. Each section states
one decision and the thinking that produced it, in prose. Where a decision was
recorded during development as a numbered ADR (the `docs/adr/` tree that has since
been folded into `DESIGN.md`), the number is noted in parentheses for anyone
digging through history. It is meant to be edited as the design keeps moving, not
frozen.

## Cross-CEM initiative (CX1–CX14, landed 2026-07-12)

The following decisions were made during the cross-CEM initiative that added a
shared runtime (`Markup.*`), per-library kind branding, a shared atom vocabulary,
explicit seam crossings, and facet-family packaging. They are recorded as a block
here and referenced from [`DESIGN.md §layers`](DESIGN.md) and the guides
([`Seams`](guides/Seams.md), [`TheLayers`](guides/TheLayers.md),
[`Glossary`](guides/Glossary.md)).

- [CX1 — Extract the runtime into a shared `markup` package](#cx1--extract-the-runtime-into-a-shared-markup-package)
- [CX2 — Brand kind rows per library](#cx2--brand-kind-rows-per-library)
- [CX3 — Two kind tiers: private brand vs shared atom](#cx3--two-kind-tiers-private-brand-vs-shared-atom)
- [CX4 — Atom vocabulary v1: text, link, label, icon](#cx4--atom-vocabulary-v1-text-link-label-icon)
- [CX5 — Seams are loud; coercions are config-blessed sugar](#cx5--seams-are-loud-coercions-are-config-blessed-sugar)
- [CX6 — The markup package is a real generated peer](#cx6--the-markup-package-is-a-real-generated-peer)
- [CX7 — Unknown atom roles are a warning, not silent](#cx7--unknown-atom-roles-are-a-warning-not-silent)
- [CX8 — The generator ships nothing library-specific](#cx8--the-generator-ships-nothing-library-specific)
- [CX9 — `NoSeamOutsideAllowedModules` takes a config record](#cx9--noseamoutsideallowedmodules-takes-a-config-record)
- [CX10 — markup is developed in the elm-cem repo, not a separate repo](#cx10--markup-is-developed-in-the-elm-cem-repo-not-a-separate-repo)
- [CX11 — Facet-family packaging: one package per facet](#cx11--facet-family-packaging-one-package-per-facet)
- [CX12 — Copy-only publish mirrors](#cx12--copy-only-publish-mirrors)
- [CX13 — Archive-first history convention](#cx13--archive-first-history-convention)
- [CX14 — No tracer; land each workstream complete](#cx14--no-tracer-land-each-workstream-complete)

### CX1 — Extract the runtime into a shared `markup` package

Before the cross-CEM initiative, every elm-cem-generated library got its own copy
of the runtime (`Element`, `Node`, `Value`, `Html.Attr` modules) via a
string-rewrite of `M3e`→`<lib>` over a template. That meant `M3e.Element.Element`
and `Markup.Element.Element` are distinct nominal types, so there is no safe way
for elements from one library to enter slots of another. Any composition across
libraries requires dropping to `Html` at the boundary via `toHtml`/`fromHtml`, with
no type-level claim about the result — the boundary is untyped.

The fix is to extract the runtime once and publish it as its own Elm package
(`jackhp95/markup-core`). All generated libraries then depend on the same published
package and share the same nominal `Element` type. The per-library `String.replace`
is replaced by an `ownsRuntime` config flag: `markup` generates with `ownsRuntime:
true` and emits all runtime modules; every other library generates with
`ownsRuntime: false` and imports from `Markup.*`.

The `markup` package is co-located with the generator in the `elm-cem` repo. This
is the only arrangement that avoids a build cycle: the generator needs a foundation
to emit against, and the foundation must itself be generated.

**What landed:** `config/runtime.json` in the elm-m3e repo sets
`{"_runtime": {"owns": false}}`. The regen drops 12 runtime modules from `src/`,
flips all import bases from `M3e.*` to `Markup.*`, and shrinks
`exposed-modules` from 619 to 611. The `markup/` package skeleton lives in
`elm-cem/markup/`; its standalone `elm make --docs` produces a 14 KB docs.json.

### CX2 — Brand kind rows per library

Sharing the `Markup.Element.Element` type dissolves the nominal island but over-
opens the system: without further constraint, any element from any library could
enter any slot of any other. The goal is the opposite — components should by default
reject foreign elements, so cross-library composition is a deliberate opt-in, not an
accident.

The mechanism is a per-library opaque phantom brand. Each generated library gets its
own `<Lib>.Kind.Brand` type (e.g., `M3e.Kind.Brand`). Component producers carry an
open row with their brand (`{ s | button : M3e.Kind.Brand }`); component slots carry
a closed row that names only the brands they accept. Because `M3e.Kind.Brand` and
`Markup.Kind.Brand` are distinct nominal types, a Markup element cannot unify with a
slot expecting `M3e.Kind.Brand`. This is pure compile-time enforcement — zero runtime
cost, no sentinel values, no wrappers.

**What landed:** `src/M3e/Kind.elm` exposes an opaque `Brand` type. Every
standard, raw, html, record, and build facet producer carries `M3e.Kind.Brand` in
its kind row. Slot closed records name only the brands and atoms they accept.
The `Supported` type was removed from kind rows entirely; it survives only on value
and attribute capability rows.

**Reality vs plan:** the plan stated that `Supported` would "disappear from kind
rows". This is accurate — kind rows now carry only `M3e.Kind.Brand` or
`Markup.Kind.Shared`, never `Supported`.

### CX3 — Two kind tiers: private brand vs shared atom

Most components are structural and should reject elements from other libraries. A
small vocabulary of content leaves (text nodes, links, labels, icons) should flow
freely across libraries. A single binary (M3e.Kind.Brand vs Markup.Kind.Shared) per
slot field achieves both ends without a special bridging type.

Config per component chooses one of two tiers:

- **private** (default): the component's kind row carries `<Lib>.Kind.Brand`. Slots
  typed with a private kind reject anything not carrying that exact brand.
- **role** (atom tier): the component's kind row carries `Markup.Kind.Shared`. Any
  library's slot that opts in to the matching atom role (`shared:text`,
  `shared:link`, etc.) will accept that element — the shared type unifies.

The default is `private`. Teams must explicitly opt a component into the role tier
in config; unrecognized components are segregated.

**What landed:** `config/slots.json` `"tier": "private"` (default) or
`"tier": {"role": "text"}` etc. The generator carries the chosen marker through all
five facet emitters and the slot-record sites. Barrel `unionSlotKinds` resolves
Brand/Shared conflicts on the same field name by preferring `shared:` (so the barrel
exposes the widest admissible kind without producing duplicate fields). Per-component
modules keep their exact configured marker.

### CX4 — Atom vocabulary v1: text, link, label, icon

The shared atom set is intentionally small and ARIA-shaped. A larger set risks
under-specifying accessibility contracts (is `heading` the same regardless of
level?) and over-coupling libraries to an evolving vocabulary. The v1 set is the
four roles the M3e slot curation exercise found most commonly needed:

| Atom | Kind field | Accessibility constraint |
|------|-----------|--------------------------|
| text | `text` | none beyond UTF-8 content |
| link | `link` | requires `href` + ≥1 text child (WCAG 2.4.4) |
| label | `label` | closed child slot: `{ text : Shared, icon : Shared }` |
| icon | `icon` | must be decorative (`iconDecorative`) or labeled (`iconLabeled`) |

Future atoms (`heading`, `image`) are non-breaking additions. The contracts are
enforced at the `Markup.Atoms` constructor level; the type system rejects empty
links and unlabeled icons.

**Reality vs plan:** `heading` and `image` are deferred — flagged to Jack for the
pre-release decision. The markup package has 16 HTML elements in its v1 manifest;
`ol`, headings, and `img` are also deferred for the same reason.

### CX5 — Seams are loud; coercions are config-blessed sugar

Before the cross-CEM initiative the seam model had one crossing: `recast` in the
`Seam` module. `recast` converts any `Element` to any other kind, with no semantic
claim. It was always loud (greppable, review-enforced), but it was the only tool
whether the crossing was well-reasoned or opportunistic.

The cross-CEM work adds a second lever: **config-declared coercions**. A `_coerce`
block in `config/slots.json` lists named crossings (`{from, fromKind, to, name}`);
the generator emits a `<Lib>.Coerce` module with typed functions (e.g.,
`M3e.Coerce.asButton : Element { k | chip : M3e.Kind.Brand } msg -> Element { s | button : M3e.Kind.Brand } msg`).
These are blessed typed crossings: they make a semantic claim (a Chip *acting as* a
button) and they are config-tracked. `recast` remains the general escape — any loud
crossing that does not have a stable semantic identity uses `recast`.

The distinction (decision): `recast` = general loud crossing; named coercion =
blessed sugar for crossings with a stable identity.

**What landed:** `src/M3e/Coerce.elm` exposes `asButton`. The implementation is
`Element.toNode >> Element.fromNode` (the same mechanism as `recast`, but typed to
the specific from/to brands). Build-shape tests prove `asButton` allows the
chip-into-button crossing that is otherwise rejected.

**Reality vs plan:** the plan suggested the `fromKind` field would use the Elm kind
field name. What landed: the config entry is
`{"from": "Chip", "fromKind": "chip", "to": "button", "name": "asButton"}` and the
emitter converts these to the actual kind field names. The coercion signature uses
the from-component's `Brand`, not a generalized kind — both sides are `M3e.Kind.Brand`
(Chip re-brands as button, both in the same library).

### CX6 — The markup package is a real generated peer

Markup is not hand-written HTML wrappers. It is a full generated peer library,
produced by the same elm-cem generator pipeline as elm-m3e, from its own CEM
manifest. This is the proof of the generator's library-agnosticism (CX8).

The markup surface is curated and intentional. Its v1 manifest contains 16 HTML
elements. The hand-written layer is only the atom constructors (`Markup.Atoms`) —
these enforce accessibility contracts at the type level and cannot be purely
generated because their signatures are the design, not a derived fact from any spec.

**What landed:** markup generates with `ownsRuntime: true`, producing the standard,
raw, html, and build facets. The record facet was skipped — HTML elements have no
required singular slots that benefit from a record form. The docs.json for the
standard (largest) facet measured at 132,168 bytes (18% of the 700 KB gate).
Slot kinds are closed: generated markup components reject foreign brands. Atoms
are accessibility-typed: `link` requires a content child, icons require a decorator
or label annotation, `label` is closed to `{ text : Shared, icon : Shared }`.

**Reality vs plan:** plan mentioned record facet as possible; it was skipped after
evaluation (no required-singular slots exist). The plan mentioned `select/option`,
`ul/li`, `table/tr` as motivating the build facet — those slots drove the build
facet inclusion.

### CX7 — Unknown atom roles are a warning, not silent

Config entries like `"tier": {"role": "bogus"}` or slot entries `"shared:bogus"`
were silently decoded and produced `Markup.Kind.Shared` on an unrecognized atom
role. This is the same "typo vanishes" hazard as unrecognized component config
keys. In a system where slot kinds are compiler-enforced, a silent unknown atom
means a developer believes they configured shared access but the emitted code does
not reflect the intent.

**What landed:** `Generate.Warnings.unknownAtomWarnings` validates all role atoms
and slot `shared:*` entries against the v1 set at config-decode time, emitting a
named warning for each unknown atom. Tests assert the warning for components and
slots.

### CX8 — The generator ships nothing library-specific

Before the initiative, the generator had two kinds of baked library specifics:
- `Generate/Action.elm` hard-coded the M3e `_actions` roster (which component
  constructors produce actions, bottom-sheet/dialog action types).
- `Generate/Native.elm` hard-coded the HTML attribute table.

Both are data, not generator logic. Baking them makes the generator M3e-aware,
which breaks the goal of producing markup (or any future library) through the same
pipeline.

**What landed:** the `_actions` block moves to `config/slots.json`; `Generate/Action.elm`
becomes data-driven from `ConfigResult.actions`. The native attr table moves to
`elm-cem/markup/native-attrs.json`; `bin/elm-cem.js` injects it at CLI time via
`injectNativeAttrs()`. The resulting `M3e.Action` module is byte-identical to the
pre-initiative version. Neutrality grep of `codegen/` for `m3e|material` yields
only doc-comment illustrative examples (57 hits in comments, zero in data or logic).

### CX9 — `NoSeamOutsideAllowedModules` takes a config record

The original `NoSeamOutsideAllowedModules` hard-coded `seamModules = [["Seam"]]`,
making the rule usable only by projects that named their seam module `Seam`. The
new `ExtractToSeam` rule already accepted `{ seamModule, allowedModules }`. A team
that renames their seam module, or has multiple seam modules, needed to configure both rules separately with different shapes.

**What landed:** `NoSeamOutsideAllowedModules.rule` now takes
`{ seamModules : List String, allowedModules : List String }`, aligning with
`ExtractToSeam`'s config shape. Multi-module blessing is tested in
elm-review-cem's suite.

### CX10 — markup is developed in the elm-cem repo, not a separate repo

An early draft proposed `markup` as a separate GitHub repo. Co-location in the
elm-cem repo is the only viable arrangement: the generator needs a foundation to emit
against at test time, and that foundation must itself be generated by the generator.
A separate repo introduces a circular dependency (markup depends on elm-cem; elm-cem
tests depend on markup). Separate development would require a bootstrap ceremony on
every generator change.

**What landed:** `markup/` lives inside `elm-cem/` as a subdirectory. The
`elm-cem split` command produces standalone package trees for publishing (CX12).
CX10 was originally stated as "create separate repo"; it is amended to "create
mirror repos at Stage F" (CX12).

### CX11 — Facet-family packaging: one package per facet

The registry caps `docs.json` at 768,000 bytes. elm-m3e's mono-package docs.json
measured at **2,021,004 bytes** — the structure alone (module graph without any
prose) is 1,110 KB. No trimming technique can rescue a mono-package publish.

The decision: each generated library publishes as a **family of Elm packages, one
per facet layer**. Users install the facets they use. The partition is mechanically
computed from bucket rules and verified against the real import graph (no module
duplicated across packages, DAG respected). A `packages.json` per library defines
the partition and its per-package metadata.

m3e family (7 packages, placeholder names):
`jackhp95/elm-m3e-core` · `jackhp95/elm-m3e-raw` · `jackhp95/elm-m3e-html` ·
`jackhp95/elm-m3e` (standard) · `jackhp95/elm-m3e-record` · `jackhp95/elm-m3e-build` ·
`jackhp95/elm-m3e-review-facts`

markup family (6 packages):
`jackhp95/markup-core` · `jackhp95/markup-raw` · `jackhp95/markup-html` ·
`jackhp95/markup` (standard) · `jackhp95/markup-build` · `jackhp95/markup-review-facts`

**Reality vs plan:** the plan mentioned `markup-record`; it was dropped because
markup HTML elements have no required-singular slots (record facet is only useful
when there are required fields). Per-package docs gates: the standard package
measured at **664,575 bytes** (headroom = +35 KB below the 700 KB gate,
+103 KB below the 768 KB hard cap). All other facets are well under gate.

The `<fam>-review-facts` satellite (deps: `elm-review-cem` + the standard package)
exposes `<Lib>.Review.Facts` for use in consumers' `review/` apps. It keeps the
elm-review dependency out of app trees, resolving blocker M5a.

Gate: `elm-cem split` enforces totality (all modules assigned), disjointness (no
module in two packages), DAG respect (deps declared, not inferred), per-package
isolation probe (compiles standalone), and docs-size ≤ 700,000 bytes.

### CX12 — Copy-only publish mirrors

Elm requires `package == GitHub repo` with an `elm.json` at the root and version
tags. Development cannot move to per-package repos — the generator+foundation
co-location (CX10) must stay intact. The resolution: a **splitter** (`elm-cem
split`, driven by `packages.json`) emits standalone mirror trees (per-package
`elm.json` + partitioned `src/` + `README` + `LICENSE`). These trees are pushed to
publish-only GitHub repos (`jackhp95/<pkg>`) and tagged. Mirrors carry a
"generated — do not edit; issues and source in the dev repo" banner.

The splitter is a tool feature: no library-specific logic is baked in. Any
elm-cem-generated library splits by running `elm-cem split` with its own
`packages.json`. The real push to `jackhp95/<pkg>` repos is gated behind Stage F
(Jack's explicit go). All pre-Stage-F rehearsals use scratch repos.

**What landed:** `scripts/mirror-release.mjs` in elm-m3e handles the push-and-tag
step. Running with `--rehearse` pushes to `file:///tmp/mirror-rehearsal/<pkg>.git`
and verifies tree + tag + banner. All 7 m3e and 6 markup packages rehearsed OK.
Without `--rehearse`, the script hard-exits (never executed in pre-Stage-F context).

### CX13 — Archive-first history convention

Before any public-main rewrite, messy working branches are pushed to the repo's
`*-archive` GitHub repo. This ensures no lineage is lost even if the squash is
lossy. The archive repos are GitHub-archived (read-only) except during the push
window.

**What landed:** the stale elm-m3e clone (tip `beee90e`, dirty
`unionSlotKinds` WIP) was pushed to `elm-cem-archive` branch
`pre-squash/elm-m3e-clone-2026-07-12` before reset. All cross-CEM work branches
(`cross-cem/wsN`) are push-protected to main only after adversarial verification.

### CX14 — No tracer; land each workstream complete

An early plan proposed a "Phase 0 tracer" that set all components to private-tier
as a first step, then applied the rest in waves. The tracer was dropped because
(a) setting all-private-by-default breaks the GoldenTest (the expected emitted
text changes); (b) it would require two complete regen passes for the same logical
change; (c) extraction (WS1) must precede branding (WS2) so brands are built
against `Markup.Kind` once, not rebuilt after the runtime move. Each workstream
instead lands its mechanism complete — real config surface, both producer AND slot
sides, negative compile gates — in dependency order.

---

- [Generate the whole library, hand-write zero components](#generate-the-whole-library-hand-write-zero-components)
- [Emit an introspectable IR, not opaque `Html`](#emit-an-introspectable-ir-not-opaque-html)
- [The generated API — three layers, three forms](#the-generated-api--three-layers-three-forms)
- [Composition over injection](#composition-over-injection)
- [Cardinality and required-presence are advisory, not typed](#cardinality-and-required-presence-are-advisory-not-typed)
- [Codegen-aware elm-review: generate facts, hand-write rules](#codegen-aware-elm-review-generate-facts-hand-write-rules)
- [The seam boundary — one loud, greppable crossing](#the-seam-boundary--one-loud-greppable-crossing)
- [The Kit is copy-paste userland, not published API](#the-kit-is-copy-paste-userland-not-published-api)
- [Regenerate in CI on a `@m3e/web` bump](#regenerate-in-ci-on-a-m3eweb-bump)
- [Unwrap the default slot; phantoms as guidance](#unwrap-the-default-slot-phantoms-as-guidance)
- [Builders are styling-free; expose host escapes](#builders-are-styling-free-expose-host-escapes)
- [The config is grown by evidence, permissive by default](#the-config-is-grown-by-evidence-permissive-by-default)

## Generate the whole library, hand-write zero components

Nothing in `src/M3e/` is hand-written per component. The hand-craft lives in the
`elm-cem` generator, in `config/slots.json`, and in the userland seam. An early
audit projected an irreducible ~13-module hand layer ("capture ceiling ≈ 80%"),
but re-examining the real `@m3e/web` source found **zero** runtime-imperative
component cases — every claimed-hand module turned out to be a pure IR-producing
function expressible as composition, and the two stragglers (Label, SplitButton)
dissolved once modeled as a governance seam and a typed-slot container
respectively (ADR 8, ADR 10). Making the whole library generated is what lets a
`@m3e/web` upgrade regenerate the library instead of forcing a hand-merge, and it
keeps 122 components uniform rather than each accreting its own idioms.

## Emit an introspectable IR, not opaque `Html`

The pre-1.0 `Ui.*` layer wrapped web components as functions returning opaque
`Html msg`, and a whole-repo audit found that shape made the library's own thesis
— make impossible states impossible against the Material 3 spec, not against the
DOM — undeliverable (ADR 6). Opaque `Html` cannot be constrained (an icon slot
would accept anything) or composed (you cannot inject `slot=`/`for`/`id` into it),
and accessible names lived where `Test.Html` couldn't see them, so real bugs
shipped green through 252 unit tests. So a component now renders to a data
structure the library controls — the lazy IR `Element` — and the only eager point
is `toHtml` at the app root. That single decision is the root the rest of the
design hangs off: because the tree is still introspectable data right up to the
render exit, phantom types can guarantee a composition is valid before it collapses
to `Html`.

## The generated API — three layers, three forms

The generated API has two orthogonal axes rather than one ladder — **three
layers** and **three forms** — for five addressable points in all: **one IR,
five facets** (a **facet** is one such addressable point). The two axes are ADR 8
for the layers, ADR 13 for the forms. The **layer axis** is how raw you go: a safety
gradient over the same IR from the `raw` layer (`M3e.Raw.*` — partial applications
of `elm/html`, strings live here and nowhere else), through the `Html` layer
(`M3e.Html.*` — phantom-typed attributes, eager component), to the default `top`
layer (`M3e.*` — fully lazy IR, typed slots); dropping a layer is rawer, less safe,
more control. The **form axis** is how strict one call site is — how required and
optional parts are passed on the top layer — and all three forms return the
identical `Element … msg` so they interchange freely: the **standard** form's
double-list call (`view [attrs] [content]`), the **Record** form (`M3e.Record.*`,
which turns missing-required into a compile error), and the **Build** form's
phantom-builder pipeline (`M3e.Build.*`, which makes a duplicate-singular setter
unwritable). Each form converts exactly one advisory check into a compile-time one,
so a team dials in as much strictness as it wants without the library forcing the
strictest shape on everyone. All three layers and all three forms exist on disk
today (`Raw/`, `Html/`, the top component modules, `Record/`, `Build/`).

## Composition over injection

The first config design absorbed "wrapper injects extra structure" cases (Slider
auto-adds a thumb, BottomSheet appends a close-trigger sentinel, SplitButton nests
a Button, form controls inject a native `<input>`) with a declarative
element-injection primitive. Reading the real `@m3e/web` source dissolved that
primitive: every case is already a *composition*, not an injection — the slider
renders consumer-supplied thumbs and derives `isRange` from how many you pass, the
bottom-sheet action is just a close-on-click member, the split button's leading is
just a Button in a slot. So the rule became: **always model added structure as
composition, never injection** (ADR 9). This is what made "hand = zero components"
reachable, and it means the code you write matches the DOM that appears — the
library is not silently manufacturing children behind your back.

## Cardinality and required-presence are advisory, not typed

Two slot properties could be encoded in the type system but at an ergonomic cost:
cardinality (some slots are singular, some accumulate) and required-presence (a
Button with no label is broken). A type-level guarantee is achievable — put
singular slots in a record, `Maybe` for optional-singular, required slots as plain
fields — but that taxes every component with a record and makes every
optional-singular slot a `Maybe` the caller must spell `Nothing` for (TreeItem
alone has four icon slots). Weighed against the project's values (uniformity over
per-component ergonomics, and "the code you write should match the code in the
browser"), the record tax was judged worse than the guarantee is worth, so these
two checks are handled by `elm-review` rules plus doc notes instead of type shape
(ADR 11). Kind and capability validity, by contrast, *are* always type-level and
never relaxed. Underpinning all of it is **IR faithfulness**: the generated IR
emits exactly what the caller composed — never adding, dropping, deduplicating, or
reordering. (This decision was later partly reconciled by the form axis above: the
record and build forms *do* lift required-presence and cardinality back into the
type system for teams that opt in.)

## Codegen-aware elm-review: generate facts, hand-write rules

The top layer is deliberately loose — the barrel exposes one component-agnostic
`variant` that accepts every component's tokens, general slot setters, and the
advisory-only checks above — so the finer facts (is this enum value valid for
*this* component, is a required slot present, is a general slot better written as
its specific name) are intentionally not in the types; they are elm-review's job
(ADR 12). Those checks need facts only the manifest and config know, and an
autonomous migrator needs machine-actionable guidance rather than prose. So the
generator emits a plain-Elm **facts** table (component → valid enums, required
slots, multi slots, shorthand↔specific names, the per-layer/form function map) and a
small set of hand-written, configurable, unit-tested generic rules consume it.
Universal invariants (the `toHtml` gate, the seam gate, no raw attribute on a
component slot) are hand-written and parameterized; component-specific checks are
one generic rule each, driven by the facts. The rules live in the sibling
`elm-review-cem` package, which keeps them reusable across any CEM-generated
library, not just this one.

## The seam boundary — one loud, greppable crossing

Userland always needs things the generator never will — an i18n text component, a
custom link, a layout wrapper — and they need the *same* phantom typing the
generated code enjoys. The decision is that there is exactly **one** place where
raw `Html` crosses into the typed IR, and it is loud and auditable (ADR 14). The
opaque `Element` type and every phantom-asserting op (`fromNode`, `fromHtml`,
`recast`, the seam stampers) live only in `*.Internal` modules; the public
`M3e.Element` re-exposes just the safe subset, so a userland `import M3e.Element`
literally has no `fromNode` in scope and cannot mint an `Element` from raw HTML.
That is a structural fence — Elm's own module exposure, not a lint rule. On top of
it, semantic seams are config-declared and generator-typed but userland-filled
(`text`/`link`/`label` are holes a team fills, not values the library defines),
and `NoSeamOutsideAllowedModules` keeps every crossing inside a few blessed adapter
modules. The escape (`Seam.recast`) is deliberately kept as a greppable feedback
signal so the design-system owner can audit each use and fix either the app or the
config, rather than a silent hole.

## The Kit is copy-paste userland, not published API

The producers that complete the composition story — `Kit` (`text`/`link`),
`Native` (native-HTML IR: `div`/`span`/`a`/…), and the app's `Seam` adapter — live
in `docs/kit/` and are explicitly **copyable, not part of the published package**.
Fork consumers copy them into their own app and adapt them. The reasoning: these
are exactly the pieces the library intentionally does not opinionate. A team whose
"text" is an i18n key resolving to the user's language should fill that typed hole
themselves, not inherit ours; navigation is a plain `<a>` whose routing is the
app's business. Publishing them would freeze one team's opinion into everyone's
dependency graph, so instead they ship as a small, honest starting point you own
after you copy it. `elm.json` `source-directories` points at `src` + `docs/kit` so
the reference site dogfoods exactly what a consumer would copy.

## Regenerate in CI on a `@m3e/web` bump

Because the library is fully generated, an upstream `@m3e/web` version bump must
regenerate `src/` or the binding drifts from the web components it wraps. A
`regen-on-bump.yml` workflow wires this: when a PR changes `@m3e/web`, CI installs
the manifest, fetches the (now public) `elm-cem` generator, runs the deterministic
regen command, `elm-format`s the output, and commits the diff back onto the PR so
the existing CI then re-validates that the regenerated code still compiles (ADR 8
covers the generator side; the planning notes referred to this regen-in-CI workflow
as "ADR-8"). Two details are load-bearing and both are the result of a real bug:
the regen is **deterministic** (a no-op bump produces no commit), and the output is
`elm-format`ed before commit, because committing the generator's raw output
introduced large spurious formatting churn that swamped the real API diff on every
bump. The generator being public means the clone needs no token; a PAT
(`ELM_CEM_TOKEN`) is optional and only needed to make the bot's regen commit
re-trigger CI automatically.

> **Amendment 2026-07-21 (pass 2):** An earlier iteration of this workflow kept a
> gitignored in-repo working clone at `/elm-cem/` so the local regen command could be
> run from the repo root. That clone is retired. The canonical local regen path is
> the sibling checkout `../elm-cem` at its current `main`
> (the phantom pipeline, local commit `7cebfde`). CI continues to do a fresh `git
> clone jackhp95/elm-cem` at regen time; the GitHub `origin/main` of `elm-cem` still
> lags local `main` (push is human-gated, Stage F), so a CI-triggered regen may not
> match the committed `src/` until that push lands. See
> `skills/regenerating-elm-m3e/SKILL.md` for the exact local regen command.

## Unwrap the default slot; phantoms as guidance

An earlier model wrapped the top layer's default-slot children in a `Content`
newtype so the slot name could be stamped. That was reversed: on the `M3e` top
layer the default slot now takes raw `Element` children directly, and the `Content`
module was retired (ADR 15). The rationale was that the wrapper was ceremony for
the common case — most default slots impose no restriction, so the wrapping bought
little and cost every call site a layer of indirection. Alongside this, the posture
on the standard form's phantom rows was settled as **guidance, not an absolute
boundary**: the shipped `Cem.Lenient` lint posture flags a slot child only when its
kind resolves statically and stays quiet otherwise, which is the accepted trade for
the ergonomic standard form. A team that wants the linter to hold the full slot-kind
guarantee can switch to `Cem.Strict`; the record and build forms hold it in the
type system regardless.

## Builders are styling-free; expose host escapes

A component builder never bakes in styling — no hardcoded `class "text-title-medium"`
on a card headline (ADR 4). Building the docs site against the old `Ui.Card` showed
that hardcoded styling defeats the Tailwind bridge, drifts from the M3 tokens the
elements already emit themselves, and blocks callers from composing their own
layout. The flip side of that rule is that callers need a way to attach a
`class`/`data-*`/`aria-*`/handler to the underlying host element, because the audit
found 50 of 52 old builders had no such affordance and the only workarounds (fork
the module, or wrap in a `<div>` that breaks the typed-slot contract) were both bad.
So host-box components expose an escape that appends raw attributes to the host
element (ADR 7), applied where a component's host needs caller-driven sizing or
styling (Shape, ScrollContainer, Skeleton, Progress, and any other whose host needs
it).

## The config is grown by evidence, permissive by default

A component absent from `config/slots.json` gets safe, maximally permissive
defaults: a free child row, no required fields, its default slot degrading to a
loose `"arbitrary"` slot where everything still composes. The looseness is
*visible* in the generated signature (an open row rather than a closed kind set),
not silently wrong. The posture is deliberately **permissive-default-you-trim**: a
freshly generated CEM composes everything, and teams *subtract* invalid
compositions in config rather than opt into valid ones. Because being wrong in
config is cheap — fix the entry and regenerate — the config is grown by evidence:
only a minority of entries are evidence-based today, and the rest ride the
permissive defaults until a real composition proves a tighter fact is warranted.
This keeps the library shippable from day one on a new `@m3e/web` release instead
of blocking on hand-authoring every slot.


## 2026-07-21 — Post-phantom publish layering: core / three component ranges / barrel

The phantom refactor retired the old *facet* split (`-raw`/`-html`/`-record`/
`-build`, one package per API style over the same components). `packages.json`
now describes a **layered** split of the single phantom surface, sized so every
publishable package's per-package `docs.json` stays comfortably under the
`DOCS_LIMIT` (700,000 bytes) the pre-phantom whole-library docs blew through.

Three layers, all version `1.0.0`, `family`/`devRepo`/`licenseText` preserved:

  1. **`jackhp95/elm-m3e-core` (bottom)** — the general/support surface that
     imports no component: `M3e.Action`, `M3e.Attributes`, `M3e.Coerce`,
     `M3e.Events`, `M3e.Kind`, `M3e.Unsafe`, `M3e.Values` (7 modules). Verified
     against `grep '^import M3e\.'`: `Attributes → Values`, `Coerce → Kind`,
     everything else importing only `elm/*` and `HtmlIr.*`. No component leaks in.
  2. **Middle — the per-component `M3e.<Component>` modules**, partitioned into
     **three** packages purely by a simple, documented rule: **alphabetical by
     module name, cut into three roughly docs-balanced ranges.** No cleverness,
     no cross-cutting grouping.
       - `jackhp95/elm-m3e-components-a` — `Accordion … FocusTrap` (45 modules)
       - `jackhp95/elm-m3e-components-b` — `FormField … NavRailToggle` (28 modules)
       - `jackhp95/elm-m3e-components-c` — `Optgroup … YearView` (50 modules)
     Component modules import only the core layer (`Attributes`/`Events`/`Kind`/
     `Action`), never each other, so the component→component DAG is empty and any
     partition is DAG-valid; the split tool's DAG check confirms it.
  3. **`jackhp95/elm-m3e` (top)** — the `M3e` barrel (`src/M3e.elm`), depending
     on core + all three component packages. Bucket is `{ "exact": "M3e" }` only.

Retired dep `jackhp95/markup-core` is replaced by
`jackhp95/elm-html-intermediate-representation` (every module imports `HtmlIr.*`);
the gate scripts map it via `--dep-src`. `jackhp95/elm-m3e-review-facts` is
unchanged (installed in `review/` only; skipped by the docs + isolation gates).

**Measured docs sizes** (`npm run measure-docs`, 2026-07-21, limit 700,000 B):

| package                | bytes   | % of limit |
| ---------------------- | ------- | ---------- |
| elm-m3e-core           |  75,206 | 10.7 %     |
| elm-m3e-components-a    | 351,407 | 50.2 %     |
| elm-m3e-components-b    | 216,430 | 30.9 %     |
| elm-m3e-components-c    | 370,886 | 53.0 %     |
| elm-m3e (barrel)       |  38,640 |  5.5 %     |

The largest package sits at 53 % of the cap — ample headroom for the surface to
grow before the ranges need re-cutting.

**Split-tool durability note.** `elm-cem split` *copies into* its output dir but
never *cleans* it, so a stale `dist-packages/` from a prior partition (e.g. the
old `{ "prefix": "M3e." }` barrel bucket) silently poisons the isolation probe
with ambiguous-module collisions. The repo-local `split` npm script therefore
prepends `rm -rf dist-packages` so `npm run gate` is idempotent regardless of
prior state. (Not an `elm-cem` bug the fixture reproduces — its fixture uses a
fresh temp dir each run — so the fix is at the consuming script, not the tool.)

`scripts/mirror-release.mjs` is **out of scope**: it still references the retired
facet names, but it is not invoked by any gate, so it is left untouched here.
