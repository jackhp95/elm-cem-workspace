module Sample.Support exposing
    ( Msg(..)
    , Toast
    , appBody
    , children
    , confirmButtons
    , href
    , model
    , on
    , rows
    )

{-| The context a guide sample assumes but does not show.

Guide samples are *fragments*. They read as if they sit inside an application
that already has a `model`, a `Msg` type, and some sibling elements — because
that is how a reader will meet them. This module supplies exactly those names so
each fragment can be compiled verbatim, without editing the sample into something
the guide does not actually display.

**These stubs are deliberately polymorphic** (that is what `M3e.Unsafe.recast`
is doing below — erasing the row so the stub satisfies whatever row a sample's
real call needs). That is a known, bounded weakening: a stub can never *prove* a
kind is admitted, it only declines to disprove it. Everything the sample itself
writes — every module, function, attribute setter, slot and enum token — is
still checked for real. Keep the stub set small and boring; if a sample needs a
*specific* type to be meaningful, write that value in the sample.

-}

import M3e exposing (Element)
import M3e.Component.Theme
import M3e.Unsafe
import M3e.Values as Value exposing (Value)


{-| The application message type a sample's event handlers produce.
-}
type Msg
    = Save
    | SaveClicked
    | CloseDialog


{-| A toast the application decided to announce (see `/guide/motion`).
-}
type alias Toast =
    { message : String }


{-| The application model a sample reads its theme/dialog inputs from.
-}
type alias Model =
    { seed : String
    , brandSeed : String
    , scheme : Value M3e.Component.Theme.Scheme
    , contrast : Value M3e.Component.Theme.Contrast
    , density : Float
    , dark : Bool
    , dialogOpen : Bool
    }


{-| -}
model : Model
model =
    { seed = "#4285F4"
    , brandSeed = "#6750A4"
    , scheme = Value.light
    , contrast = Value.standard
    , density = 0
    , dark = False
    , dialogOpen = True
    }


{-| The rest of the application, wrapped by a sample that themes it.
-}
appBody : Element accepts admittedBy msg
appBody =
    M3e.Unsafe.recast (M3e.text "…the rest of your app…")


{-| Children a sample's container is given from elsewhere.
-}
children : List (Element accepts admittedBy msg)
children =
    M3e.Unsafe.recastAll [ M3e.text "…" ]


{-| Rows a sample's surface is given from elsewhere.
-}
rows : List (Element accepts admittedBy msg)
rows =
    M3e.Unsafe.recastAll [ M3e.text "…" ]


{-| The buttons a sample's dialog puts in its actions slot.
-}
confirmButtons : Element accepts admittedBy msg
confirmButtons =
    M3e.Unsafe.recast (M3e.text "Delete")


{-| A boolean the application already holds (a switch's checked state).
-}
on : Bool
on =
    True


{-| A URL the application already holds.
-}
href : String
href =
    "/guide/theming"
