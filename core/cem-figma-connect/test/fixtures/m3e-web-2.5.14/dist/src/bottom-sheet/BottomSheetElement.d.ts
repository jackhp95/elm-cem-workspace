import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import "@m3e/web/core/a11y";
declare const M3eBottomSheetElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").SuppressInitialAnimationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A sheet used to show secondary content anchored to the bottom of the screen.
 *
 * @description
 * The `m3e-bottom-sheet` component implements a Material 3 bottom sheet with
 * gesture‑driven resizing, detent snapping, and adaptive motion. It behaves as
 * a heavy surface: transitions use non‑bouncy, decelerating motion.
 *
 * The sheet supports direct manipulation through vertical drag gestures.
 * Movement below an 8px threshold is ignored to ensure reliable tap‑to‑cycle
 * behavior on the handle. Once activated, dragging updates the sheet height
 * with friction near the minimum height to prevent abrupt collapse.
 *
 * When detents are defined, the sheet snaps to the nearest detent on release.
 * If hideable, downward gestures may dismiss the sheet using either velocity
 * or a small distance threshold below the collapsed detent. When no detents
 * are present, the sheet behaves as a simple open/hidden surface with a
 * bottom‑measured hide threshold.
 *
 * @example
 * The following example shows a modal bottom sheet with a drag handle,
 * three detents (`fit`, `half`, and `full`), and an action list. The sheet
 * is opened using a dedicated `m3e-bottom-sheet-trigger` associated by ID.
 * ```html
 * <m3e-button>
 *   <m3e-bottom-sheet-trigger for="bottomSheet">
 *     Open Bottom sheet
 *   </m3e-bottom-sheet-trigger>
 * </m3e-button>
 *
 * <m3e-bottom-sheet id="bottomSheet" modal handle hideable detents="fit half full">
 *   <m3e-action-list>
 *     <m3e-list-action autofocus>
 *       <m3e-bottom-sheet-action>Google Keep</m3e-bottom-sheet-action>
 *       <span slot="supporting-text">Add to a note</span>
 *     </m3e-list-action>
 *     <m3e-list-action>
 *       <m3e-bottom-sheet-action>Google Docs</m3e-bottom-sheet-action>
 *       <span slot="supporting-text">Embed in a document</span>
 *     </m3e-list-action>
 *   </m3e-action-list>
 * </m3e-bottom-sheet>
 * ```
 *
 * @tag m3e-bottom-sheet
 *
 * @slot - Renders the content of the sheet.
 * @slot header - Renders the header of the sheet.
 *
 * @attr detent - The zero‑based index of the detent the sheet should open to.
 * @attr detents - Detents (discrete height states) the sheet can snap to.
 * @attr handle - Whether to display a drag handle and enable the top region of the sheet as a gesture surface for dragging between detents.
 * @attr handle-label - The accessible label given to the drag handle.
 * @attr hideable - Whether the bottom sheet can hide when its swiped down.
 * @attr hide-friction - The friction coefficient to hide the sheet.
 * @attr modal - Whether the bottom sheet behaves as modal.
 * @attr open - Whether the bottom sheet is open.
 * @attr overshoot-limit - A fractional value, between 0 and 100, indicating the maximum visual overshoot allowed when dragging past the minimum or maximum size.
 *
 * @fires opening - Dispatched when the sheet begins to open.
 * @fires opened - Dispatched when the sheet has opened.
 * @fires cancel - Dispatched when the sheet is cancelled.
 * @fires closing - Dispatched when the sheet begins to close.
 * @fires closed - Dispatched when the sheet has closed.
 *
 * @cssprop --m3e-bottom-sheet-width - The width of the sheet.
 * @cssprop --m3e-bottom-sheet-max-width - The maximum width of the sheet.
 * @cssprop --m3e-bottom-sheet-container-color - The background color of the sheet container.
 * @cssprop --m3e-bottom-sheet-elevation - The elevation level when not modal.
 * @cssprop --m3e-bottom-sheet-modal-elevation - The elevation level when modal.
 * @cssprop --m3e-bottom-sheet-full-elevation - The elevation level when full height.
 * @cssprop --m3e-bottom-sheet-z-index - The z-index of the non-modal sheet.
 * @cssprop --m3e-bottom-sheet-minimized-container-shape - The border radius when minimized.
 * @cssprop --m3e-bottom-sheet-container-shape - The border radius of the sheet container.
 * @cssprop --m3e-bottom-sheet-full-container-shape - The border radius when full height.
 * @cssprop --m3e-bottom-sheet-scrim-color - The color of the scrim overlay.
 * @cssprop --m3e-bottom-sheet-scrim-opacity - The opacity of the scrim overlay.
 * @cssprop --m3e-bottom-sheet-peek-height - The visible height when minimized.
 * @cssprop --m3e-bottom-sheet-compact-top-space - The top space in compact mode.
 * @cssprop --m3e-bottom-sheet-top-space - The top space in standard mode.
 * @cssprop --m3e-bottom-sheet-padding-block - The vertical padding.
 * @cssprop --m3e-bottom-sheet-padding-inline - The horizontal padding.
 * @cssprop --m3e-bottom-sheet-handle-container-height - The height of the drag handle container.
 * @cssprop --m3e-bottom-sheet-handle-width - The width of the drag handle.
 * @cssprop --m3e-bottom-sheet-handle-height - The height of the drag handle.
 * @cssprop --m3e-bottom-sheet-handle-shape - The border radius of the handle.
 * @cssprop --m3e-bottom-sheet-handle-color - The color of the drag handle.
 * @cssprop --m3e-bottom-sheet-handle-focus-ring-offset - The offset of the focus ring around the handle.
 * @cssprop --m3e-bottom-sheet-color - The foreground (text) color of the sheet.
 * @cssprop --m3e-bottom-sheet-content-font-size - Font size for the sheet content.
 * @cssprop --m3e-bottom-sheet-content-font-weight - Font weight for the sheet content.
 * @cssprop --m3e-bottom-sheet-content-line-height - Line height for the sheet content.
 * @cssprop --m3e-bottom-sheet-content-tracking - Letter spacing (tracking) for the sheet content.
 * @cssprop --m3e-bottom-sheet-header-font-size - Font size for the sheet header.
 * @cssprop --m3e-bottom-sheet-header-font-weight - Font weight for the sheet header.
 * @cssprop --m3e-bottom-sheet-header-line-height - Line height for the sheet header.
 * @cssprop --m3e-bottom-sheet-header-tracking - Letter spacing (tracking) for the sheet header.
 */
