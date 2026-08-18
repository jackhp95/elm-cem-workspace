module Theme exposing (Model, Msg(..), TypeScaleParam(..), capitalize, controlLabel, init, schemeToggle, segmented, subscriptions, update, variantSelect, view)

import Dict exposing (Dict)
import HtmlIr.Element
import HtmlIr.Kind
import Json.Decode as Decode
import M3e exposing (Element)
import M3e.Attributes
import M3e.Component.Button
import M3e.Component.Icon
import M3e.Component.MenuItem
import M3e.Component.MenuTrigger
import M3e.Component.Theme
import M3e.Events
import M3e.Kind
import M3e.Values as Value exposing (Value)
import Theme.Fonts
import Theme.Icons exposing (IconStyle)
import Theme.Ports
import Theme.Presets exposing (Preset)
import Theme.Reel
import Theme.Scale as Scale exposing (ScaleConfig, ScaleMode)
import Theme.Tokens
import TypedHtml
import TypedHtml.Aria as Aria
import TypedHtml.Attributes
import TypedHtml.Component.Grouping
import TypedHtml.Events
import TypedHtml.Values


type alias Model =
    { scheme : Value Value.Scheme
    , seed : String
    , contrast : Value Value.Contrast
    , variant : Value M3e.Component.Theme.Variant
    , density : Float
    , motion : Value Value.Motion
    , displayFont : String
    , bodyFont : String
    , iconStyle : IconStyle
    , typeScale : ScaleConfig
    , shapeScale : ScaleConfig
    , colorOverrides : Dict String String
    , cssOverrides : Dict String String
    , activePresetId : Maybe String
    }


init : Model
init =
    { scheme = Value.auto
    , seed = "#6750A4"
    , contrast = Value.standard
    , variant = Value.neutral
    , density = 0
    , motion = Value.standard
    , displayFont = "Roboto"
    , bodyFont = "Roboto"
    , iconStyle = Theme.Icons.defaultStyle
    , typeScale = Scale.defaultConfig
    , shapeScale = Scale.defaultConfig
    , colorOverrides = Dict.empty
    , cssOverrides = Dict.empty

    -- The stock state IS the "Default" preset (`Theme.Presets`): every field
    -- above equals that preset's, so the Default card reads as active out of the
    -- box. `ResetAll` restores `init`, so it re-selects Default too. Any manual
    -- theme edit (`SetSeed`, `SetScheme`, …) clears this back to `Nothing`.
    , activePresetId = Just "default"
    }


{-| `Msg(..)` is exposed (constructors, not opaque) because sibling
`Theme.Sections.*` modules (later tasks) need to construct these directly —
they're all in the same package, not external consumers, so this is a
deliberate, scoped exception to the usual Elm Model/Msg/update encapsulation
convention.
-}
type Msg
    = SetScheme (Value Value.Scheme)
    | SetSeed String
    | SetContrast (Value Value.Contrast)
    | SetVariant (Value M3e.Component.Theme.Variant)
    | SetDensity Float
    | SetMotion (Value Value.Motion)
    | SetDisplayFont String
    | SetBodyFont String
    | SetTypeScaleMode ScaleMode
    | SetTypeScaleParam TypeScaleParam Float
    | SetShapeScaleMode ScaleMode
    | SetShapeScaleParam TypeScaleParam Float
    | SetColorOverride String String
    | ResetColorOverride String
    | SetCssOverride String String
    | UnsetCssOverride String
    | ApplyPreset Preset
    | ThemeStateLoaded Decode.Value
    | ResetAll


{-| Shared between type-scale and shape-scale param updates — both
`ScaleConfig`s expose the same 5 tunable fields.
-}
type TypeScaleParam
    = Factor
    | Ratio
    | Base
    | Bump
    | Exponent


