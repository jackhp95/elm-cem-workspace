import { LitElement } from "lit";
import { Constructor } from "./Constructor";
import { AttachInternalsMixin } from "./AttachInternals";
/** Defines functionality for an element that can be marked as touched. */
export interface TouchedMixin {
    /** Whether the user has interacted when the element. */
    readonly touched: boolean;
    /** Whether the user has not interacted when the element. */
    readonly untouched: boolean;
    /** Marks the element as touched. */
    markAsTouched(): void;
    /** Marks the element as untouched. */
    markAsUntouched(): void;
}
/**
 * Determines whether a value is a `TouchedMixin`.
 * @param {unknown} value The value to test.
 * @returns A value indicating whether `value` is a `TouchedMixin`.
 */
export declare function isTouchedMixin(value: unknown): value is TouchedMixin;
/**
 * Mixin to augment an element with functionality used to mark it as touched.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<TouchedMixin> & T} A constructor that implements `TouchedMixin`.
 */
export declare function Touched<T extends Constructor<LitElement & AttachInternalsMixin>>(base: T): Constructor<TouchedMixin> & T;
//# sourceMappingURL=Touched.d.ts.map