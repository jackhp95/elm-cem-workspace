# Extraction report

Upstream `matraic/m3e` @ `v2.7.3`

Components: 55  ·  Elements: 116

## Verification findings (README vs CEM ground truth)

- **CEM-TAG-MISMATCH**: 1
- **DEFAULT-UNDOCUMENTED**: 41
- **UNDOCUMENTED**: 44
- **DEFAULT-MISMATCH**: 11

> DEFAULT-UNDOCUMENTED = the CEM specifies a default the README doesn't state.
> UNDOCUMENTED = real attribute (in CEM) missing from the README.
> DEFAULT-MISMATCH = README and CEM disagree on an attribute's default.
> CEM-TAG-MISMATCH = the analyzer's jsdoc `decl.tagName` disagrees with the
> `custom-element-definition` registration export; the registration tag wins.
> EXAMPLE-DRIFT = a README example uses a tag/attribute/slot the CEM doesn't expose
> (markup an agent might copy verbatim); these snippets are withheld from the cards.
> README-only = the README lists an attribute the CEM doesn't expose (likely stale/typo).
> In every case the CEM value wins. (Categories with a 0 count above don't appear here.)

### autocomplete
- `panel-class` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `results-label` — **DEFAULT-UNDOCUMENTED** (CEM=(count) => `${count} options`, README blank)
- `for` — **UNDOCUMENTED** (in CEM, not in README)

### badge
- `for` — **UNDOCUMENTED** (in CEM, not in README)

### bottom-sheet
- `detent` — **DEFAULT-MISMATCH** (README=0 CEM=undefined)
- `handle-label` — **DEFAULT-UNDOCUMENTED** (CEM="Drag handle", README blank)
- `hide-friction` — **DEFAULT-UNDOCUMENTED** (CEM=0.5, README blank)
- `for` — **UNDOCUMENTED** (in CEM, not in README)

### button
- `href` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `target` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `rel` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)

### calendar
- `active` — **UNDOCUMENTED** (in CEM, not in README)
- `today` — **UNDOCUMENTED** (in CEM, not in README)
- `active-date` — **UNDOCUMENTED** (in CEM, not in README)

### card
- `href` — **UNDOCUMENTED** (in CEM, not in README)
- `target` — **UNDOCUMENTED** (in CEM, not in README)
- `rel` — **UNDOCUMENTED** (in CEM, not in README)
- `download` — **UNDOCUMENTED** (in CEM, not in README)
- `name` — **UNDOCUMENTED** (in CEM, not in README)
- `value` — **UNDOCUMENTED** (in CEM, not in README)
- `type` — **UNDOCUMENTED** (in CEM, not in README)
- `disabled-interactive` — **UNDOCUMENTED** (in CEM, not in README)
- `disabled` — **UNDOCUMENTED** (in CEM, not in README)

### checkbox
- `validationMessages` — **UNDOCUMENTED** (in CEM, not in README)

### chips
- `href` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `rel` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `target` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `type` — **DEFAULT-UNDOCUMENTED** (CEM="button", README blank)
- `href` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `rel` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `target` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `type` — **DEFAULT-UNDOCUMENTED** (CEM="button", README blank)
- `validationMessages` — **UNDOCUMENTED** (in CEM, not in README)

### date-input
- `validationMessages` — **UNDOCUMENTED** (in CEM, not in README)

### datepicker
- `for` — **UNDOCUMENTED** (in CEM, not in README)

### dialog
- `return-value` — **UNDOCUMENTED** (in CEM, not in README)
- `for` — **UNDOCUMENTED** (in CEM, not in README)

### drawer-container
- `for` — **UNDOCUMENTED** (in CEM, not in README)

### expansion-panel
- `toggle-direction` — **DEFAULT-MISMATCH** (README="end" CEM="vertical")
- `toggle-position` — **DEFAULT-MISMATCH** (README="end" CEM="after")

### fab
- `href` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `target` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `rel` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)

### fab-menu
- `href` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `rel` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `target` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `for` — **UNDOCUMENTED** (in CEM, not in README)

### icon
- `name` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)

### icon-button
- `href` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `target` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `rel` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)

### list
- `href` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `rel` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `target` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `value` — **UNDOCUMENTED** (in CEM, not in README)
- `name` — **UNDOCUMENTED** (in CEM, not in README)

### menu
- `href` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `rel` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `target` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `submenu` — **UNDOCUMENTED** (in CEM, not in README)
- `for` — **UNDOCUMENTED** (in CEM, not in README)

### nav-bar
- `href` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `rel` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `target` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)

### nav-rail
- `mode` — **DEFAULT-MISMATCH** (README=auto CEM="compact")
- `for` — **UNDOCUMENTED** (in CEM, not in README)

### option
- `term` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `state` — **UNDOCUMENTED** (in CEM, not in README)
- `scroll-strategy` — **UNDOCUMENTED** (in CEM, not in README)
- `fit-anchor-width` — **UNDOCUMENTED** (in CEM, not in README)
- `anchor-offset` — **UNDOCUMENTED** (in CEM, not in README)

### progress-indicator
- `variant` — **UNDOCUMENTED** (in CEM, not in README)

### radio-group
- `value` — **DEFAULT-MISMATCH** (README="" CEM="on")
- `aria-invalid` — **UNDOCUMENTED** (in CEM, not in README)
- `validationMessages` — **UNDOCUMENTED** (in CEM, not in README)

### search
- `hide-search-icon` — **UNDOCUMENTED** (in CEM, not in README)

### select
- `panel-class` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)
- `validationMessages` — **UNDOCUMENTED** (in CEM, not in README)

### skeleton
- `animation` — **DEFAULT-MISMATCH** (README="none" CEM="wave")

### snackbar
- `action` — **DEFAULT-UNDOCUMENTED** (CEM="", README blank)

### split-pane
- `name` — **UNDOCUMENTED** (in CEM, not in README)
- `disabled` — **UNDOCUMENTED** (in CEM, not in README)

### stepper
- `M3eStepperNextElement` — **CEM-TAG-MISMATCH** (decl.tagName=m3e-stepper-previous registration=m3e-stepper-next (registration wins))
- `invalid` — **UNDOCUMENTED** (in CEM, not in README)

### switch
- `icons` — **DEFAULT-MISMATCH** (README=false CEM="none")
- `validationMessages` — **UNDOCUMENTED** (in CEM, not in README)

### theme
- `variant` — **DEFAULT-MISMATCH** (README="content" CEM="neutral")
- `variant` — **DEFAULT-MISMATCH** (README="content" CEM="neutral")

### timepicker
- `orientation` — **DEFAULT-MISMATCH** (README="horizontal" CEM="vertical")
- `period` — **DEFAULT-UNDOCUMENTED** (CEM="am", README blank)
- `view` — **DEFAULT-UNDOCUMENTED** (CEM="hour", README blank)
- `period` — **DEFAULT-UNDOCUMENTED** (CEM="am", README blank)
- `view` — **DEFAULT-UNDOCUMENTED** (CEM="hour", README blank)
- `for` — **UNDOCUMENTED** (in CEM, not in README)

### tooltip
- `position` — **DEFAULT-MISMATCH** (README="below-after" CEM="below")
- `touch-gestures` — **UNDOCUMENTED** (in CEM, not in README)
- `disable-restore-focus` — **UNDOCUMENTED** (in CEM, not in README)

