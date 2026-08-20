import { CSSResult } from "lit";
import { CardVariant } from "../CardVariant";
/** @private */
type _CardVariantToken = {
    textColor: CSSResult;
    containerColor: CSSResult;
    containerElevation: CSSResult;
    outlineColor?: CSSResult;
    outlineThickness?: CSSResult;
    disabled: {
        textColor: CSSResult;
        textOpacity: CSSResult;
        imageOpacity: CSSResult;
        containerColor?: CSSResult;
        containerOpacity?: CSSResult;
        containerElevation: CSSResult;
        containerElevationColor: CSSResult;
        containerElevationOpacity: CSSResult;
        outlineColor?: CSSResult;
        outlineOpacity?: CSSResult;
    };
    hover: {
        textColor: CSSResult;
        stateLayerColor: CSSResult;
        stateLayerOpacity: CSSResult;
        containerElevation?: CSSResult;
        outlineColor?: CSSResult;
    };
    focus: {
        textColor: CSSResult;
        stateLayerColor: CSSResult;
        stateLayerOpacity: CSSResult;
        containerElevation?: CSSResult;
        outlineColor?: CSSResult;
    };
    pressed: {
        textColor: CSSResult;
        stateLayerColor: CSSResult;
        stateLayerOpacity: CSSResult;
        containerElevation?: CSSResult;
        outlineColor?: CSSResult;
    };
};
/**
 * Component design tokens that control the appearance variants of `M3eCardElement`.
 * @internal
 */
export declare const CardVariantToken: Record<CardVariant, _CardVariantToken>;
export {};
//# sourceMappingURL=CardVariantToken.d.ts.map