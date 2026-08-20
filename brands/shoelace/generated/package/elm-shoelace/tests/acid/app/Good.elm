module Good exposing (view)

{-| POSITIVE acid probe: a real, small program using two real Shoelace
components (`sl-alert` and `sl-button`) must compile against the generated API.

Exercises the general/barrel surface (`Sl.alert`, `Sl.button`, `Sl.text`), the
shared attribute setters carrying phantom capability rows
(`Sl.Attributes.variant`/`open`/`closable`), the shared value vocabulary
(`Sl.Values.primary`/`success`/`large`), and the render boundary
(`Sl.toHtml`). This is the "the generated bindings are actually usable, not
just compilable" proof from the brand-standup task.

-}

import Html exposing (Html)
import Sl
import Sl.Attributes
import Sl.Values


view : Html msg
view =
    Html.div []
        [ Sl.toHtml
            (Sl.alert
                [ Sl.Attributes.variant Sl.Values.success
                , Sl.Attributes.open True
                , Sl.Attributes.closable True
                ]
                [ Sl.text "Your changes have been saved." ]
            )
        , Sl.toHtml
            (Sl.button
                [ Sl.Attributes.variant Sl.Values.primary
                , Sl.Attributes.size Sl.Values.large
                ]
                [ Sl.text "Save" ]
            )
        ]
