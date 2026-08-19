import { FocusKeyManager } from "./FocusKeyManager";
/**
 * Utility for managing keyboard events and a roving tab index for selectable lists whose items directly receive focus.
 * @template T The type of managed item.
 */
export declare class RovingTabIndexManager<T extends HTMLElement> extends FocusKeyManager<T> {
    #private;
    /** @inheritdoc */
    updateActiveItem(item: T | null | undefined): void;
    /** @inheritdoc */
    setItems(items: T[]): {
        added: readonly T[];
        removed: readonly T[];
    };
    /**
     * Configures whether roving tab index is disabled.
     * @param {boolean} [disabled=true] Whether the roving tab index is disabled.
     * @returns {RovingTabIndexManager<T>} The configured roving tab index manager.
     */
    disableRovingTabIndex(disabled?: boolean): this;
}
//# sourceMappingURL=RovingTabIndexManager.d.ts.map