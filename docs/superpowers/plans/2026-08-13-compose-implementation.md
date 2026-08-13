# Compose Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship `jackhp95/elm-cem-compose` — a headless, type-directed element-tree editor driven entirely by `Cem.Facts` — plus one consumer route at `/components/compose` in elm-m3e's docs app that proves it.

**Architecture:** A `type: package` Elm package that depends on `elm/core`, `elm-community/list-extra`, and `jackhp95/elm-cem-facts` and **nothing else** — no `elm/html`, so it cannot leak a view. It owns the `Node` tree, path-addressed edit logic, and pure query functions over `List Fact`. The elm-m3e docs route owns 100% of the rendering: three independent recursive folds over the same tree (editor cards, live preview, Elm-snippet codegen) plus a mechanically-derived attribute-kind/dispatch table.

**Tech Stack:** Elm 0.19.1, `elm-test-rs` 1.0.0, `elm-format` 0.8.7, pnpm workspaces, elm-pages 12.3.0 (docs app), Playwright (browser tests), Node ESM scripts for codegen.

**Spec:** `docs/superpowers/specs/2026-08-13-compose-design.md` — **read it in full before Task 1.** This plan implements that spec; where they disagree, the spec wins and the executor escalates, *except* for the three deviations recorded below, which were verified against disk during planning.

---

## Global Constraints

Every task's requirements implicitly include this section.

- **Repo root:** `/Users/jhp/code/jackhp95/elm-cem-workspace`. All paths below are relative to it.
- **Never edit `/Users/jhp/code/jackhp95/elm-m3e/`** (the standalone checkout). It is a copy-fidelity oracle; `tools/copy-fidelity-elm-m3e.sh` in the gate goes red if it drifts. Spec §11.
- **The core package must never gain `elm/html`.** `packages/elm-cem-compose/elm.json` may declare exactly `elm/core`, `elm-community/list-extra`, `jackhp95/elm-cem-facts`. Spec §10, §15.
- **`grep -ri "m3e" packages/elm-cem-compose/src` must return nothing.** This is a gate check added in Task 7. Spec §15.
- **Generated code is the specification.** Never hand-edit an emitted file to make a check pass — change the emitter and regenerate. Workspace-wide rule, inherited from `docs/superpowers/plans/2026-08-12-elm-cem-workspace-phase0-gauntlet.md`.
- **Direct-to-main, no feature branches.** These repos commit directly to `main`. Creating a branch is a human-gated act.
- **Elm formatting is gated.** `elm-format --validate` covers `docs/app` (via `packages/elm-m3e/package.json` `check:format`) and every new package must gate its own `src/` and `tests/`. Run `elm-format --yes` before every commit.
- **"Builder" is a forbidden name** at every layer — package, module, route. `jackhp95/elm-m3e-builder` already exists and is unrelated. Spec §1.2.
- **The core has no `Cmd`, no `Effect`, no ports.** `update : Msg -> Model -> Model`. Spec §6.1.
- **Commit after every task.** Frequent commits; each task ends green.

---

## Deviations from the spec, verified on disk during planning

The spec's §9.6 and §10 were written from research that three details have since been checked against and found wrong or incomplete. **These are corrections, not scope changes.** Apply them; do not "fix" them back to the spec's wording.

1. **The facts package must be staged into `ELM_HOME` before anything can compile.** The spec does not mention this. `jackhp95/elm-cem-facts` is unpublished, and Elm resolves a *package's* `dependencies` from the `ELM_HOME` cache — **packages cannot declare `source-directories` at all**. `packages/elm-review-cem/bin/stage-facts-elm-home.mjs` exists precisely to seed that cache entry and is invoked from that package's `check:review` script. `elm-cem-compose` has the same dependency and needs the same treatment. Task 1 handles it.

2. **Nav registration does not go in `Shared.navSections`, and `check-nav.mjs` will not catch a missing entry.** The spec §9.6 item 3 says to add an entry under the `/components` prefix in `navSections` and that `check-nav.mjs` will fail otherwise. On disk (`packages/elm-m3e/docs/app/Shared.elm:1119-1175`) `navSections` has **no `components` entry at all** — the components drawer is *derived* from `docs/data/reference.json` in `currentSectionItems` (`Shared.elm:1391-1409`), and `check-nav.mjs` only validates that derived set against `reference.json`. It never reads `Shared.elm`. The correct change is to add a static link in the `Just "components"` branch of `currentSectionItems`, next to `"All components"`. Task 11 handles it.

3. **Tests live at `tests/src/*.elm`, not `tests/ComposeTest.elm`.** The spec §10 sketches the latter. The workspace house style for a `type: package` with tests is `packages/elm-review-cem/`: a sibling `tests/` directory that is its own `type: application` whose `source-directories` reach back into `../src` and across into `../../elm-cem/facts/src`, with modules under `tests/src/` and the runner invoked as `elm-test-rs --project tests --compiler node_modules/.bin/elm tests/src/*.elm`. Follow the house style.

---

## File Structure

**Phase A — the core package (new):**

| File | Responsibility |
|---|---|
| `packages/elm-cem-compose/elm.json` | Registry-faithful package manifest. The mechanical form of "headless". |
| `packages/elm-cem-compose/package.json` | `check` / `test` scripts. **Required** — `tools/gate-all.mjs` discovers work by looking for these two script names. |
| `packages/elm-cem-compose/bin/stage-facts-elm-home.mjs` | Seeds `ELM_HOME` with the unpublished facts package. Copied from `elm-review-cem`. |
| `packages/elm-cem-compose/src/Cem/Compose.elm` | The entire core. Single exposed module, ~500 lines. |
| `packages/elm-cem-compose/tests/elm.json` | Test application manifest. |
| `packages/elm-cem-compose/tests/src/FakeFacts.elm` | The hand-written fixture. No `M3e` anywhere. |
| `packages/elm-cem-compose/tests/src/StructureTest.elm` | Addressing, slot invariants, menu lifecycle. |
| `packages/elm-cem-compose/tests/src/SlotTest.elm` | Affordances and menu options — the §8.7 decision. |
| `packages/elm-cem-compose/tests/src/AttrTest.elm` | Attribute chips and menus. |
| `packages/elm-cem-compose/README.md`, `LICENSE` | Publishing hygiene. |

**Phase B — the consumer (new + modified):**

| File | Responsibility |
|---|---|
| `packages/elm-m3e/docs/elm.json` | **Modify** — two new `source-directories`. |
| `packages/elm-m3e/docs/scripts/gen-compose-attrs.mjs` | **Create** — derives the attr-kind + dispatch table from `M3e/Attributes.elm`. |
| `packages/elm-m3e/docs/app/Route/Components/Compose/Attrs.elm` | **Create, generated** — `kinds`, `toAttribute`, `witness`. Never hand-edited. |
| `packages/elm-m3e/docs/app/Route/Components/Compose/Render.elm` | **Create** — fold 2, `tagFor` + `renderNode`. |
| `packages/elm-m3e/docs/app/Route/Components/Compose/Codegen.elm` | **Create** — fold 3, `codeFor`. |
| `packages/elm-m3e/docs/app/Route/Components/Compose.elm` | **Create** — the elm-pages route + fold 1 (`viewNode`). |
| `packages/elm-m3e/docs/app/Shared.elm:1391-1409` | **Modify** — one nav link. |
| `packages/elm-m3e/review/src/CodegenReviewConfig.elm:69-77` | **Modify** — one allow-list entry. |
| `packages/elm-m3e/docs/tests-browser/compose.spec.ts` | **Create** — integration coverage of the wiring. |

Splitting the consumer into four modules rather than one is deliberate: the spec calls for three independent folds plus generated adapter data, the generated file must be separately regenerable without touching hand-written code, and `Route/Components/Name_.elm` in this app is already large enough to be hard to hold in context.

---

# Phase 0 — Preconditions (human gate, no code)

**This phase produces no commits. It exists so the executor does not silently guess an answer that belongs to a human.**

### Task 0: Confirm the package-boundary story before starting Phase B

**Files:** none — this is a read-and-escalate task.

- [ ] **Step 1: Read the two open boundary questions**

Read spec §11, §11.1, and §14 risk 4. Read `GAUNTLET-LEDGER.md` entry **D-031** (recorded in commit `7cbb425`).

The unresolved state, verbatim from the spec: **D-031** resolves that the elm-cem generator is canonical and its output is 143 modules in a flat `M3e.<Component>` namespace, *not* the 402-file `M3e/Build/*` + `M3e/Component/*` shape currently committed — which would mean `M3e.Component.Card` ceases to exist and `M3e.Card` replaces it. The ledger escalates this to a human and records it as **not yet decided**. Separately, **§11.1** records that `jackhp95/elm-m3e`'s `origin/main` is 27 commits ahead with a *different* 4-package layout, an `elm-m3e-icons` package, and a `M3e.Build.Internal` → `M3e.Forge.Internal` rename.

- [ ] **Step 2: Record the answer or the blocker**

Two questions need a human answer **before Phase B, not before Phase A**:

1. Which boundary story wins — D-031's 3-way cut in the workspace, or `origin/main`'s 4-package layout?
2. Is D-031's flat-namespace rename adopted before Compose is built, or does Phase B accept a known-cheap mechanical rename afterwards?

**Do not attempt to answer these. They are outside this plan's scope.** Escalate them and record the reply in `GAUNTLET-LEDGER.md`.

- [ ] **Step 3: Gate**

**Acceptance:** Phase A may start immediately and unconditionally — the core imports only `Cem.Facts`, whose shape survives every scenario (spec §11 consequence 2). **Phase B must not start until questions 1 and 2 have a recorded human answer.** If a human answer is not available and the work must proceed, Phase B may start against the *currently committed* spelling (`M3e.Component.Card`), which is what compiles today — but that decision must be recorded as accepted rename debt, not made silently.

---

# Phase A — The core package

Phase A is decision-independent and independently valuable. **Do not start Phase B until Phase A is green** (spec §15).

### Task 1: Package scaffold, facts staging, and gate discovery

**Files:**
- Create: `packages/elm-cem-compose/elm.json`
- Create: `packages/elm-cem-compose/package.json`
- Create: `packages/elm-cem-compose/bin/stage-facts-elm-home.mjs`
- Create: `packages/elm-cem-compose/src/Cem/Compose.elm`
- Create: `packages/elm-cem-compose/tests/elm.json`
- Create: `packages/elm-cem-compose/tests/src/SmokeTest.elm`
- Create: `packages/elm-cem-compose/README.md`, `packages/elm-cem-compose/LICENSE`

**Interfaces:**
- Consumes: `Cem.Facts.Fact`, `Cem.Facts.Facet(..)` from `packages/elm-cem/facts/src/Cem/Facts.elm`.
- Produces: a compiling, testable, gate-discovered package. Later tasks add only to `src/Cem/Compose.elm` and `tests/src/`.

- [ ] **Step 1: Create the package manifest**

Create `packages/elm-cem-compose/elm.json`, exactly:

```json
{
    "type": "package",
    "name": "jackhp95/elm-cem-compose",
    "summary": "Headless, type-directed element-tree editor over elm-cem facts",
    "license": "BSD-3-Clause",
    "version": "1.0.0",
    "exposed-modules": [
        "Cem.Compose"
    ],
    "elm-version": "0.19.0 <= v < 0.20.0",
    "dependencies": {
        "elm/core": "1.0.0 <= v < 2.0.0",
        "elm-community/list-extra": "8.7.0 <= v < 9.0.0",
        "jackhp95/elm-cem-facts": "1.0.0 <= v < 2.0.0"
    },
    "test-dependencies": {}
}
```

- [ ] **Step 2: Copy the facts staging script**

```bash
mkdir -p packages/elm-cem-compose/bin
cp packages/elm-review-cem/bin/stage-facts-elm-home.mjs packages/elm-cem-compose/bin/stage-facts-elm-home.mjs
```

Read the copied file. It computes `repoRoot` as the parent of `bin/` and `workspaceRoot` as `../..` from there, then locates `packages/elm-cem/facts`. Both hold identically for `packages/elm-cem-compose/bin/`, so **no path edit is needed** — verify this by reading, do not assume. Update only the header comment's first line to say `elm-cem-compose` instead of `elm-review-cem`.

Why this is needed: `jackhp95/elm-cem-facts` is unpublished, and a `type: package` cannot use `source-directories`. Every tool that reads this package's `elm.json` dependencies (`elm make`, `elm-review`, `elm-test-rs` against the package manifest) resolves them from `~/.elm/0.19.1/packages/`, which nothing else populates.

- [ ] **Step 3: Create the JS manifest so the gate finds this package**

Create `packages/elm-cem-compose/package.json`:

```json
{
  "name": "elm-cem-compose",
  "version": "1.0.0",
  "description": "Headless, type-directed element-tree editor over elm-cem facts",
  "license": "BSD-3-Clause",
  "private": true,
  "scripts": {
    "format": "elm-format src/ tests/src/ --yes",
    "check:format": "elm-format src/ tests/src/ --validate",
    "check:compile": "node bin/stage-facts-elm-home.mjs && elm make --docs=/dev/null",
    "check:headless": "bash bin/check-headless.sh",
    "check": "run-p \"check:*\"",
    "test:elm": "elm-test-rs --project tests --compiler node_modules/.bin/elm tests/src/*.elm",
    "test": "run-p \"test:*\"",
    "gate": "run-s check test"
  },
  "devDependencies": {
    "elm-tooling": "^1.20.0",
    "npm-run-all2": "^9.0.3"
  },
  "engines": {
    "node": ">=18"
  }
}
```

