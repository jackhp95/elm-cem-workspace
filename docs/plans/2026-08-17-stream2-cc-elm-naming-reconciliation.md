# Stream 2 — Code Connect → Elm naming reconciliation + compile-check gate

> Frontier initiative, Stream 2 (Phase 3 groundwork). Figma-INDEPENDENT — this
> whole plan is executable and verifiable without a live Figma bridge/MCP.
> Owner: figma-frontier branch. Do NOT push/merge to main — hand back to Jack.

## Problem

cem-figma-connect's emitted Code Connect Elm (`generated/m3-kit/elm/*.figma.ts`,
224 files) references **modules that do not exist** in the current elm-m3e, so a
consumer who pastes a snippet cannot compile it. Two independent staleness axes:

1. **Component module name drops the surface infix.** Snippets call
   `M3e.Button.component`, `M3e.Badge.size`, etc. and `import M3e.Button`. The
   real modules are `M3e.Component.Button` (strict per-component surface, exports
   `component`) and `M3e.Build.Button` (pipeline surface). `M3e.Button` is a
   **pre-R-025 flat name that no longer exists.**
2. **Text/attr seams point at deleted modules.** 63 snippets call `Kit.text`
   (`import Kit`); 2 call `Native.*`. Neither `Kit` nor `Native` exists in
   elm-m3e. The real text helper is `M3e.text` (the `M3e` barrel); custom HTML
   attrs are `TypedHtml.Unsafe.Attributes.customAttribute`.

## Root cause (file:line evidence)

### Axis 1 — the producer (elm-cem Face C)

`packages/elm-cem/codegen/Generate/Phantom/Emit.elm:6997` `surfacesOf` builds a
single module name and reuses it for BOTH the `top` and `build` surfaces:

```elm
-- Emit.elm:7000
moduleName =
    brand.lib ++ "." ++ (memberRef brand comp).module_        -- => "M3e.Badge"
...
top   = ( "top",   ... ("module", Encode.string moduleName) ... ("entry","component") )  -- 7011
build = ( "build", ... ("module", Encode.string moduleName) ... ("entry","build")     )  -- 7030
```

But the **source modules** the same file emits use the surface infix, proven by
the barrel's own import lines and the module guards:

- `Emit.elm:4729` — barrel imports each per-component module as
  `"import " ++ lib ++ ".Component." ++ (memberRef brand c).module_`
- `Emit.elm:6222` — `lib ++ ".Component." ++ (memberRef brand comp).module_`
- `Emit.elm:669` `guardComponentModule` — `brand.lib ++ ".Component." ++ comp.name`
- `Emit.elm:780` `guardBuildModule` — `brand.lib ++ ".Build." ++ comp.name`

So the Face-C `surfacesOf` is the ONE place that forgot the `.Component.` /
`.Build.` infix. `memberRef` returns `{ module_ = comp.name, ... }` for a normal
(non-home) component (`Emit.elm:5766`), so for badge `moduleName` resolves to
`M3e.Badge`, and the facts bundle carries `surfaces.top.module = "M3e.Badge"`.

**Confirmed downstream:** `profiles/m3-kit/facts/elm-api-facts.json` →
`components["m3e-badge"].surfaces.top.module == "M3e.Badge"` (should be
`M3e.Component.Badge`) and `.build.module == "M3e.Badge"` (should be
`M3e.Build.Badge`). The emitter faithfully propagates the fact: cem-figma-connect
`profiles/m3-kit/emitters/elm.mjs` uses `comp.module` for both the call site
(`${comp.module}.${setter}`, elm.mjs:431) and the import
(`usedImportsAdd(acc, comp.module)`, elm.mjs:410). Fix the fact → both fix.

### Axis 2 — the emitter seam config (cem-figma-connect profile)

`profiles/m3-kit/profile.json` `elm.textSeam = "Kit"`, `elm.attrSeam = "Native"`.
The profile's `$comment` justifies `Kit` by claiming *"elm-m3e has NO
library-exported text helper … `Kit` is the seam module elm-m3e's own examples
(config/examples.generated.json) … consistently import and call (`Kit.text`)."*

**That premise is now false — verified against the live tree:**
- `packages/elm-m3e/src/M3e.elm:3` exposes `text` (the `M3e` barrel; in the
  5-package split this ships in `jackhp95/elm-m3e-components`).
