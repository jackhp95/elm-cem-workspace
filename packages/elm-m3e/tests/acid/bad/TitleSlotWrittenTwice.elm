module TitleSlotWrittenTwice exposing (broken)

{-| NEGATIVE probe — the pipe-builder's write-once capability row.

A singular named slot is spent when it is written:

    withTitle :
        Element TitleSlot admittedBy msg
        -> Builder attrCaps { s | title : Available } msg
        -> Builder attrCaps { s | title : Used } msg

`M3e.Component.AppBar.build` seeds `SlotCaps` with every capability `Available`. The
first `withTitle` flips `title` to `Used`; the second demands `Available`
again, so this MUST FAIL — `<m3e-app-bar>` has one title slot and the type
says so.

Both children are legal `TitleSlot` values, so the only thing wrong here is
writing the slot twice. `app/Good.elm` writes `title` exactly once, alongside
`subtitle` and `leadingIcon`, and compiles.

Contrast `withTrailing`, which appends into the child list and is deliberately
repeatable — `app/Good.elm` calls it three times.

-}

import M3e
import M3e.Component.AppBar


broken : M3e.Element (M3e.Component.AppBar.Is s) admittedBy msg
broken =
    M3e.Component.AppBar.build
        |> M3e.Component.AppBar.withTitle (M3e.heading [] [ M3e.text "Inbox" ])
        |> M3e.Component.AppBar.withTitle (M3e.heading [] [ M3e.text "Drafts" ])
        |> M3e.Component.AppBar.toElement
