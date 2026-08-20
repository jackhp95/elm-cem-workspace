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

This guide covers the **one sanctioned brand crossing**, `recast`. (The cross-CEM
initiative (CX5) originally established a second, config-declared crossing
mechanism alongside it; it was removed after review found it duplicated
`recast`'s job behind a narrower, ungated escape — see the
[`decisions.md CX5 entry`](../decisions.md#cx5--seams-are-loud-coercions-are-config-blessed-sugar)
for the full history.) For a broader overview of the seam boundary and why it
exists, see [`DESIGN.md §6`](../DESIGN.md).

## The mechanism

### `recast` — the general loud crossing

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

Use `recast` for every brand crossing — a one-off layout adapter, a foreign
component you are integrating temporarily, or a crossing that recurs with a
stable, well-understood intent (a Chip acting as a button). When a crossing
recurs, don't reach for a second, config-declared mechanism: wrap `recast` in a
small, named local function (`asButton = M3e.Unsafe.recast`) and keep it next
to the feature that needs it. That gives you the same self-documenting name a
config-declared crossing would have had, without a second generated escape
surface for reviewers to track.

**First, check whether config is the real fix.** Before reaching for `recast`
at all, ask whether the crossing should not need an escape in the first place —
if it does not conflict with the design system's own guidance, widen the
relevant slot's `admits` list in config instead. `recast` (and a named wrapper
around it) is for the case where the crossing genuinely conflicts with that
guidance and needs an explicit, reviewed exception.

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

## Choosing the right tool

| Situation | Use |
|---|---|
| A slot rejects a kind that does not conflict with the design system's own guidance | Widen the slot's `admits` list in config |
| A crossing that genuinely conflicts with that guidance, one-off or recurring | `M3e.Unsafe.recast` (wrap it in a small, named local function if it recurs) |
| Atom producer (text, link, label, icon) entering a compatible slot | Neither — atoms flow freely via shared kind |
| Wrapping raw `Html` into the IR | `M3e.Unsafe.fromHtml` |
| A third-party custom element the library has no producer for | `M3e.Unsafe.customElement` |

The design principle: fix it in config first if you honestly can. Reach for
`recast` only when the design system is genuinely wrong for your case — and if
the same crossing recurs with consistent intent, give it a name so another
developer recognizes it, rather than repeating the bare `recast` call.
