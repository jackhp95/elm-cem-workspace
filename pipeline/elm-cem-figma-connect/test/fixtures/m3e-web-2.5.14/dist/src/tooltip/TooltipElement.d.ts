import { CSSResultGroup } from "lit";
import { AnchorPosition } from "@m3e/web/core/anchoring";
import { TooltipPosition } from "./TooltipPosition";
import { TooltipElementBase } from "./TooltipElementBase";
/**
 * Adds additional context to a button or other UI element.
 *
 * @description
 * The `m3e-tooltip` component provides contextual information in response to user interaction, enhancing comprehension
 * and reducing ambiguity. Tooltips are positioned relative to a target element and support configurable delays for
 * show and hide behavior. The component is designed to reinforce accessibility and usability, especially in dense or
 * icon-driven interfaces. Use the `for` attribute to designate the element for which to provide a tooltip.
 *
 * @example
 * The following example illustrates connecting a tooltip to a button using the `for` attribute.
 * ```html
 * <m3e-icon-button id="button" aria-label="Back">
 *  <m3e-icon name="arrow_back"></m3e-icon>
 * </m3e-icon-button>
 * <m3e-tooltip for="button">Go Back</m3e-tooltip>
 * ```
 *
 * @tag m3e-tooltip
 *
 * @slot - Renders the content of the tooltip.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr for - The identifier of the interactive control to which this element is attached.
 * @attr hide-delay - The amount of time, in milliseconds, before hiding the tooltip.
 * @attr position - The position of the tooltip.
 * @attr show-delay - The amount of time, in milliseconds, before showing the tooltip.
 *
 * @cssprop --m3e-tooltip-padding - Internal spacing of the tooltip container.
 * @cssprop --m3e-tooltip-min-width - Minimum width of the tooltip.
 * @cssprop --m3e-tooltip-max-width - Maximum width of the tooltip.
 * @cssprop --m3e-tooltip-min-height - Minimum height of the tooltip container.
 * @cssprop --m3e-tooltip-max-height - Maximum height of the tooltip.
 * @cssprop --m3e-tooltip-shape - Border radius of the tooltip container.
 * @cssprop --m3e-tooltip-container-color - Background color of the tooltip.
 * @cssprop --m3e-tooltip-supporting-text-color - Text color of supporting text.
 * @cssprop --m3e-tooltip-supporting-text-font-size - Font size of supporting text.
 * @cssprop --m3e-tooltip-supporting-text-font-weight - Font weight of supporting text.
 * @cssprop --m3e-tooltip-supporting-text-line-height - Line height of supporting text.
 * @cssprop --m3e-tooltip-supporting-text-tracking - Letter spacing of supporting text.
 */
export declare class M3eTooltipElement extends TooltipElementBase {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * The position of the tooltip.
     * @default "below"
     */
    position: TooltipPosition;
    /** @inheritdoc */
    protected get _anchorPosition(): AnchorPosition;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    detach(): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    show(): Promise<void>;
    /** @inheritdoc */
    hide(): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @inheritdoc */
    protected _updatePosition(base: HTMLElement, x: number, y: number): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-tooltip": M3eTooltipElement;
    }
}
//# sourceMappingURL=TooltipElement.d.ts.map