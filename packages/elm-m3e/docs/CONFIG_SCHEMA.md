# `config/slots.json` schema

The single declarative config the generator reads (via `bin/elm-cem.js
--config-from`). A JSON object keyed by **PascalCase component name**, plus a few
top-level **meta-keys** prefixed with `_` (see below). Every component key is
optional; a component absent from the config gets safe defaults (free child row, no
required, no groups). **Hand-authored → may be wrong; loose types + elm-review absorb
that** (see COMPONENT_AGNOSTIC_API §4-6). ~100 entries today (~28 evidence-based, rest
at defaults).

> **Vocabulary note.** This doc is the source of truth for the vocabulary the
> hand-authored config actually uses: the unnamed slot is keyed **`"unnamed"`** (not
> `"default"`), and the accepts-anything sugar is the bare string **`"arbitrary"`**
> (not `"any"`). An earlier vocabulary used `"any"`/`"default"`; the emitted open-row
> *encoding* is the same, but the config tokens are `"arbitrary"`/`"unnamed"`.

```jsonc
{
  "TreeItem": {
    // Per slot, keyed by the slot's manifest name; "unnamed" is the default
    // (unnamed) slot. An absent slot entry = not exposed.
    "slots": {
      "label":   { "kinds": ["text", "link"], "multi": false, "required": true },
      "icon":    { "kinds": ["icon"],         "multi": false, "required": false },
      "unnamed": { "kinds": ["treeItem"],     "multi": true,  "required": false }
    },
    // event/attr name -> the Action facet it drives (onClick/href fold into Action).
    "actionMap": [ ["onClick", "onClick"] ]
  },

  "FilledButton": {
    // A required Action field (goes in the required record; suppresses the
    // overlapping href/onClick). Value is "action:<facet>,<facet>,…".
    "required": { "action": "action:click,link,menuTrigger" },
    // Required plain attributes, by MANIFEST (kebab) name -> emitted as required
    // record fields.
    "requiredAttrs": ["aria-label"],
    // Always-on attributes the component needs, name -> value (never surfaced as a setter).
    "staticAttrs": { "role": "group" }
  },

  "FormField": {
    "slots": {
      "unnamed": { "kinds": "arbitrary", "multi": false, "required": false },
      "label":   { "kinds": "arbitrary", "multi": false, "required": false }
    },
    // for/id auto-wiring: names the control slot and the label slot so the
    // generator stamps id="<id>" on the control and for="<id>" on the label,
    // making the label<->control association structural, via
    // M3e.Element.Internal.withAttr (see docs/DESIGN.md §4).
    "idWiring": { "control": "unnamed", "label": "label" }
  },

  "Calendar": {
    // custom-event decoding: event name -> { path into detail/target, scalar type }.
    "events": { "change": { "path": ["target", "date"], "type": "date" } }
  },

  "Progress": {
    // variant-split grouping: fold member tags into one module.
    "group": { "linear": "m3e-linear-progress-indicator", "circular": "m3e-circular-progress-indicator" }
  },

  "Tabs": {
    // R12 typed-arg overrides: force the Elm type of an attribute the CEM types
    // wrongly or leaves under-specified. Keyed by the attribute's MANIFEST name
    // (kebab, as in requiredAttrs). Three value shapes:
    "attrTypes": {
      "some-count":    "int",                            //  scalar: "int" | "float" | "bool" | "string"
      "some-align":    ["start", "end"],                 //  enum, token == emitted value
      "disable-pagination": ["true", "false", "auto"]    //  tri-state enum (closes #96)
      // token -> value map form (token name differs from the emitted string):
      // "some-attr": { "always": "on", "never": "off" }
    }
  }
}
```

## Component-key field reference

- **`slots`** — object keyed by slot name (the manifest name; `"unnamed"` = the
  default/unnamed slot). Per entry:
  - `kinds`: the accepted-kind union — either a **list** of kind names (camelCase
    component names, or the specials `text`/`link`), or the **bare string
    `"arbitrary"`** (accepts anything, encoded as an open row). `element` is the
    implicit escape and is never listed.
  - `multi`: true if the slot holds >1 element (drives advisory cardinality).
  - `required`: true if the component is non-functional without it
    (required-singular → the record; required-multi → the content list + advisory).
- **`required`** — object of `field → kind` for NON-slot required record fields.
  Today the kind is an **Action** spec, `"action:<facet>,<facet>,…"` (an `Action`
  field that suppresses the overlapping `href`/`onClick`). (Required *plain
  attributes* like `aria-label` live in `requiredAttrs`, not here.)
