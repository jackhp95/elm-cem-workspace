<!-- Thanks for contributing to elm-m3e! -->

## What & why

<!-- What does this change and why? Link any related issue: Closes #NNN -->

## Generated code

<!-- The M3e.* modules under src are GENERATED. If this PR touches component
     output, confirm you changed the source of truth, not the artifact: -->

- [ ] I did **not** hand-edit generated `src/M3e/*` output; I changed the
      generator (`elm-cem/`) and/or `config/` and regenerated, **or** this PR touches no
      generated code.

## Checks

- [ ] `cd docs && npm run build:ci` passes (the Netlify gate).
- [ ] `docs/node_modules/.bin/elm-format --validate app src` is clean (if I touched `.elm`).
- [ ] If the generator changed: the package compiles, `build:reference` passes, and the
      `elm-cem` + `elm-review-cem` suites are green.
- [ ] For any visual change, I verified it in the docs app (Playwright / screenshot).
