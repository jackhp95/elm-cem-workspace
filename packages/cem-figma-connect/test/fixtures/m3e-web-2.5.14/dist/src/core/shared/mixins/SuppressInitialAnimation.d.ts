import { LitElement } from "lit";
import { Constructor } from "./Constructor";
import { AttachInternalsMixin } from "./AttachInternals";
/** A symbol used to define the function called to resume animation. */
export declare const resumeAnimation: unique symbol;
/** Defines functionality for an element whose animation can be suppressed. */
export interface SuppressInitialAnimationMixin {
    /** Invoked to resume animation. */
    [resumeAnimation](): void;
}
/**
 * Mixin to augment an element with behavior that suppresses initial animations.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @returns {Constructor<SuppressInitialAnimationMixin> & T} A constructor that implements initial animation suppression.
 */
export declare function SuppressInitialAnimation<T extends Constructor<LitElement & AttachInternalsMixin>>(base: T): Constructor<SuppressInitialAnimationMixin> & T;
//# sourceMappingURL=SuppressInitialAnimation.d.ts.map