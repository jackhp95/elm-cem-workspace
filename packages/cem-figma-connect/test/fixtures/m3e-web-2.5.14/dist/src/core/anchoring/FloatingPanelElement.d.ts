import { CSSResultGroup, LitElement } from "lit";
import { FloatingPanelScrollStrategy } from "./FloatingPanelScrollStrategy";
declare const M3eFloatingPanelElement_base: import("../shared/mixins/Constructor").Constructor<import("@m3e/web/core").SuppressInitialAnimationMixin> & import("../shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A lightweight, generic floating surface used to present content above the page.
 *
 * @tag m3e-floating-panel
 *
 * @attr scroll-strategy - The strategy that controls how the panel behaves when its trigger scrolls.
 * @attr fit-anchor-width - Whether the panel's width should match its anchor's width.
 * @attr anchor-offset - The logical margin, in pixels, between the panel and its anchor.
 *
 * @slot - Renders the contents of the panel.
 *
 * @fires beforetoggle - Dispatched before the toggle state changes.
 * @fires toggle - Dispatched after the toggle state has changed.
 *
 * @cssprop --m3e-floating-panel-container-shape - Corner radius of the panel container.
 * @cssprop --m3e-floating-panel-container-min-width - Minimum width of the panel container.
 * @cssprop --m3e-floating-panel-container-max-width - Maximum width of the panel container.
 * @cssprop --m3e-floating-panel-container-max-height - Maximum height of the panel container.
 * @cssprop --m3e-floating-panel-container-padding-block - Vertical padding inside the panel container.
 * @cssprop --m3e-floating-panel-container-padding-inline - Horizontal padding inside the panel container.
 * @cssprop --m3e-floating-panel-container-color - Background color of the panel container.
 * @cssprop --m3e-floating-panel-container-elevation - Box shadow elevation of the panel container.
 */
export declare class M3eFloatingPanelElement extends M3eFloatingPanelElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * The strategy that controls how the panel behaves when its trigger scrolls.
     * @default "hide"
     */
    scrollStrategy: FloatingPanelScrollStrategy;
    /**
     * Whether the panel's width should match its anchor's width.
     * @default false
     */
    fitAnchorWidth: boolean;
    /**
     * The logical margin, in pixels, between the panel and its anchor.
     * @default 0
     */
    anchorOffset: number;
    /** Whether the panel is open. */
    get isOpen(): boolean;
    /** The element that triggered the panel to open. */
    get trigger(): HTMLElement | null;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /**
     * Opens the panel.
     * @param {HTMLElement} trigger The element that triggered the panel.
     * @param {HTMLElement | null | undefined} anchor The element used to position the panel.
     * @returns {Promise<void>} A `Promise` that resolves when the panel is opened.
     */
    show(trigger: HTMLElement, anchor?: HTMLElement | null): Promise<void>;
    /**
     * Hides the panel.
     * @param {boolean} [restoreFocus=false] Whether to restore focus to the panel's trigger.
     */
    hide(restoreFocus?: boolean): void;
    /**
     * Toggles the panel.
     * @param {HTMLElement} trigger The element that triggered the panel.
     * @param {HTMLElement | undefined} anchor The element used to position the panel.
     * @returns {Promise<void>} A `Promise` that resolves when the panel is opened or closed.
     */
    toggle(trigger: HTMLElement, anchor?: HTMLElement): Promise<void>;
    /** @inheritdoc */
    protected render(): unknown;
}
interface M3eFloatingPanelElementEventMap extends HTMLElementEventMap {
    beforetoggle: ToggleEvent;
    toggle: ToggleEvent;
}
export interface M3eFloatingPanelElement {
    addEventListener<K extends keyof M3eFloatingPanelElementEventMap>(type: K, listener: (this: M3eFloatingPanelElement, ev: M3eFloatingPanelElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eFloatingPanelElementEventMap>(type: K, listener: (this: M3eFloatingPanelElement, ev: M3eFloatingPanelElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-floating-panel": M3eFloatingPanelElement;
    }
}
export {};
//# sourceMappingURL=FloatingPanelElement.d.ts.map