import { LitElement } from "lit";
import { Constructor } from "./Constructor";
/** Defines functionality for an element which supports a checked state. */
export interface CheckedMixin {
    /**
     * Whether the element is checked.
     * @default false
     */
    checked: boolean;
}
/**
 * Determines whether a value is a `CheckedMixin`.
 * @param {unknown} value The value to test.
 * @returns Whether `value` is a `CheckedMixin`.
 */
export declare function isCheckedMixin(value: unknown): value is CheckedMixin;
/**
 * Mixin to augment an element with behavior that supports a checked state.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<CheckedMixin> & T} A constructor that implements `CheckedMixin`.
 */
export declare function Checked<T extends Constructor<LitElement>>(base: T): Constructor<CheckedMixin> & T;
//# sourceMappingURL=Checked.d.ts.map