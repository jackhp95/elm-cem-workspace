module Route.GettingStarted.Installation exposing (ActionData, Data, Model, Msg, route)

import BackendTask
import Doc exposing (Lang(..), codeBlock, message)
import Head
import Head.Seo as Seo
import M3e exposing (Element)
import M3e.Attributes
import M3e.Kind
import M3e.Values as Value
import MimeType
import Pages.Url
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import TypedHtml
import TypedHtml.Attributes as TA
import UrlPath
import View exposing (View)


type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    {}


type alias ActionData =
    {}


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single { head = head, data = BackendTask.succeed {} }
        |> RouteBuilder.buildNoState { view = view }


head : App Data ActionData RouteParams -> List Head.Tag
head _ =
    Seo.summary
        { canonicalUrlOverride = Nothing
        , siteName = "elm-m3e"
        , image =
            { url = [ "og-card.png" ] |> UrlPath.join |> Pages.Url.fromPath
            , alt = "elm-m3e"
            , dimensions = Just { width = 1200, height = 630 }
            , mimeType = Just (MimeType.Image MimeType.Png)
            }
        , description = "Install elm-m3e and register the @m3e/web custom elements."
        , locale = Nothing
        , title = "Installation · elm-m3e"
        }
        |> Seo.website


pageHeading : Element { s | heading : M3e.Kind.Brand } adm_ msg
pageHeading =
    M3e.heading
        [ M3e.Attributes.variant Value.display, M3e.Attributes.size Value.small, M3e.Attributes.level 1 ]
        [ M3e.text "Installation" ]