- `packages/elm-m3e/config/examples.generated.json` uses **`M3e.text`** 1150×
  and **zero** `Kit.text` / `Native.*`. Custom attrs there are
  `TypedHtml.Unsafe.Attributes.customAttribute` (521×) and `TypedHtml.Aria.*` (10×).

So the current elm-m3e convention is `M3e.text` + `TypedHtml.*`, not `Kit`/`Native`.

## Why this is NOT a Jack design decision (it's a bugfix toward stated topology)

`packages/elm-m3e/packages.json` defines the intended **5-package split** (D-045):

| package | buckets (exposed) |
|---|---|
| `elm-m3e-html` | `M3e.Action`, `M3e.Attributes`, `M3e.Events`, `M3e.Html`, `M3e.Kind`, `M3e.Unsafe*`, `M3e.Values`, `M3e.Forge.Internal` |
| `elm-m3e-facts` | `M3e.Review.Facts` |
| `elm-m3e-icons` | `M3e.Icon` |
| **`elm-m3e-components`** | **`M3e` barrel, `M3e.Component.*`, `M3e.Internal.Types.*`** |
| `elm-m3e-builder` | `M3e.Build`, `M3e.Build.*` |

So `M3e.Component.<Name>.component` + `M3e.text` are **first-class exposed API**
in the published topology, and the git trail confirms intent:
commit `5bc2ae4` — *"R-025 emitter change — M3e.Build.<X> routes phantom types
through **exposed** M3e.Component.<X>; land 5-package split (D-045)."* The later
`d471ba5 regen … (L5)` left the **aggregate dev** `packages/elm-m3e/elm.json`
exposing only `M3e.Build.*` — a dev-artifact state, not the published shape. The
per-component ctor surface `M3e.Component.*` and the `M3e` barrel are real,
compile against the split packages, and match Jack's recorded decisions
(component ctor = `component`; icons = opaque-`Name` via `M3e.Icon.*`).

**Conclusion:** emitting `M3e.Component.<Name>.component` + `M3e.text` is
restoring intended behavior. No new API decision required from Jack.

## The fix

### F1 — Producer (elm-cem `Emit.elm:surfacesOf`)

Split the single `moduleName` into per-surface names mirroring the source
generation (use the same `memberRef` the barrel/guards use, so facts can never
drift from emitted source again):

```elm
componentModule = brand.lib ++ ".Component." ++ (memberRef brand comp).module_
buildModule     = brand.lib ++ ".Build."     ++ (memberRef brand comp).module_
-- top surface   -> componentModule (entry "component")
-- build surface -> buildModule     (entry "build")
```

Edge cases to verify against regen output (not reason about):
- **home/native components** (`homeOf comp /= Nothing`): today they get the
  `html` surface (Emit.elm:7042). Confirm they still resolve — a home comp's
  `top`/`build` module must name an emitted module or the fact must omit that
  surface. The regen + compile gate is the oracle.
- The `html` surface (`brand.lib ++ ".Html"`, Emit.elm:7047) is already correct;
  do not touch.

Regen loop: `pnpm --filter cem-figma-connect run gen:facts` (runs elm-cem via
`tools/lib/regen.mjs`; needs `packages/elm-m3e/docs/node_modules/@m3e/web`).
Then re-emit CC: `pnpm --filter cem-figma-connect run gen:emit`.

This is a workspace-wide producer change: it also re-stamps the facts bundles of
the OTHER Face-C consumers (elm-m3e docs, tailwind-m3e-web, m3e-okf). Each has
its own facts copy regenerated by the same generator; `tools/gate-all.mjs` must
stay green across all of them. Blast radius is intended (per Jack: prefer
perfection over blast radius) but must be verified end-to-end.

### F2 — Emitter text seam (cem-figma-connect profile)

`profiles/m3-kit/profile.json`: `elm.textSeam "Kit" -> "M3e"`. Update the stale
`$comment` to reflect the verified reality (`M3e.text` is exported; examples use
it). 63 snippets flip `Kit.text` → `M3e.text` and `import Kit` → `import M3e`.

### F3 — Emitter attr seam (2 snippets only)

`elm.attrSeam "Native"` renders `Native.attribute "k" "v"`. The real spelling is
`TypedHtml.Unsafe.Attributes.customAttribute "k" "v"` — a module AND function
rename, not a simple seam swap (emitter `renderNativeAttr` hardcodes `.attribute`).
Options: (a) generalize `renderNativeAttr` to take a full `seam.fn`; (b) scope
this as a follow-up and let the compile gate flag the 2 files. Recommend (a) —
small, and needed for a fully-green gate.

