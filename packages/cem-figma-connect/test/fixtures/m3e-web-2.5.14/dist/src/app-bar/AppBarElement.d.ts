import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { AppBarSize } from "./AppBarSize";
declare const M3eAppBarElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").HtmlForMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A bar, placed a the top of a screen, used to help users navigate through an application.
 *
 * @description
 * The `m3e-app-bar` component is a prominent user interface component that provides consistent
 * access to key actions, navigation, and contextual information at the top of an application screen.
 * Designed according to Material 3 principles, it organizes content with clear hierarchy, supports
 * dynamic color, elevation, and shape, and adapts to scrolling behavior.
 *
 * @example
 * ```html
 * <m3e-app-bar size="medium">
 *  <m3e-icon-button slot="leading-icon" aria-label="Back">
 *    <m3e-icon name="arrow_back"></m3e-icon>
 *  </m3e-icon-button>
 *  <span slot="title">Top 10 hiking trails</span>
 *  <span slot="subtitle">Discover popular trails</span>
 *  <m3e-icon-button slot="trailing-icon" aria-label="Bookmark" variant="tonal">
 *    <m3e-icon name="bookmark" filled></m3e-icon>
 *  </m3e-icon-button>
 * <m3e-app-bar>
 * ```
 * @example
 * The next example illustrates how to attach an app bar to a parenting scroll container
 * to produce elevation on scroll. In this example, the `for` attribute is used to attach a
 * sticky positioned `m3e-app-bar` to a parenting container styled to overflow vertically.
 * When scrolled, the app bar will automatically transition to an elevated state.
 * ```html
 * <div style="overflow-y: auto; height: 300px" id="scrollContainer">
 *  <m3e-app-bar for="scrollContainer" style="position: sticky; top: 0">
 *    <span slot="title">Title</span>
 *  </m3e-app-bar>
 *  <div style="height: 400px; display: flex; align-items: center; justify-content: center">
 *    I am scrolling content
 *  </div>
 * </div>
 * ```
 *
 * @tag m3e-app-bar
 *
 * @slot leading - Renders content positioned at the start of the bar.
 * @slot subtitle - Renders the subtitle of the bar.
 * @slot title - Renders the title of the bar.
 * @slot trailing - Renders one or more action buttons aligned to the end of the bar.
 * @slot leading-icon - Deprecated: use the `leading` slot.
 * @slot trailing-icon - Deprecated: use the `trailing` slot.
 *
 * @attr centered - Whether the title and subtitle are centered.
 * @attr for - The identifier of the interactive control to which this element is attached.
 * @attr size - The size of the bar.
 *
 * @cssprop --m3e-app-bar-container-color - Background color of the app bar container.
 * @cssprop --m3e-app-bar-container-color-on-scroll - Background color of the app bar container when scrolled.
 * @cssprop --m3e-app-bar-container-elevation - Elevation (shadow) of the app bar container.
 * @cssprop --m3e-app-bar-container-elevation-on-scroll - Elevation (shadow) of the app bar container when scrolled.
 * @cssprop --m3e-app-bar-title-text-color - Color of the app bar title text.
 * @cssprop --m3e-app-bar-subtitle-text-color - Color of the app bar subtitle text.
 * @cssprop --m3e-app-bar-padding-left - Left padding for the app bar container.
 * @cssprop --m3e-app-bar-padding-right - Right padding for the app bar container.
 * @cssprop --m3e-app-bar-small-container-height - Height of the small app bar container.
 * @cssprop --m3e-app-bar-small-title-text-font-size - Font size for the small app bar title text.
 * @cssprop --m3e-app-bar-small-title-text-font-weight - Font weight for the small app bar title text.
 * @cssprop --m3e-app-bar-small-title-text-line-height - Line height for the small app bar title text.
 * @cssprop --m3e-app-bar-small-subtitle-text-tracking - Letter spacing (tracking) for the small app bar title text.
 * @cssprop --m3e-app-bar-small-subtitle-text-font-size - Font size for the small app bar subtitle text.
 * @cssprop --m3e-app-bar-small-subtitle-text-font-weight - Font weight for the small app bar subtitle text.
 * @cssprop --m3e-app-bar-small-subtitle-text-line-height - Line height for the small app bar subtitle text.
 * @cssprop --m3e-app-bar-small-subtitle-text-tracking - Letter spacing (tracking) for the small app bar subtitle text.
 * @cssprop --m3e-app-bar-small-heading-padding-left - Left padding for the small app bar heading.
 * @cssprop --m3e-app-bar-small-heading-padding-right - Right padding for the small app bar heading.
 * @cssprop --m3e-app-bar-medium-container-height - Height of the medium app bar container.
 * @cssprop --m3e-app-bar-medium-container-height-with-subtitle - Height of the medium app bar container with subtitle.
 * @cssprop --m3e-app-bar-medium-title-text-font-size - Font size for the medium app bar title text.
 * @cssprop --m3e-app-bar-medium-title-text-font-weight - Font weight for the medium app bar title text.
 * @cssprop --m3e-app-bar-medium-title-text-line-height - Line height for the medium app bar title text.
 * @cssprop --m3e-app-bar-medium-subtitle-text-tracking - Letter spacing (tracking) for the medium app bar title text.
 * @cssprop --m3e-app-bar-medium-subtitle-text-font-size - Font size for the medium app bar subtitle text.
 * @cssprop --m3e-app-bar-medium-subtitle-text-font-weight - Font weight for the medium app bar subtitle text.
 * @cssprop --m3e-app-bar-medium-subtitle-text-line-height - Line height for the medium app bar subtitle text.
 * @cssprop --m3e-app-bar-medium-subtitle-text-tracking - Letter spacing (tracking) for the medium app bar subtitle text.
 * @cssprop --m3e-app-bar-medium-heading-padding-left - Left padding for the medium app bar heading.
 * @cssprop --m3e-app-bar-medium-heading-padding-right - Right padding for the medium app bar heading.
 * @cssprop --m3e-app-bar-medium-padding-top - Top padding for the medium app bar.
 * @cssprop --m3e-app-bar-medium-padding-bottom - Bottom padding for the medium app bar.
 * @cssprop --m3e-app-bar-medium-title-max-lines - Maximum number of lines for the medium app bar title.
 * @cssprop --m3e-app-bar-medium-subtitle-max-lines - Maximum number of lines for the medium app bar subtitle.
 * @cssprop --m3e-app-bar-large-container-height - Height of the large app bar container.
 * @cssprop --m3e-app-bar-large-container-height-with-subtitle - Height of the large app bar container with subtitle.
 * @cssprop --m3e-app-bar-large-title-text-font-size - Font size for the large app bar title text.
 * @cssprop --m3e-app-bar-large-title-text-font-weight - Font weight for the large app bar title text.
 * @cssprop --m3e-app-bar-large-title-text-line-height - Line height for the large app bar title text.
 * @cssprop --m3e-app-bar-large-subtitle-text-tracking - Letter spacing (tracking) for the large app bar title text.
 * @cssprop --m3e-app-bar-large-subtitle-text-font-size - Font size for the large app bar subtitle text.
 * @cssprop --m3e-app-bar-large-subtitle-text-font-weight - Font weight for the large app bar subtitle text.
 * @cssprop --m3e-app-bar-large-subtitle-text-line-height - Line height for the large app bar subtitle text.
 * @cssprop --m3e-app-bar-large-subtitle-text-tracking - Letter spacing (tracking) for the large app bar subtitle text.
 * @cssprop --m3e-app-bar-large-heading-padding-left - Left padding for the large app bar heading.
 * @cssprop --m3e-app-bar-large-heading-padding-right - Right padding for the large app bar heading.
 * @cssprop --m3e-app-bar-large-padding-top - Top padding for the large app bar.
 * @cssprop --m3e-app-bar-large-padding-bottom - Bottom padding for the large app bar.
 * @cssprop --m3e-app-bar-large-title-max-lines - Maximum number of lines for the large app bar title.
 * @cssprop --m3e-app-bar-large-subtitle-max-lines - Maximum number of lines for the large app bar subtitle.
 */
export declare class M3eAppBarElement extends M3eAppBarElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _base?;
    /** @private */ private readonly _leadingIcon?;
    /** @private */ private readonly _trailingIcon?;
    /**
     * Whether the title and subtitle are centered.
     * @default false
     */
    centered: boolean;
    /**
     * The size of the bar.
     * @default "small"
     */
    size: AppBarSize;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    detach(): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @private */
    private _updateScroll;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-app-bar": M3eAppBarElement;
    }
}
export {};
//# sourceMappingURL=AppBarElement.d.ts.map