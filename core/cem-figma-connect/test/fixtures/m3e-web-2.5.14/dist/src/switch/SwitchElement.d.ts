import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { formValue } from "@m3e/web/core";
import { SwitchIcons } from "./SwitchIcons";
declare const M3eSwitchElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LabelledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DirtyMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").TouchedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").ConstraintValidationMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").CheckedMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").FormAssociatedMixin> & import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * An on/off control that can be toggled by clicking.
 *
 * @description
 * The `m3e-switch` component is a semantic, accessible toggle control that reflects a binary state.
 * Designed according to Material Design 3 guidelines, it supports shape transitions, and adaptive color
 * theming across selected, unselected, and disabled states. The component responds to user interaction
 * with smooth motion and expressive feedback. It supports optional icons (`none`, `selected`, or `both`)
 * and integrates with form-associated behavior, emitting `input` and `change` events when toggled.
 *
 * @example
 * The following example illustrates a switch wrapped by a `label`.
 *
 * ```html
 * <label>Switch label&nbsp;<m3e-switch></m3e-switch></label>
 * ```
 *
 * @example
 * By default, icons are not presented. Use the `icons` attribute to control which icons to show. The next
 * example illustrates showing both the unselected and selected icons.
 *
 * ```html
 * <label>Switch label&nbsp;<m3e-switch icons="both"></m3e-switch></label>
 * ```
 *
 * @tag m3e-switch
 *
 * @attr checked - Whether the element is checked.
 * @attr disabled - Whether the element is disabled.
 * @attr icons - The icons to present.
 * @attr name - The name that identifies the element when submitting the associated form.
 * @attr value - A string representing the value of the switch.
 *
 * @fires beforeinput - Dispatched before the checked state changes.
 * @fires input - Dispatched when the checked state changes.
 * @fires change - Dispatched when the checked state changes.
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-switch-selected-icon-color - Color of the icon when the switch is selected.
 * @cssprop --m3e-switch-selected-icon-size - Size of the icon in the selected state.
 * @cssprop --m3e-switch-unselected-icon-color - Color of the icon when the switch is unselected.
 * @cssprop --m3e-switch-unselected-icon-size - Size of the icon in the unselected state.
 * @cssprop --m3e-switch-track-height - Height of the switch track.
 * @cssprop --m3e-switch-track-width - Width of the switch track.
 * @cssprop --m3e-switch-track-outline-color - Color of the track's outline.
 * @cssprop --m3e-switch-track-outline-width - Thickness of the track's outline.
 * @cssprop --m3e-switch-track-shape - Corner shape of the track.
 * @cssprop --m3e-switch-selected-track-color - Track color when selected.
 * @cssprop --m3e-switch-unselected-track-color - Track color when unselected.
 * @cssprop --m3e-switch-unselected-handle-height - Height of the handle when unselected.
 * @cssprop --m3e-switch-unselected-handle-width - Width of the handle when unselected.
 * @cssprop --m3e-switch-with-icon-handle-height - Height of the handle when icons are present.
 * @cssprop --m3e-switch-with-icon-handle-width - Width of the handle when icons are present.
 * @cssprop --m3e-switch-selected-handle-height - Height of the handle when selected.
 * @cssprop --m3e-switch-selected-handle-width - Width of the handle when selected.
 * @cssprop --m3e-switch-pressed-handle-height - Height of the handle during press.
 * @cssprop --m3e-switch-pressed-handle-width - Width of the handle during press.
 * @cssprop --m3e-switch-handle-shape - Corner shape of the handle.
 * @cssprop --m3e-switch-selected-handle-color - Handle color when selected.
 * @cssprop --m3e-switch-unselected-handle-color - Handle color when unselected.
 * @cssprop --m3e-switch-state-layer-size - Diameter of the state layer overlay.
 * @cssprop --m3e-switch-state-layer-shape - Corner shape of the state layer.
 * @cssprop --m3e-switch-disabled-selected-icon-color - Icon color when selected and disabled.
 * @cssprop --m3e-switch-disabled-selected-icon-opacity - Icon opacity when selected and disabled.
 * @cssprop --m3e-switch-disabled-unselected-icon-color - Icon color when unselected and disabled.
 * @cssprop --m3e-switch-disabled-unselected-icon-opacity - Icon opacity when unselected and disabled.
 * @cssprop --m3e-switch-disabled-track-opacity - Track opacity when disabled.
 * @cssprop --m3e-switch-disabled-selected-track-color - Track color when selected and disabled.
 * @cssprop --m3e-switch-disabled-unselected-track-color - Track color when unselected and disabled.
 * @cssprop --m3e-switch-disabled-unselected-track-outline-color - Outline color when unselected and disabled.
 * @cssprop --m3e-switch-disabled-unselected-handle-opacity - Handle opacity when unselected and disabled.
 * @cssprop --m3e-switch-disabled-selected-handle-opacity - Handle opacity when selected and disabled.
 * @cssprop --m3e-switch-disabled-selected-handle-color - Handle color when selected and disabled.
 * @cssprop --m3e-switch-disabled-unselected-handle-color - Handle color when unselected and disabled.
 * @cssprop --m3e-switch-selected-hover-icon-color - Icon color when selected and hovered.
 * @cssprop --m3e-switch-unselected-hover-icon-color - Icon color when unselected and hovered.
 * @cssprop --m3e-switch-selected-hover-track-color - Track color when selected and hovered.
 * @cssprop --m3e-switch-selected-hover-state-layer-color - State layer color when selected and hovered.
 * @cssprop --m3e-switch-selected-hover-state-layer-opacity - State layer opacity when selected and hovered.
 * @cssprop --m3e-switch-unselected-hover-track-color - Track color when unselected and hovered.
 * @cssprop --m3e-switch-unselected-hover-track-outline-color - Outline color when unselected and hovered.
 * @cssprop --m3e-switch-unselected-hover-state-layer-color - State layer color when unselected and hovered.
 * @cssprop --m3e-switch-unselected-hover-state-layer-opacity - State layer opacity when unselected and hovered.
 * @cssprop --m3e-switch-selected-hover-handle-color - Handle color when selected and hovered.
 * @cssprop --m3e-switch-unselected-hover-handle-color - Handle color when unselected and hovered.
 * @cssprop --m3e-switch-selected-focus-icon-color - Icon color when selected and focused.
 * @cssprop --m3e-switch-unselected-focus-icon-color - Icon color when unselected and focused.
 * @cssprop --m3e-switch-selected-focus-track-color - Track color when selected and focused.
 * @cssprop --m3e-switch-selected-focus-state-layer-color - State layer color when selected and focused.
 * @cssprop --m3e-switch-selected-focus-state-layer-opacity - State layer opacity when selected and focused.
 * @cssprop --m3e-switch-unselected-focus-track-color - Track color when unselected and focused.
 * @cssprop --m3e-switch-unselected-focus-track-outline-color - Outline color when unselected and focused.
 * @cssprop --m3e-switch-unselected-focus-state-layer-color - State layer color when unselected and focused.
 * @cssprop --m3e-switch-unselected-focus-state-layer-opacity - State layer opacity when unselected and focused.
 * @cssprop --m3e-switch-selected-focus-handle-color - Handle color when selected and focused.
 * @cssprop --m3e-switch-unselected-focus-handle-color - Handle color when unselected and focused.
 * @cssprop --m3e-switch-selected-pressed-icon-color - Icon color when selected and pressed.
 * @cssprop --m3e-switch-unselected-pressed-icon-color - Icon color when unselected and pressed.
 * @cssprop --m3e-switch-selected-pressed-track-color - Track color when selected and pressed.
 * @cssprop --m3e-switch-selected-pressed-state-layer-color - State layer color when selected and pressed.
 * @cssprop --m3e-switch-selected-pressed-state-layer-opacity - State layer opacity when selected and pressed.
 * @cssprop --m3e-switch-unselected-pressed-track-color - Track color when unselected and pressed.
 * @cssprop --m3e-switch-unselected-pressed-track-outline-color - Outline color when unselected and pressed.
 * @cssprop --m3e-switch-unselected-pressed-state-layer-color - State layer color when unselected and pressed.
 * @cssprop --m3e-switch-unselected-pressed-state-layer-opacity - State layer opacity when unselected and pressed.
 * @cssprop --m3e-switch-selected-pressed-handle-color - Handle color when selected and pressed.
 * @cssprop --m3e-switch-unselected-pressed-handle-color - Handle color when unselected and pressed.
 */
export declare class M3eSwitchElement extends M3eSwitchElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _track?;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    constructor();
    /**
     * The icons to present.
     * @default "none"
     */
    icons: SwitchIcons;
    /**
     * A string representing the value of the switch.
     * @default "on"
     */
    value: string;
    /** @inheritdoc @private */
    get [formValue](): string | File | FormData | null;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-switch": M3eSwitchElement;
    }
}
export {};
//# sourceMappingURL=SwitchElement.d.ts.map