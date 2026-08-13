import { PropertyValues } from "lit";
import { formValue } from "@m3e/web/core";
import { SelectionManager, selectionManager } from "@m3e/web/core/a11y";
import { M3eListElement } from "./ListElement";
import { M3eListOptionElement } from "./ListOptionElement";
declare const M3eSelectionListElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LabelledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DirtyMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").TouchedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").FormAssociatedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof M3eListElement;
/**
 * A list of selectable options.
 *
 * @description
 * The `m3e-selection-list` component provides a container for managing selectable list items with
 * single or multi-select capabilities. It implements robust keyboard navigation, form association,
 * and state management for both individual options and the list as a whole. The component supports
 * flexible layout, custom theming via CSS custom properties, and comprehensive accessibility features
 * including aria roles, roving tabindex management, and semantic event handling following Material 3
 * design principles.
 *
 * @tag m3e-selection-list
 *
 * @slot - Renders the items of the list.
 *
 * @attr hide-selection-indicator - Whether to hide the selection indicator.
 * @attr multi - Whether multiple items can be selected.
 * @attr variant - The appearance variant of the list.
 *
 * @fires beforeinput - Dispatched before the selected state of an option changes.
 * @fires input - Dispatched when the selected state of an option changes.
 * @fires change - Dispatched when the selected state of an option changes.
 *
 * @cssprop --m3e-list-divider-inset-start-size - Start inset for dividers within the list.
 * @cssprop --m3e-list-divider-inset-end-size - End inset for dividers within the list.
 * @cssprop --m3e-segmented-list-segment-gap - Gap between list items in segmented variant.
 * @cssprop --m3e-segmented-list-container-shape - Border radius of the segmented list container.
 * @cssprop --m3e-segmented-list-item-container-color - Background color of items in segmented variant.
 * @cssprop --m3e-segmented-list-item-disabled-container-color - Background color of disabled items in segmented variant.
 * @cssprop --m3e-segmented-list-item-container-shape - Border radius of items in segmented variant.
 * @cssprop --m3e-segmented-list-item-hover-container-shape - Border radius of items in segmented variant on hover.
 * @cssprop --m3e-segmented-list-item-focus-container-shape - Border radius of items in segmented variant on focus.
 * @cssprop --m3e-segmented-list-item-selected-container-shape - Border radius of items in segmented variant when selected.
 */
export declare class M3eSelectionListElement extends M3eSelectionListElement_base {
    #private;
    /** @private */
    readonly [selectionManager]: SelectionManager<M3eListOptionElement>;
    /**
     * Whether multiple items can be selected.
     * @default false
     */
    multi: boolean;
    /**
     * Whether to hide the selection indicator.
     * @default false
     */
    hideSelectionIndicator: boolean;
    /** The options of the list. */
    get options(): readonly M3eListOptionElement[];
    /** The selected option(s) of the list. */
    get selected(): readonly M3eListOptionElement[];
    /** The selected (enabled) value(s) of the set. */
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
    notifyItemsChange(): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-selection-list": M3eSelectionListElement;
    }
}
export {};
//# sourceMappingURL=SelectionListElement.d.ts.map