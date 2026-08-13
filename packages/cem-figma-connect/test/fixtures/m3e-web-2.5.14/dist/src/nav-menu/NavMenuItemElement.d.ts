import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { M3eFocusRingElement, M3eRippleElement, M3eStateLayerElement } from "@m3e/web/core";
declare const M3eNavMenuItemElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SelectedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * An expandable item, selectable item within a navigation menu.
 *
 * @description
 * The `m3e-nav-menu-item` component represents an expandable, selectable item within a navigation menu.
 * It supports nested child items, selection and disabled states, and emits events for open/close transitions.
 * The component is highly customizable via slots and CSS custom properties, and is designed for accessible,
 * keyboard-navigable menu structures.
 *
 * @example
 * The following example illustrates a navigation menu with a top-level group of menu items.
 * ```html
 * <m3e-nav-menu>
 *   <m3e-nav-menu-item-group>
 *     <m3e-heading slot="label" variant="label" size="large">Mail</m3e-heading>
 *     <m3e-nav-menu-item>
 *       <m3e-icon slot="icon" name="mail"></m3e-icon>
 *       <span slot="label">Inbox</span>
 *       <span slot="badge">24</span>
 *     </m3e-nav-menu-item>
 *     <m3e-nav-menu-item>
 *       <m3e-icon slot="icon" name="send"></m3e-icon>
 *       <span slot="label">Outbox</span>
 *     </m3e-nav-menu-item>
 *     <m3e-nav-menu-item>
 *       <m3e-icon slot="icon" name="favorite"></m3e-icon>
 *       <span slot="label">Favorites</span>
 *     </m3e-nav-menu-item>
 *     <m3e-nav-menu-item>
 *       <m3e-icon slot="icon" name="delete"></m3e-icon>
 *       <span slot="label">Trash</span>
 *     </m3e-nav-menu-item>
 *   </m3e-nav-menu-item-group>
 * </m3e-nav-menu>
 * ```
 *
 * @example
 * The next example illustrates a multilevel navigation menu.
 * ```html
 * <m3e-nav-menu>
 *   <m3e-nav-menu-item open>
 *     <m3e-icon slot="icon" name="rocket_launch"></m3e-icon>
 *     <span slot="label">Getting Started</span>
 *     <m3e-nav-menu-item>
 *       <m3e-icon slot="icon" name="widgets"></m3e-icon>
 *       <span slot="label">Overview</span>
 *     </m3e-nav-menu-item>
 *     <m3e-nav-menu-item>
 *       <m3e-icon slot="icon" name="package_2"></m3e-icon>
 *       <span slot="label">Installation</span>
 *     </m3e-nav-menu-item>
 *   </m3e-nav-menu-item>
 *   <m3e-nav-menu-item>
 *     <span slot="label">Actions</span>
 *     <m3e-nav-menu-item><span slot="label">Button</span></m3e-nav-menu-item>
 *     <m3e-nav-menu-item><span slot="label">Icon</span></m3e-nav-menu-item>
 *     <m3e-nav-menu-item><span slot="label">Icon Button</span></m3e-nav-menu-item>
 *   </m3e-nav-menu-item>
 * </m3e-nav-menu>
 * ```
 *
 * @tag m3e-nav-menu-item
 *
 * @slot - Renders the nested child items.
 * @slot label - Renders the label of the item.
 * @slot icon - Renders the icon of the item.
 * @slot badge - Renders the badge of the item.
 * @slot selected-icon - Renders the icon of the item when selected.
 * @slot toggle-icon - Renders the toggle icon.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr open - Whether the item is expanded.
 * @attr selected - Whether the item is selected.
 *
 * @fires opening - Dispatched when the item begins to open.
 * @fires opened - Dispatched when the item has opened.
 * @fires closing - Dispatched when the item begins to close.
 * @fires closed - Dispatched when the item has closed.
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-nav-menu-item-font-size - Font size for the item label.
 * @cssprop --m3e-nav-menu-item-font-weight - Font weight for the item label.
 * @cssprop --m3e-nav-menu-item-line-height - Line height for the item label.
 * @cssprop --m3e-nav-menu-item-tracking - Letter spacing for the item label.
 * @cssprop --m3e-nav-menu-item-padding - Inline padding for the item.
 * @cssprop --m3e-nav-menu-item-height - Height of the item.
 * @cssprop --m3e-nav-menu-item-spacing - Spacing between icon and label.
 * @cssprop --m3e-nav-menu-item-shape - Border radius of the item and focus ring.
 * @cssprop --m3e-nav-menu-item-icon-size - Size of the icon.
 * @cssprop --m3e-nav-menu-item-inset - Indentation for nested items.
 * @cssprop --m3e-nav-menu-item-label-color - Text color for the item label.
 * @cssprop --m3e-nav-menu-item-selected-label-color - Text color for selected item label.
 * @cssprop --m3e-nav-menu-item-selected-container-color - Background color for selected item.
 * @cssprop --m3e-nav-menu-item-selected-container-focus-color - Focus color for selected item container.
 * @cssprop --m3e-nav-menu-item-selected-container-hover-color - Hover color for selected item container.
 * @cssprop --m3e-nav-menu-item-selected-ripple-color - Ripple color for selected item.
 * @cssprop --m3e-nav-menu-item-unselected-container-focus-color - Focus color for unselected item container.
 * @cssprop --m3e-nav-menu-item-unselected-container-hover-color - Hover color for unselected item container.
 * @cssprop --m3e-nav-menu-item-unselected-ripple-color - Ripple color for unselected item.
 * @cssprop --m3e-nav-menu-item-open-container-color - Background color for open item with children.
 * @cssprop --m3e-nav-menu-item-open-container-focus-color - Focus color for open item container.
 * @cssprop --m3e-nav-menu-item-open-container-hover-color - Hover color for open item container.
 * @cssprop --m3e-nav-menu-item-open-ripple-color - Ripple color for open item.
 * @cssprop --m3e-nav-menu-item-disabled-color - Text color for disabled item.
 * @cssprop --m3e-nav-menu-item-disabled-color-opacity - Opacity for disabled item text color.
 * @cssprop --m3e-nav-menu-item-badge-font-size - Font size for badge slot.
 * @cssprop --m3e-nav-menu-item-badge-font-weight - Font weight for badge slot.
 * @cssprop --m3e-nav-menu-item-badge-line-height - Line height for badge slot.
 * @cssprop --m3e-nav-menu-item-badge-tracking - Letter spacing for badge slot.
 * @cssprop --m3e-nav-menu-divider-margin - Margin for divider elements.
 * @cssprop --m3e-nav-menu-item-vertical-inset - Vertical margin for first/last child items.
 */
