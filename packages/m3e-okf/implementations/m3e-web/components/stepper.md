# stepper

**Family:** [Navigation](../concepts/choosing-components.md#navigation) · See also: [app-bar](app-bar.md), [toolbar](toolbar.md), [nav-bar](nav-bar.md), [nav-rail](nav-rail.md), [nav-menu](nav-menu.md), [drawer-container](drawer-container.md), [tabs](tabs.md), [breadcrumb](breadcrumb.md), [toc](toc.md), [paginator](paginator.md), [slide-group](slide-group.md)

The `m3e-stepper` component orchestrates a structured, wizard-like workflow by dividing content into discrete, navigable steps. It supports horizontal and vertical orientations, linear progression, and configurable label and header positioning.

```ts
import "@m3e/web/stepper";
```

**Elements:** `<m3e-step>`, `<m3e-step-panel>`, `<m3e-stepper>`, `<m3e-stepper-next>`, `<m3e-stepper-previous>`, `<m3e-stepper-reset>`

## Examples

```html
<m3e-stepper>
  <m3e-step for="step1">Fill out your name</m3e-step>
  <m3e-step for="step2">Fill out your address</m3e-step>
  <m3e-step for="step3">Done</m3e-step>
  <m3e-step-panel id="step1">
    <form>
      <m3e-form-field>
        <label slot="label" for="name">Name</label>
        <input name="name" id="name" required />
      </m3e-form-field>
    </form>
    <div slot="actions">
      <m3e-button><m3e-stepper-next>Next</m3e-stepper-next></m3e-button>
    </div>
  </m3e-step-panel>
  <m3e-step-panel id="step2">
    <form>
      <m3e-form-field>
        <label slot="label" for="address">Address</label>
        <input name="address" id="address" required />
      </m3e-form-field>
    </form>
    <div slot="actions">
      <m3e-button><m3e-stepper-previous>Back</m3e-stepper-previous></m3e-button>
      <m3e-button><m3e-stepper-next>Next</m3e-stepper-next></m3e-button>
    </div>
  </m3e-step-panel>
  <m3e-step-panel id="step3"
    >Done
    <div slot="actions">
      <m3e-button><m3e-stepper-previous>Back</m3e-stepper-previous></m3e-button>
      <m3e-button><m3e-stepper-reset>Reset</m3e-stepper-reset></m3e-button>
    </div>
  </m3e-step-panel>
</m3e-stepper>
```

## Compositions

_Validated against the manifest — every tag, attribute, slot, and union value checked against the CEM ground truth; pure Material composition, no custom CSS._

**Horizontal stepper with completed and optional steps**

```html
<m3e-stepper orientation="horizontal" header-position="above" label-position="end">
  <m3e-step for="acct" completed editable>
    Account
    <m3e-icon slot="icon" name="person"></m3e-icon>
  </m3e-step>
  <m3e-step for="profile" selected>
    Profile
    <span slot="hint">Tell us about yourself</span>
  </m3e-step>
  <m3e-step for="review" optional>Review</m3e-step>
  <m3e-step-panel id="acct">
    <p>Account details saved.</p>
  </m3e-step-panel>
  <m3e-step-panel id="profile">
    <p>Enter your profile information.</p>
  </m3e-step-panel>
  <m3e-step-panel id="review">
    <p>Review and submit.</p>
  </m3e-step-panel>
</m3e-stepper>
```

**Linear vertical stepper with navigation controls**

```html
<m3e-stepper orientation="vertical" linear>
  <m3e-step for="s1" selected>Choose a plan</m3e-step>
  <m3e-step for="s2">Payment</m3e-step>
  <m3e-step-panel id="s1">
    <p>Pick the plan that fits you.</p>
  </m3e-step-panel>
  <m3e-step-panel id="s2">
    <p>Confirm and reset if needed.</p>
    <m3e-button>
      <m3e-stepper-previous>Back</m3e-stepper-previous>
    </m3e-button>
    <m3e-button>
      <m3e-stepper-reset>Start over</m3e-stepper-reset>
    </m3e-button>
  </m3e-step-panel>
</m3e-stepper>
```

## API

### `<m3e-step>`

A step in a wizard-like workflow.

**Display:** `flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `completed` | `boolean` | false | Whether the step has been completed. |
| `disabled` | `boolean` | false | Whether the element is disabled. |
| `editable` | `boolean` | false | Whether the step is editable and users can return to it after completion. |
| `for` | `string \| null` | null | The identifier of the interactive control to which this element is attached. |
| `optional` | `boolean` | false | Whether the step is optional. |
| `selected` | `boolean` | false | Whether the element is selected. |
| `invalid` | `boolean` | false | Whether the step has an error. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `panel` _(readonly)_ | `M3eStepPanelElement \| null` | A reference to the panel controlled by the step. |
| `stepper` _(readonly)_ | `M3eStepperElement \| null` | The stepper to which this step belongs. |
| `control` _(readonly)_ |  | The interactive element to which this element is attached. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the label of the step. |
| `icon` | Renders the icon of the step. |
| `done-icon` | Renders the icon of a completed step. |
| `edit-icon` | Renders the icon of a completed editable step. |
| `error-icon` | Renders icon of an invalid step. |
| `hint` | Renders the hint text of the step. |
| `error` | Renders the error message for an invalid step. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `beforeinput` | `Event` | Dispatched before the selected state changes. |
| `input` | `Event` | Dispatched when the selected state changes. |
| `change` | `Event` | Dispatched when the selected state changes. |
| `click` | `MouseEvent` | Dispatched when the element is clicked. |

**CSS custom properties** — 27 total across 27 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-step-shape` | Border radius of the step container, defining its visual shape. |
| `--m3e-step-padding` | Internal padding of the step container, used for layout spacing. |
| `--m3e-step-icon-shape` | Border radius of the icon container, controlling its geometric form. |
| `--m3e-step-icon-size` | Width and height of the icon container and icon glyph. |
| `--m3e-step-selected-icon-container-color` | Background color of the icon when the step is selected. |
| `--m3e-step-selected-icon-color` | Foreground color of the icon when the step is selected. |
| `--m3e-step-completed-icon-container-color` | Background color of the icon when the step is completed. |
| `--m3e-step-completed-icon-color` | Foreground color of the icon when the step is completed. |
| `--m3e-step-unselected-icon-container-color` | Background color of the icon when the step is inactive. |
| `--m3e-step-unselected-icon-color` | Foreground color of the icon when the step is inactive. |
| `--m3e-step-icon-error-color` | Foreground color of the icon when the step is invalid. |
| `--m3e-step-disabled-icon-container-color` | Base color used to mix the disabled icon background. |

_…15 more families. See source for the full list._

### `<m3e-step-panel>`

A panel presented for a step in a wizard-like workflow.

**Display:** `block`

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the panel. |
| `actions` | Renders the actions bar of the panel. |

**CSS custom properties** — 3 total across 3 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-step-panel-padding` | Padding inside the step panel container, defining internal spacing around content. |
| `--m3e-step-panel-spacing` | Vertical gap between stacked elements within the step panel. |
| `--m3e-step-panel-actions-height` | Minimum height of the slotted actions container. |

### `<m3e-stepper>`

Provides a wizard-like workflow by dividing content into logical steps.

**Display:** `flex`

**Attributes**

| Attribute | Type | Default | Description |
| --- | --- | --- | --- |
| `header-position` | `"above" \| "below"` | "above" | The position of the step header, when oriented horizontally. |
| `label-position` | `"below" \| "end"` | "end" | The position of the step labels, when oriented horizontally. |
| `linear` | `boolean` | false | Whether the validity of previous steps should be checked or not. |
| `orientation` | `"horizontal" \| "vertical" \| "auto"` | "horizontal" | The orientation of the stepper. |

**Properties** (JS-only, no attribute)

| Property | Type | Description |
| --- | --- | --- |
| `steps` _(readonly)_ | `readonly M3eStepElement[]` | The steps. |
| `selectedStep` _(readonly)_ | `M3eStepElement \| null` | The selected step. |
| `selectedIndex` _(readonly)_ | `number` | The zero-based index of the selected step. |
| `formAssociated` _(readonly)_ |  | Indicates that this custom element participates in form submission, validation, and form state restoration. |

**Slots**

| Slot | Description |
| --- | --- |
| `step` | Renders a step. |
| `panel` | Renders a panel. |

**Events**

| Event | Type | Description |
| --- | --- | --- |
| `change` | `Event` | Dispatched when the selected step changes. |
| `beforeinput` |  | Dispatched before the selected state of a step changes. |
| `input` |  | Dispatched when the selected state of a step changes. |

**CSS custom properties** — 3 total across 3 families. Common ones:

| Family (`[size]`/`[variant]` = any value) | Description |
| --- | --- |
| `--m3e-step-divider-thickness` | Thickness of the divider line between steps. |
| `--m3e-step-divider-color` | Color of the divider line between steps. |
| `--m3e-step-divider-inset` | Inset offset for divider alignment within step layout. |

### `<m3e-stepper-next>`

An element, nested within a clickable element, used to move a stepper to the next step.

**Display:** `contents`

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the action. |

### `<m3e-stepper-previous>`

An element, nested within a clickable element, used to move a stepper to the previous step.

**Display:** `contents`

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the action. |

### `<m3e-stepper-reset>`

An element, nested within a clickable element, used to reset a stepper to its initial state.

**Display:** `contents`

**Slots**

| Slot | Description |
| --- | --- |
| `(default)` | Renders the content of the action. |

## Source & fidelity

Generated from `matraic/m3e` @ [`v2.7.3`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/stepper/README.md) (MIT). · No direct Material-spec page (library extension).
API values above are taken from the build-time **Custom Elements Manifest** (machine truth), not the prose README.

Source files:
- [`packages/web/src/stepper/StepElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/stepper/StepElement.ts)
- [`packages/web/src/stepper/StepPanelElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/stepper/StepPanelElement.ts)
- [`packages/web/src/stepper/StepperElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/stepper/StepperElement.ts)
- [`packages/web/src/stepper/StepperNextElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/stepper/StepperNextElement.ts)
- [`packages/web/src/stepper/StepperPreviousElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/stepper/StepperPreviousElement.ts)
- [`packages/web/src/stepper/StepperResetElement.ts`](https://github.com/matraic/m3e/blob/v2.7.3/packages/web/src/stepper/StepperResetElement.ts)

**README drift corrected** (1 item(s); CEM values used above):
_See the extraction report `data/report.md` in the m3e-docs repo that generated this skill for specifics — attributes, defaults, or slots where the README disagreed with or omitted the code._
