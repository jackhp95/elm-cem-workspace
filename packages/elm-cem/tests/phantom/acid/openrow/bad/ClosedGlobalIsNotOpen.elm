module ClosedGlobalIsNotOpen exposing (broken)

{-| A `_globals` entry with NO `row` key must stay CLOSED. MUST FAIL.

`cflag` is `oflag`'s twin in every respect but `row`, so annotating it at the
unconstrained `Attr c msg` shape must be rejected — its real type refines the row
with `cflag : Supported`, and `c` is more general than that.

Without this probe, a change that opened every global (rather than only the
entries asking for it) would pass the whole suite.

-}

import HtmlIr.Attribute
import Or.Attributes


broken : HtmlIr.Attribute.Attr c msg
broken =
    Or.Attributes.cflag True
