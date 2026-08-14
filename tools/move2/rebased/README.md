# Rebased matched trees (Move 2 part 1/2)

Git bundles of the workspace's elm-cem + elm-m3e Phase-0 changes REBASED onto the latest
remote mains (elm-cem ad5d523, elm-m3e e1bde03). Restore with:

    # thin bundles: fetch the remote base first, then apply the rebase-resolution commits
    git clone https://github.com/jackhp95/elm-cem.git d && git -C d fetch ../elm-cem-ws-ours.thin.bundle ws-ours:ws-ours
    git clone https://github.com/jackhp95/elm-m3e.git e && git -C e fetch ../elm-m3e-ws-ours.thin.bundle ws-ours:ws-ours

- **elm-cem `ws-ours`**: e0e4f1c→ad5d523 rebase; Emit.elm auto-merged (facts-bundle + concern-sep
  coexist, 7095 lines); verified to generate 403 concern-sep files + 4083-icon M3e.Icon + facts
  bundle Face B/C.
- **elm-m3e `ws-ours`** (d1d7501): 0cd7f486→e1bde03 rebase; concern-sep src (403), packages.json,
  elm-m3e-icons package; monorepo postinstall preserved (no hooks:install); check:cem --skip-drift
  DROPPED (R-010 resolved — generator now matches committed src).

NEXT: copy these trees into packages/elm-cem + packages/elm-m3e, pnpm install, regenerate facts
bundle + consumers, re-baseline Face A (143 flat → concern-sep count), reconcile gate-all, then
repackage 5-way (split Build/*, rename core→html + review-facts→facts). DO NOT PUBLISH.
