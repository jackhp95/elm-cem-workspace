import { LitElement } from "lit";
import { AttachInternalsMixin } from "./AttachInternals";
import { Constructor } from "./Constructor";
/** Defines functionality for an element that can be marked as dirty. */
export interface DirtyMixin {
    /** Whether the user has not modified the value of the element. */
    readonly pristine: boolean;
    /** Whether the user has modified the value of the element. */
    readonly dirty: boolean;
    /** Marks the element as pristine. */
    markAsPristine(): void;
    /** Marks the element as dirty. */
    markAsDirty(): void;
}
/**
 * Determines whether a value is a `DirtyMixin`.
 * @param {unknown} value The value to test.
 * @returns A value indicating whether `value` is a `DirtyMixin`.
 */
export declare function isDirtyMixin(value: unknown): value is DirtyMixin;
/**
 * Mixin to augment an element with functionality used to mark it as dirty.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<DirtyMixin> & T} A constructor that implements `DirtyMixin`.
 */
export declare function Dirty<T extends Constructor<LitElement & AttachInternalsMixin>>(base: T): Constructor<DirtyMixin> & T;
//# sourceMappingURL=Dirty.d.ts.map