import { LitElement } from "lit";
import { Constructor } from "./Constructor";
/** A symbol through which to access the `ElementInternals` attached to an element. */
export declare const internals: unique symbol;
/** Defines functionality for an element attached to `ElementInternals`. */
export interface AttachInternalsMixin {
    /** The `ElementInternals` attached to the element. */
    readonly [internals]: ElementInternals;
}
/**
 * Determines whether a value is an `AttachInternalsMixin`.
 * @param {unknown} value The value to test.
 * @returns Whether `value` is an `AttachInternalsMixin`.
 */
export declare function isAttachInternalsMixin(value: unknown): value is AttachInternalsMixin;
/**
 * Mixin to augment an element with behavior that attaches to `ElementInternals`.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @param {boolean | undefined} formAssociated Whether the element is "Form Associated".
 * @returns {Constructor<AttachInternalsMixin> & T} A constructor that implements `AttachInternalsMixin`.
 */
export declare function AttachInternals<T extends Constructor<LitElement>>(base: T, formAssociated?: boolean): Constructor<AttachInternalsMixin> & T;
/**
 * Convenience function used to test whether an element has a given custom state.
 * @param {AttachInternalsMixin} element The element to test.
 * @param {string} state The custom state to test.
 * @returns {boolean} Whether `element` has `state`.
 */
export declare function hasCustomState(element: AttachInternalsMixin, state: string): boolean;
/**
 * Convenience function used to add custom state to an element.
 * @param {AttachInternalsMixin} element The element to which to add custom state.
 * @param {string} state The custom state to add.
 */
export declare function addCustomState(element: AttachInternalsMixin, state: string): void;
/**
 * Convenience function used to delete custom state from an element.
 * @param {AttachInternalsMixin} element The element from which to delete custom state.
 * @param {string} state The custom state to delete.
 * @returns {boolean} Whether `state` was removed from `element`.
 */
export declare function deleteCustomState(element: AttachInternalsMixin, state: string): boolean;
/**
 * Convenience function used to add or delete custom state for an element.
 * @param {AttachInternalsMixin} element The element for which to add or delete custom state.
 * @param {string} state The custom state to add or delete.
 * @param {boolean} value Whether to add or delete `state` from `element`.
 */
export declare function setCustomState(element: AttachInternalsMixin, state: string, value: boolean): void;
//# sourceMappingURL=AttachInternals.d.ts.map