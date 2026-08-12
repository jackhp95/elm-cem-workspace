# Open (unconstrained-row) global attributes

Date: 2026-08-05
Repo: `elm-cem` (implementation); touches `elm-typed-html` (config + regen) and `elm-m3e` (dependency bump only)
Status: approved design, not yet planned

## Problem

`elm-m3e`'s docs `Shared.elm` cannot place `dir` on the `m3e-theme` host:

```elm
M3e.theme
    [ M3e.Theme.color model.seed
    , TypedHtml.Attributes.dir model.dir  -- does not typecheck
    ]
```

`M3e.Theme.Attrs` (`src/M3e/Theme.elm:43`) is a closed row —
`{ class, color, contrast, density, id, motion, onChange, scheme, slot, strongFocus, style, variant : Supported }`
— with no `dir` field, so `TypedHtml.Attributes.dir : Value Dir -> Attr { c | dir : Supported } msg`
cannot unify with it. This is recorded as BLOCKED in `elm-m3e`'s
`specs/2026-08-05-theme-host-view-restructure-design.md`.

The absence isn't a design decision — no m3e config ever populated `_globals`
(`elm-m3e/config/slots.json` has none), so it silently inherits elm-cem's
four-item `defaultGlobals` (`Model.elm:1123-1129`). `lang`, `tabindex`,
`hidden`, and `title` are absent from every m3e element for the identical
reason.

## Precedent: the ARIA hybrid already draws the right line

`TypedHtml.Aria` (elm-m3e `docs/DESIGN.md` §6) already splits attributes on
exactly the axis this spec needs:

```elm
-- elm-typed-html/src/TypedHtml/Aria.elm
label : String -> Attr c msg                          -- fully open: composes anywhere
role  : Value tags -> Attr { c | role : tags } msg     -- deliberately closed
```

`role` stays gated because a role's *validity* genuinely depends on the
element (`role="tab"` on a bare `<div>` should be rejected). `label` is open
because it never does. `dir`, `lang`, `tabindex`, `hidden`, `title` have
`label`'s shape, not `role`'s — no element restricts what value they may
carry — but they currently go through the OTHER, closed, per-brand `_globals`
path, because that path predates the ARIA-hybrid insight and was never
revisited.

## Non-goals

- Migrating `class`/`id`/`slot`/`style` to the open mechanism. They already
  reach every element that needs them today, structurally — every brand's
  `_globals` roster already includes them, closing every element's row. A
  real future cleanup, not required to fix this problem.
- `popover`, `contenteditable`, `is`, and the text-editing hint attributes
  (`autocapitalize`, `autocorrect`, `enterkeyhint`, `inputmode`,
  `writingsuggestions`). These interact with a component's own behavior
  (top-layer stacking, rich editing) in ways `dir`/`lang`/`tabindex`/`hidden`/
  `title` don't, and deserve individual review rather than a blanket include.
- Any m3e-side (or calcite/shoelace/fluent-ui/web-awesome-side) config
  change. None of those brands' configs are touched by this spec.

## What already exists

- `_globals` already supports arbitrary `AttrType`s — bool/int/float/string/
  enum — via `globalDecoder` (`Model.elm:1029-1097`), whose own doc comment
  already shows `{"name": "dir", "type": ["ltr","rtl","auto"]}` as the worked
  example.
- `elm-typed-html/config/config.json` already carries `dir`/`lang`/
  `tabindex`/`hidden`/`title` as populated (closed) `_globals` entries — the
  argument-side typing (`Value Dir`, `Int`, enum-not-bool `hidden`) is already
  correct and already shipping. Only the row needs to change.
- The open-row signature template already exists and ships today, just from
  a different emitter: `universalSetters` (`Emit.elm:5556-5568`), reachable
  only from the ARIA-specific code path, hardcoded to the `"aria-"` prefix:
  ```elm
  Naming.camel name ++ " : String -> Attr c msg"
  ```

## Design

Two coupled changes, both in `codegen/Generate/Phantom/`.

### 1. `_globals` entries gain an optional `row`; `Brand` splits into two lists

