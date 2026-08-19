import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { M3eFocusRingElement, M3eStateLayerElement, TextHighlightMode } from "@m3e/web/core";
import { typeaheadLabel } from "@m3e/web/core/a11y";
declare const M3eOptionElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SelectedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * An option that can be selected.
 *
 * @description
 * The `m3e-option` component represents an individual selectable item within an option list,
 * adhering to Material Design 3 specifications. It provides visual feedback through state layers and ripple effects,
 * supports single and multiple selection modes, and includes comprehensive accessibility features including
 * keyboard navigation and focus management. The component automatically manages its visual appearance based on
 * selection and disabled states, with configurable styling for interactive and non-interactive variants.
 *
 * @tag m3e-option
 *
 * @slot - Renders the label of the option.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr disable-highlight - Whether text highlighting is disabled.
 * @attr highlight-mode - The mode in which to highlight a term.
 * @attr selected - Whether the element is selected.
 * @attr term - The search term to highlight.
 * @attr value - A string representing the value of the option.
 *
 * @cssprop --m3e-option-container-height - The height of the option container.
 * @cssprop --m3e-option-color - The text color of the option.
 * @cssprop --m3e-option-container-hover-color - The color for the hover state layer.
 * @cssprop --m3e-option-container-focus-color - The color for the focus state layer.
 * @cssprop --m3e-option-ripple-color - The color of the ripple effect.
 * @cssprop --m3e-option-selected-color - The text color when the option is selected.
 * @cssprop --m3e-option-selected-container-color - The background color when the option is selected.
 * @cssprop --m3e-option-selected-container-hover-color - The hover color for the selected state layer.
 * @cssprop --m3e-option-selected-container-focus-color - The focus color for the selected state layer.
 * @cssprop --m3e-option-selected-ripple-color - The ripple color when the option is selected.
 * @cssprop --m3e-option-disabled-color - The text color when the option is disabled.
 * @cssprop --m3e-option-disabled-opacity - The opacity level applied to the disabled text color.
 * @cssprop --m3e-option-icon-label-space - The spacing between the icon and label.
 * @cssprop --m3e-option-padding-start - The left padding of the option content.
 * @cssprop --m3e-option-padding-end - The right padding of the option content.
 * @cssprop --m3e-option-label-text-font-size - The font size of the option label.
 * @cssprop --m3e-option-label-text-font-weight - The font weight of the option label.
 * @cssprop --m3e-option-label-text-line-height - The line height of the option label.
 * @cssprop --m3e-option-label-text-tracking - The letter spacing of the option label.
 * @cssprop --m3e-option-focus-ring-shape - The corner radius of the focus ring.
 * @cssprop --m3e-option-icon-size - The size of the option icons.
 * @cssprop --m3e-option-shape - Base shape of the option.
 * @cssprop --m3e-option-selected-shape - Shape used for a selected option.
 * @cssprop --m3e-option-first-child-shape - Shape for the first option in a list.
 * @cssprop --m3e-option-last-child-shape - Shape for the last option in a list.
 */
export declare class M3eOptionElement extends M3eOptionElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @internal */ readonly focusRing?: M3eFocusRingElement;
    /** @internal */ readonly stateLayer?: M3eStateLayerElement;
    /** @private */ private readonly _ripple?;
    /** A string representing the value of the option. */
    get value(): string;
    set value(value: string);
    /**
     * The search term to highlight.
     * @default ""
     */
    term: string;
    /**
     * The mode in which to highlight a term.
     * @default "contains"
     */
    highlightMode: TextHighlightMode;
    /**
     * Whether text highlighting is disabled.
     * @default false
     */
    disableHighlight: boolean;
    /** The textual label of the option. */
    get label(): string;
    /** @internal */
    [typeaheadLabel](): string;
    /** Whether the option represents an empty option. */
    get isEmpty(): boolean;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-option": M3eOptionElement;
    }
}
export {};
//# sourceMappingURL=OptionElement.d.ts.map