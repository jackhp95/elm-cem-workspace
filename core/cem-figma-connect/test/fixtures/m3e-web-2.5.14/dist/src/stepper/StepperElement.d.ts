import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { SelectionManager, selectionManager } from "@m3e/web/core/a11y";
import { M3eStepElement } from "./StepElement";
import { StepLabelPosition } from "./StepLabelPosition";
import { StepHeaderPosition } from "./StepHeaderPosition";
import { StepperOrientation } from "./StepperOrientation";
declare const M3eStepperElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * Provides a wizard-like workflow by dividing content into logical steps.
 *
 * @description
 * The `m3e-stepper` component orchestrates a structured, wizard-like workflow by dividing
 * content into discrete, navigable steps. It supports horizontal and vertical orientations,
 * linear progression, and configurable label and header positioning.
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
 * @tag m3e-stepper
 *
 * @attr header-position - The position of the step header, when oriented horizontally.
 * @attr label-position - The position of the step labels, when oriented horizontally.
 * @attr linear - Whether the validity of previous steps should be checked or not.
 * @attr orientation - The orientation of the stepper.
 *
 * @slot step - Renders a step.
 * @slot panel - Renders a panel.
 *
 * @fires beforeinput - Dispatched before the selected state of a step changes.
 * @fires input - Dispatched when the selected state of a step changes.
 * @fires change - Dispatched when the selected step changes.
 *
 * @cssprop --m3e-step-divider-thickness - Thickness of the divider line between steps.
 * @cssprop --m3e-step-divider-color - Color of the divider line between steps.
 * @cssprop --m3e-step-divider-inset - Inset offset for divider alignment within step layout.
 */
export declare class M3eStepperElement extends M3eStepperElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private _orientation?;
    /** @private */ private _selectedIndex;
    /** @internal */ readonly [selectionManager]: SelectionManager<M3eStepElement>;
    /**
     * The position of the step header, when oriented horizontally.
     * @default "above"
     */
    headerPosition: StepHeaderPosition;
    /**
     * The position of the step labels, when oriented horizontally.
     * @default "end"
     */
    labelPosition: StepLabelPosition;
    /**
     * Whether the validity of previous steps should be checked or not.
     * @default false
     */
    linear: boolean;
    /**
     * The orientation of the stepper.
     * @default "horizontal"
     */
    orientation: StepperOrientation;
    /** The steps. */
    get steps(): readonly M3eStepElement[];
    /** The selected step. */
    get selectedStep(): M3eStepElement | null;
    /** The zero-based index of the selected step. */
    get selectedIndex(): number;
    /**
     * Moves the stepper to the previous step.
     * @returns {boolean} Whether the stepper moved to the previous step.
     */
    movePrevious(): boolean;
    /**
     * Moves the stepper to the next step.
     * @returns {boolean} Whether the stepper moved to the next step.
     */
    moveNext(): boolean;
    /**
     * Moves the stepper to the step with the specified index.
     * @param index The zero-based index of the step to which to move.
     * @returns {boolean} Whether the stepper moved to the specified `index`.
     */
    moveTo(index: number): boolean;
    /** @internal */
    _moveTo(index: number): boolean;
    /** Resets the stepper to its initial state, clearing any form data. */
    reset(): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected willUpdate(changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-stepper": M3eStepperElement;
    }
}
export {};
//# sourceMappingURL=StepperElement.d.ts.map