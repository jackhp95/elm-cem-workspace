# Glossary

Terms used across the elm-m3e docs, design notes, and generator config. When a
term appears in code (a module name, config key, or type name), the code form is
noted.

---

**atom**
A small, accessible, cross-brand content element from the shared vocabulary — plain
text (`M3e.text`, built in) plus `TypedHtml`'s own producers (`TypedHtml.text`,
`TypedHtml.a`, …), which carry the shared kind natively — no adapter module required.
Atoms carry `HtmlIr.Kind.Shared` in a role-specific kind field. They flow freely into
any m3e slot that opts in with a matching `shared:<atom>` config entry. New atoms are
non-breaking additions. See [`TheLayers — The atom layer`](TheLayers.md#the-atom-layer)
and [`decisions.md CX4`](../decisions.md#cx4--atom-vocabulary-v1-text-link-label-icon).

**brand**
An opaque, nullary phantom type local to one library — `M3e.Kind.Brand`,
`HtmlIr.Kind.Brand`, `TypedHtml.Kind.Brand`, etc. Each library mints its own brand in
its own namespace, so Elm's nominal type system keeps them distinct at zero runtime
cost. A private-tier component's kind row carries its library's brand; closed slots
reject any element carrying a different brand. See
[`decisions.md CX2`](../decisions.md#cx2--brand-kind-rows-per-library).

**coercion**
A config-declared, named, typed brand crossing. Declared in the `_coerce` block of
`config/slots.json`; generated into `<Lib>.Coerce` (e.g., `M3e.Coerce.asButton`).
A coercion makes a semantic claim about the crossing — a Chip *acting as* a button
— and is the preferred mechanism for recurrent, well-reasoned crossings. Contrast
with `recast` (the general loud crossing). See [`Seams`](Seams.md) and
[`decisions.md CX5`](../decisions.md#cx5--seams-are-loud-coercions-are-config-blessed-sugar).

**surface**
One of the two coordinated entry points the single `jackhp95/elm-m3e` package exposes:
the **general** surface (`M3e` + `M3e.Attributes` / `M3e.Events` / `M3e.Values`, the
`elm/html`-shaped everyday API) and the **per-component** surface (`M3e.<Component>`,
with narrowed values, required-content `view`, and the `build` pipeline). Both are
element↔attr typed; the per-component surface turns three `elm-review` checks into
compile errors. See [`TheLayers`](TheLayers.md). (This replaces the retired
"facet family" packaging, where each layer/form was its own published package.)

**recast**
The general loud seam crossing: `M3e.Unsafe.recast` coerces any `Element` to any other
kind row with no semantic claim (`recastAll` maps it over a list; `M3e.Unsafe.Attributes`
ships the attribute-side twins, `recastAttr` / `recastAttrAll`). Always greppable and
review-enforced. Use for one-off or as-yet-unnamed crossings; promote to a named
coercion when the crossing recurs with consistent intent. See [`Seams`](Seams.md).

**seam**
Any crossing point where a value from outside the typed IR enters it. Two
sanctioned mechanisms exist: `recast` (general) and named coercions
(`M3e.Coerce.*`, config-blessed). Every seam crossing must happen inside a
module declared in `NoSeamOutsideAllowedModules`'s `allowedModules` list.
The seam stampers (`fromNode`, `fromHtml`, `recast`) live only in `HtmlIr.Internal`,
which is lint-guarded and not re-exported from the public surface — but every brand
ships a generated `Unsafe` module (`M3e.Unsafe` / `M3e.Unsafe.Attributes`) built on
that forge, so userland code reaches for the published escapes (`fromHtml`, `fromNode`,
`recast`, `recastAll`, `customElement`) without ever hand-writing an adapter on
`HtmlIr.Internal` itself. See [`Seams`](Seams.md) and [`DESIGN.md`](../DESIGN.md).

**shared** (kind)
`HtmlIr.Kind.Shared` — the cross-brand atom marker. An `Element` carrying `Shared` in a
kind field is admissible in any slot across any brand that declares the corresponding
`shared:<atom>` config entry. The type is defined in
`elm-html-intermediate-representation` and shared by all generated brands. Distinct
from `M3e.Kind.Brand` (m3e-private) and `HtmlIr.Kind.Brand`. See
[`decisions.md CX3`](../decisions.md#cx3--two-kind-tiers-private-brand-vs-shared-atom).

**tier**
The per-component config choice of kind segregation strategy. Two tiers:

- **private** (default): the component's kind row carries `<Lib>.Kind.Brand`.
  Slots typed with a private kind reject foreign elements.
- **role** (atom tier): the component's kind row carries `HtmlIr.Kind.Shared`
  with a specific role field name (`text`, `link`, `label`, `icon`). Slots that
  opt in to the matching atom accept this element regardless of origin brand.

Config: `"tier": "private"` or `"tier": {"role": "text"}`. The generator
propagates the chosen tier through the emitted surfaces. See
[`decisions.md CX3`](../decisions.md#cx3--two-kind-tiers-private-brand-vs-shared-atom).

---

**Terms from earlier docs that changed meaning:**

- **`Supported`** — in the pre-CX2 design this appeared in kind rows. Since CX2,
  kind rows carry only `<Lib>.Kind.Brand` or `HtmlIr.Kind.Shared`. `Supported`
  still appears on attribute capability rows (`Attr { c | variant : Supported }`),
  but not on kind rows.

- **facet / facet family** — the retired packaging where each layer/form (core, raw,
  html, standard, record, build, review-facts) shipped as its own published Elm package
  via copy-only "mirror" repos and `mirror-release.mjs`. The merged architecture ships a
  single `jackhp95/elm-m3e` package with two **surfaces** (see above); the facet split,
  the mirrors, and CX11/CX12 are historical.

- **runtime** — the modules in `elm-html-intermediate-representation` that every
  generated brand imports (`HtmlIr.Element`, `HtmlIr.Node`, `HtmlIr.Attribute`,
  `HtmlIr.Value`, `HtmlIr.Kind`). The IR is **imported**, not injected (the pre-phantom
  `injectRuntime` string-rewrite is retired). The word "runtime" refers to these
  infrastructure types, not to JavaScript runtime behavior.
