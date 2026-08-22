module ReviewConfig exposing (config)

import Cem
import Review.Rule as Rule exposing (Rule)
import TypedHtml.Review.Facts


config : List Rule
config =
    [ Cem.validSlotKindWith Cem.Lenient TypedHtml.Review.Facts.facts ]
