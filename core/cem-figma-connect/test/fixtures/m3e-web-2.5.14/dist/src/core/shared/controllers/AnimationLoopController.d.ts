import { ReactiveController, ReactiveControllerHost } from "lit";
/** A `ReactiveController` used to execute a function in an animation loop. */
export declare class AnimationLoopController implements ReactiveController {
    #private;
    constructor(host: ReactiveControllerHost, callback: (deltaTime: number, elapsedTime: number) => void);
    /** @inheritdoc */
    hostDisconnected(): void;
    /** Starts the animation loop. */
    start(): void;
    /** Stops the animation loop. */
    stop(): void;
}
//# sourceMappingURL=AnimationLoopController.d.ts.map