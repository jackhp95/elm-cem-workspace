import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import "@m3e/web/icon-button";
declare const M3eSlideGroupElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & typeof LitElement;
/**
 * Presents pagination controls used to scroll overflowing content.
 *
 * @description
 * The `m3e-slide-group` component presents directional pagination controls for navigating overflowing content.
 * It orchestrates scrollable layouts with expressive slot-based icons and adaptive orientation, revealing navigation
 * affordances only when content exceeds a defined threshold.  It supports both horizontal and vertical flows, and
 * encodes accessibility through customizable labels and interaction states.
 *
 * @example
 * The following example illustrates a horizontally scrollable group of items with directional pagination buttons.
 * The scroll controls appear when content exceeds the `48px` threshold.
 * ```html
 * <m3e-slide-group threshold="48">
 *  <div>Item 1</div>
 *  <div>Item 2</div>
 *  <div>Item 3</div>
 *  <div>Item 4</div>
 *  <div>Item 5</div>
 * </m3e-slide-group>
 * ```
 *
 * @tag m3e-slide-group
 *
 * @slot - Renders the content to paginate.
 * @slot next-icon - Renders the icon to present for the next button.
 * @slot prev-icon - Renders the icon to present for the previous button.
 *
 * @attr disabled - Whether scroll buttons are disabled.
 * @attr next-page-label - The accessible label given to the button used to move to the previous page.
 * @attr previous-page-label - The accessible label given to the button used to move to the next page.
 * @attr threshold - A value, in pixels, indicating the scroll threshold at which to begin showing pagination controls.
 * @attr vertical - Whether content is oriented vertically.
 *
 * @cssprop --m3e-slide-group-button-icon-size - Sets icon size for scroll buttons; overrides default small icon size.
 * @cssprop --m3e-slide-group-button-size - Defines scroll button size; used for width (horizontal) or height (vertical).
 * @cssprop --m3e-slide-group-divider-top - Adds top border to content container for visual separation.
 * @cssprop --m3e-slide-group-divider-bottom - Adds bottom border to content container for visual separation.
 */
export declare class M3eSlideGroupElement extends M3eSlideGroupElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @internal A reference to the container used to scroll content. */
    scrollContainer: HTMLElement;
    /** @private */ private _canPage;
    /** @private */ private _canPageStart;
    /** @private */ private _canPageEnd;
    /**
     * Whether scroll buttons are disabled.
     * @default false
     */
    disabled: boolean;
    /**
     * Whether content is oriented vertically.
     * @default false
     */
    vertical: boolean;
    /**
     * A value, in pixels, indicating the scroll threshold at which to begin showing pagination controls.
     * @default 0
     */
    threshold: number;
    /**
     * The accessible label given to the button used to move to the previous page.
     * @default "Previous page"
     */
    previousPageLabel: string;
    /**
     * The accessible label given to the button used to move to the next page.
     * @default "Next page"
     */
    nextPageLabel: string;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @private */
    private _updatePaging;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-slide-group": M3eSlideGroupElement;
    }
}
export {};
//# sourceMappingURL=SlideGroupElement.d.ts.map