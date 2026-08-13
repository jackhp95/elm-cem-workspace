/** A node in a table of contents. */
export interface TocNode {
    /** An opaque identifier that uniquely identifies the node. */
    id: string;
    /** The level of the node. */
    level: number;
    /** The text to display for the node. */
    label: string;
    /** The element of the node. */
    element: HTMLElement;
    /** The child nodes. */
    nodes: TocNode[];
}
/** Provides functionality used to generate a table of contents used for in-page navigation. */
export declare class TocGenerator {
    #private;
    /**
     * Generates nodes from which to construct a table of contents for in-page navigation.
     * @param {HTMLElement} element The element for which to generate a table of contents.
     * @param {number} [maxDepth=6] The maximum depth of the table of contents.
     * @returns {Array<TocNode>} The top-level nodes of the table of contents.
     */
    static generate(element: HTMLElement, maxDepth?: number): Array<TocNode>;
}
//# sourceMappingURL=TocGenerator.d.ts.map