import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { formValue } from "@m3e/web/core";
import { SelectionManager, selectionManager } from "@m3e/web/core/a11y";
import { M3eButtonSegmentElement } from "./ButtonSegmentElement";
declare const M3eSegmentedButtonElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LabelledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DirtyMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").TouchedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").FormAssociatedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A button that allows a user to select from a limited set of options.
 *
 * @description
 * The `m3e-segmented-button` component allows users to select one or more options from a horizontal group.
 * Each segment behaves like a toggle-able button, supporting icon and label content, selection state, and
 * accessibility roles. Built with Material Design 3 principles, it adapts shape, color, and ripple feedback
 * based on interaction state and input modality. Segments are visually unified but independently interactive.
 *
 * @example
 * The following example illustrates a single-select segmented button with four segments.
 * ```html
 * <m3e-segmented-button>
 *  <m3e-button-segment checked>8 oz</m3e-button-segment>
 *  <m3e-button-segment>12 oz</m3e-button-segment>
 *  <m3e-button-segment>16 oz</m3e-button-segment>
 *  <m3e-button-segment>20 oz</m3e-button-segment>
 * </m3e-segmented-button>
 * ```
 * @example
 * The next example illustrates a multiselect segmented button designated using the `multi` attribute.
 * ```html
 * <m3e-segmented-button multi>
 *  <m3e-button-segment checked>$</m3e-button-segment>
 *  <m3e-button-segment checked>$$</m3e-button-segment>
 *  <m3e-button-segment>$$$</m3e-button-segment>
 *  <m3e-button-segment>$$$$</m3e-button-segment>
 * </m3e-segmented-button>
 * ```
 *
 * @tag m3e-segmented-button
 *
 * @slot - Renders the segments of the button.
 *
 * @attr disabled - Whether the element is disabled.
 * @attr hide-selection-indicator - Whether to hide the selection indicator.
 * @attr multi - Whether multiple options can be selected.
 * @attr name - The name that identifies the element when submitting the associated form.
 *
 * @fires beforeinput - Dispatched before the checked state of a segment changes.
 * @fires input - Dispatched when the checked state of a segment changes.
 * @fires change - Dispatched when the checked state of a segment changes.
 *
 * @cssprop --m3e-segmented-button-start-shape - Border radius for the first segment in a segmented button.
 * @cssprop --m3e-segmented-button-end-shape - Border radius for the last segment in a segmented button.
 */
export declare class M3eSegmentedButtonElement extends M3eSegmentedButtonElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @internal */
    readonly [selectionManager]: SelectionManager<M3eButtonSegmentElement>;
    /**
     * Whether multiple options can be selected.
     * @default false
     */
    multi: boolean;
    /**
     * Whether to hide the selection indicator.
     * @default false
     */
    hideSelectionIndicator: boolean;
    /** The segments of the button. */
    get segments(): readonly M3eButtonSegmentElement[];
    /** The selected segment(s) of the button. */
    get selected(): readonly M3eButtonSegmentElement[];
    /** The selected (enabled) value(s) of the button. */
    get value(): string | readonly string[] | null;
    /** @inheritdoc @internal */
    get [formValue](): string | FormData | null;
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
        "m3e-segmented-button": M3eSegmentedButtonElement;
    }
}
export {};
//# sourceMappingURL=SegmentedButtonElement.d.ts.map