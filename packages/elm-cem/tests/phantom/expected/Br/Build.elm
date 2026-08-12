module Br.Build exposing
    ( Builder
    , toElement
    )

{-| The shared builder surface for the `Br` brand: the opaque `Builder`
and the single `toElement` that closes any component's builder. Per-component
modules provide the seeds (`build`) and the narrowed `withX` setters; they all
share this one representation, so `toElement` is defined once (in
`Br.Build.Internal`) and re-exported here.

@docs Builder
@docs toElement

-}

import Br.Build.Internal as Internal
import HtmlIr.Element exposing (Element)


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
