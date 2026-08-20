import { LitElement } from "lit";
import { Constructor } from "./Constructor";
/** Defines functionality for an attached element associated with an interactive control. */
export interface HtmlForMixin {
    /** The identifier of the interactive control to which this element is attached. */
    htmlFor: string | null;
    /** The interactive element to which this element is attached. */
    readonly control: HTMLElement | null;
    /**
     * Attaches the element to an interactive control.
     * @param {HTMLElement} control The element that controls the attachable element.
     */
    attach(control: HTMLElement): void;
    /** Detaches the element from its current interactive control. */
    detach(): void;
}
/**
 * Determines whether a value is a `HtmlForMixin`.
 * @param {unknown} value The value to test.
 * @returns {value is HtmlForMixin} Whether `value` is a `HtmlForMixin`.
 */
export declare function isHtmlForMixin(value: unknown): value is HtmlForMixin;
/**
 * Mixin that creates an attached element associated with an interactive control.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<HtmlForMixin> & T} A constructor extends `base` and implements `HtmlForMixin`.
 */
export declare function HtmlFor<T extends Constructor<LitElement>>(base: T): Constructor<HtmlForMixin> & T;
//# sourceMappingURL=HtmlFor.d.ts.map