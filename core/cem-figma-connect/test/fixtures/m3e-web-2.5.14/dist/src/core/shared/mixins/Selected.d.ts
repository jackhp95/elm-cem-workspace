import { LitElement } from "lit";
import { Constructor } from "./Constructor";
/** Defines functionality for an element which supports a selected state. */
export interface SelectedMixin {
    /**
     * Whether the element is selected.
     * @default false
     */
    selected: boolean;
}
/**
 * Determines whether a value is a `SelectedMixin`.
 * @param {unknown} value The value to test.
 * @returns Whether `value` is a `SelectedMixin`.
 */
export declare function isSelectedMixin(value: unknown): value is SelectedMixin;
/**
 * Mixin to augment an element with behavior that supports a selected state.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<SelectedMixin> & T} A constructor that implements `SelectedMixin`.
 */
export declare function Selected<T extends Constructor<LitElement>>(base: T): Constructor<SelectedMixin> & T;
//# sourceMappingURL=Selected.d.ts.map