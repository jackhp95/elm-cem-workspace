import { LitElement } from "lit";
import { Constructor } from "./Constructor";
import { FormAssociatedMixin } from "./FormAssociated";
/** A symbol through which a "Form Associated" custom element validates its current state. */
export declare const validate: unique symbol;
/** Defines functionality for a "Form Associated" custom element that supports constraint validation. */
export interface ConstraintValidationMixin extends FormAssociatedMixin {
    /** Whether the element is a submittable element that is a candidate for constraint validation. */
    readonly willValidate: boolean;
    /** The validity state of the element. */
    readonly validity: ValidityState;
    /** The error message that would be displayed if the user submits the form, or an empty string if no error message. */
    readonly validationMessage: string;
    /**
     * Validates the current state of the control.
     * @returns {ValidityStateFlags | undefined} The current validity state.
     */
    [validate](): ValidityStateFlags | undefined;
    /**
     * Returns `true` if the element has no validity problems; otherwise, returns `false`, fires
     * an invalid event, and (if the event isn't canceled) reports the problem to the user.
     */
    reportValidity(): boolean;
    /**
     * Returns `true` if the element has no validity problems; otherwise,
     * returns `false`, fires an invalid event.
     */
    checkValidity(): boolean;
    /**
     * Sets a custom validity message for the element.
     * @param error The message to use for validity errors.
     */
    setCustomValidity(error: string): void;
}
/**
 * Determines whether a value is a `ConstraintValidationMixin`.
 * @param {unknown} value The value to test.
 * @returns Whether `value` is a `ConstraintValidationMixin`.
 */
export declare function isConstraintValidationMixin(value: unknown): value is ConstraintValidationMixin;
/**
 * Mixin to augment an element with "Form Associated" behavior that supports constraint validation.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<ConstraintValidationMixin> & T} A constructor that implements `ConstraintValidationMixin`.
 */
export declare function ConstraintValidation<T extends Constructor<LitElement & FormAssociatedMixin>>(base: T): Constructor<ConstraintValidationMixin> & T;
//# sourceMappingURL=ConstraintValidation.d.ts.map