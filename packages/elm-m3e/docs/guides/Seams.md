# Seams

A **seam** is any crossing point where a value from outside the typed IR
enters it. The IR itself is opaque — you cannot construct an `Element` from
raw `Html` by accident, because `fromNode`/`fromHtml` live only in `HtmlIr.Internal`,
which is lint-guarded and not re-exported from the public modules. The one
sanctioned userland door is `M3e.Unsafe` (and its attribute-side twin
`M3e.Unsafe.Attributes`) — published, generated escape surfaces that ship
*with* the library. There is no userland adapter module to hand-write anymore;
every crossing into the IR goes through one of the two mechanisms described
here.

This guide covers the **two sanctioned brand crossings** that the cross-CEM
initiative established (CX5). For a broader overview of the seam boundary and
why it exists, see [`DESIGN.md §6`](../DESIGN.md) and the
[`decisions.md CX5 entry`](../decisions.md#cx5--seams-are-loud-coercions-are-config-blessed-sugar).

## The two mechanisms

### 1. `recast` — the general loud crossing

`M3e.Unsafe.recast` is the general escape valve. It takes an `Element` with any kind
row and re-stamps it with any other kind row:

```elm
-- built on HtmlIr.Internal, shipped with the library:
recastAsButton : Element k msg -> Element { s | button : M3e.Kind.Brand } msg
recastAsButton =
    M3e.Unsafe.recast
```

`recast` makes no semantic claim — it just changes the phantom row. It is loud
by construction (you must write it explicitly) and greppable (one function name,
not an operator). `NoSeamOutsideAllowedModules` restricts which modules may call
it, so the design-system owner can audit every crossing point; app code
typically calls it from a small, named producer kept next to the feature that
needs it, rather than inline at every call site.

Use `recast` for crossings that have no stable, recurring semantic identity: a
one-off layout adapter, a foreign component you are integrating temporarily, a
crossing you expect to resolve when the library grows a proper slot.

### 2. `M3e.Coerce.*` — config-blessed typed crossings

Some brand crossings recur with a stable identity. A Chip acting as a button is
a design-system decision, not an accident. For these, the `_coerce` block in
`config/slots.json` declares the crossing, and the generator emits a typed
function in `M3e.Coerce`:

```elm
-- config/slots.json:
-- "_coerce": [{"from": "Chip", "fromKind": "chip", "to": "button", "name": "asButton"}]

-- Generated: src/M3e/Coerce.elm
asButton :
    HtmlIr.Element.Element { k | chip : M3e.Kind.Brand } admittedBy msg
    -> HtmlIr.Element.Element { s | button : M3e.Kind.Brand } admittedBy msg
asButton element =
    Ir.fromNode (HtmlIr.Element.toNode element)   -- Ir = HtmlIr.Internal
```

A named coercion differs from `recast` in two ways:

- **It is typed**: the from-kind is specific (`chip : M3e.Kind.Brand`), not
  polymorphic. Only an element that is already typed as a Chip will pass.
- **It is config-tracked**: it appears in `_coerce`, so the tool and reviewers
  can find every declared crossing without grepping the application code.

Use named coercions for crossings that appear in multiple places with the same
intent. If you reach for `recast` on the same crossing three times, that is a
sign it deserves a named coercion.

## What is NOT a seam crossing

The atom producers — `M3e.text`, `TypedHtml.text`, and the rest of `TypedHtml`'s
producers — carry a `HtmlIr.Kind.Shared`-typed row natively, no adapter
required. These are not seam crossings — they are atoms with a declared shared
role, and any m3e slot that opts in with the matching `shared:*` config entry
accepts them. The kind system allows the unification; no `recast` or coercion
is needed.

Similarly, m3e components in any closed private-tier slot accept their own brand
(`M3e.Kind.Brand`) freely — that is just the normal kind row system working.

## The review rules

Two elm-review-cem rules enforce seam discipline:

- **`NoInternalImportOutsideAllowed`** — the opaque-IR backstop: flags any import of
  `HtmlIr.Internal` (the seam stampers `fromNode`/`fromHtml`) outside the declared
  modules, so raw-to-IR crossings can only happen inside the library's own
  generated code — application code, including this docs app, is never on that list.
- **`NoSeamOutsideAllowedModules`** — flags use of `recast` (or any seam
  stamper reached through `M3e.Unsafe`) outside the set of modules a project
  declares as allowed, so every place an app reaches for the escape hatch is a
  deliberate, auditable choice:

```elm
NoSeamOutsideAllowedModules.rule
    { seamModules = [ "M3e.Unsafe" ]
    , allowedModules = [ "YourApp.Producers" ]
    }
```

Together these ensure every crossing is inside an auditable module, not
scattered across application code.

## Choosing between the two mechanisms

| Situation | Use |
|---|---|
| Crossing with a stable, recurring semantic identity (Chip as button) | Named coercion in `_coerce` |
| One-off crossing, no recurring semantic identity | `M3e.Unsafe.recast` |
| Atom producer (text, link, label, icon) entering a compatible slot | Neither — atoms flow freely via shared kind |
| Wrapping raw `Html` into the IR | `M3e.Unsafe.fromHtml` |
| A third-party custom element the library has no producer for | `M3e.Unsafe.customElement` |

The design principle: if you are uncertain which to use, start with `recast`.
If the same crossing recurs with consistent intent, promote it to a named coercion.
The test is whether the crossing has a name that another developer would recognize.
