import { LitElement } from "lit";
import { Constructor } from "./Constructor";
/** Defines functionality for an element which supports a required state. */
export interface RequiredMixin {
    /**
     * Whether a value is required for the element.
     * @default false
     */
    required: boolean;
    /** Whether a value is not required for the element. */
    readonly optional: boolean;
}
/**
 * Determines whether a value is a `RequiredMixin`.
 * @param {unknown} value The value to test.
 * @returns A value indicating whether `value` is a `RequiredMixin`.
 */
export declare function isRequiredMixin(value: unknown): value is RequiredMixin;
/**
 * Mixin to augment an element with behavior that supports a required state.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<RequiredMixin> & T} A constructor that implements `RequiredMixin`.
 */
export declare function Required<T extends Constructor<LitElement>>(base: T): Constructor<RequiredMixin> & T;
//# sourceMappingURL=Required.d.ts.map