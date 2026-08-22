# Task 6 + 7 design note — `Cem.ValidComposition` + gate wiring

**Status:** implementation design, authored + executed by the Task-6/7 agent (2026-08-21).
**Parent plan:** `docs/plans/2026-08-21-families-a11y-composition-plan.md` §6–§7.
**Resolved decision (Jack, OQ-2):** SPLIT posture — hard-fail the WHATWG content-model
violations (interactive-in-interactive at arbitrary depth; `label` single-labeled-control /
no-nested-label), WARN the ARIA relational ones (required-context) and the SVG-AAM overlay.

---

## 0. What the sibling `ValidSlotKind` can and can't do

`ValidSlotKind` checks **direct** membership: a child in a parent's content list must be a kind
the parent's slot admits (`slotKinds`, a flat allow-list). Task 3 already made the DIRECT-child
interactive-nesting a **compile error** for html (`button`/`a`/`label`/`summary` gained
`!@interactive`, so their own produced kind is no longer in their admitted `Content` row — the
`verify/bad/*.elm` acid probes prove `H.button [] [ H.button [] [] ]` fails `elm make`).

What neither the phantom types nor `ValidSlotKind` can express:

- **arbitrary-depth** interactive descendant: `H.button [] [ H.span [] [ H.a [] [] ] ]` — the
  `a` is legal in `span`, and `span` is legal in `button`, so every direct-slot check passes, yet
  the WHATWG button content model ("no interactive content **descendant**") is violated.
- **`label` single-labeled-control**: at most one labelable descendant, and no nested `label`.
- **ARIA required-context**: a `tab` needs a `tablist` **ancestor** (not necessarily a parent).
- **SVG-AAM**: a `role`/`aria-roledescription` **attribute** on a non-rendered svg element.

These are relational (ancestor/descendant), so `ValidComposition` is a NEW generic rule that
walks the AST tree of a component call rather than just its immediate content list.

## 1. API shape (mirrors `ValidSlotKind.ruleWith`)

```elm
module Cem.ValidComposition exposing (Config, defaultConfig, rule, ruleWith)

type alias Config =
    { interactiveKinds : List String        -- nouns that ARE interactive content
    , noNestedSelf : List String            -- parent nouns that forbid a same-noun descendant (a → a)
    , labelKinds : List String              -- nouns whose content model is "label" (single labeled control)
    , labelableKinds : List String          -- nouns that are labelable form controls
    , requiredContext : List ( String, List String )
                                            -- child noun → the ancestor container nouns one of which is required
    , svgNonRendered : List String          -- svg element nouns that may carry no role
    , roleAttrSetters : List String         -- attribute-setter names that assign a role/aria-roledescription
    , posture :
        { interactive : Severity            -- HARD (WHATWG) — Error
        , label : Severity                  -- HARD (WHATWG) — Error
        , requiredContext : Severity        -- WARN (ARIA)   — via Rule.error but semantically advisory
        , svgAam : Severity                 -- WARN (SVG-AAM)
        }
    }

type Severity = Hard | Warn
```

`defaultConfig` carries the WHATWG universal tables keyed by the **standard element nouns** that
are identical across html (tag names) and are the WHATWG interactive-content set
(`docs/a11y-foundation/composition-rules.json` → `interactiveContent.members`,
`whatwgContentModels`). Brands extend it (shoelace adds its own interactive nouns + role-map
required-context) but html uses `defaultConfig` verbatim.

**Why a Config param, not pure facts?** The `Cem.Facts.Fact` type carries `slotKinds` but NOT a
per-component ARIA role or interactive flag (verified — `pipeline/elm-cem-facts/src/Cem/Facts.elm`).
The interactive/role/required-context tables live in the provenance-stamped foundation JSON, not in
the facts. Passing them as a `Config` (the same way `ValidSlotKind` passes its `Unresolved`
posture) keeps the rule generic and fact-agnostic: it still resolves call sites and child kinds
through the generated facts (`Cem.Internal.Facts`), it just consults the Config for the relational
tables the facts don't carry.

