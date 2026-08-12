# Contributing to elm-review-cem

## The Fact contract is versioned — treat it as an API

`Cem.Facts.Fact` is the contract between the `elm-cem` generator and these rules.
Changing its shape (adding/removing/renaming fields) is a **breaking change** on
both sides:

- Every generator that emits `facts` must be updated in lockstep.
- Bump the package **major** version for any incompatible `Fact` change; a purely
  additive optional field that older generators can omit is at most a minor bump.

Prefer extending a rule to consume an existing field over widening `Fact`.

## Adding a rule

1. Create `src/Cem/YourRule.elm` exposing `rule : List Cem.Facts.Fact -> Rule`
   (opt-in variants may add `ruleWith`). Derive the namespace from each fact's
   `module_` — never hardcode a library name.
2. Add a doc comment (`{-| … -}`) to **every exposed value** — `elm make --docs`
   and `elm publish` reject undocumented exposures.
3. Add `"Cem.YourRule"` to `exposed-modules` in `elm.json`.
4. Wire it into `Cem.all` (or, if opt-in/mutually-exclusive, document it in the
   `Cem` module and leave it out of `all`).
5. Add `tests/YourRuleTest.elm` following the existing table-driven pattern; reuse
   the shared fixtures.

## Running the checks

Run `elm-format` on any `.elm` file you touch. Before opening a PR, confirm both
`elm make --docs` and the full test suite pass. If you have no global `elm`
0.19.x, use the pinned runner against a local compiler (see the README):

```sh
npx -y elm-test@0.19.1-revision12 --compiler /path/to/elm
```
