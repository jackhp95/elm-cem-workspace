module Hz.Build exposing
    ( Builder
    , toElement
    , AttrSlotIs, BlockedIs, DuplicateIs, ErrorOnlyIs, EventClashIs, GlobalIs, PlacementIs, TextIs, TextElementIs
    )

{-| The shared builder surface for the `Hz` brand: the opaque `Builder`
and the single `toElement` that closes any component's builder. Per-component
modules provide the seeds (`build`) and the narrowed `withX` setters; they all
share this one representation, so `toElement` is defined once (in
`Hz.Forge.Internal`) and re-exported here.

The `Is` aliases (`ButtonIs`, `CardIs`, …) let you annotate a phantom-kind
type without importing the component or its builder module.

@docs Builder
@docs toElement
@docs AttrSlotIs, BlockedIs, DuplicateIs, ErrorOnlyIs, EventClashIs, GlobalIs, PlacementIs, TextIs, TextElementIs

-}

import HtmlIr.Element exposing (Element)
import Hz.Build.AttrSlot
import Hz.Build.Blocked
import Hz.Build.Duplicate
import Hz.Build.ErrorOnly
import Hz.Build.EventClash
import Hz.Build.Global
import Hz.Build.Placement
import Hz.Build.Text
import Hz.Build.TextElement
import Hz.Forge.Internal as Internal


{-| The shared pipe-builder — see each component's `Builder` alias for its
narrowed, brand-typed form.
-}
type alias Builder row attrCaps slotCaps accepts msg =
    Internal.Builder row attrCaps slotCaps accepts msg


{-| Close any builder into its element.
-}
toElement : Builder row attrCaps slotCaps accepts msg -> Element accepts admittedBy msg
toElement =
    Internal.toElement


{-| The `AttrSlot` kind phantom — annotate with `List (Element (AttrSlotIs s) admittedBy msg)`.
-}
type alias AttrSlotIs s =
    Hz.Build.AttrSlot.Is s


{-| The `Blocked` kind phantom — annotate with `List (Element (BlockedIs s) admittedBy msg)`.
-}
type alias BlockedIs s =
    Hz.Build.Blocked.Is s


{-| The `Duplicate` kind phantom — annotate with `List (Element (DuplicateIs s) admittedBy msg)`.
-}
type alias DuplicateIs s =
    Hz.Build.Duplicate.Is s


{-| The `ErrorOnly` kind phantom — annotate with `List (Element (ErrorOnlyIs s) admittedBy msg)`.
-}
type alias ErrorOnlyIs s =
    Hz.Build.ErrorOnly.Is s


{-| The `EventClash` kind phantom — annotate with `List (Element (EventClashIs s) admittedBy msg)`.
-}
type alias EventClashIs s =
    Hz.Build.EventClash.Is s


{-| The `Global` kind phantom — annotate with `List (Element (GlobalIs s) admittedBy msg)`.
-}
type alias GlobalIs s =
    Hz.Build.Global.Is s


{-| The `Placement` kind phantom — annotate with `List (Element (PlacementIs s) admittedBy msg)`.
-}
type alias PlacementIs s =
    Hz.Build.Placement.Is s


{-| The `Text` kind phantom — annotate with `List (Element (TextIs s) admittedBy msg)`.
-}
type alias TextIs s =
    Hz.Build.Text.Is s


{-| The `TextElement` kind phantom — annotate with `List (Element (TextElementIs s) admittedBy msg)`.
-}
type alias TextElementIs s =
    Hz.Build.TextElement.Is s
