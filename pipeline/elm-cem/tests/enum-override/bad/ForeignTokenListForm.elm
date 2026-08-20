module ForeignTokenListForm exposing (broken)

{-| The union row must be CLOSED over the override's own tokens.

`wide` is a real token in this brand — the `mode` CEM enum mints it — and it shares the
`<Lib>.Values` pool with `disable-pagination`'s tokens. Sharing the POOL must not mean
sharing the ROW: an emitted row that merely happened to be open, or that accumulated
every token in the brand, would let this compile while writing `wide` into an attribute
that admits only `true`/`false`/`auto`.

-}

import Eo
import Eo.Attributes
import Eo.Values


broken =
    Eo.bar [ Eo.Attributes.disablePagination Eo.Values.wide ] []