`tools/gate-all.mjs:232-250` discovers packages via `pnpm ls -r` and runs whichever of `check` / `test` exist. `pnpm-workspace.yaml` already globs `packages/*`, so no workspace file needs editing. `check:headless` is written in Task 7 — create a placeholder now so `check` does not fail:

```bash
mkdir -p packages/elm-cem-compose/bin
printf '#!/usr/bin/env bash\nexit 0\n' > packages/elm-cem-compose/bin/check-headless.sh
chmod +x packages/elm-cem-compose/bin/check-headless.sh
```

- [ ] **Step 4: Create the minimal module**

Create `packages/elm-cem-compose/src/Cem/Compose.elm`:

```elm
module Cem.Compose exposing (version)

{-| A headless, type-directed editor for building a valid tree of custom
elements from a machine-readable component manifest.

This module renders nothing. It owns Fact-derived state, path-addressed edit
logic, and pure query functions. The consumer writes every pixel.

@docs version

-}


{-| Placeholder, replaced in Task 2.
-}
version : Int
version =
    1
```

- [ ] **Step 5: Create the test application manifest**

Create `packages/elm-cem-compose/tests/elm.json`. Modelled on `packages/elm-review-cem/tests/elm.json` — the tests directory is its own application that reaches into the package source and across to the facts source, which is how an unpublished in-workspace dependency is compiled without the registry:

```json
{
    "type": "application",
    "source-directories": [
        "src",
        "../src",
        "../../elm-cem/facts/src"
    ],
    "elm-version": "0.19.1",
    "dependencies": {
        "direct": {
            "elm/core": "1.0.5",
            "elm-community/list-extra": "8.7.0"
        },
        "indirect": {}
    },
    "test-dependencies": {
        "direct": {
            "elm-explorations/test": "2.2.1"
        },
        "indirect": {
            "elm/random": "1.0.0"
        }
    }
}
```

- [ ] **Step 6: Write the smoke test**

Create `packages/elm-cem-compose/tests/src/SmokeTest.elm`:

```elm
module SmokeTest exposing (all)

import Cem.Compose
import Expect
import Test exposing (Test, describe, test)


all : Test
all =
    describe "scaffold"
        [ test "the package compiles and is importable from tests" <|
            \_ ->
                Cem.Compose.version
                    |> Expect.equal 1
        ]
```

- [ ] **Step 7: Install and run**

```bash
pnpm install
pnpm --filter elm-cem-compose run test
```

Expected: `elm-test-rs` reports 1 passing test.

```bash
pnpm --filter elm-cem-compose run check
```

Expected: format validates, `elm make --docs=/dev/null` succeeds (this is what proves the `ELM_HOME` staging worked — if it fails with "I cannot find jackhp95/elm-cem-facts", the staging script did not run or its paths are wrong).

```bash
pnpm tasks
```

Expected: output enumerates `packages/elm-cem-compose/elm.json` as a `type: package`.

- [ ] **Step 8: Write README and LICENSE**

`README.md`: a short description, the dependency list, and the one-paragraph statement of why there is no `elm/html`. Copy `LICENSE` from `packages/elm-cem/facts/LICENSE` (BSD-3-Clause, same author).

- [ ] **Step 9: Commit**

```bash
elm-format packages/elm-cem-compose/src/ packages/elm-cem-compose/tests/src/ --yes
git add packages/elm-cem-compose
git commit -m "Compose A1: scaffold elm-cem-compose, headless package with facts staging"
```

**Acceptance:** `pnpm --filter elm-cem-compose run gate` is green; `pnpm tasks` lists the package; `packages/elm-cem-compose/elm.json` names no dependency outside the three allowed.

---

### Task 2: Data model, addressing, messages, and update

**Files:**
- Modify: `packages/elm-cem-compose/src/Cem/Compose.elm` (replace entirely)
- Create: `packages/elm-cem-compose/tests/src/FakeFacts.elm`
- Create: `packages/elm-cem-compose/tests/src/StructureTest.elm`
- Delete: `packages/elm-cem-compose/tests/src/SmokeTest.elm`

**Interfaces:**
- Consumes: `Cem.Facts.Fact` (14 fields, see below).
- Produces, relied on by every later task:
  - `type Node` — **opaque**, constructor NOT exposed
  - `type Child = ChildNode Node | ChildText String | ChildIcon String` — variants exposed
  - `type AttrValue = AttrBool Bool | AttrString String | AttrFloat String | AttrInt String | AttrEnum String`
  - `type AttrKind = BoolAttr | StringAttr | FloatAttr | IntAttr`
  - `type PathStep = IntoSlot String Int` / `type alias Path = List PathStep`
  - `type MenuKind = AttrMenu String | SlotMenu String`
  - `type alias Model = { root : Node, facts : Dict String Fact, attrKinds : Dict String AttrKind, openMenu : Maybe ( Path, MenuKind ) }`
  - `type Msg` — 9 variants, listed below
  - `init : { facts : List Fact, attrKinds : Dict String AttrKind, root : String } -> Model`
  - `update : Msg -> Model -> Model`
  - `nodeAt : Path -> Model -> Maybe Node`, `factAt : Path -> Model -> Maybe Fact`
  - `componentOf : Node -> String`, `attrsOf : Node -> List ( String, AttrValue )`, `slotsOf : Node -> List ( String, List Child )`

- [ ] **Step 1: Write the fixture**

Create `packages/elm-cem-compose/tests/src/FakeFacts.elm`. `Fact` has exactly 14 fields — copy the field list from `packages/elm-cem/facts/src/Cem/Facts.elm`. **No `M3e` anywhere; the real 130-component bundle is deliberately not used** (spec §13).

```elm
module FakeFacts exposing (all, blank, byName)

import Cem.Facts exposing (Facet(..), Fact)


blank : String -> Fact
blank name =
    { component = name
    , module_ = "Fake." ++ name
    , enums = []
    , requiredSlots = []
    , multiSlots = []
    , attrRewrites = []
    , slotRewrites = []
    , slotKinds = []
    , slotUpgrades = []
    , groupConstructors = []
    , facets = [ Standard ]
    , requiredAttrs = []
    , actionMap = []
    , usesAction = False
    }


all : List Fact
all =
    [ { blankWidget
        | enums = [ ( "variant", [ "filled", "outlined" ] ) ]
        , attrRewrites =
            [ ( "disabled", "disabled" )
            , ( "label", "label" )
            , ( "count", "count" )
            , ( "ratio", "ratio" )
            , ( "variant", "variant" )
            , ( "onClick", "onClick" )
            , ( "label", "label" )
            ]
      }
    , { blankContainer
        | multiSlots = [ "unnamed" ]
        , slotKinds = [ ( "unnamed", [ "widget", "ghost", "container" ] ) ]
      }
    , { blankLabelled
        | requiredSlots = [ "headline" ]
        , slotKinds = [ ( "headline", [ "shared:text" ] ) ]
      }
    , { blankIconic | slotKinds = [ ( "lead", [ "shared:icon" ] ) ] }
    , { blankSingle | slotKinds = [ ( "only", [ "widget", "single" ] ) ] }
    , { blankMixed
        | slotKinds =
            [ ( "any", [ "shared:text", "shared:icon", "widget", "ghost" ] )
            , ( "flowy", [ "shared:flow", "widget" ] )
            , ( "unconstrained", [] )
            ]
      }
    ]


blankWidget : Fact
blankWidget =
    blank "widget"


blankContainer : Fact
blankContainer =
    blank "container"


blankLabelled : Fact
blankLabelled =
    blank "labelled"


blankIconic : Fact
blankIconic =
    blank "iconic"


blankSingle : Fact
blankSingle =
    blank "single"


blankMixed : Fact
blankMixed =
    blank "mixed"


byName : String -> Maybe Fact
byName name =
    List.filter (\f -> f.component == name) all |> List.head
```

Fixture notes, load-bearing for later tasks:

- `"ghost"` is named in `container.unnamed` and `mixed.any` but is **absent from `all`**, so it must be silently omitted everywhere.
- `widget.attrRewrites` deliberately contains a duplicate `"label"` (deduplication must be real, not cosmetic) and an `"onClick"` (excluded because it will be absent from `attrKinds`).
- `single.only` is not multi, so `max = Just 1`.
- **`container.unnamed` names `"container"` itself**, making the fixture self-recursive exactly as the real bundle's `navMenuItem`, `heading`, and `treeItem` are. Task 7's unbounded-depth test needs this, and so do the depth-2 tests below — after Task 4 tightens `update`, `AddChild` only succeeds for a component the slot actually names, so a test that nests `container` inside `container` would silently become a no-op if the fixture did not name it. Same reason `single.only` names `"single"`.

- [ ] **Step 2: Write the failing structure tests**

Create `packages/elm-cem-compose/tests/src/StructureTest.elm`:

```elm
module StructureTest exposing (all)

import Cem.Compose as C
import Dict
import Expect
import FakeFacts
import Test exposing (Test, describe, test)


kinds : Dict.Dict String C.AttrKind
kinds =
    Dict.fromList
        [ ( "disabled", C.BoolAttr )
        , ( "label", C.StringAttr )
        , ( "count", C.IntAttr )
        , ( "ratio", C.FloatAttr )
        ]


start : String -> C.Model
start root =
    C.init { facts = FakeFacts.all, attrKinds = kinds, root = root }


apply : List C.Msg -> C.Model -> C.Model
apply msgs model =
    List.foldl C.update model msgs


slotCount : C.Path -> String -> C.Model -> Int
slotCount path slot model =
    C.nodeAt path model
        |> Maybe.map C.slotsOf
        |> Maybe.withDefault []
        |> List.filter (\( n, _ ) -> n == slot)
        |> List.head
        |> Maybe.map (Tuple.second >> List.length)
        |> Maybe.withDefault 0


all : Test
all =
    describe "structure and addressing"
        [ test "init makes an empty root of the named component" <|
            \_ ->
                start "container"
                    |> .root
                    |> C.componentOf
                    |> Expect.equal "container"
        , test "an unknown root component still constructs; queries are empty" <|
            \_ ->
                start "nope"
                    |> (\m -> ( C.componentOf m.root, C.slotsOf m.root ))
                    |> Expect.equal ( "nope", [] )
        , test "AddChild on a multi slot appends" <|
            \_ ->
                start "container"
                    |> apply
                        [ C.AddChild [] "unnamed" "widget"
                        , C.AddChild [] "unnamed" "widget"
                        ]
                    |> slotCount [] "unnamed"
                    |> Expect.equal 2
        , test "AddChild on a non-multi slot replaces, keeping the SECOND component" <|
            \_ ->
                start "single"
                    |> apply
                        [ C.AddChild [] "only" "widget"
                        , C.AddChild [] "only" "single"
                        ]
                    |> (\m ->
                            ( slotCount [] "only" m
                            , C.nodeAt [ C.IntoSlot "only" 0 ] m |> Maybe.map C.componentOf
                            )
                       )
                    |> Expect.equal ( 1, Just "single" )
        , test "AddChild with a component absent from facts is a no-op" <|
            \_ ->
                start "container"
                    |> apply [ C.AddChild [] "unnamed" "ghost" ]
                    |> slotCount [] "unnamed"
                    |> Expect.equal 0
        , test "updateAt at depth 2 edits the right node" <|
            \_ ->
                start "container"
                    |> apply
                        [ C.AddChild [] "unnamed" "container"
                        , C.AddChild [ C.IntoSlot "unnamed" 0 ] "unnamed" "widget"
                        , C.SetAttr [ C.IntoSlot "unnamed" 0, C.IntoSlot "unnamed" 0 ] "label" (C.AttrString "deep")
                        ]
                    |> C.nodeAt [ C.IntoSlot "unnamed" 0, C.IntoSlot "unnamed" 0 ]
                    |> Maybe.map C.attrsOf
                    |> Expect.equal (Just [ ( "label", C.AttrString "deep" ) ])
        , test "an edit at depth leaves siblings byte-identical" <|
            \_ ->
                let
                    seeded =
                        start "container"
                            |> apply
                                [ C.AddChild [] "unnamed" "widget"
                                , C.AddChild [] "unnamed" "widget"
                                ]

                    sibling m =
                        C.nodeAt [ C.IntoSlot "unnamed" 1 ] m |> Maybe.map C.attrsOf
                in
                seeded
                    |> apply [ C.SetAttr [ C.IntoSlot "unnamed" 0 ] "label" (C.AttrString "x") ]
                    |> sibling
                    |> Expect.equal (sibling seeded)
        , test "a path landing on a ChildText is a no-op, not a crash" <|
            \_ ->
                let
                    seeded =
                        start "labelled" |> apply [ C.AddTextChild [] "headline" ]
                in
                seeded
                    |> apply [ C.SetAttr [ C.IntoSlot "headline" 0 ] "label" (C.AttrString "x") ]
                    |> Expect.equal seeded
        , test "an out-of-range index is a no-op" <|
            \_ ->
                let
                    seeded =
                        start "container" |> apply [ C.AddChild [] "unnamed" "widget" ]
                in
                seeded
                    |> apply [ C.SetAttr [ C.IntoSlot "unnamed" 7 ] "label" (C.AttrString "x") ]
                    |> Expect.equal seeded
        , test "nodeAt on a text child is Nothing" <|
            \_ ->
                start "labelled"
                    |> apply [ C.AddTextChild [] "headline" ]
                    |> C.nodeAt [ C.IntoSlot "headline" 0 ]
                    |> Expect.equal Nothing
        , test "SetChildContent sets a text payload" <|
            \_ ->
                start "labelled"
                    |> apply
                        [ C.AddTextChild [] "headline"
                        , C.SetChildContent [] "headline" 0 "Inbox"
                        ]
                    |> .root
                    |> C.slotsOf
                    |> Expect.equal [ ( "headline", [ C.ChildText "Inbox" ] ) ]
        , test "AddIconChild defaults to star" <|
            \_ ->
                start "iconic"
                    |> apply [ C.AddIconChild [] "lead" ]
                    |> .root
                    |> C.slotsOf
                    |> Expect.equal [ ( "lead", [ C.ChildIcon "star" ] ) ]
        , test "RemoveChild at index 0 shifts the former index 1 down" <|
            \_ ->
                start "container"
                    |> apply
                        [ C.AddChild [] "unnamed" "widget"
                        , C.AddChild [] "unnamed" "single"
                        , C.RemoveChild [] "unnamed" 0
                        ]
                    |> C.nodeAt [ C.IntoSlot "unnamed" 0 ]
                    |> Maybe.map C.componentOf
                    |> Expect.equal (Just "single")
        , test "RemoveChild drops the whole subtree" <|
            \_ ->
                start "container"
                    |> apply
                        [ C.AddChild [] "unnamed" "container"
                        , C.AddChild [ C.IntoSlot "unnamed" 0 ] "unnamed" "widget"
                        , C.RemoveChild [] "unnamed" 0
                        ]
                    |> slotCount [] "unnamed"
                    |> Expect.equal 0
        , test "the root cannot be removed by any message" <|
            \_ ->
                start "container"
                    |> apply [ C.RemoveChild [] "unnamed" 0 ]
                    |> .root
                    |> C.componentOf
                    |> Expect.equal "container"
        , describe "menu lifecycle"
            [ test "OpenMenu sets openMenu" <|
                \_ ->
                    start "widget"
                        |> apply [ C.OpenMenu [] (C.AttrMenu "variant") ]
                        |> .openMenu
                        |> Expect.equal (Just ( [], C.AttrMenu "variant" ))
            , test "CloseMenu clears it" <|
                \_ ->
                    start "widget"
                        |> apply [ C.OpenMenu [] (C.AttrMenu "variant"), C.CloseMenu ]
                        |> .openMenu
                        |> Expect.equal Nothing
            , test "every structural message clears openMenu" <|
                \_ ->
                    let
                        cleared msg =
                            start "container"
                                |> apply [ C.OpenMenu [] (C.SlotMenu "unnamed"), msg ]
                                |> .openMenu
                    in
                    [ C.SetAttr [] "label" (C.AttrString "x")
                    , C.ClearAttr [] "label"
                    , C.AddChild [] "unnamed" "widget"
                    , C.AddTextChild [] "unnamed"
                    , C.AddIconChild [] "unnamed"
                    , C.SetChildContent [] "unnamed" 0 "x"
                    , C.RemoveChild [] "unnamed" 0
                    ]
                        |> List.map cleared
                        |> Expect.equal (List.repeat 7 Nothing)
            ]
        ]
```

