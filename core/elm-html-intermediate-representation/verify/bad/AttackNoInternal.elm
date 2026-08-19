module AttackNoInternal exposing (evil)

{-| The control for AttackForge: WITHOUT HtmlIr.Internal, the public surface
must offer no forge at all. MUST FAIL ("does not expose fromNode").
-}

import HtmlIr.Element
import HtmlIr.Node


evil =
    HtmlIr.Element.fromNode (HtmlIr.Node.text "x")
