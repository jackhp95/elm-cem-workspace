/**
 * Asynchronously attempts to focus an element once it becomes focusable.
 * @param {HTMLElement} element The element to to focus.
 * @param {number} [timeout=200] The maximum amount of time to attempt to focus `el`.
 * @returns {Promise<boolean>} A `Promise` that resolves to whether `el` was focused.
 */
export declare function focusWhenReady(element: HTMLElement, timeout?: number): Promise<boolean>;
//# sourceMappingURL=focusWhenReady.d.ts.map