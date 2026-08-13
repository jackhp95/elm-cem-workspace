/**
 * Resolves an element by ID, waiting for document readiness if needed.
 * @param {string} id - The element ID to resolve.
 * @param {ParentNode} root - Optional root node to query from (defaults to document).
 * @returns {Promise<T | null>} A promise that resolves with the element or `null` if not found.
 */
export declare function resolveElementById<T extends Element>(id: string, root?: ParentNode): Promise<T | null>;
//# sourceMappingURL=resolveElementById.d.ts.map