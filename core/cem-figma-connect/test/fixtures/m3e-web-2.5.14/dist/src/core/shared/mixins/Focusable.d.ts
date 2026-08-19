import { LitElement } from "lit";
import { Constructor } from "./Constructor";
import { DisabledMixin } from "./Disabled";
/**
 * Mixin to augment an element with behavior that supports a focused state.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor & T} A constructor that implements focusable behavior.
 */
export declare function Focusable<T extends Constructor<LitElement & DisabledMixin>>(base: T): Constructor & T;
//# sourceMappingURL=Focusable.d.ts.map