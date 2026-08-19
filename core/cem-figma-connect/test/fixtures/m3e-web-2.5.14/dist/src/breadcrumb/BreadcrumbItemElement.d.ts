import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { BreadcrumbItemCurrent } from "./BreadcrumbItemCurrent";
import "./BreadcrumbItemButtonElement";
declare const M3eBreadcrumbItemElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LinkButtonMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * An item in a breadcrumb.
 *
 * @description
 * The `m3e-breadcrumb-item` element represents a single item in a breadcrumb
 * navigation trail. It renders an internal button and supports navigation
 * attributes for link behavior.
 *
 * @tag m3e-breadcrumb-item
 *
 * @slot - Renders the content of the breadcrumb item.
 * @slot icon - Renders an icon before the item's label.
 *
 * @attr item-label - The accessible label used by the internal breadcrumb button.
 * @attr disabled - Whether the breadcrumb item is disabled.
 * @attr current - Marks the breadcrumb item as the current location in the trail.
 * @attr href - The URL to which the internal breadcrumb link button points.
 * @attr target - The target of the internal breadcrumb link button.
 * @attr download - A value indicating whether the internal link target will be downloaded, optionally specifying a file name.
 * @attr rel - The relationship between the internal link target and the document.
 *
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-breadcrumb-item-shape - Shape of the internal breadcrumb item button.
 * @cssprop --m3e-breadcrumb-item-container-height - Height of the internal breadcrumb item button container.
 * @cssprop --m3e-breadcrumb-item-icon-color - Color of breadcrumb item icon-only content.
 * @cssprop --m3e-breadcrumb-item-icon-padding-inline - Horizontal padding for icon-only breadcrumb items.
 * @cssprop --m3e-breadcrumb-item-icon-hover-state-layer-color - Hover state layer color for icon-only breadcrumb items.
 * @cssprop --m3e-breadcrumb-item-icon-focus-state-layer-color - Focus state layer color for icon-only breadcrumb items.
 * @cssprop --m3e-breadcrumb-item-icon-pressed-state-layer-color - Pressed state layer color for icon-only breadcrumb items.
 * @cssprop --m3e-breadcrumb-item-label-color - Color of breadcrumb item label content.
 * @cssprop --m3e-breadcrumb-item-label-font-size - Font size of breadcrumb item label content.
 * @cssprop --m3e-breadcrumb-item-label-font-weight - Font weight of breadcrumb item label content.
 * @cssprop --m3e-breadcrumb-item-label-line-height - Line height of breadcrumb item label content.
 * @cssprop --m3e-breadcrumb-item-label-tracking - Letter spacing of breadcrumb item label content.
 * @cssprop --m3e-breadcrumb-item-label-padding-inline - Horizontal padding for label breadcrumb items.
 * @cssprop --m3e-breadcrumb-item-label-hover-state-layer-color - Hover state layer color for label breadcrumb items.
 * @cssprop --m3e-breadcrumb-item-label-focus-state-layer-color - Focus state layer color for label breadcrumb items.
 * @cssprop --m3e-breadcrumb-item-label-pressed-state-layer-color - Pressed state layer color for label breadcrumb items.
 * @cssprop --m3e-breadcrumb-item-last-color - Color used for the current breadcrumb item.
 * @cssprop --m3e-breadcrumb-item-icon-label-space - Space between icon and label.
 * @cssprop --m3e-breadcrumb-item-icon-size - Size of the icon.
 * @cssprop --m3e-breadcrumb-item-disabled-color - Disabled color used by the breadcrumb item button.
 * @cssprop --m3e-breadcrumb-item-disabled-opacity - Disabled opacity used by the breadcrumb item button.
 */
export declare class M3eBreadcrumbItemElement extends M3eBreadcrumbItemElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _button;
    /**
     * The accessible label given to the item's internal button.
     * @default ""
     */
    itemLabel: string;
    /**
     * Whether the element is disabled.
     * @default false
     */
    disabled: boolean;
    /**
     * Indicates the current item in the breadcrumb path.
     * @default undefined
     */
    current?: BreadcrumbItemCurrent;
    /** @inheritdoc */
    focus(options?: FocusOptions): void;
    /** @inheritdoc */
    blur(): void;
    /** @inheritdoc */
    click(): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @internal */
    _setSeparator(nodes: Array<Node>): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-breadcrumb-item": M3eBreadcrumbItemElement;
    }
}
export {};
//# sourceMappingURL=BreadcrumbItemElement.d.ts.map