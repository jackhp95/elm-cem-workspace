module Mini.Build exposing
    ( Builder
    , toElement
    , ButtonIs, ChipIs, IconIs, SurfaceIs, TabIs, TabsIs, ToolbarIs
    )

{-| The shared builder surface for the `Mini` brand: the opaque `Builder`
and the single `toElement` that closes any component's builder. Per-component
modules provide the seeds (`build`) and the narrowed `withX` setters; they all
share this one representation, so `toElement` is defined once (in
`Mini.Forge.Internal`) and re-exported here.

The `Is` aliases (`ButtonIs`, `CardIs`, …) let you annotate a phantom-kind
type without importing the component or its builder module.

@docs Builder
@docs toElement
@docs ButtonIs, ChipIs, IconIs, SurfaceIs, TabIs, TabsIs, ToolbarIs

-}

import HtmlIr.Element exposing (Element)
import Mini.Build.Button
import Mini.Build.Chip
import Mini.Build.Icon
import Mini.Build.Surface
import Mini.Build.Tab
import Mini.Build.Tabs
import Mini.Build.Toolbar
import Mini.Forge.Internal as Internal


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


{-| The `Button` kind phantom — annotate with `List (Element (ButtonIs s) admittedBy msg)`.
-}
type alias ButtonIs s =
    Mini.Build.Button.Is s


{-| The `Chip` kind phantom — annotate with `List (Element (ChipIs s) admittedBy msg)`.
-}
type alias ChipIs s =
    Mini.Build.Chip.Is s


{-| The `Icon` kind phantom — annotate with `List (Element (IconIs s) admittedBy msg)`.
-}
type alias IconIs s =
    Mini.Build.Icon.Is s


{-| The `Surface` kind phantom — annotate with `List (Element (SurfaceIs s) admittedBy msg)`.
-}
type alias SurfaceIs s =
    Mini.Build.Surface.Is s


{-| The `Tab` kind phantom — annotate with `List (Element (TabIs s) admittedBy msg)`.
-}
type alias TabIs s =
    Mini.Build.Tab.Is s


{-| The `Tabs` kind phantom — annotate with `List (Element (TabsIs s) admittedBy msg)`.
-}
type alias TabsIs s =
    Mini.Build.Tabs.Is s


{-| The `Toolbar` kind phantom — annotate with `List (Element (ToolbarIs s) admittedBy msg)`.
-}
type alias ToolbarIs s =
    Mini.Build.Toolbar.Is s
