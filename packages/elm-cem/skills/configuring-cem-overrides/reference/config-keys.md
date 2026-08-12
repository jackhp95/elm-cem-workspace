# `--config-from` key reference

Copy-pasteable JSON. All keys optional. Component keys are the PascalCase module names
elm-cem derives from tags (`x-button` → `Button`). Reserved keys are `_`-prefixed.
Examples use neutral `x-*` / Shoelace-style components only.

## Per-component keys

```json
{
  "Button": {
    "slots": {
      "icon":    { "kinds": ["shared:icon"], "required": false, "multi": false },
      "label":   { "kinds": ["shared:text"], "required": true,  "multi": false },
      "default": { "kinds": "arbitrary", "multi": true }
    },
    "required": { "action": "action:click,link", "ariaLabel": "ariaLabel" },
    "requiredAttrs": ["variant"],
    "attrTypes": {
      "open":    "bool",
      "count":   "int",
      "size":    ["small", "medium", "large"],
      "tone":    { "primary": "brand", "neutral": "gray" }
    },
    "syntheticAttrs": {
      "hidden": { "htmlName": "data-hidden", "description": "Hide from the a11y tree." }
    },
    "events": {
      "x-change":   { "detail": "value", "type": "string" },
      "x-selected": { "path": ["detail", "index"], "type": "int" },
      "x-close":    { "type": "none" }
    },
    "idWiring":   { "control": "input", "label": "label" },
    "actionMap":  [["submit", "click"]],
    "staticAttrs": { "role": "button" },
    "attrForm":   { "value": "property", "pressed": "attribute" },
    "propertyOnly": ["value"],
    "examples": [
      { "title": "Basic", "code": "Button.view [] [ text \"Go\" ]", "section": "Usage" }
    ],
    "docMeta": { "category": "actions" }
  },
  "ProgressBar": {
    "group": { "linear": "x-progress-bar", "circular": "x-spinner" }
  }
}
```

### `attrTypes` — the three override shapes

| JSON value | Result |
| --- | --- |
| `"int"` / `"float"` / `"bool"` / `"string"` | force a scalar setter (typo → build error) |
| `["a", "b"]` | enum where token == emitted value |
| `{ "tok": "value" }` | enum where token → distinct emitted value |

The most common fix: an attribute the CEM typed as `string` that is really a presence
flag → `"open": "bool"`.

### `events` — path + leaf type

Give the JSON payload path with exactly one of `path` / `detail` / `target`, and a
`type` of `int|float|bool|string|date|none`. `none` (or no path) = no payload. An unknown
`type`, or a typed path with no source, fails the build loudly.

### `attrForm` / `propertyOnly` — attribute vs DOM property, per element

`attrForm` is `"attribute"` (the default for every scalar: SSR-visible and reflected)
or `"property"` (`Ir.property`, for an attribute whose LIVE state diverges from the
content attribute). It gets the last word over the brand-level `_controlled` roster, so
one element can opt in or back out. Anything else than those two words is a build error.

`propertyOnly` lists attributes that keep the property setter but drop the `default*`
companion, for an element whose live property has no backing content attribute
(`<output>`'s `defaultValue`). It must name an attribute the component declares and one
the roster controls **on that element** — see `_controlled`'s `elements` scope in
`docs/config-primitives.md`, which is where a per-element roster belongs; `attrForm` is
for the one-off exception.

### `syntheticAttrs` — attribute not in the CEM

Keyed by the Elm setter name. `htmlName` = the HTML attribute stamped; optional `type`
reuses the `attrTypes` vocabulary (default = a presence boolean); optional `description`.
The setter, its phantom row, and its raw emission all come for free.

## Reserved top-level keys

```json
{
  "_exclude": ["XBaseElement", "XControlElement"],
  "_htmlNamespace": "Html",
  "_rawNamespace": "Raw",
  "_baseSlots": {
    "XBaseElement": { "default": { "kinds": "arbitrary", "multi": true } }
  },
  "_seams": {
    "Text": { "kind": "text" }
  },
  "_native": {
    "emit": ["a", "button"],
    "semantics": { "a": "link" },
    "summaries": { "elements": { "a": "A hyperlink." }, "attributes": { "href": "The URL." } }
  },
  "_coerce": [
    { "from": "Chip", "fromKind": "chip", "to": "button", "name": "asButton" }
  ],
  "_runtime": { "owns": false }
}
```

- **`_exclude`** — drop base classes the analyzer emitted as components. Malformed →
  build error (a silent `[]` collapse is how leaked base classes kept emitting).
- **`_htmlNamespace` / `_rawNamespace`** — rename the interior lower-layer segments.
- **`_baseSlots`** — slot closure inherited by subclasses of a base class.
- **`_seams`** — each entry needs a non-empty `kind`; emits contract types + a kind
  stamper. `tag`/`wrap` are accepted-but-ignored.
- **`_native`** — `emit` (non-empty HTML tag names), `semantics` (tag → role),
  `summaries.elements` / `summaries.attributes` (doc prose).
- **`_coerce`** — list of config-blessed brand crossings. Each entry `{ from, fromKind,
  to, name }` emits `<Lib>.Coerce.<name> : Element { k | fromKind : Brand } msg ->
  Element { s | to : Brand } msg`. For semantically meaningful re-brandings only; general
  crossings use `Seam.recast` instead.
- **`_runtime`** — retired in the elm-phantom refactor. All generated brands import the
  published `HtmlIr.*` package as a peer Elm dependency. This key is accepted by the
  current CLI but ignored.

## Multi-file deep-merge

Later `--config-from` files override individual **fields** per component, not whole
component entries:

```bash
elm-cem --flags-from=cem.json \
  --config-from=slots.json \
  --config-from=examples.json \
  --output=src/Generated
```
