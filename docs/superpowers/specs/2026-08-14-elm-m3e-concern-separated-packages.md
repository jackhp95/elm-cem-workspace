# Spec — concern-separated elm-m3e published packages (Move 2, generator change)

Status: **DRAFT for human approval** (per D-036: "change the generator, spec first").
Author: Gauntlet manager (`claude-opus-4-8`), 2026-08-14.
Supersedes: the byte-balanced A/B cut in D-035 (`tools/move2/` artifacts kept only for their
measurement harnesses). Reframes D-031c (flat-143 canonical) — see §2.

## 1. Goal

Publish the elm-m3e Elm API as **five concern-separated packages**, each of which compiles
standalone, fits under the registry's 768,000-byte uncompressed `docs.json` cap (target: also under
the project's 700,000-byte soft gate), and forms an acyclic package-dependency DAG. Generated from
the **current** `@m3e/web` CEM (2.7.3), not from stale committed output.

| # | Package | Exposes | Depends on |
|---|---|---|---|
| 1 | `jackhp95/elm-m3e-html` | the elm/html-style shared vocabulary: `M3e.Html`, `M3e.Attributes`, `M3e.Values`, `M3e.Events`, `M3e.Kind`, `M3e.Action`, `M3e.Coerce`, `M3e.Unsafe`, `M3e.Unsafe.Attributes` | IR, (facts?) |
| 2 | `jackhp95/elm-m3e-components` | per-component **required-record** modules `M3e.Component.<X>` (`view`, `el`, record types, narrowed values, record setters) + unexposed `M3e.Internal.Types.<X>` | html |
| 3 | `jackhp95/elm-m3e-builder` | per-component **phantom-builder** modules `M3e.Build.<X>` (`build`, `toElement`, `with*`) + unexposed `M3e.Build.Internal` | components, html |
| 4 | `jackhp95/elm-m3e-icons` | a **typesafe Material Symbols icon-name type** (NEW — see §5) | html |
| 5 | `jackhp95/elm-m3e-facts` | shared facts (`Cem.Facts`) | — |

The `M3e` general-surface barrel (re-exports every component constructor) and its placement is an
open item — see §7 (likely a thin top module in `elm-m3e-components`, or a 6th "umbrella" package).

## 2. Why this needs a generator change (and reframes D-031c)

The current `elm-cem` generator emits **one merged module per component**: flat `M3e.Button`
bundles the required-record surface (`view`, `el`), the phantom builder (`build`, `toElement`), and
narrowed values in a single module (`Emit.elm` `compModule`, verified). `split.js` can only assign
whole modules to packages — it cannot split a merged module's contents. Therefore packages 2 and 3
(components vs builder) require the generator to emit those as **separate modules** again, as the
older architecture (the committed 402-file tree) did.

This supersedes the flat-143 "canonical" decision (D-031c): that decision was internally consistent
with *today's* generator, but the product requirement (concern-separated packages) makes the
generator's flat/merged output the thing to change. "Generated code is the specification" is
preserved — we change the source/generator and regenerate; we do **not** hand-edit or publish the
stale committed 402 tree.

## 3. Measured feasibility (bytes + DAG)

Measured with the spike's `elm make --docs docs.json` harness on the committed 402 concern-separated
tree (which already has the separation and compiles), IR + facts vendored unexposed:

| Package | exposed modules | `docs.json` | % 768k cap | % 700k soft |
|---|---:|---:|---:|---:|
| elm-m3e-html (primitives) | 8–9 | **212,958 B** | 27.7% | 30.4% |
| elm-m3e-components (`Component.*`) | 130 | **432,693 B** | 56.3% | 61.8% |
| elm-m3e-builder (`Build.*`) | 131–132 | **592,171 B** | 77.1% | 84.6% |
| elm-m3e-facts (`Cem.Facts`) | 1 | tiny | <1% | <1% |
| elm-m3e-icons | 1 (a big type) | **TBD** — see §5 | ? | ? |

All measured packages fit under both caps with margin. (The spike's "builder = 810,420 B = 105.5%"
was a different, broken split configuration; the clean measurement is 592k.)

**DAG (verified in `src/`):** `Component.*` imports `Build.*` **0** times; `Build.*` imports
`Component.*` **130** times; both import unexposed `Internal.Types.*`; `Build.*` imports
`Build.Internal`. So the dependency is one-directional **builder → components → html**, i.e.
**acyclic**. The correct internal placement is: `Internal.Types.*` unexposed **in components**,
`Build.Internal` unexposed **in builder** (components never import it — 0). This is why the old
committed split "did not compile" (it mis-placed the shared internals, creating a components↔builder
cycle); the fix is placement, not a structural impossibility. The generator change MUST emit this
acyclic shape, and a standalone per-package compile (§6) is the gate that proves it.

## 4. The generator change (elm-cem codegen)

Change `Emit.elm` so that, instead of one merged `compModule` per component, it emits per component:
- **`M3e.Component.<X>`** — the required-record surface: `view`, `el`, the record types
  (`Is`, `Attrs`, `Content`, slot types), narrowed value types (`Shape`, `Size`, …), and record
  setters. Exposed.
- **`M3e.Build.<X>`** — the phantom-builder surface: `build`, `toElement`, `Builder`, cap types,
  `with*` setters. Exposed. Imports `M3e.Component.<X>` and `M3e.Build.Internal`.
- **`M3e.Internal.Types.<X>`** — the shared phantom-type internals. Unexposed; lives with components.

Plus the existing shared modules (`M3e.Build.Internal`, `M3e.Html`, `M3e.Attributes`, …) unchanged
in content. The change is essentially restoring the concern-separated emit the older generator had,
targeting the current CEM. `Cem.Facts` (the facts package) is unaffected.