- [ ] **Step 3: Run to verify it fails**

```bash
rm packages/elm-cem-compose/tests/src/SmokeTest.elm
pnpm --filter elm-cem-compose run test:elm
```

Expected: compile failure — `Cem.Compose` exposes only `version`.

- [ ] **Step 4: Implement the model**

Replace `packages/elm-cem-compose/src/Cem/Compose.elm` entirely:

```elm
module Cem.Compose exposing
    ( Model, init, Msg(..), update
    , Node, Child(..), AttrValue(..), AttrKind(..)
    , PathStep(..), Path, MenuKind(..)
    , nodeAt, factAt
    , componentOf, attrsOf, slotsOf
    )

{-| A headless, type-directed editor for building a valid tree of custom
elements from a machine-readable component manifest (`Cem.Facts`).

This module renders nothing and has no side effects. It owns the tree,
path-addressed edit logic, and pure query functions; the consumer writes
every pixel.

@docs Model, init, Msg, update
@docs Node, Child, AttrValue, AttrKind
@docs PathStep, Path, MenuKind
@docs nodeAt, factAt
@docs componentOf, attrsOf, slotsOf

-}

import Cem.Facts exposing (Fact)
import Dict exposing (Dict)
import List.Extra


{-| One configured attribute value.

Numeric values carry raw entry text, not `Float`/`Int`: a user mid-typing
`"1."` or `"-"` would have the character eaten on every keystroke if the model
stored a parsed number. Parsing happens at the point of use, and an
unparseable value simply contributes no attribute.

`AttrFloat` and `AttrInt` are distinct despite both holding `String` because
codegen must emit `String.fromFloat` vs `String.fromInt` shapes.

-}
type AttrValue
    = AttrBool Bool
    | AttrString String
    | AttrFloat String
    | AttrInt String
    | AttrEnum String


{-| The shape of a non-enum attribute. Enum-ness is not a member: whether an
attribute is an enum is answered by whether its name appears in `fact.enums`.
-}
type AttrKind
    = BoolAttr
    | StringAttr
    | FloatAttr
    | IntAttr


{-| One element in the tree. Opaque: the slot-cardinality invariant is
maintained by `update`, so no consumer may construct a two-element non-multi
slot.
-}
type Node
    = Node
        { component : String
        , attrs : Dict String AttrValue
        , children : Dict String (List Child)
        }


{-| What occupies one position in a slot.

The variant is decided at CHOICE time — a slot advertises every mode its
`kinds` permit and the user picks one. It is not a fixed per-slot property.

-}
type Child
    = ChildNode Node
    | ChildText String
    | ChildIcon String


{-| One descent: into a named slot, at an index. -}
type PathStep
    = IntoSlot String Int


{-| Read root-first. `[]` is the root node. -}
type alias Path =
    List PathStep


{-| Which chip's menu is live. -}
type MenuKind
    = AttrMenu String
    | SlotMenu String


{-| The whole editor state. `facts` is indexed by `Fact.component` because
every query does a lookup.
-}
type alias Model =
    { root : Node
    , facts : Dict String Fact
    , attrKinds : Dict String AttrKind
    , openMenu : Maybe ( Path, MenuKind )
    }


{-| `root` is the component name the empty tree starts at. If it is not among
`facts` the model is still constructed and every query on it returns empty.
-}
init :
    { facts : List Fact
    , attrKinds : Dict String AttrKind
    , root : String
    }
    -> Model
init config =
    { root = emptyNode config.root
    , facts =
        List.foldl (\f -> Dict.insert f.component f) Dict.empty config.facts
    , attrKinds = config.attrKinds
    , openMenu = Nothing
    }


emptyNode : String -> Node
emptyNode name =
    Node { component = name, attrs = Dict.empty, children = Dict.empty }



-- MESSAGES


{-| Every edit. No `Cmd`, no `Effect`: the core has no side effects. -}
type Msg
    = SetAttr Path String AttrValue
    | ClearAttr Path String
    | OpenMenu Path MenuKind
    | CloseMenu
    | AddChild Path String String
    | AddTextChild Path String
    | AddIconChild Path String
    | SetChildContent Path String Int String
    | RemoveChild Path String Int


{-| Every structural message applies `updateAt` and then clears `openMenu` —
selecting a value dismisses its menu.
-}
update : Msg -> Model -> Model
update msg model =
    case msg of
        OpenMenu path kind ->
            { model | openMenu = Just ( path, kind ) }

        CloseMenu ->
            { model | openMenu = Nothing }

        SetAttr path name value ->
            edit path (setAttr name value) model

        ClearAttr path name ->
            edit path (removeAttr name) model

        AddChild path slot component ->
            if Dict.member component model.facts then
                edit path (insertChild model slot (ChildNode (emptyNode component))) model

            else
                closeMenu model

        AddTextChild path slot ->
            edit path (insertChild model slot (ChildText "")) model

        AddIconChild path slot ->
            edit path (insertChild model slot (ChildIcon "star")) model

        SetChildContent path slot index text ->
            edit path (setChildContent slot index text) model

        RemoveChild path slot index ->
            edit path (removeChild slot index) model


{-| Apply a node transform at a path and dismiss any open menu. -}
edit : Path -> (Node -> Node) -> Model -> Model
edit path f model =
    { model | root = updateAt path f model.root, openMenu = Nothing }


closeMenu : Model -> Model
closeMenu model =
    { model | openMenu = Nothing }


setAttr : String -> AttrValue -> Node -> Node
setAttr name value (Node n) =
    Node { n | attrs = Dict.insert name value n.attrs }


removeAttr : String -> Node -> Node
removeAttr name (Node n) =
    Node { n | attrs = Dict.remove name n.attrs }


{-| Append on a multi slot; replace on every other slot. This cap is a model
invariant, not a convention — which is why `Node` is opaque.
-}
insertChild : Model -> String -> Child -> Node -> Node
insertChild model slot child ((Node n) as node) =
    let
        isMulti =
            Dict.get n.component model.facts
                |> Maybe.map (\f -> List.member slot f.multiSlots)
                |> Maybe.withDefault False

        existing =
            Dict.get slot n.children |> Maybe.withDefault []
    in
    Node
        { n
            | children =
                Dict.insert slot
                    (if isMulti then
                        existing ++ [ child ]

                     else
                        [ child ]
                    )
                    n.children
        }


setChildContent : String -> Int -> String -> Node -> Node
setChildContent slot index text ((Node n) as node) =
    case Dict.get slot n.children of
        Nothing ->
            node

        Just children ->
            case List.Extra.getAt index children of
                Just (ChildText _) ->
                    Node { n | children = Dict.insert slot (List.Extra.setAt index (ChildText text) children) n.children }

                Just (ChildIcon _) ->
                    Node { n | children = Dict.insert slot (List.Extra.setAt index (ChildIcon text) children) n.children }

                _ ->
                    node


removeChild : String -> Int -> Node -> Node
removeChild slot index ((Node n) as node) =
    case Dict.get slot n.children of
        Nothing ->
            node

        Just children ->
            if index < 0 || index >= List.length children then
                node

            else
                Node { n | children = Dict.insert slot (List.Extra.removeAt index children) n.children }


{-| The single recursive locator. Descends only through `ChildNode`; a step
landing on text/icon content, an out-of-range index, or an unknown slot is a
no-op returning the tree unchanged. Compose never crashes on a stale path.
-}
updateAt : Path -> (Node -> Node) -> Node -> Node
updateAt path f ((Node n) as node) =
    case path of
        [] ->
            f node

        (IntoSlot slot index) :: rest ->
            case Dict.get slot n.children of
                Nothing ->
                    node

                Just children ->
                    case List.Extra.getAt index children of
                        Just (ChildNode child) ->
                            Node
                                { n
                                    | children =
                                        Dict.insert slot
                                            (List.Extra.setAt index (ChildNode (updateAt rest f child)) children)
                                            n.children
                                }

                        _ ->
                            node



-- NAVIGATION


{-| `Nothing` for any path that does not resolve to a `ChildNode`. -}
nodeAt : Path -> Model -> Maybe Node
nodeAt path model =
    nodeAtHelp path model.root


nodeAtHelp : Path -> Node -> Maybe Node
nodeAtHelp path ((Node n) as node) =
    case path of
        [] ->
            Just node

        (IntoSlot slot index) :: rest ->
            Dict.get slot n.children
                |> Maybe.andThen (List.Extra.getAt index)
                |> Maybe.andThen
                    (\child ->
                        case child of
                            ChildNode inner ->
                                nodeAtHelp rest inner

                            _ ->
                                Nothing
                    )


{-| `nodeAt` then a `facts` lookup. `Nothing` if either step fails. -}
factAt : Path -> Model -> Maybe Fact
factAt path model =
    nodeAt path model
        |> Maybe.andThen (\node -> Dict.get (componentOf node) model.facts)



-- ACCESSORS


{-| The component noun this node was built from. -}
componentOf : Node -> String
componentOf (Node n) =
    n.component


{-| Sorted association list, so two equal trees produce byte-identical
generated code.
-}
attrsOf : Node -> List ( String, AttrValue )
attrsOf (Node n) =
    Dict.toList n.attrs


{-| Only slots that currently hold children, sorted. A fold that needs the
full declared slot set asks `slotChips`.
-}
slotsOf : Node -> List ( String, List Child )
slotsOf (Node n) =
    Dict.toList n.children |> List.filter (\( _, cs ) -> not (List.isEmpty cs))
```

- [ ] **Step 5: Run to verify it passes**

```bash
pnpm --filter elm-cem-compose run test:elm
```

Expected: all `StructureTest` cases PASS.

- [ ] **Step 6: Commit**

```bash
elm-format packages/elm-cem-compose/src/ packages/elm-cem-compose/tests/src/ --yes
git add packages/elm-cem-compose
git commit -m "Compose A2: Node/Child/Path data model, update, and addressing"
```

