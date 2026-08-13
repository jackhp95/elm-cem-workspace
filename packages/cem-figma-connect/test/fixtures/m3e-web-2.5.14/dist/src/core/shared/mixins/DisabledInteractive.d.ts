import { LitElement } from "lit";
import { Constructor } from "./Constructor";
import { DisabledMixin } from "./Disabled";
/** Defines functionality for an element which supports an interactive disabled state. */
export interface DisabledInteractiveMixin extends DisabledMixin {
    /**
     * Whether the element is disabled and interactive.
     * @default false
     */
    disabledInteractive: boolean;
}
/**
 * Determines whether a value is a `DisabledInteractiveMixin`.
 * @param {unknown} value The value to test.
 * @returns {value is DisabledInteractiveMixin} Whether `value` is a `DisabledInteractiveMixin`.
 */
export declare function isDisabledInteractiveMixin(value: unknown): value is DisabledInteractiveMixin;
/**
 * Mixin to augment an element with behavior that supports an interactive disabled state.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<DisabledInteractiveMixin>} A constructor that implements `DisabledInteractiveMixin`.
 */
export declare function DisabledInteractive<T extends Constructor<LitElement & DisabledMixin>>(base: T): Constructor<DisabledInteractiveMixin> & T;
//# sourceMappingURL=DisabledInteractive.d.ts.map