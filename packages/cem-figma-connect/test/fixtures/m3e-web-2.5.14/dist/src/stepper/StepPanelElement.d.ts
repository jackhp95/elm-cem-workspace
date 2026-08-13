import { CSSResultGroup, LitElement } from "lit";
declare const M3eStepPanelElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A panel presented for a step in a wizard-like workflow.
 *
 * @description
 * The `m3e-step-panel` is a container for presenting contextual content and actions
 * associated with a single step in a structured workflow.
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
 * @tag m3e-step-panel
 *
 * @slot - Renders the content of the panel.
 * @slot actions- Renders the actions bar of the panel.
 *
 * @cssprop --m3e-step-panel-padding - Padding inside the step panel container, defining internal spacing around content.
 * @cssprop --m3e-step-panel-spacing - Vertical gap between stacked elements within the step panel.
 * @cssprop --m3e-step-panel-actions-height - Minimum height of the slotted actions container.
 */
export declare class M3eStepPanelElement extends M3eStepPanelElement_base {
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @internal */
    active: boolean;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-step-panel": M3eStepPanelElement;
    }
}
export {};
//# sourceMappingURL=StepPanelElement.d.ts.map