setScaleParam : TypeScaleParam -> Float -> ScaleConfig -> ScaleConfig
setScaleParam param value config =
    case param of
        Factor ->
            { config | factor = value }

        Ratio ->
            { config | ratio = value }

        Base ->
            { config | base = value }

        Bump ->
            { config | bump = value }

        Exponent ->
            { config | exponent = value }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetScheme scheme ->
            persist { model | scheme = scheme, activePresetId = Nothing }

        SetSeed seed ->
            persist { model | seed = seed, activePresetId = Nothing }
                |> andSetFavicon seed

        SetContrast contrast ->
            persist { model | contrast = contrast, activePresetId = Nothing }

        SetVariant v ->
            persist { model | variant = v, activePresetId = Nothing }

        SetDensity density ->
            persist { model | density = density }

        SetMotion motion ->
            persist { model | motion = motion }

        SetDisplayFont font ->
            let
                newModel : Model
                newModel =
                    { model | displayFont = font, activePresetId = Nothing }
            in
            persist newModel |> andThen (fontCmds newModel)

        SetBodyFont font ->
            let
                newModel : Model
                newModel =
                    { model | bodyFont = font, activePresetId = Nothing }
            in
            persist newModel |> andThen (fontCmds newModel)

        SetTypeScaleMode mode ->
            let
                newModel : Model
                newModel =
                    { model | typeScale = setScaleMode mode model.typeScale }
            in
            persist newModel |> andPushTypeScale newModel

        SetTypeScaleParam param value ->
            let
                newModel : Model
                newModel =
                    { model | typeScale = setScaleParam param value model.typeScale }
            in
            persist newModel |> andPushTypeScale newModel

        SetShapeScaleMode mode ->
            let
                newModel : Model
                newModel =
                    { model | shapeScale = setScaleMode mode model.shapeScale }
            in
            persist newModel |> andPushShapeScale newModel

        SetShapeScaleParam param value ->
            let
                newModel : Model
                newModel =
                    { model | shapeScale = setScaleParam param value model.shapeScale }
            in
            persist newModel |> andPushShapeScale newModel

        SetColorOverride cssVar value ->
            persist { model | colorOverrides = Dict.insert cssVar value model.colorOverrides }
                |> andThen (Theme.Ports.setCssOverride { property = cssVar, value = value })

        ResetColorOverride cssVar ->
            persist { model | colorOverrides = Dict.remove cssVar model.colorOverrides }
                |> andThen (Theme.Ports.setCssOverride { property = cssVar, value = "" })

        SetCssOverride cssVar value ->
            persist { model | cssOverrides = Dict.insert cssVar value model.cssOverrides }
                |> andThen (Theme.Ports.setCssOverride { property = cssVar, value = value })

        -- Revert one raw CSS custom property to the stylesheet default: drop it
        -- from the persisted overrides AND send `value = ""`, which `index.ts`
        -- turns into `style.removeProperty` (setting it to a literal empty string
        -- would leave the inline declaration in place, shadowing the default).
        UnsetCssOverride cssVar ->
            persist { model | cssOverrides = Dict.remove cssVar model.cssOverrides }
                |> andThen (Theme.Ports.setCssOverride { property = cssVar, value = "" })

        ApplyPreset preset ->
            let
                newModel : Model
                newModel =
                    applyPresetToModel preset model
            in
            ( newModel
            , Cmd.batch
                (Theme.Ports.setFaviconColor preset.seedColor
                    :: (preset.cssOverrides
                            |> List.map (\( k, v ) -> Theme.Ports.setCssOverride { property = k, value = v })
                       )
                    ++ [ storeState newModel
                       , fontCmds newModel
                       , setIconVariantCmd newModel
                       ]
                )
            )

        ThemeStateLoaded value ->
            case Decode.decodeValue Theme.Ports.decoder value of
                Ok decoded ->
                    let
                        loaded : Model
                        loaded =
                            fromPersisted decoded
                    in
                    ( loaded
                    , Cmd.batch
                        (pushTypeScaleCmds loaded
                            ++ pushShapeScaleCmds loaded
                            ++ pushOverrideCmds loaded
                            ++ [ fontCmds loaded
                               , setIconVariantCmd loaded
                               , specimenFontsCmd
                               ]
                        )
                    )

                Err _ ->
                    -- Even with no persisted state, boot still needs to apply the
                    -- default font vars and load the reel's specimen fonts (the
                    -- reliable seam past the init-port race).
                    ( model, Cmd.batch [ fontCmds model, specimenFontsCmd ] )

        ResetAll ->
            persist init
                |> andThen
                    (Cmd.batch
                        (List.map (\( k, _ ) -> Theme.Ports.setCssOverride { property = k, value = "" })
                            (Dict.toList model.colorOverrides ++ Dict.toList model.cssOverrides)
                        )
                    )