stepHeading : String -> Element { s | heading : M3e.Kind.Brand } adm_ msg
stepHeading label =
    M3e.heading
        [ M3e.Attributes.variant Value.headline, M3e.Attributes.size Value.small, M3e.Attributes.level 2 ]
        [ M3e.text label ]


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view _ _ =
    View.fromElement "Installation"
        (Doc.pane
            [ TypedHtml.section [ TA.class "space-y-3" ]
                [ pageHeading
                , TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                    [ M3e.text "elm-m3e ships in two parts. The brand primitives — the shared vocabulary and escape hatches (M3e.Attributes, M3e.Values, M3e.Events, M3e.Html, and friends) — publish to the Elm package registry as jackhp95/elm-m3e. The 128 typed components (M3e.Button, M3e.Card, M3e.Theme, … and the M3e barrel) are NOT published; you generate them into your project with elm-cem's eject command. Follow the four steps below and you will have a themed button rendering in the browser." ]
                , message "Prerequisites: Elm 0.19.1, Node 18+ (eject runs via npx/pnpm dlx), and a bundler that can serve ES modules (Vite, esbuild, Parcel, or Webpack). The steps below assume Vite, but any bundler that runs npm packages and lets you inject a <script> tag will work."
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ stepHeading "1. Install the primitives and eject the components"
                , TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                    [ M3e.text "Install the published primitives from the Elm registry. This gives you the primitive modules — M3e.Attributes, M3e.Values, M3e.Events, the escape hatches, and M3e.Html (the loose, open-rowed component producers):" ]
                , codeBlock Shell """
elm install jackhp95/elm-m3e
"""
                , TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                    [ M3e.text "To get the full typed component surface (M3e.Button, M3e.Card, M3e.Theme, … and the M3e barrel), run elm-cem's eject command. It pulls the pre-generated M3e.* modules into a vendor folder, adds that folder to source-directories in your elm.json, and promotes the dependencies the generated code imports. eject also removes the jackhp95/elm-m3e registry dependency — the vendored superset already contains those primitive modules, so there is no collision:" ]
                , codeBlock Shell """
npx elm-cem eject m3e --elm-json=elm.json --write
"""
                , TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                    [ M3e.text "eject defaults to a dry run that prints its plan and writes nothing; pass --write to apply it. The vendored M3e.* modules are a build artifact — re-run eject to update them rather than editing them by hand. Add --with-review to also wire up the elm-review-cem lint rules." ]
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ stepHeading "2. Register the web components"
                , TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                    [ M3e.text "The Elm modules emit <m3e-*> custom elements; they only render once the @m3e/web element definitions are registered. Install the package and import it once, before your Elm app boots:" ]
                , codeBlock Shell """
npm i @m3e/web
"""
                , codeBlock NoLang """
// m3e-entry.js — import once, before Elm.Main.init runs
import "@m3e/web/all";
"""
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ stepHeading "3. Add the token + utility CSS bridge"
                , TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                    [ M3e.text "tailwind-m3e-web maps the M3 design tokens to Tailwind v4 utilities (bg-surface, text-body-lg, rounded-md-corner-large, …). It is NOT published to npm — it is a private repository, vendored here as CSS only. There is no @import from a package name; you must vendor the CSS files into your project first." ]
                , TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                    [ M3e.text "If you have access to the private repo, clone it and copy its CSS into your project; otherwise copy the vendored copy from this repo (docs/vendor/tailwind-m3e-web):" ]
                , codeBlock Shell """
# Option A — from the private source repo (requires access)
git clone https://github.com/jackhp95/tailwind-m3e-web.git
cp -R tailwind-m3e-web/src        your-project/vendor/tailwind-m3e-web/src
cp -R tailwind-m3e-web/generated  your-project/vendor/tailwind-m3e-web/generated

# Option B — from the copy vendored inside this repo
cp -R elm-m3e/docs/vendor/tailwind-m3e-web your-project/vendor/tailwind-m3e-web
"""
                , TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                    [ M3e.text "Then reference the vendored files by relative path from your stylesheet:" ]
                , codeBlock NoLang """
/* style.css — paths are relative to your vendored copy */
@import "tailwindcss";
@import "./vendor/tailwind-m3e-web/src/index.css";
@import "./vendor/tailwind-m3e-web/generated/utilities.css";
"""
                ]
            , TypedHtml.section [ TA.class "space-y-3" ]
                [ stepHeading "4. Wrap your app in a theme and render"
                , TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                    [ M3e.text "M3e.Theme is an attribute-style element (not a builder): M3e.Component.Theme.view takes a list of attributes — color, scheme, contrast, density, variant, motion — and a list of child elements. It owns the dynamic color for its subtree, usually the whole app. Here is a complete Main.elm that renders a themed button:" ]
                , codeBlock Elm mainModule
                , TypedHtml.p [ TA.class "text-body-lg text-on-surface-variant" ]
                    [ M3e.text "M3e.toHtml turns an M3e Element into elm/html, so Browser.sandbox can render it. Finally, an index.html loads the CSS, registers the components, and boots Elm:" ]
                , codeBlock Xml """
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="/style.css" />
  </head>
  <body>
    <div id="app"></div>
    <!-- register the <m3e-*> elements first -->
    <script type="module" src="/m3e-entry.js"></script>
    <!-- then boot Elm (compiled from Main.elm) -->
    <script type="module">
      import { Elm } from "/main.js";
      Elm.Main.init({ node: document.getElementById("app") });
    </script>
  </body>
</html>
"""
                ]
            ]
        )



-- @sample expect-review NoRedundantElementEscape: `Browser.sandbox` requires
-- `Html`, so the app root has to leave the typed tree exactly once. That is the
-- same documented exemption `app/Shared.elm` carries in the docs review config —
-- recorded here rather than hidden, so a SECOND toHtml would still be caught.


mainModule : String
mainModule =
    """module Main exposing (main)

import Browser
import Html
import M3e
import M3e.Component.Button as Button
import M3e.Component.Theme as Theme
import M3e.Values as Value


main : Program () () ()
main =
    Browser.sandbox { init = (), update = \\_ model -> model, view = view }


view : () -> Html.Html ()
view _ =
    M3e.toHtml
        (Theme.view
            [ Theme.color "#6750A4"
            , Theme.scheme Value.auto
            ]
            [ Button.view
                [ Button.variant Value.filled ]
                [ M3e.text "It works" ]
            ]
        )"""
