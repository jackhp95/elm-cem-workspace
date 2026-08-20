import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { SelectionManager, selectionManager } from "@m3e/web/core/a11y";
import "@m3e/web/slide-group";
import { TabVariant } from "./TabVariant";
import { M3eTabElement } from "./TabElement";
import { TabHeaderPosition } from "./TabHeaderPosition";
declare const M3eTabsElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * Organizes content into separate views where only one view can be visible at a time.
 *
 * @description
 * The `m3e-tabs` component provides a structured navigation surface for organizing content into distinct views,
 * where only one view is visible at a time. It supports scrollable tab headers with optional pagination,
 * accessible labeling for navigation controls, and configurable header positioning to suit various layout
 * contexts. Two visual variants are available: `primary`, which emphasizes active indicators and shape styling
 * for prominent navigation, and `secondary`, which offers a more subtle presentation with reduced indicator
 * thickness. Stretch behavior allows tabs to expand and align rhythmically within their container, consistent
 * with Material 3 guidance.
 *
 * @example
 * The following example illustrates using the `m3e-tabs`, `m3e-tab`, and `m3e-tab-panel` components to present
 * secondary tabs.
 * ```html
 * <m3e-tabs>
 *  <m3e-tab selected for="videos"><m3e-icon slot="icon" name="videocam"></m3e-icon>Video</m3e-tab>
 *  <m3e-tab for="photos"><m3e-icon slot="icon" name="photo"></m3e-icon>Photos</m3e-tab>
 *  <m3e-tab for="audio"><m3e-icon slot="icon" name="music_note"></m3e-icon>Audio</m3e-tab>
 *  <m3e-tab-panel id="videos">Videos</m3e-tab-panel>
 *  <m3e-tab-panel id="photos">Photos</m3e-tab-panel>
 *  <m3e-tab-panel id="audio">Audio</m3e-tab-panel>
 * </m3e-tabs>
 * ```
 *
 * @tag m3e-tabs
 *
 * @slot - Renders the tabs.
 * @slot panel - Renders the panels of the tabs.
 * @slot next-icon - Renders the icon to present for the next button used to paginate.
 * @slot prev-icon - Renders the icon to present for the previous button used to paginate.
 *
 * @attr disable-pagination - Whether scroll buttons are disabled.
 * @attr header-position - The position of the tab headers.
 * @attr next-page-label - The accessible label given to the button used to move to the previous page.
 * @attr previous-page-label - The accessible label given to the button used to move to the next page.
 * @attr stretch - Whether tabs are stretched to fill the header.
 * @attr variant - The appearance variant of the tabs.
 *
 * @fires beforeinput - Dispatched before the selected state of a tab changes.
 * @fires input - Dispatched when the selected state of a tab changes.
 * @fires change - Dispatched when the selected tab changes.
 *
 * @cssprop --m3e-tabs-paginator-button-icon-size - Overrides the icon size for paginator buttons.
 * @cssprop --m3e-tabs-active-indicator-color - Color of the active tab indicator.
 * @cssprop --m3e-tabs-primary-before-active-indicator-shape - Border radius for active indicator when header is before and variant is primary.
 * @cssprop --m3e-tabs-primary-after-active-indicator-shape - Border radius for active indicator when header is after and variant is primary.
 * @cssprop --m3e-tabs-primary-active-indicator-inset - Inset for primary variant's active indicator.
 * @cssprop --m3e-tabs-primary-active-indicator-thickness - Thickness for primary variant's active indicator.
 * @cssprop --m3e-tabs-secondary-active-indicator-thickness - Thickness for secondary variant's active indicator.
 */
export declare class M3eTabsElement extends M3eTabsElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _tablist;
    /** @private */ _selectedIndex: number | null;
    /** @internal */
    readonly [selectionManager]: SelectionManager<M3eTabElement>;
    constructor();
    /**
     * Whether scroll buttons are disabled.
     * @default false
     */
    get disablePagination(): boolean | "auto";
    set disablePagination(value: boolean | "auto");
    /**
     * The position of the tab headers.
     * @default "before"
     */
    headerPosition: TabHeaderPosition;
    /**
     * The appearance variant of the tabs.
     * @default "secondary"
     */
    variant: TabVariant;
    /**
     * Whether tabs are stretched to fill the header.
     * @default false
     */
    stretch: boolean;
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
    /** The tabs. */
    get tabs(): readonly M3eTabElement[];
    /** The selected tab. */
    get selectedTab(): M3eTabElement | null;
    /** The zero-based index of the selected tab. */
    get selectedIndex(): number;
    set selectedIndex(value: number);
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-tabs": M3eTabsElement;
    }
}
export {};
//# sourceMappingURL=TabsElement.d.ts.map