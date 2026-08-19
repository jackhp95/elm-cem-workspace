import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { ScrollDividers } from "./ScrollDividers";
declare const M3eScrollContainerElement_base: import("../mixins/Constructor").Constructor<import("..").AttachInternalsMixin> & typeof LitElement;
/**
 * A vertically oriented content container which presents dividers above and below content when scrolled.
 *
 * @description
 * The `m3e-scroll-container` component provides a vertically oriented scrollable container with dynamic
 * dividers above and below content. Designed according to Material 3 principles, it supports custom scrollbar
 * thickness, divider styling, and focus ring theming via CSS custom properties.
 *
 * @example
 * This example shows a scrollable container with dividers above and below the content, and thin scrollbars enabled.
 * ```html
 * <m3e-scroll-container dividers="above-below" thin>
 *   <div>Scrollable content goes here</div>
 * </m3e-scroll-container>
 * ```
 *
 * @tag m3e-scroll-container
 *
 * @slot - Renders the scrollable content.
 *
 * @attr dividers - The dividers used to separate scrollable content.
 * @attr thin - Whether to present thin scrollbars.
 *
 * @cssprop --m3e-divider-thickness - Thickness of the divider lines above and below content.
 * @cssprop --m3e-divider-color - Color of the divider lines when visible.
 * @cssprop --m3e-focus-ring-color - Color of the focus ring outline.
 * @cssprop --m3e-focus-ring-thickness - Thickness of the focus ring outline.
 * @cssprop --m3e-focus-ring-factor - Animation factor for focus ring thickness.
 * @cssprop --m3e-focus-ring-duration - Duration of the focus ring animation.
 */
export declare class M3eScrollContainerElement extends M3eScrollContainerElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * The dividers used to separate scrollable content.
     * @default "above-below"
     */
    dividers: ScrollDividers;
    /**
     * Whether to present thin scrollbars.
     * @default false
     */
    thin: boolean;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @private */
    private _updateScroll;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-scroll-container": M3eScrollContainerElement;
    }
}
export {};
//# sourceMappingURL=ScrollContainerElement.d.ts.map