export declare class M3eNavMenuItemElement extends M3eNavMenuItemElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @internal */ readonly stateLayer?: M3eStateLayerElement;
    /** @internal */ readonly focusRing?: M3eFocusRingElement;
    /** @internal */ readonly ripple?: M3eRippleElement;
    /** @private */ private readonly _base?;
    /** @private */ private _hasChildItems;
    /**
     * Whether the item is expanded.
     * @default false
     */
    open: boolean;
    /** A reference to the nested `HTMLAnchorElement`. */
    get link(): HTMLAnchorElement | null;
    /** A reference to the element used to present the label of the item. */
    get label(): HTMLElement | null;
    /** Whether the item is visible. */
    get visible(): boolean;
    /** The full path of the item, starting with the top-most ancestor, including this item. */
    get path(): ReadonlyArray<M3eNavMenuItemElement>;
    /** Whether the item has child items. */
    get hasChildItems(): boolean;
    /** The parenting item. */
    get parentItem(): M3eNavMenuItemElement | null;
    /** The items that immediately descend from this item. */
    get childItems(): readonly M3eNavMenuItemElement[];
    /** The one-based level of the item. */
    get level(): number;
    /**
     * Expands this item, and optionally, all descendants.
     * @param {boolean} [descendants=false] Whether to expand all descendants.
     */
    expand(descendants?: boolean): void;
    /**
     * Collapses this item, and optionally, all descendants.
     * @param {boolean} [descendants=false] Whether to expand all descendants.
     */
    collapse(descendants?: boolean): void;
    /** Toggles the expanded state of the item. */
    toggle(): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
interface M3eNavMenuItemElementEventMap extends HTMLElementEventMap {
    opening: Event;
    opened: Event;
    closing: Event;
    closed: Event;
}
export interface M3eNavMenuItemElement {
    addEventListener<K extends keyof M3eNavMenuItemElementEventMap>(type: K, listener: (this: M3eNavMenuItemElement, ev: M3eNavMenuItemElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eNavMenuItemElementEventMap>(type: K, listener: (this: M3eNavMenuItemElement, ev: M3eNavMenuItemElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-nav-menu-item": M3eNavMenuItemElement;
    }
}
export {};
//# sourceMappingURL=NavMenuItemElement.d.ts.map