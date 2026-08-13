import { LitElement, PropertyValues } from "lit";
import "@m3e/web/core/a11y";
import { SearchViewMode } from "./SearchViewMode";
import { SearchViewQueryEventDetail } from "./SearchViewQueryEventDetail";
import "./SearchBarElement";
declare const M3eSearchViewElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A surface that presents suggestions and results for a search.
 *
 * @description
 * The `m3e-search-view` component presents the surface for suggestions,
 * history, and results, managing the open and close lifecycle around an
 * embedded search bar. It emits `query`, `clear`, and `toggle`, events to
 * support application driven search logic, and exposes CSS properties for
 * container, shape, spacing, and layout across contained, docked, and full
 * screen configurations.
 *
 * @example
 * The following example shows a contained view in docked mode with a simple set of search results.
 * ```html
 * <m3e-search-view mode="docked" contained>
 *   <input slot="input" placeholder="Search..." />
 *   <m3e-list>
 *     <m3e-list-item>Result One</m3e-list-item>
 *     <m3e-list-item>Result Two</m3e-list-item>
 *     <m3e-list-item>Result Three</m3e-list-item>
 *   </m3e-list>
 * </m3e-search-view>
 * ```
 *
 * @tag m3e-search-view
 *
 * @attr contained - Whether the view features a persistent, filled search container.
 * @attr mode - The behavior mode of the view.
 * @attr open - Whether the view is expanded to show results.
 * @attr clear-label - The accessible label given to the button used to clear the search term.
 * @attr close-label - The accessible label given to the button used to collapse the view.
 * @attr hide-search-icon - Whether to hide the search icon.
 *
 * @slot - When open, renders the results content of the view.
 * @slot input - Renders the input of the view.
 * @slot open-leading - When open, renders content before the input of the view.
 * @slot open-trailing - When open, renders content after the input of the view.
 * @slot closed-leading - When closed, renders content before the input of the view.
 * @slot closed-trailing - When closed, renders content after the input of the view.
 *
 * @fires clear - Dispatched when the search term is cleared.
 * @fires query - Dispatched when the view is opened or when the user modifies the search term.
 * @fires beforetoggle - Dispatched before the toggle state changes.
 * @fires toggle - Dispatched after the toggle state has changed.
 *
 * @cssprop --m3e-search-view-container-color - Background color of the view container.
 * @cssprop --m3e-search-view-contained-container-color - Background color of the contained view container.
 * @cssprop --m3e-search-view-divider-color - Color of the divider separating header and results.
 * @cssprop --m3e-search-view-divider-thickness - Thickness of the divider separating header and results.
 * @cssprop --m3e-search-view-full-screen-container-shape - Shape of the fullscreen view container.
 * @cssprop --m3e-search-view-full-screen-header-container-height - Height of the header container in fullscreen mode.
 * @cssprop --m3e-search-view-docked-container-shape - Shape of the docked view container.
 * @cssprop --m3e-search-view-docked-header-container-height - Height of the header container in docked mode.
 * @cssprop --m3e-search-view-contained-leading-margin - Leading margin for the contained view.
 * @cssprop --m3e-search-view-contained-trailing-margin - Trailing margin for the contained view.
 * @cssprop --m3e-search-view-contained-focused-leading-margin - Leading margin when the contained view is focused.
 * @cssprop --m3e-search-view-contained-focused-trailing-margin - Trailing margin when the contained view is focused.
 * @cssprop --m3e-search-view-contained-docked-bar-results-gap - Gap between the contained docked bar and results.
 * @cssprop --m3e-search-view-contained-docked-results-shape - Shape of the results container in contained docked mode.
 * @cssprop --m3e-search-view-contained-docked-bar-shape - Shape of the bar in contained docked mode.
 * @cssprop --m3e-search-view-contained-full-screen-bar-container-height - Height of the bar container in contained fullscreen mode.
 * @cssprop --m3e-search-view-docked-container-min-height - Minimum height of the docked view container.
 * @cssprop --m3e-search-view-docked-container-max-height - Maximum height of the docked view container.
 * @cssprop --m3e-search-view-contained-docked-results-space - Space above the results in contained docked mode.
 * @cssprop --m3e-search-view-docked-results-bottom-space - Space below the results in docked mode.
 * @cssprop --m3e-search-view-docked-scrim-color - Color of the scrim behind the docked view.
 * @cssprop --m3e-search-view-docked-scrim-opacity - Opacity of the scrim behind the docked view.
 */
export declare class M3eSearchViewElement extends M3eSearchViewElement_base {
    #private;
    /** The styles of the element. */
    static styles: import("lit").CSSResultGroup;
    /** @private */ private _clearable;
    /** @private */ private _mode?;
    /** @private */ private readonly _anchor;
    /** @private */ private readonly _view;
    constructor();
    /**
     * Whether the view features a persistent, filled search container.
     * @default false
     */
    contained: boolean;
    /**
     * The behavior mode of the view.
     * @default "docked"
     */
    mode: SearchViewMode;
    /**
     * Whether the view is expanded to show results.
     * @default false
     */
    open: boolean;
    /**
     * The accessible label given to the button used to clear the search term.
     * @default "Clear"
     */
    clearLabel: string;
    /**
     * The accessible label given to the button used to collapse the view.
     * @default "Close"
     */
    closeLabel: string;
    /**
     * Whether to hide the search icon.
     * @default false;
     */
    hideSearchIcon: boolean;
    /** The current mode applied to the view. */
    get currentMode(): Exclude<SearchViewMode, "auto">;
    set currentMode(value: Exclude<SearchViewMode, "auto">);
    /** Clears the search term. */
    clear(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected willUpdate(changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @private */
    private _handleFocusChange;
}
interface M3eSearchViewElementEventMap extends HTMLElementEventMap {
    clear: Event;
    query: CustomEvent<SearchViewQueryEventDetail>;
    beforetoggle: ToggleEvent;
    toggle: ToggleEvent;
}
export interface M3eSearchViewElement {
    addEventListener<K extends keyof M3eSearchViewElementEventMap>(type: K, listener: (this: M3eSearchViewElement, ev: M3eSearchViewElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eSearchViewElementEventMap>(type: K, listener: (this: M3eSearchViewElement, ev: M3eSearchViewElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-search-view": M3eSearchViewElement;
    }
}
export {};
//# sourceMappingURL=SearchViewElement.d.ts.map