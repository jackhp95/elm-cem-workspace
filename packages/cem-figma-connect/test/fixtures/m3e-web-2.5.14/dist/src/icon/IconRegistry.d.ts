import { SVGTemplateResult } from "lit";
import { IconVariant } from "./IconVariant";
/** Encapsulates information used to construct an SVG. */
export type SvgIconInfo = {
    /** The viewbox of the SVG. */
    viewBox: string;
    /** The path of the SVG. */
    path: string;
};
/** Represents the fill-axis SVG data for a single icon. */
export type SvgIconFillSet = {
    /** The unfilled (FILL=0) SVG representation (or path assuming viewBox="0 -960 960 960") of the icon. */
    outlined: SvgIconInfo | string;
    /** The filled (FILL=1) SVG representation (or path assuming viewBox="0 -960 960 960") of the icon. */
    filled: SvgIconInfo | string;
};
/**
 * Service to register and display icons used by the `m3e-icon` component.
 * @internal
 */
export declare class IconRegistry {
    #private;
    /**
     * Adds an icon to the registry for the given variant and weight.
     * @param {string} name The name of the icon.
     * @param {IconVariant} variant The variant of the icon.
     * @param {SvgIconFillSet} fillSet The SVG data for both fill states (outlined and filled) of the icon.
     */
    static addIcon(name: string, variant: IconVariant, fillSet: SvgIconFillSet): void;
    /**
     * Determines whether an icon is registered for the given variant.
     * @param {string} name The name of the icon.
     * @param {IconVariant} variant The variant of the icon.
     * @returns {boolean} Whether `icon` is registered for the given `variant`.
     */
    static isIconRegistered(name: string, variant: IconVariant): boolean;
    /**
     * Renders an icon from the registry.
     * @param {string} name The name of the icon.
     * @param {IconVariant} variant The variant of the icon.
     * @param {boolean} filled Whether to render a filled variant of the icon.
     * @returns {SVGTemplateResult | undefined} A `SVGTemplateResult` used to render the icon.
     */
    static renderIcon(name: string, variant: IconVariant, filled: boolean): SVGTemplateResult | undefined;
    /**
     * Begins observing registration for the specified icon.
     * @param {string} name The name of the icon to observe.
     * @param {IconVariant} variant The variant of the icon to observe.
     * @param {() => void} callback Callback invoked when the specified icon is registered for the given variant.
     * @returns {() => void} Function used to stop observing.
     */
    static observe(name: string, variant: IconVariant, callback: () => void): () => void;
}
//# sourceMappingURL=IconRegistry.d.ts.map