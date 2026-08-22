module M3e.Build.Chip exposing (ChipBuilder, ChipAttrCaps, ChipSlotCaps, ChipIs, ChipContent, ChipIconSlot, ChipTrailingIconSlot, ChipChildAdmittedBy, chipBuild, chipToElement, chipWithClass, chipWithId, chipWithSlot, chipWithStyle, chipWithValue, chipWithVariant, chipIcon, chipTrailingIcon, chipWithIcon, chipWithTrailingIcon, chipWithChild, AssistBuilder, AssistAttrCaps, AssistSlotCaps, AssistIs, AssistContent, AssistIconSlot, AssistChildAdmittedBy, assistBuild, assistToElement, assistWithClass, assistWithDisabled, assistWithDisabledInteractive, assistWithDownload, assistWithHref, assistWithId, assistWithName, assistWithOnClick, assistWithRel, assistWithSlot, assistWithStyle, assistWithTarget, assistWithType, assistWithValue, assistWithVariant, assistIcon, assistWithIcon, assistWithChild, FilterBuilder, FilterAttrCaps, FilterSlotCaps, FilterIs, FilterContent, FilterIconSlot, FilterTrailingIconSlot, FilterChildAdmittedBy, filterBuild, filterToElement, filterWithClass, filterWithDisabled, filterWithDisabledInteractive, filterWithId, filterWithOnBeforeinput, filterWithOnChange, filterWithOnClick, filterWithOnInput, filterWithSelected, filterWithSlot, filterWithStyle, filterWithValue, filterWithVariant, filterIcon, filterTrailingIcon, filterWithIcon, filterWithTrailingIcon, filterWithChild, InputBuilder, InputAttrCaps, InputSlotCaps, InputIs, InputContent, InputAvatarSlot, InputIconSlot, InputRemoveIconSlot, InputChildAdmittedBy, inputBuild, inputToElement, inputWithClass, inputWithDisabled, inputWithDisabledInteractive, inputWithId, inputWithOnClick, inputWithOnRemove, inputWithRemovable, inputWithRemoveLabel, inputWithSlot, inputWithStyle, inputWithValue, inputWithVariant, inputAvatar, inputIcon, inputRemoveIcon, inputWithAvatar, inputWithIcon, inputWithRemoveIcon, inputWithChild, SuggestionBuilder, SuggestionAttrCaps, SuggestionSlotCaps, SuggestionIs, SuggestionContent, SuggestionIconSlot, SuggestionChildAdmittedBy, SuggestionActionCaps, suggestionBuild, suggestionToElement, suggestionWithClass, suggestionWithDisabled, suggestionWithDisabledInteractive, suggestionWithDownload, suggestionWithHref, suggestionWithId, suggestionWithName, suggestionWithOnClick, suggestionWithRel, suggestionWithSlot, suggestionWithStyle, suggestionWithTarget, suggestionWithType, suggestionWithValue, suggestionWithVariant, suggestionIcon, suggestionWithIcon, suggestionWithChild, SetBuilder, SetAttrCaps, SetSlotCaps, SetIs, SetContent, SetChildAdmittedBy, setBuild, setToElement, setWithClass, setWithId, setWithSlot, setWithStyle, setWithVertical, setWithChild, FilterSetBuilder, FilterSetAttrCaps, FilterSetSlotCaps, FilterSetIs, FilterSetContent, FilterSetChildAdmittedBy, filterSetBuild, filterSetToElement, filterSetWithClass, filterSetWithDisabled, filterSetWithHideSelectionIndicator, filterSetWithId, filterSetWithMulti, filterSetWithName, filterSetWithOnBeforeinput, filterSetWithOnChange, filterSetWithOnInput, filterSetWithSlot, filterSetWithStyle, filterSetWithVertical, filterSetWithChild, InputSetBuilder, InputSetAttrCaps, InputSetSlotCaps, InputSetIs, InputSetContent, InputSetChildAdmittedBy, inputSetBuild, inputSetToElement, inputSetWithClass, inputSetWithDisabled, inputSetWithId, inputSetWithMaxChips, inputSetWithName, inputSetWithOnChange, inputSetWithRequired, inputSetWithSlot, inputSetWithStyle, inputSetWithValidationmessages, inputSetWithVertical, inputSetInput, inputSetWithInput, inputSetWithChild)