{-| Apply a preset's fields to the model — the single, pure source of truth for
preset application. Both `ApplyPreset` (direct) and the `onPresetRequested` port
bridge in `Shared.elm` resolve to this function, ensuring they stay in sync.
-}
applyPresetToModel : Preset -> Model -> Model
applyPresetToModel preset model =
    { model
        | scheme = preset.scheme
        , seed = preset.seedColor
        , contrast = preset.contrast
        , displayFont = preset.displayFont
        , bodyFont = preset.bodyFont
        , iconStyle = preset.iconStyle
        , colorOverrides = Dict.fromList preset.cssOverrides
        , cssOverrides = Dict.empty
        , activePresetId = Just preset.id
    }


{-| Fire the `loadFonts` port for a display + body font pair. Takes just the two
font names (not a whole `Preset`) so both `ApplyPreset` (from a preset) and
`ThemeStateLoaded` (from the restored model, which has no preset) can share it.
-}
loadFontCmd : { displayFont : String, bodyFont : String } -> Cmd Msg
loadFontCmd fonts =
    case Theme.Fonts.googleFontsUrl [ fonts.displayFont, fonts.bodyFont ] of
        Just url ->
            Theme.Ports.loadFonts url

        Nothing ->
            Cmd.none


{-| The display/body font pair carried by a model, in the shape `loadFontCmd`
expects.
-}
fontsOf : Model -> { displayFont : String, bodyFont : String }
fontsOf model =
    { displayFont = model.displayFont, bodyFont = model.bodyFont }


{-| Push the two app font custom properties (`--app-font-display` /
`--app-font-body`) so the theme's fonts actually APPLY globally. `style.css`'s
`body` and `m3e-heading` rules read these vars; `@m3e/web` has no font-family
design token, so this var + the CSS cascade is the mechanism by which selecting
a theme changes the whole app's fonts. `setCssOverride` prepends `--`, so the
property names here are unprefixed. This was the missing "last mile" behind the
"fonts don't change on select" bug.
-}
pushFontVarsCmds : Model -> List (Cmd Msg)
pushFontVarsCmds model =
    [ Theme.Ports.setCssOverride
        { property = "app-font-display", value = Theme.Fonts.fontStack model.displayFont }
    , Theme.Ports.setCssOverride
        { property = "app-font-body", value = Theme.Fonts.fontStack model.bodyFont }
    ]


{-| Everything needed to make a model's fonts live: fetch the webfont files
(`loadFonts`) AND apply them globally (`--app-font-*` vars). Both `ApplyPreset`
and the manual font setters use this so the two never drift.
-}
fontCmds : Model -> Cmd Msg
fontCmds model =
    Cmd.batch (loadFontCmd (fontsOf model) :: pushFontVarsCmds model)


{-| Load every reel card's specimen-subset webfont (§D6) so each card renders in
its own display + body font instead of falling back to sans-serif. Fired from
`ThemeStateLoaded` (which `index.ts` triggers AFTER the ports are subscribed) —
`Shared.init`'s one-shot send races the port subscription and is dropped, so
this is the reliable seam. `index.ts` dedupes by href, so re-sending is safe.
-}
specimenFontsCmd : Cmd Msg
specimenFontsCmd =
    Theme.Ports.loadSpecimenFonts (Theme.Fonts.specimenSubsetUrls Theme.Presets.presets)