- **`requiredAttrs`** — list of attribute **manifest names** (kebab, e.g.
  `"aria-label"`) that are required; each becomes a required field on the record
  surface.
- **`staticAttrs`** — object of `name → value` for attributes the component always
  needs (e.g. `{ "role": "group" }`). Emitted unconditionally, never surfaced as a
  setter.
- **`actionMap`** — list of `[eventOrAttr, actionFacet]` pairs mapping an
  event/attribute name onto the `Action` facet it drives (e.g.
  `[["onClick","onClick"],["href","link"]]`).
- **`events`** — object of `eventName → { … }` describing how to decode a custom
  event. Each value has a `type` (scalar: `"int"`/`"string"`/`"date"`/…) and a path,
  given as either `"path": [ … ]` (into `target`/the event object) or
  `"detail": "<key>"` (into `event.detail`).
- **`idWiring`** — object naming the two slots involved in `for`/`id` auto-wiring:
  `{ "control": "<slotName>", "label": "<slotName>" }`. The generator stamps
  `id="<generated>"` on the control-slot element and `for="<generated>"` on the
  label-slot element (via `M3e.Element.Internal.withAttr`; see `docs/DESIGN.md` §4),
  so the label↔control association is structural rather than hand-wired.
- **`group`** — object of `memberName → tag` for variant-split folding (fold several
  manifest tags into one Elm module, e.g. `Progress`).
- **`attrTypes`** (R12) — object keyed by an attribute's **manifest name** (kebab, e.g.
  `disable-pagination`; matches the `requiredAttrs` convention). Declaratively OVERRIDES
  the Elm type the generator would otherwise derive from the CEM `type.text`, for
  attributes the manifest types wrongly or leaves untyped. Three value shapes:
  - **scalar** — one of `"int"`, `"float"`, `"bool"`, `"string"`. Forces the matching
    scalar setter (an unknown string is a LOUD build error, never a silent `String`).
  - **list** — `["a", "b", …]`. Forces a typed `Value` enum where each token's name
    equals its emitted attribute string.
  - **map** — `{ "token": "value", … }`. Forces a typed `Value` enum where the Elm-facing
    token name may DIFFER from the emitted string (e.g. `{ "always": "on" }` exposes
    `M3e.Token.always` but writes `on`).

  The generator mints one shared `M3e.Token` token per token name across the whole
  manifest, so a **map** whose token reuses a name already minted with a different string
  (e.g. `always` already renders `"always"` for `hide-subscript`/`float-label`) is a
  COLLISION — the generator reports it as a build warning (`valueTokenConflicts`). Pick a
  distinct token name, or map it to the same string. (This is why #96's tri-state uses the
  collision-free list `["true","false","auto"]` rather than `never`/`always` tokens.)

## Top-level meta-keys

These live at the root of the config (not under a component key) and are prefixed with
`_`. They configure the generator globally rather than one component:

- **`_baseSlots`** — object of `baseName → slots` giving the default slot map for a
  *base class* several components extend (e.g. `ActionElementBase`). A component that
  extends a base inherits these slots unless its own `slots` entry overrides them.
- **`_seams`** — the semantic-seam registry: a map of seam name → `{ kind, wrap|tag }`
  telling the generator which phantom `kind` each hand-written `Seam` producer stamps
  and how it renders. Today: `text` (`kind: "text"`, `wrap: "span"`), `link`
  (`kind: "link"`, `tag: "a"`), `label` (`kind: "label"`, `tag: "label"`). Drives the
  generated contract types in `M3e.Seam` that `docs/kit/Seam.elm` fills.
- **`_native`** — the native-HTML IR emit list: `{ "emit": [ …tag names… ],
  "semantics": { tag: kind, … } }`. `emit` is the set of native tags the generator
  produces as first-class IR `Element`s (`a`, `label`, `div`, `span`, `p`, `ul`, `li`,
  `input`, `button`, …). `semantics` overrides the phantom kind for the *semantic* tags
  that stamp a specific one (`a → link`, `label → label`); every other emitted tag
  carries the `html` kind (open row, fits `arbitrary`/`any` slots).

**Not yet in the schema but referenced in design docs** (COMPONENT_AGNOSTIC_API §4-6):
`skip` (surface curation) and per-slot type-suffix / most-common-kind overrides. These are
unbuilt — add them when the corresponding generator features land. (The `typedArgs`
concept from those docs is now shipped as **`attrTypes`** above.)
