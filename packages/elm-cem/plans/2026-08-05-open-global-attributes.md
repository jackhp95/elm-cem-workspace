# Open (unconstrained-row) global attributes — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** An `_globals` entry may declare `"row": "open"`, which emits an unconstrained-row setter (`Attr c msg`) instead of the closed `Attr { c | <name> : Supported } msg`, and excludes the name from every element's closed `Attrs` alias. Exercised in `elm-typed-html` for `dir`/`lang`/`tabindex`/`hidden`/`title`, which unblocks `elm-m3e`'s `M3e.theme`-host hoist with zero m3e source changes.

**Architecture:** `globalDecoder` grows an optional `"row"` key and returns `( Bool, AttrSpec )`. The single kernelBlocked choke point (`Model.elm:1285`) partitions instead of only filtering, and `Brand` gains `openGlobals` beside `globals`. `plainSetterDecl`/`enumSetterDecl` take a leading `rowOpen : Bool` that swaps the row string. Every other global-consumer reads BOTH lists — see the invariant below, which is the load-bearing correction to the design doc.

**Tech Stack:** Elm (elm-codegen host; `codegen/` is compiled Elm), Node golden+acid harness (`tests/phantom/gate.mjs`), `elm-test-rs`.

**Spec:** `specs/2026-08-05-open-global-attributes-design.md`

## The invariant (correction to the spec's Blast radius)

The spec says `attrsFields` and its call sites need zero edits. True — but it then understates elm-cem's blast radius as "the decoder, `Brand`, and two decl-builders". An open global is **still a global** for namespace, union-minting, exposure and facts purposes; it stops being one *only* for row closure. So:

> **Exactly two consumers read `brand.globals` alone — the two row-closure sites.
> Every other consumer reads `brand.globals ++ brand.openGlobals`.**

The two row-closure sites (unchanged, by design):

| Site | Why open globals must NOT appear |
|---|---|
| `Emit.elm:1293` `attrsFields` | It *is* the closed `Attrs` row. An open global in it would defeat the whole change. |
| `Emit.elm:3112` `attrPipes` | A `with<Field>` pipe consumes a capability field that an open global has no row membership for. |

The consumers the spec omits, each of which silently breaks or regresses if it keeps reading `globals` alone:

| Site | Failure if missed |
|---|---|
| `Model.elm:1803` `globalEnums` | No `Values.Dir` union is minted → generated `Attributes.elm` annotates against a type that does not exist. |
| `Model.elm:1855` `tokenValuePairs` | The one-token-one-string conflict check and `Brand.tokenValues` lose the open enum's pairs. |
| `Model.elm:1630` K2 collapse | Spec's own guard: an open global colliding with a component's CEM attr of the same name must still be caught. |
| `Emit.elm:1463` `isGlobalName` | `enumAttrs` filters on it, so an open ENUM global's setter is emitted **twice** in one module. |
| `Emit.elm:1476` `hasEnumGlobal` | `HtmlIr.Value` / `<Lib>.Values` imports vanish → emitted module does not compile. |
| `Emit.elm:3678` `globalNames` | Feeds `exposeBlock`/`docsBlock`. Setter is declared but never exposed → private to its own module, unusable downstream, and `check:whatwg` gate 1d fails. |
| `Emit.elm:444` `globalPairs` | `guardAttributesModule` stops seeing the name, so a genuine top-level collision goes unreported. |
| `Emit.elm:5056` `globalAttributes` | `Review.Facts` would **lose** 5 entries in elm-typed-html — a regression, not a no-op. |

Plus one wiring step that is not a *read* at all and produces **no error of any kind** when missed:

| Site | Failure if missed |
|---|---|
| `Emit.elm:3991` module-body `List.concat` | The new decl list must be spliced into the concat that becomes the file text. Left only in a `let`, the declarations are computed and thrown away — no codegen error, no Elm error, just a mysteriously absent function downstream. |

## Global Constraints

- `"row"` absent ⇒ `"closed"`. Every existing config in `cem-configs/` and `elm-typed-html/config/config.json` must regenerate **byte-identical**. The `mini`/`native`/`hostile`/`barren` goldens are that regression proof and must not change.
- `kernelBlocked` filters BEFORE the partition, so a blocked name (`is`) is dropped whatever its `row`.
- Only `elm-typed-html`'s config gains `"row": "open"`, and only for `dir`/`lang`/`tabindex`/`hidden`/`title`. Not `class`/`id`/`slot`/`style`, not `popover`/`contenteditable`/`is`/the text-editing hints (spec Non-goals).
- `defaultGlobals` stays `List Attr.AttrSpec` and stays closed — the bare four are adapted at the decoder call site, not rewritten.
- Do not touch the uncommitted `elm-m3e/docs/app/Shared.elm` diff. It is the acceptance test.
- Three repos ⇒ three separate commits.

