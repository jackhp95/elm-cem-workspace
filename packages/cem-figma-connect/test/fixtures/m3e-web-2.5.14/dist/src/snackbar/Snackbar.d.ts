/** Encapsulates options used to present a snackbar message. */
export interface SnackbarOptions {
    /** The length of time, in milliseconds, to wait before automatically dismissing the snackbar. */
    duration?: number;
    /** The accessible label given to the close button used to dismiss the snackbar. */
    closeLabel?: string;
    /** The callback function invoked when the action is clicked. */
    actionCallback?: () => void;
}
/**
 * Presents short updates about application processes at the bottom of the screen from anywhere in an application.
 * @example
 * The following example illustrates basic usage.
 * ```js
 * M3eSnackbar.open("File deleted");
 * ```
 * @example
 * The next example illustrates presenting a snackbar with an action and callback.
 * ```js
 * M3eSnackbar.open("File deleted", "Undo", {
 *   actionCallback: () => {
 *     // Undo logic here
 *   },
 * });
 */
export declare class M3eSnackbar {
    /**
     * Opens a snackbar with a message.
     * @param {string} message The message to show in the snackbar.
     * @param {SnackbarOptions | undefined} options Options that control the behavior of the snackbar.
     */
    static open(message: string, options?: SnackbarOptions): void;
    /**
     * Opens a snackbar with a message and action.
     * @param {string} message The message to show in the snackbar.
     * @param {string} action The label for the snackbar action.
     * @param {SnackbarOptions | undefined} options Options that control the behavior of the snackbar.
     */
    static open(message: string, action: string, options?: SnackbarOptions): void;
    /**
     * Opens a snackbar with a message, action and optional close affordance.
     * @param {string} message The message to show in the snackbar.
     * @param {string} action The label for the snackbar action.
     * @param {boolean} dismissible Whether to present close affordance.
     * @param {SnackbarOptions | undefined} options Options that control the behavior of the snackbar.
     */
    static open(message: string, action: string, dismissible: boolean, options?: SnackbarOptions): void;
    /**
     * Opens a snackbar with a message and optional close affordance.
     * @param {string} message The message to show in the snackbar.
     * @param {boolean} dismissible Whether to present close affordance.
     * @param {SnackbarOptions | undefined} options Options that control the behavior of the snackbar.
     */
    static open(message: string, dismissible: boolean, options?: SnackbarOptions): void;
    /** Dismisses the currently visible snackbar. */
    static dismiss(): void;
}
type M3eSnackbarClass = typeof M3eSnackbar;
declare global {
    /** Presents short updates about application processes at the bottom of the screen from anywhere in an application. */
    var M3eSnackbar: M3eSnackbarClass;
}
export {};
//# sourceMappingURL=Snackbar.d.ts.map