{-| The **Chip** family — the COMPOSED builder tier.

One module carrying every member's builder surface, member-prefixed
(the per-element flat surface lives at `M3e.Build.<Element>`), sourced through `M3e.Component.Chip`
— the one real Components-driven builder implementation (DAG
`Build → Components → Elements → Core`), never `M3e.Element.*`.

@docs ChipBuilder, ChipAttrCaps, ChipSlotCaps, ChipIs, ChipContent, ChipIconSlot, ChipTrailingIconSlot, ChipChildAdmittedBy, chipBuild, chipToElement, chipWithClass, chipWithId, chipWithSlot, chipWithStyle, chipWithValue, chipWithVariant, chipIcon, chipTrailingIcon, chipWithIcon, chipWithTrailingIcon, chipWithChild, AssistBuilder, AssistAttrCaps, AssistSlotCaps, AssistIs, AssistContent, AssistIconSlot, AssistChildAdmittedBy, assistBuild, assistToElement, assistWithClass, assistWithDisabled, assistWithDisabledInteractive, assistWithDownload, assistWithHref, assistWithId, assistWithName, assistWithOnClick, assistWithRel, assistWithSlot, assistWithStyle, assistWithTarget, assistWithType, assistWithValue, assistWithVariant, assistIcon, assistWithIcon, assistWithChild, FilterBuilder, FilterAttrCaps, FilterSlotCaps, FilterIs, FilterContent, FilterIconSlot, FilterTrailingIconSlot, FilterChildAdmittedBy, filterBuild, filterToElement, filterWithClass, filterWithDisabled, filterWithDisabledInteractive, filterWithId, filterWithOnBeforeinput, filterWithOnChange, filterWithOnClick, filterWithOnInput, filterWithSelected, filterWithSlot, filterWithStyle, filterWithValue, filterWithVariant, filterIcon, filterTrailingIcon, filterWithIcon, filterWithTrailingIcon, filterWithChild, InputBuilder, InputAttrCaps, InputSlotCaps, InputIs, InputContent, InputAvatarSlot, InputIconSlot, InputRemoveIconSlot, InputChildAdmittedBy, inputBuild, inputToElement, inputWithClass, inputWithDisabled, inputWithDisabledInteractive, inputWithId, inputWithOnClick, inputWithOnRemove, inputWithRemovable, inputWithRemoveLabel, inputWithSlot, inputWithStyle, inputWithValue, inputWithVariant, inputAvatar, inputIcon, inputRemoveIcon, inputWithAvatar, inputWithIcon, inputWithRemoveIcon, inputWithChild, SuggestionBuilder, SuggestionAttrCaps, SuggestionSlotCaps, SuggestionIs, SuggestionContent, SuggestionIconSlot, SuggestionChildAdmittedBy, SuggestionActionCaps, suggestionBuild, suggestionToElement, suggestionWithClass, suggestionWithDisabled, suggestionWithDisabledInteractive, suggestionWithDownload, suggestionWithHref, suggestionWithId, suggestionWithName, suggestionWithOnClick, suggestionWithRel, suggestionWithSlot, suggestionWithStyle, suggestionWithTarget, suggestionWithType, suggestionWithValue, suggestionWithVariant, suggestionIcon, suggestionWithIcon, suggestionWithChild, SetBuilder, SetAttrCaps, SetSlotCaps, SetIs, SetContent, SetChildAdmittedBy, setBuild, setToElement, setWithClass, setWithId, setWithSlot, setWithStyle, setWithVertical, setWithChild, FilterSetBuilder, FilterSetAttrCaps, FilterSetSlotCaps, FilterSetIs, FilterSetContent, FilterSetChildAdmittedBy, filterSetBuild, filterSetToElement, filterSetWithClass, filterSetWithDisabled, filterSetWithHideSelectionIndicator, filterSetWithId, filterSetWithMulti, filterSetWithName, filterSetWithOnBeforeinput, filterSetWithOnChange, filterSetWithOnInput, filterSetWithSlot, filterSetWithStyle, filterSetWithVertical, filterSetWithChild, InputSetBuilder, InputSetAttrCaps, InputSetSlotCaps, InputSetIs, InputSetContent, InputSetChildAdmittedBy, inputSetBuild, inputSetToElement, inputSetWithClass, inputSetWithDisabled, inputSetWithId, inputSetWithMaxChips, inputSetWithName, inputSetWithOnChange, inputSetWithRequired, inputSetWithSlot, inputSetWithStyle, inputSetWithValidationmessages, inputSetWithVertical, inputSetInput, inputSetWithInput, inputSetWithChild

-}

import HtmlIr.Element as El exposing (Element)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import Json.Encode
import M3e.Action as Ac
import M3e.Attributes as A
import M3e.Component.Chip as Component
import M3e.Events as Ev
import M3e.Forge.Internal as B
import M3e.Kind exposing (Available, Brand, Ctx, Used)
import M3e.Values


{-| -}
type alias ChipIs s =
    Component.ChipIs s


{-| -}
type alias ChipBuilder attrCaps slotCaps msg kind =
    Component.ChipBuilder attrCaps slotCaps msg kind


{-| -}
type alias ChipAttrCaps =
    Component.ChipAttrCaps


{-| -}
type alias ChipSlotCaps =
    Component.ChipSlotCaps


{-| -}
type alias ChipChildAdmittedBy childAdm =
    Component.ChipChildAdmittedBy childAdm


{-| -}
type alias ChipContent =
    Component.ChipContent


{-| -}
type alias ChipIconSlot =
    Component.ChipIconSlot


{-| -}
type alias ChipTrailingIconSlot =
    Component.ChipTrailingIconSlot


{-| -}
chipBuild :
    { content : Element Component.ChipContent (Component.ChipChildAdmittedBy childAdm) msg }
    -> ChipBuilder ChipAttrCaps ChipSlotCaps msg kind
chipBuild required_ =
    B.init "m3e-chip" [] [ El.toNode required_.content ]


{-| -}
chipToElement : ChipBuilder attrCaps slotCaps msg kind -> Element (Component.ChipIs kind) admittedBy msg
chipToElement =
    B.toElement


{-| -}
chipIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ChipIconSlot msg
    -> Element free freeAdmittedBy msg
chipIcon builder =
    Component.chipIcon (B.toElement builder)


{-| -}
chipTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ChipTrailingIconSlot msg
    -> Element free freeAdmittedBy msg
chipTrailingIcon builder =
    Component.chipTrailingIcon (B.toElement builder)


{-| -}
chipWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ChipIconSlot msg
    -> ChipBuilder attrCaps { s | icon : Available } msg kind
    -> ChipBuilder attrCaps { s | icon : Used } msg kind
chipWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.chipIcon (B.toElement slotBuilder))) builder_


{-| -}
chipWithTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.ChipTrailingIconSlot msg
    -> ChipBuilder attrCaps { s | trailingIcon : Available } msg kind
    -> ChipBuilder attrCaps { s | trailingIcon : Used } msg kind
chipWithTrailingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.chipTrailingIcon (B.toElement slotBuilder))) builder_


