import { CSSResult } from "lit";
import { AppBarSize } from "../AppBarSize";
/** @private */
type _AppBarSizeToken = {
    containerHeight: CSSResult;
    containerHeightWithSubtitle?: CSSResult;
    paddingTop?: CSSResult;
    paddingBottom?: CSSResult;
    titleTextFontSize: CSSResult;
    titleTextFontWeight: CSSResult;
    titleTextLineHeight: CSSResult;
    titleTextTracking: CSSResult;
    subtitleTextFontSize: CSSResult;
    subtitleTextFontWeight: CSSResult;
    subtitleTextLineHeight: CSSResult;
    subtitleTextTracking: CSSResult;
    titleMaxLines?: CSSResult;
    subtitleMaxLines?: CSSResult;
    headingPaddingLeft: CSSResult;
    headingPaddingRight: CSSResult;
};
/**
 * Component design tokens that control the `M3eAppBarElement` for all size variants.
 * @internal
 */
export declare const AppBarSizeToken: Record<AppBarSize, _AppBarSizeToken>;
export {};
//# sourceMappingURL=AppBarSizeToken.d.ts.map