{-| Fire the `setIconVariant` port with the model's active icon style, switching
every `<m3e-icon>` in the app to that Material Symbols optical variant (§D4).
-}
setIconVariantCmd : Model -> Cmd Msg
setIconVariantCmd model =
    Theme.Ports.setIconVariant (Theme.Icons.toString model.iconStyle)


persist : Model -> ( Model, Cmd Msg )
persist model =
    ( model, storeState model )


storeState : Model -> Cmd Msg
storeState model =
    Theme.Ports.storeThemeState
        (Theme.Ports.encode
            { scheme = Value.toString model.scheme
            , seed = model.seed
            , contrast = Value.toString model.contrast
            , variant = Value.toString model.variant
            , density = model.density
            , motion = Value.toString model.motion
            , displayFont = model.displayFont
            , bodyFont = model.bodyFont
            , iconStyle = Theme.Icons.toString model.iconStyle
            , typeScaleMode = Scale.modeToString model.typeScale.mode
            , typeScaleFactor = model.typeScale.factor
            , typeScaleRatio = model.typeScale.ratio
            , typeScaleBase = model.typeScale.base
            , typeScaleBump = model.typeScale.bump
            , typeScaleExponent = model.typeScale.exponent
            , shapeScaleMode = Scale.modeToString model.shapeScale.mode
            , shapeScaleFactor = model.shapeScale.factor
            , shapeScaleRatio = model.shapeScale.ratio
            , shapeScaleBase = model.shapeScale.base
            , shapeScaleBump = model.shapeScale.bump
            , shapeScaleExponent = model.shapeScale.exponent
            , colorOverrides = Dict.toList model.colorOverrides
            , cssOverrides = Dict.toList model.cssOverrides
            , activePresetId = model.activePresetId
            }
        )


andThen : Cmd Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andThen extraCmd ( model, cmd ) =
    ( model, Cmd.batch [ cmd, extraCmd ] )


andSetFavicon : String -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andSetFavicon seed =
    andThen (Theme.Ports.setFaviconColor seed)


setScaleMode : ScaleMode -> ScaleConfig -> ScaleConfig
setScaleMode mode config =
    { config | mode = mode }


pushTypeScaleCmds : Model -> List (Cmd Msg)
pushTypeScaleCmds model =
    Theme.Tokens.typescaleTokens
        |> List.map
            (\token ->
                Theme.Ports.setCssOverride
                    { property = token.cssVar
                    , value = String.fromFloat (Scale.compute model.typeScale token) ++ "rem"
                    }
            )


pushShapeScaleCmds : Model -> List (Cmd Msg)
pushShapeScaleCmds model =
    Theme.Tokens.shapeTokens
        |> List.map
            (\token ->
                Theme.Ports.setCssOverride
                    { property = token.cssVar
                    , value = String.fromFloat (Scale.compute model.shapeScale token) ++ "rem"
                    }
            )


pushOverrideCmds : Model -> List (Cmd Msg)
pushOverrideCmds model =
    (Dict.toList model.colorOverrides ++ Dict.toList model.cssOverrides)
        |> List.map (\( k, v ) -> Theme.Ports.setCssOverride { property = k, value = v })


andPushTypeScale : Model -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andPushTypeScale model ( m, cmd ) =
    ( m, Cmd.batch (cmd :: pushTypeScaleCmds model) )


andPushShapeScale : Model -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andPushShapeScale model ( m, cmd ) =
    ( m, Cmd.batch (cmd :: pushShapeScaleCmds model) )


fromPersisted :
    { scheme : String
    , seed : String
    , contrast : String
    , variant : String
    , density : Float
    , motion : String
    , displayFont : String
    , bodyFont : String
    , iconStyle : String
    , typeScaleMode : String
    , typeScaleFactor : Float
    , typeScaleRatio : Float
    , typeScaleBase : Float
    , typeScaleBump : Float
    , typeScaleExponent : Float
    , shapeScaleMode : String
    , shapeScaleFactor : Float
    , shapeScaleRatio : Float
    , shapeScaleBase : Float
    , shapeScaleBump : Float
    , shapeScaleExponent : Float
    , colorOverrides : List ( String, String )
    , cssOverrides : List ( String, String )
    , activePresetId : Maybe String
    }
    -> Model
