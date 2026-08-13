The words in a UI are part of the design. Material's content-design guidance covers alt
text, component microcopy (labels, errors, hints), and general writing style. All of the
guidance below is Material's; where a control supplies the text, the slot/attribute is m3e.

## Alt text

Every meaningful image needs a text alternative; decorative images take an empty one
([alt text](https://m3.material.io/foundations/content-design/alt-text)). You should
write alt text that conveys the image's purpose, not its appearance
([alt text](https://m3.material.io/foundations/content-design/alt-text)). For an
image `m3e-avatar`, put the `alt` on the `<img>` you slot in; for an initials avatar the
visible text is the name.

```html
<m3e-avatar>
  <img src="/u/ada.jpg" alt="Ada Lovelace" />
</m3e-avatar>

<m3e-avatar>AL</m3e-avatar>
```

## Writing for components

Labels should be short and action-oriented — a button says what happens
([UX writing](https://m3.material.io/foundations/content-design/style-guide/ux-writing-best-practices)).
Error text should state what went wrong and how to fix it, not just that it is invalid
([UX writing](https://m3.material.io/foundations/content-design/style-guide/ux-writing-best-practices)).
Surface it through the form-field `error` slot, and keep hints in the `hint` slot. (m3e behavior)

```html
<m3e-form-field variant="outlined">
  <label for="pw">Password</label>
  <input id="pw" name="password" type="password" required />
  <span slot="hint">At least 8 characters.</span>
  <span slot="error">Password must be at least 8 characters.</span>
</m3e-form-field>
```

## Global writing basics

Prefer sentence case for labels, buttons, and headings
([content design](https://m3.material.io/foundations/content-design/overview)). You should
write in the second person and active voice, and avoid jargon the user would not use
([global writing](https://m3.material.io/foundations/content-design/global-writing/overview)).
Keep terminology consistent — one action, one name across the whole product
([content design](https://m3.material.io/foundations/content-design/overview)).

---
_See also: [Forms & validation](forms.md) · [Accessibility](accessibility.md)._
