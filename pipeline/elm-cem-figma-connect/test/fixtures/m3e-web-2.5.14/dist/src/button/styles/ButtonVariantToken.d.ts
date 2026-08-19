import { CSSResult } from "lit";
import { ButtonVariant } from "../ButtonVariant";
/** @private */
type _ButtonVariantToken = {
    labelTextColor: CSSResult;
    iconColor: CSSResult;
    containerColor?: CSSResult;
    containerElevation?: CSSResult;
    outlineColor?: CSSResult;
    unselectedLabelTextColor: CSSResult;
    unselectedIconColor: CSSResult;
    unselectedContainerColor?: CSSResult;
    selectedLabelTextColor: CSSResult;
    selectedIconColor: CSSResult;
    selectedContainerColor?: CSSResult;
    disabled: {
        containerColor: CSSResult;
        containerOpacity: CSSResult;
        iconColor: CSSResult;
        iconOpacity: CSSResult;
        labelTextColor: CSSResult;
        labelTextOpacity: CSSResult;
        containerElevation?: CSSResult;
        outlineColor?: CSSResult;
    };
    hover: {
        iconColor: CSSResult;
        labelTextColor: CSSResult;
        stateLayerColor: CSSResult;
        stateLayerOpacity: CSSResult;
        containerElevation?: CSSResult;
        outlineColor?: CSSResult;
        unselectedLabelTextColor: CSSResult;
        unselectedIconColor: CSSResult;
        unselectedStateLayerColor: CSSResult;
        selectedLabelTextColor: CSSResult;
        selectedIconColor: CSSResult;
        selectedStateLayerColor: CSSResult;
    };
    focus: {
        iconColor: CSSResult;
        labelTextColor: CSSResult;
        stateLayerColor: CSSResult;
        stateLayerOpacity: CSSResult;
        containerElevation?: CSSResult;
        outlineColor?: CSSResult;
        unselectedLabelTextColor: CSSResult;
        unselectedIconColor: CSSResult;
        unselectedStateLayerColor: CSSResult;
        selectedLabelTextColor: CSSResult;
        selectedIconColor: CSSResult;
        selectedStateLayerColor: CSSResult;
    };
    pressed: {
        iconColor: CSSResult;
        labelTextColor: CSSResult;
        stateLayerColor: CSSResult;
        stateLayerOpacity: CSSResult;
        containerElevation?: CSSResult;
        outlineColor?: CSSResult;
        unselectedLabelTextColor: CSSResult;
        unselectedIconColor: CSSResult;
        unselectedStateLayerColor: CSSResult;
        selectedLabelTextColor: CSSResult;
        selectedIconColor: CSSResult;
        selectedStateLayerColor: CSSResult;
    };
};
/**
 * Component design tokens that control the appearance variants of `M3eButtonElement`.
 * @internal
 */
export declare const ButtonVariantToken: Record<ButtonVariant, _ButtonVariantToken>;
export {};
//# sourceMappingURL=ButtonVariantToken.d.ts.map