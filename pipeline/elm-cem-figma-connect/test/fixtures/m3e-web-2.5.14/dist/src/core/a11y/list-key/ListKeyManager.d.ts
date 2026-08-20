/**
 * Adapted from Angular Material CDK KeyManager
 * Source: https://github.com/angular/components/blob/main/src/cdk/a11y/key-manager/list-key-manager.ts
 *
 * @license MIT
 * Copyright (c) 2025 Google LLC
 * See LICENSE file in the project root for full license text.
 */
import { ModifierKey } from "../keycodes";
import { ListManager } from "./ListManager";
import { TypeaheadItem } from "./Typeahead";
/**
 * Utility for managing keyboard events for selectable lists.
 * @template T The type of managed item.
 */
export declare class ListKeyManager<T extends HTMLElement & TypeaheadItem> extends ListManager<T> {
    #private;
    /**
     * Whether the active item will wrap to the other end of
     * list when there are no more items in the given direction.
     * @default false
     */
    wrap: boolean;
    /**
     * Whether to activate the first and last items respectively when
     * the `HOME` or `END` key is pressed.
     * @default false
     */
    homeAndEnd: boolean;
    /**
     * Whether to activate every 10th (or configured) first/last item
     * in the up/down direction when the `PAGEUP` or `PAGEDOWN` key is pressed.
     * @default false
     */
    pageUpAndDown: boolean;
    /**
     * The number of items to skip when the `PAGEUP` or `PAGEDOWN` key is pressed.
     * @default 10
     */
    pageDelta: number;
    /**
     * Whether to the list is oriented vertically.
     * @default false
     */
    vertical: boolean;
    /** The allowed modifier keys.
     * @default []
     */
    allowedModifiers: ModifierKey[];
    /**
     * A function used to skip items.
     * @param {T} item The item to test.
     * @returns {boolean} Whether `item` should be skipped.
     */
    skipPredicate: (item: T) => boolean;
    /**
     * The directionality.
     * @default "ltr"
     */
    directionality: "ltr" | "rtl";
    /** @inheritdoc */
    setItems(items: T[]): {
        added: readonly T[];
        removed: readonly T[];
    };
    /** @inheritdoc */
    updateActiveItem(item: T | null | undefined): void;
    /**
     * Configures the key manager to activate the first and last items respectively when the `HOME` or `END` key is pressed.
     * @param {boolean} [enabled = true] Whether to activate the first and last items respectively when
     * the `HOME` or `END` key is pressed.
     * @returns {ListKeyManager<T>} The configured key manager.
     */
    withHomeAndEnd(enabled?: boolean): this;
    /**
     * Configures the key manager to page up and down when the `PAGEUP` or `PAGEDOWN` key is pressed.
     * @param {boolean} [enabled = true] Whether to activate page up and down when the `PAGEUP` or `PAGEDOWN` key is pressed.
     * @param {number} [pageDelta=10] The number of items to skip when the `PAGEUP` or `PAGEDOWN` key is pressed.
     * @returns {ListKeyManager<T>} The configured key manager.
     */
    withPageUpAndDown(enabled?: boolean, pageDelta?: number): this;
    /**
     * Configures wrapping mode, which determines whether the active item will wrap to the other end of list when there are no more items in the given direction.
     * @param {boolean} [enabled = true] Whether the active item will wrap to the other end of
     * list when there are no more items in the given direction.
     * @returns {ListKeyManager<T>} The configured key manager.
     */
    withWrap(enabled?: boolean): this;
    /**
     * Configures whether to move the selection vertically.
     * @param {boolean} [enabled = true] Whether to move selection vertically.
     * @returns {ListKeyManager<T>} The configured key manager.
     */
    withVerticalOrientation(enabled?: boolean): this;
    /**
     * Configured allowed modifier keys.
     * @param {ModifierKey[]} modifiers The allowed modifier keys.
     * @returns {ListKeyManager<T>} The configured key manager.
     */
    withAllowedModifiers(...modifiers: ModifierKey[]): this;
    /**
     * Configures whether typeahead is enabled.
     * @param {boolean} [enabled = true] Whether typeahead is enabled.
     * @returns {ListKeyManager<T>} The configured key manager.
     */
    withTypeahead(enabled?: boolean): this;
    /**
     * Configures a function used to test whether an item should be skipped.
     * @param skipPredicate A function used to determine whether an item should be skipped.
     * @returns {ListKeyManager<T>} The configured key manager.
     */
    withSkipPredicate(skipPredicate: (item: T) => boolean): this;
    /**
     * Configures the directionality.
     * @param {"ltr" | "rtl"} directionality The directionality.
     * @returns {ListKeyManager<T>} The configured key manager.
     */
    withDirectionality(directionality: "ltr" | "rtl"): this;
    /**
     * Sets the active item depending on the key event passed in.
     * @param {KeyboardEvent} e The keyboard event to be used for determining which element should be active.
     */
    onKeyDown(e: KeyboardEvent): void;
}
//# sourceMappingURL=ListKeyManager.d.ts.map