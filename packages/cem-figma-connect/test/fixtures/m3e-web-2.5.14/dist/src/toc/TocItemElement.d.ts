import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { TocNode } from "./TocGenerator";
declare const M3eTocItemElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SelectedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * An item in a table of contents.
 * @tag m3e-toc-item
 *
 * @slot - Renders the label of the item.
 *
 * @attr disabled - A value indicating whether the element is disabled.
 *
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-toc-item-shape - Border radius of the TOC item.
 * @cssprop --m3e-toc-item-padding-block - Block padding for the TOC item.
 * @cssprop --m3e-toc-item-padding - Inline padding for the TOC item.
 * @cssprop --m3e-toc-item-inset - Indentation per level for the TOC item.
 * @cssprop --m3e-toc-active-indicator-animation-duration - Animation duration for the active indicator.
 * @cssprop --m3e-toc-item-font-size - Font size for unselected items.
 * @cssprop --m3e-toc-item-font-weight - Font weight for unselected items.
 * @cssprop --m3e-toc-item-line-height - Line height for unselected items.
 * @cssprop --m3e-toc-item-tracking - Letter spacing for unselected items.
 * @cssprop --m3e-toc-item-color - Text color for unselected items.
 * @cssprop --m3e-toc-item-selected-font-size - Font size for selected items.
 * @cssprop --m3e-toc-item-selected-font-weight - Font weight for selected items.
 * @cssprop --m3e-toc-item-selected-line-height - Line height for selected items.
 * @cssprop --m3e-toc-item-selected-tracking - Letter spacing for selected items.
 * @cssprop --m3e-toc-item-selected-color - Text color for selected items.
 */
export declare class M3eTocItemElement extends M3eTocItemElement_base {
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _base?;
    /** @private */ private readonly _stateLayer?;
    /** @internal */ node?: TocNode;
    /** @internal */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-toc-item": M3eTocItemElement;
    }
}
export {};
//# sourceMappingURL=TocItemElement.d.ts.map