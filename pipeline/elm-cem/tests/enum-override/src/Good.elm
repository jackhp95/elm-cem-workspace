module Good exposing (view)

{-| Everything a config-forced enum override MUST make compile.

The point of an `attrTypes` enum override is a `Value <Row>` setter. Grepping the
emitted text proves the SIGNATURE; this proves the whole chain actually type-checks —
that the row the shared setter closes over, the row the per-component setter narrows
to, and the row each pooled token asserts are the same rows.

-}

import Eo
import Eo.Attributes
import Eo.Build.Bar
import Eo.Element.Bar
import Eo.Element.Gate
import Eo.Values
import Html exposing (Html)
import HtmlIr.Element
import HtmlIr.Node


view : Html msg
view =
    HtmlIr.Node.toHtml
        (HtmlIr.Element.toNode
            (Eo.bar
                [ -- LIST form, from the shared vocabulary. `true` / `false` are ordinary
                  -- Elm identifiers, and `auto` is the token the `mode` CEM enum already
                  -- minted — reused, not re-minted.
                  Eo.Attributes.disablePagination Eo.Values.true
                , Eo.Attributes.mode Eo.Values.auto

                -- The AEnumNum shape stays a plain String: `HtmlIr.Value`'s row is over
                -- string tokens and has no numeric member, so `number | 'all'` has no
                -- `Value` spelling. See `Attr.AttrType`.
                , Eo.Attributes.maxVisible "all"
                ]
                [ Eo.Element.Bar.component
                    -- The per-component setters narrow to the SAME pooled tokens.
                    [ Eo.Element.Bar.disablePagination Eo.Values.auto
                    , Eo.Element.Bar.mode Eo.Values.wide
                    ]
                    []
                , Eo.gate
                    -- MAP form. The Elm name is `always`; the string it writes is "true".
                    [ Eo.Attributes.strict Eo.Values.always ]
                    []
                , Eo.Element.Gate.component [ Eo.Element.Gate.strict Eo.Values.never ] []

                -- The builder pipes carry the same rows.
                , Eo.Build.Bar.build
                    |> Eo.Build.Bar.withDisablePagination Eo.Values.false
                    |> Eo.Build.Bar.toElement
                ]
            )
        )
