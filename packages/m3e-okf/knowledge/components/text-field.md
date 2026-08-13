---
type: concept
title: Text field
description: A labeled input for entering text, with supporting and error text, in filled or outlined styles.
resource: https://m3.material.io/components/text-fields/overview
tags: [components, text-field, input, forms, validation]
timestamp: 2026-07-11T00:00:00Z
diataxis: reference
sources:
  - url: https://m3.material.io/components/text-fields/overview
    retrieved: 2026-07-11
    note: Text-field anatomy and styles.
  - url: https://m3.material.io/components/text-fields/guidelines
    retrieved: 2026-07-11
    note: Label, supporting text, and error usage.
---

A text field is a labeled control for entering text. It comes in a filled and an
outlined style, and pairs the input with a persistent label plus optional
supporting text and error text so the field explains itself.

## Anatomy

A text field is an input area inside a shaped container, with a label that rests
above the text once the field is filled or focused. Supporting text sits below to
guide entry; error text replaces it when validation fails.

## Usage

Keep the label short and always present rather than relying on placeholder text
that vanishes on typing. Supporting text guides input up front; error text states
what went wrong and how to fix it, not merely that the value is invalid.

## Do / Don't

**Do**

- Keep a short, persistent label on every field so its purpose stays visible
  after the user starts typing.
- Use supporting text to set expectations up front (format, constraints), and
  error text to say what went wrong and how to fix it.
- Size the field to the expected input where it helps (a short field for a ZIP
  code, a wider one for an address).
- Mark required fields consistently, and validate at a helpful moment rather than
  flagging every keystroke.

**Don't**

- Don't use placeholder text as the label — it disappears on typing and leaves
  the user without a reference.
- Don't write error text that only says a value is "invalid"; state the rule and
  the fix.
- Don't signal required, error, or focus state with color alone.
- Don't cram unrelated inputs into one field or ask for information you don't need.

## Accessibility

The label is programmatically associated with the input so it is announced as the
field's name. Error and supporting text are linked to the field so assistive
technology reads them with it, and required and invalid states are conveyed
beyond color alone.

For the technology-specific API (the form-field wrapper, slots, and validation
wiring), see
[/implementations/m3e-web/components/form-field](/implementations/m3e-web/components/form-field).
