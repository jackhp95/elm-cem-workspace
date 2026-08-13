import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { ExpansionTogglePosition } from "./ExpansionTogglePosition";
import { ExpansionToggleDirection } from "./ExpansionToggleDirection";
declare const M3eExpansionPanelElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * An expandable details-summary view.
 *
 * @description
 * The `m3e-expansion-panel` component provides an accessible, animated details-summary view for
 * organizing content in collapsible sections. It supports custom header, content, actions, and
 * toggle icon slots, and offers configurable toggle position and direction. The panel responds to
 * open/close states, emits lifecycle events, and supports rich theming via CSS custom properties
 * for elevation, shape, spacing, and color.
 *
 * @example
 * The following example illustrates the basic use of the `m3e-accordion` and `m3e-expansion-panel` components.
 *
 * ```html
 * <m3e-accordion>
 *   <m3e-expansion-panel>
 *     <span slot="header">Panel 1</span>
 *     I am content for the first expansion panel
 *   </m3e-expansion-panel>
 *   <m3e-expansion-panel>
 *     <span slot="header">Panel 2</span>
 *     I am content for the second expansion panel
 *   </m3e-expansion-panel>
 * </m3e-accordion>
 * ```
 *
 * @tag m3e-expansion-panel
 *
 * @slot - Renders the detail of the panel.
 * @slot actions - Renders the actions bar of the panel.
 * @slot header - Renders the header content.
 * @slot toggle-icon - Renders the expansion toggle icon.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr hide-toggle - Whether to hide the expansion toggle.
 * @attr open - Whether the panel is expanded.
 * @attr toggle-direction - The direction of the expansion toggle.
 * @attr toggle-position - The position of the expansion toggle.
 *
 * @fires opening - Dispatched when the expansion panel begins to open.
 * @fires opened - Dispatched when the expansion panel has opened.
 * @fires closing - Dispatched when the expansion panel begins to close.
 * @fires closed - Dispatched when the expansion panel has closed.
 *
 * @cssprop --m3e-expansion-header-collapsed-height - Height of the header when the panel is collapsed.
 * @cssprop --m3e-expansion-header-expanded-height - Height of the header when the panel is expanded.
 * @cssprop --m3e-expansion-header-padding-left - Left padding inside the header.
 * @cssprop --m3e-expansion-header-padding-right - Right padding inside the header.
 * @cssprop --m3e-expansion-header-spacing - Spacing between header elements.
 * @cssprop --m3e-expansion-header-toggle-icon-size - Size of the toggle icon (e.g. chevron).
 * @cssprop --m3e-expansion-header-font-size - The font size of the header text.
 * @cssprop --m3e-expansion-header-font-weight - The font weight of the header text.
 * @cssprop --m3e-expansion-header-line-height - The line height of the header text.
 * @cssprop --m3e-expansion-header-tracking - Letter spacing (tracking) of the header text.
 * @cssprop --m3e-expansion-panel-text-color - Color of the panel's text content.
 * @cssprop --m3e-expansion-panel-disabled-text-color - Color of the panel's text content, when disabled.
 * @cssprop --m3e-expansion-panel-disabled-text-opacity - Opacity of the panel's text content, when disabled.
 * @cssprop --m3e-expansion-panel-container-color - Background color of the panel container.
 * @cssprop --m3e-expansion-panel-elevation - Elevation level when the panel is collapsed.
 * @cssprop --m3e-expansion-panel-shape - Shape (e.g. border radius) of the panel when collapsed.
 * @cssprop --m3e-expansion-panel-open-elevation - Elevation level when the panel is expanded.
 * @cssprop --m3e-expansion-panel-open-shape - Shape (e.g. border radius) of the panel when expanded.
 * @cssprop --m3e-expansion-panel-content-padding - Padding around the panel's content area.
 * @cssprop --m3e-expansion-panel-actions-spacing - Spacing between action buttons or elements.
 * @cssprop --m3e-expansion-panel-actions-padding - Padding around the actions section.
 * @cssprop --m3e-expansion-panel-actions-divider-thickness - Thickness of the divider above actions.
 * @cssprop --m3e-expansion-panel-actions-divider-color - Color of the divider above actions.
 */
export declare class M3eExpansionPanelElement extends M3eExpansionPanelElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextId;
    /** @private */ private readonly _header?;
    /**
     * Whether the panel is expanded.
     * @default false
     */
    open: boolean;
    /**
     * The direction of the expansion toggle.
     * @default "vertical"
     */
    toggleDirection: ExpansionToggleDirection;
    /**
     * The position of the expansion toggle.
     * @default "after"
     */
    togglePosition: ExpansionTogglePosition;
    /**
     * Whether to hide the expansion toggle.
     * @default false
     */
    hideToggle: boolean;
    /** @inheritdoc */
    focus(options?: FocusOptions): void;
    /** @inheritdoc */
    blur(): void;
    /** @inheritdoc */
    click(): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
}
interface M3eExpansionPanelElementEventMap extends HTMLElementEventMap {
    opening: Event;
    opened: Event;
    closing: Event;
    closed: Event;
}
export interface M3eExpansionPanelElement {
    addEventListener<K extends keyof M3eExpansionPanelElementEventMap>(type: K, listener: (this: M3eExpansionPanelElement, ev: M3eExpansionPanelElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eExpansionPanelElementEventMap>(type: K, listener: (this: M3eExpansionPanelElement, ev: M3eExpansionPanelElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-expansion-panel": M3eExpansionPanelElement;
    }
}
export {};
//# sourceMappingURL=ExpansionPanelElement.d.ts.map