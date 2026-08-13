import { CSSResultGroup, LitElement } from "lit";
/**
 * An inline container which presents an ellipsis when content overflows.
 *
 * @description
 * The `m3e-text-overflow` component truncates inline content with an ellipsis when it
 * exceeds the available width. It's intended for use inside flex or otherwise
 * constrained containers to preserve layout while providing predictable, single-line
 * truncation behavior for long text.
 *
 * @example
 * A typical usage inside a flex container where the heading and trailing actions are
 * constrained, allowing the center text to truncate with an ellipsis.
 *
 * ```html
 * <div style="display:flex;align-items:center;gap:12px;">
 *   <m3e-icon name="menu"></m3e-icon>
 *   <m3e-text-overflow>Very long title or breadcrumb that should truncate gracefully</m3e-text-overflow>
 *   <m3e-icon name="more_vert"></m3e-icon>
 * </div>
 * ```
 *
 * @tag m3e-text-overflow
 *
 * @slot - Renders the content to truncate with an ellipsis.
 */
export declare class M3eTextOverflowElement extends LitElement {
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-text-overflow": M3eTextOverflowElement;
    }
}
//# sourceMappingURL=TextOverflowElement.d.ts.map