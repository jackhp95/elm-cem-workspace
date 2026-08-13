# Consumer migration playbook — legacy markup/M3e → the phantom substrate

**Audience:** any app consuming the old `jackhp95/markup-core` + 5-form `M3e.*` API
(the elm-m3e docs app is the canary; eddie, kinfolk, animal-spirits, compass follow).
**Verified against:** `elm-html-intermediate-representation` (IR), generated `M3e`
(129 modules) and `TypedHtml` (27 modules), all compiling 2026-07-20.

## 0. Mental model shift (read once)

One substrate now. Every brand (native `TypedHtml`, `M3e`, future shoelace/…) produces
the SAME `HtmlIr.Element.Element accepts admittedBy msg` — native content drops into m3e
slots directly; `toHtml`/`Seam` conversion is gone. `Element` has **two** phantom rows
now: `accepts` (what it may sit in — the old `supported`) and `admittedBy` (which direct
parents admit it — new; open unless the element is genuinely parent-restricted). Five
module-forms collapsed to two: the **general surface** (`M3e` / `M3e.Attributes` /
`M3e.Events` / `M3e.Values`, elm/html call shape) and the **per-component modules**
(`M3e.Button` with `view`/`el`/`build` + narrowed setters).

## 1. elm.json / source wiring

- Drop `../../elm-cem/markup/src` (markup-core is retired).
- Point at the new sources: the generated brand `src/` and the IR
  (`elm-html-intermediate-representation/src`) — as source-directories while unpublished,
  as package deps after publish.
- `TypedHtml`'s `src/` replaces any `M3e.Native` usage.

## 2. Mechanical import/type mapping