**Acceptance:** every test above passes; `Node`'s constructor is not in the `exposing` list; `update` returns no `Cmd`.

---

### Task 3: Slot affordances and slot chips — the §8.7 decision

**Files:**
- Modify: `packages/elm-cem-compose/src/Cem/Compose.elm`
- Create: `packages/elm-cem-compose/tests/src/SlotTest.elm`

**Interfaces:**
- Consumes: `Model`, `Path`, `nodeAt`, `factAt`, `slotsOf` from Task 2.
- Produces:
  - `type alias SlotAffordances = { text : Bool, icon : Bool, components : List String }`
  - `type alias SlotChipInfo = { name : String, required : Bool, affordances : SlotAffordances, filled : Int, max : Maybe Int }`
  - `slotChips : Path -> Model -> List SlotChipInfo`

**This is the heart of the spec amendment.** A slot is *not* pre-classified into one content mode. It advertises every mode its `kinds` permit. An implementation that ports `Builder.elm`'s winner-takes-all `slotContentKind` will fail the `mixed.any` test below — that test exists to catch exactly that regression.

- [ ] **Step 1: Write the failing tests**

Create `packages/elm-cem-compose/tests/src/SlotTest.elm`:

```elm
module SlotTest exposing (all)

import Cem.Compose as C
import Dict
import Expect
import FakeFacts
import Test exposing (Test, describe, test)


start : String -> C.Model
start root =
    C.init { facts = FakeFacts.all, attrKinds = Dict.empty, root = root }


chip : String -> String -> Maybe C.SlotChipInfo
chip root slot =
    C.slotChips [] (start root)
        |> List.filter (\c -> c.name == slot)
        |> List.head


affordances : String -> String -> Maybe C.SlotAffordances
affordances root slot =
    Maybe.map .affordances (chip root slot)


all : Test
all =
    describe "slot affordances"
        [ test "a slot naming BOTH text and a component offers BOTH" <|
            \_ ->
                affordances "mixed" "any"
                    |> Expect.equal
                        (Just { text = True, icon = True, components = [ "widget" ] })
        , test "shared:flow counts as text, and coexists with a component" <|
            \_ ->
                affordances "mixed" "flowy"
                    |> Expect.equal
                        (Just { text = True, icon = False, components = [ "widget" ] })
        , test "empty kinds means text-only, never every-component" <|
            \_ ->
                affordances "mixed" "unconstrained"
                    |> Expect.equal
                        (Just { text = True, icon = False, components = [] })
        , test "a text-only slot" <|
            \_ ->
                affordances "labelled" "headline"
                    |> Expect.equal
                        (Just { text = True, icon = False, components = [] })
        , test "an icon-only slot" <|
            \_ ->
                affordances "iconic" "lead"
                    |> Expect.equal
                        (Just { text = False, icon = True, components = [] })
        , test "a components-only slot affords no text" <|
            \_ ->
                affordances "container" "unnamed"
                    |> Expect.equal
                        (Just { text = False, icon = False, components = [ "widget", "container" ] })
        , test "a component absent from facts is silently omitted" <|
            \_ ->
                affordances "container" "unnamed"
                    |> Maybe.map (.components >> List.member "ghost")
                    |> Expect.equal (Just False)
        , test "required is read from requiredSlots" <|
            \_ ->
                Maybe.map .required (chip "labelled" "headline")
                    |> Expect.equal (Just True)
        , test "max is Nothing for a multi slot" <|
            \_ ->
                Maybe.map .max (chip "container" "unnamed")
                    |> Expect.equal (Just Nothing)
        , test "max is Just 1 for a non-multi slot" <|
            \_ ->
                Maybe.map .max (chip "single" "only")
                    |> Expect.equal (Just (Just 1))
        , test "filled counts current children" <|
            \_ ->
                start "container"
                    |> C.update (C.AddChild [] "unnamed" "widget")
                    |> C.slotChips []
                    |> List.filter (\c -> c.name == "unnamed")
                    |> List.map .filled
                    |> Expect.equal [ 1 ]
        , test "required slots come first, then the rest alphabetically" <|
            \_ ->
                C.slotChips [] (start "mixed")
                    |> List.map .name
                    |> Expect.equal [ "any", "flowy", "unconstrained" ]
        , test "the slot set is the union of requiredSlots, multiSlots and slotKinds keys" <|
            \_ ->
                C.slotChips [] (start "labelled")
                    |> List.map .name
                    |> Expect.equal [ "headline" ]
        , test "an unresolvable path yields no chips" <|
            \_ ->
                C.slotChips [ C.IntoSlot "nope" 0 ] (start "container")
                    |> Expect.equal []
        ]
```

- [ ] **Step 2: Run to verify it fails**

```bash
pnpm --filter elm-cem-compose run test:elm
```

Expected: compile failure — `SlotChipInfo`, `SlotAffordances`, `slotChips` do not exist.

- [ ] **Step 3: Implement**

Add to the `exposing` list of `Cem.Compose`: `SlotAffordances, SlotChipInfo, slotChips` (and the matching `@docs` line). Append to the module:

```elm
-- SLOTS


{-| Every content mode a slot permits — not the highest-precedence one.

The three are independent: a slot may afford all of them, exactly one, or
none. This replaces the winner-takes-all classification the prototype used,
under which a slot naming both text and components collapsed to text and the
components became unreachable.

-}
type alias SlotAffordances =
    { text : Bool
    , icon : Bool
    , components : List String
    }


{-| One slot chip. `max` is `Nothing` for a multi slot, `Just 1` otherwise —
the machine-readable form of the replace-not-append invariant.
-}
type alias SlotChipInfo =
    { name : String
    , required : Bool
    , affordances : SlotAffordances
    , filled : Int
    , max : Maybe Int
    }


{-| The kind tokens that mean "this slot takes text".

`"shared:flow"` and `"shared:phrasing"` are HTML content categories. The
prototype's rule did not name them at all, so they fell through to its
component branch — a latent bug, fixed here.

-}
textKinds : List String
textKinds =
    [ "html", "shared:text", "shared:link", "shared:flow", "shared:phrasing" ]


iconKind : String
iconKind =
    "shared:icon"


kindsFor : Fact -> String -> List String
kindsFor fact slot =
    fact.slotKinds
        |> List.filter (\( name, _ ) -> name == slot)
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault []


affordancesFor : Model -> Fact -> String -> SlotAffordances
affordancesFor model fact slot =
    let
        kinds =
            kindsFor fact slot
    in
    { text = List.isEmpty kinds || List.any (\k -> List.member k textKinds) kinds
    , icon = List.member iconKind kinds
    , components =
        kinds
            |> List.filter (\k -> not (String.contains ":" k))
            |> List.filter (\k -> Dict.member k model.facts)
            |> List.Extra.unique
    }


{-| The declared slot set: required slots first in `requiredSlots` order, then
the rest alphabetically, deduplicated.
-}
slotNames : Fact -> List String
slotNames fact =
    let
        required =
            List.Extra.unique fact.requiredSlots

        rest =
            (fact.multiSlots ++ List.map Tuple.first fact.slotKinds)
                |> List.filter (\s -> not (List.member s required))
                |> List.Extra.unique
                |> List.sort
    in
    required ++ rest


{-| One entry per slot the node's `Fact` declares. Empty for an unresolvable
path.
-}
slotChips : Path -> Model -> List SlotChipInfo
slotChips path model =
    case ( nodeAt path model, factAt path model ) of
        ( Just node, Just fact ) ->
            slotNames fact
                |> List.map
                    (\slot ->
                        { name = slot
                        , required = List.member slot fact.requiredSlots
                        , affordances = affordancesFor model fact slot
                        , filled = childrenIn slot node |> List.length
                        , max =
                            if List.member slot fact.multiSlots then
                                Nothing

                            else
                                Just 1
                        }
                    )

        _ ->
            []


childrenIn : String -> Node -> List Child
childrenIn slot (Node n) =
    Dict.get slot n.children |> Maybe.withDefault []
```

- [ ] **Step 4: Run to verify it passes**

```bash
pnpm --filter elm-cem-compose run test:elm
```

Expected: `SlotTest` all PASS, `StructureTest` still PASS.

- [ ] **Step 5: Commit**

```bash
elm-format packages/elm-cem-compose/src/ packages/elm-cem-compose/tests/src/ --yes
git add packages/elm-cem-compose
git commit -m "Compose A3: non-exclusive SlotAffordances and slotChips (spec 8.7)"
```

**Acceptance:** `mixed.any` reports `text = True` AND `components = [ "widget" ]` simultaneously. If it reports only one, the winner-takes-all rule has been reintroduced.

---

### Task 4: Slot menu options and Add-message agreement

**Files:**
- Modify: `packages/elm-cem-compose/src/Cem/Compose.elm`
- Modify: `packages/elm-cem-compose/tests/src/SlotTest.elm`

**Interfaces:**
- Consumes: `SlotAffordances`, `slotChips` from Task 3.
- Produces:
  - `type SlotOption = OptionText | OptionIcon | OptionComponent String`
  - `slotMenuOptions : Path -> String -> Model -> List SlotOption`
  - a tightened `update` in which `AddTextChild` / `AddIconChild` / `AddChild` are no-ops when the slot does not afford them.

**The invariant this task establishes:** every option `slotMenuOptions` returns produces a model change when its corresponding message is applied, and no message succeeds that the menu did not offer. Menu and update must agree in both directions.

- [ ] **Step 1: Write the failing tests**

Append to `packages/elm-cem-compose/tests/src/SlotTest.elm`'s `all` describe list — add these entries before the closing `]`:

```elm
        , describe "slot menu options"
            [ test "a mixed slot enumerates text, icon, then components in order" <|
                \_ ->
                    C.slotMenuOptions [] "any" (start "mixed")
                        |> Expect.equal
                            [ C.OptionText, C.OptionIcon, C.OptionComponent "widget" ]
            , test "ghost is omitted because it is absent from facts" <|
                \_ ->
                    C.slotMenuOptions [] "any" (start "mixed")
                        |> List.member (C.OptionComponent "ghost")
                        |> Expect.equal False
            , test "a components-only slot offers no text" <|
                \_ ->
                    C.slotMenuOptions [] "unnamed" (start "container")
                        |> Expect.equal
                            [ C.OptionComponent "widget", C.OptionComponent "container" ]
            , test "a text-only slot offers exactly OptionText" <|
                \_ ->
                    C.slotMenuOptions [] "headline" (start "labelled")
                        |> Expect.equal [ C.OptionText ]
            , test "an unknown slot offers nothing" <|
                \_ ->
                    C.slotMenuOptions [] "nope" (start "labelled")
                        |> Expect.equal []
            , test "the option order is stable across repeated calls" <|
                \_ ->
                    let
                        model =
                            start "mixed"
                    in
                    C.slotMenuOptions [] "any" model
                        |> Expect.equal (C.slotMenuOptions [] "any" model)
            ]
        , describe "menu and update agree"
            [ test "every offered option changes the model when applied" <|
                \_ ->
                    let
                        msgFor slot option =
                            case option of
                                C.OptionText ->
                                    C.AddTextChild [] slot

                                C.OptionIcon ->
                                    C.AddIconChild [] slot

                                C.OptionComponent name ->
                                    C.AddChild [] slot name

                        checkSlot root slot =
                            let
                                model =
                                    start root
                            in
                            C.slotMenuOptions [] slot model
                                |> List.map
                                    (\option ->
                                        C.update (msgFor slot option) model /= model
                                    )

                        results =
                            List.concat
                                [ checkSlot "mixed" "any"
                                , checkSlot "mixed" "flowy"
                                , checkSlot "mixed" "unconstrained"
                                , checkSlot "container" "unnamed"
                                , checkSlot "labelled" "headline"
                                , checkSlot "iconic" "lead"
                                , checkSlot "single" "only"
                                ]
                    in
                    results
                        |> Expect.equal (List.repeat (List.length results) True)
            , test "AddTextChild on a components-only slot is a no-op" <|
                \_ ->
                    let
                        model =
                            start "container"
                    in
                    C.update (C.AddTextChild [] "unnamed") model
                        |> .root
                        |> C.slotsOf
                        |> Expect.equal []
            , test "AddIconChild on a text-only slot is a no-op" <|
                \_ ->
                    let
                        model =
                            start "labelled"
                    in
                    C.update (C.AddIconChild [] "headline") model
                        |> .root
                        |> C.slotsOf
                        |> Expect.equal []
            , test "AddChild of a component the slot does not name is a no-op" <|
                \_ ->
                    start "container"
                        |> C.update (C.AddChild [] "unnamed" "labelled")
                        |> .root
                        |> C.slotsOf
                        |> Expect.equal []
            ]
```

Note the previous `StructureTest` case *"AddTextChild then AddTextChild on a non-multi slot replaces"* is implied by Task 2's replace test; if the executor wants it explicit, add it here against `labelled.headline`.

- [ ] **Step 2: Run to verify it fails**

Expected: compile failure — `SlotOption` and `slotMenuOptions` do not exist. The three no-op tests will also fail once it compiles, because Task 2's `update` does not consult affordances.

- [ ] **Step 3: Implement `SlotOption` and the query**

Add `SlotOption(..), slotMenuOptions` to the `exposing` list and `@docs`. Append:

