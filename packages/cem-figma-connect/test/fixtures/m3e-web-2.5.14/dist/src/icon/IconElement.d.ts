import { CSSResultGroup, LitElement, PropertyValues } from "lit";
import { IconVariant } from "./IconVariant";
import { IconGrade } from "./IconGrade";
import { IconWeight } from "./IconWeight";
declare const M3eIconElement_base: import("../core/shared/mixins/Constructor").Constructor & typeof LitElement;
/**
 * A small symbol used to easily identify an action or category.
 *
 * @description
 * The `m3e-icon` component makes it easier to use Material Symbols in your application. Material Symbols are Google's newest icons supporting
 * a range of design variants. For more information, see:
 * - {@link https://developers.google.com/fonts/docs/material_symbols|Material Symbol Guide}
 * - {@link https://fonts.google.com/icons|Material Symbol Library}
 *
 * The Material Symbols font is the easiest way to incorporate Material Symbols into your application. Using the
 * {@link https://developers.google.com/fonts/docs/css2#forming_api_urls|Fonts CSS API}, you can use variable fonts to optimize icon
 * usage within your application. See {@link https://caniuse.com/variable-fonts|Can I Use's Variable Fonts} to determine whether
 * your user's browser support variable fonts.
 *
 * @example
 * The following example illustrates showing the `home` icon. The `name` attribute specifies the icon to present.
 * ```html
 * <m3e-icon name="home"></m3e-icon>
 * ```
 * @example
 * The next example illustrates a link used to download a variable font for outlined icons with fill support.
 * ```html
 * <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0..1,0" rel="stylesheet"/>
 * ```
 *
 * @tag m3e-icon
 *
 * @attr filled - Whether the icon is filled.
 * @attr grade - The grade of the icon.
 * @attr optical-size - A value from 20 to 48 indicating the optical size of the icon.
 * @attr name - The name of the icon.
 * @attr variant - The appearance variant of the icon.
 * @attr weight - A value from 100 to 700 indicating the weight of the icon.
 */
export declare class M3eIconElement extends M3eIconElement_base {
    #private;
    /** The styles of the element. */
    static styles: CSSResultGroup;
    /** @private */ private readonly _icon?;
    /** The name of the icon. */
    name: string;
    /**
     * The appearance variant of the icon.
     * @default "outlined"
     */
    variant: IconVariant;
    /**
     * Whether the icon is filled.
     * @default false
     */
    filled: boolean;
    /**
     * The grade of the icon.
     * @default "medium"
     */
    grade: IconGrade;
    /**
     * A value from 100 to 700 indicating the weight of the icon.
     * @default 400
     */
    weight: IconWeight;
    /**
     * A value from 20 to 48 indicating the optical size of the icon.
     * @default 24
     */
    opticalSize: number;
    /** @inheritdoc */
    connectedCallback(): void;
    /** @inheritdoc */
    disconnectedCallback(): void;
    /** @inheritdoc */
    protected willUpdate(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected updated(_changedProperties: PropertyValues<this>): void;
    /** @inheritdoc */
    protected render(): unknown;
}
declare global {
    interface HTMLElementTagNameMap {
        "m3e-icon": M3eIconElement;
    }
}
export {};
//# sourceMappingURL=IconElement.d.ts.map