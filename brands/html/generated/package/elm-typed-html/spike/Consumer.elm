module Consumer exposing (badButtonInButton, badButtonWithA, collateralButtonWithSpan, okButtonWithText)

{-| `Cem.ValidSlotKind` spike consumer (Task 3.3, families/a11y-composition
plan, 2026-08-21). A CONSUMER call site — deliberately outside `src/` (excluded
by `ReviewConfig.ignoreGenerated`) and `verify/` (excluded by
`ReviewConfig.ignoreVerifyFixtures`), so the rule actually evaluates
`TypedHtml.Review.Facts.facts` against real usage instead of being suppressed.

Reproduce from this package's root (`elm-typed-html/`), with:
`node_modules/.bin/elm-review --elmjson spike/elm.json --config spike-review`

Real output at the Task 3 commit (`facts` populated by the `!@interactive`
`admits` edit):

  - `badButtonInButton` — ERROR: "`button` is not an allowed child of the
    `default` slot on `button`". Confirmed ABSENT before this task's `admits`
    edit at the COMPILER layer — `H.button [] [ H.button [] [] ]` used to
    type-check (button's own `sharedPhrasing`-collapsed produced kind was
    still in its own admitted set). `ValidSlotKind` itself already flagged it
    pre-task too, for an unrelated, pre-existing reason (below).
  - `badButtonWithA` — ERROR: same shape, `a` for `button`. `a` is
    `transparent`, so this is NEVER caught by the Elm compiler (see
    `verify/src/Good.elm`'s `a11yPositives` doc) — `ValidSlotKind` is the ONLY
    layer that catches `button > a`, and it fires because of BUTTON's own
    `!@interactive` exclusion of `a` (A's own admits, added in this same task,
    govern what's legal INSIDE an `<a>` — a separate axis, also unreachable by
    the compiler for the same transparency reason).
  - `collateralButtonWithSpan` — ERROR, BOTH before and after this task's
    edit. `ValidSlotKind` matches a child's bare NOUN ("span") against the
    parent's `slotKinds` STRINGS; before this task those strings already read
    `[…, "shared:phrasing", …]` (never literally `"span"`), so this was
    ALREADY flagged — a pre-existing, orthogonal gap this task neither
    created nor fixed. (At the COMPILER layer, by contrast, `H.button [] [
    H.span [] [] ]` DID compile before this task and does NOT after — a real,
    task-introduced compiler-level restriction; see the Task 3 report.)
  - `okButtonWithText` — no error, before or after. `H.text` is admitted via
    the explicit `"shared:text"` kind entry (`isAllowedKind`'s `"shared:" ++
    kind` match), untouched by the `@phrasing`-side subtraction.

-}

import TypedHtml as H
import TypedHtml.Attributes as At


badButtonInButton =
    H.button [] [ H.button [] [] ]


badButtonWithA =
    H.button [] [ H.a [ At.href "/x" ] [] ]


collateralButtonWithSpan =
    H.button [] [ H.span [] [ H.text "hi" ] ]


okButtonWithText =
    H.button [] [ H.text "hi" ]
