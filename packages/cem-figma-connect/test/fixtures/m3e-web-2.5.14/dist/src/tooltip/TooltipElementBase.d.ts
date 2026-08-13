import { LitElement, PropertyValues } from "lit";
import { AnchorPosition } from "@m3e/web/core/anchoring";
import { TooltipTouchGestures } from "./TooltipTouchGestures";
declare const TooltipElementBase_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").HtmlForMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/** Provides a base implementation for a tooltip. This class must be inherited. */
export declare abstract class TooltipElementBase extends TooltipElementBase_base {
    #private;
    /** @private */ private static __openTooltips;
    /** @internal */ protected readonly _base: HTMLElement;
    /**
     * Whether the element is disabled.
     * @default false
     */
    disabled: boolean;
    /**
     * The amount of time, in milliseconds, before showing the tooltip.
     * @default 0
     */
    get showDelay(): number;
    set showDelay(value: number);
    /**
     * The amount of time, in milliseconds, before hiding the tooltip.
     * @default 200
     */
    get hideDelay(): number;
    set hideDelay(value: number);
    /**
     * The mode in which to handle touch gestures.
     * @default "auto"
     */
    touchGestures: TooltipTouchGestures;
    /** Whether the tooltip is currently open. */
    get isOpen(): boolean;
    /**
     * Whether the tooltip is interactive.
     * @internal
     */
    protected get _isInteractive(): boolean;
    /**
     * The position in which to anchor the tooltip relative to its trigger.
     * @internal
     */
    protected abstract get _anchorPosition(): AnchorPosition;
    /** @inheritdoc */
    attach(control: HTMLElement): void;
    /** @inheritdoc */
    detach(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /**
     * Manually shows the tooltip.
     * @returns {Promise<void>} A `Promise` that resolves when the tooltip is shown.
     */
    show(): Promise<void>;
    /** Manually hides the tooltip. */
    hide(): void;
    /**
     * Updates the position of the tooltip.
     * @internal
     * @param {HTMLElement} base The internal element of the tooltip to position.
     * @param {number} x The x-coordinate, in pixels, to which to position `base`.
     * @param {number} y The y-coordinate, in pixels, to which to position `base`.
     */
    protected abstract _updatePosition(base: HTMLElement, x: number, y: number): void;
}
export {};
//# sourceMappingURL=TooltipElementBase.d.ts.map