import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { ToolbarVariant } from "./ToolbarVariant";
import { ToolbarShape } from "./ToolbarShape";
declare const M3eToolbarElement_base: import("../core/shared/mixins/Constructor").Constructor<import("@m3e/web/core").VerticalMixin> & import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * Presents frequently used actions relevant to the current page.
 *
 * @description
 * The `m3e-toolbar` component presents contextual actions, navigation, and controls. Designed according to
 * Material 3 principles, it supports vertical and horizontal orientation, shape and variant customization,
 * and adaptive layout via CSS custom properties.
 *
 * @example
 * The following example illustrates a `vibrant`, `rounded` toolbar containing icon buttons.
 *
 * ```html
 * <m3e-toolbar variant="vibrant" shape="rounded">
 *  <m3e-icon-button>
 *    <m3e-icon name="arrow_back"></m3e-icon>
 *  </m3e-icon-button>
 *  <m3e-icon-button>
 *    <m3e-icon name="arrow_forward"></m3e-icon>
 *  </m3e-icon-button>
 *  <m3e-icon-button width="wide" variant="filled">
 *    <m3e-icon name="add"></m3e-icon>
 *  </m3e-icon-button>
 *  <m3e-icon-button>
 *    <m3e-icon name="picture_in_picture"></m3e-icon>
 *  </m3e-icon-button>
 *  <m3e-icon-button>
 *    <m3e-icon name="more_vert"></m3e-icon>
 *  </m3e-icon-button>
 * </m3e-toolbar>
 * ```
 *
 * @tag m3e-toolbar
 *
 * @slot - Renders the content of the toolbar.
 *
 * @attr elevated - Whether the toolbar is elevated.
 * @attr shape - The shape of the toolbar.
 * @attr variant - The appearance variant of the toolbar.
 * @attr vertical - Whether the element is oriented vertically.
 *
 * @cssprop --m3e-toolbar-size - The size (height or width) of the toolbar.
 * @cssprop --m3e-toolbar-spacing - The gap between toolbar items.
 * @cssprop --m3e-toolbar-rounded-shape - Border radius for rounded shape.
 * @cssprop --m3e-toolbar-rounded-padding - Padding for rounded shape.
 * @cssprop --m3e-toolbar-square-padding - Padding for square shape.
 * @cssprop --m3e-toolbar-standard-container-color - Container color for the standard variant.
 * @cssprop --m3e-toolbar-standard-color - Foreground color for the standard variant.
 * @cssprop --m3e-toolbar-vibrant-container-color - Container color for the vibrant variant.
 * @cssprop --m3e-toolbar-vibrant-color - Foreground color for the vibrant variant.
 */
export declare class M3eToolbarElement extends M3eToolbarElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * The appearance variant of the toolbar.
     * @default "standard"
     */
    variant: ToolbarVariant;
    /**
     * The shape of the toolbar.
     * @default "square"
     */
    shape: ToolbarShape;
    /**
     * Whether the toolbar is elevated.
     * @default false
     */
    elevated: boolean;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected update(changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-toolbar": M3eToolbarElement;
    }
}
export {};
//# sourceMappingURL=ToolbarElement.d.ts.map