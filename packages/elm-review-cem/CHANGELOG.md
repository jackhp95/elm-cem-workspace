# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Note that the
`Cem.Facts.Fact` contract is part of the public API: any incompatible change to
it is a major version bump.

## [Unreleased]

### Added

- `NoRedundantAttributeEscape` (`Cem.redundantAttributeEscape`, opt-in) — the
  attribute-side twin of `NoRedundantElementEscape`: flags a
  `<root>.Unsafe.Attributes.customAttribute` / `fromHtmlAttribute` escape that
  writes an attribute (or wires an event) the typed layer already has a setter
  for. Evidence-driven rather than name-listed: a setter is only suggested when
  the rule has SEEN its declaration in a `<root>.Attributes` / `.Aria` /
  `.Events` module (derived per facts namespace, extendable with
  `setterModules`), AND the attribute name is element-INDEPENDENT: `aria-*` /
  `role`, an HTML global attribute, or an event. A custom element's attribute
  namespace is disjoint from HTML's — `<raw-html content="…">` is not
  `<meta content="…">` — and the rule cannot see the enclosing element, so
  element-specific names are never matched. Per-component setters from the facts
  are not an evidence source either: their rows are closed, so suggesting one
  without knowing the element is unsound. Autofix for the one byte-identical
  rewrite (an empty-string value onto a `Bool` setter); report-only everywhere
  else.
- `NoRedundantElementEscape` gained three raw-tag detections, all keyed on the
  facts' covered-tag set: an Html-accepting escape wrapping a hand-written
  covered tag (`Unsafe.fromHtml (Html.a …)`, `Html.node "header"`),
  `Unsafe.customElement` pointed at a covered tag, and `Unsafe.customElement`
  applied to an element expression instead of a tag name.
- Initial facts-driven `Cem.*` rule set: `validEnumValue`, `requireSlot`,
  `singularSlot`, `singularAttribute`, `missingRequiredAttribute`,
  `missingRequiredSingularSlot`, `preferComponentModules`, `validSlotKind`
  (`Cem.all` / `Cem.allWith`), plus the opt-in autofixes `preferBarrel` /
  `preferComponentSetters`.
- `Cem.requireFormFieldLabel` (opt-in, module `Cem.RequireFormFieldLabel`) — the
  accessible-name backstop for a form-field's control: flags a `<root>.FormField`
  whose control has no `slot="label"` child, no `aria-label`/`aria-labelledby`, and
  no `id` (the `<label for>` proxy) on the Standard/barrel facet. Reasons only from
  static Elm structure and stays silent on anything it cannot fully resolve, so it
  never mis-flags a legitimately-labelled field.
- `Cem.fences` — the canonical seam/opaque-IR boundary preset
  (`NoInternalImportOutsideAllowed` + `NoSeamOutsideAllowedModules` +
  `NoRedundantElementForge`) from one config record, so consumers stop hand-rolling
  a `CodegenReviewConfig` (and forgetting the `TypedHtml`/`HtmlIr` allow-list entry).
- Per-namespace fact handling: rules group concatenated facts
  (`M3e … ++ TypedHtml …`) by namespace and resolve call sites against every
  namespace present, instead of only the first fact's.
- Seam-discipline rules (config-driven, top-level names): `NoSeamOutsideAllowedModules`,
  `NoInternalImportOutsideAllowed`, and the cross-file autofix companion `ExtractToSeam`.
- `Cem.Facts` versioned fact contract (with `slotKinds` for `ValidSlotKind`) — the
  load-bearing contract with `elm-cem`'s generated `Review.Facts`.

### Changed

- `NoRedundantElementForge` keys its covered-tag set on the HTML tag (reversing
  elm-cem's reserved-word escaping) rather than the Elm producer name, so a forged
  `<main>` (producer `main_`) is now flagged.

### Removed

- The five mutually-exclusive `translateTo*` surface translators (`Standard`,
  `Record`, `Build`, `Html`, `Raw`) — they rewrote toward `Html`/`Raw` layers no
  generated brand still emits. This also retires the only code that hardcoded a
  `Seam.*` residue target; the seam target is now purely config-driven
  (`NoSeamOutsideAllowedModules` / `ExtractToSeam`).

<!-- No tagged release yet; versioning is publish-gated. Keep entries here until
     the first tagged release, then move them under a `## [1.0.0]` heading. -->