---

### Task 1: Fixture first — a suite that pins open-row output

**Files:**
- Create: `tests/phantom/fixtures/openrow.cem.json`, `tests/phantom/fixtures/openrow-config.json`
- Create: `tests/phantom/acid/openrow/{elm.json,src/Good.elm,bad/*.elm}`
- Modify: `tests/phantom/suites.mjs` (new suite entry, `filterPrefix: "Or"`, own `expected/` dir)

**Interfaces:**
- Produces: an `Or` brand with one open bool global, one open enum global, and one closed global of matching shape (a closed enum + a closed bool), so "byte-identical closed output" is asserted in the same emitted file as the open output.

- [ ] **Step 1: Write the fixture CEM + config**

Config `_globals`: `{"name":"oflag","type":"bool","row":"open"}`, `{"name":"odir","type":["ltr","rtl","auto"],"row":"open"}`, `{"name":"cflag","type":"bool"}`, `{"name":"cdir","type":["ltr","rtl","auto"]}`, plus bare `"class"`. The closed pair matches the open pair's shape exactly, which is what makes the comparison meaningful.

- [ ] **Step 2: Write the acid probes**

`src/Good.elm` — the open setter composes onto an element whose `Attrs` row never declares it. `bad/` — the closed setter is still gated (a `cdir` on an element that does not admit it must fail), which proves the change did not open everything.

- [ ] **Step 3: Run the gate; confirm it fails**

Run: `node tests/phantom/gate.mjs --suite=openrow`
Expected: FAIL — the generator either rejects `"row"` as an unknown key or emits `odir : … -> Attr { c | odir : Supported } msg`.

---

### Task 2: `Model.elm` — decoder, `Brand`, partition

**Files:** Modify `codegen/Generate/Phantom/Model.elm`

- [ ] **Step 1:** `globalDecoder : D.Decoder ( Bool, Attr.AttrSpec )`; decode optional `"row"` (`"open"` ⇒ `True`, `"closed"` ⇒ `False`, anything else ⇒ `D.fail` naming both legal values). Bare-string form ⇒ `( False, … )`.
- [ ] **Step 2:** `RawConfig.globals : List ( Bool, Attr.AttrSpec )`; decoder call site (`:1220`) adapts `defaultGlobals` with `List.map (Tuple.pair False)`.
- [ ] **Step 3:** `Brand` gains `openGlobals : List Attr.AttrSpec`.
- [ ] **Step 4:** The choke point partitions; `globalBlockedNotes` and `kernelBlockedRoster` map `Tuple.second` off `raw.globals` first.
- [ ] **Step 5:** K2 (`:1630`), `globalEnums` (`:1803`), `tokenValuePairs` (`:1855`) read the concatenation. `Brand` construction sets both sorted lists.

**Verify:** `node tests/phantom/gate.mjs` — every pre-existing suite still green (the byte-identical proof).

---

### Task 3: `Emit.elm` — `rowOpen` parameter, the seven reads, and the splice

**Files:** Modify `codegen/Generate/Phantom/Emit.elm`

- [ ] **Step 1:** Add `allGlobals : Brand -> List Attr.AttrSpec` (= `globals ++ openGlobals`) and route the seven omitted consumers through it. Leave `attrsFields` and `attrPipes` reading `brand.globals`.
- [ ] **Step 2:** `plainSetterDecl`/`enumSetterDecl` take a leading `rowOpen : Bool`; `"c"` when open, else today's string. Thread `False` at all four existing call sites (`:3752`, `:3755`, `plainSetter` `:3778`, `enumSetter` `:3886`).
- [ ] **Step 3:** Add `openGlobalDecls`, walking `brand.openGlobals` through the same two functions with `True`.
- [ ] **Step 4:** **Splice `openGlobalDecls` into the module-body `List.concat` (`:3991`).** Missing this is silent — see the invariant table.
- [ ] **Step 5:** Fold the open names into `globalNames` so they reach `exposeBlock`/`docsBlock`.

**Verify:** `node tests/phantom/gate.mjs` — all suites green, including `openrow`. Bless `openrow`'s goldens only after reading the diff.

---

