import { LitElement } from "lit";
import { CheckedOrSelectedMixin, DisabledMixin } from "@m3e/web/core";
import { RadioKeyManager } from "./RadioKeyManager";
/** A symbol through which to access an element's selection manager. */
export declare const selectionManager: unique symbol;
/**
 * Utility for managing keyboard events for selectable lists where one or more items can be selected.
 * @template T The type of managed item.
 */
export declare class SelectionManager<T extends LitElement & DisabledMixin & CheckedOrSelectedMixin> extends RadioKeyManager<T> {
    #private;
    /** A value indicating whether multiple items can be selected. */
    get multi(): boolean;
    set multi(value: boolean);
    /** The selected items. */
    get selectedItems(): readonly T[];
    /**
     * Selects or deselects the item based on the item's checked or selected state.
     * @param {T} item The item whose selection state has changed.
     */
    notifySelectionChange(item: T): void;
    /**
     * Deselects the specified item.
     * @param {T} item The item to deselect.
     */
    deselect(item: T): void;
    /**
     * Updates the selected item.
     * @param {T | null | undefined} item The selected item.
     * @param {boolean} [activate=true] A value indicating whether to activate the item.
     */
    select(item: T | null | undefined, activate?: boolean): void;
    /** @inheritdoc */
    setItems(items: T[]): {
        added: readonly T[];
        removed: readonly T[];
    };
    /**
     * Configures the selection manager with a callback invoked when selected items change.
     * @param {() => void} callback The callback invoked when selected items change.
     * @returns {SelectionManager<T>} The configured selection manager.
     */
    onSelectedItemsChange(callback: () => void): this;
}
//# sourceMappingURL=SelectionManager.d.ts.map