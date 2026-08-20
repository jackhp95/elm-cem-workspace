import { ReactiveController, ReactiveControllerHost } from "lit";
/**
 * A `ReactiveController` that provides safe, predictable inerting of background
 * content for modal UI surfaces (dialogs, date pickers, fullscreen search views).
 */
export declare class InertController implements ReactiveController {
    #private;
    constructor(host: ReactiveControllerHost & HTMLElement);
    /**
     * Locks background content by applying inertness to all non‑modal elements,
     * isolating the active surface from pointer and keyboard interaction.
     */
    lock(): void;
    /** Restores background interactivity by removing inertness previously applied during `lock()`. */
    unlock(): void;
    /** @inheritdoc */
    hostDisconnected(): void;
}
//# sourceMappingURL=InertController.d.ts.map