---
name: configuring-cem-review-rules
description: >-
  Assembles a review/src/ReviewConfig.elm for a project that consumes the
  jackhp95/elm-review-cem package (elm-review rules for elm-cem-generated
  component libraries). Use in projects that depend on elm-review-cem when
  wiring up Cem.all / Cem.allWith, deciding which opt-in rules to enable,
  applying the Cem.fences boundary preset, or setting up the seam-discipline rules
  (NoSeamOutsideAllowedModules / NoInternalImportOutsideAllowed / ExtractToSeam).
  Triggers include "configure the CEM review rules", "which Cem rules should I
  enable", "enable barrel style", "set up the fence preset", "why doesn't
  RequireSlot / ValidSlotKind fire on my dynamic list", "set up the seam
  allow-list", and "how do I pass the generated facts to the rules". Routes to
  the package's per-rule docs and encodes only assembly judgment, not the
  per-rule reference.
disable-model-invocation: false
---

# Configuring CEM review rules (consumer)

You are wiring `jackhp95/elm-review-cem` into a project's `review/` config. The
package's 16 exposed modules already carry grade-A per-rule doc comments — this
skill is the **assembly decision tree** and the failure modes those per-rule docs
don't cover. When you need the semantics of one rule, read its module doc (linked
below); don't re-derive it here.

## First move: pass the generated facts

Every `Cem.*` rule is namespace-agnostic and takes a `List Cem.Facts.Fact`. Those
facts are **not** something you write — `elm-cem` emits them into an *unexposed*
module of the generated library, conventionally `<Lib>.Review.Facts`, exposing
`facts : List Cem.Facts.Fact`. Your config imports that module and threads
`facts` into the rules. If a user is hand-writing facts, that's the mistake:
point them back at the generator. The `<Lib>.Review.Facts` module carries no
`elm-review` import because `Cem.Facts` has none — review tooling only enters in
the consuming `review/` config.

You can concatenate several libraries' facts
(`M3e.Review.Facts.facts ++ TypedHtml.Review.Facts.facts`) — the rules group them
by namespace and check each library, so a second library's facts are not ignored.

Version note: `Cem.Facts.Fact` is a versioned contract. The generated
`Review.Facts` and this package must agree major-for-major (README §"Contract
with elm-cem": 1.0.0 ↔ 1.0.0). A facts/rules mismatch is a compile error in
`review/`, not a silent misfire.

## The decision tree

1. **Default: `Cem.all facts`.** Runs every non-opt-in, facts-driven rule with
   `validSlotKind = Lenient`. This is what almost every app should ship. Append
   your own project rules with `++`.

2. **`Cem.allWith { validSlotKind = Cem.Strict } facts` when** you want
   unresolvable slot children flagged. `Strict` warns on EVERY child whose kind
   can't be resolved statically — `let`-bound values, function parameters,
   `List.map` output, helper returns (`viewRow row`). That is a lot of warnings;
   treat `Strict` as a deliberate opt-in for a codebase that keeps slot children
   inline, not a drop-in upgrade. `Cem.all` is exactly `allWith { validSlotKind
   = Lenient }`.

3. **`Cem.all` does NOT include the autofixes.** Do not expect `preferBarrel` or
   `preferComponentSetters` in `all`. Enable those explicitly, à la carte, on top
   of `all`.

4. **The barrel autofix pair are INVERSES — pick at most one direction.**
   - `Cem.preferComponentModules` (IN `all`) rewrites barrel shorthands *down* to
     per-component setters.
   - `Cem.preferBarrel` (opt-in) rewrites the per-component-module API *up* to the
     flat barrel.
   These point opposite ways. Enabling both makes `--fix` fight itself. If a user
   wants "barrel style everywhere", enable `preferBarrel` and understand that
   `preferComponentModules` (shipped in `all`) points the other way — you must
   drop it from `all` for a coherent barrel codebase (see the barrel persona in
   the reference config). Never enable both directions.

5. **The fence preset — `Cem.fences {...}`.** For the seam/opaque-IR boundary,
   prefer the preset over hand-rolling the three boundary rules. It takes one
   config record and wires `NoInternalImportOutsideAllowed` (allowing `*.Internal`
   from `brandRoots ++ ["TypedHtml","HtmlIr"] ++ allowedModules`),
   `NoSeamOutsideAllowedModules`, and `NoRedundantElementForge`:

   ```elm
   Cem.all M3e.Review.Facts.facts
       ++ Cem.fences
           { brandRoots = [ "M3e" ]
           , seamModules = [ "Seam" ]
           , allowedModules = [ "Seam", "Native", "Kit", "Layout" ]
           , typedHtmlFacts = TypedHtml.Review.Facts.facts
           }
   ```

   Hand-rolling these (the pre-preset way) is where configs drifted — apps kept
   omitting the `TypedHtml`/`HtmlIr` allow-list entry and gated those libraries'
   own interior imports. Reach for the wired rules à la carte only when a project
   needs an allow-list the preset can't express.

6. **Advisory vs compile-time posture — don't call a silent rule a bug.** Several
   rules are deliberately advisory and silent when they can't verify statically:
   `requireSlot`, `missingRequiredAttribute`, `missingRequiredSingularSlot`, and
   `validSlotKind` in `Lenient`. If `requireSlot` doesn't fire on a
   dynamically-built or helper-returned content list, that is by design — the
   rule only reasons about inline literal content lists; it stays silent rather
   than false-positive on a list it can't see into. The fix for "I want it to
   catch my dynamic case" is not available at review time; it's a limitation of
   static analysis, not a defect. Explain the posture; don't file a bug.

7. **Seam-discipline rules take module allow-lists, NOT facts.** These three keep
   their top-level names (no `Cem.` prefix) and are config-driven:
   - `NoSeamOutsideAllowedModules.rule { seamModules, allowedModules }` — the gate.
     `seamModules` is the list of dotted module names whose functions are considered seam
     escapes; `allowedModules` is the list of modules permitted to call them (matched on
     dot boundaries: `"Kit"` also allows `Kit.Surface`).
   - `NoInternalImportOutsideAllowed.rule allowedPrefixes` — the fence. Prefixes
     are the module names permitted to import `*.Internal` (typically the
     generated `<Lib>` namespace plus your adapter layers).
   - `ExtractToSeam.rule { seamModule, allowedModules }` — opt-in autofix
     companion to the gate; lifts each flagged escape into `seamModule`. Share
     `allowedModules` with the gate so both rules see the same boundary.
   Common wiring errors: passing `facts` to these (they take module-name lists);
   omitting `seamModules` (the new required field in `NoSeamOutsideAllowedModules`);
   forgetting that allow-list entries match on dot boundaries. The package ships no
   default allow-list; you supply your project's.

## Reference

- **[reference/ReviewConfig-personas.md](reference/ReviewConfig-personas.md)** —
  three complete, annotated `ReviewConfig.elm` files (strict app, migrating app,
  library-with-seams), verified against the real `Cem` API.
- Per-rule semantics: read the module doc for the rule in question —
  `Cem.RequireSlot`, `Cem.ValidSlotKind`, `Cem.PreferBarrel`,
  `Cem.PreferComponentModules`, `NoSeamOutsideAllowedModules`, etc. Each exposed
  module documents exactly what it flags and when it stays silent.
- README §"Usage in a review/ config" and §"Seam discipline" for the package's
  own framing.

---
_Validated against elm-review-cem 1.0.0, 2026-07._
