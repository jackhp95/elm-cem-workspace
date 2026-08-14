# jackhp95/elm-m3e-icons

Type-safe Material Symbols icon element helpers for elm-m3e.

This package is a standalone sub-package of [elm-m3e](https://github.com/jackhp95/elm-m3e).
It depends ONLY on `elm/html` and `jackhp95/elm-html-intermediate-representation`
— no `elm-m3e-components` dependency. Suitable for projects that need only icons
without the full component library.

**Generated file.** Do not edit `src/` by hand — run `npm run gen:src` in the
elm-m3e repo to regenerate from the icon catalog (`config/icons-catalog.json`).

## Usage

```elm
import M3e.Icon

-- A named icon
M3e.Icon.menu [] []

-- A custom / app-specific icon
M3e.Icon.custom "my_custom_icon" [] []
```

## License

BSD-3-Clause — see [LICENSE](LICENSE).