Config shape (new optional key; its absence preserves every existing
config's current meaning exactly):

```json
{ "name": "dir", "type": ["ltr", "rtl", "auto"], "row": "open" }
```

`globalDecoder` (`Model.elm:1029`) changes shape from `D.Decoder Attr.AttrSpec`
to `D.Decoder ( Bool, Attr.AttrSpec )`, decoding `"row"` (default `"closed"`)
alongside the existing name/type decoding. The one choke point every
downstream global-consumer already reads (`Model.elm:1285-1286`, per its own
comment: "Brand.globals, whence the global setters, the builder pipes and
every element's Attrs row") partitions instead of only filtering:

```elm
( openGlobals, globals ) =
    raw.globals
        |> List.filter (\( _, g ) -> not (Attr.kernelBlocked g))
        |> List.partition Tuple.first
        |> Tuple.mapBoth (List.map Tuple.second) (List.map Tuple.second)
```

`Brand` (`Model.elm:400-414`) gains one field, `openGlobals : List Attr.AttrSpec`,
alongside the unchanged `globals`. `attrsFields` (`Emit.elm:1293-1299`) and
its seven call sites (builder `with<Field>` names, the `Attrs` alias, the
"Available" caps record, `Review.Facts` pairs) read only `brand.globals`
today and need **zero edits** — an open entry simply never reaches them.

### 2. `plainSetterDecl` / `enumSetterDecl` take a `rowOpen` flag

```elm
plainSetterDecl : Bool -> String -> Attr.AttrSpec -> List String
plainSetterDecl rowOpen docText a =
    let
        rowType =
            if rowOpen then
                "c"
            else
                "{ c | " ++ a.capName ++ " : Supported }"

        body = ... -- unchanged
    in
    [ "", "", doc docText
    , a.elmName ++ " : " ++ setterInputType a ++ " -> Attr " ++ rowType ++ " msg"
    ]
        ++ body
```

`enumSetterDecl` takes the identical parameter and branch. Four existing call
sites need `False` threaded through, not just the two inside the globals
block (`Emit.elm:3752`, `:3755`): the shared-vocabulary wrappers `plainSetter`
(`:3777-3778`, called from `:3992`) and `enumSetter` (`:3869,3886`, called
from `:3995`) each make a direct call too. All four are one-line changes —
none touch either function's body, only which literal they pass for
`rowOpen`. Closed globals and every component/controlled attribute setter
then emit byte-identical output to today. A new block walks
`brand.openGlobals` through the same two functions with `True`:

```elm
openGlobalDecls =
    brand.openGlobals
        |> List.concatMap
            (\g ->
                case ( isEnumSpec g, unionFor brand g.elmName ) of
                    ( True, Just union ) -> enumSetterDecl True (globalDoc g) g.htmlName union
                    _                     -> plainSetterDecl True (globalDoc g) g
            )
```

Computing `openGlobalDecls` is not sufficient on its own — two wiring points
in `attributesModule` (`Emit.elm:3660-3997`) both currently read only
`brand.globals` and must be updated too, or the new declarations exist but
never reach a usable state:

- `globalNames` (`:3677-3680`) feeds the module's `exposing (...)` via
  `exposeBlock`/`docsBlock` (`:3962-3985`). It must also fold in
  `brand.openGlobals |> List.map .elmName`, or `dir`/etc. are declared but
  private — unusable from any other module, `TypedHtml.Attributes.dir`
  included.
- The module body itself (`:3990-3996`, the `List.concat [ imports, globals,
  ..., enumAttrs |> List.concatMap enumSetter ]` that becomes the literal
  file text) must actually splice `openGlobalDecls` in alongside `globals`.
  Left out, this is not a compile error at the generator level — the
  declaration is simply never written to the output file, so the missing
  function surfaces downstream with no error pointing at the cause.

Verification for this spec must check the generated file directly (grep for
`dir` in both the body and the `exposing (...)` header), not just that
generation exits zero.

### Generated output, before/after (`dir`, one attribute)

`TypedHtml/Attributes.elm:93-97`, today:

```elm
{-| The global `dir` attribute.
-}
dir : Value TypedHtml.Values.Dir -> Attr { c | dir : Supported } msg
dir value_ =
    Ir.attribute "dir" (HtmlIr.Value.toString value_)
```

Proposed — one line changes, argument/body/doc untouched:

```elm
dir : Value TypedHtml.Values.Dir -> Attr c msg
```

Every generated `Attrs` alias in every brand loses the `dir : Supported`
line (`TypedHtml/Grouping.elm:40` and 14 other sites in elm-typed-html
alone) — `dir` no longer needs to be declared anywhere to be usable.

## Naming and guards

- The `kernelBlocked` filter runs before the partition, so a kernel-blocked
  name (`is`) is dropped regardless of its `row` value — open doesn't bypass
  that guard.
- The K2 same-name collision check against per-component CEM attributes must
  run over `openGlobals` exactly as it does `globals` today — an open global
  colliding with a component's own conflicting attribute of the same name is
  a hazard independent of row shape.
- `"row"` absent defaults to `"closed"`, so every existing config across
  every brand (`elm-typed-html`'s 27 entries, any brand in `cem-configs/`)
  produces identical output with zero edits to that config.
- `isGlobalName` (`Emit.elm:1461-1463`, currently
  `brand.globals |> List.any (\g -> g.elmName == elmName)`) must check
  `openGlobals` too, or its three call sites drift out of sync with what
  "is this name a global" actually means the moment any global moves to
  open. Two of the three (`Emit.elm:437`, `:3763`) guard against
  double-emitting a per-component enum that a global already owns — for an
  *enum* global (`dir`, `hidden` are both enums in this spec's scope), a
  stale answer means a real collision: the per-component path and the
  open-globals path could both emit a setter of the same name into the same
  module. Fix at the source (`isGlobalName` itself), not at each call site:

  ```elm
  isGlobalName : Brand -> String -> Bool
  isGlobalName brand elmName =
      brand.globals |> List.any (\g -> g.elmName == elmName)
          || (brand.openGlobals |> List.any (\g -> g.elmName == elmName))
  ```

## Blast radius

- **elm-cem**: `Model.elm` (decoder + `Brand` shape) and `Emit.elm` (two
  decl-builders gain a parameter; every existing call site updated to pass
  `False`). Additive to the config surface; no other brand's generated
  output changes, because no other brand's config uses `"row": "open"`.
- **elm-typed-html**: `config/config.json` flips `dir`/`lang`/`tabindex`/
  `hidden`/`title` — the exact five named as load-bearing in this morning's
  blocked-hoist finding — to `"row": "open"`. Regenerate (`npm run gen`);
  `check:whatwg` and `check:drift` (`scripts/check-whatwg.mjs`,
  `scripts/regen-diff-gate.sh`) must stay green.
- **elm-m3e**: zero code or config changes. `M3e.Theme.Attrs` — and every
  other m3e element's `Attrs` — is untouched, because open globals never
  enter any brand's row-closure. Bump the `elm-typed-html` dependency once
  published; no `npm run gen:src` regen needed.
- The currently-uncommitted `docs/app/Shared.elm` diff (class/dir hoisted
  directly onto `M3e.theme`, wrapper `<div>` removed) is the acceptance
  test: it should compile unmodified once the dependency bumps.

## Verification

- New elm-cem fixture: a config with one open bool global, one open enum
  global, and one closed global of matching shape. Assert the open entries'
  generated signatures carry no row refinement and are absent from every
  fixture element's `Attrs` alias; assert the closed one is byte-identical
  to today.
- Regression fixture: every entry in every real config currently under
  `cem-configs/` and `elm-typed-html/config/config.json` regenerates to
  identical output through the new decoder (proves the `"closed"` default
  is non-breaking).
- elm-typed-html: regenerate, `check:whatwg` and `check:drift` green,
  confirm `dir`/`lang`/`tabindex`/`hidden`/`title` no longer appear in any
  generated `Attrs` alias.
- elm-m3e: bump dependency, apply the existing `Shared.elm` diff, `elm
  make`/`npm run gate` green with no other file touched.

## Consumers

elm-m3e's `specs/2026-08-05-theme-host-view-restructure-design.md` BLOCKED
hoist is unblocked once this lands and the dependency bumps — the
previously-reverted `Shared.elm` diff is re-applied, not redesigned.
