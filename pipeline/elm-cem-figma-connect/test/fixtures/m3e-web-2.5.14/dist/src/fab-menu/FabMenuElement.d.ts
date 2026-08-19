import { CSSResultGroup, LitElement } from "lit";
import { FabMenuVariant } from "./FabMenuVariant";
declare const M3eFabMenuElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SuppressInitialAnimationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A menu, opened from a floating action button (FAB), used to display multiple related actions.
 *
 * @description
 * The `m3e-fab-menu` component presents a dynamic menu of related actions, elegantly revealed from a
 * floating action button (FAB). Designed using expressive, adaptive surfaces, it enables seamless access
 * to contextual actions in modern, visually rich interfaces.
 *
 * @example
 * The following example illustrates triggering a `m3e-fab-menu` from an `m3e-fab` using a `m3e-fab-menu-trigger`.
 * ```html
 * <m3e-fab variant="primary" size="large">
 *  <m3e-fab-menu-trigger for="fabmenu">
 *    <m3e-icon name="edit"></m3e-icon>
 *  </m3e-fab-menu-trigger>
 * </m3e-fab>
 * <m3e-fab-menu id="fabmenu" variant="secondary">
 *  <m3e-fab-menu-item>First</m3e-fab-menu-item>
 *  <m3e-fab-menu-item>Second</m3e-fab-menu-item>
 *  <m3e-fab-menu-item>Third</m3e-fab-menu-item>
 *  <m3e-fab-menu-item>Forth</m3e-fab-menu-item>
 *  <m3e-fab-menu-item>Fifth</m3e-fab-menu-item>
 *  <m3e-fab-menu-item>Sixth</m3e-fab-menu-item>
 * </m3e-fab-menu>
 * ```
 *
 * @tag m3e-fab-menu
 *
 * @slot - Renders the contents of the menu.
 *
 * @attr variant - The appearance variant of the menu.
 *
 * @fires beforetoggle - Dispatched before the toggle state changes.
 * @fires toggle - Dispatched after the toggle state has changed.
 *
 * @cssprop --m3e-fab-menu-spacing - Vertical gap between menu items.
 * @cssprop --m3e-fab-menu-max-width - Maximum width of the menu.
 * @cssprop --m3e-primary-fab-color - Foreground color for primary variant items.
 * @cssprop --m3e-primary-fab-container-color - Container color for primary variant items.
 * @cssprop --m3e-primary-fab-hover-color - Hover background color for primary variant items.
 * @cssprop --m3e-primary-fab-focus-color - Focus background color for primary variant items.
 * @cssprop --m3e-primary-fab-ripple-color - Ripple color for primary variant items.
 * @cssprop --m3e-secondary-fab-color - Foreground color for secondary variant items.
 * @cssprop --m3e-secondary-fab-container-color - Container color for secondary variant items.
 * @cssprop --m3e-secondary-fab-hover-color - Hover background color for secondary variant items.
 * @cssprop --m3e-secondary-fab-focus-color - Focus background color for secondary variant items.
 * @cssprop --m3e-secondary-fab-ripple-color - Ripple color for secondary variant items.
 * @cssprop --m3e-tertiary-fab-color - Foreground color for tertiary variant items.
 * @cssprop --m3e-tertiary-fab-container-color - Container color for tertiary variant items.
 * @cssprop --m3e-tertiary-fab-hover-color - Hover background color for tertiary variant items.
 * @cssprop --m3e-tertiary-fab-focus-color - Focus background color for tertiary variant items.
 * @cssprop --m3e-tertiary-fab-ripple-color - Ripple color for tertiary variant items.
 */
export declare class M3eFabMenuElement extends M3eFabMenuElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * The appearance variant of the menu.
     * @default "primary"
     */
    variant: FabMenuVariant;
    /** Whether the menu is open. */
    get isOpen(): boolean;
    /**
     * Opens the menu.
     * @param {HTMLElement} trigger The element that triggered the menu.
     * @returns {Promise<void>} A `Promise` that resolves when the menu is opened.
     */
    show(trigger: HTMLElement): Promise<void>;
    /**
     * Hides the menu.
     * @param {boolean} [restoreFocus=false] A value indicating whether to restore focus to the menu's trigger.
     */
    hide(restoreFocus?: boolean): void;
    /**
     * Toggles the menu.
     * @param {HTMLElement} trigger The element that triggered the menu.
     * @returns {Promise<void>} A `Promise` that resolves when the menu is opened or closed.
     */
    toggle(trigger: HTMLElement): Promise<void>;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected render(): unknown;
}
interface M3eFabMenuElementEventMap extends HTMLElementEventMap {
    beforetoggle: ToggleEvent;
    toggle: ToggleEvent;
}
export interface M3eFabMenuElement {
    addEventListener<K extends keyof M3eFabMenuElementEventMap>(type: K, listener: (this: M3eFabMenuElement, ev: M3eFabMenuElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eFabMenuElementEventMap>(type: K, listener: (this: M3eFabMenuElement, ev: M3eFabMenuElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-fab-menu": M3eFabMenuElement;
    }
}
export {};
//# sourceMappingURL=FabMenuElement.d.ts.map