```elm
{-| One way to fill a slot. Each maps to exactly one message:
`OptionText` → `AddTextChild`, `OptionIcon` → `AddIconChild`,
`OptionComponent n` → `AddChild … n`.
-}
type SlotOption
    = OptionText
    | OptionIcon
    | OptionComponent String


{-| The full menu for a slot: every valid way to fill it, in one list.

Order is fixed so the menu does not reshuffle between renders — text and icon
first (the cheap, terminal choices), then the component list (the branch into
recursion). Returns `[]` only when the slot affords nothing at all.

No option in this list is ever a no-op.

-}
slotMenuOptions : Path -> String -> Model -> List SlotOption
slotMenuOptions path slot model =
    affordancesAt path slot model
        |> Maybe.map optionsOf
        |> Maybe.withDefault []


affordancesAt : Path -> String -> Model -> Maybe SlotAffordances
affordancesAt path slot model =
    slotChips path model
        |> List.filter (\c -> c.name == slot)
        |> List.head
        |> Maybe.map .affordances


optionsOf : SlotAffordances -> List SlotOption
optionsOf a =
    List.concat
        [ if a.text then
            [ OptionText ]

          else
            []
        , if a.icon then
            [ OptionIcon ]

          else
            []
        , List.map OptionComponent a.components
        ]
```

- [ ] **Step 4: Tighten `update` so the messages agree with the menu**

Replace the three `Add*` branches in `update`:

```elm
        AddChild path slot component ->
            addIfAfforded path slot (\a -> List.member component a.components) (ChildNode (emptyNode component)) model

        AddTextChild path slot ->
            addIfAfforded path slot .text (ChildText "") model

        AddIconChild path slot ->
            addIfAfforded path slot .icon (ChildIcon "star") model
```

and add:

```elm
{-| Insert a child only if the slot's affordances permit that kind. This is the
other half of "no menu ever offers an option that produces no effect": what the
menu does not offer, the core does not do.
-}
addIfAfforded : Path -> String -> (SlotAffordances -> Bool) -> Child -> Model -> Model
addIfAfforded path slot permitted child model =
    case affordancesAt path slot model of
        Just affordances ->
            if permitted affordances then
                edit path (insertChild model slot child) model

            else
                closeMenu model

        Nothing ->
            closeMenu model
```

The old `Dict.member component model.facts` guard is now redundant — `affordancesFor` already filters `components` to names present in `facts`, so a component absent from facts can never appear in `a.components`. Task 2's "AddChild with a component absent from facts is a no-op" test still passes, now for a stronger reason.

- [ ] **Step 5: Run to verify it passes**

```bash
pnpm --filter elm-cem-compose run test:elm
```

Expected: all three test modules PASS.

- [ ] **Step 6: Commit**

```bash
elm-format packages/elm-cem-compose/src/ packages/elm-cem-compose/tests/src/ --yes
git add packages/elm-cem-compose
git commit -m "Compose A4: slotMenuOptions enumerates every valid kind; update agrees"
```

**Acceptance:** the "every offered option changes the model" test passes for all seven fixture slots, and all three no-op tests pass.

---

### Task 5: Attribute chips

**Files:**
- Modify: `packages/elm-cem-compose/src/Cem/Compose.elm`
- Create: `packages/elm-cem-compose/tests/src/AttrTest.elm`

**Interfaces:**
- Produces:
  - `type AttrChipKind = EnumChip (List String) | PlainChip AttrKind`
  - `type alias AttrChipInfo = { name : String, kind : AttrChipKind, isSet : Bool, currentValue : Maybe AttrValue }`
  - `attrChips : Path -> Model -> List AttrChipInfo`

- [ ] **Step 1: Write the failing tests**

Create `packages/elm-cem-compose/tests/src/AttrTest.elm`:

```elm
module AttrTest exposing (all)

import Cem.Compose as C
import Dict
import Expect
import FakeFacts
import Test exposing (Test, describe, test)


kinds : Dict.Dict String C.AttrKind
kinds =
    Dict.fromList
        [ ( "disabled", C.BoolAttr )
        , ( "label", C.StringAttr )
        , ( "count", C.IntAttr )
        , ( "ratio", C.FloatAttr )
        ]


start : C.Model
start =
    C.init { facts = FakeFacts.all, attrKinds = kinds, root = "widget" }


names : C.Model -> List String
names model =
    C.attrChips [] model |> List.map .name


all : Test
all =
    describe "attribute chips"
        [ test "enum chips come first, then plain chips deduplicated and sorted" <|
            \_ ->
                names start
                    |> Expect.equal [ "variant", "count", "disabled", "label", "ratio" ]
        , test "an attrRewrites name absent from attrKinds produces no chip" <|
            \_ ->
                names start
                    |> List.member "onClick"
                    |> Expect.equal False
        , test "a name in both enums and attrRewrites produces exactly one chip" <|
            \_ ->
                names start
                    |> List.filter (\n -> n == "variant")
                    |> List.length
                    |> Expect.equal 1
        , test "the variant chip carries its tokens" <|
            \_ ->
                C.attrChips [] start
                    |> List.filter (\c -> c.name == "variant")
                    |> List.map .kind
                    |> Expect.equal [ C.EnumChip [ "filled", "outlined" ] ]
        , test "a plain chip carries its kind" <|
            \_ ->
                C.attrChips [] start
                    |> List.filter (\c -> c.name == "count")
                    |> List.map .kind
                    |> Expect.equal [ C.PlainChip C.IntAttr ]
        , test "isSet is False before any SetAttr" <|
            \_ ->
                C.attrChips [] start
                    |> List.filter (\c -> c.name == "variant")
                    |> List.map .isSet
                    |> Expect.equal [ False ]
        , test "isSet is True after SetAttr, and carries the value" <|
            \_ ->
                start
                    |> C.update (C.SetAttr [] "variant" (C.AttrEnum "filled"))
                    |> C.attrChips []
                    |> List.filter (\c -> c.name == "variant")
                    |> List.map (\c -> ( c.isSet, c.currentValue ))
                    |> Expect.equal [ ( True, Just (C.AttrEnum "filled") ) ]
        , test "ClearAttr returns isSet to False" <|
            \_ ->
                start
                    |> C.update (C.SetAttr [] "variant" (C.AttrEnum "filled"))
                    |> C.update (C.ClearAttr [] "variant")
                    |> C.attrChips []
                    |> List.filter (\c -> c.name == "variant")
                    |> List.map .isSet
                    |> Expect.equal [ False ]
        , test "an unresolvable path yields no chips" <|
            \_ ->
                C.attrChips [ C.IntoSlot "nope" 0 ] start
                    |> Expect.equal []
        ]
```

The first test is the load-bearing one: `"variant"` (enum, from `fact.enums` order) precedes the plain chips, which are alphabetical, and the duplicated `"label"` in the fixture appears once.

- [ ] **Step 2: Run to verify it fails**

Expected: compile failure — `AttrChipInfo`, `AttrChipKind`, `attrChips` do not exist.

- [ ] **Step 3: Implement**

Add `AttrChipInfo, AttrChipKind(..), attrChips` to `exposing` and `@docs`. Append:

```elm
-- ATTRIBUTES


{-| Whether a chip is an enum (and its legal tokens) or a plain typed value.

`kind` is carried on the chip because the consumer cannot render one without
it — an enum chip's label shows the current token, a boolean chip is a toggle,
a string chip opens a text field.

-}
type AttrChipKind
    = EnumChip (List String)
    | PlainChip AttrKind


{-| One configurable attribute. `isSet` is `True` exactly when the attribute
has an entry in the node's `attrs`. An unset attribute contributes nothing to
the preview and nothing to the generated code.
-}
type alias AttrChipInfo =
    { name : String
    , kind : AttrChipKind
    , isSet : Bool
    , currentValue : Maybe AttrValue
    }


{-| Enum chips in the `Fact`'s own order, then plain chips deduplicated and
sorted. `attrRewrites` maps barrel setter name to per-component setter name and
the same per-component name can be reached from more than one barrel entry, so
deduplication is required, not cosmetic.

A name absent from both `fact.enums` and `Model.attrKinds` is not offered at
all — which is how event setters are excluded.

-}
attrChips : Path -> Model -> List AttrChipInfo
attrChips path model =
    case ( nodeAt path model, factAt path model ) of
        ( Just node, Just fact ) ->
            let
                current name =
                    currentAttr name node

                enumNames =
                    List.map Tuple.first fact.enums

                enumChips =
                    fact.enums
                        |> List.map
                            (\( name, tokens ) ->
                                { name = name
                                , kind = EnumChip tokens
                                , isSet = current name /= Nothing
                                , currentValue = current name
                                }
                            )

                plainChips =
                    fact.attrRewrites
                        |> List.map Tuple.second
                        |> List.filter (\name -> not (List.member name enumNames))
                        |> List.Extra.unique
                        |> List.sort
                        |> List.filterMap
                            (\name ->
                                Dict.get name model.attrKinds
                                    |> Maybe.map
                                        (\kind ->
                                            { name = name
                                            , kind = PlainChip kind
                                            , isSet = current name /= Nothing
                                            , currentValue = current name
                                            }
                                        )
                            )
            in
            enumChips ++ plainChips

        _ ->
            []


currentAttr : String -> Node -> Maybe AttrValue
currentAttr name (Node n) =
    Dict.get name n.attrs
```

- [ ] **Step 4: Run to verify it passes, then commit**

```bash
pnpm --filter elm-cem-compose run test:elm
elm-format packages/elm-cem-compose/src/ packages/elm-cem-compose/tests/src/ --yes
git add packages/elm-cem-compose
git commit -m "Compose A5: attrChips with a genuine unset state"
```

**Acceptance:** all four test modules pass. `isSet` is `False` on a fresh model for every chip — the deliberate divergence from the prototype, which always emitted every enum's first token.

---

### Task 6: Attribute menus

**Files:**
- Modify: `packages/elm-cem-compose/src/Cem/Compose.elm`
- Modify: `packages/elm-cem-compose/tests/src/AttrTest.elm`

**Interfaces:**
- Produces:
  - `type NumberKind = FloatNumber | IntNumber`
  - `type MenuOptions = EnumTokens (List String) (Maybe String) | BoolToggle Bool | TextInput String | NumberInput NumberKind String`
  - `attrMenuOptions : Path -> String -> Model -> Maybe MenuOptions`

- [ ] **Step 1: Write the failing tests**

Append to `AttrTest.elm`'s `all` list, before the closing `]`:

```elm
        , describe "attribute menus"
            [ test "an unset enum offers its tokens with no current selection" <|
                \_ ->
                    C.attrMenuOptions [] "variant" start
                        |> Expect.equal
                            (Just (C.EnumTokens [ "filled", "outlined" ] Nothing))
            , test "a set enum reports the current token" <|
                \_ ->
                    start
                        |> C.update (C.SetAttr [] "variant" (C.AttrEnum "filled"))
                        |> C.attrMenuOptions [] "variant"
                        |> Expect.equal
                            (Just (C.EnumTokens [ "filled", "outlined" ] (Just "filled")))
            , test "an unset boolean defaults to False" <|
                \_ ->
                    C.attrMenuOptions [] "disabled" start
                        |> Expect.equal (Just (C.BoolToggle False))
            , test "an unset string defaults to empty" <|
                \_ ->
                    C.attrMenuOptions [] "label" start
                        |> Expect.equal (Just (C.TextInput ""))
            , test "numbers carry raw entry text, so a half-typed value survives" <|
                \_ ->
                    start
                        |> C.update (C.SetAttr [] "ratio" (C.AttrFloat "1."))
                        |> C.attrMenuOptions [] "ratio"
                        |> Expect.equal (Just (C.NumberInput C.FloatNumber "1."))
            , test "an int attribute reports IntNumber" <|
                \_ ->
                    C.attrMenuOptions [] "count" start
                        |> Expect.equal (Just (C.NumberInput C.IntNumber ""))
            , test "an attribute this node does not offer is Nothing" <|
                \_ ->
                    C.attrMenuOptions [] "nope" start
                        |> Expect.equal Nothing
            , test "an unresolvable path is Nothing" <|
                \_ ->
                    C.attrMenuOptions [ C.IntoSlot "nope" 0 ] "variant" start
                        |> Expect.equal Nothing
            ]
```

- [ ] **Step 2: Run to verify it fails.** Expected: compile failure.

- [ ] **Step 3: Implement**

Add `NumberKind(..), MenuOptions(..), attrMenuOptions` to `exposing` and `@docs`. Append:

