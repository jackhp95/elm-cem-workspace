import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { SelectionManager, selectionManager } from "@m3e/web/core/a11y";
import { M3eRadioElement } from "./RadioElement";
declare const M3eRadioGroupElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LabelledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").RequiredConstraintValidationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DirtyMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").TouchedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").RequiredMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ConstraintValidationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").FormAssociatedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A container for a set of radio buttons.
 *
 * @description
 * The `m3e-radio-group` component is a semantic container that orchestrates a set of `m3e-radio` elements.
 * It provides accessible grouping, keyboard navigation, and validation logic for mutually exclusive selection.
 * When marked as `required`, the group enforces selection constraints and reflects validation state, while
 * delegating form submission to the checked radio. The group does not submit a value itself—it coordinates
 * behavior, focus, and feedback across its radios.
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
 * @tag m3e-radio-group
 *
 * @slot - Renders the radio buttons of the group.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr name - The name that identifies the element when submitting the associated form.
 * @attr required - Whether the element is required.
 *
 * @fires beforeinput - Dispatched before the checked state of a radio button changes.
 * @fires input - Dispatched when the checked state of a radio button changes.
 * @fires change - Dispatched when the checked state of a radio button changes.
 */
export declare class M3eRadioGroupElement extends M3eRadioGroupElement_base {
    #private;
    /** The list of attributes corresponding to the registered properties. */
    static get observedAttributes(): string[];
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @internal */
    readonly [selectionManager]: SelectionManager<M3eRadioElement>;
    /** The radios in the group. */
    get radios(): readonly M3eRadioElement[];
    /** The selected radio. */
    get selected(): M3eRadioElement | null;
    /** The selected value of the radio group. */
    get value(): string | null;
    /** @inheritdoc */
    markAsTouched(): void;
    /** @inheritdoc */
    markAsUntouched(): void;
    /** @inheritdoc */
    markAsDirty(): void;
    /** @inheritdoc */
    markAsPristine(): void;
    /** Synchronizes property values when attributes change. */
    attributeChangedCallback(name: string, oldValue: string | null, newValue: string | null): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-radio-group": M3eRadioGroupElement;
    }
}
export {};
//# sourceMappingURL=RadioGroupElement.d.ts.map