### Task 4: `elm-typed-html` — config flip + regen

- [ ] **Step 1:** Add `"row": "open"` to `dir`/`lang`/`tabindex`/`hidden`/`title` in `config/config.json`.
- [ ] **Step 2:** `npm run gen`.
- [ ] **Step 3: Grep the emitted file directly — do not rely on "it compiled".**

```bash
grep -n "^dir :\|^lang :\|^tabindex :\|^hidden :\|^title :" src/TypedHtml/Attributes.elm   # each must end `-> Attr c msg`
sed -n '1,20p' src/TypedHtml/Attributes.elm                                                # each must be in exposing (...)
grep -rn "dir : Supported" src/                                                            # must be EMPTY
```

- [ ] **Step 4:** `npm run check:whatwg`, `npm run check:drift`, `npm run gate`.

---

### Task 5: `elm-m3e` — dependency bump only, then the acceptance test

- [ ] **Step 1:** Bump the `elm-typed-html` dependency. No `gen:src`, no other source edit.
- [ ] **Step 2:** Confirm the pre-existing uncommitted `docs/app/Shared.elm` diff compiles **unmodified**.
- [ ] **Step 3:** `npm run gate` in the docs app.
- [ ] **Step 4:** Confirm `git diff --stat` shows no change to any `src/M3e/**` file.

---

### Task 6: Cross-brand zero-diff proof + commits

- [ ] **Step 1:** Regenerate every brand reachable locally (elm-m3e, elm-calcite, elm-shoelace, elm-fluent-ui, elm-web-awesome) and confirm zero `src/` diff outside elm-typed-html.
- [ ] **Step 2:** `npm run gate` in elm-cem.
- [ ] **Step 3:** Three commits — elm-cem, elm-typed-html, elm-m3e.
- [ ] **Step 4:** Append `## OUTCOME` to this plan.

---

## Self-Review

**Spec coverage.** Optional `"row"` key → Task 2 Step 1. `Brand.openGlobals` → Task 2 Step 3. Partition after filter → Task 2 Step 4. `rowOpen` on both decl-builders + four `False` call sites → Task 3 Step 2. New open block → Task 3 Step 3. K2 guard over open globals → Task 2 Step 5. `attrsFields` zero-edit, asserted not assumed → Task 1's fixture `Attrs` alias. New fixture with one open bool / one open enum / matching closed → Task 1. Regression proof → the four pre-existing suites' goldens, gated at Task 2 Step 5 and Task 3. elm-typed-html flip + gates → Task 4. elm-m3e bump + `Shared.elm` acceptance → Task 5. Cross-brand zero diff → Task 6.

**Where this plan departs from the spec.** The spec's elm-cem blast radius is understated by seven reads plus one splice; the invariant section above is the correction, and Task 3 Step 1 implements it as a single named helper rather than eight ad-hoc concatenations, so the next reader can see which two sites are deliberately excluded and why. The spec's claim that `attrsFields`' seven call sites need zero edits is correct and is preserved.

**Open risk to surface at execution.** `hidden` is an enum (`["hidden","until-found"]`), not a bool, so flipping it exercises the open-enum path in a real brand — meaning `TypedHtml.Values.Hidden` must survive the `globalEnums` change. If `Values.elm` loses any union after Task 4, `globalEnums` was missed. Task 4 Step 3's third grep is the tripwire.

---

## OUTCOME

Executed 2026-08-05. All acceptance criteria met. Three commits, one per repo.

### What landed

- **elm-cem** — `globalDecoder : D.Decoder ( Bool, Attr.AttrSpec )` reading an
  optional `"row"`; `RawConfig.globals` becomes a pair list; `Brand.openGlobals`
  beside `globals`; the kernelBlocked choke point partitions after filtering;
  `plainSetterDecl`/`enumSetterDecl` take a leading `rowOpen`; `openGlobalDecls`
  spliced into the `<Lib>.Attributes` body concat. New `Emit.allGlobals` routes
  the eight non-row-closure consumers. New `openrow` phantom suite.
- **elm-typed-html** — five `_globals` entries flipped; `src/` regenerated
  (18 files, +78/−602 — every `Attrs` alias loses five fields).
- **elm-m3e** — vendored `TypedHtml.*` refreshed (`gen:vendor`). Zero changes
  under `src/M3e/**`.

### Verification performed

