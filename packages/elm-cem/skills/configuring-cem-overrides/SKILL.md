---
name: configuring-cem-overrides
description: >-
  Authors an elm-cem `--config-from` override file — the per-component and reserved
  config keys that refine what a Custom Elements Manifest can't express. Use in
  projects using elm-cem when the user wants to fix or shape generated bindings via
  config: force an attribute's type (an `open` attr generating as String should be
  Bool), declare typed slots, mark fields required, group variant tags into one module,
  inject an attribute the CEM omits, wire for/id, type an event payload, exclude leaked
  base classes, or rename the Html/Raw namespaces. Covers every real config key
  (slots, required, group, examples, docMeta, requiredAttrs, actionMap, attrTypes,
  idWiring, events, staticAttrs, attrForm, syntheticAttrs; reserved _baseSlots, _seams,
  _native, _htmlNamespace, _rawNamespace, _exclude) and multi-file deep-merge. The rule
  of thumb: fix wrong output in config, never by editing generated Elm.
---

# Configuring elm-cem overrides (`--config-from`)

`--flags-from` alone gives generic, manifest-only output. A `--config-from=<json>` file
adds refinements the CEM can't state. Keys are **component module names** (e.g.
`Button`, `Dialog` — the PascalCase name elm-cem derives from the tag), plus a set of
`_`-prefixed **reserved** keys. Every field is optional. Absent config ⇒ the config-free
path, so bindings stay generic across libraries.

**Golden rule:** wrong or thin generated output is fixed in config, **never** by editing
the generated `.elm` (a regen overwrites it). Reach for the right key below.

```bash
elm-cem --flags-from=<cem.json> --config-from=overrides.json --output=src/Generated
```

The generator is **loud on invalid config** — a present-but-malformed key fails the
build rather than silently collapsing. A typo in a scalar type name, an empty `slots`
block, or a bad `_exclude` array is a build error, by design.

## Per-component keys (decision guidance)

Each lives under a component's entry in the config object. Choosing between the
near-neighbors is the hard part:

- **`slots`** — typed slot children. Each slot maps to `{ kinds, multi, required }`.
  `kinds` is either the string `"arbitrary"` (spec-open content) **or** a non-empty list
  of kind descriptors. Two forms of kind descriptor:
  - A bare private kind name (e.g. `"icon"`, `"button"`) → slot accepts only that
    library's own branded kind (`<Lib>.Kind.Brand`).
  - A `"shared:<atom>"` name (e.g. `"shared:text"`, `"shared:icon"`) → slot accepts the
    shared atom kind (`HtmlIr.Kind.Shared`), produced by `Kit.text`, `Kit.icon`, etc. Use
    for slots that should accept accessible atoms from any library.
  An empty list or a missing `kinds` is a build error — "undetermined" is deliberately
  not representable. A `required` **single** slot (`required: true, multi: false`) becomes
  a record field on `view`; everything else is passed as children.
- **`required`** — non-slot required fields (map: field → kind). Value `action:<caps>`
  (comma-separated, e.g. `action:click,link`) makes the field an `<Lib>.Action` with
  those capabilities and **suppresses** the raw `href`/`target`/`rel`/`download`
  setters. `ariaLabel` wires the field to `aria-label`.
- **`requiredAttrs`** — a plain list of attribute names to mark required. Use this when
  an *existing CEM attribute* must be non-optional; use `required` when you're
  introducing a *new required field* (slot/action/aria) not backed 1:1 by an attribute.
- **`attrTypes`** — per-attribute **type override**, the fix for CEM type bugs (the
  classic case: an `open` attribute the manifest typed as `string` that should be a
  presence `bool`). Map attribute name → one of:
  - a scalar string `"int"` | `"float"` | `"bool"` | `"string"` (a typo here fails
    loud — it won't degrade to String);
  - a list `["a","b"]` → an enum (token == emitted value);
  - an object `{"tok":"value"}` → an enum with distinct token/emitted-value.
- **`syntheticAttrs`** — inject a settable attribute **not in the CEM**, carrying a real
  phantom capability so it only type-checks on the component(s) it's declared on. Keyed
  by the Elm setter name; each value gives `htmlName` (the stamped HTML attr), optional
  `type` (reuses the `attrTypes` vocabulary; default = presence boolean), and optional
  `description`. Use for library-specific marker attributes a sibling component reads.
- **`group`** — variant-split families: several tags folded into one module with one
  constructor per variant (map: variant name → tag).
- **`events`** — a typed **event payload** per DOM event name. The JSON path is exactly
  one of `path` (explicit list), `detail` (shorthand `["detail", X]`), or `target`
  (shorthand `["target", X]`); `type` picks the leaf decoder
  (`int|float|bool|string|date|none`). `none` = no payload. Unknown `type` fails loud.
- **`idWiring`** — for/id auto-wiring: `{ "control": <name>, "label": <name> }`. Present
  but missing either field fails loud (a typo must not silently drop the wiring).
- **`actionMap`** — pairs `[["from","to"], …]` remapping action capability names.
- **`staticAttrs`** — attributes always stamped with a fixed value (map: name → value).
- **`attrForm`** — per-attribute form-shape override (map: name → form).
- **`examples`** — usage examples appended to module docs (grouped by `section`), each
  also emitted as a machine-readable marker. Fields: `title`, `code`, `section`,
  `codeRecord`.
- **`docMeta`** — opaque key/value doc metadata, passed through untouched.

A key-by-key JSON reference with copy-pasteable neutral snippets is in
[reference/config-keys.md](reference/config-keys.md).

## Reserved top-level keys (`_`-prefixed — never collide with a component name)

- **`_exclude`** — a list of component (class) names to drop. The fix for abstract base
  classes the analyzer emitted as if they were components. Present-but-malformed fails
  loud (a silent collapse to `[]` is exactly how leaked base classes kept emitting).
- **`_htmlNamespace`** / **`_rawNamespace`** — rename the interior lower-layer segments
  (defaults `"Html"` / `"Raw"`).
- **`_baseSlots`** — the inherited-default-slot closure (slot definitions shared by a
  base class, applied to its subclasses).
- **`_seams`** — config-declared semantic seams (contract types + kind stampers).
- **`_native`** — typed native/HTML IR (`emit` tags, `semantics`, MDN `summaries`).
- **`_coerce`** — a list of config-blessed brand crossings:
  `[{ "from": "Chip", "fromKind": "chip", "to": "button", "name": "asButton" }, …]`.
  Each entry emits a named loud crossing function in `<Lib>.Coerce` (e.g.
  `M3e.Coerce.asButton`). Use for stable, semantically meaningful re-brandings; for
  one-off or exploratory crossings use `Seam.recast` in a seam module instead.
- **`_runtime`** — retired in the elm-phantom refactor. All generated brands now import
  the published `HtmlIr.*` package as a peer Elm dependency; this key is accepted but
  ignored by the current generator.

## Multiple `--config-from` files deep-merge

`--config-from` may be passed **multiple times**. Files deep-merge per component: the
component key, then each component's field object — later files add or **override
individual fields** rather than replacing the whole component entry. This lets
hand-authored slots and machine-generated examples live in separate files.

---
Validated against elm-cem 1.0.0, 2026-07.
