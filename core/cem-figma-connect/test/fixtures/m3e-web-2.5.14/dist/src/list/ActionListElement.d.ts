import { RovingTabIndexManager, selectionManager } from "@m3e/web/core/a11y";
import { M3eListElement } from "./ListElement";
import { M3eListItemButtonElement } from "./ListItemButtonElement";
/**
 * A list of actions.
 *
 * @description
 * The `m3e-action-list` component provides a specialized list container for action-based
 * interactions following Material 3 design principles. It manages keyboard navigation with
 * roving tab index, supporting arrow keys, Home/End navigation, and vertical orientation.
 * The component is optimized for scenarios where each list item represents a clickable action.
 *
 * @tag m3e-action-list
 *
 * @slot - Renders the items of the list.
 *
 * @attr variant - The appearance variant of the list.
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
export declare class M3eActionListElement extends M3eListElement {
    #private;
    /** @private */
    readonly [selectionManager]: RovingTabIndexManager<M3eListItemButtonElement>;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    notifyItemsChange(): Promise<void>;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-action-list": M3eActionListElement;
    }
}
//# sourceMappingURL=ActionListElement.d.ts.map