{-| -}
chipWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> ChipBuilder attrCaps slotCaps msg kind
    -> ChipBuilder attrCaps slotCaps msg kind
chipWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
chipWithClass : String -> ChipBuilder { a | class : Available } slotCaps msg kind -> ChipBuilder { a | class : Used } slotCaps msg kind
chipWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
chipWithId : String -> ChipBuilder { a | id : Available } slotCaps msg kind -> ChipBuilder { a | id : Used } slotCaps msg kind
chipWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
chipWithSlot : String -> ChipBuilder { a | slot : Available } slotCaps msg kind -> ChipBuilder { a | slot : Used } slotCaps msg kind
chipWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
chipWithStyle : String -> String -> ChipBuilder { a | style : Available } slotCaps msg kind -> ChipBuilder { a | style : Used } slotCaps msg kind
chipWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
chipWithValue : String -> ChipBuilder { a | value : Available } slotCaps msg kind -> ChipBuilder { a | value : Used } slotCaps msg kind
chipWithValue value_ =
    B.withAttribute (A.value value_)


{-| -}
chipWithVariant : Value Component.ChipVariant -> ChipBuilder { a | variant : Available } slotCaps msg kind -> ChipBuilder { a | variant : Used } slotCaps msg kind
chipWithVariant value_ =
    B.withAttribute (Component.chipVariant value_)


{-| -}
type alias AssistIs s =
    Component.AssistIs s


{-| -}
type alias AssistBuilder attrCaps slotCaps msg kind =
    Component.AssistBuilder attrCaps slotCaps msg kind


{-| -}
type alias AssistAttrCaps =
    Component.AssistAttrCaps


{-| -}
type alias AssistSlotCaps =
    Component.AssistSlotCaps


{-| -}
type alias AssistChildAdmittedBy childAdm =
    Component.AssistChildAdmittedBy childAdm


{-| -}
type alias AssistContent =
    Component.AssistContent


{-| -}
type alias AssistIconSlot =
    Component.AssistIconSlot


{-| -}
assistBuild :
    { content : Element Component.AssistContent (Component.AssistChildAdmittedBy childAdm) msg }
    -> AssistBuilder AssistAttrCaps AssistSlotCaps msg kind
assistBuild required_ =
    B.init "m3e-assist-chip" [] [ El.toNode required_.content ]


{-| -}
assistToElement : AssistBuilder attrCaps slotCaps msg kind -> Element (Component.AssistIs kind) admittedBy msg
assistToElement =
    B.toElement


{-| -}
assistIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.AssistIconSlot msg
    -> Element free freeAdmittedBy msg
assistIcon builder =
    Component.assistIcon (B.toElement builder)


{-| -}
assistWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.AssistIconSlot msg
    -> AssistBuilder attrCaps { s | icon : Available } msg kind
    -> AssistBuilder attrCaps { s | icon : Used } msg kind
assistWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.assistIcon (B.toElement slotBuilder))) builder_


{-| -}
assistWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> AssistBuilder attrCaps slotCaps msg kind
    -> AssistBuilder attrCaps slotCaps msg kind
assistWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
assistWithClass : String -> AssistBuilder { a | class : Available } slotCaps msg kind -> AssistBuilder { a | class : Used } slotCaps msg kind
assistWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
assistWithId : String -> AssistBuilder { a | id : Available } slotCaps msg kind -> AssistBuilder { a | id : Used } slotCaps msg kind
assistWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
assistWithSlot : String -> AssistBuilder { a | slot : Available } slotCaps msg kind -> AssistBuilder { a | slot : Used } slotCaps msg kind
assistWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
assistWithStyle : String -> String -> AssistBuilder { a | style : Available } slotCaps msg kind -> AssistBuilder { a | style : Used } slotCaps msg kind
assistWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
assistWithDisabled : Bool -> AssistBuilder { a | disabled : Available } slotCaps msg kind -> AssistBuilder { a | disabled : Used } slotCaps msg kind
assistWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
assistWithDisabledInteractive : Bool -> AssistBuilder { a | disabledInteractive : Available } slotCaps msg kind -> AssistBuilder { a | disabledInteractive : Used } slotCaps msg kind
assistWithDisabledInteractive value_ =
    B.withAttribute (A.disabledInteractive value_)


{-| -}
assistWithDownload : String -> AssistBuilder { a | download : Available } slotCaps msg kind -> AssistBuilder { a | download : Used } slotCaps msg kind
assistWithDownload value_ =
    B.withAttribute (A.download value_)


{-| -}
assistWithHref : String -> AssistBuilder { a | href : Available } slotCaps msg kind -> AssistBuilder { a | href : Used } slotCaps msg kind
assistWithHref value_ =
    B.withAttribute (A.href value_)


{-| -}
assistWithName : String -> AssistBuilder { a | name : Available } slotCaps msg kind -> AssistBuilder { a | name : Used } slotCaps msg kind
assistWithName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| -}
assistWithRel : String -> AssistBuilder { a | rel : Available } slotCaps msg kind -> AssistBuilder { a | rel : Used } slotCaps msg kind
assistWithRel value_ =
    B.withAttribute (A.rel value_)


{-| -}
assistWithTarget : String -> AssistBuilder { a | target : Available } slotCaps msg kind -> AssistBuilder { a | target : Used } slotCaps msg kind
assistWithTarget value_ =
    B.withAttribute (A.target value_)


{-| -}
assistWithType : Value Component.AssistType -> AssistBuilder { a | type_ : Available } slotCaps msg kind -> AssistBuilder { a | type_ : Used } slotCaps msg kind
assistWithType value_ =
    B.withAttribute (Component.assistType_ value_)


