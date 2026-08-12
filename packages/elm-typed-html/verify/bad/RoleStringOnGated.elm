module RoleStringOnGated exposing (broken)

{-| The escape hatch must not bypass the gate: roleString targets
`role : Supported`, but div's row pins `role : DivRoles`. MUST FAIL.
-}

import TypedHtml as H
import TypedHtml.Aria as Aria


broken =
    H.div [ Aria.roleString "banner" ] []
