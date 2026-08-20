module Sl.Events exposing
    ( onAfterCollapse, onAfterCollapseWith, onAfterExpand, onAfterExpandWith, onAfterHide, onAfterHideWith, onAfterShow, onAfterShowWith, onBlur, onBlurWith, onCancel, onCancelWith, onChange, onChangeWith, onClear, onClearWith, onClose, onCloseWith, onCollapse, onCollapseWith, onCopy, onCopyWith, onError, onErrorWith, onExpand, onExpandWith, onFinish, onFinishWith, onFocus, onFocusWith, onHide, onHideWith, onHover, onHoverWith, onInitialFocus, onInitialFocusWith, onInput, onInputWith, onInvalid, onInvalidWith, onLazyChange, onLazyChangeWith, onLazyLoad, onLazyLoadWith, onLoad, onLoadWith, onMutation, onMutationWith, onRemove, onRemoveWith, onReposition, onRepositionWith, onRequestClose, onRequestCloseWith, onResize, onResizeWith, onSelect, onSelectWith, onSelectionChange, onSelectionChangeWith, onShow, onShowWith, onSlideChange, onSlideChangeWith, onStart, onStartWith, onTabHide, onTabHideWith, onTabShow, onTabShowWith
    , delegate
    )

{-| Events as capabilities: each setter is an open producer admitted only by
elements whose closed `Attrs` row lists the event — `onClick` on a
non-interactive element is a compile error.

`delegate` is the ONE loud escape for bubbling: it forgets an event's
capability so it can be placed on a container and rely on DOM bubbling from an
interactive descendant. Pair it with a real interactive child and a keyboard
path (lint-checked).

@docs onAfterCollapse, onAfterCollapseWith, onAfterExpand, onAfterExpandWith, onAfterHide, onAfterHideWith, onAfterShow, onAfterShowWith, onBlur, onBlurWith, onCancel, onCancelWith, onChange, onChangeWith, onClear, onClearWith, onClose, onCloseWith, onCollapse, onCollapseWith, onCopy, onCopyWith, onError, onErrorWith, onExpand, onExpandWith, onFinish, onFinishWith, onFocus, onFocusWith, onHide, onHideWith, onHover, onHoverWith, onInitialFocus, onInitialFocusWith, onInput, onInputWith, onInvalid, onInvalidWith, onLazyChange, onLazyChangeWith, onLazyLoad, onLazyLoadWith, onLoad, onLoadWith, onMutation, onMutationWith, onRemove, onRemoveWith, onReposition, onRepositionWith, onRequestClose, onRequestCloseWith, onResize, onResizeWith, onSelect, onSelectWith, onSelectionChange, onSelectionChangeWith, onShow, onShowWith, onSlideChange, onSlideChangeWith, onStart, onStartWith, onTabHide, onTabHideWith, onTabShow, onTabShowWith
@docs delegate

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import Json.Decode


{-| The `sl-after-collapse` event.
-}
onAfterCollapse : msg -> Attr { c | onAfterCollapse : Supported } msg
onAfterCollapse msg =
    Ir.on "sl-after-collapse" (Json.Decode.succeed msg)


{-| The `sl-after-collapse` event with a custom payload decoder.
-}
onAfterCollapseWith : Json.Decode.Decoder msg -> Attr { c | onAfterCollapse : Supported } msg
onAfterCollapseWith =
    Ir.on "sl-after-collapse"


{-| The `sl-after-expand` event.
-}
onAfterExpand : msg -> Attr { c | onAfterExpand : Supported } msg
onAfterExpand msg =
    Ir.on "sl-after-expand" (Json.Decode.succeed msg)


{-| The `sl-after-expand` event with a custom payload decoder.
-}
onAfterExpandWith : Json.Decode.Decoder msg -> Attr { c | onAfterExpand : Supported } msg
onAfterExpandWith =
    Ir.on "sl-after-expand"


{-| The `sl-after-hide` event.
-}
onAfterHide : msg -> Attr { c | onAfterHide : Supported } msg
onAfterHide msg =
    Ir.on "sl-after-hide" (Json.Decode.succeed msg)


{-| The `sl-after-hide` event with a custom payload decoder.
-}
onAfterHideWith : Json.Decode.Decoder msg -> Attr { c | onAfterHide : Supported } msg
onAfterHideWith =
    Ir.on "sl-after-hide"


{-| The `sl-after-show` event.
-}
onAfterShow : msg -> Attr { c | onAfterShow : Supported } msg
onAfterShow msg =
    Ir.on "sl-after-show" (Json.Decode.succeed msg)


{-| The `sl-after-show` event with a custom payload decoder.
-}
onAfterShowWith : Json.Decode.Decoder msg -> Attr { c | onAfterShow : Supported } msg
onAfterShowWith =
    Ir.on "sl-after-show"


{-| The `sl-blur` event.
-}
onBlur : msg -> Attr { c | onBlur : Supported } msg
onBlur msg =
    Ir.on "sl-blur" (Json.Decode.succeed msg)


{-| The `sl-blur` event with a custom payload decoder.
-}
onBlurWith : Json.Decode.Decoder msg -> Attr { c | onBlur : Supported } msg
onBlurWith =
    Ir.on "sl-blur"


{-| The `sl-cancel` event.
-}
onCancel : msg -> Attr { c | onCancel : Supported } msg
onCancel msg =
    Ir.on "sl-cancel" (Json.Decode.succeed msg)


{-| The `sl-cancel` event with a custom payload decoder.
-}
onCancelWith : Json.Decode.Decoder msg -> Attr { c | onCancel : Supported } msg
onCancelWith =
    Ir.on "sl-cancel"


{-| The `sl-change` event.
-}
onChange : msg -> Attr { c | onChange : Supported } msg
onChange msg =
    Ir.on "sl-change" (Json.Decode.succeed msg)


{-| The `sl-change` event with a custom payload decoder.
-}
onChangeWith : Json.Decode.Decoder msg -> Attr { c | onChange : Supported } msg
onChangeWith =
    Ir.on "sl-change"


{-| The `sl-clear` event.
-}
onClear : msg -> Attr { c | onClear : Supported } msg
onClear msg =
    Ir.on "sl-clear" (Json.Decode.succeed msg)


{-| The `sl-clear` event with a custom payload decoder.
-}
onClearWith : Json.Decode.Decoder msg -> Attr { c | onClear : Supported } msg
onClearWith =
    Ir.on "sl-clear"


{-| The `sl-close` event.
-}
onClose : msg -> Attr { c | onClose : Supported } msg
onClose msg =
    Ir.on "sl-close" (Json.Decode.succeed msg)


{-| The `sl-close` event with a custom payload decoder.
-}
onCloseWith : Json.Decode.Decoder msg -> Attr { c | onClose : Supported } msg
onCloseWith =
    Ir.on "sl-close"


{-| The `sl-collapse` event.
-}
onCollapse : msg -> Attr { c | onCollapse : Supported } msg
onCollapse msg =
    Ir.on "sl-collapse" (Json.Decode.succeed msg)


{-| The `sl-collapse` event with a custom payload decoder.
-}
onCollapseWith : Json.Decode.Decoder msg -> Attr { c | onCollapse : Supported } msg
onCollapseWith =
    Ir.on "sl-collapse"


{-| The `sl-copy` event.
-}
onCopy : msg -> Attr { c | onCopy : Supported } msg
onCopy msg =
    Ir.on "sl-copy" (Json.Decode.succeed msg)


{-| The `sl-copy` event with a custom payload decoder.
-}
onCopyWith : Json.Decode.Decoder msg -> Attr { c | onCopy : Supported } msg
onCopyWith =
    Ir.on "sl-copy"


{-| The `sl-error` event.
-}
onError : msg -> Attr { c | onError : Supported } msg
onError msg =
    Ir.on "sl-error" (Json.Decode.succeed msg)


{-| The `sl-error` event with a custom payload decoder.
-}
onErrorWith : Json.Decode.Decoder msg -> Attr { c | onError : Supported } msg
onErrorWith =
    Ir.on "sl-error"


{-| The `sl-expand` event.
-}
onExpand : msg -> Attr { c | onExpand : Supported } msg
onExpand msg =
    Ir.on "sl-expand" (Json.Decode.succeed msg)


{-| The `sl-expand` event with a custom payload decoder.
-}
onExpandWith : Json.Decode.Decoder msg -> Attr { c | onExpand : Supported } msg
onExpandWith =
    Ir.on "sl-expand"


{-| The `sl-finish` event.
-}
onFinish : msg -> Attr { c | onFinish : Supported } msg
onFinish msg =
    Ir.on "sl-finish" (Json.Decode.succeed msg)


{-| The `sl-finish` event with a custom payload decoder.
-}
onFinishWith : Json.Decode.Decoder msg -> Attr { c | onFinish : Supported } msg
onFinishWith =
    Ir.on "sl-finish"


{-| The `sl-focus` event.
-}
onFocus : msg -> Attr { c | onFocus : Supported } msg
onFocus msg =
    Ir.on "sl-focus" (Json.Decode.succeed msg)


{-| The `sl-focus` event with a custom payload decoder.
-}
onFocusWith : Json.Decode.Decoder msg -> Attr { c | onFocus : Supported } msg
onFocusWith =
    Ir.on "sl-focus"


{-| The `sl-hide` event.
-}
onHide : msg -> Attr { c | onHide : Supported } msg
onHide msg =
    Ir.on "sl-hide" (Json.Decode.succeed msg)


{-| The `sl-hide` event with a custom payload decoder.
-}
onHideWith : Json.Decode.Decoder msg -> Attr { c | onHide : Supported } msg
onHideWith =
    Ir.on "sl-hide"


{-| The `sl-hover` event.
-}
onHover : msg -> Attr { c | onHover : Supported } msg
onHover msg =
    Ir.on "sl-hover" (Json.Decode.succeed msg)


{-| The `sl-hover` event with a custom payload decoder.
-}
onHoverWith : Json.Decode.Decoder msg -> Attr { c | onHover : Supported } msg
onHoverWith =
    Ir.on "sl-hover"


{-| The `sl-initial-focus` event.
-}
onInitialFocus : msg -> Attr { c | onInitialFocus : Supported } msg
onInitialFocus msg =
    Ir.on "sl-initial-focus" (Json.Decode.succeed msg)


{-| The `sl-initial-focus` event with a custom payload decoder.
-}
onInitialFocusWith : Json.Decode.Decoder msg -> Attr { c | onInitialFocus : Supported } msg
onInitialFocusWith =
    Ir.on "sl-initial-focus"


{-| The `sl-input` event.
-}
onInput : msg -> Attr { c | onInput : Supported } msg
onInput msg =
    Ir.on "sl-input" (Json.Decode.succeed msg)


{-| The `sl-input` event with a custom payload decoder.
-}
onInputWith : Json.Decode.Decoder msg -> Attr { c | onInput : Supported } msg
onInputWith =
    Ir.on "sl-input"


{-| The `sl-invalid` event.
-}
onInvalid : msg -> Attr { c | onInvalid : Supported } msg
onInvalid msg =
    Ir.on "sl-invalid" (Json.Decode.succeed msg)


{-| The `sl-invalid` event with a custom payload decoder.
-}
onInvalidWith : Json.Decode.Decoder msg -> Attr { c | onInvalid : Supported } msg
onInvalidWith =
    Ir.on "sl-invalid"


{-| The `sl-lazy-change` event.
-}
onLazyChange : msg -> Attr { c | onLazyChange : Supported } msg
onLazyChange msg =
    Ir.on "sl-lazy-change" (Json.Decode.succeed msg)


{-| The `sl-lazy-change` event with a custom payload decoder.
-}
onLazyChangeWith : Json.Decode.Decoder msg -> Attr { c | onLazyChange : Supported } msg
onLazyChangeWith =
    Ir.on "sl-lazy-change"


{-| The `sl-lazy-load` event.
-}
onLazyLoad : msg -> Attr { c | onLazyLoad : Supported } msg
onLazyLoad msg =
    Ir.on "sl-lazy-load" (Json.Decode.succeed msg)


{-| The `sl-lazy-load` event with a custom payload decoder.
-}
onLazyLoadWith : Json.Decode.Decoder msg -> Attr { c | onLazyLoad : Supported } msg
onLazyLoadWith =
    Ir.on "sl-lazy-load"


{-| The `sl-load` event.
-}
onLoad : msg -> Attr { c | onLoad : Supported } msg
onLoad msg =
    Ir.on "sl-load" (Json.Decode.succeed msg)


{-| The `sl-load` event with a custom payload decoder.
-}
onLoadWith : Json.Decode.Decoder msg -> Attr { c | onLoad : Supported } msg
onLoadWith =
    Ir.on "sl-load"


{-| The `sl-mutation` event.
-}
onMutation : msg -> Attr { c | onMutation : Supported } msg
onMutation msg =
    Ir.on "sl-mutation" (Json.Decode.succeed msg)


{-| The `sl-mutation` event with a custom payload decoder.
-}
onMutationWith : Json.Decode.Decoder msg -> Attr { c | onMutation : Supported } msg
onMutationWith =
    Ir.on "sl-mutation"


{-| The `sl-remove` event.
-}
onRemove : msg -> Attr { c | onRemove : Supported } msg
onRemove msg =
    Ir.on "sl-remove" (Json.Decode.succeed msg)


{-| The `sl-remove` event with a custom payload decoder.
-}
onRemoveWith : Json.Decode.Decoder msg -> Attr { c | onRemove : Supported } msg
onRemoveWith =
    Ir.on "sl-remove"


{-| The `sl-reposition` event.
-}
onReposition : msg -> Attr { c | onReposition : Supported } msg
onReposition msg =
    Ir.on "sl-reposition" (Json.Decode.succeed msg)


{-| The `sl-reposition` event with a custom payload decoder.
-}
onRepositionWith : Json.Decode.Decoder msg -> Attr { c | onReposition : Supported } msg
onRepositionWith =
    Ir.on "sl-reposition"


{-| The `sl-request-close` event.
-}
onRequestClose : msg -> Attr { c | onRequestClose : Supported } msg
onRequestClose msg =
    Ir.on "sl-request-close" (Json.Decode.succeed msg)


{-| The `sl-request-close` event with a custom payload decoder.
-}
onRequestCloseWith : Json.Decode.Decoder msg -> Attr { c | onRequestClose : Supported } msg
onRequestCloseWith =
    Ir.on "sl-request-close"


{-| The `sl-resize` event.
-}
onResize : msg -> Attr { c | onResize : Supported } msg
onResize msg =
    Ir.on "sl-resize" (Json.Decode.succeed msg)


{-| The `sl-resize` event with a custom payload decoder.
-}
onResizeWith : Json.Decode.Decoder msg -> Attr { c | onResize : Supported } msg
onResizeWith =
    Ir.on "sl-resize"


{-| The `sl-select` event.
-}
onSelect : msg -> Attr { c | onSelect : Supported } msg
onSelect msg =
    Ir.on "sl-select" (Json.Decode.succeed msg)


{-| The `sl-select` event with a custom payload decoder.
-}
onSelectWith : Json.Decode.Decoder msg -> Attr { c | onSelect : Supported } msg
onSelectWith =
    Ir.on "sl-select"


{-| The `sl-selection-change` event.
-}
onSelectionChange : msg -> Attr { c | onSelectionChange : Supported } msg
onSelectionChange msg =
    Ir.on "sl-selection-change" (Json.Decode.succeed msg)


{-| The `sl-selection-change` event with a custom payload decoder.
-}
onSelectionChangeWith : Json.Decode.Decoder msg -> Attr { c | onSelectionChange : Supported } msg
onSelectionChangeWith =
    Ir.on "sl-selection-change"


{-| The `sl-show` event.
-}
onShow : msg -> Attr { c | onShow : Supported } msg
onShow msg =
    Ir.on "sl-show" (Json.Decode.succeed msg)


{-| The `sl-show` event with a custom payload decoder.
-}
onShowWith : Json.Decode.Decoder msg -> Attr { c | onShow : Supported } msg
onShowWith =
    Ir.on "sl-show"


{-| The `sl-slide-change` event.
-}
onSlideChange : msg -> Attr { c | onSlideChange : Supported } msg
onSlideChange msg =
    Ir.on "sl-slide-change" (Json.Decode.succeed msg)


{-| The `sl-slide-change` event with a custom payload decoder.
-}
onSlideChangeWith : Json.Decode.Decoder msg -> Attr { c | onSlideChange : Supported } msg
onSlideChangeWith =
    Ir.on "sl-slide-change"


{-| The `sl-start` event.
-}
onStart : msg -> Attr { c | onStart : Supported } msg
onStart msg =
    Ir.on "sl-start" (Json.Decode.succeed msg)


{-| The `sl-start` event with a custom payload decoder.
-}
onStartWith : Json.Decode.Decoder msg -> Attr { c | onStart : Supported } msg
onStartWith =
    Ir.on "sl-start"


{-| The `sl-tab-hide` event.
-}
onTabHide : msg -> Attr { c | onTabHide : Supported } msg
onTabHide msg =
    Ir.on "sl-tab-hide" (Json.Decode.succeed msg)


{-| The `sl-tab-hide` event with a custom payload decoder.
-}
onTabHideWith : Json.Decode.Decoder msg -> Attr { c | onTabHide : Supported } msg
onTabHideWith =
    Ir.on "sl-tab-hide"


{-| The `sl-tab-show` event.
-}
onTabShow : msg -> Attr { c | onTabShow : Supported } msg
onTabShow msg =
    Ir.on "sl-tab-show" (Json.Decode.succeed msg)


{-| The `sl-tab-show` event with a custom payload decoder.
-}
onTabShowWith : Json.Decode.Decoder msg -> Attr { c | onTabShow : Supported } msg
onTabShowWith =
    Ir.on "sl-tab-show"


{-| Forget an event's capability row (the bubbling escape).
-}
delegate : Attr capability msg -> Attr anyCapability msg
delegate attr =
    Ir.recast attr
