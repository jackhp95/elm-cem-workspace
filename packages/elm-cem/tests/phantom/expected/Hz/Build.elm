module Hz.Build exposing
    ( Builder
    , toElement
    )

{-| The shared builder surface for the `Hz` brand: the opaque `Builder`
and the single `toElement` that closes any component's builder. Per-component
modules provide the seeds (`build`) and the narrowed `withX` setters; they all
share this one representation, so `toElement` is defined once (in
`Hz.Build.Internal`) and re-exported here.

@docs Builder
@docs toElement

-}

import HtmlIr.Element exposing (Element)
import Hz.Build.Internal as Internal


{-| The shared pipe-builder — see each component's `Builder` alias for its
narrowed, brand-typed form.
-}
type alias Builder row attrCaps slotCaps msg =
    Internal.Builder row attrCaps slotCaps msg


{-| Close any builder into its element.
-}
toElement : Builder row attrCaps slotCaps msg -> Element accepts admittedBy msg
toElement =
    Internal.toElement
