module Generate.SharedAttrs exposing (componentModuleName)

{-| Component → Elm module-name derivation, shared by `Generate` (declaration
rename) and `Generate.Normalize` (config lookup key).


## Where shared-attribute CONFLICT handling lives — and why not here

This module used to also carry a "shared attribute vocabulary" with its own
cross-component type-conflict mechanism (`canonicalSharedSpecs`, `conflictCapMap`,
`stampCaps`, `dominantTypeKey`, …) that suffixed the non-dominant type of a
conflicting attribute (`value` → `valueFloat`) and stamped it with a distinct phantom
capability. **None of it was ever called.** The legacy 5-form pipeline that consumed
it was retired; the phantom pipeline builds its own vocabulary in
`Generate.Phantom.Model` (`Brand.sharedAttrs`), and `LibraryInfo.conflictCaps` — the
only input `stampCaps` read — was hardwired to `Dict.empty`.

It cost a real bug. `elm-typed-html`'s manifest typed `datetime` as `string` on
`<ins>`/`<del>` and `number` on `<time>`; the doc comments here promised a suffixed
`datetimeFloat`, so nobody looked further, and `TypedHtml.Attributes.datetime` shipped
as `Float` with the `String` side silently dropped. The dead code was a decoy.

Conflict handling now lives in exactly three places, all live:

  - `Generate.Phantom.Emit.conflictsWithCanonical` — a component whose scalar type
    disagrees with the shared canonical gets a LOCAL, correctly-typed setter in its own
    module instead of delegating. Non-fatal and correct; @m3e/web relies on it. Every
    delegation site actually asks `divergesFromCanonical`, which is this predicate
    plus the attribute-vs-PROPERTY form (a form split delegates fine and is silently
    wrong, so it needs the same treatment); it calls this one rather than restating it.
  - `Generate.Phantom.Emit.guardHomeAttrTypes` — two elements sharing a `home`
    module that disagree is UNREPRESENTABLE (one module, one name, two types), so it
    fails the run and names the fix. This is the `datetime` guard.
  - `Generate.Phantom.Emit.guardHomeAttrForms` — the same guard transposed to the form
    axis, for the split that `_controlled`'s element scope makes reachable.

`Generate.Phantom.Model` additionally emits an info note naming which type each
cross-component canonical took, so the choice is never silent again.

Do not reintroduce a parallel mechanism here. The suffixing IDEA was not the mistake —
doing it automatically, from a `dominantTypeKey` nobody could see, was. Config
`_renames` is the sanctioned form: an author names the element whose value space is the
odd one out and what its setter should be called, `buildComp` moves `elmName` and
`capName` together so the rename is a fresh capability ROW, and the shared setter then
fails to compile against that element instead of being silently misapplied to it. That
is how `<progress>`/`<meter>`/`<li>` opt out of `value` in `elm-typed-html`; see
`Attr.AttrSpec.capName`.

@docs componentModuleName

-}

import Cem
import Generate.Types exposing (LibraryInfo)
import Naming


{-| The PascalCase module-name segment for a component (e.g. `sl-split-panel`
with prefix `sl-` -> `SplitPanel`). The library module name is prepended by the
caller.
-}
componentModuleName : LibraryInfo -> Cem.Declaration -> String
componentModuleName libraryInfo component =
    component.tagName
        |> Maybe.withDefault component.name
        |> String.replace libraryInfo.componentPrefix ""
        |> Naming.pascal
