import { CSSResultGroup, LitElement } from "lit";
import "@m3e/web/core/a11y";
import "@m3e/web/icon-button";
declare const M3eDialogElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A dialog that provides important prompts in a user flow.
 *
 * @description
 * The `m3e-dialog` component presents important prompts, alerts, and actions in user flows.
 * Designed according to Material 3 principles, it supports custom header, content, and
 * close icon slots, ARIA accessibility, focus management, and theming via CSS custom properties.
 *
 * @example
 * ```html
 * <m3e-button variant="filled">
 *   <m3e-dialog-trigger for="dlg">Open Dialog</m3e-dialog-trigger>
 * </m3e-button>
 * <m3e-dialog id="dlg" dismissible onclosed="console.log(this.returnValue)">
 *   <span slot="header">Dialog Title</span>
 *   Dialog content goes here.
 *   <div slot="actions" end>
 *     <m3e-button autofocus><m3e-dialog-action return-value="ok">Close</m3e-dialog-action></m3e-button>
 *   </div>
 * </m3e-dialog>
 * ```
 *
 * @tag m3e-dialog
 *
 * @slot - Renders the content of the dialog.
 * @slot header - Renders the header of the dialog.
 * @slot actions - Renders the actions of the dialog.
 * @slot close-icon - Renders the icon of the button used to close the dialog.
 *
 * @attr alert - Whether the dialog is an alert.
 * @attr close-label - The accessible label given to the button used to dismiss the dialog.
 * @attr disable-close -Whether users cannot click the backdrop or press escape to dismiss the dialog.
 * @attr dismissible - Whether a button is presented that can be used to close the dialog.
 * @attr no-focus-trap - Whether to disable focus trapping, which keeps keyboard `Tab` navigation within the dialog.
 * @attr open - Whether the dialog is open.
 *
 * @fires opening - Dispatched when the dialog begins to open.
 * @fires opened - Dispatched when the dialog has opened.
 * @fires cancel - Dispatched when the dialog is cancelled.
 * @fires closing - Dispatched when the dialog begins to close.
 * @fires closed - Dispatched when the dialog has closed.
 *
 * @cssprop --m3e-dialog-shape - Border radius of the dialog container.
 * @cssprop --m3e-dialog-min-width - Minimum width of the dialog.
 * @cssprop --m3e-dialog-max-width - Maximum width of the dialog.
 * @cssprop --m3e-dialog-color - Foreground color of the dialog.
 * @cssprop --m3e-dialog-container-color - Background color of the dialog container.
 * @cssprop --m3e-dialog-scrim-color - Color of the scrim (backdrop overlay).
 * @cssprop --m3e-dialog-scrim-opacity - Opacity of the scrim when open.
 * @cssprop --m3e-dialog-header-container-color - Background color of the dialog header.
 * @cssprop --m3e-dialog-header-color - Foreground color of the dialog header.
 * @cssprop --m3e-dialog-header-font-size - Font size for the dialog header.
 * @cssprop --m3e-dialog-header-font-weight - Font weight for the dialog header.
 * @cssprop --m3e-dialog-header-line-height - Line height for the dialog header.
 * @cssprop --m3e-dialog-header-tracking - Letter spacing for the dialog header.
 * @cssprop --m3e-dialog-content-color - Foreground color of the dialog content.
 * @cssprop --m3e-dialog-content-font-size - Font size for the dialog content.
 * @cssprop --m3e-dialog-content-font-weight - Font weight for the dialog content.
 * @cssprop --m3e-dialog-content-line-height - Line height for the dialog content.
 * @cssprop --m3e-dialog-content-tracking - Letter spacing for the dialog content.
 */
export declare class M3eDialogElement extends M3eDialogElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private static __nextId;
    /** @private */ private _withActions;
    /** @private */ private readonly _base;
    /** @private */ private readonly _content;
    /**
     * Whether the dialog is an alert.
     * @default false
     */
    alert: boolean;
    /**
     * Whether the dialog is open.
     * @default false
     */
    get open(): boolean;
    set open(value: boolean);
    /**
     * Whether a button is presented that can be used to close the dialog.
     * @default false
     */
    dismissible: boolean;
    /**
     * Whether users cannot click the backdrop or press ESC to dismiss the dialog.
     * @default false
     */
    disableClose: boolean;
    /**
     * Whether to disable focus trapping, which keeps keyboard `Tab` navigation within the dialog.
     * @default false
     */
    noFocusTrap: boolean;
    /**
     * The accessible label given to the button used to dismiss the dialog.
     * @default "Close"
     */
    closeLabel: string;
    /**
     * The return value of the dialog.
     * @default ""
     */
    returnValue: string;
    /**
     * Asynchronously opens the dialog.
     * @returns {Promise<void>} A `Promise` that resolves when the dialog is open.
     */
    show(): Promise<void>;
    /**
     * Asynchronously closes the dialog.
     * @param {string} returnValue The value to return.
     * @returns {Promise<void>} A `Promise` that resolves when the dialog is closed.
     */
    hide(returnValue?: string): Promise<void>;
    /** @inheritdoc */
    protected render(): unknown;
}
interface M3eDialogElementEventMap extends HTMLElementEventMap {
    opening: Event;
    opened: Event;
    closing: Event;
    closed: Event;
    cancel: Event;
}
export interface M3eDialogElement {
    addEventListener<K extends keyof M3eDialogElementEventMap>(type: K, listener: (this: M3eDialogElement, ev: M3eDialogElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eDialogElementEventMap>(type: K, listener: (this: M3eDialogElement, ev: M3eDialogElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-dialog": M3eDialogElement;
    }
}
export {};
//# sourceMappingURL=DialogElement.d.ts.map