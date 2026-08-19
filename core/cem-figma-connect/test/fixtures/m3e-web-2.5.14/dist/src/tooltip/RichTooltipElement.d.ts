import { CSSResultGroup, PropertyValues } from "lit";
import { AnchorPosition } from "@m3e/web/core/anchoring";
import { RichTooltipPosition } from "./RichTooltipPosition";
import { TooltipElementBase } from "./TooltipElementBase";
/**
 * Provides contextual details for a control, such as explaining the value or purpose of a feature.
 *
 * @description
 * The `m3e-rich-tooltip` component provides contextual guidance for a control. It supports an optional
 * subhead, multi-line supporting text, and optional action elements. When non‑interactive, it behaves
 * as a standard tooltip and contributes an `aria-describedby` message to its control. When interactive,
 * it becomes a lightweight anchored dialog with manual popover behavior, keyboard dismissal, and
 * click‑outside light‑dismiss.
 *
 * @example
 * The following example illustrates connecting an interactive rich tooltip to a button using the `for` attribute.
 * ```html
 * <m3e-icon-button id="btnSettings">
 *  <m3e-icon name="settings"></m3e-icon>
 * </m3e-icon-button>
 * <m3e-rich-tooltip for="btnSettings">
 *  <span slot="subhead">New settings available</span>
 *  Now you can adjust the uploaded image quality, and upgrade your available storage space.
 *  <div slot="actions">
 *    <m3e-button>
 *      <m3e-rich-tooltip-action>Learn more</m3e-rich-tooltip-action>
 *    </m3e-button>
 *  </div>
 * </m3e-rich-tooltip>
 * ```
 *
 * @tag m3e-rich-tooltip
 *
 * @slot - The main supporting text of the tooltip.
 * @slot subhead - Optional subhead text displayed above the supporting content.
 * @slot actions - Optional action elements displayed at the bottom of the tooltip.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr for - The identifier of the interactive control to which this element is attached.
 * @attr hide-delay - The amount of time, in milliseconds, before hiding the tooltip.
 * @attr position - The position of the tooltip.
 * @attr show-delay - The amount of time, in milliseconds, before showing the tooltip.
 *
 * @fires beforetoggle - Dispatched before the toggle state changes.
 * @fires toggle - Dispatched after the toggle state has changed.
 *
 * @cssprop --m3e-rich-tooltip-padding-top - Top padding of the tooltip container.
 * @cssprop --m3e-rich-tooltip-padding-bottom - Bottom padding of the tooltip container (when no actions are present).
 * @cssprop --m3e-rich-tooltip-padding-inline - Horizontal padding of the tooltip container.
 * @cssprop --m3e-rich-tooltip-max-width - Maximum width of the tooltip surface.
 * @cssprop --m3e-rich-tooltip-shape - Border‑radius of the tooltip container.
 * @cssprop --m3e-rich-tooltip-container-color - Background color of the tooltip surface.
 * @cssprop --m3e-rich-tooltip-subhead-color - Color of the subhead text.
 * @cssprop --m3e-rich-tooltip-subhead-font-size - Font size of the subhead text.
 * @cssprop --m3e-rich-tooltip-subhead-font-weight - Font weight of the subhead text.
 * @cssprop --m3e-rich-tooltip-subhead-line-height - Line height of the subhead text.
 * @cssprop --m3e-rich-tooltip-subhead-tracking - Letter‑spacing of the subhead text.
 * @cssprop --m3e-rich-tooltip-subhead-bottom-space - Space below the subhead before the supporting text.
 * @cssprop --m3e-rich-tooltip-supporting-text-color - Color of the supporting text.
 * @cssprop --m3e-rich-tooltip-supporting-text-font-size - Font size of the supporting text.
 * @cssprop --m3e-rich-tooltip-supporting-text-font-weight - Font weight of the supporting text.
 * @cssprop --m3e-rich-tooltip-supporting-text-line-height - Line height of the supporting text.
 * @cssprop --m3e-rich-tooltip-supporting-text-tracking - Letter‑spacing of the supporting text.
 * @cssprop --m3e-rich-tooltip-actions-padding-inline - Horizontal padding applied to the actions slot area.
 * @cssprop --m3e-rich-tooltip-actions-top-space - Space above the actions slot.
 * @cssprop --m3e-rich-tooltip-actions-bottom-space - Space below the actions slot.
 */
export declare class M3eRichTooltipElement extends TooltipElementBase {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextId;
    /** @private */ private _hasSubhead;
    /** @private */ private _interactive;
    /**
     * The position of the tooltip.
     * @default "below-after"
     */
    position: RichTooltipPosition;
    /** @inheritdoc */
    protected get _isInteractive(): boolean;
    /** @inheritdoc */
    protected get _anchorPosition(): AnchorPosition;
    /** @inheritdoc */
    protected render(): unknown;
    /** @inheritdoc */
    show(): Promise<void>;
    /**
     * Manually hides the tooltip.
     * @param [restoreFocus=true] Whether to restore focus to the element that triggered the interactive tooltip.
     */
    hide(restoreFocus?: boolean): void;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected _updatePosition(base: HTMLElement, x: number, y: number): void;
}
interface M3eRichTooltipElementEventMap extends HTMLElementEventMap {
    beforetoggle: ToggleEvent;
    toggle: ToggleEvent;
}
export interface M3eRichTooltipElement {
    addEventListener<K extends keyof M3eRichTooltipElementEventMap>(type: K, listener: (this: M3eRichTooltipElement, ev: M3eRichTooltipElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eRichTooltipElementEventMap>(type: K, listener: (this: M3eRichTooltipElement, ev: M3eRichTooltipElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-rich-tooltip": M3eRichTooltipElement;
    }
}
export {};
//# sourceMappingURL=RichTooltipElement.d.ts.map