---
name: elm-m3e-docs-barrel-conversion
description: elm-m3e docs barrel conversion COMPLETE + verified 2026-07-13; barrel events are decoder-based (use Native.onClick for msg clicks); Shape.name / Theme scheme+contrast / Seams NavMenuItem intentionally stay non-barrel
metadata: 
  node_type: memory
  type: project
  originSessionId: 1a3abdd9-b1ed-45fe-b380-f23af8bea17c
---

The elm-m3e **docs barrel conversion** (the original ask behind `/tmp/markup-docs-barrel-handoff.md`) is DONE + verified 2026-07-13, uncommitted. ~24 docs files converted from `M3e.Record.*` / `M3e.Build.* `/ Standard component modules (`M3e.AppBar` etc.) to the one-import `M3e` barrel. Verified: all 25 routes `elm make` clean; full `elm-pages build` prerenders every route ("Success - Adapter script complete"); elm-review shows ZERO violations in docs code and ZERO `ValidSlotKind` violations.

**Recipe:** `Comp.view { content = C } [ Comp.variant Value.v, Comp.size Value.s, Comp.level N ] [ Comp.slot X ]` → `M3e.comp [ M3e.variant<V>, M3e.size<S>, M3e.attrLevel N ] [ C, M3e.<comp>Slot<Slot> X ]` (record `content`/`input`/`label` field becomes the FIRST child). `action = Action.none`→drop; `Action.link u`→`M3e.attrHref u`; `Action.linkWith {..}`→`attrHref`+`attrTarget`/`attrRel` as set.

**Non-obvious barrel API facts (bit me; the compiler catches them):**
- Barrel **events are decoder-based**: `M3e.onClick : Decoder msg -> Attr`. The component/`Action` `onClick` took a plain `msg`. For a msg click on a barrel component use **`Native.onClick msg`** (= `Seam.asAttribute (Html.Events.onClick msg)`) — the maintainer's blessed idiom, shown in `docs/app/Route/Examples/Feed.elm`.
- The barrel does NOT expose a **shape-name** setter (`M3e.shape` wants a `nameEnum` attr but there's no `attrNameEnum`); keep `M3e.Shape.name token` (Styles/Shape.elm). Same shape as `Native`/`Seam`: a sanctioned component-module escape the barrel can't express.
- The barrel has NO general **`attrScheme`/`attrContrast`** — only literal portmanteaus (`schemeAuto`, `contrastHigh`). For a computed token, map via a `case` returning the portmanteau attr (Shared.elm `schemeAttr`/`contrastAttr`). `attrColor`/`attrDensity` DO exist.

**Intended NON-barrel remainders (do NOT "finish" these — they're correct):** Seams.elm keeps `M3e.Record.NavMenuItem` because its `linkNavCode` string deliberately teaches the record form and the live `linkNav` demo must mirror it; Installation.elm's `import M3e.Button`/`Theme` are inside the Main.elm `"""` example string; CheatSheet/Strictness/Guide-Theming/Guide-Motion teach surfaces in strings; Doc/Usage.elm keeps its `codeFor`/`recordBuildCode` renderers + `"M3e.Record"`/`"M3e.Build"` labels (the surface-comparison machinery). Only page chrome (headings, surface-selector Tabs) was converted there.

Pre-existing (NOT mine): docs elm-review reports NoUnused.Exports / NoInternalImportOutsideAllowed in `../../elm-cem/markup/src/Markup/Build/*` — from the prior session's uncommitted markup codegen, see [[markup-categories-typed-globals-design]]. Related: [[elm-m3e-cross-cem-branding]].
