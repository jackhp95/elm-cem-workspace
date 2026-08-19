import { LitElement } from "lit";
import { Constructor } from "./Constructor";
import { ConstraintValidationMixin } from "./ConstraintValidation";
import { RequiredMixin } from "./Required";
/** Defines functionality for an element which supports validating a required state. */
export interface RequiredConstraintValidationMixin extends RequiredMixin, ConstraintValidationMixin {
}
/**
 * Determines whether a value is a `RequiredConstraintValidationMixin`.
 * @param {unknown} value The value to test.
 * @returns A value indicating whether `value` is a `RequiredConstraintValidationMixin`.
 */
export declare function isRequiredConstraintValidationMixin(value: unknown): value is RequiredConstraintValidationMixin;
/**
 * Mixin to augment an element with behavior that supports a required state.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<RequiredConstraintValidationMixin> & T} A constructor that implements `RequiredConstraintValidationMixin`.
 */
export declare function RequiredConstraintValidation<T extends Constructor<LitElement & RequiredMixin & ConstraintValidationMixin>>(base: T): Constructor<RequiredConstraintValidationMixin> & T;
//# sourceMappingURL=RequiredConstraintValidation.d.ts.map