fromPersisted decoded =
    { scheme = Value.schemeFromString decoded.scheme |> Maybe.withDefault Value.auto
    , seed = decoded.seed
    , contrast = Value.contrastFromString decoded.contrast |> Maybe.withDefault Value.standard
    , variant = themeVariantFromString decoded.variant
    , density = decoded.density
    , motion = Value.motionFromString decoded.motion |> Maybe.withDefault Value.standard
    , displayFont = decoded.displayFont
    , bodyFont = decoded.bodyFont
    , iconStyle = Theme.Icons.fromString decoded.iconStyle
    , typeScale =
        { mode = Scale.modeFromString decoded.typeScaleMode |> Maybe.withDefault Scale.Linear
        , factor = decoded.typeScaleFactor
        , ratio = decoded.typeScaleRatio
        , base = decoded.typeScaleBase
        , bump = decoded.typeScaleBump
        , exponent = decoded.typeScaleExponent
        }
    , shapeScale =
        { mode = Scale.modeFromString decoded.shapeScaleMode |> Maybe.withDefault Scale.Linear
        , factor = decoded.shapeScaleFactor
        , ratio = decoded.shapeScaleRatio
        , base = decoded.shapeScaleBase
        , bump = decoded.shapeScaleBump
        , exponent = decoded.shapeScaleExponent
        }
    , colorOverrides = Dict.fromList decoded.colorOverrides
    , cssOverrides = Dict.fromList decoded.cssOverrides
    , activePresetId = decoded.activePresetId
    }


subscriptions : Sub Msg
subscriptions =
    Theme.Ports.readThemeState ThemeStateLoaded


{-| One segmented-button control: `SegmentedButton` holding `ButtonSegment`
children, each a checked/label/onClick triple. Ported from `Shared.elm` —
exposed here because `Theme.Sections.*` (later tasks) need it for the
Contrast/Motion segmented controls too.
-}
segmented : List ( String, Bool, Msg ) -> Element { s | segmentedButton : M3e.Kind.Brand } admittedBy Msg
segmented segments =
    M3e.segmentedButton []
        (List.map
            (\( lbl, isChecked, msg ) ->
                M3e.buttonSegment
                    [ M3e.Attributes.checked isChecked, M3e.Events.onClick msg ]
                    [ M3e.text lbl ]
            )
            segments
        )


{-| Upper-case the first character. Enum wire strings are lower-case; the
settings controls display them title-cased. Ported from `Shared.elm` —
exposed here because `Theme.Sections.*` (later tasks) need it too.
-}
capitalize : String -> String
capitalize s =
    case String.uncons s of
        Just ( c, rest ) ->
            String.cons (Char.toUpper c) rest

        Nothing ->
            s


{-| A small label heading above a control. Relocated here from `Shared.elm`: the
`Theme.Sections.*` modules cannot import `Shared` (it sits ABOVE `Theme` in the
import graph), so it lives alongside `segmented`/`capitalize` — the same
relocation pattern used when the drawer was split out. `msg`-polymorphic so both
`Theme` and `Shared` can render it under their own `Msg`.
-}
controlLabel : String -> Element { s | heading : M3e.Kind.Brand } admittedBy msg
controlLabel lbl =
    M3e.heading
        [ M3e.Attributes.variant Value.label
        , M3e.Attributes.size Value.large
        , TypedHtml.Attributes.class "text-on-surface"
        ]
        [ M3e.text lbl ]


