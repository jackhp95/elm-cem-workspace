import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import type { M3eStepperElement } from "./StepperElement";
import { M3eStepPanelElement } from "./StepPanelElement";
declare const M3eStepElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SelectedMixin> & import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").HtmlForMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A step in a wizard-like workflow.
 *
 * @description
 * The `m3e-step` component represents a single step in a structured, wizard-like workflow.
 * It supports semantic labeling, stateful styling, and optional interaction for completed,
 * selected, invalid, or disabled states. It aligns with Material Design guidance for progressive
 * disclosure, accessible navigation, and visual continuity across horizontal and vertical layouts.
 *
 * @example
 * The following example demonstrates a linear multi-step form flow using the `m3e-stepper`
 * component. Each `m3e-step` defines a navigable step label, linked to its corresponding
 * `m3e-step-panel` via the `for` attribute. Navigation is orchestrated using the
 * `m3e-stepper-next`, `m3e-stepper-previous`, and `m3e-stepper-reset` components.
 *
 * <m3e-stepper>
 *  <m3e-step for="step1">Fill out your name</m3e-step>
 *  <m3e-step for="step2">Fill out your address</m3e-step>
 *  <m3e-step for="step3">Done</m3e-step>
 *  <m3e-step-panel id="step1">
 *    <form>
 *      <m3e-form-field>
 *        <label slot="label" for="name">Name</label>
 *        <input name="name" id="name" required />
 *      </m3e-form-field>
 *    </form>
 *    <div slot="actions">
 *      <m3e-button><m3e-stepper-next>Next</m3e-stepper-next></m3e-button>
 *    </div>
 *  </m3e-step-panel>
 *  <m3e-step-panel id="step2">
 *    <form>
 *      <m3e-form-field>
 *        <label slot="label" for="address">Address</label>
 *        <input name="address" id="address" required />
 *      </m3e-form-field>
 *    </form>
 *    <div slot="actions">
 *      <m3e-button><m3e-stepper-previous>Back</m3e-stepper-previous></m3e-button>
 *      <m3e-button><m3e-stepper-next>Next</m3e-stepper-next></m3e-button>
 *    </div>
 *  </m3e-step-panel>
 *  <m3e-step-panel id="step3">Done
 *    <div slot="actions">
 *      <m3e-button><m3e-stepper-previous>Back</m3e-stepper-previous></m3e-button>
 *      <m3e-button><m3e-stepper-reset>Reset</m3e-stepper-reset></m3e-button>
 *    </div>
 *  </m3e-step-panel>
 * </m3e-stepper>
 *
 * @tag m3e-step
 *
 * @slot - Renders the label of the step.
 * @slot icon - Renders the icon of the step.
 * @slot done-icon - Renders the icon of a completed step.
 * @slot edit-icon - Renders the icon of a completed editable step.
 * @slot error-icon - Renders icon of an invalid step.
 * @slot hint - Renders the hint text of the step.
 * @slot error - Renders the error message for an invalid step.
 *
 * @attr completed - Whether the step has been completed.
 * @attr disabled - Whether the element is disabled.
 * @attr editable - Whether the step is editable and users can return to it after completion.
 * @attr for - The identifier of the interactive control to which this element is attached.
 * @attr optional - Whether the step is optional.
 * @attr selected - Whether the element is selected.
 *
 * @fires beforeinput - Dispatched before the selected state changes.
 * @fires input - Dispatched when the selected state changes.
 * @fires change - Dispatched when the selected state changes.
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-step-shape - Border radius of the step container, defining its visual shape.
 * @cssprop --m3e-step-padding - Internal padding of the step container, used for layout spacing.
 * @cssprop --m3e-step-icon-shape - Border radius of the icon container, controlling its geometric form.
 * @cssprop --m3e-step-icon-size - Width and height of the icon container and icon glyph.
 * @cssprop --m3e-step-selected-icon-container-color - Background color of the icon when the step is selected.
 * @cssprop --m3e-step-selected-icon-color - Foreground color of the icon when the step is selected.
 * @cssprop --m3e-step-completed-icon-container-color - Background color of the icon when the step is completed.
 * @cssprop --m3e-step-completed-icon-color - Foreground color of the icon when the step is completed.
 * @cssprop --m3e-step-unselected-icon-container-color - Background color of the icon when the step is inactive.
 * @cssprop --m3e-step-unselected-icon-color - Foreground color of the icon when the step is inactive.
 * @cssprop --m3e-step-icon-error-color - Foreground color of the icon when the step is invalid.
 * @cssprop --m3e-step-disabled-icon-container-color - Base color used to mix the disabled icon background.
 * @cssprop --m3e-step-disabled-icon-color - Base color used to mix the disabled icon foreground.
 * @cssprop --m3e-step-label-color - Text color of the step label in its default state.
 * @cssprop --m3e-step-label-error-color - Text color of the step label when the step is invalid.
 * @cssprop --m3e-step-disabled-label-color - Base color used to mix the disabled label foreground.
 * @cssprop --m3e-step-font-size - Font size of the step label.
 * @cssprop --m3e-step-font-weight - Font weight of the step label.
 * @cssprop --m3e-step-line-height - Line height of the step label.
 * @cssprop --m3e-step-tracking - Letter spacing of the step label.
 * @cssprop --m3e-step-icon-label-space - Gap between icon and label.
 * @cssprop --m3e-step-hint-font-size - Font size of hint and error messages.
 * @cssprop --m3e-step-hint-font-weight - Font weight of hint and error messages.
 * @cssprop --m3e-step-hint-line-height - Line height of hint and error messages.
 * @cssprop --m3e-step-hint-tracking - Letter spacing of hint and error messages.
 * @cssprop --m3e-step-hint-color - Text color of hint messages in valid state.
 * @cssprop --m3e-step-disabled-hint-color - Base color used to mix the disabled hint foreground.
 */
export declare class M3eStepElement extends M3eStepElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextId;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /** @private */ private readonly _ripple?;
    /**
     * Whether the step is optional.
     * @default false
     */
    optional: boolean;
    /**
     * Whether the step is editable and users can return to it after completion.
     * @default false
     */
    editable: boolean;
    /**
     * Whether the step has been completed.
     * @default false
     */
    completed: boolean;
    /**
     * Whether the step has an error.
     * @default false
     */
    invalid: boolean;
    /** @internal */
    index: number;
    /** A reference to the panel controlled by the step. */
    get panel(): M3eStepPanelElement | null;
    /** The stepper to which this step belongs. */
    get stepper(): M3eStepperElement | null;
    /** Resets the step to its initial state, clearing any form data. */
    reset(): void;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    detach(): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-step": M3eStepElement;
    }
}
export {};
//# sourceMappingURL=StepElement.d.ts.map