```elm
{-| Which numeric shape codegen and dispatch must use. -}
type NumberKind
    = FloatNumber
    | IntNumber


{-| What to draw for an open attribute menu. The consumer decides whether a
boolean is a switch, a checkbox, or two menu items; the core only says it is
boolean-shaped and what it currently is.
-}
type MenuOptions
    = EnumTokens (List String) (Maybe String)
    | BoolToggle Bool
    | TextInput String
    | NumberInput NumberKind String


{-| `Nothing` if the path does not resolve, or if the attribute is not one this
node offers.
-}
attrMenuOptions : Path -> String -> Model -> Maybe MenuOptions
attrMenuOptions path name model =
    attrChips path model
        |> List.filter (\c -> c.name == name)
        |> List.head
        |> Maybe.map menuOptionsFor


menuOptionsFor : AttrChipInfo -> MenuOptions
menuOptionsFor chip =
    case chip.kind of
        EnumChip tokens ->
            EnumTokens tokens
                (case chip.currentValue of
                    Just (AttrEnum token) ->
                        Just token

                    _ ->
                        Nothing
                )

        PlainChip BoolAttr ->
            BoolToggle
                (case chip.currentValue of
                    Just (AttrBool b) ->
                        b

                    _ ->
                        False
                )

        PlainChip StringAttr ->
            TextInput (rawText chip.currentValue)

        PlainChip FloatAttr ->
            NumberInput FloatNumber (rawText chip.currentValue)

        PlainChip IntAttr ->
            NumberInput IntNumber (rawText chip.currentValue)


rawText : Maybe AttrValue -> String
rawText value =
    case value of
        Just (AttrString s) ->
            s

        Just (AttrFloat s) ->
            s

        Just (AttrInt s) ->
            s

        Just (AttrEnum s) ->
            s

        Just (AttrBool _) ->
            ""

        Nothing ->
            ""
```

- [ ] **Step 4: Run, format, commit**

```bash
pnpm --filter elm-cem-compose run test:elm
elm-format packages/elm-cem-compose/src/ packages/elm-cem-compose/tests/src/ --yes
git add packages/elm-cem-compose
git commit -m "Compose A6: attrMenuOptions"
```

**Acceptance:** all attribute-menu tests pass; `AttrFloat "1."` round-trips unchanged.

---

### Task 7: Determinism, the headless gate, and Phase A sign-off

**Files:**
- Create: `packages/elm-cem-compose/bin/check-headless.sh` (replace the Task 1 placeholder)
- Modify: `packages/elm-cem-compose/tests/src/StructureTest.elm`
- Modify: `packages/elm-cem-compose/README.md`

- [ ] **Step 1: Write the determinism test**

Append to `StructureTest.elm`'s `all` list:

```elm
        , describe "determinism"
            [ test "the same Msg list applied to two inits yields equal models" <|
                \_ ->
                    let
                        msgs =
                            [ C.AddChild [] "unnamed" "widget"
                            , C.AddChild [] "unnamed" "container"
                            , C.SetAttr [ C.IntoSlot "unnamed" 0 ] "label" (C.AttrString "a")
                            , C.SetAttr [ C.IntoSlot "unnamed" 0 ] "disabled" (C.AttrBool True)
                            , C.AddChild [ C.IntoSlot "unnamed" 1 ] "unnamed" "widget"
                            ]
                    in
                    apply msgs (start "container")
                        |> Expect.equal (apply msgs (start "container"))
            , test "attrsOf ordering is stable regardless of insertion order" <|
                \_ ->
                    let
                        forward =
                            start "widget"
                                |> apply
                                    [ C.SetAttr [] "label" (C.AttrString "a")
                                    , C.SetAttr [] "count" (C.AttrInt "1")
                                    ]

                        backward =
                            start "widget"
                                |> apply
                                    [ C.SetAttr [] "count" (C.AttrInt "1")
                                    , C.SetAttr [] "label" (C.AttrString "a")
                                    ]
                    in
                    C.attrsOf forward.root
                        |> Expect.equal (C.attrsOf backward.root)
            , test "unbounded depth: a self-recursive component nests with no cap" <|
                \_ ->
                    let
                        path n =
                            List.repeat n (C.IntoSlot "unnamed" 0)

                        nest n model =
                            if n <= 0 then
                                model

                            else
                                nest (n - 1) (C.update (C.AddChild (path (10 - n)) "unnamed" "container") model)
                    in
                    nest 10 (start "container")
                        |> C.nodeAt (path 10)
                        |> Maybe.map C.componentOf
                        |> Expect.equal (Just "container")
            ]
```

The last case is the core-side acceptance test for spec §8.3: no depth cap, no recursion guard. It relies on `container.unnamed` naming `"container"` itself, which the Task 2 fixture already does — no fixture change is needed here.

- [ ] **Step 2: Write the headless gate**

Replace `packages/elm-cem-compose/bin/check-headless.sh`:

```bash
#!/usr/bin/env bash
# The mechanical form of "headless": this package must not know what a view is,
# and must not know which brand it is editing. Both are one-line greps, and both
# are load-bearing claims in the spec (§10, §15) rather than conventions.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0

if grep -riq "m3e" "$here/src"; then
  echo "check-headless: FAIL — 'm3e' appears in src/; the core must be brand-agnostic:"
  grep -rin "m3e" "$here/src"
  fail=1
fi

for forbidden in '"elm/html"' '"elm/virtual-dom"' '"jackhp95/elm-m3e"'; do
  if grep -q "$forbidden" "$here/elm.json"; then
    echo "check-headless: FAIL — elm.json declares $forbidden; the core renders nothing."
    fail=1
  fi
done

allowed='elm/core|elm-community/list-extra|jackhp95/elm-cem-facts'
if grep -oE '"[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+"' "$here/elm.json" \
  | grep -vE "\"($allowed)\"" \
  | grep -q .; then
  echo "check-headless: FAIL — elm.json names a dependency outside the registry-faithful set:"
  grep -oE '"[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+"' "$here/elm.json" | grep -vE "\"($allowed)\""
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "check-headless: OK — no view, no brand, three dependencies."
```

Note: the third check greps `"author/package"` shaped strings, which in this file appear only as the package name and its dependencies. `jackhp95/elm-cem-compose` is the package's own name, so add it to `allowed` if the check trips on it — verify by running, do not guess.

```bash
chmod +x packages/elm-cem-compose/bin/check-headless.sh
```

- [ ] **Step 3: Run the full package gate**

```bash
pnpm --filter elm-cem-compose run gate
```

Expected: format validates, `elm make --docs=/dev/null` succeeds, `check-headless` prints OK, all four test modules pass.

- [ ] **Step 4: Run the workspace gate**

```bash
pnpm gate:all
```

Expected: green, with `elm-cem-compose: check` and `elm-cem-compose: test` appearing in the item list. If the new package does not appear, `pnpm install` was not re-run after adding `package.json`.

- [ ] **Step 5: Finish the README and commit**

The README must state: what the package is, the three dependencies and why there is no fourth, that `Node` is opaque and why, and that the consumer supplies `attrKinds` because Elm has no reflection (spec §4.1, §5.3).

```bash
elm-format packages/elm-cem-compose/src/ packages/elm-cem-compose/tests/src/ --yes
git add packages/elm-cem-compose
git commit -m "Compose A7: determinism tests, headless gate, README — Phase A complete"
```

**Phase A acceptance, all four required (spec §15):**
1. `elm-test` (via `elm-test-rs`) is green across `StructureTest`, `SlotTest`, `AttrTest`.
2. The package compiles standalone (`elm make --docs=/dev/null` after facts staging).
3. `elm.json` contains no `elm/html`, no `jackhp95/elm-m3e`, and nothing outside the registry-faithful set.
4. `grep -ri "m3e" packages/elm-cem-compose/src` returns nothing.

Plus: `pnpm gate:all` is green and enumerates the new package.

---

# Phase B — The elm-m3e docs consumer

**Do not start until Phase A is green and Task 0's boundary question has a recorded answer.**

### Task 8: Put `Cem.Facts` and `Cem.Compose` on the docs app's source path

**Files:**
- Modify: `packages/elm-m3e/docs/elm.json`

This is spec §14 risk 5 and it is deliberately first, so it fails fast if the new source directories interact badly with the vendored `vendor/elm-foundation` tree.

- [ ] **Step 1: Prove the current failure**

Create a scratch file `packages/elm-m3e/docs/app/ScratchFacts.elm`:

```elm
module ScratchFacts exposing (count)

import M3e.Review.Facts


count : Int
count =
    List.length M3e.Review.Facts.facts
```

```bash
cd packages/elm-m3e/docs && npx elm make app/ScratchFacts.elm --output=/dev/null
```

Expected: **FAIL** — `M3e.Review.Facts` imports `Cem.Facts`, which is not on the source path.

- [ ] **Step 2: Add the two source directories**

Edit `packages/elm-m3e/docs/elm.json`, `source-directories` only:

```json
    "source-directories": [
        "app",
        "src",
        ".elm-pages",
        "../src",
        "../../elm-cem/facts/src",
        "../../elm-cem-compose/src",
        "vendor/elm-foundation"
    ],
```

`../../elm-cem/facts/src` is the **canonical** `Cem.Facts`, deliberately not `../editor/stub` — the stub is an LSP convenience copy and pointing a compiled route at it would create a second `Cem.Facts` that can drift. Spec §9.6.

- [ ] **Step 3: Verify it now compiles**

```bash
cd packages/elm-m3e/docs && npx elm make app/ScratchFacts.elm --output=/dev/null
```

Expected: PASS. Then verify the whole app still builds:

```bash
pnpm --filter m3e-builder-docs run check
```

- [ ] **Step 4: Delete the scratch file and commit**

```bash
rm packages/elm-m3e/docs/app/ScratchFacts.elm
git add packages/elm-m3e/docs/elm.json
git commit -m "Compose B8: put canonical Cem.Facts and Cem.Compose on the docs source path"
```

**Acceptance:** a module importing `M3e.Review.Facts` and `Cem.Compose` compiles inside the docs app; `pnpm --filter m3e-builder-docs run check` is green. **If `elm-cem-compose` is now compiled through `source-directories`, `elm.json`'s registry dependency on `jackhp95/elm-cem-facts` is not consulted here — the docs app resolves both from source. That is expected and is why the docs app needs no ELM_HOME staging.**

---

### Task 9: Generate the attribute kind and dispatch table

**Files:**
- Create: `packages/elm-m3e/docs/scripts/gen-compose-attrs.mjs`
- Create (generated): `packages/elm-m3e/docs/app/Route/Components/Compose/Attrs.elm`
- Modify: `packages/elm-m3e/docs/package.json` (two scripts)

**Interfaces:**
- Produces, consumed by Tasks 11–13:
  - `kinds : Dict String Cem.Compose.AttrKind`
  - `toAttribute : ( String, Cem.Compose.AttrValue ) -> List (Html.Attribute msg)`
  - `witness : List ()` — see step 3
  - `codeLineFor : String -> Cem.Compose.AttrValue -> Maybe String`

This is the adapter, and it is the single largest piece of per-library work (spec §14 risk 1). **It is derived by script and the output is committed; never hand-edit `Attrs.elm`.** Spec §9.5 says the POC should derive it by script rather than by hand, and spec §11.1 notes an upstream commit regenerates `M3e.Attributes` with 204 portmanteau enum attributes — a hand-written table would go stale.

- [ ] **Step 1: Write the generator**

Create `packages/elm-m3e/docs/scripts/gen-compose-attrs.mjs`. It reads two inputs and writes one output:

- Input A: `packages/elm-m3e/src/M3e/Attributes.elm` — parse top-level type annotations with a regex over lines matching `^([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*(.+)$` followed by a definition line. Classify the **first argument type**: `Bool ->` → `BoolAttr`, `String ->` → `StringAttr`, `Float ->` → `FloatAttr`, `Int ->` → `IntAttr`. Anything else (a phantom `Value`, an `Attribute msg`, a message handler) → **unclassifiable, emit nothing** — which is how `onClick` and friends are excluded (spec non-goal 6).
- Input B: `packages/elm-m3e/src/M3e/Review/Facts.elm` — the set of names actually reachable, i.e. `facts |> concatMap (.attrRewrites >> map Tuple.second)`. Emit only names in the intersection of A and B, so the table has no dead rows.

Output: `app/Route/Components/Compose/Attrs.elm`, with a header comment `{- GENERATED by scripts/gen-compose-attrs.mjs — do not edit. -}`, and:

```elm
kinds : Dict String Cem.Compose.AttrKind
kinds =
    Dict.fromList
        [ ( "disabled", Cem.Compose.BoolAttr )
        , ( "href", Cem.Compose.StringAttr )
        -- … one row per classified name …
        ]
```

- [ ] **Step 2: Emit the runtime dispatch**

In the same generated module, emit `toAttribute`. The preview renders through `Html.node` because which component is being rendered is only known at runtime, so the attribute side is plain `Html.Attributes.attribute` with the value stringified per kind. The `Maybe.andThen` over the parse is what makes a half-typed number contribute nothing (spec §5.1, §9.3):

```elm
toAttribute : ( String, Cem.Compose.AttrValue ) -> List (Html.Attribute msg)
toAttribute ( name, value ) =
    case value of
        Cem.Compose.AttrBool True ->
            [ Html.Attributes.attribute name "" ]

        Cem.Compose.AttrBool False ->
            []

        Cem.Compose.AttrString s ->
            [ Html.Attributes.attribute name s ]

        Cem.Compose.AttrEnum token ->
            [ Html.Attributes.attribute name (kebab token) ]

        Cem.Compose.AttrFloat raw ->
            String.toFloat raw
                |> Maybe.map (\f -> [ Html.Attributes.attribute name (String.fromFloat f) ])
                |> Maybe.withDefault []

        Cem.Compose.AttrInt raw ->
            String.toInt raw
                |> Maybe.map (\i -> [ Html.Attributes.attribute name (String.fromInt i) ])
                |> Maybe.withDefault []
```

- [ ] **Step 3: Emit the compile-time witness**

