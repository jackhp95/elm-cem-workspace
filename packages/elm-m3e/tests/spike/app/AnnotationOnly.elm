module AnnotationOnly exposing (buttonList)

{-| Slim-import property: a module importing only `M3e.Build` (the annotation
skin, not the component or its builder module) names a component's phantom type
for an annotation.

No `M3e.Button`, `M3e.Button.Build`, or `M3e.Icon.Build` — only the slim
aliases from `M3e.Build`.

-}

import HtmlIr.Element exposing (Element)
import M3e.Build exposing (ButtonIs)


buttonList : List (Element (ButtonIs s) admittedBy msg)
buttonList =
    []