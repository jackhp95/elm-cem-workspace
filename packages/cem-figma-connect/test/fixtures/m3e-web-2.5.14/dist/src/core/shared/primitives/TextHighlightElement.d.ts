import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { TextHighlightMode } from "./TextHighlightMode";
/**
 * Highlights text which matches a given search term.
 *
 * @description
 * Highlights all text ranges in slotted content that match a given search term using the CSS Custom Highlight API.
 *
 * @example
 * The following example illustrates highlighting "Lor".
 * ```html
 * <m3e-text-highlight term="Lor">
 *  <p>
 *    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt
 *    ut labore et dolore magna aliqua.
 *  </p>
 * </m3e-text-highlight>
 * ```
 *
 * @tag m3e-text-highlight
 *
 * @slot - Renders the content to highlight.
 *
 * @attr case-sensitive - Whether matching is case sensitive.
 * @attr disabled - A value indicating whether text highlighting is disabled.
 * @attr mode - The mode in which to highlight text.
 * @attr term - The term to highlight.
 *
 * @fires highlight - Dispatched when content is highlighted.
 *
 * @cssprop --m3e-text-highlight-container-color - Background color applied to highlighted text ranges.
 * @cssprop --m3e-text-highlight-color - Foreground color of highlighted text content.
 * @cssprop --m3e-text-highlight-decoration - Optional text decoration (e.g., underline, line-through) for highlighted text.
 * @cssprop --m3e-text-highlight-shadow - Optional text shadow for emphasis or contrast.
 */
export declare class M3eTextHighlightElement extends LitElement {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextId;
    constructor();
    /**
     * A value indicating whether text highlighting is disabled.
     * @default false
     */
    disabled: boolean;
    /**
     * The term to highlight.
     * @default ""
     */
    term: string;
    /**
     * Whether matching is case sensitive.
     * @default false
     */
    caseSensitive: boolean;
    /**
     * The mode in which to highlight text.
     * @default "contains"
     */
    mode: TextHighlightMode;
    /** A value indicating whether text highlighting is supported by the browser. */
    get isSupported(): boolean;
    /** The ranges that match the current term. */
    get ranges(): readonly Range[];
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
interface M3eTextHighlightElementEventMap extends HTMLElementEventMap {
    highlight: CustomEvent<readonly Range[]>;
}
export interface M3eTextHighlightElement {
    addEventListener<K extends keyof M3eTextHighlightElementEventMap>(type: K, listener: (this: M3eTextHighlightElement, ev: M3eTextHighlightElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eTextHighlightElementEventMap>(type: K, listener: (this: M3eTextHighlightElement, ev: M3eTextHighlightElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-text-highlight": M3eTextHighlightElement;
    }
}
export {};
//# sourceMappingURL=TextHighlightElement.d.ts.map