**Constraints on the change:**
- Face A byte-identity harness (`tools/ab-elm-cem.sh`) currently pins **143 files** for the flat
  emit. The concern-separated emit changes the file set and count — so the A/B baseline is
  re-established at the new shape, and A/B thereafter proves the concern-separated emit is
  deterministic (pristine vs workspace elm-cem, same config → byte-identical). This is a deliberate,
  recorded change to what Face A measures, not a weakening.
- The facts bundle (Face B/C) and all consumers must stay green — the generator change is to the
  Elm EMIT only, not to the facts extraction.

## 5. Icons — the one genuinely new artifact (highest uncertainty)

Today icons are a plain `String` (`M3e.Icon` exposes `name : String -> …`, `withName`). "Typesafe
icons" means a generated Elm type whose values are the valid Material Symbols names, so
`M3e.Icons.home` is checked at compile time.

**Open design questions (need answering before building this package):**
1. **Source of the name list.** The `@m3e/web` CEM manifest does not enumerate Material Symbols
   names. Candidates: the Material Symbols font codepoints file (`MaterialSymbolsOutlined`… ~3,600
   names), or a curated subset. This is a NEW data source to vendor + a NEW generator step.
2. **Representation & size.** A custom type with ~3,600 zero-arg variants, or a set of top-level
   `home : Icon` constants, both produce a large `docs.json`. Rough order: 3,600 × ~25 B ≈ 90 KB of
   docs — likely well under cap, but MUST be measured before committing to one package. If a full
   set overflows, options are a curated common set or splitting the icon set.
3. **Wiring.** How `M3e.Icons.home` feeds the components' `icon`/`withIcon` slots (type plumbing
   from the icons package into components/builder without creating a dependency cycle — icons is a
   leaf that components may depend on, or the icon type lives in html/base and icons just provides
   the named values).

Recommendation: treat icons as a **separate, later part** (it is the only greenfield piece), ship
the html/components/builder/facts four first, and design icons once the concern-separated generation
exists. Flagged for the human — this may warrant its own mini-spec.

## 6. Gates (proving each package, keeping the workspace green)

- **Per-package standalone compile + size gate.** `elm-cem validate --src=<split> --packages=<cfg>`
  already exists (docs-size gate ≤ 700 KB) and `elm-cem split` already checks totality / disjointness
  / DAG-respect. Extend/wire these so each of the 5 emitted packages: (a) compiles standalone with
  the others as declared deps (the true isolation compile — vendor family deps unexposed, or stage in
  ELM_HOME), (b) is under the soft gate, (c) has no import cycle. A per-package "bite" test (make one
  package exceed cap → RED) proves the gate.
- **`tools/ab-elm-m3e-split.sh`** re-pointed at the new `packages.json` (5 packages, concern buckets)
  and re-baselined; proves the split step is deterministic.
- **`node tools/gate-all.mjs` stays green** (manager runs it; ~350 s) and **Face A A/B** re-baselined
  to the concern-separated file count, byte-identical thereafter.
- **No test deleted**; app/consumer tests repointed to the new module names (§7).

## 7. Migration (workspace consumers of the emitted API)

Adopting the concern-separated emit changes the committed `src/` and the modules apps import:
- The three elm-m3e Elm applications (`docs/`, `tests/`, `editor/`) compile against `../src` and use
  `M3e.<Component>` (flat) today — 127 `import M3e.Component.<X>` already exist in the workspace
  (V-C9) because much of it predates the flat merge, but the flat `M3e.<X>` imports and the merged
  surface usages must move to `M3e.Component.<X>` / `M3e.Build.<X>`. Exact counts to be re-derived
  against the concern-separated emit.
- `elm-review-cem` rule tests and the acid/spike suites encode API shape — repoint, do not delete.
- Consumers (cem-figma-connect, m3e-okf, tailwind) read the **facts bundle**, not the Elm modules, so
  they are largely unaffected; verify via `gate-all` + `check-drift`.

## 8. Sequencing (proposed gauntlet parts)

1. **Generator: concern-separated emit** — change `Emit.elm`; regenerate; prove the emit is acyclic
   and each concern group compiles. Re-baseline Face A. (Manager-designed bar; builder = Sonnet;
   Opus critic.)
2. **Split config + per-package gates** — `packages.json` for the 5 packages; wire standalone-compile
   + size gates; prove each package under cap with a bite test.
3. **Adopt committed `src/` + migrate apps/tests** — repoint the three apps + rule/acid tests; keep
   `gate-all` green.
4. **Icons** — separate part (or its own spec) per §5.
Each part lands with `gate-all` green and is revertible.

## 9. Non-goals / hard stops

- **DO NOT PUBLISH.** Stop and report at the publish boundary (the brief's hard rule). This spec
  covers up to "5 packages generated, compiling standalone, under cap, gate-all green" — not the
  registry push.
- Not touching the html→elm engine consolidation (the other Phase-1 item).
- Not changing the facts bundle / consumers' contracts.

## 10. Open questions for the human

1. **Icons source & scope** (§5) — full Material Symbols set vs curated subset; is the name-list
   source acceptable to vendor? Ship icons last / separately?
2. **The `M3e` barrel** — keep the one-import general surface? If so, which package hosts it
   (a thin module in `elm-m3e-components`, or a 6th umbrella package `elm-m3e`)?
3. **`elm-m3e-facts` naming** — the facts package exposes `Cem.Facts` (module namespace `Cem.*`, not
   `M3e.*`). Publish it as `jackhp95/elm-m3e-facts` exposing `Cem.Facts`, or keep the existing
   `jackhp95/elm-cem-facts`? (elm-review-cem already depends on `elm-cem-facts`.)
4. **Package names** — confirm `elm-m3e-html` / `-components` / `-builder` / `-icons` / `-facts`.
