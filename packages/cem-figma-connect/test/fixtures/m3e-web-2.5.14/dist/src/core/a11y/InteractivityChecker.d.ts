/** Utility for checking the interactivity of an element, such as whether it is focusable. */
export declare class M3eInteractivityChecker {
    #private;
    /**
     * Determines whether a given element can receive focus.
     * @param {Element} element The element to test.
     * @param {readonly Element[]} [parents = undefined] The known parent elements to test. The default value is `undefined`.
     * @param {boolean} [allowVisiblyHidden=false] Whether to allow visibly hidden elements as focusable.
     * @param {boolean} [allowDisabled=false] Whether to allow disabled elements as focusable.
     * @returns {boolean} Whether `element` can receive focus.
     */
    static isFocusable(element: Element, parents?: readonly Element[], allowVisiblyHidden?: boolean, allowDisabled?: boolean): boolean;
    /**
     * Finds interactive elements that descend from the specified element.
     * @param {HTMLElement} element The `HTMLElement` to search.
     * @param {boolean} [allowVisiblyHidden=false] Whether to allow visibly hidden elements as focusable.
     * @returns {HTMLElement[]} The interactive elements that descend from `element`.
     */
    static findInteractiveElements(element: HTMLElement, allowVisiblyHidden?: boolean): HTMLElement[];
}
type M3eInteractivityCheckerClass = typeof M3eInteractivityChecker;
declare global {
    /** Utility for checking the interactivity of an element, such as whether it is focusable. */
    var M3eInteractivityChecker: M3eInteractivityCheckerClass;
}
export {};
//# sourceMappingURL=InteractivityChecker.d.ts.map