export declare class M3eBottomSheetElement extends M3eBottomSheetElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __openSheet?;
    /**
     * Whether the bottom sheet behaves as modal.
     * @default false
     */
    modal: boolean;
    /**
     * Whether the bottom sheet is open.
     * @default false
     */
    open: boolean;
    /**
     * Whether to display a drag handle and enable the top region of the sheet as a gesture
     * surface for dragging between detents.
     * @default false
     */
    handle: boolean;
    /**
     * The accessible label given to the drag handle.
     * @default "Drag handle"
     */
    handleLabel: string;
    /**
     * Detents (discrete height states) the sheet can snap to.
     * @default []
     */
    detents: string[];
    /**
     * The zero‑based index of the detent the sheet should open to.
     * @default 0
     */
    detent: number;
    /**
     * Whether the bottom sheet can hide when its swiped down.
     * @default false
     */
    hideable: boolean;
    /**
     * The friction coefficient to hide the sheet.
     * @default 0.5
     */
    hideFriction: number;
    /**
     * A fractional value, between 0 and 100, indicating the maximum visual overshoot allowed when dragging past the minimum or maximum size.
     * @default 4
     */
    overshootLimit: number;
    /**
     * Shows the sheet.
     * @param {number} detent The zero‑based index of the detent the sheet should open to.
     */
    show(detent?: number): void;
    /** Hides the sheet. */
    hide(): void;
    /**
     * Toggles the opened state of the sheet.
     * @param {number} detent The zero‑based index of the detent the sheet should open to.
     */
    toggle(detent?: number): void;
    /** Moves the sheet to the next detent. */
    cycle(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
}
interface M3eBottomSheetElementEventMap extends HTMLElementEventMap {
    opening: Event;
    opened: Event;
    closing: Event;
    closed: Event;
    cancel: Event;
}
export interface M3eBottomSheetElement {
    addEventListener<K extends keyof M3eBottomSheetElementEventMap>(type: K, listener: (this: M3eBottomSheetElement, ev: M3eBottomSheetElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eBottomSheetElementEventMap>(type: K, listener: (this: M3eBottomSheetElement, ev: M3eBottomSheetElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-bottom-sheet": M3eBottomSheetElement;
    }
}
export {};
//# sourceMappingURL=BottomSheetElement.d.ts.map