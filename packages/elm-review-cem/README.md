# elm-review-cem

[`elm-review`](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/)
rules for [`elm-cem`](https://github.com/jackhp95/elm-cem)-generated Material 3
(M3e) component libraries. These are the machine-checkable *guarantee layer*
behind ADR-15: slot-kind validity, required content/attributes, slot & attribute
cardinality, enum-token validity, and barrel preference.

Namespace `Cem.*`. Every rule is **namespace-agnostic** and **codegen-aware**: it
takes a generated `List Cem.Facts.Fact` value and derives the target library's
root namespace from the facts themselves. Nothing here hardcodes a library name.
Facts from several libraries can be concatenated
(`M3e.Review.Facts.facts ++ TypedHtml.Review.Facts.facts`); the rules group them
by namespace, so each library's components are checked (not just the first).

## How it works: the Fact contract

`Cem.Facts` owns the versioned `Fact` type — the contract between the `elm-cem`
generator and these rules. `elm-cem` emits a `facts : List Cem.Facts.Fact` value
into an *unexposed* module of the library it generates. Because `Cem.Facts` has
**no `elm-review` dependency**, that generated module stays free of any
`elm-review` import; the review tooling only enters in the consuming project's
`review/` config, which passes `facts` into the rules.

Each `Fact` carries a component's fully-qualified Standard (top) `module_`, so the
rules derive the library's namespace on their own.

## Usage in a `review/` config

In your project's `review/elm.json`, add `jackhp95/elm-review-cem` as a
dependency, then in `review/src/ReviewConfig.elm`:

```elm
module ReviewConfig exposing (config)

import Cem
import MyLib.Review.Facts        -- the generated, unexposed facts module
import Review.Rule exposing (Rule)


config : List Rule
config =
    Cem.all MyLib.Review.Facts.facts
        -- ++ your own project rules
```

`Cem.all : List Cem.Facts.Fact -> List Rule` runs every non-opt-in rule with
lenient defaults. Use `Cem.allWith { validSlotKind = Cem.Strict } facts` to
flag unresolvable slot children. Individual rules (`Cem.requireSlot`,
`Cem.validSlotKind`, …) can be enabled à la carte.

### The fence preset

`Cem.fences` bundles the three seam/opaque-IR boundary rules a consuming project
would otherwise hand-roll in a `CodegenReviewConfig` module (and drift on — see
the note under Seam discipline). Concatenate it onto `Cem.all`:

```elm
config : List Rule
config =
    Cem.all M3e.Review.Facts.facts
        ++ Cem.fences
            { brandRoots = [ "M3e" ]
            , seamModules = [ "Seam" ]
            , allowedModules = [ "Seam", "Native", "Kit", "Layout" ]
            , typedHtmlFacts = TypedHtml.Review.Facts.facts
            }
```

It wires `NoInternalImportOutsideAllowed` (allowing `*.Internal` imports from
`brandRoots ++ [ "TypedHtml", "HtmlIr" ] ++ allowedModules`),
`NoSeamOutsideAllowedModules` (`seamModules` gated to `allowedModules`), and
`NoRedundantElementForge` (fed `typedHtmlFacts`). The always-present
`TypedHtml`/`HtmlIr` entry is exactly what apps hand-rolling the config kept
forgetting.

## The rules

Grouped as `Cem.elm` groups them.

**Facts-driven core** — every rule below is included in `Cem.all` (and
`Cem.allWith`), each taking the generated `List Cem.Facts.Fact`:

| Rule | What it flags |
| --- | --- |
| `Cem.validEnumValue` | A loose enum setter given a value token the target component does not accept. |
| `Cem.requireSlot` | A constructor whose content list omits a required-multi slot (advisory). |
| `Cem.singularSlot` | A singular content slot filled more than once. |
| `Cem.singularAttribute` | An attribute setter used more than once on a single call (HTML attrs hold one value). |
| `Cem.missingRequiredAttribute` | A component call missing a required HTML attribute (advisory; silent when unverifiable). |
| `Cem.missingRequiredSingularSlot` | A Standard call whose content list omits a required-singular slot. |
| `Cem.preferComponentModules` | A barrel shorthand where a per-component setter is preferred — **autofix**. |
| `Cem.validSlotKind` / `validSlotKindWith` | A slot child whose kind the enclosing component's slot rejects (posture: `Lenient`/`Strict`). |

**Opt-in barrel autofixes** — not in `Cem.all`; enable individually:

| Rule | What it does |
| --- | --- |
| `Cem.preferBarrel` / `preferBarrelWith` | Rewrites the strict per-component Standard facet (`<root>.<Comp>.*`) to the flat `<root>` barrel — **autofix**. |
| `Cem.preferComponentSetters` | Upgrades a generic barrel slot setter (`<root>.slotLeading`) to the component-specific barrel setter, for slot-kind safety — **autofix**. |

**Opt-in escape-reflex backstops** — not in `Cem.all` or `Cem.fences`; enable via
`Cem.redundantElementEscape { seamEscapes } facts` and
`Cem.redundantAttributeEscape { setterModules } facts` (the standalone rule
modules are `NoRedundantElementEscape` and `NoRedundantAttributeEscape`):

| Rule | What it flags |
| --- | --- |
| `Cem.redundantElementEscape` | The consumer-side "drop to plain Html" reflex: an escape (`<Lib>.toHtml`, `<Lib>.Unsafe.recast`/`recastAll`/`fromHtml`, or a configured `Seam.*` escape) wrapping a value a **known family producer** already returned as a typed `Element` — `toHtml (M3e.button …)`, `Unsafe.recast (M3e.heading …)`. Also: an Html-accepting escape wrapping a hand-written **covered raw tag** (`Unsafe.fromHtml (Html.a …)`), and `Unsafe.customElement` pointed at a covered tag or at an element expression. Advisory (no autofix). |
| `Cem.redundantAttributeEscape` | The same reflex on the **attribute** surface: `<Lib>.Unsafe.Attributes.customAttribute "<name>" …` / `fromHtmlAttribute (Html.Attributes.attribute "<name>" …)` / `fromHtmlAttribute (Html.Events.on "<event>" …)` where a typed setter of that name already exists. Evidence-driven (the setter must have been *seen* declared in a `<root>.Attributes`/`.Aria`/`.Events` module) and restricted to **element-independent** names — `aria-*`/`role`, HTML globals, events — since the rule cannot see which element the `Attr` lands on. Advisory, except for the one byte-identical boolean rewrite — **autofix**. |

They are the consumer-side mirror of `NoRedundantElementForge` (which catches the
same reflex on the *producer* side). All three are facts-driven; the element
escape rule takes the same `List Cem.Facts.Fact` and flags an escape only when
its argument `callSite`-resolves to a fact, or writes a tag the facts cover — so
it stays silent on a genuine `Html` escape (a custom tag, a caller-supplied
`Html msg`). They are opt-in (not in `all`/`fences`) because they need the
specific `seamEscapes` / `setterModules` names `fences` does not carry, and the
reflex is consumer guidance rather than a boundary invariant.

**Opt-in accessible-name backstop** — not in `Cem.all`; enable via
`Cem.requireFormFieldLabel facts` (the standalone rule module is
`Cem.RequireFormFieldLabel`):

| Rule | What it flags |
| --- | --- |
| `Cem.requireFormFieldLabel` | A form-field (`<root>.FormField`) wrapping a control with **no discoverable accessible name** — no `slot="label"` child (`<root>.FormField.label`), no `aria-label`/`aria-labelledby`, and no `id` (the `<label for>` proxy) — on the Standard/barrel facet. Advisory (no autofix). |

It is the form-field companion of `Cem.missingRequiredAttribute` (which requires
`aria-label` on icon-only controls). Reasoning statically from Elm source, it
recognises the form-field by its elm-cem noun and stays **silent** on anything it
cannot fully resolve (a dynamic content list, a helper/native-wrapped control, a
`build`-facet pipeline) — false positives are engineered out at the cost of some
false negatives, which is why it is opt-in. An `id` on the control is treated as
evidence of an intended external `<label for>` association (the rule cannot see
that `<label>` element).

**Seam-discipline** — boundary rules that keep their **top-level** module name
(not `Cem.*`). The first three are config-driven (each takes explicit module
names); `NoRedundantElementForge` is facts-driven (it takes the typed-HTML
producer facts):

| Rule | What it does |
| --- | --- |
| `NoSeamOutsideAllowedModules` | Flags any applied `Seam.*` escape used outside the allow-listed adapter modules (the gate). |
| `NoInternalImportOutsideAllowed` | Flags an `import` of a `*.Internal` module from a module not in the allowed prefixes (the fence). |
| `NoRedundantElementForge` | Flags a producer in an `HtmlIr.Internal`-importing module that forges a plain covered tag (`Ir.node "div"`, direct or via a local helper) the typed layer already provides — advisory. |
| `ExtractToSeam` | **Autofix** companion to the gate: lifts each flagged `Seam.*` escape into the seam module and rewrites the call site. |

## Seam discipline

Alongside the facts-driven `Cem.*` set, the package ships these **seam-discipline**
rules. They are the *boundary* counterpart to the facts-driven correctness rules:
most take an explicit list of module names, so they are
config-driven rather than codegen-driven, and keep their **top-level** module
names (not `Cem.*`). They enforce the "one door out" opaque-IR boundary a
generated library defines: rendered residue crosses back to raw `Html` only
through a single *seam* module, and interior `*.Internal` modules stay private.

- **The gate — `NoSeamOutsideAllowedModules.rule { seamModules, allowedModules }`.** Flags any
  applied escape (from the configured `seamModules` list) outside the modules
  allowed to hold one (the reusable adapters + the seam module itself).
  `allowedModules` are dotted names matched on dot boundaries, so `"Kit"` also
  allows `Kit.Surface`. `seamModules` names the modules whose functions are
  considered seam escapes (e.g. `[ "Seam", "Seam.Internal" ]`).

- **The fence — `NoInternalImportOutsideAllowed.rule allowedPrefixes`.** Flags an
  `import` of any `*.Internal` module from a module whose name is not one of
  `allowedPrefixes` (or nested under one). This keeps the opaque IR opaque:
  only generated code and the modules that build the crossings may reach inside.

- **The autofix companion — `ExtractToSeam.rule { seamModule, allowedModules }`.**
  Opt-in, cross-file. For each applied `Seam.*` escape the gate would flag, it
  emits a fix that lifts the escape into `seamModule` as a named binding and
  rewrites the call site to reference it — turning a gate violation into a
  one-command refactor. Triggers on exactly the escapes `NoSeamOutsideAllowedModules`
  flags.

- **The forge-redundancy backstop — `NoRedundantElementForge.rule facts`.** Where
  the fence keeps `HtmlIr.Internal` inside the blessed adapter modules, this rule
  keeps the forge from *re-implementing the typed producer layer* there. In a
  module that imports `HtmlIr.Internal`, it flags a top-level producer that forges
  a node whose tag is a **literal in the covered set** — either directly
  (`Ir.node "div" …`) or through a local forge helper (`div = node "div"`, where
  `node` itself forges `Ir.node`). The covered set is enumerated from the passed
  `TypedHtml.Review.Facts.facts` (one entry per HTML tag), so nothing is
  hardcoded. It is deliberately advisory (no autofix): retargeting a producer to
  `TypedHtml.<tag>` narrows the open attribute row to a closed one and surfaces
  real type errors that need human judgment. It keys strictly on a covered literal
  tag, so it stays silent on the genuine escapes — a variable/dynamic tag
  (`node tagName …`), an uncovered custom element (`Ir.node "compass-passkey"`),
  and the attribute/event escapes (`attribute`/`onClick`/`style`, which forge via
  `fromHtmlAttribute`, not `node`).

These rules ship no default config: a consuming project passes its own allowed
modules. Rather than hand-rolling them (where the `TypedHtml`/`HtmlIr` allow-list
entry is easy to forget), reach for the **`Cem.fences` preset** above, which
wires the gate + fence + forge-backstop from one config record.

## Contract with elm-cem

`Cem.Facts.Fact` is the **load-bearing contract** between this package and
`elm-cem`. `elm-cem` generates a `Review.Facts` module (unexposed, inside the
library it emits) whose `facts : List Cem.Facts.Fact` value is produced against
exactly this `Fact` shape; these rules consume it. Any incompatible change to the
`Fact` type is therefore a coordinated, major-version event on both sides (see the
note atop [CHANGELOG.md](./CHANGELOG.md)).

Compatibility:

| elm-cem (generated `Review.Facts`) | elm-review-cem (`Cem.Facts.Fact`) |
| --- | --- |
| 1.0.0 | 1.0.0 |

## Running the tests

```sh
npm install               # installs elm-review + elm-tooling wrapper
npx elm-tooling install   # installs elm, elm-format, elm-test-rs into node_modules/.bin
npm test                  # test:elm (elm-test-rs — 158 tests, must stay green)
```

The other npm scripts:

```sh
npm run check:format       # validates src/, tests/, review/src/ are elm-format clean
npm run format              # formats in-place (the fix for check:format)
npm run check:review        # dogfoods review/ config over src/ + tests/
npm run check                # run-p "check:*" — every check above, in parallel
npm run gate                 # run-s check test — what hooks/pre-push runs
```

`elm make --docs docs.json` must also pass — `elm publish` refuses a package
whose docs don't build (every exposed value must be documented).

## License

BSD-3-Clause. See [LICENSE](./LICENSE).
