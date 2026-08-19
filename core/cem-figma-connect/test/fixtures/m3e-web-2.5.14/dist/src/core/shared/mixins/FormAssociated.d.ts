import { LitElement } from "lit";
import { AttachInternalsMixin } from "./AttachInternals";
import { Constructor } from "./Constructor";
import { DisabledMixin } from "./Disabled";
import { LabelledMixin } from "./Labelled";
/** A symbol through which a "Form Associated" custom element provides a value for a form. */
export declare const formValue: unique symbol;
/** A symbol through which a "Form Associated" custom element provides a default value for resetting a form. */
export declare const defaultValue: unique symbol;
/** Defines functionality for a "Form Associated" custom element. */
export interface FormAssociatedMixin extends LabelledMixin, DisabledMixin, AttachInternalsMixin {
    /** The `HTMLFormElement` associated with this element. */
    readonly form: HTMLFormElement | null;
    /** The form value of the element. */
    readonly [formValue]: string | File | FormData | null;
    /** The default value (value or checked state) of the element. */
    readonly [defaultValue]: unknown;
    /** The name that identifies the element when submitting the associated form. */
    name: string;
}
/**
 * Determines whether a value is a `FormAssociatedMixin`.
 * @param {unknown} value The value to test.
 * @returns A value indicating whether `value` is a `FormAssociatedMixin`.
 */
export declare function isFormAssociatedMixin(value: unknown): value is FormAssociatedMixin;
/**
 * Mixin to augment an element with "Form Associated" behavior.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<FormAssociatedMixin> & T} A constructor that implements `FormAssociatedMixin`.
 */
export declare function FormAssociated<T extends Constructor<LitElement & DisabledMixin & AttachInternalsMixin>>(base: T): Constructor<FormAssociatedMixin> & T;
//# sourceMappingURL=FormAssociated.d.ts.map