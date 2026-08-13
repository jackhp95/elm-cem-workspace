import { LitElement } from "lit";
import { Constructor } from "./Constructor";
/** Defines functionality for an element which supports reconnection logic. */
export interface ReconnectedCallbackMixin {
    /** Callback invoked when the element is connected after being disconnected. */
    reconnectedCallback(): void;
}
/**
 * Mixin to augment an element with behavior that supports reconnection logic.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<ReconnectedCallbackMixin> & T} A constructor that implements `ReconnectedCallbackMixin`.
 */
export declare function ReconnectedCallback<T extends Constructor<LitElement>>(base: T): Constructor<ReconnectedCallbackMixin> & T;
//# sourceMappingURL=ReconnectedCallback.d.ts.map