/**
 * Adapted from Angular Material Form Field
 * Source: https://github.com/angular/components/blob/main/src/material/form-field/form-field.ts
 *
 * @license MIT
 * Copyright (c) 2025 Google LLC
 * See LICENSE file in the project root for full license text.
 */
import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { FormFieldControl } from "./FormFieldControl";
import { FormFieldVariant } from "./FormFieldVariant";
import { HideSubscriptType } from "./HideSubscriptType";
import { FloatLabelType } from "./FloatLabelType";
declare const M3eFormFieldElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A container for form controls that applies Material Design styling and behavior.
 *
 * @description
 * The `m3e-form-field` component is a semantic, expressive container for form controls that anchors
 * label behavior, subscript messaging, and variant-specific layout. Designed according to Material Design 3
 * guidelines, it supports two visual variants—`outlined` and `filled`—each with dynamic elevation,
 * shape transitions, and adaptive color theming. The component responds to control state changes
 * (focus, hover, press, disabled, invalid) with smooth motion and semantic clarity, ensuring
 * visual hierarchy and emotional resonance.

 * The component is accessible by default, with ARIA annotations, contrast-safe color tokens,
 * and dynamic descriptions for hint and error messaging. It supports prefix and suffix content,
 * floating labels, and adaptive subscript visibility. When hosting a control with validation,
 * error messages are surfaced with `aria-invalid` and described for assistive technology.

 * Native form controls may not expose full state or messaging on their own. `m3e-form-field` bridges
 * these gaps by coordinating label floating, container styling, and subscript feedback.
 *
 * @example
 * The following example illustrates a basic usage of the `m3e-form-field`.
 * ```html
 * <m3e-form-field>
 *  <label slot="label" for="field">Text field</label>
 *  <input id="field" />
 * </m3e-form-field>
 * ```
 *
 * @tag m3e-form-field
 *
 * @slot - Renders the control of the field.
 * @slot prefix - Renders content before the fields's control.
 * @slot prefix-text - Renders text before the fields's control.
 * @slot suffix - Renders content after the fields's control.
 * @slot suffix-text - Renders text after the fields's control.
 * @slot hint - Renders hint text in the fields's subscript, when the control is valid.
 * @slot error - Renders error text in the fields's subscript, when the control is invalid.
 *
 * @attr float-label - Specifies whether the label should float always or only when necessary.
 * @attr hide-required-marker - Whether the required marker should be hidden.
 * @attr hide-subscript - Whether subscript content is hidden.
 * @attr variant - The appearance variant of the field.
 *
 * @cssprop --m3e-form-field-font-size - Font size for the form field container text.
 * @cssprop --m3e-form-field-font-weight - Font weight for the form field container text.
 * @cssprop --m3e-form-field-line-height - Line height for the form field container text.
 * @cssprop --m3e-form-field-tracking - Letter spacing for the form field container text.
 * @cssprop --m3e-form-field-label-font-size - Font size for the floating label.
 * @cssprop --m3e-form-field-label-font-weight - Font weight for the floating label.
 * @cssprop --m3e-form-field-label-line-height - Line height for the floating label.
 * @cssprop --m3e-form-field-label-tracking - Letter spacing for the floating label.
 * @cssprop --m3e-form-field-subscript-font-size - Font size for hint and error text.
 * @cssprop --m3e-form-field-subscript-font-weight - Font weight for hint and error text.
 * @cssprop --m3e-form-field-subscript-line-height - Line height for hint and error text.
 * @cssprop --m3e-form-field-subscript-tracking - Letter spacing for hint and error text.
 * @cssprop --m3e-form-field-color - Text color for the form field container.
 * @cssprop --m3e-form-field-subscript-color - Color for hint and error text.
 * @cssprop --m3e-form-field-invalid-color - Color used when the control is invalid.
 * @cssprop --m3e-form-field-focused-outline-color - Outline color when focused.
 * @cssprop --m3e-form-field-focused-color - Label color when focused.
 * @cssprop --m3e-form-field-outline-color - Outline color in outlined variant.
 * @cssprop --m3e-form-field-container-color - Background color in filled variant.
 * @cssprop --m3e-form-field-hover-container-color - Hover background color in filled variant.
 * @cssprop --m3e-form-field-width - Width of the form field container.
 * @cssprop --m3e-form-field-icon-size - Size of prefix and suffix icons.
 * @cssprop --m3e-outlined-form-field-container-shape - Corner radius for outlined container.
 * @cssprop --m3e-form-field-container-shape - Corner radius for filled container.
 * @cssprop --m3e-form-field-hover-container-opacity - Opacity for hover background in filled variant.
 * @cssprop --m3e-form-field-disabled-opacity - Opacity for disabled text.
 * @cssprop --m3e-form-field-disabled-container-opacity - Opacity for disabled container background.
 */
export declare class M3eFormFieldElement extends M3eFormFieldElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _base;
    /** @private */ private readonly _prefix;
    /** @private */ private readonly _suffix;
    /** @private */ private readonly _error;
    /** @private */ private readonly _hint;
    /** @private */ private _pseudoLabel;
    /** @private */ private _required;
    /** @private */ private _invalid;
    /** @private */ private _validationMessage;
    constructor();
    /** A reference to the element used to anchor dropdown menus. */
    get menuAnchor(): HTMLElement;
    /** A reference to the hosted form field control. */
    get control(): FormFieldControl | null;
    /**
     * The appearance variant of the field.
     * @default "outlined"
     */
    variant: FormFieldVariant;
    /**
     * Whether the required marker should be hidden.
     * @default false
     */
    hideRequiredMarker: boolean;
    /**
     * Whether subscript content is hidden.
     * @default "auto"
     */
    hideSubscript: HideSubscriptType;
    /**
     * Specifies whether the label should float always or only when necessary.
     * @default "auto"
     */
    floatLabel: FloatLabelType;
    /**
     * Notifies the form field that the state of the hosted `control` has changed.
     * @param {boolean} [checkValidity=false] Whether to check validity.
     */
    notifyControlStateChange(checkValidity?: boolean): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-form-field": M3eFormFieldElement;
    }
}
export {};
//# sourceMappingURL=FormFieldElement.d.ts.map