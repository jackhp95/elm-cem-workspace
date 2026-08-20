module Sl.Review.Facts exposing (facts, globalAttributes, reExposedValueTokens)

{-| GENERATED review facts for the elm-review-cem rules (phantom pipeline).

@docs facts, globalAttributes, reExposedValueTokens

-}

import Cem.Facts exposing (Facet(..), Fact)


{-| Per-component facts.
-}
facts : List Fact
facts =
    [ { component = "alert"
      , module_ = "Sl.Component.Alert"
      , enums = [ ( "countdown", [ "ltr", "rtl" ] ), ( "variant", [ "danger", "neutral", "primary", "success", "warning" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "closable", "closable" ), ( "countdown", "countdown" ), ( "duration", "duration" ), ( "open", "open" ), ( "variant", "variant" ), ( "onShow", "onShow" ), ( "onAfterShow", "onAfterShow" ), ( "onHide", "onHide" ), ( "onAfterHide", "onAfterHide" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "animatedImage"
      , module_ = "Sl.Component.AnimatedImage"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "alt", "alt" ), ( "play", "play" ), ( "src", "src" ), ( "onLoad", "onLoad" ), ( "onError", "onError" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "animation"
      , module_ = "Sl.Component.Animation"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "delay", "delay" ), ( "direction", "direction" ), ( "duration", "duration" ), ( "easing", "easing" ), ( "endDelay", "endDelay" ), ( "fill", "fill" ), ( "iterationStart", "iterationStart" ), ( "iterations", "iterations" ), ( "name", "name" ), ( "play", "play" ), ( "playbackRate", "playbackRate" ), ( "onCancel", "onCancel" ), ( "onFinish", "onFinish" ), ( "onStart", "onStart" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "avatar"
      , module_ = "Sl.Component.Avatar"
      , enums = [ ( "loading", [ "eager", "lazy" ] ), ( "shape", [ "circle", "rounded", "square" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "image", "image" ), ( "initials", "initials" ), ( "label", "label" ), ( "loading", "loading" ), ( "shape", "shape" ), ( "onError", "onError" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "badge"
      , module_ = "Sl.Component.Badge"
      , enums = [ ( "variant", [ "danger", "neutral", "primary", "success", "warning" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "pill", "pill" ), ( "pulse", "pulse" ), ( "variant", "variant" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "breadcrumb"
      , module_ = "Sl.Component.Breadcrumb"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "label", "label" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "breadcrumbItem"
      , module_ = "Sl.Component.BreadcrumbItem"
      , enums = [ ( "target", [ "blank_", "parent_", "self_", "top_" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "href", "href" ), ( "rel", "rel" ), ( "target", "target" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "button"
      , module_ = "Sl.Component.Button"
      , enums = [ ( "formenctype", [ "applicationXWwwFormUrlencoded", "multipartFormData", "textPlain" ] ), ( "formmethod", [ "get", "post" ] ), ( "formtarget", [ "blank_", "parent_", "self_", "top_" ] ), ( "size", [ "large", "medium", "small" ] ), ( "target", [ "blank_", "parent_", "self_", "top_" ] ), ( "type_", [ "button", "reset", "submit" ] ), ( "variant", [ "danger", "default", "neutral", "primary", "success", "text", "warning" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "caret", "caret" ), ( "circle", "circle" ), ( "disabled", "disabled" ), ( "download", "download" ), ( "form", "form" ), ( "formenctype", "formenctype" ), ( "formmethod", "formmethod" ), ( "formnovalidate", "formnovalidate" ), ( "formtarget", "formtarget" ), ( "href", "href" ), ( "loading", "loading" ), ( "name", "name" ), ( "outline", "outline" ), ( "pill", "pill" ), ( "rel", "rel" ), ( "size", "size" ), ( "target", "target" ), ( "title", "title" ), ( "type_", "type_" ), ( "value", "value" ), ( "variant", "variant" ), ( "defaultValue", "defaultValue" ), ( "onBlur", "onBlur" ), ( "onFocus", "onFocus" ), ( "onInvalid", "onInvalid" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "buttonGroup"
      , module_ = "Sl.Component.ButtonGroup"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "label", "label" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "card"
      , module_ = "Sl.Component.Card"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "carousel"
      , module_ = "Sl.Component.Carousel"
      , enums = [ ( "orientation", [ "horizontal", "vertical" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "autoplay", "autoplay" ), ( "autoplayInterval", "autoplayInterval" ), ( "loop", "loop" ), ( "mouseDragging", "mouseDragging" ), ( "navigation", "navigation" ), ( "orientation", "orientation" ), ( "pagination", "pagination" ), ( "slidesPerMove", "slidesPerMove" ), ( "slidesPerPage", "slidesPerPage" ), ( "onSlideChange", "onSlideChange" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "carouselItem"
      , module_ = "Sl.Component.CarouselItem"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "checkbox"
      , module_ = "Sl.Component.Checkbox"
      , enums = [ ( "size", [ "large", "medium", "small" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "checked", "checked" ), ( "disabled", "disabled" ), ( "form", "form" ), ( "helpText", "helpText" ), ( "indeterminate", "indeterminate" ), ( "name", "name" ), ( "required", "required" ), ( "size", "size" ), ( "title", "title" ), ( "value", "value" ), ( "defaultChecked", "defaultChecked" ), ( "defaultValue", "defaultValue" ), ( "onBlur", "onBlur" ), ( "onChange", "onChange" ), ( "onFocus", "onFocus" ), ( "onInput", "onInput" ), ( "onInvalid", "onInvalid" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "colorPicker"
      , module_ = "Sl.Component.ColorPicker"
      , enums = [ ( "format", [ "hex", "hsl", "hsv", "rgb" ] ), ( "size", [ "large", "medium", "small" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "form", "form" ), ( "format", "format" ), ( "hoist", "hoist" ), ( "inline", "inline" ), ( "label", "label" ), ( "name", "name" ), ( "noFormatToggle", "noFormatToggle" ), ( "opacity", "opacity" ), ( "required", "required" ), ( "size", "size" ), ( "swatches", "swatches" ), ( "uppercase", "uppercase" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ), ( "onBlur", "onBlur" ), ( "onChange", "onChange" ), ( "onFocus", "onFocus" ), ( "onInput", "onInput" ), ( "onInvalid", "onInvalid" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "copyButton"
      , module_ = "Sl.Component.CopyButton"
      , enums = [ ( "tooltipPlacement", [ "bottom", "left", "right", "top" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "copyLabel", "copyLabel" ), ( "disabled", "disabled" ), ( "errorLabel", "errorLabel" ), ( "feedbackDuration", "feedbackDuration" ), ( "from", "from" ), ( "hoist", "hoist" ), ( "successLabel", "successLabel" ), ( "tooltipPlacement", "tooltipPlacement" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ), ( "onCopy", "onCopy" ), ( "onError", "onError" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "details"
      , module_ = "Sl.Component.Details"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "open", "open" ), ( "summary", "summary" ), ( "onShow", "onShow" ), ( "onAfterShow", "onAfterShow" ), ( "onHide", "onHide" ), ( "onAfterHide", "onAfterHide" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "dialog"
      , module_ = "Sl.Component.Dialog"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "label", "label" ), ( "noHeader", "noHeader" ), ( "open", "open" ), ( "onShow", "onShow" ), ( "onAfterShow", "onAfterShow" ), ( "onHide", "onHide" ), ( "onAfterHide", "onAfterHide" ), ( "onInitialFocus", "onInitialFocus" ), ( "onRequestClose", "onRequestClose" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "divider"
      , module_ = "Sl.Component.Divider"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "vertical", "vertical" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "drawer"
      , module_ = "Sl.Component.Drawer"
      , enums = [ ( "placement", [ "bottom", "end", "start", "top" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "contained", "contained" ), ( "label", "label" ), ( "noHeader", "noHeader" ), ( "open", "open" ), ( "placement", "placement" ), ( "onShow", "onShow" ), ( "onAfterShow", "onAfterShow" ), ( "onHide", "onHide" ), ( "onAfterHide", "onAfterHide" ), ( "onInitialFocus", "onInitialFocus" ), ( "onRequestClose", "onRequestClose" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "dropdown"
      , module_ = "Sl.Component.Dropdown"
      , enums = [ ( "placement", [ "bottom", "bottomEnd", "bottomStart", "left", "leftEnd", "leftStart", "right", "rightEnd", "rightStart", "top", "topEnd", "topStart" ] ), ( "sync", [ "both", "height", "width" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "distance", "distance" ), ( "hoist", "hoist" ), ( "open", "open" ), ( "placement", "placement" ), ( "skidding", "skidding" ), ( "stayOpenOnSelect", "stayOpenOnSelect" ), ( "sync", "sync" ), ( "onShow", "onShow" ), ( "onAfterShow", "onAfterShow" ), ( "onHide", "onHide" ), ( "onAfterHide", "onAfterHide" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "formatBytes"
      , module_ = "Sl.Component.FormatBytes"
      , enums = [ ( "display", [ "long", "narrow", "short" ] ), ( "unit", [ "bit", "byte" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "display", "display" ), ( "unit", "unit" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "formatDate"
      , module_ = "Sl.Component.FormatDate"
      , enums = [ ( "day", [ "value2Digit", "numeric" ] ), ( "era", [ "long", "narrow", "short" ] ), ( "hour", [ "value2Digit", "numeric" ] ), ( "hourFormat", [ "value12", "value24", "auto" ] ), ( "minute", [ "value2Digit", "numeric" ] ), ( "month", [ "value2Digit", "long", "narrow", "numeric", "short" ] ), ( "second", [ "value2Digit", "numeric" ] ), ( "timeZoneName", [ "long", "short" ] ), ( "weekday", [ "long", "narrow", "short" ] ), ( "year", [ "value2Digit", "numeric" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "date", "date" ), ( "day", "day" ), ( "era", "era" ), ( "hour", "hour" ), ( "hourFormat", "hourFormat" ), ( "minute", "minute" ), ( "month", "month" ), ( "second", "second" ), ( "timeZone", "timeZone" ), ( "timeZoneName", "timeZoneName" ), ( "weekday", "weekday" ), ( "year", "year" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "formatNumber"
      , module_ = "Sl.Component.FormatNumber"
      , enums = [ ( "currencyDisplay", [ "code", "name", "narrowsymbol", "symbol" ] ), ( "type_", [ "currency", "decimal", "percent" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "currency", "currency" ), ( "currencyDisplay", "currencyDisplay" ), ( "maximumFractionDigits", "maximumFractionDigits" ), ( "maximumSignificantDigits", "maximumSignificantDigits" ), ( "minimumFractionDigits", "minimumFractionDigits" ), ( "minimumIntegerDigits", "minimumIntegerDigits" ), ( "minimumSignificantDigits", "minimumSignificantDigits" ), ( "noGrouping", "noGrouping" ), ( "type_", "type_" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "icon"
      , module_ = "Sl.Component.Icon"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "label", "label" ), ( "library", "library" ), ( "name", "name" ), ( "src", "src" ), ( "onLoad", "onLoad" ), ( "onError", "onError" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "iconButton"
      , module_ = "Sl.Component.IconButton"
      , enums = [ ( "target", [ "blank_", "parent_", "self_", "top_" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "download", "download" ), ( "href", "href" ), ( "label", "label" ), ( "library", "library" ), ( "name", "name" ), ( "src", "src" ), ( "target", "target" ), ( "onBlur", "onBlur" ), ( "onFocus", "onFocus" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "imageComparer"
      , module_ = "Sl.Component.ImageComparer"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "position", "position" ), ( "onChange", "onChange" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "include"
      , module_ = "Sl.Component.Include"
      , enums = [ ( "mode", [ "cors", "noCors", "sameOrigin" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "allowScripts", "allowScripts" ), ( "mode", "mode" ), ( "src", "src" ), ( "onLoad", "onLoad" ), ( "onError", "onError" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "input"
      , module_ = "Sl.Component.Input"
      , enums = [ ( "autocapitalize", [ "characters", "none", "off", "on", "sentences", "words" ] ), ( "autocorrect", [ "off", "on" ] ), ( "enterkeyhint", [ "done", "enter", "go", "next", "previous", "search", "send" ] ), ( "inputmode", [ "decimal", "email", "none", "numeric", "search", "tel", "text", "url" ] ), ( "size", [ "large", "medium", "small" ] ), ( "type_", [ "date", "datetimeLocal", "email", "number", "password", "search", "tel", "text", "time", "url" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "autocapitalize", "autocapitalize" ), ( "autocomplete", "autocomplete" ), ( "autocorrect", "autocorrect" ), ( "autofocus", "autofocus" ), ( "clearable", "clearable" ), ( "disabled", "disabled" ), ( "enterkeyhint", "enterkeyhint" ), ( "filled", "filled" ), ( "form", "form" ), ( "helpText", "helpText" ), ( "inputmode", "inputmode" ), ( "label", "label" ), ( "max", "max" ), ( "maxlength", "maxlength" ), ( "min", "min" ), ( "minlength", "minlength" ), ( "name", "name" ), ( "noSpinButtons", "noSpinButtons" ), ( "passwordToggle", "passwordToggle" ), ( "passwordVisible", "passwordVisible" ), ( "pattern", "pattern" ), ( "pill", "pill" ), ( "placeholder", "placeholder" ), ( "readonly", "readonly" ), ( "required", "required" ), ( "size", "size" ), ( "spellcheck", "spellcheck" ), ( "step", "step" ), ( "title", "title" ), ( "type_", "type_" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ), ( "onBlur", "onBlur" ), ( "onChange", "onChange" ), ( "onClear", "onClear" ), ( "onFocus", "onFocus" ), ( "onInput", "onInput" ), ( "onInvalid", "onInvalid" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "menu"
      , module_ = "Sl.Component.Menu"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "onSelect", "onSelect" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "menuItem"
      , module_ = "Sl.Component.MenuItem"
      , enums = [ ( "type_", [ "checkbox", "normal" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "checked", "checked" ), ( "disabled", "disabled" ), ( "loading", "loading" ), ( "type_", "type_" ), ( "value", "value" ), ( "defaultChecked", "defaultChecked" ), ( "defaultValue", "defaultValue" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "menuLabel"
      , module_ = "Sl.Component.MenuLabel"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "mutationObserver"
      , module_ = "Sl.Component.MutationObserver"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "attr", "attr" ), ( "attrOldValue", "attrOldValue" ), ( "charData", "charData" ), ( "charDataOldValue", "charDataOldValue" ), ( "childList", "childList" ), ( "disabled", "disabled" ), ( "onMutation", "onMutation" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "option"
      , module_ = "Sl.Component.Option"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "popup"
      , module_ = "Sl.Component.Popup"
      , enums = [ ( "arrowPlacement", [ "anchor", "center", "end", "start" ] ), ( "autoSize", [ "both", "horizontal", "vertical" ] ), ( "flipFallbackStrategy", [ "bestFit", "initial" ] ), ( "placement", [ "bottom", "bottomEnd", "bottomStart", "left", "leftEnd", "leftStart", "right", "rightEnd", "rightStart", "top", "topEnd", "topStart" ] ), ( "strategy", [ "absolute", "fixed" ] ), ( "sync", [ "both", "height", "width" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "active", "active" ), ( "anchor", "anchor" ), ( "arrow", "arrow" ), ( "arrowPadding", "arrowPadding" ), ( "arrowPlacement", "arrowPlacement" ), ( "autoSize", "autoSize" ), ( "autoSizePadding", "autoSizePadding" ), ( "autosizeboundary", "autosizeboundary" ), ( "distance", "distance" ), ( "flip", "flip" ), ( "flipFallbackPlacements", "flipFallbackPlacements" ), ( "flipFallbackStrategy", "flipFallbackStrategy" ), ( "flipPadding", "flipPadding" ), ( "flipboundary", "flipboundary" ), ( "hoverBridge", "hoverBridge" ), ( "placement", "placement" ), ( "shift", "shift" ), ( "shiftPadding", "shiftPadding" ), ( "shiftboundary", "shiftboundary" ), ( "skidding", "skidding" ), ( "strategy", "strategy" ), ( "sync", "sync" ), ( "onReposition", "onReposition" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "progressBar"
      , module_ = "Sl.Component.ProgressBar"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "indeterminate", "indeterminate" ), ( "label", "label" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "progressRing"
      , module_ = "Sl.Component.ProgressRing"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "label", "label" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "qrCode"
      , module_ = "Sl.Component.QrCode"
      , enums = [ ( "errorCorrection", [ "h", "l", "m", "q" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "background", "background" ), ( "errorCorrection", "errorCorrection" ), ( "fill", "fill" ), ( "label", "label" ), ( "radius", "radius" ), ( "size", "size" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "radio"
      , module_ = "Sl.Component.Radio"
      , enums = [ ( "size", [ "large", "medium", "small" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "size", "size" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ), ( "onBlur", "onBlur" ), ( "onFocus", "onFocus" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "radioButton"
      , module_ = "Sl.Component.RadioButton"
      , enums = [ ( "size", [ "large", "medium", "small" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "pill", "pill" ), ( "size", "size" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ), ( "onBlur", "onBlur" ), ( "onFocus", "onFocus" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "radioGroup"
      , module_ = "Sl.Component.RadioGroup"
      , enums = [ ( "size", [ "large", "medium", "small" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "form", "form" ), ( "helpText", "helpText" ), ( "label", "label" ), ( "name", "name" ), ( "required", "required" ), ( "size", "size" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ), ( "onChange", "onChange" ), ( "onInput", "onInput" ), ( "onInvalid", "onInvalid" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "range"
      , module_ = "Sl.Component.Range"
      , enums = [ ( "tooltip", [ "bottom", "none", "top" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "form", "form" ), ( "helpText", "helpText" ), ( "label", "label" ), ( "max", "max" ), ( "min", "min" ), ( "name", "name" ), ( "step", "step" ), ( "title", "title" ), ( "tooltip", "tooltip" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ), ( "onBlur", "onBlur" ), ( "onChange", "onChange" ), ( "onFocus", "onFocus" ), ( "onInput", "onInput" ), ( "onInvalid", "onInvalid" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "rating"
      , module_ = "Sl.Component.Rating"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "getsymbol", "getsymbol" ), ( "label", "label" ), ( "max", "max" ), ( "precision", "precision" ), ( "readonly", "readonly" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ), ( "onChange", "onChange" ), ( "onHover", "onHover" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "relativeTime"
      , module_ = "Sl.Component.RelativeTime"
      , enums = [ ( "format", [ "long", "narrow", "short" ] ), ( "numeric", [ "always", "auto" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "date", "date" ), ( "format", "format" ), ( "numeric", "numeric" ), ( "sync", "sync" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "resizeObserver"
      , module_ = "Sl.Component.ResizeObserver"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "onResize", "onResize" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "select"
      , module_ = "Sl.Component.Select"
      , enums = [ ( "placement", [ "bottom", "top" ] ), ( "size", [ "large", "medium", "small" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "clearable", "clearable" ), ( "disabled", "disabled" ), ( "filled", "filled" ), ( "form", "form" ), ( "gettag", "gettag" ), ( "helpText", "helpText" ), ( "hoist", "hoist" ), ( "label", "label" ), ( "maxOptionsVisible", "maxOptionsVisible" ), ( "multiple", "multiple" ), ( "name", "name" ), ( "open", "open" ), ( "pill", "pill" ), ( "placeholder", "placeholder" ), ( "placement", "placement" ), ( "required", "required" ), ( "size", "size" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ), ( "onChange", "onChange" ), ( "onClear", "onClear" ), ( "onInput", "onInput" ), ( "onFocus", "onFocus" ), ( "onBlur", "onBlur" ), ( "onShow", "onShow" ), ( "onAfterShow", "onAfterShow" ), ( "onHide", "onHide" ), ( "onAfterHide", "onAfterHide" ), ( "onInvalid", "onInvalid" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "skeleton"
      , module_ = "Sl.Component.Skeleton"
      , enums = [ ( "effect_", [ "none", "pulse", "sheen" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "effect_", "effect_" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "spinner"
      , module_ = "Sl.Component.Spinner"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "splitPanel"
      , module_ = "Sl.Component.SplitPanel"
      , enums = [ ( "primary", [ "end", "start" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "position", "position" ), ( "positionInPixels", "positionInPixels" ), ( "primary", "primary" ), ( "snap", "snap" ), ( "snapThreshold", "snapThreshold" ), ( "vertical", "vertical" ), ( "onReposition", "onReposition" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "switch"
      , module_ = "Sl.Component.Switch"
      , enums = [ ( "size", [ "large", "medium", "small" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "checked", "checked" ), ( "disabled", "disabled" ), ( "form", "form" ), ( "helpText", "helpText" ), ( "name", "name" ), ( "required", "required" ), ( "size", "size" ), ( "title", "title" ), ( "value", "value" ), ( "defaultChecked", "defaultChecked" ), ( "defaultValue", "defaultValue" ), ( "onBlur", "onBlur" ), ( "onChange", "onChange" ), ( "onInput", "onInput" ), ( "onFocus", "onFocus" ), ( "onInvalid", "onInvalid" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "tab"
      , module_ = "Sl.Component.Tab"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "active", "active" ), ( "closable", "closable" ), ( "disabled", "disabled" ), ( "panel", "panel" ), ( "onClose", "onClose" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "tabGroup"
      , module_ = "Sl.Component.TabGroup"
      , enums = [ ( "activation", [ "auto", "manual" ] ), ( "placement", [ "bottom", "end", "start", "top" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "activation", "activation" ), ( "fixedScrollControls", "fixedScrollControls" ), ( "noScrollControls", "noScrollControls" ), ( "placement", "placement" ), ( "onTabShow", "onTabShow" ), ( "onTabHide", "onTabHide" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "tabPanel"
      , module_ = "Sl.Component.TabPanel"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "active", "active" ), ( "name", "name" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "tag"
      , module_ = "Sl.Component.Tag"
      , enums = [ ( "size", [ "large", "medium", "small" ] ), ( "variant", [ "danger", "neutral", "primary", "success", "text", "warning" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "pill", "pill" ), ( "removable", "removable" ), ( "size", "size" ), ( "variant", "variant" ), ( "onRemove", "onRemove" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "textarea"
      , module_ = "Sl.Component.Textarea"
      , enums = [ ( "autocapitalize", [ "characters", "none", "off", "on", "sentences", "words" ] ), ( "enterkeyhint", [ "done", "enter", "go", "next", "previous", "search", "send" ] ), ( "inputmode", [ "decimal", "email", "none", "numeric", "search", "tel", "text", "url" ] ), ( "resize", [ "auto", "none", "vertical" ] ), ( "size", [ "large", "medium", "small" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "autocapitalize", "autocapitalize" ), ( "autocomplete", "autocomplete" ), ( "autocorrect", "autocorrect" ), ( "autofocus", "autofocus" ), ( "disabled", "disabled" ), ( "enterkeyhint", "enterkeyhint" ), ( "filled", "filled" ), ( "form", "form" ), ( "helpText", "helpText" ), ( "inputmode", "inputmode" ), ( "label", "label" ), ( "maxlength", "maxlength" ), ( "minlength", "minlength" ), ( "name", "name" ), ( "placeholder", "placeholder" ), ( "readonly", "readonly" ), ( "required", "required" ), ( "resize", "resize" ), ( "rows", "rows" ), ( "size", "size" ), ( "spellcheck", "spellcheck" ), ( "title", "title" ), ( "value", "value" ), ( "defaultValue", "defaultValue" ), ( "onBlur", "onBlur" ), ( "onChange", "onChange" ), ( "onFocus", "onFocus" ), ( "onInput", "onInput" ), ( "onInvalid", "onInvalid" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "tooltip"
      , module_ = "Sl.Component.Tooltip"
      , enums = [ ( "placement", [ "bottom", "bottomEnd", "bottomStart", "left", "leftEnd", "leftStart", "right", "rightEnd", "rightStart", "top", "topEnd", "topStart" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "content", "content" ), ( "disabled", "disabled" ), ( "distance", "distance" ), ( "hoist", "hoist" ), ( "open", "open" ), ( "placement", "placement" ), ( "skidding", "skidding" ), ( "trigger", "trigger" ), ( "onShow", "onShow" ), ( "onAfterShow", "onAfterShow" ), ( "onHide", "onHide" ), ( "onAfterHide", "onAfterHide" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "tree"
      , module_ = "Sl.Component.Tree"
      , enums = [ ( "selection", [ "leaf", "multiple", "single" ] ) ]
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "selection", "selection" ), ( "onSelectionChange", "onSelectionChange" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "treeItem"
      , module_ = "Sl.Component.TreeItem"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = [ ( "disabled", "disabled" ), ( "expanded", "expanded" ), ( "lazy", "lazy" ), ( "selected", "selected" ), ( "defaultSelected", "defaultSelected" ), ( "onExpand", "onExpand" ), ( "onAfterExpand", "onAfterExpand" ), ( "onCollapse", "onCollapse" ), ( "onAfterCollapse", "onAfterCollapse" ), ( "onLazyChange", "onLazyChange" ), ( "onLazyLoad", "onLazyLoad" ) ]
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    , { component = "visuallyHidden"
      , module_ = "Sl.Component.VisuallyHidden"
      , enums = []
      , requiredSlots = []
      , multiSlots = []
      , attrRewrites = []
      , slotRewrites = []
      , slotKinds = []
      , slotUpgrades = []
      , groupConstructors = []
      , facets = [ Standard, Build ]
      , requiredAttrs = []
      , actionMap = []
      , usesAction = False
      }
    ]


{-| The document-wide attributes EVERY element of this brand admits — the
`_globals` roster.

Emitted for the escape-discipline rules, which may only suggest a typed
setter when the attribute's meaning is **element-independent**. A global
qualifies by definition; an element-specific attribute does not, because from
an escape call site `content` on a `<meta>` is indistinguishable from
`content` on a custom element that gives the name its own meaning.

-}
globalAttributes : List String
globalAttributes =
    [ "class", "id", "slot", "style" ]


{-| Kept for the PreferBarrel flatten class; inert on the phantom surface.
-}
reExposedValueTokens : List String
reExposedValueTokens =
    []
