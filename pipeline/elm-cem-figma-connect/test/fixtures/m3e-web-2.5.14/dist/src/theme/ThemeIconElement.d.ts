import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { ColorScheme } from "./ColorScheme";
import { ThemeVariant } from "./ThemeVariant";
declare const M3eThemeIconElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * An icon that visually presents a preview of a theme.
 *
 * @description
 * The `m3e-theme-icon` renders a small preview of a theme's surface and primary colors.
 *
 * @example
 * The following example presents a preview of a teal light theme.
 * ```html
 * <m3e-theme-icon color="#004f4f" scheme="light"></m3e-theme-icon>
 * ```
 *
 * @tag m3e-theme-icon
 *
 * @attr color - The hex color of the theme to preview
 * @attr scheme - The color scheme of the theme to preview.
 * @attr variant - The color variant of the theme to preview.
 *
 * @cssprop --m3e-theme-icon-size - Size of the theme icon.
 * @cssprop --m3e-theme-icon-shape - Border radius of the icon container.
 * @cssprop --m3e-theme-icon-outline-color - Outline stroke color of the icon border.
 * @cssprop --m3e-theme-icon-outline-opacity - Opacity percentage applied to the outline color.
 * @cssprop --m3e-theme-icon-container-color - Fill color for the container layer of the previewed theme.
 * @cssprop --m3e-theme-icon-color - Fill color for the primary layer of the previewed theme.
 */
export declare class M3eThemeIconElement extends M3eThemeIconElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * The hex color of the theme to preview
     * @default "#6750A4"
     */
    color: string;
    /** The color variant of the theme.
     * @default "neutral"
     */
    variant: ThemeVariant;
    /**
     * The color scheme of the theme.
     * @default "auto"
     */
    scheme: ColorScheme;
    /** Whether a dark theme is applied. */
    get isDark(): boolean;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
}
export {};
//# sourceMappingURL=ThemeIconElement.d.ts.map