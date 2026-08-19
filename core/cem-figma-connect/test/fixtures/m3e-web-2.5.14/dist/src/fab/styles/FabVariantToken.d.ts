import { CSSResult } from "lit";
import { FabVariant } from "../FabVariant";
/** @private */
type _FabVariantToken = {
    labelTextColor: CSSResult;
    iconColor: CSSResult;
    containerColor: CSSResult;
    containerElevation: CSSResult;
    loweredContainerElevation: CSSResult;
    loweredContainerColor?: CSSResult;
    disabled: {
        containerColor: CSSResult;
        containerOpacity: CSSResult;
        iconColor: CSSResult;
        iconOpacity: CSSResult;
        labelTextColor: CSSResult;
        labelTextOpacity: CSSResult;
        containerElevation: CSSResult;
        loweredContainerElevation: CSSResult;
    };
    hover: {
        iconColor: CSSResult;
        labelTextColor: CSSResult;
        stateLayerColor: CSSResult;
        stateLayerOpacity: CSSResult;
        containerElevation: CSSResult;
        loweredContainerElevation: CSSResult;
    };
    focus: {
        iconColor: CSSResult;
        labelTextColor: CSSResult;
        stateLayerColor: CSSResult;
        stateLayerOpacity: CSSResult;
        containerElevation: CSSResult;
        loweredContainerElevation: CSSResult;
    };
    pressed: {
        iconColor: CSSResult;
        labelTextColor: CSSResult;
        stateLayerColor: CSSResult;
        stateLayerOpacity: CSSResult;
        containerElevation: CSSResult;
        loweredContainerElevation: CSSResult;
    };
};
/**
 * Component design tokens that control the appearance variants of `M3FabElement`.
 * @internal
 */
export declare const FabVariantToken: Record<FabVariant, _FabVariantToken>;
export {};
//# sourceMappingURL=FabVariantToken.d.ts.map