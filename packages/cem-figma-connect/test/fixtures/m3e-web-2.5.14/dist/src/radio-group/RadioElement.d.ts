import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { formValue } from "@m3e/web/core";
declare const M3eRadioElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LabelledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DirtyMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").TouchedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").CheckedMixin> & import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").FormAssociatedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A radio button that allows a user to select one option from a set of options.
 *
 * @description
 * The `m3e-radio` component represents a radio button that enables users to select an options from a set.
 * It supports selection from mutually exclusive options, emitting `input` and `change` events when its state updates.
 * The component reflects its state through customizable CSS properties for hover, focus, ripple, and icon styling—
 * adapting dynamically based on whether it is selected, unselected, or disabled.
 *
 * Attributes like `checked`, `disabled`, and `value` control its behavior and accessibility, while its visual
 * presentation can be tuned via design tokens such as `--m3e-radio-container-size` and `--m3e-radio-icon-size`.
 *
 * @example
 * The following example illustrates using `m3e-radio-group` and `m3e-radio` to present a group of options.
 * ```html
 * <label for="rdg1">Radio group</label>
 * <br />
 * <m3e-radio-group id="rdg1">
 *  <label><m3e-radio value="1"></m3e-radio> Value 1</label>
 *  <label><m3e-radio value="2"></m3e-radio> Value 2</label>
 *  <label><m3e-radio value="3"></m3e-radio> Value 3</label>
 *  <label><m3e-radio value="4"></m3e-radio> Value 4</label>
 * </m3e-radio-group>
 * ```
 *
 * @tag m3e-radio
 *
 * @attr checked - Whether the element is checked.
 * @attr disabled - Whether the element is disabled.
 * @attr name - The name that identifies the element when submitting the associated form.
 * @attr required - Whether the element is required.
 * @attr value - A string representing the value of the radio.
 *
 * @fires beforeinput - Dispatched before the checked state changes.
 * @fires input - Dispatched when the checked state changes.
 * @fires change - Dispatched when the checked state changes.
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-radio-container-size - Base size of the radio button container.
 * @cssprop --m3e-radio-icon-size - Size of the radio icon inside the wrapper.
 * @cssprop --m3e-radio-unselected-hover-color - Hover state layer color when radio is not selected.
 * @cssprop --m3e-radio-unselected-focus-color - Focus state layer color when radio is not selected.
 * @cssprop --m3e-radio-unselected-ripple-color - Ripple color when radio is not selected.
 * @cssprop --m3e-radio-unselected-icon-color - Icon color when radio is not selected.
 * @cssprop --m3e-radio-selected-hover-color - Hover state layer color when radio is selected.
 * @cssprop --m3e-radio-selected-focus-color - Focus state layer color when radio is selected.
 * @cssprop --m3e-radio-selected-ripple-color - Ripple color when radio is selected.
 * @cssprop --m3e-radio-selected-icon-color - Icon color when radio is selected.
 * @cssprop --m3e-radio-disabled-icon-color - Icon color when radio is disabled.
 * @cssprop --m3e-radio-error-hover-color - Fallback hover color used when the radio is invalid and touched.
 * @cssprop --m3e-radio-error-focus-color - Fallback focus color used when the radio is invalid and touched.
 * @cssprop --m3e-radio-error-ripple-color - Fallback ripple color used when the radio is invalid and touched.
 * @cssprop --m3e-radio-error-icon-color - Fallback icon color used when the radio is invalid and touched.
 */
export declare class M3eRadioElement extends M3eRadioElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /** @private */ private readonly _ripple?;
    /**
     * A string representing the value of the radio.
     * @default "on"
     */
    value: string;
    /** @inheritdoc @internal */
    get [formValue](): string | File | FormData | null;
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
        "m3e-radio": M3eRadioElement;
    }
}
export {};
//# sourceMappingURL=RadioElement.d.ts.map