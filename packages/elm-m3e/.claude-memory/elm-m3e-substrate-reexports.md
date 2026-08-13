---
name: elm-m3e-substrate-reexports
description: elm-cem now re-exports every substrate type per brand so no consumer imports HtmlIr; docs app is at zero HtmlIr/Seam and kit/ is deleted; RC5 cross-brand gap still open
metadata: 
  node_type: memory
  type: project
  originSessionId: adeeda52-06d6-40f1-9aeb-16b125e71ab3
  modified: 2026-08-04T22:13:34.361Z
---

As of 2026-08-04, `elm-cem` emits one shared substrate re-export block
(`substrateReExport{Names,Imports,Decls}` in `codegen/Generate/Phantom/Emit.elm`)
used by both the brand barrel and the published `<Lib>.Html`. Every brand now
re-exports `Element`, `Attr`, `Node`, `toHtml`, `toNode`, `mapMsg`, `mapNode`,
plus `Value` on `<Lib>.Values` and `Supported`/`Shared` on `<Lib>.Kind`. The
escape surface is `<Lib>.Unsafe` (`fromHtml`, `fromNode`, `recast`, `recastAll`,
`customElement`) and `<Lib>.Unsafe.Attributes` (`fromHtmlAttribute`, `recastAttr`,
`recastAttrAll`, `customAttribute`). **No consumer should ever need to import
`HtmlIr.*`** — if one does, that is a codegen gap, not a userland problem.

One emitter serves 6 brands (elm-m3e, elm-typed-html, elm-web-awesome,
elm-shoelace, elm-calcite, elm-fluent-ui); regeneration is deterministic with no
API cost. `docs/kit/` in elm-m3e is deleted — `Kit`/`Native`/`Seam` were all
superseded, and `ExampleNav` (an ordinary docs component) moved to `docs/src/`.

**Still open — RC5.** M3e slot kinds are config strings in `config/slots.json`;
the `shared:` prefix desugars to the cross-library `HtmlIr.Kind.Shared`, a bare
name to the brand-private `M3e.Kind.Brand`. The kind `"html"` means "arbitrary
native HTML" but desugars brand-private, so **no `TypedHtml.*` element can ever
satisfy it** (27 rows, 6 modules). Needs its own plan doc. The reverse direction
(M3e components inside native containers whose `*Content` rows enumerate tags) is
harder and may stay an explicit `M3e.Coerce` / `Unsafe.recast` crossing.

Three traps that cost real time here:

- **`elm-cem validate` measures ALL modules, not the published set.** It reports
  elm-m3e at 187% of the 700 KB registry docs cap; the actually-published 10
  modules are ~27%. Use `validate --emit-docs=<path> --no-assert` and sum over
  `elm.json`'s `exposed-modules` before concluding anything about headroom.
  `_publishGeneralOnly: true` exists for this cap, so the barrel stays unexposed.
- **elm-pages injects Lamdera wire codecs for type aliases declared in Route
  modules.** An alias containing an *extensible* record fails the site build
  (`w3_encode_*`), never at `elm make`. Keep such aliases closed.
- **`elm make app/Route/Index.elm` only compiles that route's import graph** and
  will report zero errors while other routes are broken. Verify with
  `elm make $(find app src -name '*.elm')` and a real `npm run build:site`.

Plan doc with full root-cause analysis and measurements:
`~/Documents/code/planning/2026-08-04-elm-m3e-substrate-leak-elimination.md`.
Related: [[elm-m3e-cross-cem-branding]], [[elm-cem-codegen-overhaul]],
[[elm-m3e-family-git-hygiene]].
