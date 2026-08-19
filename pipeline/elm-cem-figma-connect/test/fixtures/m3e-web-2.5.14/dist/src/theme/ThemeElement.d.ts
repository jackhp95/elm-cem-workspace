import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { ColorScheme } from "./ColorScheme";
import { ContrastLevel } from "./ContrastLevel";
import { MotionScheme } from "./MotionScheme";
import { ThemeVariant } from "./ThemeVariant";
/**
 * A non-visual element responsible for application-level theming.
 *
 * @description
 * The `m3e-theme` component is a non-visual element used to apply dynamic color, expressive motion, density, and strong focus indicators
 * to nested, theme-aware elements.
 *
 * When `m3e-theme` is nested directly beneath the `<body>` of a document, the `<body>`'s `background-color` is set to the computed
 * value of `--md-sys-color-background` and `color` is set to the computed value of `--md-sys-color-on-background`. In addition,
 * the document's `scrollbar-color` is set to the computed values of `--m3e-scrollbar-thumb-color` and `--m3e-scrollbar-track-color` which,
 * when supported, cascades to all viewport scrollbars.
 *
 * @example
 * The following example adds a top-level `m3e-theme` directly beneath a document's `<body>` element to
 * apply application-level theming.  In this example, `color` and `scheme` are used to create a dynamic color
 * palette which automatically adjusts to a user's light or dark color preference. In addition, expressive motion
 * and strong focus indicators are enabled.
 *
 * ```html
 * <body>
 *  <m3e-theme color="#6750A4" scheme="auto" motion="expressive" strong-focus>
 *      <!-- Normal body content here. -->
 *  </m3e-theme>
 * <body/>
 * ```
 * @tag m3e-theme
 *
 * @slot - Renders content styled by the theme.
 *
 * @attr color - The hex color from which to derive dynamic color palettes.
 * @attr contrast - The contrast level of the theme.
 * @attr density - The density scale (0, -1, -2).
 * @attr scheme - The color scheme of the theme.
 * @attr strong-focus - Whether to enable strong focus indicators.
 * @attr variant - The color variant of the theme.
 *
 * @fires change - Dispatched when the theme changes.
 */
export declare class M3eThemeElement extends LitElement {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /**
     * The hex color from which to derive dynamic color palettes.
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
    /**
     * The contrast level of the theme.
     * @default "standard"
     */
    contrast: ContrastLevel;
    /**
     * Whether to enable strong focus indicators.
     * @default false
     */
    strongFocus: boolean;
    /**
     * The density scale (0, -1, -2).
     * @default 0
     */
    density: number;
    /** The motion scheme.
     * @default "standard"
     */
    motion: MotionScheme;
    /** Whether a dark theme is applied. */
    get isDark(): boolean;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected firstUpdated(_changedProperties: PropertyValues): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-theme": M3eThemeElement;
    }
}
//# sourceMappingURL=ThemeElement.d.ts.map