module Good exposing (page, view)

{-| Tests that barren (zero enum) compiles without Values.elm.
This proves K6 works: no Values module is emitted, and no module imports it.
-}

import Html exposing (Html)
import HtmlIr.Element
import HtmlIr.Node
import Br
import Br.Attributes
import Br.Component.Barren
import Br.Kind


type Msg
    = NoOp


page : HtmlIr.Element.Element { s | barren : Br.Kind.Brand } admittedBy Msg
page =
    Br.barren
        [ Br.Component.Barren.label "test label"
        , Br.Attributes.class "container"
        ]
        []


view : Html Msg
view =
    HtmlIr.Node.toHtml (HtmlIr.Element.toNode page)