### F4 — The compile-check gate (`tools/check-cc-elm-compiles.mjs`)

New gate that proves B's emitted Elm compiles against the real elm-m3e:

1. Read each `generated/m3-kit/elm/*.figma.ts`; extract the `figma.code\`…\``
   body + the `imports: [...]` array + the `const <hole> = instance.getX(...)`
   binding table.
2. Substitute each `${hole}` with a concrete Elm expr from its binding map
   (getEnum → first mapped value e.g. `M3e.Values.large`; getString → its
   default or `"x"`; getBoolean → `True`).
3. Emit ONE scratch module (`CcSnippets.elm`) with the de-duped union of all
   imports and one `snippetN = <body>` decl per example. Lists compile as
   `List (M3e.Element msg)`, singletons as `M3e.Element msg` (let Elm infer —
   no annotations).
4. `elm make --output=/dev/null` against a scratch `elm.json` whose
   `source-directories` reach `packages/elm-m3e/src` (+ any seam dirs) and whose
   `dependencies` mirror `packages/elm-m3e/docs/elm.json` (the proven set that
   already compiles this exact vocabulary). Report pass/fail per snippet from the
   compiler's module/line mapping.
5. **v1 = non-blocking report** (mirrors the token-change-report L7 landing):
   prints the failing set, exits 0, wired as `check:cc-elm-report`. After F1–F3
   turn it green, **flip to blocking** (`check:cc-elm-compile`, exits nonzero)
   and add to `gate-all`.

Rationale for v1-non-blocking-first: it reproduces the bug as a *measured*
failure before the fix (honesty: never fake green), then becomes the regression
lock once green. This is the "compile-check gate over B's emitted Elm" the
acceptance criteria call for.

Fallback if `elm make` dep resolution is unavailable offline: a static
module-reference existence check (every `import`ed + `Module.member`-referenced
module ∈ the elm-m3e emitted-source module set ∪ packages.json buckets). Weaker
(misses arg-type errors) but deterministic and offline. Prefer real `elm make`.

## Verification

- [ ] `gen:facts` baseline (no Emit.elm change) is byte-stable — proves the loop
      works and there's no pre-existing drift. (In progress.)
- [ ] After F1: `elm-api-facts.json` badge `top.module == "M3e.Component.Badge"`,
      `build.module == "M3e.Build.Badge"`; every other Face-C consumer's facts
      regenerated the same way; no home-component fact points at a missing module.
- [ ] After F2/F3 + `gen:emit`: `grep -c Kit\\. generated/m3-kit/elm/*.figma.ts`
      == 0; `grep -c Native\\.` == 0; `import M3e.Button` → `import M3e.Component.Button`.
- [ ] `tools/check-cc-elm-compiles.mjs` : RED before fix (documents the bug),
      GREEN after — captured compiler output, not "looks right".
- [ ] `pnpm --filter cem-figma-connect check` and `node tools/gate-all.mjs` green
      from clean; `pnpm check` byte-stable (regenerated 224 files committed).
- [ ] Commit-per-milestone: (a) gate v1 non-blocking + red evidence; (b) producer
      fix + regen; (c) seam fix + regen; (d) flip gate to blocking + gate-all green.

## Blast radius (a cost, not a blocker)

- elm-cem `Emit.elm` (1 producer edit) → regenerates Face C for **all**
  consumers (elm-m3e docs, cem-figma-connect, tailwind-m3e-web, m3e-okf) +
  the 224 CC `.figma.ts` + profile seam. Every `gate-all` item must stay green.
- No elm-m3e source or public-API change is required (the Component/barrel
  modules already exist and are exposed in the split packages). We do NOT touch
  the aggregate `elm.json` exposed-modules in this plan; the compile gate proves
  the snippets against `packages/elm-m3e/src` directly (source-directories, the
  way the docs app already validates this vocabulary).

## Relationship to Phase-1 L5 (engine A)

`docs/plans/2026-08-17-phase1-L4-facec-coverage-audit.md` deferred engine A's
migration on a "D-seam decision (what module is A's text/native/plain-HTML
seam)". This plan **answers that decision empirically** for engine B via
`examples.generated.json`: text=`M3e.text`, plain-HTML=`TypedHtml.*`,
custom-attr=`TypedHtml.Unsafe.Attributes.customAttribute`. The same seam mapping
unblocks A's L5 when it's picked up.
