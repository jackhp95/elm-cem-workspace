module TypedHtml.Aria exposing
    ( role, roleString
    , navigation, presentation, tab
    , Checked, checked
    , false, mixed, true
    , label, labelledby
    )

{-| The ARIA concern axis — the HYBRID design: `role` is TYPE-GATED per
element where it earns its keep (an element's `<El>Roles` alias closes the
legal set; a wrong role is a compile error), enumerated aria-\* states are
value-typed, and the universal aria-\* attributes stay open. The role×state
dependency is lint territory.

@docs role, roleString
@docs navigation, presentation, tab
@docs Checked, checked
@docs false, mixed, true
@docs label, labelledby

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import TypedHtml.Kind exposing (Role)


{-| Set a TYPED role: the token's row must fit the element's closed role set.
-}
role : Value tags -> Attr { c | role : tags } msg
role value_ =
    Ir.attribute "role" (HtmlIr.Value.toString value_)


{-| Set a raw role string on a role-UNGATED element (its row has `role : Supported`).
-}
roleString : String -> Attr { c | role : Supported } msg
roleString =
    Ir.attribute "role"


{-| The `navigation` role token.
-}
navigation : Value { r | navigation : Role }
navigation =
    Ir.token "navigation"


{-| The `presentation` role token.
-}
presentation : Value { r | presentation : Role }
presentation =
    Ir.token "presentation"


{-| The `tab` role token.
-}
tab : Value { r | tab : Role }
tab =
    Ir.token "tab"


{-| The values `aria-checked` admits.
-}
type alias Checked =
    { false : Supported
    , mixed : Supported
    , true : Supported
    }


{-| Value-typed `aria-checked` (universal: any element admits it).
-}
checked : Value Checked -> Attr c msg
checked value_ =
    Ir.attribute "aria-checked" (HtmlIr.Value.toString value_)


{-| The `false` state token.
-}
false : Value { v | false : Supported }
false =
    Ir.token "false"


{-| The `mixed` state token.
-}
mixed : Value { v | mixed : Supported }
mixed =
    Ir.token "mixed"


{-| The `true` state token.
-}
true : Value { v | true : Supported }
true =
    Ir.token "true"


{-| The open `aria-label` attribute (universal).
-}
label : String -> Attr c msg
label =
    Ir.attribute "aria-label"


{-| The open `aria-labelledby` attribute (universal).
-}
labelledby : String -> Attr c msg
labelledby =
    Ir.attribute "aria-labelledby"
