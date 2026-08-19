import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { ListItemContentType } from "./ListItemContentType";
declare const M3eListItemElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * An item in a list.
 *
 * @description
 * The `m3e-list-item` component represents a single item within a list. It supports rich
 * content, leading/trailing media, overline, supporting text, and trailing supporting text
 * via named slots. The component is highly customizable through CSS custom properties and
 * is designed for accessibility and flexible layout.
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
 *    <m3e-icon slot="leading" name="person"></m3e-icon>
 *    <span slot="overline">Overline</span>
 *    Headline
 *    <span slot="supporting-text">Supporting text</span>
 *    <m3e-icon slot="trailing" name="arrow_right"></m3e-icon>
 *  </m3e-list-item>
 * </m3e-list>
 * ```
 *
 * @tag m3e-list-item
 *
 * @slot - Renders the content of the list item.
 * @slot leading - Renders the leading content of the list item.
 * @slot overline - Renders the overline of the list item.
 * @slot supporting-text - Renders the supporting text of the list item.
 * @slot trailing - Renders the trailing content of the list item.
 *
 * @cssprop --m3e-list-item-between-space - Horizontal gap between elements.
 * @cssprop --m3e-list-item-leading-space - Horizontal padding for the leading side.
 * @cssprop --m3e-list-item-trailing-space - Horizontal padding for the trailing side.
 * @cssprop --m3e-list-item-padding-inline - Horizontal padding for the list item.
 * @cssprop --m3e-list-item-padding-block - Vertical padding for the list item.
 * @cssprop --m3e-list-item-one-line-top-space - Top padding for one-line items.
 * @cssprop --m3e-list-item-one-line-bottom-space - Bottom padding for one-line items.
 * @cssprop --m3e-list-item-two-line-top-space - Top padding for two-line items.
 * @cssprop --m3e-list-item-two-line-bottom-space - Bottom padding for two-line items.
 * @cssprop --m3e-list-item-three-line-top-space - Top padding for three-line items.
 * @cssprop --m3e-list-item-three-line-bottom-space - Bottom padding for three-line items.
 * @cssprop --m3e-list-item-font-size - Font size for main content.
 * @cssprop --m3e-list-item-font-weight - Font weight for main content.
 * @cssprop --m3e-list-item-line-height - Line height for main content.
 * @cssprop --m3e-list-item-tracking - Letter spacing for main content.
 * @cssprop --m3e-list-item-overline-font-size - Font size for overline slot.
 * @cssprop --m3e-list-item-overline-font-weight - Font weight for overline slot.
 * @cssprop --m3e-list-item-overline-line-height - Line height for overline slot.
 * @cssprop --m3e-list-item-overline-tracking - Letter spacing for overline slot.
 * @cssprop --m3e-list-item-supporting-text-font-size - Font size for supporting text slot.
 * @cssprop --m3e-list-item-supporting-text-font-weight - Font weight for supporting text slot.
 * @cssprop --m3e-list-item-supporting-text-line-height - Line height for supporting text slot.
 * @cssprop --m3e-list-item-supporting-text-tracking - Letter spacing for supporting text slot.
 * @cssprop --m3e-list-item-trailing-text-font-size - Font size for trailing supporting text slot.
 * @cssprop --m3e-list-item-trailing-text-font-weight - Font weight for trailing supporting text slot.
 * @cssprop --m3e-list-item-trailing-text-line-height - Line height for trailing supporting text slot.
 * @cssprop --m3e-list-item-trailing-text-tracking - Letter spacing for trailing supporting text slot.
 * @cssprop --m3e-list-item-icon-size - Size for leading/trailing icons.
 * @cssprop --m3e-list-item-label-text-color - Color for the main content.
 * @cssprop --m3e-list-item-overline-color - Color for the overline slot.
 * @cssprop --m3e-list-item-supporting-text-color - Color for the supporting text slot.
 * @cssprop --m3e-list-item-leading-color - Color for the leading content.
 * @cssprop --m3e-list-item-trailing-color - Color for the trailing content.
 * @cssprop --m3e-list-item-container-color - Background color of the list item.
 * @cssprop --m3e-list-item-container-shape - Border radius of the list item.
 * @cssprop --m3e-list-item-hover-container-shape - Border radius of the list item on hover.
 * @cssprop --m3e-list-item-focus-container-shape - Border radius of the list item on focus.
 * @cssprop --m3e-list-item-video-width - Width of the video slot.
 * @cssprop --m3e-list-item-video-height - Height of the video slot.
 * @cssprop --m3e-list-item-video-shape - Border radius of the video slot.
 * @cssprop --m3e-list-item-image-width - Width of the image slot.
 * @cssprop --m3e-list-item-image-height - Height of the image slot.
 * @cssprop --m3e-list-item-image-shape - Border radius of the image slot.
 * @cssprop --m3e-list-item-three-line-top-offset - Top offset for media in three line items.
 * @cssprop --m3e-list-item-one-line-height - Minimum height of a one line list item.
 * @cssprop --m3e-list-item-two-line-height - Minimum height of a two line list item.
 * @cssprop --m3e-list-item-three-line-height - Minimum height of a three line list item.
 */
export declare class M3eListItemElement extends M3eListItemElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** The type of leading content. */
    get leadingContentType(): ListItemContentType;
    /** The type of trailing content. */
    get trailingContentType(): ListItemContentType;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @internal */
    protected _renderBase(): unknown;
    /** @internal */
    protected _handleLeadingSlotChange(e: Event): void;
    /** @internal */
    protected _handleTrailingSlotChange(e: Event): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-list-item": M3eListItemElement;
    }
}
export {};
//# sourceMappingURL=ListItemElement.d.ts.map