{-| -}
assistWithValue : String -> AssistBuilder { a | value : Available } slotCaps msg kind -> AssistBuilder { a | value : Used } slotCaps msg kind
assistWithValue value_ =
    B.withAttribute (A.value value_)


{-| -}
assistWithVariant : Value Component.AssistVariant -> AssistBuilder { a | variant : Available } slotCaps msg kind -> AssistBuilder { a | variant : Used } slotCaps msg kind
assistWithVariant value_ =
    B.withAttribute (Component.assistVariant value_)


{-| -}
assistWithOnClick : msg -> AssistBuilder { a | onClick : Available } slotCaps msg kind -> AssistBuilder { a | onClick : Used } slotCaps msg kind
assistWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| -}
type alias FilterIs s =
    Component.FilterIs s


{-| -}
type alias FilterBuilder attrCaps slotCaps msg kind =
    Component.FilterBuilder attrCaps slotCaps msg kind


{-| -}
type alias FilterAttrCaps =
    Component.FilterAttrCaps


{-| -}
type alias FilterSlotCaps =
    Component.FilterSlotCaps


{-| -}
type alias FilterChildAdmittedBy childAdm =
    Component.FilterChildAdmittedBy childAdm


{-| -}
type alias FilterContent =
    Component.FilterContent


{-| -}
type alias FilterIconSlot =
    Component.FilterIconSlot


{-| -}
type alias FilterTrailingIconSlot =
    Component.FilterTrailingIconSlot


{-| -}
filterBuild :
    { content : Element Component.FilterContent (Component.FilterChildAdmittedBy childAdm) msg }
    -> FilterBuilder FilterAttrCaps FilterSlotCaps msg kind
filterBuild required_ =
    B.init "m3e-filter-chip" [] [ El.toNode required_.content ]


{-| -}
filterToElement : FilterBuilder attrCaps slotCaps msg kind -> Element (Component.FilterIs kind) admittedBy msg
filterToElement =
    B.toElement


{-| -}
filterIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.FilterIconSlot msg
    -> Element free freeAdmittedBy msg
filterIcon builder =
    Component.filterIcon (B.toElement builder)


{-| -}
filterTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.FilterTrailingIconSlot msg
    -> Element free freeAdmittedBy msg
filterTrailingIcon builder =
    Component.filterTrailingIcon (B.toElement builder)


{-| -}
filterWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.FilterIconSlot msg
    -> FilterBuilder attrCaps { s | icon : Available } msg kind
    -> FilterBuilder attrCaps { s | icon : Used } msg kind
filterWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.filterIcon (B.toElement slotBuilder))) builder_


{-| -}
filterWithTrailingIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.FilterTrailingIconSlot msg
    -> FilterBuilder attrCaps { s | trailingIcon : Available } msg kind
    -> FilterBuilder attrCaps { s | trailingIcon : Used } msg kind
filterWithTrailingIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.filterTrailingIcon (B.toElement slotBuilder))) builder_


{-| -}
filterWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> FilterBuilder attrCaps slotCaps msg kind
    -> FilterBuilder attrCaps slotCaps msg kind
filterWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
filterWithClass : String -> FilterBuilder { a | class : Available } slotCaps msg kind -> FilterBuilder { a | class : Used } slotCaps msg kind
filterWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
filterWithId : String -> FilterBuilder { a | id : Available } slotCaps msg kind -> FilterBuilder { a | id : Used } slotCaps msg kind
filterWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
filterWithSlot : String -> FilterBuilder { a | slot : Available } slotCaps msg kind -> FilterBuilder { a | slot : Used } slotCaps msg kind
filterWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
filterWithStyle : String -> String -> FilterBuilder { a | style : Available } slotCaps msg kind -> FilterBuilder { a | style : Used } slotCaps msg kind
filterWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
filterWithDisabled : Bool -> FilterBuilder { a | disabled : Available } slotCaps msg kind -> FilterBuilder { a | disabled : Used } slotCaps msg kind
filterWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
filterWithDisabledInteractive : Bool -> FilterBuilder { a | disabledInteractive : Available } slotCaps msg kind -> FilterBuilder { a | disabledInteractive : Used } slotCaps msg kind
filterWithDisabledInteractive value_ =
    B.withAttribute (A.disabledInteractive value_)


{-| -}
filterWithSelected : Bool -> FilterBuilder { a | selected : Available } slotCaps msg kind -> FilterBuilder { a | selected : Used } slotCaps msg kind
filterWithSelected value_ =
    B.withAttribute (A.selected value_)


{-| -}
filterWithValue : String -> FilterBuilder { a | value : Available } slotCaps msg kind -> FilterBuilder { a | value : Used } slotCaps msg kind
filterWithValue value_ =
    B.withAttribute (A.value value_)


{-| -}
filterWithVariant : Value Component.FilterVariant -> FilterBuilder { a | variant : Available } slotCaps msg kind -> FilterBuilder { a | variant : Used } slotCaps msg kind
filterWithVariant value_ =
    B.withAttribute (Component.filterVariant value_)


{-| -}
filterWithOnBeforeinput : msg -> FilterBuilder { a | onBeforeinput : Available } slotCaps msg kind -> FilterBuilder { a | onBeforeinput : Used } slotCaps msg kind
filterWithOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
filterWithOnInput : msg -> FilterBuilder { a | onInput : Available } slotCaps msg kind -> FilterBuilder { a | onInput : Used } slotCaps msg kind
filterWithOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
filterWithOnChange : msg -> FilterBuilder { a | onChange : Available } slotCaps msg kind -> FilterBuilder { a | onChange : Used } slotCaps msg kind
filterWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
filterWithOnClick : msg -> FilterBuilder { a | onClick : Available } slotCaps msg kind -> FilterBuilder { a | onClick : Used } slotCaps msg kind
filterWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| -}
type alias InputIs s =
    Component.InputIs s


