M3E form controls are **form-associated custom elements**: dropped inside a native
`<form>`, they submit, validate, and reset just like built-in inputs. Wire them with
the standard attributes — `name` (the submitted key), `value`, and `required` — then
read them back with `FormData` or the form's `submit` event. No custom JS plumbing.

## A complete form

```html
<form>
  <m3e-form-field variant="outlined">
    <label slot="label" for="full-name">Full name</label>
    <input id="full-name" name="fullName" type="text" required />
    <span slot="hint">Your first and last name.</span>
  </m3e-form-field>

  <m3e-form-field variant="outlined">
    <label for="email">Email</label>
    <m3e-icon slot="prefix" name="mail"></m3e-icon>
    <input id="email" name="email" type="email" required />
  </m3e-form-field>

  <label for="plan">Plan</label>
  <m3e-select id="plan" name="plan" required>
    <m3e-option value="free">Free</m3e-option>
    <m3e-option value="pro">Pro</m3e-option>
    <m3e-option value="team">Team</m3e-option>
  </m3e-select>

  <m3e-radio-group name="billing" required>
    <label><m3e-radio value="monthly" checked></m3e-radio> Monthly</label>
    <label><m3e-radio value="yearly"></m3e-radio> Yearly</label>
  </m3e-radio-group>

  <label>
    <m3e-switch name="newsletter" value="subscribed"></m3e-switch>
    Email me product news
  </label>

  <label>
    <m3e-checkbox name="terms" value="accepted" required></m3e-checkbox>
    I accept the terms of service
  </label>

  <div>
    <m3e-button type="reset" variant="text">Reset</m3e-button>
    <m3e-button type="submit" variant="filled">Create account</m3e-button>
  </div>
</form>
```

## How the wiring works

- **Submission** — each control contributes its `name=value` pair to the form's
  `FormData`, exactly like a native input. `<m3e-button type="submit">` submits the
  form; `type="reset"` returns every control to its default state.
- **Labels** — give the form-field its floating label via `<label slot="label">`, and
  associate it to the control with `for`=<control id> — the component does no id-wiring.
  (A `<label for>` placed in the default slot also works.) For standalone controls, wrap
  the control in a `<label>`, or point a `<label for>` at the control's `id`.
- **Required & validation** — `required` participates in native constraint validation,
  so `form.checkValidity()`, the `submit` event's validity gating, and `:invalid`
  styling all work. Surface a message through the form-field's `error` slot:

```html
<m3e-form-field variant="outlined">
  <label for="user">Username</label>
  <input id="user" name="username" type="text" required />
  <span slot="error">This field is required.</span>
</m3e-form-field>
```

- **Multiple / numeric values** — `<m3e-select multi>` submits each selected option
  under the same `name`; a `<m3e-slider>` submits its thumb's `value` under the
  thumb's `name`:

```html
<m3e-slider labelled min="0" max="1000" step="50">
  <m3e-slider-thumb name="budget" value="400"></m3e-slider-thumb>
</m3e-slider>
```

## Form-capable elements

`form-field` (wrapping `input`/`textarea`), `select`, `checkbox`, `radio-group`,
`switch`, `slider`, and `datepicker` are all form-associated. Each participates in
the enclosing `<form>` via `name`/`value`/`required` — see the component card for its
exact attributes.