**Resolved ambiguity, recorded here so the executor does not rediscover it.** Spec §4.1 says the adapter table's value is that it "names real `M3e.Attributes` functions so a renamed setter is a compile error in that table." But spec §9.3 has the preview render through `Html.node` with plain `Html.Attribute`s — which never touches a typed setter, so nothing would break at compile time on a rename. Both cannot be true of the same code.

Resolution: keep §9.3's plain-`Html` preview (it is the only thing that can render a runtime-chosen tag) and preserve the §4.1 property with an explicit witness — a generated value that references every real setter and every real enum token, so a rename or a removed token is still a compile error in the generated table:

```elm
{-| Compile-time only. Every entry references a real `M3e.Attributes` setter
and a real `M3e.Values` token, so a renamed setter or a retired token is a
compile error HERE rather than a silent no-op at runtime. Never called.
-}
witness : List ()
witness =
    [ always () (M3e.Attributes.disabled True)
    , always () (M3e.Attributes.variant M3e.Values.filled)
    -- … one row per (setter) and per (attribute, token) enum pair …
    ]
```

Also emit `codeLineFor : String -> Cem.Compose.AttrValue -> Maybe String`, returning the snippet text for one attribute (e.g. `Just "M3e.Attributes.variant M3e.Values.filled"`), `Nothing` for an unparseable number. Task 13 consumes it.

- [ ] **Step 4: Wire the scripts**

Add to `packages/elm-m3e/docs/package.json` `scripts`:

```json
    "gen:compose-attrs": "node scripts/gen-compose-attrs.mjs",
    "check:compose-attrs": "node scripts/gen-compose-attrs.mjs --check",
```

`--check` regenerates to a temp file and byte-compares against the committed one, exiting 1 on drift. `check:compose-attrs` is picked up by the existing `check` aggregation. This is the workspace's standard "generated code is the specification" gate.

- [ ] **Step 5: Generate, compile, verify the counts**

```bash
cd packages/elm-m3e/docs && npm run gen:compose-attrs && npx elm make app/Route/Components/Compose/Attrs.elm --output=/dev/null
```

Expected: compiles. Then sanity-check against the spec's measured baseline — spec §4.1 records **182 non-enum setter names and 201 distinct (attribute, token) enum pairs** across the components. The generated `kinds` row count should be within a few of 182, and `witness` should carry ~201 enum rows. **A wildly different number means the regex mis-parsed `M3e/Attributes.elm`** — investigate before proceeding; do not accept a table that silently dropped half the setters.

- [ ] **Step 6: Commit**

```bash
git add packages/elm-m3e/docs/scripts/gen-compose-attrs.mjs \
        packages/elm-m3e/docs/app/Route/Components/Compose/Attrs.elm \
        packages/elm-m3e/docs/package.json
git commit -m "Compose B9: derive the attr kind + dispatch table by script"
```

**Acceptance:** `Attrs.elm` compiles; `npm run check:compose-attrs` passes on a clean tree and fails if `Attrs.elm` is hand-edited; the row count is in the expected range.

---

### Task 10: Fold 2 — `renderNode`, the live preview

**Files:**
- Create: `packages/elm-m3e/docs/app/Route/Components/Compose/Render.elm`
- Modify: `packages/elm-m3e/review/src/CodegenReviewConfig.elm`

Written before the editor view because it is the smallest fold, has no interaction, and its `tagFor` is needed by nothing else — so a mistake here is cheap to find.

**Interfaces:**
- Consumes: `Cem.Compose.{Node, Child(..), componentOf, attrsOf, slotsOf}`, `Attrs.toAttribute`.
- Produces: `renderNode : Cem.Compose.Node -> Html msg`, `tagFor : String -> String`.

- [ ] **Step 1: Write `tagFor`**

```elm
{-| `"appBar"` → `"m3e-app-bar"`. Kebab-casing the fact's component noun is
verified to match `M3e.Html`'s own tag literals for all components, and is
deliberately NOT re-derived from `@m3e/web`'s `custom-elements.json`, which has
at least one known-bad `tagName` (`StepperNextElement` lists
`"m3e-stepper-previous"`).
-}
tagFor : String -> String
tagFor component =
    "m3e-" ++ toKebabCase component


toKebabCase : String -> String
toKebabCase input =
    input
        |> String.toList
        |> List.concatMap
            (\c ->
                if Char.isUpper c then
                    [ '-', Char.toLower c ]

                else
                    [ c ]
            )
        |> String.fromList
```

- [ ] **Step 2: Write the recursive render**

```elm
renderNode : Cem.Compose.Node -> Html msg
renderNode node =
    Html.node (tagFor (Cem.Compose.componentOf node))
        (List.concatMap Attrs.toAttribute (Cem.Compose.attrsOf node))
        (List.concatMap renderSlot (Cem.Compose.slotsOf node))


renderSlot : ( String, List Cem.Compose.Child ) -> List (Html msg)
renderSlot ( slotName, children ) =
    List.map
        (\child ->
            case child of
                Cem.Compose.ChildText text ->
                    Html.span (placement slotName) [ Html.text text ]

                Cem.Compose.ChildIcon glyph ->
                    Html.node "m3e-icon" (placement slotName) [ Html.text glyph ]

                Cem.Compose.ChildNode inner ->
                    withSlot slotName (renderNode inner)
        )
        children


{-| The facts' name for the default slot is `"unnamed"`, and the default slot
takes no `slot=` attribute. Both folds must special-case it.
-}
placement : String -> List (Html.Attribute msg)
placement slotName =
    if slotName == "unnamed" then
        []

    else
        [ Html.Attributes.attribute "slot" slotName ]
```

`withSlot` re-wraps a rendered node with its `slot=` attribute. Because `renderNode` already produced the element, the simplest correct implementation re-renders with the placement attribute prepended rather than trying to patch an `Html` value (which Elm cannot inspect):

```elm
withSlot : String -> Cem.Compose.Node -> Html msg
withSlot slotName node =
    Html.node (tagFor (Cem.Compose.componentOf node))
        (placement slotName ++ List.concatMap Attrs.toAttribute (Cem.Compose.attrsOf node))
        (List.concatMap renderSlot (Cem.Compose.slotsOf node))
```

Restructure `renderSlot` to call `withSlot slotName inner` directly for the `ChildNode` case and drop the outer `renderNode` call there, so nothing renders twice.

- [ ] **Step 3: Add the review allow-list entry**

The preview crosses into the typed world once, via `M3e.Unsafe.fromHtml`, because which component is being rendered is only known at runtime so no typed constructor can produce it. Edit `packages/elm-m3e/review/src/CodegenReviewConfig.elm`, the `NoUnsafeImportOutsideAllowed.rule` list (currently lines 69-77), adding one entry **with a comment explaining why**, matching the existing style of the `"Route.Examples.Shop"` precedent:

```elm
      --   `Route.Components.Compose` — the Compose preview renders a
      --     runtime-chosen custom element, so no typed constructor can produce
      --     it; one documented `fromHtml` at the render boundary.
      NoUnsafeImportOutsideAllowed.rule
        [ "M3e"
        , "TypedHtml"
        , "Doc"
        , "Shared"
        , "View"
        , "Route.Examples.Shop"
        , "Route.Guide"
        , "Route.Components.Compose"
        ]
```

If the `fromHtml` call ends up in `Route.Components.Compose.Render` rather than the route module, use that module's name instead — match the module where the import actually lives.

- [ ] **Step 4: Compile, review, commit**

```bash
cd packages/elm-m3e/docs && npx elm make app/Route/Components/Compose/Render.elm --output=/dev/null && npm run check:review
```

```bash
elm-format packages/elm-m3e/docs/app/Route/Components/Compose/ --yes
git add packages/elm-m3e/docs/app/Route/Components/Compose/Render.elm packages/elm-m3e/review/src/CodegenReviewConfig.elm
git commit -m "Compose B10: renderNode preview fold + one documented review allow-list entry"
```

**Acceptance:** compiles; `check:review` green with exactly one new allow-list entry.

---

### Task 11: The route skeleton and nav registration

**Files:**
- Create: `packages/elm-m3e/docs/app/Route/Components/Compose.elm`
- Modify: `packages/elm-m3e/docs/app/Shared.elm:1391-1409`

**Template to follow: `packages/elm-m3e/docs/app/Route/Examples/Feed.elm`** — the cleanest of the app's `buildWithLocalState` routes: self-owned state, no `BackendTask` data, no deep-linking. Read its first 100 lines before writing.

**Interfaces:**
- Produces: a live route at `/components/compose` rendering one card for the root node with no chips yet.

- [ ] **Step 1: Write the route skeleton**

```elm
module Route.Components.Compose exposing (ActionData, Data, Model, Msg, route)

import BackendTask
import Cem.Compose
import Dict
import Effect exposing (Effect)
import Head
import M3e
import M3e.Review.Facts
import PagesMsg exposing (PagesMsg)
import Route.Components.Compose.Attrs as Attrs
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import UrlPath exposing (UrlPath)
import View exposing (View)


type alias Model =
    { compose : Cem.Compose.Model }


type Msg
    = ComposeMsg Cem.Compose.Msg


type alias RouteParams =
    {}


type alias Data =
    {}


type alias ActionData =
    {}


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.single { head = head, data = BackendTask.succeed {} }
        |> RouteBuilder.buildWithLocalState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init _ _ =
    ( { compose =
            Cem.Compose.init
                { facts = M3e.Review.Facts.facts
                , attrKinds = Attrs.kinds
                , root = "list"
                }
      }
    , Effect.none
    )


update : App Data ActionData RouteParams -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update _ _ (ComposeMsg composeMsg) model =
    ( { model | compose = Cem.Compose.update composeMsg model.compose }, Effect.none )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions _ _ _ _ =
    Sub.none


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    []
```

`update` is a one-liner because the core returns no effects. Compose needs no `BackendTask` at all — unlike `Components/All.elm` and `Components/Name_.elm`, which load `docs/data/reference.json` via `Doc.Data`, its data source is `M3e.Review.Facts.facts`, a compiled-in Elm value.

Root component `"list"` is a deliberate starting choice: `list.unnamed` is a pure-nesting slot with five component options and no text, so the recursive case is visible immediately.

- [ ] **Step 2: Write a placeholder `view`**

```elm
view : App Data ActionData RouteParams -> Shared.Model -> Model -> View (PagesMsg Msg)
view _ _ model =
    View.fromElement "Compose"
        (M3e.mapMsg PagesMsg.fromMsg
            (M3e.mapMsg ComposeMsg (Doc.pane [ screen model.compose ]))
        )
```

`view` follows the app's convention of erasing the phantom rows once, at the boundary. For this task `screen` renders only the root component's name; the chips arrive in Task 12. **Check `View.fromElement` and `Doc.pane`'s actual signatures in the app before writing** — the spec's sketch is from research, not from a compile.

- [ ] **Step 3: Register the nav link**

**This is deviation 2 — the spec's instruction here is wrong.** `navSections` has no `components` entry; the components drawer is derived from `reference.json` in `currentSectionItems`. Edit `packages/elm-m3e/docs/app/Shared.elm`, the `Just "components"` branch (currently lines 1394-1399):

```elm
        Just "components" ->
            ( "/components/all", "All components" )
                :: ( "/components/compose", "Compose" )
                :: (components
                        |> List.sortBy (\c -> String.toLower c.label)
                        |> List.map (\c -> ( "/components/" ++ c.slug, c.label ))
                   )
```

`check-nav.mjs` does **not** validate this branch — it only checks that every `reference.json`-derived slug resolves to a page. So this link is not machine-gated; the Playwright spec in Task 14 is what covers it.

- [ ] **Step 4: Build and view**

```bash
cd packages/elm-m3e/docs && npm run start
```

Open `http://localhost:1234/components/compose` (check the dev port in `docs/package.json`). Expected: the page renders, the drawer shows a "Compose" link under Components, and the link navigates.

- [ ] **Step 5: Commit**

```bash
elm-format packages/elm-m3e/docs/app/Route/Components/Compose.elm packages/elm-m3e/docs/app/Shared.elm --yes
git add packages/elm-m3e/docs/app/Route/Components/Compose.elm packages/elm-m3e/docs/app/Shared.elm
git commit -m "Compose B11: route skeleton at /components/compose + drawer link"
```

**Acceptance:** the route loads in the dev server; the drawer link appears and navigates; `pnpm --filter m3e-builder-docs run check` is green.

---

### Task 12: Fold 1 — `viewNode`, the editor

**Files:**
- Modify: `packages/elm-m3e/docs/app/Route/Components/Compose.elm`

**Interfaces:**
- Consumes: `attrChips`, `slotChips`, `attrMenuOptions`, `slotMenuOptions`, `componentOf`, `slotsOf`, and the `Msg` constructors.
- Produces: the interactive card tree.

- [ ] **Step 1: Write the recursive card**

One `m3e-card` per `Node`. Header names the component. Body is an `m3e-chip-set` built from `attrChips path model ++ slotChips path model`, then a menu when `model.openMenu` matches this path, then a recursive call per `ChildNode` in `slotsOf node`.

