import { LitElement } from "lit";
import { Constructor } from "./Constructor";
/**
 * Mixin to augment an element with behavior emits a click event on keyboard events.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @param {boolean} [allowEnter=true] Whether the `ENTER` key emits a click event.
 * @returns {T} A class that extends `base` with keyboard click behavior.
 */
export declare function KeyboardClick<T extends Constructor<LitElement>>(base: T, allowEnter?: boolean): T;
//# sourceMappingURL=KeyboardClick.d.ts.map