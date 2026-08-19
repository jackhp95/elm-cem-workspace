import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { CollapsibleOrientation } from "./CollapsibleOrientation";
declare const M3eCollapsibleElement_base: import("../mixins/Constructor").Constructor<import("..").AttachInternalsMixin> & typeof LitElement;
/**
 * A container used to expand and collapse content.
 *
 * @example
 * ```html
 * <m3e-collapsible>
 *  <!-- Collapsible content -->
 * </m3e-collapsible>
 * ```
 *
 * @tag m3e-collapsible
 *
 * @slot - Renders the collapsible content.
 *
 * @attr open - Whether content is visible.
 * @attr orientation - Orientation of collapsible content.
 * @attr no-animate - Whether to disable animation.
 *
 * @fires opening - Dispatched when the collapsible begins to open.
 * @fires opened - Dispatched when the collapsible has opened.
 * @fires closing - Dispatched when the collapsible begins to close.
 * @fires closed - Dispatched when the collapsible has closed.
 *
 * @cssprop --m3e-collapsible-animation-duration - The duration of the expand / collapse animation.
 */
export declare class M3eCollapsibleElement extends M3eCollapsibleElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * Whether content is visible.
     * @default false
     */
    open: boolean;
    /**
     * Orientation of collapsible content.
     * @default "vertical"
     */
    orientation: CollapsibleOrientation;
    /**
     * Whether to disable animation.
     * @default false
     */
    noAnimate: boolean;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
}
interface M3eCollapsibleElementEventMap extends HTMLElementEventMap {
    opening: Event;
    opened: Event;
    closing: Event;
    closed: Event;
}
export interface M3eCollapsibleElement {
    addEventListener<K extends keyof M3eCollapsibleElementEventMap>(type: K, listener: (this: M3eCollapsibleElement, ev: M3eCollapsibleElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eCollapsibleElementEventMap>(type: K, listener: (this: M3eCollapsibleElement, ev: M3eCollapsibleElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-collapsible": M3eCollapsibleElement;
    }
}
export {};
//# sourceMappingURL=CollapsibleElement.d.ts.map