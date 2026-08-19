---
type: concept
title: Autocomplete
description: A text field that suggests and filters matching options as the user types.
resource: https://m3.material.io/components/menus/overview
tags: [components, autocomplete, combobox, suggestions, form]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/menus/overview
    retrieved: 2026-07-11
    note: Exposed-dropdown and typeahead selection.
  - url: https://m3.material.io/components/menus/guidelines
    retrieved: 2026-07-11
    note: Menu-based selection guidance the autocomplete builds on.
---

Autocomplete is a [text field](/components/text-field) that filters and suggests matching
options as the user types, combining free text entry with a constrained set of choices. It
suits long option lists where typing to narrow is faster than scanning.

## Anatomy

A text field with an attached list of suggestions that updates as the user types; choosing a
suggestion fills the field. Depending on configuration, the user may be limited to listed
options or allowed to enter free text.

## Usage

Use autocomplete when the option set is large enough that a [select](/components/select) would
be tedious to scroll and typing to filter is natural — a country, a recipient, a tag. Make
clear whether free text is accepted or only listed options are valid, and show a helpful empty
state when nothing matches. See [search](/patterns/search) for search-oriented suggestion flows.

## Do / Don't

**Do**

- Use autocomplete when the option set is large enough that a
  [select](/components/select) would be tedious to scroll and typing to filter is
  natural — a country, a recipient, a tag.
- Make clear whether free text is accepted or only listed options are valid.
- Show a helpful empty state when nothing matches, and rank suggestions by
  relevance.
- Filter forgivingly (case-insensitive, matching within the string) so near-misses
  still surface results.

**Don't**

- Don't use autocomplete for a short option list — a plain
  [select](/components/select) or [radio group](/components/radio-group) is
  simpler.
- Don't leave the user guessing whether their typed value will be accepted.
- Don't show a dead end on no match; offer a "no results" message or a way to add
  a value.
- Don't auto-select or overwrite the user's text in a way that fights their typing.

## Accessibility

The field exposes that it has an associated suggestion list and its expanded state; suggestions
are navigable by keyboard; the active suggestion is announced; and choosing or dismissing keeps
focus sensible. See [forms](/patterns/forms).

For the technology-specific API, see
[/implementations/m3e-web/components/autocomplete](/implementations/m3e-web/components/autocomplete).
