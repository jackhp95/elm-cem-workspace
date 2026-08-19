import { ReactiveController, ReactiveControllerHost } from "lit";
/**
 * A `ReactiveController` that provides safe, predictable scroll locking for modal UI
 * surfaces (dialogs, bottom sheets, overlays).
 */
export declare class ScrollLockController implements ReactiveController {
    #private;
    constructor(host: ReactiveControllerHost);
    /** Locks document scrolling only if scroll actually exists. */
    lock(): void;
    /** Unlocks document scrolling and restores the previous state. */
    unlock(): void;
    /** @inheritdoc */
    hostDisconnected(): void;
}
//# sourceMappingURL=ScrollLockController.d.ts.map