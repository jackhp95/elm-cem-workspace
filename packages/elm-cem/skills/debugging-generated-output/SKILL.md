---
name: debugging-generated-output
description: >-
  Localizes why elm-cem generated the wrong Elm output — is the fault in the source
  CEM, in the config overrides, or a generator bug? Use in projects using elm-cem when
  generated bindings are wrong or surprising: an attribute has the wrong type, a
  component or module is missing or duplicated, a slot/event/token looks off, a setter
  is absent, or the output won't compile. Gives a mental model of the four CLI
  preprocessing passes and what each can corrupt, how to inspect the merged CEM elm-cem
  actually fed the generator, how to read the ⚠️/ℹ️ generator warnings, and how to
  classify-and-route a defect. The fix almost always lands in config
  (configuring-cem-overrides) or upstream in the CEM — never by hand-editing generated
  Elm, which a regen overwrites.
---

# Debugging elm-cem generated output

When the emitted Elm is wrong, resist patching the generated `.elm` — a `npm run gen`
overwrites it. Instead **localize the defect** to one of three fault sources, then fix it
at its source.

## The three fault sources a defect can live in

Every wrong-output defect traces to one of three sources — the **CEM**, the **config**, or
the **generator**. Name the source, then fix it there:

1. **The source CEM is wrong.** The `custom-elements.json` misdescribes the component
   (wrong attribute type, missing slot, a base class emitted as a component, a colliding
   `tagName`). elm-cem faithfully generates what the manifest says. **Fix upstream** (in
   the analyzer config / library) or **paper over it in `--config-from`**.
2. **Your config is wrong or missing.** The CEM is right but under-specified, and the
   override you'd expect isn't there or is malformed. **Fix the config** (see
   configuring-cem-overrides).
3. **The generator has a bug.** The CEM and config are both right, yet the output is
   wrong. **File an issue / fix the generator** (see extending-the-generator).

Most "bugs" are a **CEM** or **config** fault. Rule out those two first, then suspect the
**generator**.

## The four CLI preprocessing passes (what each can corrupt)

`bin/elm-cem.js` rewrites the CEM through four passes **before** the Elm generator ever
runs. Each writes a temp copy of the CEM and repoints `--flags-from` at it. Knowing which
pass owns which transform tells you where a surprising change came from:

1. **`reconcileTagNames`** (innermost) — overwrites each class declaration's `tagName`
   with the authoritative `custom-element-definition` export's `name`. Fixes analyzer
   bugs where a class carries a sibling's tag (which would otherwise merge two components
   into one and drop a module). Symptom if relevant: a component you expected went
   missing / merged.
2. **`recordTypeAliases`** — resolves named TS string-literal union aliases
   (`type Size = "small" | "large"`) into the CEM so alias-typed attributes become real
   Elm enums instead of falling back to `String`. Symptom if relevant: an attribute that
   *should* be an enum came out as `String` — the alias wasn't inlined (or lives in a
   `.d.ts` the pass couldn't find).
3. **`injectConfig`** — reads every `--config-from` file, deep-merges them, stores the
   result under the reserved `_config` key. Symptom if relevant: your override "did
   nothing" — likely a merge-order or malformed-key issue.
4. **`injectNativeAttrs`** (outermost) — reads `data/native-attrs.json` (the bundled
   HTML attr→element constraint table) and injects it under `_config._nativeAttrTable`.
   Libraries may override or extend the table via `--config-from`. Symptom if relevant:
   native attr setters missing or unconstrained — the bundled file may be absent from an
   unusual package installation (elm-cem warns loudly in this case).

## Inspect the merged CEM elm-cem actually fed the generator

The passes write temp files to the OS temp dir named `elm-cem-tag-*`, `elm-cem-nat-*`,
`elm-cem-cfg-*` (`<prefix>-<pid>.json`). The most useful is `elm-cem-cfg-*` — the fully
merged CEM with `_config` inlined, i.e. exactly what the generator saw:

```bash
ls -t "${TMPDIR:-/tmp}"/elm-cem-*.json | head        # newest temp copies from the last run
```

They're cleaned up on a clean exit; to keep one, inspect immediately after a run, or run
the generator, then before the process exits, capture it. Confirm your override landed:
does the component entry under `_config` have the field you set? Is the attribute's type
in the CEM what you assumed? This resolves CEM-vs-config in one look.

## Read the generator warnings

The generator emits `⚠️` / `ℹ️` lines to stdout — they are diagnostics, not noise:

- **`⚠️ CEM has no schemaVersion` / `Unknown CEM schemaVersion`** — the manifest is a
  schema major elm-cem wasn't validated against (it supports schema `1.x`). Output may be
  incomplete. CEM fault.
- **`ℹ️ Attribute "<name>" has multiple types across components`** — the same attribute
  name is typed differently on different components. elm-cem keeps them via type-suffixed
  variants (`value` + `valueFloat`), each with its own capability — **not** a failure,
  but if you wanted one uniform type, unify it with `attrTypes`. Config fault.
- **`⚠️ Value token "<x>" is minted from two literals`** — two enum literals camelCase to
  the same token (e.g. `"AUTO"`/`"auto"`). The row keeps the first; rename one literal or
  map both to the same string via `attrTypes`. CEM or config fault.
- **`⚠️ Slot helper "<x>" … collides …`** — a whole-slot helper name collided with a
  kind-specific placement helper and was renamed (`<x>Slot`). Informational.

## Classify-and-route

| Symptom | Likely source | Fix |
| --- | --- | --- |
| Attribute is `String`, should be enum/bool/number | CEM under-specified | `attrTypes` (config) |
| Attribute is `String`, alias exists in source | CEM/aliases | fix the `.d.ts` alias or add `attrTypes` |
| Component missing / two merged into one | CEM tagName bug | usually auto-fixed by pass 1; else upstream |
| Abstract base class emitted as a component | CEM over-broad | `_exclude` (config) |
| A slot/required field you want isn't there | config missing | `slots` / `required` (config) |
| Event has no typed payload | config missing | `events` (config) |
| Output doesn't compile / HtmlIr.* missing | IR peer dependency not installed | add `elm-html-intermediate-representation` to the generated package's `elm.json` dependencies |
| CEM + config both verified correct, output still wrong | generator bug | reproduce minimally, file an issue |

A minimal CEM snippet + the exact config used + the generated-vs-expected Elm is the
ideal bug report for a genuine generator defect.

---
Validated against elm-cem 1.0.0, 2026-07.
