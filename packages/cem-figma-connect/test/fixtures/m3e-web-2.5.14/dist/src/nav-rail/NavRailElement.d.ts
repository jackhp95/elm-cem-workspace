import { CSSResultGroup } from "lit";
import { M3eNavBarElement, NavItemOrientation } from "@m3e/web/nav-bar";
declare const M3eNavRailElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SuppressInitialAnimationMixin> & typeof M3eNavBarElement;
/**
 * A vertical bar, typically used on larger devices, that allows a user to switch between views.
 *
 * @description
 * The `m3e-nav-rail` component provides a vertical navigation rail for switching between views in
 * an application. Designed for larger devices, it supports compact and expanded modes, interactive
 * items, and theming via CSS custom properties.
 *
 * @example
 * The following example illustrates a nav rail whose expanded state is automatically determined by the
 * current screen size.  In addition, a toggle button is used to allow the user to manually toggle the
 * expanded state.
 *
 * ```html
 * <m3e-nav-rail id="nav-rail" mode="auto">
 *   <m3e-icon-button toggle>
 *     <m3e-icon name="menu"></m3e-icon>
 *     <m3e-icon slot="selected" name="menu_open"></m3e-icon>
 *     <m3e-nav-rail-toggle for="nav-rail"></m3e-nav-rail-toggle>
 *   </m3e-icon-button>
 *   <m3e-fab size="small">
 *     <m3e-icon name="edit"></m3e-icon>
 *     <span slot="label">Extended</span>
 *   </m3e-fab>
 *   <m3e-nav-item><m3e-icon slot="icon" name="news"></m3e-icon>News</m3e-nav-item>
 *   <m3e-nav-item><m3e-icon slot="icon" name="globe"></m3e-icon>Global</m3e-nav-item>
 *   <m3e-nav-item><m3e-icon slot="icon" name="star"></m3e-icon>For you</m3e-nav-item>
 *   <m3e-nav-item><m3e-icon slot="icon" name="newsstand"></m3e-icon>Trending</m3e-nav-item>
 * </m3e-nav-rail>
 * ```
 *
 * @tag m3e-nav-rail
 *
 * @attr mode - The mode in which items in the rail are presented.
 *
 * @fires beforeinput - Dispatched before the selected state of an item changes.
 * @fires input - Dispatched when the selected state of an item changes.
 * @fires change - Dispatched when the selected state of an item changes.
 *
 * @cssprop --m3e-nav-rail-top-space - Top block padding for the nav rail.
 * @cssprop --m3e-nav-rail-bottom-space - Bottom block padding for the nav rail.
 * @cssprop --m3e-nav-rail-compact-width - Width of the nav rail in compact mode.
 * @cssprop --m3e-nav-rail-inline-padding - Inline padding for nav rail.
 * @cssprop --m3e-nav-rail-expanded-width - Width of the nav rail in expanded mode.
 * @cssprop --m3e-nav-rail-expanded-item-height - Height of nav items in expanded mode.
 * @cssprop --m3e-nav-rail-button-item-space - Space below icon buttons and FABs.
 * @cssprop --m3e-nav-rail-icon-button-inset - Inset for icon buttons.
 * @cssprop --m3e-nav-rail-expanded-inline-padding - Deprecated, use `--m3e-nav-rail-inline-padding`.
 * @cssprop --m3e-nav-rail-expanded-min-width - Deprecated, use `--m3e-nav-rail-expanded-width`.
 * @cssprop --m3e-nav-rail-expanded-max-width - Deprecated, use `--m3e-nav-rail-expanded-width`.
 * @cssprop --m3e-nav-rail-expanded-icon-button-inset - Deprecated, use `--m3e-nav-rail-icon-button-inset`.
 */
export declare class M3eNavRailElement extends M3eNavRailElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    constructor();
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc @internal */
    protected _updateItems(): void;
    /** @inheritdoc @internal */
    protected _updateOrientation(orientation: NavItemOrientation): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-nav-rail": M3eNavRailElement;
    }
}
export {};
//# sourceMappingURL=NavRailElement.d.ts.map