### Severity mechanism

elm-review has no built-in warn-vs-error split (every `Rule.error` fails `elm-review`). The repo's
existing convention (`ValidSlotKind`'s `Lenient`/`Strict`) is: a posture field decides whether an
error is EMITTED at all. We use the same mechanism but per-constraint-family: `Hard` emits the
error unconditionally; `Warn` emits an error whose **message is prefixed `warning:`** and whose
details explain it is advisory — AND the brand gate wiring runs the Warn-severity families through
`Rule.ignoreErrorsForDirectories` on the strict-gate fixtures only where a real warn-vs-fail split
is needed. In practice: the HARD families (interactive/label) are wired into every brand's
`check:review` config as plain errors (they turn the gate red); the WARN families are emitted with
the `warning:` prefix so they are visible but, per OQ-2, are wired at a posture that does not fail
the gate on the intentional-composition cases (a `tab` deliberately built without its `tablist`
in the same module). The distinction is REAL: the mutation proof shows a HARD mutation
(`button`-in-`button` 3-deep) turning the gate red, and a WARN mutation (`menuitem` outside `menu`)
surfacing as a `warning:`-prefixed advisory that the brand config chooses not to fail on.

## 2. Brand wiring (Task 7)

| brand    | review config exists? | `role`/aria attrs modelled? | ValidComposition families active |
|----------|-----------------------|-----------------------------|----------------------------------|
| html     | yes (`review/`)       | yes                         | interactive (HARD), label (HARD), required-context (WARN) |
| shoelace | yes (`review/`)       | host-managed (not in API)   | interactive (HARD), required-context (WARN) via role-map |
| svg      | **no review config**  | **no** (globals are presentation-only) | overlay (d) is INERT until svg models `role`/`aria-*`; see below |

**SVG reality (verified):** `brands/svg/A11Y-OVERLAY.md` §1 states svg does not yet model
`role`/`aria-*` attributes, and svg has **no `check:review` step** (its gate is `check:compile` +
render tests). So the SVG-AAM overlay (constraint d) has nothing to fire on and no review harness
to run in. Task 6 still IMPLEMENTS the overlay logic + a red/green unit test (the rule is generic
and must be correct for when svg gains those attributes and a review config — the A11Y-OVERLAY note
explicitly says "Task 6 should key off the foundation set so it stays correct after that merge").
The svg *mutation proof* is therefore demonstrated at the unit-test level (a `role` setter on
`defs` trips the rule; removing it clears it) rather than through a not-yet-existent svg review
gate. This is documented honestly rather than fabricating a svg review config the brand doesn't
have. Wiring svg's review gate + role attributes is follow-up (it belongs with the svg-audit
branch's attribute-family work, per the overlay note's own prerequisite clause).

## 3. Gate wiring

- `elm-review-cem: check` + `elm-review-cem: test` already run the rule's compile + unit tests
  (the new `ValidCompositionTest.elm` joins the elm-test suite). This is where constraint families
  (a)–(d) get their red+green proofs.
- `elm-typed-html: check` (`check:review`) + `elm-shoelace: check` (`check:review`) get
  `Cem.validComposition*` added to their `ReviewConfig.elm` `codegenAware` list. The mutation proof
  inserts an arbitrary-depth `button`-in-`button` (html) and a `menuitem`-outside-`menu` (shoelace)
  into a throwaway consumer module, runs `check:review`, shows red, reverts, shows green.
- `Cem` barrel gains `validComposition` / `validCompositionWith` exports and `ValidComposition` is
  added to `exposed-modules`.
- No new gate-all step is needed: the brands' existing `check` steps already run `check:review`,
  and `elm-review-cem`'s existing `check`/`test` steps already run the rule's compile+tests. Task 7
  therefore does not add to `gate-all-expected-steps.json` (that file lists step NAMES, and no step
  name changes — the rule rides inside existing steps). This is confirmed against the step list.
```
