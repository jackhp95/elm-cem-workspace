module NoHandEditedGeneratedM3e exposing (rule)

{-| Forbids hand-editing the committed-copy `vendor/` M3e trees in a consumer repo.

The elm-m3e / elm-cem family is unpublished, so external Elm consumers vendor a
**committed copy** of the canonical source trees (see the rollout plan §5.1b and
the companion `scripts/revendor-m3e.mjs`, which is the _only_ sanctioned writer of
`vendor/`). The hazard of a committed copy is silent DRIFT: someone hand-edits a
vendored module, or adds/deletes one, diverging from canonical.

This rule is **Layer 2** of the anti-drift guard — the same-language, in-editor
early warning. It reads `vendor/m3e-manifest.json` (written by `revendor-m3e.mjs`)
via [`Rule.withExtraFilesProjectVisitor`](Review-Rule#withExtraFilesProjectVisitor)
and reports:

  - a file under `vendor/` that is **not in the manifest** (added by hand),
  - a file whose content length **differs from the manifest** (edited by hand),
  - a file in the manifest that is **missing** from `vendor/` (deleted by hand),
  - a missing or malformed `vendor/m3e-manifest.json`.

The remediation is always the same: re-run `scripts/revendor-m3e.mjs`; never edit
`vendor/` by hand. No autofix is offered — elm-review cannot re-run the vendor
script, so the message _is_ the fix.

**Boundary with Layer 1.** This rule compares content **length**, not bytes. At
review time elm-review runs on Node and hands the rule the identical JS string the
manifest's `len` was computed from, so `String.length` matches by construction —
a parity-safe signal with no sha256 implementation in Elm. Byte-exact verification
(catching a same-length in-place edit) is the job of the deterministic
`check-vendor.mjs` gate (Layer 1), which runs on pre-push/CI and is the gate of
record. This rule is the ergonomic complement, not a replacement.

    config =
        [ NoHandEditedGeneratedM3e.rule
        ]

@docs rule

-}

import Dict exposing (Dict)
import Elm.Syntax.Range exposing (Range)
import Json.Decode as Decode
import Review.FilePattern as FilePattern
import Review.Rule as Rule exposing (Error, Rule)


{-| The rule. Takes no configuration — the manifest at `vendor/m3e-manifest.json`
carries everything it needs.
-}
rule : Rule
rule =
    Rule.newProjectRuleSchema "NoHandEditedGeneratedM3e" ()
        |> Rule.withExtraFilesProjectVisitor vendorFilesVisitor
            [ FilePattern.include "vendor/**/*"
            , FilePattern.include manifestPath
            ]
        |> Rule.fromProjectRuleSchema


manifestPath : String
manifestPath =
    "vendor/m3e-manifest.json"


{-| The human-readable provenance record `revendor-m3e.mjs` writes alongside the
manifest. It is not a vendored _source_ file, so it is excluded from the checks.
-}
provenancePath : String
provenancePath =
    "vendor/VENDORED_FROM.json"


type alias FileEntry =
    { fileKey : Rule.ExtraFileKey, content : String }


{-| Errors emitted by an extra-files project visitor carry the
`useErrorForModule` scope that `withExtraFilesProjectVisitor` requires.
-}
type alias VendorError =
    Error { useErrorForModule : () }


vendorFilesVisitor : Dict String FileEntry -> () -> ( List VendorError, () )
vendorFilesVisitor files () =
    ( checkVendor files, () )


checkVendor : Dict String FileEntry -> List VendorError
checkVendor files =
    case Dict.get manifestPath files of
        Nothing ->
            -- No manifest. Only a problem if something *is* vendored — otherwise
            -- this repo simply isn't an M3e committed-copy consumer.
            case List.head (vendoredEntries files) of
                Nothing ->
                    []

                Just ( _, entry ) ->
                    [ missingManifestError entry ]

        Just manifestEntry ->
            case Decode.decodeString manifestDecoder manifestEntry.content of
                Err err ->
                    [ badManifestError manifestEntry (Decode.errorToString err) ]

                Ok manifestLens ->
                    checkAgainstManifest manifestEntry manifestLens (vendoredEntries files)


{-| Manifest → `Dict path length`. Only the per-file `len` matters to this rule;
`sha256` (byte-exact) is Layer 1's concern.
-}
manifestDecoder : Decode.Decoder (Dict String Int)
manifestDecoder =
    Decode.field "files" (Decode.dict (Decode.field "len" Decode.int))


vendoredEntries : Dict String FileEntry -> List ( String, FileEntry )
vendoredEntries files =
    files
        |> Dict.toList
        |> List.filter (\( path, _ ) -> path /= manifestPath && path /= provenancePath)


checkAgainstManifest : FileEntry -> Dict String Int -> List ( String, FileEntry ) -> List VendorError
checkAgainstManifest manifestEntry manifestLens vendored =
    let
        vendoredPaths : List String
        vendoredPaths =
            List.map Tuple.first vendored

        driftErrors : List VendorError
        driftErrors =
            vendored
                |> List.filterMap
                    (\( path, entry ) ->
                        case Dict.get path manifestLens of
                            Nothing ->
                                Just (addedError path entry)

                            Just len ->
                                if String.length entry.content /= len then
                                    Just (editedError path entry)

                                else
                                    Nothing
                    )

        missingErrors : List VendorError
        missingErrors =
            manifestLens
                |> Dict.keys
                |> List.filter (\path -> not (List.member path vendoredPaths))
                |> List.map (missingError manifestEntry)
    in
    driftErrors ++ missingErrors



-- ERRORS


addedError : String -> FileEntry -> VendorError
addedError path entry =
    let
        ( range, _ ) =
            firstLineRange entry.content
    in
    Rule.errorForExtraFile entry.fileKey
        { message = "Vendored M3e file is not in the manifest: " ++ path
        , details =
            [ "This file under vendor/ is not recorded in " ++ manifestPath ++ ", so it was added by hand."
            , "The vendor/ tree is a committed copy of unpublished elm-cem-workspace source; only scripts/revendor-m3e.mjs may write it. Run: node scripts/revendor-m3e.mjs --commit <sha> — never hand-edit vendor/."
            ]
        }
        range


editedError : String -> FileEntry -> VendorError
editedError path entry =
    let
        ( range, _ ) =
            firstLineRange entry.content
    in
    Rule.errorForExtraFile entry.fileKey
        { message = "Vendored M3e file has been hand-edited: " ++ path
        , details =
            [ "This vendored file's content no longer matches the length recorded in " ++ manifestPath ++ ", so it was edited by hand."
            , "Run: node scripts/revendor-m3e.mjs --commit <sha> to restore it from canonical — never hand-edit vendor/. (Byte-exact drift is also enforced by the check:vendor gate.)"
            ]
        }
        range


missingError : FileEntry -> String -> VendorError
missingError manifestEntry path =
    let
        ( range, _ ) =
            substringRange manifestEntry.content ("\"" ++ path ++ "\"")
    in
    Rule.errorForExtraFile manifestEntry.fileKey
        { message = "Vendored M3e file is missing (listed in the manifest but absent): " ++ path
        , details =
            [ manifestPath ++ " records " ++ path ++ ", but that file is not present under vendor/ — it was deleted by hand."
            , "Run: node scripts/revendor-m3e.mjs --commit <sha> to restore the full vendored tree — never hand-edit vendor/."
            ]
        }
        range


missingManifestError : FileEntry -> VendorError
missingManifestError entry =
    let
        ( range, _ ) =
            firstLineRange entry.content
    in
    Rule.errorForExtraFile entry.fileKey
        { message = "vendor/ has files but no " ++ manifestPath
        , details =
            [ "There are files under vendor/ but no " ++ manifestPath ++ " recording them, so drift cannot be verified."
            , "Run: node scripts/revendor-m3e.mjs --commit <sha> to (re)generate the manifest, or remove the stray vendor/ files."
            ]
        }
        range


badManifestError : FileEntry -> String -> VendorError
badManifestError manifestEntry decodeError =
    let
        ( range, _ ) =
            firstLineRange manifestEntry.content
    in
    Rule.errorForExtraFile manifestEntry.fileKey
        { message = manifestPath ++ " is malformed"
        , details =
            [ "Could not read the vendor manifest: " ++ decodeError
            , "Regenerate it with: node scripts/revendor-m3e.mjs --commit <sha>."
            ]
        }
        range



-- RANGES


{-| A range covering the first line of `content`, plus that line as the `under`
string. Used to anchor an error on a present file.
-}
firstLineRange : String -> ( Range, String )
firstLineRange content =
    let
        firstLine : String
        firstLine =
            content |> String.lines |> List.head |> Maybe.withDefault ""
    in
    ( { start = { row = 1, column = 1 }
      , end = { row = 1, column = String.length firstLine + 1 }
      }
    , firstLine
    )


{-| A range covering the first occurrence of `needle` (assumed single-line) in
`content`, plus `needle` as the `under` string. Falls back to the first line when
the needle is absent. Used to point at a manifest entry for a missing file.
-}
substringRange : String -> String -> ( Range, String )
substringRange content needle =
    case List.head (String.indexes needle content) of
        Nothing ->
            firstLineRange content

        Just idx ->
            let
                before : String
                before =
                    String.left idx content

                linesBefore : List String
                linesBefore =
                    String.lines before

                row : Int
                row =
                    List.length linesBefore

                startColumn : Int
                startColumn =
                    (linesBefore |> List.reverse |> List.head |> Maybe.withDefault "" |> String.length) + 1
            in
            ( { start = { row = row, column = startColumn }
              , end = { row = row, column = startColumn + String.length needle }
              }
            , needle
            )
