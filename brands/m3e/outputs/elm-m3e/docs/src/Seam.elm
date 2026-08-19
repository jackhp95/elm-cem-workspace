module Seam exposing (colorSwatchChrome, selectionIndicatorShape)

{-| **The seam** — the one place a design-system escape is allowed to live.

Every fence in this repo points here: `NoProprietaryDsClasses`'s `allowedModules`
(Tailwind styling classes), `NoSeamOutsideAllowedModules`'s `seamModules` and
`NoUnsafeImportOutsideAllowed`'s allow-list (`M3e.Unsafe` escapes such as
`recast`). Whether an escape crossed a KIND or painted a SURFACE, it is the same
artifact to a reviewer — a small named producer containing something the design
system cannot express yet — so it lands in one module that can be read top to
bottom.

**The discipline.** Do not apply the escape inline at the point of need. Wrap it in
a named producer here, so it is greppable, countable, and has somewhere to carry
its justification. A styling class scattered across forty call sites is invisible;
the same class as one export here is a line item someone can delete the day the
component ships the property.

**Every export must say, in its own doc comment:** what the design system cannot
express, what was verified to establish that, and what would let this be deleted.
An entry that cannot answer those three is a mistake being laundered, not an
escape being contained — fix the call site instead.

This module stayed deliberately empty until something genuinely needed it. It has
exactly one member today; if it grows quickly, that is a signal about the design
system, not about this file.

@docs colorSwatchChrome, selectionIndicatorShape

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Kind exposing (Supported)
import TypedHtml.Attributes


{-| A fully-round corner for the element an `m3e-selection-indicator` is attached
to.

**What the design system cannot express.** `m3e-selection-indicator` has no shape
property. Verified against the generated utility list — no `m3e-selection-indicator-shape-*`
utility exists — and against the component's own CSS, which derives its shape from
`border-radius: inherit` off its light-DOM parent. So the parent has to carry a
radius the component cannot supply, and no `m3e-*` bridge utility exists for it.

**What happens without it.** Not cosmetic: the indicator renders as a SQUARE box
behind the round colour swatches in the theme editor. Verified by removing it and
capturing the result at 411x761 before putting it back.

**What lets this be deleted.** Either `m3e-selection-indicator` gaining a shape
property (which would generate an `m3e-selection-indicator-shape-*` utility, and
then the call site uses that directly), or it inheriting shape from the element it
is `for`. Filed as an m3e gap; delete this export and its call site in
`Theme.colorAvatar` the day either lands.

-}
selectionIndicatorShape : Attr { c | class : Supported } msg
selectionIndicatorShape =
    TypedHtml.Attributes.class "rounded-full"


{-| The round outlined chrome of a colour-override swatch in the theme editor.

**What the design system cannot express.** The swatch must render a circle with a
visible outline whose FILL is an arbitrary user-chosen hex — and show as an empty
outlined circle when the token is unset (fill `transparent`). `m3e-avatar` is round
and takes a colour, but exposes no outline property, so an unset swatch becomes an
invisible transparent circle. Verified: swapping the label for an `m3e-avatar` lost
the border outright.

**Why it stays a native `<label for>`.** The swatch labels a visually-hidden native
`<input type="color">`, which is what keeps the control keyboard-reachable and
screen-reader-labelled. A `<label>` admits only phrasing content, so a custom
element cannot go inside it; replacing the label with a component broke
`settings-sheet.spec.ts:138` (`locator.fill` timed out — the input was no longer
reachable). Structure that works beats markup that lints.

**What lets this be deleted.** `m3e-avatar` gaining an outline/border property, or
an `m3e-*` swatch primitive that accepts an arbitrary fill. Filed as an m3e gap.

-}
colorSwatchChrome : Attr { c | class : Supported } msg
colorSwatchChrome =
    TypedHtml.Attributes.class "rounded-full border border-outline"
