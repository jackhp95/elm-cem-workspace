import { ActionElementBase } from "@m3e/web/core";
import type { M3eMenuElement } from "./MenuElement";
declare const M3eMenuTriggerElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").HtmlForMixin> & typeof ActionElementBase;
/**
 * An element, nested within a clickable element, used to open a menu.
 *
 * @description
 * The `m3e-menu-trigger` component is used to open a menu when nested within a clickable element
 * such as a button or menu item. It anchors the menu to its invoker, enabling contextual flows and
 * nested hierarchies.
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
 * @tag m3e-menu-trigger
 *
 * @slot - Renders the contents of the trigger.
 */
export declare class M3eMenuTriggerElement extends M3eMenuTriggerElement_base {
    /** The menu triggered by the element. */
    get menu(): M3eMenuElement | null;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    detach(): void;
    /** @inheritdoc */
    _onClick(): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-menu-trigger": M3eMenuTriggerElement;
    }
}
export {};
//# sourceMappingURL=MenuTriggerElement.d.ts.map