| Claim | Evidence |
|---|---|
| Open entries emit `Attr c msg`, closed unchanged | `openrow` golden: `odir`/`oflag` open, `cdir`/`cflag` closed in one file |
| Open entries absent from every closed row | `Or/Plain.elm` `Attrs`+`AttrCaps` carry only `cdir`/`cflag`/`class` |
| Open entries get no builder pipe | `bad/OpenGlobalHasNoPipe.elm` — **compiled before** the change, rejected after |
| Closed row still gates | `bad/ClosedGlobalIsNotOpen.elm` rejected throughout |
| `"closed"` default is non-breaking | mini/native/hostile/barren goldens byte-identical (`git status` clean); elm-typed-html regenerated pre-config-edit with zero diff |
| Setters exposed, not just declared | all five in `TypedHtml.Attributes`' `exposing (…)` header |
| Declarations reach the file | all five present in the body with `-> Attr c msg` |
| No duplicate declarations | exactly one `dir`/`hidden` decl — `isGlobalName` fix |
| Enum unions survive | `TypedHtml.Values.Dir` + `.Hidden` still minted |
| No other brand's output changes | **A/B generation**: pristine-HEAD vs modified elm-cem over the same config, byte-identical for elm-calcite, elm-shoelace, elm-fluent-ui, elm-web-awesome, elm-m3e |
| The blocked hoist is unblocked | `docs/app/Shared.elm` compiles **unmodified** (32 modules) |
| elm-typed-html gates | `check:format` `check:review` `check:validate` `check:acid` `check:whatwg` `check:drift` all green |
| elm-cem gates | phantom gate ALL GREEN (8 suites); 14 `test:*` + `check:format` + neutrality green |

### Corrections to the spec, found during execution

The spec's Blast radius named the decoder, `Brand`, and the two decl-builders.
Eight further sites needed the both-lists reading; each fails quietly, not loudly:

1. `Model.globalEnums` — else no `Values.<Row>` is minted for an open enum and
   the emitted module annotates against a nonexistent type.
2. `Model.tokenValuePairs` — else the one-token-one-string check loses coverage.
3. `Model` K2 collapse — the spec's own guard, made explicit.
4. `Emit.isGlobalName` — **live, not latent.** `globalEnums` is itself what puts
   every enum global into `brand.unions`, so `dir`/`hidden` survive the
   `enumAttrs` filter and get a SECOND declaration. Fixed at the source function,
   covering all three call sites.
5. `Emit.hasEnumGlobal` — else the `Values` / `HtmlIr.Value` imports vanish.
6. `Emit.globalNames` — else declared but never exposed.
7. `Emit.globalPairs` — else the collision registry loses the name.
8. `Emit.globalAttributes` — else `Review.Facts` silently *loses* five entries.

Plus the module-body `List.concat` splice, which is not a read at all and emits
no error from any tool when missed.

### Deliberately not done

- `class`/`id`/`slot`/`style` and `popover`/`contenteditable`/`is`/the
  text-editing hints stay closed (spec Non-goals).
- `codegen/` was **not** run through `elm-format`: HEAD is equally unformatted
  and the repo's `check:format` covers only `tests/src`, so formatting would have
  produced a large unrelated diff.
- The `<Lib>.Attributes` module docstring still says "Every setter is an open
  producer (`{ c | attr : Supported }`)", which is now imprecise — some setters
  are fully open. Left alone deliberately: editing it would change EVERY brand's
  generated bytes, violating the zero-diff criterion. Worth a follow-up that
  regenerates all brands in one pass.

### Pre-existing failures found, NOT caused by this change

- **elm-cem `check:gates`** — `core.hooksPath` unset in this checkout. Remedy is
  the repo's own `npm run hooks:install`; not run, because it is a durable local
  git-config change.
- **elm-m3e `check:review` / `check:samples`** — tracked
  `review/src/CodegenReviewConfig.elm` imports `NoRedundantAttributeEscape`,
  which exists nowhere and is not provided by sibling `elm-review-cem/src/`
  (which has `NoRedundantElementEscape`). The review config cannot build at HEAD,
  which cascades into three `check:samples` "rule did not report" complaints.
- **elm-m3e `check:drift`** — gitignored `docs/data/reference.json` is stale by
  an `HtmlIr.* → M3e.*` re-qualification unrelated to this change (0 of 1660
  changed lines involve the five globals). Left as found.
- **The four other brand repos' committed `src/`** is stale by the PREVIOUS
  commit's Value-primitives work (`toString`/`FromString`/`Values`), which
  regenerated only elm-typed-html and elm-m3e. This is why a naive
  regenerate-and-diff shows churn; the A/B proof above isolates it.