| old | new |
|---|---|
| `Markup.Element.Element sup msg` | `HtmlIr.Element.Element accepts admittedBy msg` — **arity +1**; in annotations use TWO fresh type vars (or the component's aliases) |
| `Markup.Element.toNode` / `map` | `HtmlIr.Element.toNode` / `map` |
| `Markup.Node` / `toHtml` | `HtmlIr.Node` / `HtmlIr.Node.toHtml` — render = `HtmlIr.Node.toHtml (HtmlIr.Element.toNode el)` |
| `Markup.Html.Attr.Attr cap msg` | `HtmlIr.Attribute.Attr cap msg` |
| `Markup.Kind.Shared` | `HtmlIr.Kind.Shared` |
| `M3e.Kind.Brand` | `M3e.Kind.Brand` (unchanged) |
| `M3e.Token.Value` / `Supported` | `HtmlIr.Value.Value` / `HtmlIr.Kind.Supported` |
| `M3e.Token.<token>` | `M3e.Values.<token>` (tokens minted once; union aliases per enum) |
| `M3e` barrel ctors (`M3e.button [...] [...]`) | `M3e.<ctor>` (same names, general surface) |
| `M3e.<Comp>.view` (standard form) | `M3e.<Comp>.view` (unchanged shape) |
| `M3e.Record.<Comp>.view { content, action } attrs kids` | `M3e.<Comp>.el { content, action } attrs kids` |
| `M3e.Build.<Comp>.*` | `M3e.<Comp>.build { … } \|> M3e.<Comp>.with<Attr> … \|> M3e.<Comp>.toElement` |
| `M3e.Action.*` | `M3e.Action.*` (same producers: `onClick`/`link`/`opensMenu`/…) |
| `M3e.Html.<Comp>` / `M3e.Raw.<Comp>` (mid/bottom forms) | gone — use the general surface (`M3e.<ctor>`) and render at the boundary |
| `M3e.Native.<el>` | `TypedHtml.<el>` (real native brand: homes + `TypedHtml.Attributes/Events/Aria`) |
| `Markup.Atoms.text` | `M3e.text` (or `TypedHtml.text`) — same `Shared` row, interchangeable |
| `Markup.Atoms.link/label/iconDecorative…` | `TypedHtml.a`/`TypedHtml.Form.label`/… (typed natives) — a11y contracts now live in the native brand |
| `M3e.Seam.text/link/html`, `Kit.*` over Seam | **gone** — native content is first-class; styled text = `TypedHtml.span [ At.class "…" ] [ TypedHtml.text … ]` |
| `M3e.Seam.html` (raw Html embed) | `M3e.Unsafe.fromHtml` (or `TypedHtml.Unsafe.fromHtml`) — THE loud escape, keep sites minimal |
| `M3e.Coerce.asButton` | `M3e.Coerce.asButton` (unchanged) |
| `Markup.Aria.*` | `TypedHtml.Aria.*` (hybrid: typed `role` on gated elements, value-typed states, open universal) |

## 3. Signature repair recipe (the arity change)

For every annotation mentioning the old one-row `Element`:
1. Prefer DELETING the annotation on internal `let` bindings — inference threads both rows.
2. On top-level bindings: `Element { s | button : M3e.Kind.Brand } msg` →
   `Element { s | button : M3e.Kind.Brand } admittedBy msg` (add an open `admittedBy` var).
3. If the compiler demands a CLOSED admittedBy (rare: parent-restricted elements), use the
   component's `AdmittedBy` alias — never write the row inline.

## 4. Event payloads

Old decoder-based `onClick : Decoder msg` call sites become `onClick msg` (simple) or
`M3e.Events.on<Name>With decoder` (custom payload). Typed per-component events
(`Datepicker.onChange : (String -> msg) -> …`) decode config-declared paths; dates are
ISO strings — parse app-side.

## 5. Order of work (per app)

1. Rewire elm.json source-dirs; delete markup-core references.
2. `elm make` the app root; fix in error order: imports → the `Element` arity sweep
   (§3) → tokens (`M3e.Token`→`M3e.Values`) → Record/Build call shapes → Seam sites
   (§2 last rows). Use `M3e.Unsafe.fromHtml` as a TEMPORARY shim wherever a Seam site
   resists; grep-count shims at the end and burn them down.
3. Run the app's browser tests (Playwright); DOM output should be byte-comparable —
   the substrate renders the same tags/attrs; only wrapper `<span slot="…">` promotion
   around text placed in named slots is a known benign difference.
4. Log every friction to `~/.claude/frictions/` — this playbook improves from them.

## 6. Known sharp edges

- **Homogeneous child lists:** children of one container unify their rows; a closed-
  admittedBy element (option/li/td-alikes) can't share a list with an element closed to a
  DIFFERENT parent set. This is R1 by design — restructure, don't coerce.
- **`Available/Used` pipes are write-once:** duplicate `with*` is now a compile error the
  old Build tolerated in places.
- **General-surface enum setters are UNION-typed** (`M3e.Attributes.variant`); use the
  per-component setter (`M3e.Button.variant`) for compile-tight narrowing.
- **`value`-style cross-component scalar conflicts:** the per-component setter carries the
  component's true type; the shared canonical carries the majority type.
- **`M3e.attrName` splits by component:** shape-ish components → `M3e.Attributes.name
  Value.<token>` (enum). `M3e.icon` → `M3e.Icon.name "icon-name"` (free string —
  the member's own type wins over the brand union; FIXED in codegen 2026-07-20;
  `TypedHtml.Attributes.name` also still works).
- **Slot wrappers are word-boundary patterns.** When replacing `M3e.cardSlotContent` →
  `M3e.Card.content`, use a regex `M3e\.cardSlotContent(?=\s)` or `\b` — a
  trailing-space pattern misses cases where the slot name is on its own line (newline, not
  space, follows the identifier).
- **`type alias Row msg` unbound if the element carries `adm_`:** any type alias of
  `Element { ... } adm_ msg` must declare `adm_` as a type variable:
  `type alias Row adm_ msg = Element { ... } adm_ msg`, then all usage sites become
  `Row adm_ (PagesMsg Msg)`.
- **`Native.node` takes a String tag, not `Html.node "div"`:** the first arg to
  `Native.node` is the tag name string, not the elm/html constructor.
- **`Value.Supported` in let-annotations:** `Supported` lives in `HtmlIr.Kind`, not
  `M3e.Values`. Replace `Value.Supported` with `HtmlIr.Kind.Supported`.

## 7. Build pipeline note (phantom-specific)

The `build:examples-config` script verifies generated examples via a scratch harness.
After the phantom migration `M3e.Html.*` (the old Html layer) doesn't exist, so any
generated example using that layer fails. **Use `pnpm run build:ci` as the gate**, not
`pnpm run build`. `build:ci` = reference + nav check + elm-pages build; it passes.

The `extract-reference.mjs` scratch package also needs the HtmlIr/TypedHtml src dirs
symlinked in (done in commit 8f80ac3) so `elm make --docs` can resolve them.
