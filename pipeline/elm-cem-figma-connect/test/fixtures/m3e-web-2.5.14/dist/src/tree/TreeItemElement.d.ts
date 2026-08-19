import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { M3eFocusRingElement, M3eRippleElement, M3eStateLayerElement } from "@m3e/web/core";
declare const M3eTreeItemElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SelectedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * An expandable item in a tree.
 *
 * @description
 * The `m3e-tree-item` component represents a single item within an `m3e-tree`.
 * It supports nested child items, expand/collapse behavior, selection,
 * disabled state, and interaction styling. Items may contain a child group
 * that hosts additional `m3e-tree-item` elements.
 *
 * @tag m3e-tree-item
 *
 * @slot - Renders the nested child items.
 * @slot label - Renders the label of the item.
 * @slot icon - Renders the icon of the item.
 * @slot selected-icon - Renders the icon of the item when selected.
 * @slot toggle-icon - Renders the toggle icon.
 * @slot open-toggle-icon - Renders the toggle icon when selected.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr indeterminate - Whether the element's checked state is indeterminate.
 * @attr open - Whether the item is expanded.
 * @attr selected - Whether the item is selected.
 *
 * @fires opening - Dispatched when the item begins to open.
 * @fires opened - Dispatched when the item has opened.
 * @fires closing - Dispatched when the item begins to close.
 * @fires closed - Dispatched when the item has closed.
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-tree-item-font-size - Font size for the item label.
 * @cssprop --m3e-tree-item-font-weight - Font weight for the item label.
 * @cssprop --m3e-tree-item-line-height - Line height for the item label.
 * @cssprop --m3e-tree-item-tracking - Letter spacing for the item label.
 * @cssprop --m3e-tree-item-padding - Inline padding for the item.
 * @cssprop --m3e-tree-item-height - Height of the item.
 * @cssprop --m3e-tree-item-shape - Border radius of the item and focus ring.
 * @cssprop --m3e-tree-item-icon-size - Size of the icon.
 * @cssprop --m3e-tree-item-inset - Indentation for nested items.
 * @cssprop --m3e-tree-item-label-color - Text color for the item label.
 * @cssprop --m3e-tree-item-selected-label-color - Text color for selected item label.
 * @cssprop --m3e-tree-item-selected-container-color - Background color for selected item.
 * @cssprop --m3e-tree-item-selected-container-focus-color - Focus color for selected item container.
 * @cssprop --m3e-tree-item-selected-container-hover-color - Hover color for selected item container.
 * @cssprop --m3e-tree-item-selected-ripple-color - Ripple color for selected item.
 * @cssprop --m3e-tree-item-unselected-container-focus-color - Focus color for unselected item container.
 * @cssprop --m3e-tree-item-unselected-container-hover-color - Hover color for unselected item container.
 * @cssprop --m3e-tree-item-unselected-ripple-color - Ripple color for unselected item.
 * @cssprop --m3e-tree-item-disabled-color - Text color for disabled item.
 * @cssprop --m3e-tree-item-disabled-color-opacity - Opacity for disabled item text color.
 */
export declare class M3eTreeItemElement extends M3eTreeItemElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @internal */ readonly stateLayer?: M3eStateLayerElement;
    /** @internal */ readonly focusRing?: M3eFocusRingElement;
    /** @internal */ readonly ripple?: M3eRippleElement;
    /** @private */ private readonly _base?;
    /** @private */ private _hasChildItems;
    /** @private */ private _multi;
    /**
     * Whether the item is expanded.
     * @default false
     */
    open: boolean;
    /**
     * A value indicating whether the element's selected / checked state is indeterminate.
     * @default false
     */
    indeterminate: boolean;
    /** A reference to the nested `HTMLAnchorElement`. */
    get link(): HTMLAnchorElement | null;
    /** A reference to the element used to present the label of the item. */
    get label(): HTMLElement | null;
    /** Whether the item is visible. */
    get visible(): boolean;
    /** The full path of the item, starting with the top-most ancestor, including this item. */
    get path(): ReadonlyArray<M3eTreeItemElement>;
    /** Whether the item has child items. */
    get hasChildItems(): boolean;
    /** The parenting item. */
    get parentItem(): M3eTreeItemElement | null;
    /** The items that immediately descend from this item. */
    get childItems(): readonly M3eTreeItemElement[];
    /** The one-based level of the item. */
    get level(): number;
    /**
     * Expands this item, and optionally, all descendants.
     * @param {boolean} [descendants=false] Whether to expand all descendants.
     */
    expand(descendants?: boolean): void;
    /**
     * Collapses this item, and optionally, all descendants.
     * @param {boolean} [descendants=false] Whether to collapse all descendants.
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
interface M3eTreeItemElementEventMap extends HTMLElementEventMap {
    opening: Event;
    opened: Event;
    closing: Event;
    closed: Event;
}
export interface M3eTreeItemElement {
    addEventListener<K extends keyof M3eTreeItemElementEventMap>(type: K, listener: (this: M3eTreeItemElement, ev: M3eTreeItemElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eTreeItemElementEventMap>(type: K, listener: (this: M3eTreeItemElement, ev: M3eTreeItemElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-tree-item": M3eTreeItemElement;
    }
}
export {};
//# sourceMappingURL=TreeItemElement.d.ts.map