{-| Scheme control: a single toggle icon button flipping Light ⇄ Dark (the same
shape as `Shared.directionToggle`), replacing the 3-option segmented control.
`auto` ("System") is no longer directly selectable here — it is reachable through
the control row's scoped reset. When `scheme == auto` the toggle reads as "not
dark" (shows `dark_mode`, i.e. click to go dark) without that being a `SetScheme`.

These controls compare tokens with `==`. A `Value` is opaque over a `String`, so
the comparison is on the underlying wire string — meaning tokens from DIFFERENT
enums that share a string would compare equal. Safe here because each control
only ever compares a field against its own enum's values.

-}
schemeToggle : Model -> Element { s | iconButton : M3e.Kind.Brand } admittedBy Msg
schemeToggle model =
    let
        isDark : Bool
        isDark =
            Value.toString model.scheme == "dark"

        ( next, glyph, lbl ) =
            if isDark then
                ( Value.light, "light_mode", "Switch to light theme" )

            else
                ( Value.dark, "dark_mode", "Switch to dark theme" )
    in
    M3e.iconButton
        [ TypedHtml.Events.onClick (SetScheme next)
        , Aria.label lbl
        , Aria.pressed
            (if isDark then
                Aria.true

             else
                Aria.false
            )
        ]
        [ M3e.icon [ M3e.Component.Icon.name glyph ] [] ]


