import { LitElement } from "lit";
import { Constructor } from "./Constructor";
/** A symbol through which to access a function used to render a pseudo link. */
export declare const renderPseudoLink: unique symbol;
/** Specifies the possible targets for a link. */
export type LinkTarget = "_self" | "_blank" | "_parent" | "_top" | (string & {});
/** Defines functionality for an interactive element that functions as a link. */
export interface LinkButtonMixin {
    /**
     * The URL to which the link button points.
     * @default ""
     */
    href: string;
    /**
     * The target of the link button.
     * @default ""
     */
    target: LinkTarget;
    /**
     * The relationship between the `target` of the link button and the document.
     * @default ""
     */
    rel: string;
    /**
     * A value indicating whether the `target` of the link button will be downloaded,
     * optionally specifying the new name of the file.
     * @default null
     */
    download: string | null;
    /** Function used to render a pseudo link. */
    [renderPseudoLink](): unknown;
}
/**
 * Determines whether a value is a `LinkButtonMixin`.
 * @param {unknown} value The value to test.
 * @returns {value is LinkButtonMixin} Whether `value` is a `LinkButtonMixin`.
 */
export declare function isLinkButtonMixin(value: unknown): value is LinkButtonMixin;
/**
 * Mixin to augment an element with behavior that supports functioning as a link.
 * @template T The type of the base class.
 * @param {T} base The base class.
 * @param {boolean} [disableClick=false] Whether to disable the default click handler.
 * @returns {Constructor<LinkButtonMixin>} A constructor that implements `LinkButtonMixin`.
 */
export declare function LinkButton<T extends Constructor<LitElement>>(base: T, disableClick?: boolean): Constructor<LinkButtonMixin> & T;
//# sourceMappingURL=LinkButton.d.ts.map