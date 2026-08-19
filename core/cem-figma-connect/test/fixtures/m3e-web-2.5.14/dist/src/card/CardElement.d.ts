import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { CardVariant } from "./CardVariant";
import { CardOrientation } from "./CardOrientation";
declare const M3eCardElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").LinkButtonMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").FormSubmitterMixin> & import("../core/shared/mixins/Constructor").Constructor & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledInteractiveMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").DisabledMixin> & import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").AttachInternalsMixin> & typeof LitElement;
/**
 * A content container for text, images (or other media), and actions in the context of a single subject.
 *
 * @description
 * The `m3e-card` component is a flexible, expressive container for presenting a unified subject—text,
 * media, and actions—on a visually distinct surface. It supports multiple appearance variants via the
 * `variant` attribute: `filled` (default, for solid emphasis), `outlined` (for subtle framing with a border),
 * and `elevated` (for depth and motion with shadow elevation).
 *
 * Cards can be made actionable, responding to user interaction when the `actionable` attribute is set, and can be
 * presented inline with surrounding content using the `inline` attribute.
 *
 * It supports both vertical and horizontal layouts through the `orientation` attribute. Content organization is
 * enabled via dedicated slots for `header`, `content`, `actions`, and `footer`, or developers can use the default
 * slot for custom layouts.
 *
 * The component provides dynamic elevation, adaptive shape, and expressive color theming, and responds to interaction states
 * (hover, focus, press, disabled) with smooth motion and visual feedback, ensuring clarity, accessibility,
 * and a cohesive user experience in accordance with Material Design 3 guidelines.
 *
 * @example
 * The following example illustrates each of the dedicated slots of a card.
 * ```html
 * <m3e-card>
 *  <div slot="header">Header section</div>
 *  <div slot="content">Content section</div>
 *  <div slot="actions">Actions section</div>
 *  <div slot="footer">Footer section</div>
 * </m3e-card>
 * ```
 *
 * @tag m3e-card
 *
 * @slot - Renders the content of the card without padding.
 * @slot header - Renders the header of the card.
 * @slot content - Renders the content of the card with padding.
 * @slot actions - Renders the actions of the card.
 * @slot footer - Renders the footer of the card.
 *
 * @attr actionable - Whether the card is "actionable" and will respond to use interaction.
 * @attr inline - Whether to present the card inline with surrounding content.
 * @attr orientation - The orientation of the card.
 * @attr variant - The appearance variant of the card.
 *
 * @fires click - Dispatched when the element is clicked.
 *
 * @cssprop --m3e-card-padding - Internal spacing for all slotted regions
 * @cssprop --m3e-card-shape - Corner radius of the card container.
 * @cssprop --m3e-filled-card-text-color - Foreground color for text content in filled cards.
 * @cssprop --m3e-filled-card-container-color - Background color of the filled card container.
 * @cssprop --m3e-filled-card-container-elevation - Elevation level for filled card container.
 * @cssprop --m3e-filled-card-disabled-text-color - Text color when filled card is disabled.
 * @cssprop --m3e-filled-card-disabled-text-opacity - Opacity applied to text when disabled.
 * @cssprop --m3e-filled-card-disabled-container-color - Background color when disabled.
 * @cssprop --m3e-filled-card-disabled-container-elevation - Elevation level when disabled.
 * @cssprop --m3e-filled-card-disabled-container-elevation-color - Shadow color when disabled.
 * @cssprop --m3e-filled-card-disabled-container-elevation-opacity - Shadow opacity when disabled.
 * @cssprop --m3e-filled-card-disabled-container-opacity - Overall container opacity when disabled.
 * @cssprop --m3e-filled-card-hover-text-color - Text color on hover.
 * @cssprop --m3e-filled-card-hover-state-layer-color - State layer color on hover.
 * @cssprop --m3e-filled-card-hover-state-layer-opacity - State layer opacity on hover.
 * @cssprop --m3e-filled-card-hover-container-elevation - Elevation level on hover.
 * @cssprop --m3e-filled-card-focus-text-color - Text color on focus.
 * @cssprop --m3e-filled-card-focus-state-layer-color - State layer color on focus.
 * @cssprop --m3e-filled-card-focus-state-layer-opacity - State layer opacity on focus.
 * @cssprop --m3e-filled-card-focus-container-elevation - Elevation level on focus.
 * @cssprop --m3e-filled-card-pressed-text-color - Text color on press.
 * @cssprop --m3e-filled-card-pressed-state-layer-color - State layer color on press.
 * @cssprop --m3e-filled-card-pressed-state-layer-opacity - State layer opacity on press.
 * @cssprop --m3e-filled-card-pressed-container-elevation - Elevation level on press.
 * @cssprop --m3e-elevated-card-text-color - Foreground color for text content in elevated cards.
 * @cssprop --m3e-elevated-card-container-color - Background color of the elevated card container.
 * @cssprop --m3e-elevated-card-container-elevation - Elevation level for elevated card container.
 * @cssprop --m3e-elevated-card-disabled-text-color - Text color when elevated card is disabled.
 * @cssprop --m3e-elevated-card-disabled-text-opacity - Opacity applied to text when disabled.
 * @cssprop --m3e-elevated-card-disabled-container-color - Background color when disabled.
 * @cssprop --m3e-elevated-card-disabled-container-elevation - Elevation level when disabled.
 * @cssprop --m3e-elevated-card-disabled-container-elevation-color - Shadow color when disabled.
 * @cssprop --m3e-elevated-card-disabled-container-elevation-opacity - Shadow opacity when disabled.
 * @cssprop --m3e-elevated-card-disabled-container-opacity - Overall container opacity when disabled.
 * @cssprop --m3e-elevated-card-hover-text-color - Text color on hover.
 * @cssprop --m3e-elevated-card-hover-state-layer-color - State layer color on hover.
 * @cssprop --m3e-elevated-card-hover-state-layer-opacity - State layer opacity on hover.
 * @cssprop --m3e-elevated-card-hover-container-elevation - Elevation level on hover.
 * @cssprop --m3e-elevated-card-focus-text-color - Text color on focus.
 * @cssprop --m3e-elevated-card-focus-state-layer-color - State layer color on focus.
 * @cssprop --m3e-elevated-card-focus-state-layer-opacity - State layer opacity on focus.
 * @cssprop --m3e-elevated-card-focus-container-elevation - Elevation level on focus.
 * @cssprop --m3e-elevated-card-pressed-text-color - Text color on press.
 * @cssprop --m3e-elevated-card-pressed-state-layer-color - State layer color on press.
 * @cssprop --m3e-elevated-card-pressed-state-layer-opacity - State layer opacity on press.
 * @cssprop --m3e-elevated-card-pressed-container-elevation - Elevation level on press.
 * @cssprop --m3e-outlined-card-text-color - Foreground color for text content in outlined cards.
 * @cssprop --m3e-outlined-card-container-color - Background color of the outlined card container.
 * @cssprop --m3e-outlined-card-container-elevation - Elevation level for outlined card container.
 * @cssprop --m3e-outlined-card-outline-color - Border color for outlined cards.
 * @cssprop --m3e-outlined-card-outline-thickness - Border thickness for outlined cards.
 * @cssprop --m3e-outlined-card-disabled-text-color - Text color when outlined card is disabled.
 * @cssprop --m3e-outlined-card-disabled-text-opacity - Opacity applied to text when disabled.
 * @cssprop --m3e-outlined-card-disabled-container-elevation - Elevation level when disabled.
 * @cssprop --m3e-outlined-card-disabled-container-elevation-color - Shadow color when disabled.
 * @cssprop --m3e-outlined-card-disabled-container-elevation-opacity - Shadow opacity when disabled.
 * @cssprop --m3e-outlined-card-disabled-outline-color - Border color when disabled.
 * @cssprop --m3e-outlined-card-disabled-outline-opacity - Border opacity when disabled.
 * @cssprop --m3e-outlined-card-hover-text-color - Text color on hover.
 * @cssprop --m3e-outlined-card-hover-state-layer-color - State layer color on hover.
 * @cssprop --m3e-outlined-card-hover-state-layer-opacity - State layer opacity on hover.
 * @cssprop --m3e-outlined-card-hover-container-elevation - Elevation level on hover.
 * @cssprop --m3e-outlined-card-hover-outline-color - Border color on hover.
 * @cssprop --m3e-outlined-card-focus-text-color - Text color on focus.
 * @cssprop --m3e-outlined-card-focus-state-layer-color - State layer color on focus.
 * @cssprop --m3e-outlined-card-focus-state-layer-opacity - State layer opacity on focus.
 * @cssprop --m3e-outlined-card-focus-container-elevation - Elevation level on focus.
 * @cssprop --m3e-outlined-card-focus-outline-color - Border color on focus.
 * @cssprop --m3e-outlined-card-pressed-text-color - Text color on press.
 * @cssprop --m3e-outlined-card-pressed-state-layer-color - State layer color on press.
 * @cssprop --m3e-outlined-card-pressed-state-layer-opacity - State layer opacity on press.
 * @cssprop --m3e-outlined-card-pressed-container-elevation - Elevation level on press.
 * @cssprop --m3e-outlined-card-pressed-outline-color - Border color on press.
 */
export declare class M3eCardElement extends M3eCardElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _base?;
    /** @private */ private readonly _elevation?;
    /** @private */ private readonly _focusRing?;
    /** @private */ private readonly _stateLayer?;
    /** @private */ private readonly _ripple?;
    constructor();
    /**
     * Whether to present the card inline with surrounding content.
     * @default false
     */
    inline: boolean;
    /**
     * Whether the card is "actionable" and will respond to use interaction.
     * @default false
     */
    actionable: boolean;
    /**
     * The appearance variant of the card.
     * @default "filled"
     */
    variant: CardVariant;
    /**
     * The orientation of the card.
     * @default "vertical"
     */
    orientation: CardOrientation;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected render(): unknown;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-card": M3eCardElement;
    }
}
export {};
//# sourceMappingURL=CardElement.d.ts.map