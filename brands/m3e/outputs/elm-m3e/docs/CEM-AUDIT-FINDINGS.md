# CEM completeness audit — findings + remaining tasks

Durable record of a forensic audit of `@m3e/web` 2.6.2's `custom-elements.json`
(the CEM) and its downstream effect on the generated `M3e.*` Elm API. Written so
the work survives context compaction and can brief subagents.

Repos (all under `/Users/jhp/code/jackhp95/`):
- `elm-m3e` — the brand; `src/` is generated `M3e.*`, `config/slots.json` is the
  curation, `docs/` is the elm-pages docs app + tooling.
- `elm-review-cem` — the `Cem.*` elm-review rules.
- `elm-cem` — the generator (npm). Distribution model: `elm-cem/docs/distribution-model.md`.

`@m3e/web` source (matraic/m3e) cloned at:
`…/scratchpad/m3e-src` (packages/web/src/*.ts hold the JSDoc + render).
The 2.6.2 CEM: `elm-m3e/docs/node_modules/.pnpm/@m3e+web@2.6.2_…/node_modules/@m3e/web/dist/custom-elements.json`
Unminified bundle: same dir `dist/all.js`.

## The core finding

`@m3e/web`'s CEM is generated from JSDoc `@slot`/`@fires`/`@attr`/`@tag` tags,
which are **inconsistent with the components' actual render**. So the CEM
silently omits real slots (and one event), and our generator faithfully mirrors
the incomplete manifest. Attributes are fine (property decorators flatten
correctly). Method used to be certain: static render-template scan × runtime
headless-Chromium shadow-DOM render × orphan check — the two methods *disagreed*
on real cases, so triangulation was necessary.

### Slots — the triangulated missing set (render vs CEM)
Genuinely-missing, uncompensated slots (verified runtime + static):
- **m3e-form-field `label`** — the floating-label slot (`<slot name="label">`,
  its own `@example`, and `::slotted([slot="label"])` CSS). THE motivating bug.
- **m3e-list-item + m3e-list-item-button** `leading-icon`, `trailing-icon`,
  `trailing-supporting-text` (the list-action/list-option/expandable variants
  OVERRIDE the render and correctly drop them — do NOT add there).

Already compensated in `config/slots.json` by prior work (do NOT re-add):
search-view/search-bar icon-override slots, option-panel `no-data`/`loading`,
step-panel `actions`, breadcrumb-item-button `icon`.

### Attributes — complete. Only 4 cosmetic casing nits
`SplitPane.valueFormatter`, `Timepicker(/Dial/Input).blackoutTimes` are bare
`@property()` on FUNCTION types → Lit registers a lowercased, unsettable
attribute. Our generator emits dead `valueformatter`/`blackouttimes` String
setters that emit wrong-cased attributes. Low impact (nobody sets a function via
attribute). Correct fix is upstream `@property({ attribute: false })`.

### Events — 2 missing
`state-change` on `m3e-option` (public), `pagination-changed` on
`m3e-slide-group` (upstream-internal).

## Curation questions — ALL resolved (config was already correct)
- Chip `trailing-icon` on assist/input/suggestion: source shows only Chip/
  FilterChip declare it. Config correct; no change.
- `role` on grouping containers: RadioGroup/ButtonGroup/SegmentedButton/
  MenuItemGroup/NavMenuItemGroup self-set role via the `Role` mixin
  (`this.role = this.role || role`); only ChipSet lacks it → config already
  patches it. No change.
- `aria-label` required on toggles/triggers: all extend `ActionElementBase`
  (display:contents wrappers; accessible name comes from the host button). No change.
- `m3e-fab-menu-item` absent from CEM: root cause = `@tag m3e-menu-item` typo in
  source (copy-pasted from MenuItem) while `@customElement("m3e-fab-menu-item")`.

## What's DONE
- **elm-m3e `a20e3d64`**: added form-field `label` + list-item(/button) icon
  slots to config, regen, verified (form-field emits `slot="label"`, gate green,
  20 tests, primitives docs.json 183 KB unchanged).
- **Upstream PR matraic/m3e#91** (annotation-only): the `@slot` omissions +
  `@fires state-change` + the `@tag m3e-fab-menu-item` fix. Branch
  `fix/cem-slot-jsdoc-omissions` on fork `jackhp95/m3e`.

## REMAINING TASKS (delegated to subagents)

### Task A — examples-gen overhaul (elm-m3e/docs/scripts/examples-gen)
Real bug: `lib/oracle.mjs:261` reads `moduleConfig.slots` but the config key is
`admits` → `slotConfig` is always `{}`, so examples-gen never sees config-defined
slots (incl. `label`) AND loses every slot's `kinds`/`multi`/`required`.
Complications: (1) the examples-gen unit suite is ALREADY red at baseline — the
`tree-item required label` and `nav-menu-item missing required label slot` tests
in `lib/to-elm.test.mjs` fail before any change; (2) fixing the key activates the
"fold required text/link slot" path (`foldsToRecord` / `renderRequiredNamedSlotChild`),
which changes how required-slot children render (e.g. `label (Kit.text "x")` →
`label (Native.span [] [Kit.text "x"])`) and needs reconciling against the current
library (NavMenuItem/TreeItem have BOTH a `view`+`label`-helper form and an
`el`/`build` required-record form; the oracle targets the `view`/helper form).
Goal: fix the read, reconcile the fold/skip/unwrap logic against the current
generated library, GREEN the suite, regenerate examples, and confirm elm-m3e
`gate` (regen-drift) still passes. Docs-only — does NOT affect library correctness.

### Task B — seam fix (elm-m3e/docs/kit/Seam.elm)
`Seam.field`/`Seam.label` (≈L102–151) hand-rolls a native `<label for=id>` as a
SIBLING in the form-field default slot (the pre-slot workaround) instead of using
the now-existing `slot="label"`. Update it to place the label via
`M3e.FormField.label` (which emits `slot="label"`) while KEEPING the `for`/`id`
association for accessibility. This is why hand-written docs examples "skip the
label." Verify the docs app still compiles.

### Task C — a11y rule (elm-review-cem)
Add a rule (or extend the facts-driven set) requiring an accessible NAME on a
form-field's control — a `<label for>`/`slot="label"` association or an
`aria-label` — analogous to the existing `missingRequiredAttribute` rule that
requires `aria-label` on icon-only controls. Now that `M3e.FormField.label`
exists, the rule finally has a slot to require. Match the repo's rule conventions
(facts-driven, `Cem.*`), add tests, keep `npm test` green and zero suppressions.
