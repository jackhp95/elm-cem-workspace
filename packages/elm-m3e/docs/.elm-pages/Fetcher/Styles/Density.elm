module Fetcher.Styles.Density exposing (submit)

{-| -}

import Bytes exposing (Bytes)
import Bytes.Decode
import Http
import Pages.Fetcher
import Route.Styles.Density


submit :
    (Result Http.Error Route.Styles.Density.ActionData -> msg)
    ->
        { fields : List ( String, String )
        , headers : List ( String, String )
        }
    -> Pages.Fetcher.Fetcher msg
submit toMsg options =
    { decoder =
        \bytesResult ->
            bytesResult
                |> Result.andThen
                    (\okBytes ->
                        okBytes
                            |> Bytes.Decode.decode Route.Styles.Density.w3_decode_ActionData
                            |> Result.fromMaybe (Http.BadBody "Couldn't decode bytes.")
                    )
                |> toMsg
    , fields = options.fields
    , headers = ("elm-pages-action-only", "true") :: options.headers
        , url = [ [ "styles" ], [ "density" ], [ "content.dat" ] ] |> List.concat |> String.join "/" |> Just
    }
    |> Pages.Fetcher.Fetcher
