import { LitElement } from "lit";
import { AttachInternalsMixin } from "./AttachInternals";
import { Constructor } from "./Constructor";
/** Specifies the form submission behaviors. */
export type FormSubmitterType = "button" | "submit" | "reset";
/** Defines functionality for an element which can be used to submit a form. */
export interface FormSubmitterMixin extends AttachInternalsMixin {
    /**
     * The name of the element, submitted as a pair with the element's `value`
     * as part of form data, when the element is used to submit a form.
     */
    name: string;
    /** The value associated with the element's name when it's submitted with form data. */
    value: string | null;
    /**
     * The type of the element.
     * @default "button"
     */
    type: FormSubmitterType;
}
/**
 * Determines whether a value is a `FormSubmitterMixin`.
 * @param {unknown} value The value to test.
 * @returns {value is FormSubmitterMixin} Whether `value` is a `FormSubmitterMixin`.
 */
export declare function isFormSubmitterMixin(value: unknown): value is FormSubmitterMixin;
/**
 * Mixin to augment an element with behavior used to submit a form.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<FormSubmitterMixin>} A constructor that implements `FormSubmitterMixin`.
 */
export declare function FormSubmitter<T extends Constructor<LitElement & AttachInternalsMixin>>(base: T): Constructor<FormSubmitterMixin> & T;
//# sourceMappingURL=FormSubmitter.d.ts.map