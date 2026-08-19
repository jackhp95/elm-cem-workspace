import { LitElement } from "lit";
import { CheckedMixin } from "./Checked";
import { Constructor } from "./Constructor";
/** Defines functionality for an element which supports a mixed checked state. */
export interface CheckedIndeterminateMixin extends CheckedMixin {
    /**
     * Whether the element's checked state is indeterminate.
     * @default false
     */
    indeterminate: boolean;
}
/**
 * Determines whether a value is a `CheckedIndeterminateMixin`.
 * @param {unknown} value The value to test.
 * @returns Whether `value` is a `CheckedIndeterminateMixin`.
 */
export declare function isCheckedIndeterminateMixin(value: unknown): value is CheckedIndeterminateMixin;
/**
 * Mixin to augment an element with behavior that supports a mixed checked state.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<CheckedIndeterminateMixin> & T} A constructor that implements `CheckedIndeterminateMixin`.
 */
export declare function CheckedIndeterminate<T extends Constructor<LitElement>>(base: T): Constructor<CheckedIndeterminateMixin> & T;
//# sourceMappingURL=CheckedIndeterminate.d.ts.map