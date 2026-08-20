import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { BadgeSize } from "./BadgeSize";
import { BadgePosition } from "./BadgePosition";
declare const M3eBadgeElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").HtmlForMixin> & typeof LitElement;
/**
 * A visual indicator used to label content.
 *
 * @description
 * The `m3e-badge` component is a compact visual indicator used to label content. Designed
 * according to Material Design 3 guidelines, it can display counts, presence, or semantic
 * emphasis, and is attachable to icons, buttons, or other components. Badges support dynamic
 * sizing, color, and shape, ensuring clarity and accessibility while maintaining a consistent,
 * expressive appearance across surfaces.
 *
 * @example
 * The following example illustrates attaching a `m3e-badge` to another element using the `for` attribute.
 * ```html
 * <m3e-button id="button">Button</m3e-button>
 * <m3e-badge for="button">10</m3e-badge>
 * ```
 *
 * @tag m3e-badge
 *
 * @slot - Renders the content of the badge.
 *
 * @attr size - The size of the badge.
 *
 * @cssprop --m3e-badge-shape - Corner radius of the badge.
 * @cssprop --m3e-badge-color - Foreground color of badge content.
 * @cssprop --m3e-badge-container-color - Background color of the badge.
 * @cssprop --m3e-badge-small-size - Fixed dimensions for small badge. Used for minimal indicators (e.g. dot).
 * @cssprop --m3e-badge-medium-size - Height and min-width for medium badge.
 * @cssprop --m3e-badge-medium-font-size - Font size for medium badge label.
 * @cssprop --m3e-badge-medium-font-weight - Font weight for medium badge label.
 * @cssprop --m3e-badge-medium-line-height - Line height for medium badge label.
 * @cssprop --m3e-badge-medium-tracking - Letter spacing for medium badge label.
 * @cssprop --m3e-badge-large-size - Height and min-width for large badge.
 * @cssprop --m3e-badge-large-font-size - Font size for large badge label.
 * @cssprop --m3e-badge-large-font-weight - Font weight for large badge label.
 * @cssprop --m3e-badge-large-line-height - Line height for large badge label.
 * @cssprop --m3e-badge-large-tracking - Letter spacing for large badge label.
 */
export declare class M3eBadgeElement extends M3eBadgeElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    constructor();
    /**
     * The size of the badge.
     * @default "medium"
     */
    size: BadgeSize;
    /**
     * The position of the badge, when attached to another element.
     * @default "above-after"
     */
    position: BadgePosition;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    detach(): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-badge": M3eBadgeElement;
    }
}
export {};
//# sourceMappingURL=BadgeElement.d.ts.map