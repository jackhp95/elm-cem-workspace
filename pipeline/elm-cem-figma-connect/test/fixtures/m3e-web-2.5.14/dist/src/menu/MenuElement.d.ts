import { CSSResultGroup, LitElement } from "lit";
import { MenuPositionX, MenuPositionY } from "./MenuPosition";
import { MenuItemElementBase } from "./MenuItemElementBase";
import { MenuVariant } from "./MenuVariant";
declare const M3eMenuElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SuppressInitialAnimationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * Presents a list of choices on a temporary surface.
 *
 * @description
 * The `m3e-menu` component presents a list of choices on a temporary surface, typically anchored to a trigger element.
 * It supports dynamic positioning via `position-x` and `position-y` attributes, and renders its contents through the default slot.
 *
 * @example
 * The following example illustrates a basic menu.  The `m3e-menu-trigger` is used to trigger a `m3e-menu` specified
 * by the `for` attribute when its parenting element is activated.
 * ```html
 * <m3e-button>
 *   <m3e-menu-trigger for="menu1">Basic menu</m3e-menu-trigger>
 * </m3e-button>
 * <m3e-menu id="menu1">
 *   <m3e-menu-item>Apple</m3e-menu-item>
 *   <m3e-menu-item>Apricot</m3e-menu-item>
 *   <m3e-menu-item>Avocado</m3e-menu-item>
 *   <m3e-menu-item>Green Apple</m3e-menu-item>
 *   <m3e-menu-item>Green Grapes</m3e-menu-item>
 *   <m3e-menu-item>Olive</m3e-menu-item>
 *   <m3e-menu-item>Orange</m3e-menu-item>
 * </m3e-menu>
 * ```
 *
 * @example
 * The next example illustrates nested menus.  Submenus are triggered by placing a `m3e-menu-trigger` inside a `m3e-menu-item`.
 * ```html
 * <m3e-button>
 *   <m3e-menu-trigger for="menu2">Nested menus</m3e-menu-trigger>
 * </m3e-button>
 * <m3e-menu id="menu2">
 *   <m3e-menu-item>
 *     <m3e-menu-trigger for="menu3">Fruits with A</m3e-menu-trigger>
 *   </m3e-menu-item>
 *   <m3e-menu-item>Grapes</m3e-menu-item>
 *   <m3e-menu-item>Olive</m3e-menu-item>
 *   <m3e-menu-item>Orange</m3e-menu-item>
 * </m3e-menu>
 * <m3e-menu id="menu3">
 *   <m3e-menu-item>Apricot</m3e-menu-item>
 *   <m3e-menu-item>Avocado</m3e-menu-item>
 *   <m3e-menu-item>
 *     <m3e-menu-trigger for="menu4">Apples</m3e-menu-trigger>
 *   </m3e-menu-item>
 * </m3e-menu>
 * <m3e-menu id="menu4">
 *   <m3e-menu-item>Fuji</m3e-menu-item>
 *   <m3e-menu-item>Granny Smith</m3e-menu-item>
 *   <m3e-menu-item>Red Delicious</m3e-menu-item>
 * </m3e-menu>
 * ```
 *
 * @tag m3e-menu
 *
 * @slot - Renders the contents of the menu.
 *
 * @attr position-x - The position of the menu, on the x-axis.
 * @attr position-y - The position of the menu, on the y-axis.
 * @attr variant - The appearance variant of the menu.
 *
 * @fires beforetoggle - Dispatched before the toggle state changes.
 * @fires toggle - Dispatched after the toggle state has changed.
 *
 * @cssprop --m3e-menu-container-shape - Controls the corner radius of the menu container.
 * @cssprop --m3e-menu-active-container-shape - Controls the corner radius of the menu container when active.
 * @cssprop --m3e-menu-container-min-width - Minimum width of the menu container.
 * @cssprop --m3e-menu-container-max-width - Maximum width of the menu container.
 * @cssprop --m3e-menu-container-max-height - Maximum height of the menu container.
 * @cssprop --m3e-menu-container-padding-block - Vertical padding inside the menu container.
 * @cssprop --m3e-menu-container-padding-inline - Horizontal padding inside the menu container.
 * @cssprop --m3e-menu-container-color - Background color of the menu container.
 * @cssprop --m3e-menu-container-elevation - Box shadow elevation of the menu container.
 * @cssprop --m3e-vibrant-menu-container-color - Background color of the menu container for vibrant variant.
 * @cssprop --m3e-menu-divider-spacing - Vertical spacing around slotted `m3e-divider` elements.
 * @cssprop --m3e-menu-gap - Gap between content in the menu.
 */
export declare class M3eMenuElement extends M3eMenuElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ static __activeMenu?: M3eMenuElement;
    /**
     * The position of the menu, on the x-axis.
     * @default "after"
     */
    positionX: MenuPositionX;
    /**
     * The position of the menu, on the y-axis.
     * @default "below"
     */
    positionY: MenuPositionY;
    /**
     * The appearance variant of the menu.
     * @default "standard"
     */
    variant: MenuVariant;
    /** The items of the menu. */
    get items(): ReadonlyArray<MenuItemElementBase>;
    /** A value indicating whether the menu is open. */
    get isOpen(): boolean;
    /** A value indicating whether the menu is a submenu. */
    submenu: boolean;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
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
     * Closes this menu and any parenting menus.
     * @param {boolean} [restoreFocus=false] A value indicating whether to restore focus to the menu's trigger.
     */
    hideAll(restoreFocus?: boolean): void;
    /**
     * Toggles the menu.
     * @param {HTMLElement} trigger The element that triggered the menu.
     * @returns {Promise<void>} A `Promise` that resolves when the menu is opened or closed.
     */
    toggle(trigger: HTMLElement): Promise<void>;
    /** @inheritdoc */
    protected render(): unknown;
    /** @internal */
    _activate(): void;
}
interface M3eMenuElementEventMap extends HTMLElementEventMap {
    beforetoggle: ToggleEvent;
    toggle: ToggleEvent;
}
export interface M3eMenuElement {
    addEventListener<K extends keyof M3eMenuElementEventMap>(type: K, listener: (this: M3eMenuElement, ev: M3eMenuElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eMenuElementEventMap>(type: K, listener: (this: M3eMenuElement, ev: M3eMenuElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-menu": M3eMenuElement;
    }
}
export {};
//# sourceMappingURL=MenuElement.d.ts.map