{-| -}
type alias InputBuilder attrCaps slotCaps msg kind =
    Component.InputBuilder attrCaps slotCaps msg kind


{-| -}
type alias InputAttrCaps =
    Component.InputAttrCaps


{-| -}
type alias InputSlotCaps =
    Component.InputSlotCaps


{-| -}
type alias InputChildAdmittedBy childAdm =
    Component.InputChildAdmittedBy childAdm


{-| -}
type alias InputContent =
    Component.InputContent


{-| -}
type alias InputAvatarSlot =
    Component.InputAvatarSlot


{-| -}
type alias InputIconSlot =
    Component.InputIconSlot


{-| -}
type alias InputRemoveIconSlot =
    Component.InputRemoveIconSlot


{-| -}
inputBuild :
    { content : Element Component.InputContent (Component.InputChildAdmittedBy childAdm) msg }
    -> InputBuilder InputAttrCaps InputSlotCaps msg kind
inputBuild required_ =
    B.init "m3e-input-chip" [] [ El.toNode required_.content ]


{-| -}
inputToElement : InputBuilder attrCaps slotCaps msg kind -> Element (Component.InputIs kind) admittedBy msg
inputToElement =
    B.toElement


{-| -}
inputAvatar :
    B.Builder childRow childAttrCaps childSlotCaps Component.InputAvatarSlot msg
    -> Element free freeAdmittedBy msg
inputAvatar builder =
    Component.inputAvatar (B.toElement builder)


{-| -}
inputIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.InputIconSlot msg
    -> Element free freeAdmittedBy msg
inputIcon builder =
    Component.inputIcon (B.toElement builder)


{-| -}
inputRemoveIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.InputRemoveIconSlot msg
    -> Element free freeAdmittedBy msg
inputRemoveIcon builder =
    Component.inputRemoveIcon (B.toElement builder)


{-| -}
inputWithAvatar :
    B.Builder childRow childAttrCaps childSlotCaps Component.InputAvatarSlot msg
    -> InputBuilder attrCaps { s | avatar : Available } msg kind
    -> InputBuilder attrCaps { s | avatar : Used } msg kind
inputWithAvatar slotBuilder builder_ =
    B.withChild (El.toNode (Component.inputAvatar (B.toElement slotBuilder))) builder_


{-| -}
inputWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.InputIconSlot msg
    -> InputBuilder attrCaps { s | icon : Available } msg kind
    -> InputBuilder attrCaps { s | icon : Used } msg kind
inputWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.inputIcon (B.toElement slotBuilder))) builder_


{-| -}
inputWithRemoveIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.InputRemoveIconSlot msg
    -> InputBuilder attrCaps { s | removeIcon : Available } msg kind
    -> InputBuilder attrCaps { s | removeIcon : Used } msg kind
inputWithRemoveIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.inputRemoveIcon (B.toElement slotBuilder))) builder_


{-| -}
inputWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> InputBuilder attrCaps slotCaps msg kind
    -> InputBuilder attrCaps slotCaps msg kind
inputWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
inputWithClass : String -> InputBuilder { a | class : Available } slotCaps msg kind -> InputBuilder { a | class : Used } slotCaps msg kind
inputWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
inputWithId : String -> InputBuilder { a | id : Available } slotCaps msg kind -> InputBuilder { a | id : Used } slotCaps msg kind
inputWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
inputWithSlot : String -> InputBuilder { a | slot : Available } slotCaps msg kind -> InputBuilder { a | slot : Used } slotCaps msg kind
inputWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
inputWithStyle : String -> String -> InputBuilder { a | style : Available } slotCaps msg kind -> InputBuilder { a | style : Used } slotCaps msg kind
inputWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
inputWithDisabled : Bool -> InputBuilder { a | disabled : Available } slotCaps msg kind -> InputBuilder { a | disabled : Used } slotCaps msg kind
inputWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
inputWithDisabledInteractive : Bool -> InputBuilder { a | disabledInteractive : Available } slotCaps msg kind -> InputBuilder { a | disabledInteractive : Used } slotCaps msg kind
inputWithDisabledInteractive value_ =
    B.withAttribute (A.disabledInteractive value_)


{-| -}
inputWithRemovable : Bool -> InputBuilder { a | removable : Available } slotCaps msg kind -> InputBuilder { a | removable : Used } slotCaps msg kind
inputWithRemovable value_ =
    B.withAttribute (A.removable value_)


{-| -}
inputWithRemoveLabel : String -> InputBuilder { a | removeLabel : Available } slotCaps msg kind -> InputBuilder { a | removeLabel : Used } slotCaps msg kind
inputWithRemoveLabel value_ =
    B.withAttribute (A.removeLabel value_)


{-| -}
inputWithValue : String -> InputBuilder { a | value : Available } slotCaps msg kind -> InputBuilder { a | value : Used } slotCaps msg kind
inputWithValue value_ =
    B.withAttribute (A.value value_)


{-| -}
inputWithVariant : Value Component.InputVariant -> InputBuilder { a | variant : Available } slotCaps msg kind -> InputBuilder { a | variant : Used } slotCaps msg kind
inputWithVariant value_ =
    B.withAttribute (Component.inputVariant value_)


{-| -}
inputWithOnRemove : msg -> InputBuilder { a | onRemove : Available } slotCaps msg kind -> InputBuilder { a | onRemove : Used } slotCaps msg kind
inputWithOnRemove value_ =
    B.withAttribute (Ev.onRemove value_)