```elm
viewNode path node model =
    M3e.card [ M3e.Attributes.variant Value.outlined ]
        [ M3e.Component.Card.header
            (Doc.sectionLabel (Cem.Compose.componentOf node))
        , M3e.Component.Card.content
            (TypedHtml.div [ TA.class "flex flex-col gap-3" ]
                [ M3e.chipSet []
                    (List.map (attrChipView path) (Cem.Compose.attrChips path model)
                        ++ List.map (slotChipView path) (Cem.Compose.slotChips path model)
                    )
                , menuFor path model
                , TypedHtml.div [ TA.class "pl-4 flex flex-col gap-3" ]
                    (childCards path node model)
                ]
            )
        ]


attrChipView path info =
    M3e.filterChip
        [ M3e.Attributes.selected info.isSet
        , M3e.Events.onClick (Cem.Compose.OpenMenu path (Cem.Compose.AttrMenu info.name))
        ]
        [ M3e.text (chipLabel info) ]
```

`filterChip` + `onClick` is exactly the pattern already in `docs/app/Route/Examples/Feed.elm:223`, so this is not a new interaction shape for the app.

- [ ] **Step 2: Write the slot chip and its menu**

The slot chip label uses `filled` and `max`: `"2"` when `max = Nothing`, `"1 / 1"` when `max = Just 1`. `required` may be styled but nothing blocks or complains (spec non-goal 5).

**The slot menu is the whole point of the §8.7 amendment.** It renders one item per `SlotOption`, and must not collapse:

```elm
slotMenuView path slotName model =
    M3e.menu []
        (Cem.Compose.slotMenuOptions path slotName model
            |> List.map
                (\option ->
                    case option of
                        Cem.Compose.OptionText ->
                            menuItem "Text" (Cem.Compose.AddTextChild path slotName)

                        Cem.Compose.OptionIcon ->
                            menuItem "Icon" (Cem.Compose.AddIconChild path slotName)

                        Cem.Compose.OptionComponent name ->
                            menuItem name (Cem.Compose.AddChild path slotName name)
                )
        )
```

**Permitted consumer shortcut:** when `slotMenuOptions` returns exactly one option, the chip may fire that option's message directly instead of opening a one-item menu (spec §7.2 step 2). This is a consumer convenience over a uniform core answer — do not push it into the core.

- [ ] **Step 3: Recurse, and render text/icon children inline**

`childCards` maps over `slotsOf node`; for each `ChildNode` at index `i` in slot `s` it calls `viewNode (path ++ [ Cem.Compose.IntoSlot s i ])`. For each `ChildText`/`ChildIcon` it renders an inline text field wired to `SetChildContent path s i`. Every child gets a remove control firing `RemoveChild path s i`.

- [ ] **Step 4: Check the chip re-click hazard**

Spec §14 risk 6, believed not to apply but **unverified — check it in a browser now, it is cheap here and expensive to discover late.** `m3e-filter-chip`'s click handler toggles its own `selected` unconditionally and `M3e.Attributes.selected` cannot resync a value the element changed itself. Compose's chips are buttons that open menus rather than independently toggleable state, and every click produces a model change (`OpenMenu` always changes `openMenu`), so the re-click race that bit the prototype should not arise. Click the same chip three times in a row and confirm the menu opens each time and the chip's filled state matches `isSet`, not the click count. If it misbehaves, switch to `M3e.assistChip` or a plain button and record why.

- [ ] **Step 5: Format, compile, commit**

```bash
elm-format packages/elm-m3e/docs/app/Route/Components/Compose.elm --yes
cd packages/elm-m3e/docs && npm run check
git add packages/elm-m3e/docs/app/Route/Components/Compose.elm
git commit -m "Compose B12: viewNode editor fold — chips, menus, recursion"
```

**Acceptance, in a browser:** starting from `list`, clicking the `unnamed` slot chip opens a five-item menu; picking `listItem` adds a nested card with its own chips; clicking the nested `listItem`'s `trailing` chip opens a menu containing **text, icon, avatar, checkbox, heading, radio, and switch** — the §8.7 acceptance check. Picking `checkbox` adds a checkbox card.

---

### Task 13: Fold 3 — codegen

**Files:**
- Create: `packages/elm-m3e/docs/app/Route/Components/Compose/Codegen.elm`
- Modify: `packages/elm-m3e/docs/app/Route/Components/Compose.elm` (render the snippet pane)

**Interfaces:**
- Consumes: `componentOf`, `attrsOf`, `slotsOf`, `Child(..)`, `Attrs.codeLineFor`.
- Produces: `codeFor : Cem.Compose.Node -> String`.

- [ ] **Step 1: Write the fold**

Generalises the prototype's `codeSnippet` / `attrCodeLine` / `slotCodeLine` by recursing into children rather than emitting a `{- default X instance -}` placeholder comment. Indentation is a function of depth. Emits against the `Html` facet (spec §8.6):

```elm
codeFor : Cem.Compose.Node -> String
codeFor node =
    render 0 node


render : Int -> Cem.Compose.Node -> String
render depth node =
    let
        pad n =
            String.repeat (4 * n) " "

        attrLines =
            Cem.Compose.attrsOf node
                |> List.filterMap (\( name, value ) -> Attrs.codeLineFor name value)
                |> List.map (\line -> pad (depth + 2) ++ line)

        childLines =
            Cem.Compose.slotsOf node
                |> List.concatMap (childCode (depth + 2))
    in
    String.join "\n"
        (List.concat
            [ [ pad depth ++ "M3e.Html." ++ Cem.Compose.componentOf node ]
            , bracketed (depth + 1) attrLines
            , bracketed (depth + 1) childLines
            ]
        )
```

`bracketed` emits `[]` on one line when the list is empty and a multi-line Elm list otherwise.

- [ ] **Step 2: Handle the default slot**

`slot=` is omitted for the slot named `"unnamed"`, which is the facts' name for the default slot. Both the render fold and this one must special-case it — the prototype does so in `slotPlacementAttrs` and `slotCodeLine` independently. A named slot's child emits its slot attribute; `ChildText` emits `M3e.text "…"`; `ChildIcon` emits the icon constructor with the glyph name.

- [ ] **Step 3: Verify the worked example from the spec**

Build `list > listItem > text "Inbox"` in the browser and confirm the snippet pane reads exactly:

```elm
M3e.Html.list
    [ ]
    [ M3e.Html.listItem
        [ ]
        [ M3e.text "Inbox" ]
    ]
```

- [ ] **Step 4: Verify the snippet actually compiles**

Paste the generated snippet into a scratch module in the docs app and run `elm make` on it. **This is spec §15's "the live preview and the snippet agree" criterion and it must be checked by compiling, not by reading.** Do this for at least: the three-level `list > listItem > checkbox` tree, and one tree with a set enum attribute and a set boolean attribute.

- [ ] **Step 5: Format, compile, commit**

```bash
elm-format packages/elm-m3e/docs/app/Route/Components/Compose/Codegen.elm --yes
cd packages/elm-m3e/docs && npm run check
git add packages/elm-m3e/docs/app/Route/Components/Compose/
git commit -m "Compose B13: recursive codegen fold"
```

**Acceptance:** the snippet for the worked example matches byte-for-byte; a pasted snippet compiles; `attrsOf`/`slotsOf` sorting means two identical trees produce identical text.

---

### Task 14: Browser integration coverage and Phase B sign-off

**Files:**
- Create: `packages/elm-m3e/docs/tests-browser/compose.spec.ts`

Style template: `packages/elm-m3e/docs/tests-browser/nav.spec.ts` — a doc comment stating what invariant the file defends, then role-based locators. **Note `test:browser` runs a full `elm-pages build` first (`playwright.config.ts` `webServer.command`), so expect minutes, not seconds.**

- [ ] **Step 1: Write the spec**

Four tests, each mapping to a spec §15 criterion:

```ts
import { test, expect } from "@playwright/test";

/**
 * Compose is a type-directed tree editor: what a slot's menu offers is derived
 * from that slot's `kinds` in `M3e.Review.Facts`, not hand-written. These tests
 * defend the wiring, not the logic — the logic is covered by elm-test in
 * packages/elm-cem-compose/tests.
 *
 * The `trailing` test is the one that matters most: it is the acceptance check
 * for the decision that a slot offers EVERY valid content kind rather than the
 * highest-precedence one. Under the superseded rule `listItem.trailing`
 * collapsed to a text box and the checkbox was unreachable.
 */
test("a slot menu offers every valid kind, not just text", async ({ page }) => {
  await page.goto("/components/compose");
  // build list > listItem, then open the listItem's trailing slot menu
  // assert the menu contains Text, Icon, avatar, checkbox, heading, radio, switch
});

test("setting an attribute updates both the live element and the snippet", async ({ page }) => {
  // click an enum chip, pick a token, assert the rendered m3e-* element carries
  // the attribute AND the snippet pane text contains the setter call
});

test("nesting three levels deep works with chips alone", async ({ page }) => {
  // menu > menuItemGroup > menuItem
});

test("the drawer links to Compose", async ({ page }) => {
  await page.goto("/components/button");
  const drawer = page.locator(".primary-nav-drawer");
  await expect(drawer.getByRole("link", { name: "Compose", exact: true })).toBeVisible();
});
```

Fill in each body against the real DOM — snapshot the page in the dev server first and use role-based locators, matching the house style. Do not write CSS-structure-dependent selectors beyond the `.primary-nav-drawer` precedent.

- [ ] **Step 2: Run**

```bash
cd packages/elm-m3e/docs && npx playwright test tests-browser/compose.spec.ts
```

- [ ] **Step 3: Run the full workspace gate**

```bash
pnpm gate:all
```

Expected: green. Watch specifically for `copy-fidelity-elm-m3e.sh`, which fails if a git-tracked file under `packages/elm-m3e/` goes missing or an untracked one is committed — the new route files must be committed, not left untracked.

- [ ] **Step 4: Commit**

```bash
git add packages/elm-m3e/docs/tests-browser/compose.spec.ts
git commit -m "Compose B14: browser coverage — Phase B complete"
```

**Phase B acceptance — all demonstrable in a browser (spec §15):**

- Starting from an empty root, a tree **at least three levels deep** is buildable with chips and menus alone. 66 of 130 components have a nestable slot and the longest simple chain is 5, so most reasonable starting points work; `menu > menuItemGroup > menuItem` is the scripted demo.
- **The §8.7 decision is visible:** `listItem.trailing` offers text, an icon, **and** `checkbox`, and picking `checkbox` puts a real `m3e-checkbox` in the rendered list item. `button`'s default slot offers text alongside its 15 component nouns.
- **Unbounded depth:** `navMenuItem` accepts `navMenuItem` (as do `heading` and `treeItem`), so `navMenu > navMenuItem > navMenuItem > …` works to arbitrary depth with no cap, no guard, no degradation.
- Every attribute chip corresponds to a real setter, and setting it changes the live element's appearance.
- The preview and the snippet agree — a pasted snippet compiles and renders the same tree.
- No menu ever offers an option that produces no effect.
- The route passes `review/` with at most the one documented `M3e.Unsafe.fromHtml` allow-list entry.

---

## Self-review — spec coverage

| Spec section | Covered by |
|---|---|
| §4 headless split, §10 package layout | Task 1 |
| §4.1 consumer owns attr dispatch, §5.3 injected kind table | Task 9 |
| §5.1 `AttrValue`, §5.2 `AttrKind`, §5.4 `Node`, §5.5 `Child`, §5.6 addressing, §5.7 `Model`/`MenuKind`, §5.8 `Msg` | Task 2 |
| §6.1 init/update, §6.2 navigation, §6.6 accessors | Task 2 |
| §6.3 attr chips | Task 5 |
| §6.4 attr menus | Task 6 |
| §6.5 slot affordances + chips | Task 3 |
| §6.5 `slotMenuOptions` / `SlotOption` | Task 4 |
| §7 interaction cycle, §7.1–7.3 traces | Tasks 12, 13 (traces are the browser acceptance checks) |
| §8.1 arbitrary depth, §8.3 no auto-fill / no guard | Task 7 determinism test, Task 14 browser check |
| §8.7 the amendment | Tasks 3, 4 (core), 12, 14 (visible) |
| §9.1 route location, §9.5 wiring | Task 11 |
| §9.2 fold 1 | Task 12 |
| §9.3 fold 2 | Task 10 |
| §9.4 fold 3 | Task 13 |
| §9.6 build wiring | Task 8 (item 1), Task 11 (item 3, corrected), item 2 needs no change |
| §11 / §11.1 boundary questions | Task 0 (escalated, not resolved) |
| §13 testing strategy | Tasks 2–7 |
| §14 risk 1 (derive by script) | Task 9 |
| §14 risk 2 (silent omission) | Accepted; the `"ghost"` fixture case pins the behaviour (Tasks 3, 4). The `unknownSlotKinds` diagnostic is explicitly not in the POC. |
| §14 risk 3 | Resolved by §8.7; Tasks 3, 4, 12, 14 |
| §14 risk 4 | Task 0 |
| §14 risk 5 | Task 8, deliberately first in Phase B |
| §14 risk 6 (chip re-click) | Task 12 step 4 |
| §14 risk 7 (chip-set scale) | Accepted for the POC; no task. `attrChips` already reports `isSet`, the partition key a "+N more" affordance would use. |
| §15 success criteria | Task 7 (Phase A), Task 14 (Phase B) |
| Non-goals 1–9 | No tasks, by construction. Nothing in this plan adds reordering, persistence, a second adapter, undo, validation reporting, event handlers, facts editing, or a facet switcher. |
