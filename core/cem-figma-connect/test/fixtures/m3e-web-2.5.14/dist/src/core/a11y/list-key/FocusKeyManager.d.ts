import { ListKeyManager } from "./ListKeyManager";
/**
 * Utility for managing keyboard events for selectable lists whose items directly receive focus.
 * @template T The type of managed item.
 */
export declare class FocusKeyManager<T extends HTMLElement> extends ListKeyManager<T> {
    #private;
    /** @inheritdoc */
    setActiveItem(item: T | null | undefined): void;
    /**
     * Configures the key manager with options used to focus items.
     * @param {FocusOptions} options Options used to focus items.
     * @returns {FocusKeyManager<T>} The configured key manager.
     */
    withOptions(options: FocusOptions): this;
}
//# sourceMappingURL=FocusKeyManager.d.ts.map