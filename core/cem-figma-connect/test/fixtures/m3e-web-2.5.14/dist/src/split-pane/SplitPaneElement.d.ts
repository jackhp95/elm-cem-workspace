import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { formValue } from "@m3e/web/core";
import { Direction } from "@m3e/web/core/bidi";
import { SplitPaneOrientation } from "./SplitPaneOrientation";
declare const M3eSplitPaneElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").FormAssociatedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ReconnectedCallbackMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A dual-view layout that separates content with a movable drag handle.
 * @description
 * The `m3e-split-pane` component delivers a Material 3-inspired split view with a
 * movable drag handle, enabling responsive layout composition and pane resizing.
 * It supports keyboard interaction, adaptive orientation, and optional detent snapping
 * for consistent, accessible content distribution.
 *
 * @example
 * The following example illustrates the basic use of the `m3e-split-pane` with start and end content.
 * In this example, the start pane occupies 25% of the available width.
 * ```html
 * <m3e-split-pane value="25">
 *  <m3e-card slot="start"></m3e-card>
 *  <m3e-card slot="end"></m3e-card>
 * </m3e-split-pane>
 * ```
 *
 * @example
 * The next example demonstrates minimum and maximum constraints, where the start pane
 * may shrink to 25% but cannot grow beyond 50% of the available space.
 * ```html
 * <m3e-split-pane value="25" min="25" max="50">
 *  <m3e-card slot="start"></m3e-card>
 *  <m3e-card slot="end"></m3e-card>
 * </m3e-split-pane>
 * ```
 *
 * @example
 * The next example demonstrates percentage‑based detents, allowing the drag handle to snap at
 * 0%, 25%, 50%, 75%, and 100% of the available space.
 * ```html
 * <m3e-split-pane value="50" detents="0 25 50 75 100">
 *  <m3e-card slot="start"></m3e-card>
 *  <m3e-card slot="end"></m3e-card>
 * </m3e-split-pane>
 * ```
 *
 * @tag m3e-split-pane
 *
 * @slot start - Renders content at the logical start side of the pane.
 * @slot end - Renders content at the logical end side of the pane.
 *
 * @attr detents - Detents (discrete sizes) the start pane can snap to.
 * @attr label - The accessible label given to the moveable drag handle.
 * @attr max - A fractional value, between 0 and 100, indicating the maximum size of the start pane.
 * @attr min - A fractional value, between 0 and 100, indicating the minimum size of the start pane.
 * @attr orientation - The orientation of the split.
 * @attr overshoot-limit - A fractional value, between 0 and 100, indicating the maximum visual overshoot allowed when dragging past the minimum or maximum size.
 * @attr step - A fractional value, between 0 and 100, indicating the increment by which to adjust the value when resized via keyboard.
 * @attr value - A fractional value, between 0 and 100, indicating the size of the start pane.
 * @attr wrap-detents - Whether cycling through detents will wrap.
 *
 * @fires beforeinput - Dispatched continuously before the user adjusts the drag handle.
 * @fires input - Dispatched continuously while the user adjusts the drag handle.
 * @fires change - Dispatched when the user finishes adjusting the drag handle.
 *
 * @cssprop --m3e-split-pane-drag-handle-hover-color - Color used for the drag handle hover state.
 * @cssprop --m3e-split-pane-drag-handle-hover-opacity - Opacity used for the drag handle hover state.
 * @cssprop --m3e-split-pane-drag-handle-focus-color - Color used for the drag handle focus state.
 * @cssprop --m3e-split-pane-drag-handle-focus-opacity - Opacity used for the drag handle focus state.
 * @cssprop --m3e-split-pane-drag-handle-color - Background color of the drag handle when not pressed.
 * @cssprop --m3e-split-pane-drag-handle-shape - Corner shape of the drag handle when not pressed.
 * @cssprop --m3e-split-pane-drag-handle-pressed-color - Background color of the drag handle when pressed.
 * @cssprop --m3e-split-pane-drag-handle-pressed-shape - Corner shape of the drag handle when pressed.
 * @cssprop --m3e-split-pane-drag-handle-container-width - Width of the drag handle container.
 * @cssprop --m3e-split-pane-drag-handle-width - Thickness of the drag handle when not pressed.
 * @cssprop --m3e-split-pane-drag-handle-height - Length of the drag handle when not pressed.
 * @cssprop --m3e-split-pane-drag-handle-pressed-width - Thickness of the drag handle when pressed.
 * @cssprop --m3e-split-pane-drag-handle-pressed-height - Length of the drag handle when pressed.
 */
export declare class M3eSplitPaneElement extends M3eSplitPaneElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ _orientation?: Exclude<SplitPaneOrientation, "auto">;
    /** @private */ private _base;
    /** @private */ private _dragHandle;
    /**
     * A fractional value, between 0 and 100, indicating the size of the start pane.
     * @default 50
     */
    value: number;
    /**
     * A fractional value, between 0 and 100, indicating the minimum size of the start pane.
     * @default 0
     */
    min: number;
    /**
     * A fractional value, between 0 and 100, indicating the maximum size of the start pane.
     * @default 100
     */
    max: number;
    /**
     * A fractional value, between 0 and 100, indicating the maximum visual overshoot allowed when dragging past the minimum or maximum size.
     * @default 4
     */
    overshootLimit: number;
    /**
     * A fractional value, between 0 and 100, indicating the increment by which to adjust the value when resized via keyboard.
     * @default 1
     */
    step: number;
    /**
     * Detents (discrete sizes) the start pane can snap to.
     * @default []
     */
    detents: string[];
    /**
     * Whether cycling through detents will wrap.
     * @default false
     */
    wrapDetents: boolean;
    /**
     * The orientation of the split.
     * @default "horizontal"
     */
    orientation: SplitPaneOrientation;
    /**
     * The accessible label given to the movable drag handle.
     * @default "Resize panes"
     */
    label: string;
    /** A function used to generates human readable text for the accessible value (`aria-valuetext`) of the drag handle. */
    valueFormatter?: (value: number, orientation: Omit<SplitPaneOrientation, "auto">, dir: Direction) => string | undefined;
    /** The current orientation of the split. */
    get currentOrientation(): Exclude<SplitPaneOrientation, "auto">;
    /** @inheritdoc */
    get [formValue](): string | File | FormData | null;
    /**
     * Moves the drag handle to the collapsed position. If detents exist, snaps to the collapsed detent.
     * If no detents exist, moves to the minimum allowed value.
     */
    collapse(): void;
    /**
     * Moves the drag handle to the expanded position. If detents exist, snaps to the expanded detent.
     * If no detents exist, moves to the maximum allowed value.
     */
    expand(): void;
    /**
     * Moves the drag handle to the specified position. If detents exist, snaps to the closest detent.
     * If no detents exist, moves to the specified value.
     * @param {number} value A fractional value, between 0 and 100, indicating the size of the start pane.
     */
    snapToValue(value: number): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    reconnectedCallback(): void;
    /** @inheritdoc */
    protected willUpdate(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-split-pane": M3eSplitPaneElement;
    }
}
export {};
//# sourceMappingURL=SplitPaneElement.d.ts.map