# Figma extraction methodology (how to derive Code Connect content faithfully)

The whole point of this tool is to be the **translation layer** — *extract* what
a Figma component actually is and emit correct Code Connect bindings — not to
hard-code or guess content. This doc captures the methodology the hard way,
after a round where guessing produced wrong icons/slots/counts across ~a dozen
components.

## The cardinal rule: read the property layer, not the pixel layer

Figma exposes a component two ways over the bridge (`extract/relay` → the
plugin). They are NOT equivalent:

| Source | What it gives | Use it for |
|---|---|---|
| `capture_set` → `contentTree` | flattened geometry: node names, TEXT characters, structure | structure, text, counts, which slots are present |
| `get_component_properties` | `componentPropertyDefinitions` (SET) + resolved `componentProperties` (variant): `INSTANCE_SWAP`, `VARIANT`, `BOOLEAN`, `TEXT` | the actual chosen glyph, fill, size, variant, show/hide |

**The contentTree flattens an icon to an unnamed `VECTOR "icon"` — the glyph
identity is gone.** If you extract from the contentTree and then "identify" the
icon, you are guessing. Read `get_component_properties` instead.

## Mapping primitives → code

- **Icon slot** = an `INSTANCE_SWAP` property. Resolve its default value node's
  **name** → glyph + fill. The M3 kit's placeholder is **`stars_filled`**
  (a filled star-in-circle), reused across button/icon-button/fab/split-button.
  Parse `"<glyph>_filled"` → `name="<glyph>" filled`. Fill matters — the kit
  default is filled; emitting the outline is wrong.
- **Icon visibility is gated.** An icon shows only if a `Show <x>` BOOLEAN is
  true, OR the `Configuration` VARIANT default names it. Chips default to
  `Configuration="Label only"` → **no icon** (that's why assist/filter/suggestion
  chips are correctly icon-less). Don't emit an icon just because a swap default exists.
- **`Size` VARIANT → `size` attr** by **visual match**, not by label — the Figma
  and code size scales don't align by name. Badge: Figma default `Large` renders
  32px; code `size="small"` (not "large") matches at 22×32. Measure, don't assume.
- **`Type`/shape VARIANT → `shape`** (`Round`→`round`, `Square`→`square`);
  **`Color` VARIANT → `variant`** (`Filled`→`filled`, …). These often already
  live in the confirmed `fixedAttrs` — check before adding a `set-attrs` (a key
  collision is an error).
- **`TEXT` property → label content.**

## Multi-element slots

Web-component slots accept **multiple elements with the same `slot` name**; the
component lays them up. `slot="actions"` on several buttons is valid and auto-rows
when the slot's container is a row. If they stack, it's the container's layout
(e.g. a vertical card puts actions as full-width column children), not a binding bug.

## Component API facts: use the `m3e` skill, don't guess

Tags/attributes/slots/tokens are documented in the **`m3e` skill**
(`m3e-okf/skills/m3e/components/<name>.md`). Every fact this project got wrong
(card `slot="header"` + `inline`/`orientation`, nav-bar `mode="expanded"` +
nav-item `orientation="horizontal"`, `selected-icon` slot, badge `size`) was
already documented there — invoke the skill (the disclosure hook nudges you) instead
of reconstructing from generic Material memory. See `.claude/settings.local.json`.

## Representative vs showcase

Figma "component sets" are often **showcases** (the `list` set has 10 rows, the
`menu` set has ~7). Match the **structure and per-item content**, but use a
**representative count** — a 21-item menu snippet is unusable as a Code Connect
example. Emit what a developer would actually paste.

## Tooling

- `scratchpad/extract-examples.mjs` — property-driven example generator (flat
  components): reads `get_component_properties`, maps primitives, diffs vs
  `examples.json`. Slot-content components (list/menu/card/dialog) need the
  recursive slot pass.
- `scratchpad/render-all.mjs` — the visual gate renderer (code vs Figma).
- Bridge: `bun extract/relay/socket.ts` on `:3055`; channel varies per session.