{-| -}
inputWithOnClick : msg -> InputBuilder { a | onClick : Available } slotCaps msg kind -> InputBuilder { a | onClick : Used } slotCaps msg kind
inputWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| -}
type alias SuggestionIs s =
    Component.SuggestionIs s


{-| -}
type alias SuggestionBuilder attrCaps slotCaps msg kind =
    Component.SuggestionBuilder attrCaps slotCaps msg kind


{-| -}
type alias SuggestionAttrCaps =
    Component.SuggestionAttrCaps


{-| -}
type alias SuggestionSlotCaps =
    Component.SuggestionSlotCaps


{-| -}
type alias SuggestionChildAdmittedBy childAdm =
    Component.SuggestionChildAdmittedBy childAdm


{-| -}
type alias SuggestionContent =
    Component.SuggestionContent


{-| -}
type alias SuggestionIconSlot =
    Component.SuggestionIconSlot


{-| -}
type alias SuggestionActionCaps =
    Component.SuggestionActionCaps


{-| -}
suggestionBuild :
    { content : Element Component.SuggestionContent (Component.SuggestionChildAdmittedBy childAdm) msg
    , action : Ac.Action Component.SuggestionActionCaps msg
    }
    -> SuggestionBuilder SuggestionAttrCaps SuggestionSlotCaps msg kind
suggestionBuild required_ =
    B.init "m3e-suggestion-chip" (Ac.toAttrs required_.action) [ Ac.wrapContent required_.action (El.toNode required_.content) ]


{-| -}
suggestionToElement : SuggestionBuilder attrCaps slotCaps msg kind -> Element (Component.SuggestionIs kind) admittedBy msg
suggestionToElement =
    B.toElement


{-| -}
suggestionIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SuggestionIconSlot msg
    -> Element free freeAdmittedBy msg
suggestionIcon builder =
    Component.suggestionIcon (B.toElement builder)


{-| -}
suggestionWithIcon :
    B.Builder childRow childAttrCaps childSlotCaps Component.SuggestionIconSlot msg
    -> SuggestionBuilder attrCaps { s | icon : Available } msg kind
    -> SuggestionBuilder attrCaps { s | icon : Used } msg kind
suggestionWithIcon slotBuilder builder_ =
    B.withChild (El.toNode (Component.suggestionIcon (B.toElement slotBuilder))) builder_


{-| -}
suggestionWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> SuggestionBuilder attrCaps slotCaps msg kind
    -> SuggestionBuilder attrCaps slotCaps msg kind
suggestionWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
suggestionWithClass : String -> SuggestionBuilder { a | class : Available } slotCaps msg kind -> SuggestionBuilder { a | class : Used } slotCaps msg kind
suggestionWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
suggestionWithId : String -> SuggestionBuilder { a | id : Available } slotCaps msg kind -> SuggestionBuilder { a | id : Used } slotCaps msg kind
suggestionWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
suggestionWithSlot : String -> SuggestionBuilder { a | slot : Available } slotCaps msg kind -> SuggestionBuilder { a | slot : Used } slotCaps msg kind
suggestionWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
suggestionWithStyle : String -> String -> SuggestionBuilder { a | style : Available } slotCaps msg kind -> SuggestionBuilder { a | style : Used } slotCaps msg kind
suggestionWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
suggestionWithDisabled : Bool -> SuggestionBuilder { a | disabled : Available } slotCaps msg kind -> SuggestionBuilder { a | disabled : Used } slotCaps msg kind
suggestionWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
suggestionWithDisabledInteractive : Bool -> SuggestionBuilder { a | disabledInteractive : Available } slotCaps msg kind -> SuggestionBuilder { a | disabledInteractive : Used } slotCaps msg kind
suggestionWithDisabledInteractive value_ =
    B.withAttribute (A.disabledInteractive value_)


{-| -}
suggestionWithDownload : String -> SuggestionBuilder { a | download : Available } slotCaps msg kind -> SuggestionBuilder { a | download : Used } slotCaps msg kind
suggestionWithDownload value_ =
    B.withAttribute (A.download value_)


{-| -}
suggestionWithHref : String -> SuggestionBuilder { a | href : Available } slotCaps msg kind -> SuggestionBuilder { a | href : Used } slotCaps msg kind
suggestionWithHref value_ =
    B.withAttribute (A.href value_)


{-| -}
suggestionWithName : String -> SuggestionBuilder { a | name : Available } slotCaps msg kind -> SuggestionBuilder { a | name : Used } slotCaps msg kind
suggestionWithName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| -}
suggestionWithRel : String -> SuggestionBuilder { a | rel : Available } slotCaps msg kind -> SuggestionBuilder { a | rel : Used } slotCaps msg kind
suggestionWithRel value_ =
    B.withAttribute (A.rel value_)


{-| -}
suggestionWithTarget : String -> SuggestionBuilder { a | target : Available } slotCaps msg kind -> SuggestionBuilder { a | target : Used } slotCaps msg kind
suggestionWithTarget value_ =
    B.withAttribute (A.target value_)


{-| -}
suggestionWithType : Value Component.SuggestionType -> SuggestionBuilder { a | type_ : Available } slotCaps msg kind -> SuggestionBuilder { a | type_ : Used } slotCaps msg kind
suggestionWithType value_ =
    B.withAttribute (Component.suggestionType_ value_)


{-| -}
suggestionWithValue : String -> SuggestionBuilder { a | value : Available } slotCaps msg kind -> SuggestionBuilder { a | value : Used } slotCaps msg kind
suggestionWithValue value_ =
    B.withAttribute (A.value value_)


