import { CSSResult } from "lit";
import { IconButtonVariant } from "../IconButtonVariant";
/** @private */
type _IconButtonVariantToken = {
    iconColor: CSSResult;
    containerColor?: CSSResult;
    containerElevation?: CSSResult;
    outlineColor?: CSSResult;
    unselectedIconColor: CSSResult;
    unselectedContainerColor?: CSSResult;
    selectedIconColor: CSSResult;
    selectedContainerColor?: CSSResult;
    disabled: {
        containerColor: CSSResult;
        containerElevation?: CSSResult;
        containerOpacity: CSSResult;
        iconColor: CSSResult;
        iconOpacity: CSSResult;
        outlineColor?: CSSResult;
    };
    hover: {
        iconColor: CSSResult;
        stateLayerColor: CSSResult;
        stateLayerOpacity: CSSResult;
        containerElevation?: CSSResult;
        outlineColor?: CSSResult;
        unselectedIconColor: CSSResult;
        unselectedStateLayerColor: CSSResult;
        selectedIconColor: CSSResult;
        selectedStateLayerColor: CSSResult;
    };
    focus: {
        iconColor: CSSResult;
        stateLayerColor: CSSResult;
        stateLayerOpacity: CSSResult;
        containerElevation?: CSSResult;
        outlineColor?: CSSResult;
        unselectedIconColor: CSSResult;
        unselectedStateLayerColor: CSSResult;
        selectedIconColor: CSSResult;
        selectedStateLayerColor: CSSResult;
    };
    pressed: {
        iconColor: CSSResult;
        stateLayerColor: CSSResult;
        stateLayerOpacity: CSSResult;
        containerElevation?: CSSResult;
        outlineColor?: CSSResult;
        unselectedIconColor: CSSResult;
        unselectedStateLayerColor: CSSResult;
        selectedIconColor: CSSResult;
        selectedStateLayerColor: CSSResult;
    };
};
/**
 * Component design tokens that control the appearance variants of `M3eIconButtonElement`.
 * @internal
 */
export declare const IconButtonVariantToken: Record<IconButtonVariant | "elevated", _IconButtonVariantToken>;
export {};
//# sourceMappingURL=IconButtonVariantToken.d.ts.map