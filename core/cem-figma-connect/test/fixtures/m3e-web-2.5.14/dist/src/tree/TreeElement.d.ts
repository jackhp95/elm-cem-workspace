import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { SelectionManager, selectionManager } from "@m3e/web/core/a11y";
import { M3eTreeItemElement } from "./TreeItemElement";
declare const M3eTreeElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * Presents hierarchical data in a tree structure.
 *
 * @description
 * The `m3e-tree` component presents hierarchical data in a structure that users can
 * navigate, with nested levels that open and collapse as needed.
 *
 * @example
 * The following example illustrates a simple tree with nested child items.
 * ```html
 * <m3e-tree>
 *   <m3e-tree-item open>
 *     <span slot="label">Getting Started</span>
 *     <m3e-tree-item>
 *       <span slot="label">Overview</span>
 *     </m3e-tree-item>
 *     <m3e-tree-item>
 *       <span slot="label">Installation</span>
 *     </m3e-tree-item>
 *   </m3e-tree-item>
 *   <m3e-tree-item>
 *     <span slot="label">Components</span>
 *     <m3e-tree-item>
 *       <span slot="label">Button</span>
 *     </m3e-tree-item>
 *     <m3e-tree-item>
 *       <span slot="label">Card</span>
 *     </m3e-tree-item>
 *   </m3e-tree-item>
 * </m3e-tree>
 * ```
 *
 * @example
 * The next example demonstrates multi-selection with cascading selection state.
 * ```html
 * <m3e-tree multi cascade>
 *   <m3e-tree-item>
 *     <span slot="label">Fruits</span>
 *     <m3e-tree-item>
 *       <span slot="label">Apples</span>
 *     </m3e-tree-item>
 *     <m3e-tree-item>
 *       <span slot="label">Oranges</span>
 *     </m3e-tree-item>
 *     <m3e-tree-item>
 *       <span slot="label">Bananas</span>
 *     </m3e-tree-item>
 *   </m3e-tree-item>
 *   <m3e-tree-item>
 *     <span slot="label">Vegetables</span>
 *     <m3e-tree-item>
 *       <span slot="label">Carrots</span>
 *     </m3e-tree-item>
 *     <m3e-tree-item>
 *       <span slot="label">Broccoli</span>
 *     </m3e-tree-item>
 *     <m3e-tree-item>
 *       <span slot="label">Spinach</span>
 *     </m3e-tree-item>
 *   </m3e-tree-item>
 * </m3e-tree>
 * ```
 *
 * @tag m3e-tree
 *
 * @slot - Renders the items of the tree.
 *
 * @attr multi - Whether multiple items can be selected.
 * @attr cascade -Whether multiple item selection cascades to child items.
 *
 * @fires change - Dispatched when the selected state changes.
 *
 * @cssprop --m3e-tree-scrollbar-width - Width of the tree scrollbar.
 * @cssprop --m3e-tree-scrollbar-color - Color of the tree scrollbar.
 */
export declare class M3eTreeElement extends M3eTreeElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextId;
    /** @private */
    readonly [selectionManager]: SelectionManager<M3eTreeItemElement>;
    constructor();
    /**
     * Whether multiple items can be selected.
     * @default false
     */
    multi: boolean;
    /**
     * Whether multiple item selection cascades to child items.
     * @default false
     */
    cascade: boolean;
    /** The selected items of the tree. */
    get selected(): readonly M3eTreeItemElement[];
    /** All the items of the tree. */
    get items(): readonly M3eTreeItemElement[];
    /**
     * Expands all items, and optionally, all descendants.
     * @param {boolean} [descendants=false] Whether to expand all descendants.
     */
    expand(descendants?: boolean): void;
    /**
     * Expands the specified items, and optionally, all descendants.
     * @param {M3eTreeItemElement[]} items The items to expand.
     * @param {boolean} [descendants=false] Whether to expand all descendants.
     */
    expand(items: M3eTreeItemElement[], descendants?: boolean): void;
    /**
     * Collapses all items, and optionally, all descendants.
     * @param {boolean} [descendants=false] Whether to collapse all descendants.
     */
    collapse(descendants?: boolean): void;
    /**
     * Collapses the specified items, and optionally, all descendants.
     * @param {M3eTreeItemElement[]} items The items to collapse.
     * @param {boolean} [descendants=false] Whether to collapse all descendants.
     */
    collapse(items: M3eTreeItemElement[], descendants?: boolean): void;
    /**
     * Selects the specified item.
     * @param {M3eTreeItemElement} item The item to select.
     * @param {boolean} [activate=false] A value indicating whether to activate the item.
     */
    select(item: M3eTreeItemElement, activate?: boolean): void;
    /**
     * Deselects the specified item.
     * @param {M3eTreeItemElement} item The item to deselect.
     */
    deselect(item: M3eTreeItemElement): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected willUpdate(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-tree": M3eTreeElement;
    }
}
export {};
//# sourceMappingURL=TreeElement.d.ts.map