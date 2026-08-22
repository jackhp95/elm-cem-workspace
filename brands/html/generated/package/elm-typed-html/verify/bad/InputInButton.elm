module InputInButton exposing (broken)

{-| families/a11y-composition plan, Task 3.5: the `sharedPhrasing` /
`sharedInteractive` split must keep the ORIGINAL a11y rejection intact — an
interactive element inside `button` is still "interactive content descendant"
and MUST FAIL. `input` produces `sharedInteractive`, which `button`'s
`!@interactive` subtraction removes from its admitted row, so this does not
type-check. Companion to bad/InteractiveContentInButton.elm (button > button);
this one pins a DIFFERENT interactive member so the fix cannot pass by only
special-casing `button`'s own produced kind. See verify/src/Good.elm's
`a11yBenignInButton` for the other half (button > span now COMPILES).
-}

import TypedHtml as H


broken =
    H.button [] [ H.input [] [] ]
