---
name: auditing-m3e-escapes
description: >-
  Audits and eliminates needless escape-hatch calls in elm-m3e consumer code —
  `M3e.Unsafe.*`, `M3e.Unsafe.Attributes.*`, `TypedHtml.Unsafe.*`, `HtmlIr.Internal`,
  and hand-rolled `Html`/`Html.Attributes` in a typed tree. Use when reviewing or
  writing elm-m3e UI code, after any migration or codemod that rewrote escape calls,
  when someone asks whether an `Unsafe` call is justified, when adding a raw attribute
  or a custom element, or before merging a branch that touches views. Enforces the
  ladder M3e > TypedHtml > escape, and treats every surviving escape as something that
  must be individually justified in a comment.
---

# Auditing elm-m3e escapes

An escape is a call that leaves the typed tree. The library ships them on purpose,
lint-fenced and greppable. **They are a last resort, not a convenience.**

## The ladder

Always resolve in this order. Stop at the first rung that works.

1. **`M3e.*`** — a design-system component or its typed setter. If M3e models the
   thing, use M3e, even if raw HTML would be shorter.
2. **`TypedHtml.*`** — standard HTML element, attribute, ARIA helper, or event.
3. **Escape** — `M3e.Unsafe.*` / `M3e.Unsafe.Attributes.*`, and only for something
   the first two genuinely cannot express.

A escape that could have been rung 1 or 2 is a defect, not a style preference. It
throws away the slot-kind checking, the content model, and the capability row that
the whole substrate exists to provide.

## The audit

### 1. Enumerate

```bash
cd docs   # or the consumer app
rg -n 'M3e\.Unsafe\.[A-Za-z]|TypedHtml\.Unsafe\.[A-Za-z]|HtmlIr\.Internal' app/ src/ -g '*.elm' \
  | grep -v ':import' | grep -v '^\S*:[0-9]*: *--'
```

Also catch raw `elm/html` leaking into a typed tree, which is the same defect wearing
a different name:

```bash
rg -n '^import Html\b|^import Html\.Attributes|^import Html\.Events' app/ src/ -g '*.elm'
```

Ignore hits inside `"""…"""` string literals and `{-| … -}` doc comments — those are
rendered documentation, not code. Audit them separately (§4); wrong sample code
teaches the defect to every reader.

### 2. Classify every site

For each call, answer in order:

**Is it an attribute?** Look for a typed setter before assuming there isn't one.

```bash
# component-specific setter (rung 1)
rg -n "^<name> :" ../src/M3e/Attributes.elm ../src/M3e/<Component>.elm
# standard HTML attribute (rung 2)
rg -n "^<name> :" -A1 vendor/elm-foundation/TypedHtml/Attributes.elm
# ARIA
rg -n "^<name> :" -A1 vendor/elm-foundation/TypedHtml/Aria.elm
```

Enum-valued attributes take a `Value` token, not a `String` — `TypedHtml.Attributes.dir
(TypedHtml.Values.ltr)`, not `attribute "dir" "ltr"`. If your helper returns `String`,
change it to return `Value <Union>`; the token modules already export both the union
alias and the tokens.

**Is it an event?** Check the generated event surface, and check the `*With` variant —
the plain form takes a `msg`, the `*With` form takes a `Decoder msg`:

```bash
rg -n "^on[A-Z][A-Za-z]* :" -A1 ../src/M3e/Events.elm vendor/elm-foundation/TypedHtml/Events.elm
```

**Is it an element?** `M3e.Unsafe.fromHtml` wrapping hand-written `Html.div`/`Html.a`/
`Html.header` is always wrong — those are `TypedHtml.div` / `.a` / `.header`. It is only
justified for output you did not construct: rendered Markdown, a syntax highlighter,
raw SVG, a third-party library returning `Html msg`.

**Is it a custom element?** `M3e.Unsafe.customElement` + `M3e.Unsafe.Attributes.customAttribute`
are correct for a tag with no generated producer (`<model-viewer>`, `<slide-panels>`).
They are wrong for a standard tag — `customElement "div"` is a defect.

**Is it a `recast`?** A `recast` means "this slot's declared kinds are wrong for what I
must place." Before accepting it, check whether the real defect is upstream in config:
- Is the slot's `"multi"` wrong? A `false` that should be `true` forces a wrapper
  element, and the wrapper then needs a recast. Fixing `"multi"` removes both.
- Does the slot's `kinds` list actually match the upstream manifest's description?

### 3. Fix or justify

Every surviving escape needs a comment saying **which rungs were checked and why they
failed**. "No typed setter exists for `aria-hidden`" is a justification. Silence is not.

If an escape survives because the *library* is missing something — a typed setter that
should exist, a slot kind that is wrong — that is a codegen/config bug. File it. Do not
let a library gap masquerade as userland necessity.

### 4. Audit the prose too

Sample code in guide pages and doc comments is read as instruction. Run the same
enumeration over string literals and doc comments, and hold it to the same ladder. A
guide that shows `fromHtmlAttribute (class "…")` teaches readers to reach for an escape
where `TypedHtml.Attributes.class` exists.

### 5. Verify

```bash
cd docs && npx elm make $(find app src -name '*.elm' | tr '\n' ' ') --output=/dev/null
cd .. && npm run gate
```

`elm make` on a single route only compiles that route's import graph and will report
success while other routes are broken. Compile all of them, and run a real
`npm run build:site` — elm-pages' Lamdera wire codecs fail at build time, not at
`elm make` time.

## Known library gaps

Escapes that currently have no rung-1 or rung-2 alternative. Check whether these are
still true before accepting one:

None currently known. `aria-hidden` was the last entry here — `TypedHtml.Aria` now
exposes `hidden : Value Hidden -> Attr c msg` (enum-valued: `true`/`false`/`undefined`,
reusing the same tokens `checked`/`expanded`/`orientation`/… already mint), so a site
needing `aria-hidden` should call `Aria.hidden Aria.true` / `Aria.hidden Aria.false`,
not escape.

## Why this exists

A migration that mechanically rewrites `OldSeam.asAttribute` → `M3e.Unsafe.Attributes.fromHtmlAttribute`
*preserves* every escape instead of eliminating it, and the result looks clean because
the escape now has a blessed name. It is not clean. Rewriting an escape is not the same
as removing one, and only a per-site check against the ladder tells the difference.