{-| The 9 M3 dynamic-color variants valid on `m3e-theme`. Separated from the
broader `Value.variantValues` (which covers every component's variant enum,
not just theme's).
-}
themeVariantValues : List (Value M3e.Component.Theme.Variant)
themeVariantValues =
    [ Value.content
    , Value.expressive
    , Value.fidelity
    , Value.fruitSalad
    , Value.monochrome
    , Value.neutral
    , Value.rainbow
    , Value.tonalSpot
    , Value.vibrant
    ]


{-| Parse a persisted variant string back to a typed value. Falls back to
`neutral` (the element's own documented default) for unknown strings so old
blobs or typos don't silently break the decode.
-}
themeVariantFromString : String -> Value M3e.Component.Theme.Variant
themeVariantFromString s =
    case s of
        "content" ->
            Value.content

        "expressive" ->
            Value.expressive

        "fidelity" ->
            Value.fidelity

        "fruit-salad" ->
            Value.fruitSalad

        "monochrome" ->
            Value.monochrome

        "rainbow" ->
            Value.rainbow

        "tonal-spot" ->
            Value.tonalSpot

        "vibrant" ->
            Value.vibrant

        _ ->
            Value.neutral


{-| Editorial label for one theme variant. camelCase wire strings get
split into title case; everything else is just capitalized.
-}
variantLabelFor : Value M3e.Component.Theme.Variant -> String
variantLabelFor v =
    case Value.toString v of
        "fruit-salad" ->
            "Fruit Salad"

        "tonal-spot" ->
            "Tonal Spot"

        other ->
            capitalize other


{-| Variant picker: a button whose nested `m3e-menu-trigger` opens an anchored
`m3e-menu` of the 9 `themeVariantValues` (was a 9-option segmented button that
overflowed on every narrow screen). The anchor is `MenuTrigger.for` pointing at
the sibling menu's `id`; the menu itself carries no `for`/`open` attribute.
Selecting fires the existing `SetVariant` — no `Msg`/model change, only the
rendering swap.
-}
variantSelect : Model -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
variantSelect model =
    TypedHtml.div [ TypedHtml.Attributes.class "inline-block" ]
        [ M3e.button
            []
            [ M3e.menuTrigger
                [ M3e.Component.MenuTrigger.for variantMenuId ]
                [ M3e.text (variantLabelFor model.variant) ]
            , M3e.Component.Button.trailingIcon
                (M3e.icon [ M3e.Component.Icon.name "arrow_drop_down" ] [])
            ]
        , M3e.menu [ M3e.Attributes.id variantMenuId ]
            (List.map
                (\v ->
                    M3e.menuItem
                        [ M3e.Component.MenuItem.onClick (SetVariant v) ]
                        [ M3e.text (variantLabelFor v) ]
                )
                themeVariantValues
            )
        ]


{-| The one `id` the variant button's `menu-trigger` anchors to. A single
constant so the anchor and the menu can never drift apart.
-}
variantMenuId : String
variantMenuId =
    "theme-variant-menu"


{-| The drawer's color controls, all real m3e components: a row of blank
`m3e-avatar`s, one per curated seed color, each painted by its OWN nested
`<m3e-theme>` (seeded with that hex) so the swatch shows the color's live-derived
primary — never a hand-painted hex. Each swatch sets the avatar's
`--m3e-avatar-color` custom property to `var(--md-sys-color-primary)`, which
resolves against that swatch's nested theme. The first option is the
source-color picker (`sourceColorOption`). A small `m3e-heading` labels the row.
-}
colorOptions : Model -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
colorOptions model =
    TypedHtml.div [ TypedHtml.Attributes.class "flex flex-col gap-1.5" ]
        [ TypedHtml.div []
            [ M3e.heading
                [ M3e.Attributes.variant Value.label
                , M3e.Attributes.size Value.small
                , TypedHtml.Attributes.class "text-on-surface-variant"
                ]
                [ M3e.text "Source color" ]
            ]
        , -- One horizontally-scrolling, snap-aligned row instead of a wrapping
          -- block: the swatch strip is a browse-and-pick control, and wrapping it
          -- to four rows in a narrow drawer buries the reel and the sections
          -- below it. `py-2` gives the selected swatch's ring room to draw.
          TypedHtml.div [ TypedHtml.Attributes.class "flex snap-x snap-mandatory items-center gap-3 overflow-x-auto py-2" ]
            (sourceColorOption model :: List.map (colorAvatar model) curatedSwatchColors)
        ]


{-| The source-color picker = the first color option. A blank `m3e-avatar` (in a
nested `<m3e-theme>` seeded with the current color, so it mirrors the live seed)
carrying a `colorize` icon, with a transparent native `<input type=color>`
stretched over it — clicking anywhere opens the OS color picker and fires
`SetSeed`. The native input is the keyboard-accessible control.
-}
sourceColorOption : Model -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
sourceColorOption model =
    TypedHtml.div
        [ TypedHtml.Attributes.class "relative inline-flex rounded-full" ]
        [ TypedHtml.div []
            [ M3e.theme [ M3e.Component.Theme.color model.seed ]
                [ M3e.avatar
                    [ M3e.Attributes.class "m3e-avatar-size-[2rem]"
                    , M3e.Attributes.style "--m3e-avatar-color" "var(--md-sys-color-primary)"
                    , M3e.Attributes.style "--m3e-avatar-label-color" "var(--md-sys-color-on-primary)"
                    ]
                    [ M3e.icon [ M3e.Component.Icon.name "colorize", M3e.Attributes.class "text-base" ] [] ]
                ]
            ]
        , TypedHtml.div [ TypedHtml.Attributes.class "absolute inset-0" ]
            [ TypedHtml.input
                [ TypedHtml.Attributes.id "seed-color"
                , TypedHtml.Attributes.type_ "color"
                , TypedHtml.Attributes.value model.seed
                , TypedHtml.Events.onInput SetSeed
                , TypedHtml.Attributes.class "size-full opacity-0 cursor-pointer"
                , Aria.label "Source color"
                ]
                []
            ]
        ]


{-| One curated color swatch: a blank `m3e-avatar` whose background is the
color's derived primary (via a nested `<m3e-theme>` seeded with the hex). The
click target is a transparent, empty native `<button>` overlaid on top —
`onClick` is an interactive-element attribute (a `div` can't carry it), and an
empty button avoids threading a branded child through the button's
phrasing-content slot. The active swatch (matching the current seed) gets a
primary ring in the APP palette so the selected marker reads consistently
across hues.
-}
colorAvatar : Model -> String -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy Msg
colorAvatar model hex =
    TypedHtml.div
        [ TypedHtml.Attributes.class
            ("relative inline-flex rounded-full "
                ++ (if model.seed == hex then
                        -- `on-surface`, not `primary`: the ring is drawn in the
                        -- APP palette over a swatch whose own nested theme is a
                        -- different hue, and a primary ring can vanish against a
                        -- near-primary swatch.
                        "ring-2 ring-on-surface"

                    else
                        ""
                   )
            )
        ]
        [ TypedHtml.div []
            [ M3e.theme [ M3e.Component.Theme.color hex ]
                [ M3e.avatar
                    [ M3e.Attributes.class "m3e-avatar-size-[2rem]"
                    , M3e.Attributes.style "--m3e-avatar-color" "var(--md-sys-color-primary)"
                    ]
                    []
                ]
            ]
        , TypedHtml.div [ TypedHtml.Attributes.class "absolute inset-0" ]
            [ TypedHtml.button
                [ TypedHtml.Events.onClick (SetSeed hex)
                , Aria.label ("Set source color to " ++ hex)
                , TypedHtml.Attributes.class "size-full rounded-full cursor-pointer"
                ]
                []
            ]
        ]


{-| ~20 curated hex colors for the quick-picker, chosen for hue spread across
the Material color wheel. Visual reference: beercss.com's `#themes3` popover
(a compact 2-row grid of ~20 round swatches). Exact hex values are a
design/visual call — a reasonable starting set, not pixel-matched.
-}
curatedSwatchColors : List String
curatedSwatchColors =
    [ "#6750A4"
    , "#B3261E"
    , "#7D5260"
    , "#006A6A"
    , "#984061"
    , "#8C4A2F"
    , "#5C6BC0"
    , "#00897B"
    , "#43A047"
    , "#FB8C00"
    , "#D81B60"
    , "#5E35B1"
    , "#3949AB"
    , "#00ACC1"
    , "#7CB342"
    , "#FDD835"
    , "#F4511E"
    , "#6D4C41"
    , "#546E7A"
    , "#8E24AA"
    ]


{-| `sections` is threaded in rather than imported here because each
`Theme.Sections.*` module imports `Theme` (for `Model`/`Msg`, per the note on
`Msg` above) — if `Theme.elm` also imported the section modules to build
their views itself, that would be an unresolvable Elm import cycle (Elm, unlike
some languages, rejects module cycles outright; there is no forward-declaration
escape hatch). The caller (the app-level `Shared.elm`, wired in the NEXT task)
sits above both `Theme` and `Theme.Sections.*` in the import graph, so it is
the natural place to call each section's `view model` and hand the results in
here.
-}
view :
    { dir : TypedHtml.Values.Value TypedHtml.Values.Dir
    , onSetDirection : TypedHtml.Values.Value TypedHtml.Values.Dir -> msg
    , sectionsEl : Element { cs | formField : M3e.Kind.Brand, segmentedButton : M3e.Kind.Brand, sharedFlow : HtmlIr.Kind.Shared, button : M3e.Kind.Brand } (TypedHtml.Component.Grouping.DivChildAdmittedBy sectionAdm) msg
    }
    -> Model
    -> (Msg -> msg)
    -> Element (TypedHtml.Component.Grouping.DivIs s) admittedBy msg
view { sectionsEl } model toMsg =
    TypedHtml.div
        [ TypedHtml.Attributes.class "flex flex-col gap-2 py-4"
        ]
        [ -- Scheme and variant no longer render here: they moved into
          -- `Shared.controlRow`, pinned at the top of the settings sheet with
          -- direction and the scoped reset, so the three "what does the whole app
          -- look like" knobs sit together above the per-topic accordion.
          colorOptions model |> HtmlIr.Element.map toMsg
        , Theme.Reel.view
            { presets = Theme.Presets.presets
            , activeId = model.activePresetId
            , onPick = \preset -> toMsg (ApplyPreset preset)
            }
        , sectionsEl
        , resetAllButton |> HtmlIr.Element.map toMsg
        ]


resetAllButton : Element (M3e.Component.Button.Is s) admittedBy Msg
resetAllButton =
    M3e.button
        [ TypedHtml.Events.onClick ResetAll ]
        [ M3e.text "Reset all" ]
