import { LitElement } from "lit";
import { Constructor } from "./Constructor";
/** Defines functionality for an element which supports a vertical orientation. */
export interface VerticalMixin {
    /**
     * Whether the element is oriented vertically.
     * @default false
     */
    vertical: boolean;
}
/**
 * Determines whether a value is a `VerticalMixin`.
 * @param {unknown} value The value to test.
 * @returns A value indicating whether `value` is a `VerticalMixin`.
 */
export declare function isVerticalMixin(value: unknown): value is VerticalMixin;
/**
 * Mixin to augment an element with behavior that supports a vertical orientation.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<VerticalMixin> & T} A constructor that implements `VerticalMixin`.
 */
export declare function Vertical<T extends Constructor<LitElement>>(base: T): Constructor<VerticalMixin> & T;
//# sourceMappingURL=Vertical.d.ts.map