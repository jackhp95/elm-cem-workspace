import { CSSResultGroup, PropertyValues } from "lit";
import { formValue } from "@m3e/web/core";
import { FormFieldControl } from "@m3e/web/form-field";
import { M3eChipSetElement } from "./ChipSetElement";
import { M3eInputChipElement } from "./InputChipElement";
import { InputChipSetChangeEventDetail } from "./InputChipSetChangeEventDetail";
declare const M3eInputChipSetElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").RequiredConstraintValidationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").RequiredMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ConstraintValidationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DirtyMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").TouchedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").FormAssociatedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof M3eChipSetElement;
/**
 * A container that transforms user input into a cohesive set of interactive chips, supporting entry, editing, and removal of discrete values.
 *
 * @description
 * The `m3e-input-chip-set` component enables users to input, display, and manage a collection of discrete
 * values as input chips. Designed for expressive, accessible forms, it supports keyboard navigation, validation,
 * and seamless integration with form controls. This component is ideal for capturing user-generated tags,
 * keywords, or selections in a visually consistent and interactive manner.
 *
 * @example
 * The following example illustrates the use of the `m3e-input-chip-set` inside a `m3e-form-field`.
 * In this example, the `input` slot specifies the `input` element used to add input chips and the
 * field label's `for` attribute targets the `input` element to provide an accessible label.
 * ```html
 * <m3e-form-field>
 *  <label slot="label" for="keywords">Keywords</label>
 *  <m3e-input-chip-set aria-label="Enter keywords">
 *    <input id="keywords" slot="input" placeholder="New keyword..." />
 *  </m3e-input-chip-set>
 * </m3e-form-field>
 * ```
 *
 * @tag m3e-input-chip-set
 *
 * @slot - Renders the chips of the set.
 * @slot input - Renders the input element used to add new chips to the set.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr name - The name that identifies the element when submitting the associated form.
 * @attr required - Whether a value is required for the element.
 * @attr vertical - Whether the element is oriented vertically.
 *
 * @fires change - Dispatched when a chip is added to, or removed from, the set.
 *
 * @cssprop --m3e-chip-set-spacing - The spacing (gap) between chips in the set.
 */
export declare class M3eInputChipSetElement extends M3eInputChipSetElement_base implements FormFieldControl {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** The chips of the set. */
    get chips(): readonly M3eInputChipElement[];
    /** The values of the set. */
    get value(): readonly string[] | null;
    /** @inheritdoc @internal */
    get [formValue](): FormData | null;
    /** @inheritdoc */
    get shouldLabelFloat(): boolean;
    /** @inheritdoc */
    onContainerClick(): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
interface M3eInputChipSetElementEventMap extends HTMLElementEventMap {
    change: CustomEvent<InputChipSetChangeEventDetail>;
}
export interface M3eInputChipSetElement {
    addEventListener<K extends keyof M3eInputChipSetElementEventMap>(type: K, listener: (this: M3eInputChipSetElement, ev: M3eInputChipSetElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eInputChipSetElementEventMap>(type: K, listener: (this: M3eInputChipSetElement, ev: M3eInputChipSetElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-input-chip-set": M3eInputChipSetElement;
    }
}
export {};
//# sourceMappingURL=InputChipSetElement.d.ts.map