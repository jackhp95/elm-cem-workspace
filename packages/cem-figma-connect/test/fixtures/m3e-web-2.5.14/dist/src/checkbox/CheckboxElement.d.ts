import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { formValue } from "@m3e/web/core";
declare const M3eCheckboxElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LabelledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").RequiredConstraintValidationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DirtyMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").TouchedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").RequiredMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ConstraintValidationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").CheckedIndeterminateMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").FormAssociatedMixin> & import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A checkbox that allows a user to select one or more options from a limited number of choices.
 *
 * @description
 * The `m3e-checkbox` component enables users to select one or more options from a set. It supports selected,
 * unselected, and indeterminate states, and communicates selection through visual cues and accessible semantics.
 * This component reflects user intent, form participation, and validation feedback, adapting to disabled and
 * required contexts. It emits `input` and `change` events to signal state transitions and integrates with form
 * submission via `name` and `value`.
 *
 * @example
 * The following example illustrates wrapping a `m3e-checkbox` within a `label`.
 * ```html
 * <label>
 *  <m3e-checkbox></m3e-checkbox>
 *  Checkbox label
 * </label>
 * ```
 * @example
 * The next example illustrates use of the `for` attribute to label a checkbox.
 * ```html
 * <m3e-checkbox id="chk"></m3e-checkbox>
 * <label for="chk">Checkbox label </label>
 * ```
 *
 * @tag m3e-checkbox
 *
 * @attr checked - Whether the element is checked.
 * @attr disabled - Whether the element is disabled.
 * @attr indeterminate - Whether the element's checked state is indeterminate.
 * @attr name - The name that identifies the element when submitting the associated form.
 * @attr required - Whether the element is required.
 * @attr value - A string representing the value of the checkbox.
 *
 * @fires beforeinput - Dispatched before the checked state changes.
 * @fires input - Dispatched when the checked state changes.
 * @fires invalid - Dispatched when a form is submitted and the element fails constraint validation.
 * @fires change - Dispatched when the checked state changes.
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-checkbox-icon-size - Size of the checkbox icon inside the container.
 * @cssprop --m3e-checkbox-container-size - Base size of the checkbox container.
 * @cssprop --m3e-checkbox-container-shape - Border radius of the icon container.
 * @cssprop --m3e-checkbox-unselected-outline-thickness - Border thickness for unselected state.
 * @cssprop --m3e-checkbox-unselected-outline-color - Border color for unselected state.
 * @cssprop --m3e-checkbox-unselected-hover-outline-color - Border color on hover when unselected.
 * @cssprop --m3e-checkbox-unselected-disabled-outline-color - Base color for disabled unselected outline.
 * @cssprop --m3e-checkbox-unselected-disabled-outline-opacity - Opacity for disabled unselected outline.
 * @cssprop --m3e-checkbox-unselected-error-outline-color - Border color for invalid unselected state.
 * @cssprop --m3e-checkbox-selected-container-color - Background color for selected container.
 * @cssprop --m3e-checkbox-selected-icon-color - Icon color for selected state.
 * @cssprop --m3e-checkbox-selected-disabled-container-color - Base color for disabled selected container.
 * @cssprop --m3e-checkbox-selected-disabled-container-opacity - Opacity for disabled selected container.
 * @cssprop --m3e-checkbox-selected-disabled-icon-color - Base color for disabled selected icon.
 * @cssprop --m3e-checkbox-selected-disabled-icon-opacity - Opacity for disabled selected icon.
 * @cssprop --m3e-checkbox-unselected-hover-color - Ripple hover color for unselected state.
 * @cssprop --m3e-checkbox-unselected-focus-color - Ripple focus color for unselected state.
 * @cssprop --m3e-checkbox-unselected-ripple-color - Ripple base color for unselected state.
 * @cssprop --m3e-checkbox-selected-hover-color - Ripple hover color for selected state.
 * @cssprop --m3e-checkbox-selected-focus-color - Ripple focus color for selected state.
 * @cssprop --m3e-checkbox-selected-ripple-color - Ripple base color for selected state.
 * @cssprop --m3e-checkbox-unselected-error-hover-color - Ripple hover color for invalid unselected state.
 * @cssprop --m3e-checkbox-unselected-error-focus-color - Ripple focus color for invalid unselected state.
 * @cssprop --m3e-checkbox-unselected-error-ripple-color - Ripple base color for invalid unselected state.
 * @cssprop --m3e-checkbox-selected-error-hover-color - Ripple hover color for invalid selected state.
 * @cssprop --m3e-checkbox-selected-error-focus-color - Ripple focus color for invalid selected state.
 * @cssprop --m3e-checkbox-selected-error-ripple-color - Ripple base color for invalid selected state.
 */
export declare class M3eCheckboxElement extends M3eCheckboxElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /** @private */ private readonly _ripple?;
    /**
     * A string representing the value of the checkbox.
     * @default "on"
     */
    value: string;
    /** @inheritdoc @private */
    get [formValue](): string | File | FormData | null;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-checkbox": M3eCheckboxElement;
    }
}
export {};
//# sourceMappingURL=CheckboxElement.d.ts.map