{-| -}
suggestionWithVariant : Value Component.SuggestionVariant -> SuggestionBuilder { a | variant : Available } slotCaps msg kind -> SuggestionBuilder { a | variant : Used } slotCaps msg kind
suggestionWithVariant value_ =
    B.withAttribute (Component.suggestionVariant value_)


{-| -}
suggestionWithOnClick : msg -> SuggestionBuilder { a | onClick : Available } slotCaps msg kind -> SuggestionBuilder { a | onClick : Used } slotCaps msg kind
suggestionWithOnClick value_ =
    B.withAttribute (Ev.onClick value_)


{-| -}
type alias SetIs s =
    Component.SetIs s


{-| -}
type alias SetBuilder attrCaps slotCaps msg kind =
    Component.SetBuilder attrCaps slotCaps msg kind


{-| -}
type alias SetAttrCaps =
    Component.SetAttrCaps


{-| -}
type alias SetSlotCaps =
    Component.SetSlotCaps


{-| -}
type alias SetChildAdmittedBy childAdm =
    Component.SetChildAdmittedBy childAdm


{-| -}
type alias SetContent =
    Component.SetContent


{-| -}
setBuild : SetBuilder SetAttrCaps SetSlotCaps msg kind
setBuild =
    B.init "m3e-chip-set" [] []


{-| -}
setToElement : SetBuilder attrCaps slotCaps msg kind -> Element (Component.SetIs kind) admittedBy msg
setToElement =
    B.toElement


{-| -}
setWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> SetBuilder attrCaps slotCaps msg kind
    -> SetBuilder attrCaps slotCaps msg kind
setWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
setWithClass : String -> SetBuilder { a | class : Available } slotCaps msg kind -> SetBuilder { a | class : Used } slotCaps msg kind
setWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
setWithId : String -> SetBuilder { a | id : Available } slotCaps msg kind -> SetBuilder { a | id : Used } slotCaps msg kind
setWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
setWithSlot : String -> SetBuilder { a | slot : Available } slotCaps msg kind -> SetBuilder { a | slot : Used } slotCaps msg kind
setWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
setWithStyle : String -> String -> SetBuilder { a | style : Available } slotCaps msg kind -> SetBuilder { a | style : Used } slotCaps msg kind
setWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
setWithVertical : Bool -> SetBuilder { a | vertical : Available } slotCaps msg kind -> SetBuilder { a | vertical : Used } slotCaps msg kind
setWithVertical value_ =
    B.withAttribute (A.vertical value_)


{-| -}
type alias FilterSetIs s =
    Component.FilterSetIs s


{-| -}
type alias FilterSetBuilder attrCaps slotCaps msg kind =
    Component.FilterSetBuilder attrCaps slotCaps msg kind


{-| -}
type alias FilterSetAttrCaps =
    Component.FilterSetAttrCaps


{-| -}
type alias FilterSetSlotCaps =
    Component.FilterSetSlotCaps


{-| -}
type alias FilterSetChildAdmittedBy childAdm =
    Component.FilterSetChildAdmittedBy childAdm


{-| -}
type alias FilterSetContent =
    Component.FilterSetContent


{-| -}
filterSetBuild : FilterSetBuilder FilterSetAttrCaps FilterSetSlotCaps msg kind
filterSetBuild =
    B.init "m3e-filter-chip-set" [] []


{-| -}
filterSetToElement : FilterSetBuilder attrCaps slotCaps msg kind -> Element (Component.FilterSetIs kind) admittedBy msg
filterSetToElement =
    B.toElement


{-| -}
filterSetWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> FilterSetBuilder attrCaps slotCaps msg kind
    -> FilterSetBuilder attrCaps slotCaps msg kind
filterSetWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
filterSetWithClass : String -> FilterSetBuilder { a | class : Available } slotCaps msg kind -> FilterSetBuilder { a | class : Used } slotCaps msg kind
filterSetWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
filterSetWithId : String -> FilterSetBuilder { a | id : Available } slotCaps msg kind -> FilterSetBuilder { a | id : Used } slotCaps msg kind
filterSetWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
filterSetWithSlot : String -> FilterSetBuilder { a | slot : Available } slotCaps msg kind -> FilterSetBuilder { a | slot : Used } slotCaps msg kind
filterSetWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
filterSetWithStyle : String -> String -> FilterSetBuilder { a | style : Available } slotCaps msg kind -> FilterSetBuilder { a | style : Used } slotCaps msg kind
filterSetWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
filterSetWithDisabled : Bool -> FilterSetBuilder { a | disabled : Available } slotCaps msg kind -> FilterSetBuilder { a | disabled : Used } slotCaps msg kind
filterSetWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
filterSetWithHideSelectionIndicator : Bool -> FilterSetBuilder { a | hideSelectionIndicator : Available } slotCaps msg kind -> FilterSetBuilder { a | hideSelectionIndicator : Used } slotCaps msg kind
filterSetWithHideSelectionIndicator value_ =
    B.withAttribute (A.hideSelectionIndicator value_)


{-| -}
filterSetWithMulti : Bool -> FilterSetBuilder { a | multi : Available } slotCaps msg kind -> FilterSetBuilder { a | multi : Used } slotCaps msg kind
filterSetWithMulti value_ =
    B.withAttribute (A.multi value_)


{-| -}
filterSetWithName : String -> FilterSetBuilder { a | name : Available } slotCaps msg kind -> FilterSetBuilder { a | name : Used } slotCaps msg kind
filterSetWithName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| -}
filterSetWithVertical : Bool -> FilterSetBuilder { a | vertical : Available } slotCaps msg kind -> FilterSetBuilder { a | vertical : Used } slotCaps msg kind
filterSetWithVertical value_ =
    B.withAttribute (A.vertical value_)


