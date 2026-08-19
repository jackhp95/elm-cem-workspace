import { LitElement } from "lit";
import { Constructor } from "./Constructor";
/** Defines functionality for an element which supports a read-only state. */
export interface ReadOnlyMixin {
    /**
     * A value indicating whether the element is read-only.
     * @default false
     */
    readOnly: boolean;
}
/**
 * Determines whether a value is a `ReadOnlyMixin`.
 * @param {unknown} value The value to test.
 * @returns A value indicating whether `value` is a `ReadOnlyMixin`.
 */
export declare function isReadOnlyMixin(value: unknown): value is ReadOnlyMixin;
/**
 * Mixin to augment an element with behavior that supports a read-only state.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @param {boolean} reflect A value indicating whether the read-only state is reflected as an attribute. The default value is `true`.
 * @returns {Constructor<ReadOnlyMixin> & T} A constructor that implements `ReadOnlyMixin`.
 */
export declare function ReadOnly<T extends Constructor<LitElement>>(base: T, reflect?: boolean): Constructor<ReadOnlyMixin> & T;
//# sourceMappingURL=ReadOnly.d.ts.map