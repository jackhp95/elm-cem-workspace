import { CSSResultGroup, PropertyValues } from "lit";
import { M3eIconButtonElement } from "@m3e/web/icon-button";
import { M3eChipElement } from "./ChipElement";
declare const M3eInputChipElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledInteractiveMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof M3eChipElement;
/**
 * A chip which represents a discrete piece of information entered by a user.
 *
 * @description
 * The `m3e-input-chip` component represents an input chip, allowing users to enter, display,
 * and manage discrete values such as tags or keywords. It supports expressive styling, accessibility,
 * keyboard interaction, and appearance variants including `elevated` and `outlined`.
 *
 * @example
 * The following example illustrates the use of the `m3e-input-chip-set` inside a `m3e-form-field`.
 * In this example, the `input` slot specifies the `input` element used to add input chips and the
 * field label's `for` attribute targets the `input` element to provide an accessible label.
 * ```html
 * <m3e-form-field>
 *  <label slot="label" for="keywords">Keywords</label>
 *  <m3e-input-chip-set aria-label="Enter keywords">
 *    <input id="keywords" slot="input" placeholder="New keyword..." />
 *  </m3e-input-chip-set>
 * </m3e-form-field>
 * ```
 *
 * @tag m3e-input-chip
 *
 * @slot - Renders the label of the chip.
 * @slot avatar - Renders an avatar before the chip's label.
 * @slot icon - Renders an icon before the chip's label.
 * @slot remove-icon - Renders the icon for the button used to remove the chip.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr disabled-interactive - Whether the element is disabled and interactive.
 * @attr removable - Whether the chip is removable.
 * @attr remove-label - The accessible label given to the button used to remove the chip.
 * @attr value - A string representing the value of the chip.
 * @attr variant - The appearance variant of the chip.
 *
 * @fires remove - Dispatched when the remove button is clicked or DELETE or BACKSPACE key is pressed.
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-chip-container-shape - Border radius of the chip container.
 * @cssprop --m3e-chip-container-height - Base height of the chip container before density adjustment.
 * @cssprop --m3e-chip-label-text-font-size - Font size of the chip label text.
 * @cssprop --m3e-chip-label-text-font-weight - Font weight of the chip label text.
 * @cssprop --m3e-chip-label-text-line-height - Line height of the chip label text.
 * @cssprop --m3e-chip-label-text-tracking - Letter spacing of the chip label text.
 * @cssprop --m3e-chip-label-text-color - Label text color in default state.
 * @cssprop --m3e-chip-icon-color - Icon color in default state.
 * @cssprop --m3e-chip-icon-size - Font size of leading/trailing icons.
 * @cssprop --m3e-chip-spacing - Horizontal gap between chip content elements.
 * @cssprop --m3e-chip-padding-start - Default start padding when no icon is present.
 * @cssprop --m3e-chip-padding-end - Default end padding when no trailing icon is present.
 * @cssprop --m3e-chip-with-icon-padding-start - Start padding when leading icon is present.
 * @cssprop --m3e-chip-with-icon-padding-end - End padding when trailing icon is present.
 * @cssprop --m3e-chip-disabled-label-text-color - Base color for disabled label text.
 * @cssprop --m3e-chip-disabled-label-text-opacity - Opacity applied to disabled label text.
 * @cssprop --m3e-chip-disabled-icon-color - Base color for disabled icons.
 * @cssprop --m3e-chip-disabled-icon-opacity - Opacity applied to disabled icons.
 * @cssprop --m3e-elevated-chip-container-color - Background color for elevated variant.
 * @cssprop --m3e-elevated-chip-elevation - Elevation level for elevated variant.
 * @cssprop --m3e-elevated-chip-hover-elevation - Elevation level on hover.
 * @cssprop --m3e-elevated-chip-disabled-container-color - Background color for disabled elevated variant.
 * @cssprop --m3e-elevated-chip-disabled-container-opacity - Opacity applied to disabled elevated background.
 * @cssprop --m3e-elevated-chip-disabled-elevation - Elevation level for disabled elevated variant.
 * @cssprop --m3e-outlined-chip-outline-thickness - Outline thickness for outlined variant.
 * @cssprop --m3e-outlined-chip-outline-color - Outline color for outlined variant.
 * @cssprop --m3e-outlined-chip-disabled-outline-color - Outline color for disabled outlined variant.
 * @cssprop --m3e-outlined-chip-disabled-outline-opacity - Opacity applied to disabled outline.
 * @cssprop --m3e-chip-avatar-size - Font size of the avatar slot content.
 * @cssprop --m3e-chip-avatar-icon-size - Size of the icon displayed inside the avatar when used in a chip.
 * @cssprop --m3e-chip-avatar-font-size - Font size of text initials inside the avatar when used in a chip.
 * @cssprop --m3e-chip-avatar-font-weight - Font weight of text initials inside the avatar when used in a chip.
 * @cssprop --m3e-chip-avatar-line-height - Line height of text initials inside the avatar when used in a chip.
 * @cssprop --m3e-chip-avatar-tracking - Letter spacing (tracking) of text initials inside the avatar when used in a chip.
 * @cssprop --m3e-chip-disabled-avatar-opacity - Opacity applied to the avatar when disabled.
 * @cssprop --m3e-chip-with-avatar-padding-start - Start padding when an avatar is present.
 */
export declare class M3eInputChipElement extends M3eInputChipElement_base {
    #private;
    /** Indicates that this custom element participates in form submission, validation, and form state restoration. */
    static readonly formAssociated = true;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** A reference to the grid cell of the chip. */
    readonly cell: HTMLSpanElement;
    /** A reference to the button used to remove the chip. */
    readonly removeButton: M3eIconButtonElement | null;
    /**
     * Whether the chip is removable.
     * @default false
     */
    removable: boolean;
    /**
     * The accessible label given to the button used to remove the chip.
     * @default "Remove"
     */
    removeLabel: string;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @internal @inheritdoc */
    protected _renderTrailingIcon(): unknown;
}
interface M3eInputChipElementEventMap extends HTMLElementEventMap {
    remove: Event;
}
export interface M3eInputChipElement {
    addEventListener<K extends keyof M3eInputChipElementEventMap>(type: K, listener: (this: M3eInputChipElement, ev: M3eInputChipElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eInputChipElementEventMap>(type: K, listener: (this: M3eInputChipElement, ev: M3eInputChipElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-input-chip": M3eInputChipElement;
    }
}
export {};
//# sourceMappingURL=InputChipElement.d.ts.map