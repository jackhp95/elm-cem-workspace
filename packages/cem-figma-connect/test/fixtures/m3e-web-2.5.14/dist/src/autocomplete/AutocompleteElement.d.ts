import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { M3eOptionElement } from "@m3e/web/option";
import { AutocompleteFilterMode } from "./AutocompleteFilterMode";
import { AutocompleteQueryEventDetail } from "./AutocompleteQueryEventDetail";
declare const M3eAutocompleteElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").HtmlForMixin> & typeof LitElement;
/**
 * Enhances a text input with suggested options.
 *
 * @description
 * The `m3e-autocomplete` component augments a text input field with a dynamically positioned menu of filterable suggestions,
 * following Material Design 3 principles. It provides real-time filtering, keyboard navigation, automatic option activation,
 * and text highlighting to guide user selection. The component manages focus, selection state, and menu visibility while
 * integrating seamlessly with form field containers and supporting both required and optional selection modes.
 *
 * @example
 * The following example illustrates use of the `m3e-autocomplete` paired with a `m3e-form-field`.
 * ```html
 * <m3e-form-field>
 *   <label slot="label" for="fruit">Choose your favorite fruit</label>
 *   <input id="fruit" />
 * </m3e-form-field>
 * <m3e-autocomplete for="fruit">
 *   <m3e-option>Apples</m3e-option>
 *   <m3e-option>Oranges</m3e-option>
 *   <m3e-option>Bananas</m3e-option>
 *   <m3e-option>Grapes</m3e-option>
 * </m3e-autocomplete>
 * ```
 *
 * @tag m3e-autocomplete
 *
 * @attr auto-activate - Whether the first option should be automatically activated.
 * @attr case-sensitive - Whether filtering is case sensitive.
 * @attr filter - Mode in which to filter options.
 * @attr hide-selection-indicator - Whether to hide the selection indicator.
 * @attr hide-loading - Whether to hide the menu when loading options.
 * @attr hide-no-data - Whether to hide the menu when there are no options to show.
 * @attr loading - Whether options are being loaded.
 * @attr loading-label - The text announced and presented when loading options.
 * @attr no-data-label - The text announced and presented when no options are available for the current term.
 * @attr panel-class - Class or list of classes to be applied to the autocomplete's overlay panel.
 * @attr required - Whether the user is required to make a selection when interacting with the autocomplete.
 * @attr results-label - The text announced when available options change for the current term.
 *
 * @slot - Renders the options of the autocomplete.
 * @slot loading - Renders content when loading options.
 * @slot no-data - Renders content when there are no options to show.
 *
 * @fires toggle - Dispatched when the options menu opens or closes.
 * @fires query - Dispatched when the input is focused or when the user modifies its value.
 * @fires change - Dispatched when the committed value changes due to selecting an option or clearing the input.
 */
export declare class M3eAutocompleteElement extends M3eAutocompleteElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextId;
    /** @private */ private _options;
    /** @private */ private readonly _listKeyManager;
    constructor();
    /**
     * Whether to hide the selection indicator.
     * @default false
     */
    hideSelectionIndicator: boolean;
    /**
     * Whether the user is required to make a selection when interacting with the autocomplete.
     * @default false
     */
    required: boolean;
    /**
     * Whether the first option should be automatically activated.
     * @default false
     */
    autoActivate: boolean;
    /**
     * Whether filtering is case sensitive.
     * @default false
     */
    caseSensitive: boolean;
    /**
     * Mode in which to filter options.
     * @default "contains"
     */
    filter: AutocompleteFilterMode | ((option: M3eOptionElement, term: string) => boolean);
    /**
     * Whether options are being loaded.
     * @default false
     */
    loading: boolean;
    /**
     * Whether to hide the menu when there are no options to show.
     * @default false
     */
    hideNoData: boolean;
    /**
     * Whether to hide the menu when loading options.
     * @default false
     */
    hideLoading: boolean;
    /**
     * The text announced and presented when loading options.
     * @default "Loading..."
     */
    loadingLabel: string;
    /**
     * The text announced and presented when no options are available for the current term.
     * @default "No options"
     */
    noDataLabel: string;
    /**
     * The text announced when available options change for the current term.
     * @default (count) => `${count} options`
     */
    resultsLabel: string | ((count: number) => string);
    /**
     * Class or list of classes to be applied to the autocomplete's overlay panel.
     * @default ""
     */
    panelClass: string;
    /** The options that can be selected. */
    get options(): readonly M3eOptionElement[];
    /** The selected option. */
    get selected(): M3eOptionElement | null;
    /** The selected (enabled) value. */
    get value(): string | null;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    detach(): void;
    /**
     * Clears the value of the element.
     * @param [restoreFocus=false] Whether to restore input focus.
     */
    clear(restoreFocus?: boolean): void;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
interface M3eAutocompleteElementEventMap extends HTMLElementEventMap {
    toggle: ToggleEvent;
    query: CustomEvent<AutocompleteQueryEventDetail>;
}
export interface M3eAutocompleteElement {
    addEventListener<K extends keyof M3eAutocompleteElementEventMap>(type: K, listener: (this: M3eAutocompleteElement, ev: M3eAutocompleteElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eAutocompleteElementEventMap>(type: K, listener: (this: M3eAutocompleteElement, ev: M3eAutocompleteElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-autocomplete": M3eAutocompleteElement;
    }
}
export {};
//# sourceMappingURL=AutocompleteElement.d.ts.map