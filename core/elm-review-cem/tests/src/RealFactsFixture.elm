module RealFactsFixture exposing
    ( facts
    , syntheticLayoutFacts
    )

{-| A VERBATIM snapshot of representative entries from elm-m3e's generated
`M3e.Review.Facts.facts` (copied from
`elm-m3e/src/M3e/Review/Facts.elm` on 2026-08-12). The point of this fixture is
that it is shaped EXACTLY like real generated data — every `module_` carries the
`.Component.` segment — so tests that consume it exercise the same barrel-alias
resolution real code hits. The hand-written per-rule fixtures elsewhere use FLAT
`module_` (`"M3e.Grid"`), which makes `factKey == siteKey` and silently hides
barrel-resolution bugs; this fixture is the antidote.

Three entries chosen to cover the shapes the barrel bug touched:

  - `accordion` — required-multi default slot (`requiredSlots ∩ multiSlots =
    ["unnamed"]`): the shape `RequireSlot` must catch on a barrel call.
  - `appBar` — has SINGULAR slots (`title`, `subtitle`) not in `multiSlots`
    (`["leading","trailing"]`): the shape `SingularSlot` must catch.
  - `button` — the canonical enum-bearing component (`ValidEnumValue` surface).

If the generated `Fact` record gains/loses a field, this fixture will fail to
compile — a deliberate tripwire that keeps the snapshot honest against the
contract.

@docs facts

-}

import Cem.Facts exposing (Facet(..), Fact)


{-| A synthetic fact whose `module_` uses a NEW intermediate segment
(`"Layout"`) that has never appeared in real facts. This fixture exists
specifically to prove that `barrelNamespaceParts` is GENERIC — it must derive
the barrel root `["M3e"]` from `["M3e","Layout"]` without hardcoding `"Layout"`.

If `barrelNamespaceParts` still checks for a segment allowlist, the barrel-alias
key `"M3e\u{0000}card"` will be ABSENT from `buildIndex` and the associated
`RealFactsShapeTest` assertions will FAIL — proving the regression is live.

-}
syntheticLayoutFacts : List Fact
syntheticLayoutFacts =
    [ { component = "card"
      , module_ = "M3e.Layout.Card"
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
    ]


{-| Verbatim real facts (field order as generated).
-}
facts : List Fact
facts =
    [ { component = "accordion"
      , module_ = "M3e.Component.Accordion"
      , enums = []
      , requiredSlots = [ "unnamed" ]
      , multiSlots = [ "unnamed" ]
      , attrRewrites = [ ( "multi", "multi" ) ]
      , slotRewrites = []
      , slotKinds = [ ( "unnamed", [ "expansionPanel" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Record, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "appBar"
      , module_ = "M3e.Component.AppBar"
      , enums = [ ( "size", [ "large", "medium", "small" ] ) ]
      , requiredSlots = []
      , multiSlots = [ "leading", "trailing" ]
      , attrRewrites = [ ( "centered", "centered" ), ( "for", "for" ), ( "size", "size" ) ]
      , slotRewrites = [ ( "leading", "leading" ), ( "leading-icon", "leadingIcon" ), ( "subtitle", "subtitle" ), ( "title", "title" ), ( "trailing", "trailing" ), ( "trailing-icon", "trailingIcon" ) ]
      , slotKinds = [ ( "leading", [ "button", "iconButton", "shared:icon" ] ), ( "subtitle", [ "heading", "shared:flow", "shared:phrasing", "shared:text" ] ), ( "title", [ "heading", "shared:flow", "shared:phrasing", "shared:text" ] ), ( "trailing", [ "button", "iconButton", "searchBar", "shared:flow", "shared:phrasing" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "button"
      , module_ = "M3e.Component.Button"
      , enums = [ ( "shape", [ "rounded", "square" ] ), ( "size", [ "extraLarge", "extraSmall", "large", "medium", "small" ] ), ( "type_", [ "button", "reset", "submit" ] ), ( "variant", [ "elevated", "filled", "outlined", "text", "tonal" ] ) ]
      , requiredSlots = [ "unnamed" ]
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "disabledInteractive", "disabledInteractive" ), ( "download", "download" ), ( "href", "href" ), ( "name", "name" ), ( "rel", "rel" ), ( "selected", "selected" ), ( "shape", "shape" ), ( "size", "size" ), ( "target", "target" ), ( "toggle", "toggle" ), ( "type_", "type_" ), ( "value", "value" ), ( "variant", "variant" ), ( "defaultSelected", "defaultSelected" ), ( "defaultValue", "defaultValue" ), ( "onBeforeinput", "onBeforeinput" ), ( "onInput", "onInput" ), ( "onChange", "onChange" ), ( "onClick", "onClick" ) ]
      , slotRewrites = [ ( "icon", "icon" ), ( "selected", "selected" ), ( "selected-icon", "selectedIcon" ), ( "trailing-icon", "trailingIcon" ) ]
      , slotKinds = [ ( "unnamed", [ "bottomSheetAction", "bottomSheetTrigger", "datepickerToggle", "dialogAction", "dialogTrigger", "drawerToggle", "fabMenuTrigger", "heading", "menuTrigger", "navRailToggle", "richTooltipAction", "shared:icon", "shared:text", "stepperNext", "stepperPrevious", "stepperReset", "timepickerToggle" ] ), ( "icon", [ "loadingIndicator", "shared:icon" ] ), ( "selected", [ "heading", "shared:icon", "shared:text" ] ), ( "selected-icon", [ "shared:icon" ] ), ( "trailing-icon", [ "shared:icon" ] ) ]
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Record, Build ]
      , requiredAttrs = []
      , actionMap = [ ( "onClick", "onClick" ), ( "href", "link" ) ]
      , usesAction = True
      }
    ]
