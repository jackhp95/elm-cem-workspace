import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import "@m3e/web/button";
import "@m3e/web/icon-button";
declare const M3eSnackbarElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * Presents short updates about application processes at the bottom of the screen.
 * @tag m3e-snackbar
 *
 * @slot - Renders the content of the snackbar.
 * @slot close-icon - Renders the icon of the button used to close the snackbar.
 *
 * @attr action - The label of the snackbar's action.
 * @attr close-label - The accessible label given to the button used to dismiss the snackbar.
 * @attr dismissible - Whether a button is presented that can be used to close the snackbar.
 * @attr duration - The length of time, in milliseconds, to wait before automatically dismissing the snackbar.
 *
 * @fires beforetoggle - Dispatched before the toggle state changes.
 * @fires toggle - Dispatched after the toggle state has changed.
 *
 * @cssprop --m3e-snackbar-margin - Vertical offset from the bottom of the viewport.
 * @cssprop --m3e-snackbar-container-shape - Border radius of the snackbar container.
 * @cssprop --m3e-snackbar-container-color - Background color of the snackbar.
 * @cssprop --m3e-snackbar-padding - Internal spacing of the snackbar container.
 * @cssprop --m3e-snackbar-min-width - Minimum width of the snackbar.
 * @cssprop --m3e-snackbar-max-width - Maximum width of the snackbar.
 */
export declare class M3eSnackbarElement extends M3eSnackbarElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ static __current: M3eSnackbarElement | null;
    /** The currently open snackbar. */
    static get current(): M3eSnackbarElement | null;
    /**
     * The length of time, in milliseconds, to wait before automatically dismissing the snackbar.
     * @default 3000
     */
    duration: number;
    /**
     * The label of the snackbar's action.
     * @default ""
     */
    action: string;
    /**
     * Whether a button is presented that can be used to close the snackbar.
     * @default false
     */
    dismissible: boolean;
    /**
     * The accessible label given to the button used to dismiss the snackbar.
     * @default "Close"
     */
    closeLabel: string;
    /** Whether the user clicked the action. */
    get isActionTaken(): boolean;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected render(): import("lit-html").TemplateResult<1>;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues): void;
}
interface M3eSnackbarElementEventMap extends HTMLElementEventMap {
    beforetoggle: ToggleEvent;
    toggle: ToggleEvent;
}
export interface M3eSnackbarElement {
    addEventListener<K extends keyof M3eSnackbarElementEventMap>(type: K, listener: (this: M3eSnackbarElement, ev: M3eSnackbarElementEventMap[K]) => void, options?: boolean | AddEventListenerOptions): void;
    addEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void;
    removeEventListener<K extends keyof M3eSnackbarElementEventMap>(type: K, listener: (this: M3eSnackbarElement, ev: M3eSnackbarElementEventMap[K]) => void, options?: boolean | EventListenerOptions): void;
    removeEventListener(type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-snackbar": M3eSnackbarElement;
    }
}
export {};
//# sourceMappingURL=SnackbarElement.d.ts.map