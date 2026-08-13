/**
 * Adapted from Angular Material CDK KeyManager
 * Source: https://github.com/angular/components/blob/main/src/cdk/a11y/key-manager/typeahead.ts
 *
 * @license MIT
 * Copyright (c) 2025 Google LLC
 * See LICENSE file in the project root for full license text.
 */
/** A symbol through which to access an element's textual content used for typeahead search. */
export declare const typeaheadLabel: unique symbol;
/** Defines functionality required for an item that supports searching using typeahead. */
export interface TypeaheadItem {
    /** Returns the textual content to search. */
    [typeaheadLabel]?(): string;
}
/**
 * Determines whether a value is a `TypeaheadItem`.
 * @param {unknown} value The value to test.
 * @returns A value indicating whether `value` is an `TypeaheadItem`.
 */
export declare function isTypeaheadItem(value: unknown): value is TypeaheadItem;
/** Encapsulates options used to select items based on typeahead.
 * @template T The type of `TypeaheadItem`.
 */
export interface TypeaheadOptions<T extends TypeaheadItem = TypeaheadItem> {
    /** The interval, in milliseconds, before searching items. */
    debounceInterval?: number;
    /** Function used to determine whether an item should be skipped. */
    skipPredicate?: (item: T) => boolean;
    /** Function invoked when an item is selected. */
    callback: (item: T) => void;
}
/**
 * Implements typeahead functionality which selects items based on keyboard input.
 * @template T The type of `TypeaheadItem`.
 */
export declare class Typeahead<T extends TypeaheadItem = TypeaheadItem> {
    #private;
    /**
     * Initializes a new instance of this class.
     * @param {TypeaheadOptions<T>} options Options that control typeahead behavior.
     */
    constructor(options: TypeaheadOptions<T>);
    /** A value indicating whether the user is currently typing. */
    get isTyping(): boolean;
    /**
     * Sets the items to search.
     * @param {readonly T[]} items The items to search.
     */
    setItems(items: readonly T[]): void;
    /**
     * Sets the index of the selected item.
     * @param {number} index The index of the selected item.
     */
    setSelectedIndex(index: number): void;
    /** Resets the stored sequence of typed characters. */
    reset(): void;
    /**
     * Sets the selected item depending on the key event passed in.
     * @param {KeyboardEvent} e The keyboard event to be used for determining which element should be active.
     */
    onKeyDown(e: KeyboardEvent): void;
}
//# sourceMappingURL=Typeahead.d.ts.map