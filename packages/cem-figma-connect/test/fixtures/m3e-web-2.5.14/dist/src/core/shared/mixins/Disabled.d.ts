import { LitElement } from "lit";
import { Constructor } from "./Constructor";
/** Defines functionality for an element which supports a disabled state. */
export interface DisabledMixin {
    /**
     * Whether the element is disabled.
     * @default false
     */
    disabled: boolean;
}
/**
 * Determines whether a value is a `DisabledMixin`.
 * @param {unknown} value The value to test.
 * @returns {value is DisabledMixin} Whether `value` is a `DisabledMixin`.
 */
export declare function isDisabledMixin(value: unknown): value is DisabledMixin;
/**
 * Mixin to augment an element with behavior that supports a disabled state.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @param {boolean} [reflect=true] Whether the disabled property is reflected as an attribute.
 * @returns {Constructor<DisabledMixin> & T} A constructor that implements `DisabledMixin`.
 */
export declare function Disabled<T extends Constructor<LitElement>>(base: T, reflect?: boolean): Constructor<DisabledMixin> & T;
//# sourceMappingURL=Disabled.d.ts.map