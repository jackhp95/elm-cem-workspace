<!--
Thanks for contributing to elm-cem! Keep the generator library-agnostic:
new behaviour belongs in a config key, never a hard-coded component/library name.
See CONTRIBUTING.md.
-->

## What & why

<!-- What does this change and why? Link the issue it closes (e.g. `Closes #NN`). -->

## Kind of change

- [ ] Bug fix (no public-surface change)
- [ ] New / extended config key (additive)
- [ ] Change to the **generated output** (module / function / phantom-row names)
- [ ] Docs / governance / tooling only

## Generated-surface impact

<!--
elm-cem has TWO public surfaces (see CHANGELOG.md § Stability policy): the CLI +
`Cem`/`Generate` modules, AND the generated output that downstream packages compile
against. If a golden diff changed, categorize it (expected additive vs. breaking rename/
retype) and note it below.
-->

- [ ] No generated-surface change
- [ ] Additive only (new module/setter/token; nothing renamed or retyped)
- [ ] **Breaking** generated-surface change (renamed/retyped/removed) — flagged in the
      CHANGELOG and the PR title

## Checklist

- [ ] `npm test` passes (elm-test-rs golden + unit suites, CLI tests)
- [ ] `npm run format:check` clean
- [ ] Neutrality gate green (`bash .github/neutrality-check.sh`)
- [ ] `CHANGELOG.md` updated under _Unreleased_ (for any user-visible change)
- [ ] Docs updated if behaviour or config changed