{-| -}
filterSetWithOnChange : msg -> FilterSetBuilder { a | onChange : Available } slotCaps msg kind -> FilterSetBuilder { a | onChange : Used } slotCaps msg kind
filterSetWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)


{-| -}
filterSetWithOnBeforeinput : msg -> FilterSetBuilder { a | onBeforeinput : Available } slotCaps msg kind -> FilterSetBuilder { a | onBeforeinput : Used } slotCaps msg kind
filterSetWithOnBeforeinput value_ =
    B.withAttribute (Ev.onBeforeinput value_)


{-| -}
filterSetWithOnInput : msg -> FilterSetBuilder { a | onInput : Available } slotCaps msg kind -> FilterSetBuilder { a | onInput : Used } slotCaps msg kind
filterSetWithOnInput value_ =
    B.withAttribute (Ev.onInput value_)


{-| -}
type alias InputSetIs s =
    Component.InputSetIs s


{-| -}
type alias InputSetBuilder attrCaps slotCaps msg kind =
    Component.InputSetBuilder attrCaps slotCaps msg kind


{-| -}
type alias InputSetAttrCaps =
    Component.InputSetAttrCaps


{-| -}
type alias InputSetSlotCaps =
    Component.InputSetSlotCaps


{-| -}
type alias InputSetChildAdmittedBy childAdm =
    Component.InputSetChildAdmittedBy childAdm


{-| -}
type alias InputSetContent =
    Component.InputSetContent


{-| -}
inputSetBuild : InputSetBuilder InputSetAttrCaps InputSetSlotCaps msg kind
inputSetBuild =
    B.init "m3e-input-chip-set" [] []


{-| -}
inputSetToElement : InputSetBuilder attrCaps slotCaps msg kind -> Element (Component.InputSetIs kind) admittedBy msg
inputSetToElement =
    B.toElement


{-| -}
inputSetInput :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> Element free freeAdmittedBy msg
inputSetInput builder =
    Component.inputSetInput (B.toElement builder)


{-| -}
inputSetWithInput :
    B.Builder childRow childAttrCaps childSlotCaps childAccepts msg
    -> InputSetBuilder attrCaps { s | input : Available } msg kind
    -> InputSetBuilder attrCaps { s | input : Used } msg kind
inputSetWithInput slotBuilder builder_ =
    B.withChild (El.toNode (Component.inputSetInput (B.toElement slotBuilder))) builder_


{-| -}
inputSetWithChild :
    B.Builder childRow childAttrCaps childSlotCaps accepts msg
    -> InputSetBuilder attrCaps slotCaps msg kind
    -> InputSetBuilder attrCaps slotCaps msg kind
inputSetWithChild childBuilder builder_ =
    B.withChild (El.toNode (B.toElement childBuilder)) builder_


{-| -}
inputSetWithClass : String -> InputSetBuilder { a | class : Available } slotCaps msg kind -> InputSetBuilder { a | class : Used } slotCaps msg kind
inputSetWithClass value_ =
    B.withAttribute (A.class value_)


{-| -}
inputSetWithId : String -> InputSetBuilder { a | id : Available } slotCaps msg kind -> InputSetBuilder { a | id : Used } slotCaps msg kind
inputSetWithId value_ =
    B.withAttribute (A.id value_)


{-| -}
inputSetWithSlot : String -> InputSetBuilder { a | slot : Available } slotCaps msg kind -> InputSetBuilder { a | slot : Used } slotCaps msg kind
inputSetWithSlot value_ =
    B.withAttribute (A.slot value_)


{-| -}
inputSetWithStyle : String -> String -> InputSetBuilder { a | style : Available } slotCaps msg kind -> InputSetBuilder { a | style : Used } slotCaps msg kind
inputSetWithStyle property value_ =
    B.withAttribute (A.style property value_)


{-| -}
inputSetWithDisabled : Bool -> InputSetBuilder { a | disabled : Available } slotCaps msg kind -> InputSetBuilder { a | disabled : Used } slotCaps msg kind
inputSetWithDisabled value_ =
    B.withAttribute (A.disabled value_)


{-| -}
inputSetWithMaxChips : Float -> InputSetBuilder { a | maxChips : Available } slotCaps msg kind -> InputSetBuilder { a | maxChips : Used } slotCaps msg kind
inputSetWithMaxChips value_ =
    B.withAttribute (A.maxChips value_)


{-| -}
inputSetWithName : String -> InputSetBuilder { a | name : Available } slotCaps msg kind -> InputSetBuilder { a | name : Used } slotCaps msg kind
inputSetWithName value_ =
    B.withAttribute (Ir.attribute "name" value_)


{-| -}
inputSetWithRequired : Bool -> InputSetBuilder { a | required : Available } slotCaps msg kind -> InputSetBuilder { a | required : Used } slotCaps msg kind
inputSetWithRequired value_ =
    B.withAttribute (A.required value_)


{-| -}
inputSetWithValidationmessages : String -> InputSetBuilder { a | validationmessages : Available } slotCaps msg kind -> InputSetBuilder { a | validationmessages : Used } slotCaps msg kind
inputSetWithValidationmessages value_ =
    B.withAttribute (A.validationmessages value_)


{-| -}
inputSetWithVertical : Bool -> InputSetBuilder { a | vertical : Available } slotCaps msg kind -> InputSetBuilder { a | vertical : Used } slotCaps msg kind
inputSetWithVertical value_ =
    B.withAttribute (A.vertical value_)


{-| -}
inputSetWithOnChange : msg -> InputSetBuilder { a | onChange : Available } slotCaps msg kind -> InputSetBuilder { a | onChange : Used } slotCaps msg kind
inputSetWithOnChange value_ =
    B.withAttribute (Ev.onChange value_)
