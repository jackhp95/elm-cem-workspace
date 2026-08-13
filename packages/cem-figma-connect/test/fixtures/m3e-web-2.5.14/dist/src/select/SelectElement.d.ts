import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { formValue } from "@m3e/web/core";
import type { FormFieldControl } from "@m3e/web/form-field";
import { M3eOptionElement } from "@m3e/web/option";
declare const M3eSelectElement_base: import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LabelledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").RequiredConstraintValidationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DirtyMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").TouchedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").RequiredMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ConstraintValidationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").FormAssociatedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A form control that allows users to select a value from a set of predefined options.
 *
 * @description
 * The `m3e-select` component follows Material Design 3 principles and provides a comprehensive
 * selection interface for capturing user input. It supports both single and multiple selection modes,
 * customizable validation states, and accessible keyboard navigation. The component integrates seamlessly
 * with form field containers and dynamically positions its option list menu to ensure optimal viewport
 * visibility. Selection changes are communicated through standard form events, enabling predictable integration
 * with form submission and reactive state management systems.
 *
 * @example
 * The following demonstrates a `m3e-select` component wrapped in a `m3e-form-field` with a slotted label.
 * The label is associated with the select via the `for` and `id` attributes, ensuring accessible form semantics.
 * Each `m3e-option` defines an option within the dropdown.
 *
 * ```html
 * <m3e-form-field>
 *   <label slot="label" for="select">Choose your favorite fruit</label>
 *   <m3e-select id="select">
 *     <m3e-option>Apples</m3e-option>
 *     <m3e-option>Oranges</m3e-option>
 *     <m3e-option>Bananas</m3e-option>
 *     <m3e-option>Grapes</m3e-option>
 *   </m3e-select>
 * </m3e-form-field>
 * ```
 *
 * @tag m3e-select
 *
 * @slot - Renders the options of the select.
 * @slot arrow - Renders the dropdown arrow.
 * @slot value - Renders the selected value(s).
 *
 * @attr disabled - Whether the element is disabled.
 * @attr hide-selection-indicator - Whether to hide the selection indicator for single select options.
 * @attr multi - Whether multiple options can be selected.
 * @attr name - The name that identifies the element when submitting the associated form.
 * @attr panel-class - Class or list of classes to be applied to the select's overlay panel.
 * @attr required - Whether the element is required.
 *
 * @fires beforeinput - Dispatched before the selected state changes.
 * @fires input - Dispatched when the selected state changes.
 * @fires change - Dispatched when the selected state changes.
 *
 * @cssprop --m3e-form-field-font-size - The font size of the select control.
 * @cssprop --m3e-form-field-font-weight - The font weight of the select control.
 * @cssprop --m3e-form-field-line-height - The line height of the select control.
 * @cssprop --m3e-form-field-tracking - The letter spacing of the select control.
 * @cssprop --m3e-select-container-shape - The corner radius of the select container.
 * @cssprop --m3e-select-disabled-color - The text color when the select is disabled.
 * @cssprop --m3e-select-disabled-color-opacity - The opacity level applied to the disabled text color.
 * @cssprop --m3e-select-icon-size - The size of the dropdown arrow icon.
 */
export declare class M3eSelectElement extends M3eSelectElement_base implements FormFieldControl {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ static __nextId: number;
    /** @private */ private _options;
    /** @private */ private readonly _listKeyManager;
    /** @private */ private readonly _focusRing?;
    constructor();
    /**
     * Whether to hide the selection indicator for single select options.
     * @default false
     */
    hideSelectionIndicator: boolean;
    /**
     * Whether multiple options can be selected.
     * @default false
     */
    multi: boolean;
    /**
     * Class or list of classes to be applied to the select's overlay panel.
     * @default ""
     */
    panelClass: string;
    /** The options that can be selected. */
    get options(): readonly M3eOptionElement[];
    /** The selected option(s). */
    get selected(): readonly M3eOptionElement[];
    /** The selected (enabled) value(s). */
    get value(): string | readonly string[] | null;
    /** @inheritdoc @internal */
    get [formValue](): string | FormData | null;
    /** @inheritdoc */
    get shouldLabelFloat(): boolean;
    /** @inheritdoc */
    onContainerClick(): void;
    /**
     * Clears the value of the element.
     * @param [restoreFocus=false] Whether to restore input focus.
     */
    clear(restoreFocus?: boolean): void;
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
interface M3eSelectElementEventMap extends HTMLElementEventMap {
    toggle: ToggleEvent;
}
export interface M3eSelectElement {
    addEventListener<K extends keyof M3eSelectElementEventMap>(type: K, listener: (this: M3eSelectElement, ev: M3eSelectElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eSelectElementEventMap>(type: K, listener: (this: M3eSelectElement, ev: M3eSelectElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-select": M3eSelectElement;
    }
}
export {};
//# sourceMappingURL=SelectElement.d.ts.map