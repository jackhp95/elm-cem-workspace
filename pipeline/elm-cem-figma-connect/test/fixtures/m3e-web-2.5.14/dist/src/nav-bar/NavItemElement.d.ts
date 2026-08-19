import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { resumeAnimation } from "@m3e/web/core";
import type { M3eNavBarElement } from "./NavBarElement";
import { NavItemOrientation } from "./NavItemOrientation";
declare const M3eNavItemElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SuppressInitialAnimationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LinkButtonMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SelectedMixin> & import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledInteractiveMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * An item, placed in a navigation bar or rail, used to navigate to destinations in an application.
 *
 * @description
 * The `m3e-nav-item` component represents an interactive navigation item for use in navigation bars
 * or rails. Designed according to Material 3 principles, it supports icon and label slots, selection state,
 * orientation, and extensive theming via CSS custom properties.
 *
 * @example
 * The following example illustrates a nav bar with vertically oriented items.
 * ```html
 * <m3e-nav-bar>
 *   <m3e-nav-item><m3e-icon slot="icon" name="news"></m3e-icon>News</m3e-nav-item>
 *   <m3e-nav-item><m3e-icon slot="icon" name="globe"></m3e-icon>Global</m3e-nav-item>
 *   <m3e-nav-item><m3e-icon slot="icon" name="star"></m3e-icon>For you</m3e-nav-item>
 *   <m3e-nav-item><m3e-icon slot="icon" name="newsstand"></m3e-icon>Trending</m3e-nav-item>
 * </m3e-nav-bar>
 * ```
 *
 * @tag m3e-nav-item
 *
 * @slot - Renders the label of the item.
 * @slot icon - Renders the icon of the item.
 * @slot selected-icon - Renders the icon of the item when selected.
 *
 * @attr disabled - A value indicating whether the element is disabled.
 * @attr disabled-interactive - A value indicating whether the element is disabled and interactive.
 * @attr download - A value indicating whether the `target` of the link button will be downloaded, optionally specifying the new name of the file.
 * @attr href - The URL to which the link button points.
 * @attr orientation - The layout orientation of the item.
 * @attr rel - The relationship between the `target` of the link button and the document.
 * @attr selected - A value indicating whether the element is selected.
 * @attr target - The target of the link button.
 *
 * @fires beforeinput - Dispatched before the selected state changes.
 * @fires input - Dispatched when the selected state changes.
 * @fires change - Dispatched when the selected state changes.
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-nav-item-label-text-font-size - Font size for the label text.
 * @cssprop --m3e-nav-item-label-text-font-weight - Font weight for the label text.
 * @cssprop --m3e-nav-item-label-text-line-height - Line height for the label text.
 * @cssprop --m3e-nav-item-label-text-tracking - Letter spacing for the label text.
 * @cssprop --m3e-nav-item-shape - Border radius of the nav item.
 * @cssprop --m3e-nav-item-icon-size - Size of the icon.
 * @cssprop --m3e-nav-item-spacing - Spacing between icon and label.
 * @cssprop --m3e-nav-item-inactive-label-text-color - Color of the label text when inactive.
 * @cssprop --m3e-nav-item-inactive-icon-color - Color of the icon when inactive.
 * @cssprop --m3e-nav-item-inactive-hover-state-layer-color - State layer color on hover when inactive.
 * @cssprop --m3e-nav-item-inactive-focus-state-layer-color - State layer color on focus when inactive.
 * @cssprop --m3e-nav-item-inactive-pressed-state-layer-color - State layer color on press when inactive.
 * @cssprop --m3e-nav-item-active-label-text-color - Color of the label text when active/selected.
 * @cssprop --m3e-nav-item-active-icon-color - Color of the icon when active/selected.
 * @cssprop --m3e-nav-item-active-container-color - Container color when active/selected.
 * @cssprop --m3e-nav-item-active-hover-state-layer-color - State layer color on hover when active.
 * @cssprop --m3e-nav-item-active-focus-state-layer-color - State layer color on focus when active.
 * @cssprop --m3e-nav-item-active-pressed-state-layer-color - State layer color on press when active.
 * @cssprop --m3e-nav-item-focus-ring-shape - Border radius for the focus ring.
 * @cssprop --m3e-nav-item-disabled-label-text-color - Color of the label text when disabled.
 * @cssprop --m3e-nav-item-disabled-label-text-opacity - Opacity of the label text when disabled.
 * @cssprop --m3e-nav-item-disabled-icon-color - Color of the icon when disabled.
 * @cssprop --m3e-nav-item-disabled-icon-opacity - Opacity of the icon when disabled.
 * @cssprop --m3e-horizontal-nav-item-padding - Padding for horizontal orientation.
 * @cssprop --m3e-horizontal-nav-item-active-indicator-height - Height of the active indicator in horizontal orientation.
 * @cssprop --m3e-vertical-nav-item-active-indicator-width - Width of the active indicator in vertical orientation.
 * @cssprop --m3e-vertical-nav-item-active-indicator-height - Height of the active indicator in vertical orientation.
 * @cssprop --m3e-vertical-nav-item-active-indicator-margin - Margin for the active indicator in vertical orientation.
 */
export declare class M3eNavItemElement extends M3eNavItemElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /** @private */ private readonly _ripple?;
    /** @private */ private readonly _inner?;
    /**
     * The layout orientation of the item.
     * @default "vertical"
     */
    orientation: NavItemOrientation;
    /** The navigation bar to which this item belongs. */
    get navBar(): M3eNavBarElement | null;
    /** @internal */
    [resumeAnimation](): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-nav-item": M3eNavItemElement;
    }
}
export {};
//# sourceMappingURL=NavItemElement.d.ts.map