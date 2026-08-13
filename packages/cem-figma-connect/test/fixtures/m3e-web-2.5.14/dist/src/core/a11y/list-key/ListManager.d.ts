/**
 * Utility for managing a list of items which supports activation.
 * @template T The type of managed item.
 */
export declare class ListManager<T> {
    #private;
    /** The items being managed. */
    get items(): ReadonlyArray<T>;
    /** The active item. */
    get activeItem(): T | null;
    /**
     * Sets the items to manage.
     * @param {Array<T>} items The new items.
     * @returns {{ added: ReadonlyArray<T>; removed: ReadonlyArray<T> }} An object specifying added and removed items.
     */
    setItems(items: Array<T>): {
        added: ReadonlyArray<T>;
        removed: ReadonlyArray<T>;
    };
    /**
     * Sets the active item.
     * @param {T | null | undefined} item The new active item.
     */
    setActiveItem(item: T | null | undefined): void;
    /**
     * Updates the active item.
     * @param {T | null | undefined} item The active item.
     */
    updateActiveItem(item: T | null | undefined): void;
    /**
     * Configures the list manager with a callback invoked when an item is activated.
     * @param {() => void} callback The callback invoked when an item is activated.
     * @returns {ListManager<T>} The configured list manager.
     */
    onActiveItemChange(callback: () => void): this;
}
//# sourceMappingURL=ListManager.d.ts.map