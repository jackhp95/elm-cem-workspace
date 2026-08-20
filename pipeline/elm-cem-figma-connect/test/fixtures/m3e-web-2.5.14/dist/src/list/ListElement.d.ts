import { CSSResultGroup, LitElement } from "lit";
import { ListVariant } from "./ListVariant";
import { M3eListItemElement } from "./ListItemElement";
import { ListItemContentType } from "./ListItemContentType";
declare const M3eListElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A list of items.
 *
 * @description
 * The `m3e-list` component provides a list container for organizing and displaying
 * multiple list items. It supports flexible layout, custom padding, and divider insets
 * via CSS custom properties.
 *
 * @example
 * The following example illustrates a list with a single item using all supported slots.
 *
 * Note: This example uses the `@m3e/icon` package to present Material Design symbols, but any icon package can be
 * substituted depending on your design system or preferences
 *
 * ```html
 * <m3e-list>
 *  <m3e-list-item>
 *    <m3e-icon slot="leading-icon" name="person"></m3e-icon>
 *    <span slot="overline">Overline</span>
 *    Headline
 *    <span slot="supporting-text">Supporting text</span>
 *    <span slot="trailing-text">100+</span>
 *    <m3e-icon slot="trailing-icon" name="arrow_right"></m3e-icon>
 *  </m3e-list-item>
 * </m3e-list>
 * ```
 *
 * @tag m3e-list
 *
 * @slot - Renders the items of the list.
 *
 * @attr variant - The appearance variant of the list.
 *
 * @cssprop --m3e-list-divider-inset-start-size - Start inset for dividers within the list.
 * @cssprop --m3e-list-divider-inset-end-size - End inset for dividers within the list.
 * @cssprop --m3e-segmented-list-segment-gap - Gap between list items in segmented variant.
 * @cssprop --m3e-segmented-list-container-shape - Border radius of the segmented list container.
 * @cssprop --m3e-segmented-list-item-container-color - Background color of items in segmented variant.
 * @cssprop --m3e-segmented-list-item-disabled-container-color - Background color of disabled items in segmented variant.
 * @cssprop --m3e-segmented-list-item-container-shape - Border radius of items in segmented variant.
 * @cssprop --m3e-segmented-list-item-hover-container-shape - Border radius of items in segmented variant on hover.
 * @cssprop --m3e-segmented-list-item-focus-container-shape - Border radius of items in segmented variant on focus.
 * @cssprop --m3e-segmented-list-item-selected-container-shape - Border radius of items in segmented variant when selected.
 */
export declare class M3eListElement extends M3eListElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * The appearance variant of the list.
     * @default "standard"
     */
    variant: ListVariant;
    /** The items of the list. */
    get items(): ReadonlyArray<M3eListItemElement>;
    /** The type of leading content. */
    get leadingContentType(): ListItemContentType;
    /** The type of trailing content. */
    get trailingContentType(): ListItemContentType;
    /** @inheritdoc */
    protected render(): unknown;
    /**
     * @internal
     * Notifies the list that items have changed.
     */
    notifyItemsChange(): void;
    /**
     * @internal
     * Notifies the list that the leading content of an item has changed.
     */
    notifyLeadingContentTypeChange(oldType: ListItemContentType, newType: ListItemContentType): void;
    /**
     * @internal
     * Notifies the list that the trailing content of an item has changed.
     */
    notifyTrailingContentTypeChange(oldType: ListItemContentType, newType: ListItemContentType): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-list": M3eListElement;
    }
}
export {};
//# sourceMappingURL=ListElement.d.ts.map