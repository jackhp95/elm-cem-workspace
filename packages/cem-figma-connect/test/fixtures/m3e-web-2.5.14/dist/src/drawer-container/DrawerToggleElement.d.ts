import { ActionElementBase } from "@m3e/web/core";
declare const M3eDrawerToggleElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").HtmlForMixin> & typeof ActionElementBase;
/**
 * An element, nested within a clickable element, used to toggle the opened state of a drawer.
 *
 * @example
 * The following example illustrates the use of a `m3e-drawer-toggle`, nested inside a `m3e-icon-button` component,
 * which toggles the open state of the start drawer.
 *
 * ```html
 * <m3e-icon-button slot="leading-icon" aria-label="Menu" toggle selected>
 *   <m3e-drawer-toggle for="startDrawer"></m3e-drawer-toggle>
 *   <m3e-icon name="menu"></m3e-icon>
 *   <m3e-icon slot="selected" name="menu_open"></m3e-icon>
 * </m3e-icon-button>
 *
 * <m3e-drawer-container start>
 *   <nav slot="start" id="startDrawer" aria-label="Navigation">
 *     <!-- Start drawer content -->
 *   </nav>
 *   <!-- Container content -->
 * </m3e-drawer-container>
 * ```
 *
 * @tag m3e-drawer-toggle
 */
export declare class M3eDrawerToggleElement extends M3eDrawerToggleElement_base {
    #private;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    detach(): void;
    /** @inheritdoc */
    _onClick(): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-drawer-toggle": M3eDrawerToggleElement;
    }
}
export {};
//# sourceMappingURL=DrawerToggleElement.d.ts.map