module M3e.Family.Chip exposing (ChipIs, ChipAttrs, ChipBuilder, ChipAttrCaps, ChipSlotCaps, ChipContent, ChipIconSlot, ChipTrailingIconSlot, ChipChildAdmittedBy, ChipVariant, AssistIs, AssistAttrs, AssistBuilder, AssistAttrCaps, AssistSlotCaps, AssistContent, AssistIconSlot, AssistChildAdmittedBy, AssistType, AssistVariant, FilterIs, FilterAttrs, FilterBuilder, FilterAttrCaps, FilterSlotCaps, FilterContent, FilterIconSlot, FilterTrailingIconSlot, FilterChildAdmittedBy, FilterVariant, InputIs, InputAttrs, InputBuilder, InputAttrCaps, InputSlotCaps, InputContent, InputAvatarSlot, InputIconSlot, InputRemoveIconSlot, InputChildAdmittedBy, InputVariant, SuggestionIs, SuggestionAttrs, SuggestionBuilder, SuggestionAttrCaps, SuggestionSlotCaps, SuggestionContent, SuggestionIconSlot, SuggestionChildAdmittedBy, SuggestionActionCaps, SuggestionType, SuggestionVariant, SetIs, SetAttrs, SetBuilder, SetAttrCaps, SetSlotCaps, SetContent, SetChildAdmittedBy, FilterSetIs, FilterSetAttrs, FilterSetBuilder, FilterSetAttrCaps, FilterSetSlotCaps, FilterSetContent, FilterSetChildAdmittedBy, InputSetIs, InputSetAttrs, InputSetBuilder, InputSetAttrCaps, InputSetSlotCaps, InputSetContent, InputSetChildAdmittedBy, chip, chipVariant, chipValue, chipDefaultValue, chipIcon, chipTrailingIcon, chipChild, assist, assistType_, assistVariant, assistDisabled, assistDisabledInteractive, assistDownload, assistHref, assistName, assistRel, assistTarget, assistValue, assistDefaultValue, assistOnClick, assistIcon, assistChild, filter, filterVariant, filterDisabled, filterDisabledInteractive, filterSelected, filterValue, filterDefaultSelected, filterDefaultValue, filterOnBeforeinput, filterOnInput, filterOnChange, filterOnClick, filterIcon, filterTrailingIcon, filterChild, input, inputVariant, inputDisabled, inputDisabledInteractive, inputRemovable, inputRemoveLabel, inputValue, inputDefaultValue, inputOnRemove, inputOnClick, inputAvatar, inputIcon, inputRemoveIcon, inputChild, suggestion, suggestionType_, suggestionVariant, suggestionDisabled, suggestionDisabledInteractive, suggestionDownload, suggestionHref, suggestionName, suggestionRel, suggestionTarget, suggestionValue, suggestionDefaultValue, suggestionOnClick, suggestionIcon, suggestionChild, set, setVertical, setChild, filterSet, filterSetDisabled, filterSetHideSelectionIndicator, filterSetMulti, filterSetName, filterSetVertical, filterSetOnChange, filterSetOnBeforeinput, filterSetOnInput, filterSetChild, inputSet, inputSetDisabled, inputSetName, inputSetRequired, inputSetValidationmessages, inputSetVertical, inputSetOnChange, inputSetInput, inputSetChild)

{-| The **Chip** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Component.Chip`](M3e.Component.Chip) as `chip`, [`M3e.Component.AssistChip`](M3e.Component.AssistChip) as `assist`, [`M3e.Component.FilterChip`](M3e.Component.FilterChip) as `filter`, [`M3e.Component.InputChip`](M3e.Component.InputChip) as `input`, [`M3e.Component.SuggestionChip`](M3e.Component.SuggestionChip) as `suggestion`, [`M3e.Component.ChipSet`](M3e.Component.ChipSet) as `set`, [`M3e.Component.FilterChipSet`](M3e.Component.FilterChipSet) as `filterSet`, [`M3e.Component.InputChipSet`](M3e.Component.InputChipSet) as `inputSet`.

Prefer whichever import reads best — the flat `M3e.Component.*` modules and
this family module are the same elements, same types.

@docs ChipIs, ChipAttrs, ChipBuilder, ChipAttrCaps, ChipSlotCaps, ChipContent, ChipIconSlot, ChipTrailingIconSlot, ChipChildAdmittedBy, ChipVariant, AssistIs, AssistAttrs, AssistBuilder, AssistAttrCaps, AssistSlotCaps, AssistContent, AssistIconSlot, AssistChildAdmittedBy, AssistType, AssistVariant, FilterIs, FilterAttrs, FilterBuilder, FilterAttrCaps, FilterSlotCaps, FilterContent, FilterIconSlot, FilterTrailingIconSlot, FilterChildAdmittedBy, FilterVariant, InputIs, InputAttrs, InputBuilder, InputAttrCaps, InputSlotCaps, InputContent, InputAvatarSlot, InputIconSlot, InputRemoveIconSlot, InputChildAdmittedBy, InputVariant, SuggestionIs, SuggestionAttrs, SuggestionBuilder, SuggestionAttrCaps, SuggestionSlotCaps, SuggestionContent, SuggestionIconSlot, SuggestionChildAdmittedBy, SuggestionActionCaps, SuggestionType, SuggestionVariant, SetIs, SetAttrs, SetBuilder, SetAttrCaps, SetSlotCaps, SetContent, SetChildAdmittedBy, FilterSetIs, FilterSetAttrs, FilterSetBuilder, FilterSetAttrCaps, FilterSetSlotCaps, FilterSetContent, FilterSetChildAdmittedBy, InputSetIs, InputSetAttrs, InputSetBuilder, InputSetAttrCaps, InputSetSlotCaps, InputSetContent, InputSetChildAdmittedBy, chip, chipVariant, chipValue, chipDefaultValue, chipIcon, chipTrailingIcon, chipChild, assist, assistType_, assistVariant, assistDisabled, assistDisabledInteractive, assistDownload, assistHref, assistName, assistRel, assistTarget, assistValue, assistDefaultValue, assistOnClick, assistIcon, assistChild, filter, filterVariant, filterDisabled, filterDisabledInteractive, filterSelected, filterValue, filterDefaultSelected, filterDefaultValue, filterOnBeforeinput, filterOnInput, filterOnChange, filterOnClick, filterIcon, filterTrailingIcon, filterChild, input, inputVariant, inputDisabled, inputDisabledInteractive, inputRemovable, inputRemoveLabel, inputValue, inputDefaultValue, inputOnRemove, inputOnClick, inputAvatar, inputIcon, inputRemoveIcon, inputChild, suggestion, suggestionType_, suggestionVariant, suggestionDisabled, suggestionDisabledInteractive, suggestionDownload, suggestionHref, suggestionName, suggestionRel, suggestionTarget, suggestionValue, suggestionDefaultValue, suggestionOnClick, suggestionIcon, suggestionChild, set, setVertical, setChild, filterSet, filterSetDisabled, filterSetHideSelectionIndicator, filterSetMulti, filterSetName, filterSetVertical, filterSetOnChange, filterSetOnBeforeinput, filterSetOnInput, filterSetChild, inputSet, inputSetDisabled, inputSetName, inputSetRequired, inputSetValidationmessages, inputSetVertical, inputSetOnChange, inputSetInput, inputSetChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Action as Ac
import M3e.Component.AssistChip as Assist_
import M3e.Component.Chip as Chip_
import M3e.Component.ChipSet as Set_
import M3e.Component.FilterChip as Filter_
import M3e.Component.FilterChipSet as FilterSet_
import M3e.Component.InputChip as Input_
import M3e.Component.InputChipSet as InputSet_
import M3e.Component.SuggestionChip as Suggestion_


{-| The `chip` element of this family — delegates to [`M3e.Component.Chip.component`](M3e.Component.Chip#component).
-}
chip :
    { content : Element ChipContent (ChipChildAdmittedBy childAdm) msg }
    -> List (Attr ChipAttrs msg)
    -> List (Element ChipContent (ChipChildAdmittedBy childAdm) msg)
    -> Element (ChipIs s) admittedBy msg
chip =
    Chip_.component


{-| See [`M3e.Component.Chip.Is`](M3e.Component.Chip#Is).
-}
type alias ChipIs s =
    Chip_.Is s


{-| See [`M3e.Component.Chip.Attrs`](M3e.Component.Chip#Attrs).
-}
type alias ChipAttrs =
    Chip_.Attrs


{-| See [`M3e.Component.Chip.Builder`](M3e.Component.Chip#Builder).
-}
type alias ChipBuilder attrCaps slotCaps msg kind =
    Chip_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.Chip.AttrCaps`](M3e.Component.Chip#AttrCaps).
-}
type alias ChipAttrCaps =
    Chip_.AttrCaps


{-| See [`M3e.Component.Chip.SlotCaps`](M3e.Component.Chip#SlotCaps).
-}
type alias ChipSlotCaps =
    Chip_.SlotCaps


{-| See [`M3e.Component.Chip.Content`](M3e.Component.Chip#Content).
-}
type alias ChipContent =
    Chip_.Content


{-| See [`M3e.Component.Chip.IconSlot`](M3e.Component.Chip#IconSlot).
-}
type alias ChipIconSlot =
    Chip_.IconSlot


{-| See [`M3e.Component.Chip.TrailingIconSlot`](M3e.Component.Chip#TrailingIconSlot).
-}
type alias ChipTrailingIconSlot =
    Chip_.TrailingIconSlot


{-| See [`M3e.Component.Chip.ChildAdmittedBy`](M3e.Component.Chip#ChildAdmittedBy).
-}
type alias ChipChildAdmittedBy childAdm =
    Chip_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.Chip.Variant`](M3e.Component.Chip#Variant).
-}
type alias ChipVariant =
    Chip_.Variant


{-| See [`M3e.Component.Chip.variant`](M3e.Component.Chip#variant).
-}
chipVariant : Value ChipVariant -> Attr { c | variant : Supported } msg
chipVariant =
    Chip_.variant


{-| See [`M3e.Component.Chip.value`](M3e.Component.Chip#value).
-}
chipValue : String -> Attr { c | value : Supported } msg
chipValue =
    Chip_.value


{-| See [`M3e.Component.Chip.defaultValue`](M3e.Component.Chip#defaultValue).
-}
chipDefaultValue : String -> Attr { c | value : Supported } msg
chipDefaultValue =
    Chip_.defaultValue


{-| See [`M3e.Component.Chip.icon`](M3e.Component.Chip#icon).
-}
chipIcon : Element ChipIconSlot admittedBy msg -> Element free freeAdmittedBy msg
chipIcon =
    Chip_.icon


{-| See [`M3e.Component.Chip.trailingIcon`](M3e.Component.Chip#trailingIcon).
-}
chipTrailingIcon : Element ChipTrailingIconSlot admittedBy msg -> Element free freeAdmittedBy msg
chipTrailingIcon =
    Chip_.trailingIcon


{-| See [`M3e.Component.Chip.child`](M3e.Component.Chip#child).
-}
chipChild : Element ChipContent admittedBy msg -> Element free freeAdmittedBy msg
chipChild =
    Chip_.child


{-| The `assist` element of this family — delegates to [`M3e.Component.AssistChip.component`](M3e.Component.AssistChip#component).
-}
assist :
    { content : Element AssistContent (AssistChildAdmittedBy childAdm) msg }
    -> List (Attr AssistAttrs msg)
    -> List (Element AssistContent (AssistChildAdmittedBy childAdm) msg)
    -> Element (AssistIs s) admittedBy msg
assist =
    Assist_.component


{-| See [`M3e.Component.AssistChip.Is`](M3e.Component.AssistChip#Is).
-}
type alias AssistIs s =
    Assist_.Is s


{-| See [`M3e.Component.AssistChip.Attrs`](M3e.Component.AssistChip#Attrs).
-}
type alias AssistAttrs =
    Assist_.Attrs


{-| See [`M3e.Component.AssistChip.Builder`](M3e.Component.AssistChip#Builder).
-}
type alias AssistBuilder attrCaps slotCaps msg kind =
    Assist_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.AssistChip.AttrCaps`](M3e.Component.AssistChip#AttrCaps).
-}
type alias AssistAttrCaps =
    Assist_.AttrCaps


{-| See [`M3e.Component.AssistChip.SlotCaps`](M3e.Component.AssistChip#SlotCaps).
-}
type alias AssistSlotCaps =
    Assist_.SlotCaps


{-| See [`M3e.Component.AssistChip.Content`](M3e.Component.AssistChip#Content).
-}
type alias AssistContent =
    Assist_.Content


{-| See [`M3e.Component.AssistChip.IconSlot`](M3e.Component.AssistChip#IconSlot).
-}
type alias AssistIconSlot =
    Assist_.IconSlot


{-| See [`M3e.Component.AssistChip.ChildAdmittedBy`](M3e.Component.AssistChip#ChildAdmittedBy).
-}
type alias AssistChildAdmittedBy childAdm =
    Assist_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.AssistChip.Type`](M3e.Component.AssistChip#Type).
-}
type alias AssistType =
    Assist_.Type


{-| See [`M3e.Component.AssistChip.type_`](M3e.Component.AssistChip#type_).
-}
assistType_ : Value AssistType -> Attr { c | type_ : Supported } msg
assistType_ =
    Assist_.type_


{-| See [`M3e.Component.AssistChip.Variant`](M3e.Component.AssistChip#Variant).
-}
type alias AssistVariant =
    Assist_.Variant


{-| See [`M3e.Component.AssistChip.variant`](M3e.Component.AssistChip#variant).
-}
assistVariant : Value AssistVariant -> Attr { c | variant : Supported } msg
assistVariant =
    Assist_.variant


{-| See [`M3e.Component.AssistChip.disabled`](M3e.Component.AssistChip#disabled).
-}
assistDisabled : Bool -> Attr { c | disabled : Supported } msg
assistDisabled =
    Assist_.disabled


{-| See [`M3e.Component.AssistChip.disabledInteractive`](M3e.Component.AssistChip#disabledInteractive).
-}
assistDisabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
assistDisabledInteractive =
    Assist_.disabledInteractive


{-| See [`M3e.Component.AssistChip.download`](M3e.Component.AssistChip#download).
-}
assistDownload : String -> Attr { c | download : Supported } msg
assistDownload =
    Assist_.download


{-| See [`M3e.Component.AssistChip.href`](M3e.Component.AssistChip#href).
-}
assistHref : String -> Attr { c | href : Supported } msg
assistHref =
    Assist_.href


{-| See [`M3e.Component.AssistChip.name`](M3e.Component.AssistChip#name).
-}
assistName : String -> Attr { c | name : Supported } msg
assistName =
    Assist_.name


{-| See [`M3e.Component.AssistChip.rel`](M3e.Component.AssistChip#rel).
-}
assistRel : String -> Attr { c | rel : Supported } msg
assistRel =
    Assist_.rel


{-| See [`M3e.Component.AssistChip.target`](M3e.Component.AssistChip#target).
-}
assistTarget : String -> Attr { c | target : Supported } msg
assistTarget =
    Assist_.target


{-| See [`M3e.Component.AssistChip.value`](M3e.Component.AssistChip#value).
-}
assistValue : String -> Attr { c | value : Supported } msg
assistValue =
    Assist_.value


{-| See [`M3e.Component.AssistChip.defaultValue`](M3e.Component.AssistChip#defaultValue).
-}
assistDefaultValue : String -> Attr { c | value : Supported } msg
assistDefaultValue =
    Assist_.defaultValue


{-| See [`M3e.Component.AssistChip.onClick`](M3e.Component.AssistChip#onClick).
-}
assistOnClick : msg -> Attr { c | onClick : Supported } msg
assistOnClick =
    Assist_.onClick


{-| See [`M3e.Component.AssistChip.icon`](M3e.Component.AssistChip#icon).
-}
assistIcon : Element AssistIconSlot admittedBy msg -> Element free freeAdmittedBy msg
assistIcon =
    Assist_.icon


{-| See [`M3e.Component.AssistChip.child`](M3e.Component.AssistChip#child).
-}
assistChild : Element AssistContent admittedBy msg -> Element free freeAdmittedBy msg
assistChild =
    Assist_.child


{-| The `filter` element of this family — delegates to [`M3e.Component.FilterChip.component`](M3e.Component.FilterChip#component).
-}
filter :
    { content : Element FilterContent (FilterChildAdmittedBy childAdm) msg }
    -> List (Attr FilterAttrs msg)
    -> List (Element FilterContent (FilterChildAdmittedBy childAdm) msg)
    -> Element (FilterIs s) admittedBy msg
filter =
    Filter_.component


{-| See [`M3e.Component.FilterChip.Is`](M3e.Component.FilterChip#Is).
-}
type alias FilterIs s =
    Filter_.Is s


{-| See [`M3e.Component.FilterChip.Attrs`](M3e.Component.FilterChip#Attrs).
-}
type alias FilterAttrs =
    Filter_.Attrs


{-| See [`M3e.Component.FilterChip.Builder`](M3e.Component.FilterChip#Builder).
-}
type alias FilterBuilder attrCaps slotCaps msg kind =
    Filter_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.FilterChip.AttrCaps`](M3e.Component.FilterChip#AttrCaps).
-}
type alias FilterAttrCaps =
    Filter_.AttrCaps


{-| See [`M3e.Component.FilterChip.SlotCaps`](M3e.Component.FilterChip#SlotCaps).
-}
type alias FilterSlotCaps =
    Filter_.SlotCaps


{-| See [`M3e.Component.FilterChip.Content`](M3e.Component.FilterChip#Content).
-}
type alias FilterContent =
    Filter_.Content


{-| See [`M3e.Component.FilterChip.IconSlot`](M3e.Component.FilterChip#IconSlot).
-}
type alias FilterIconSlot =
    Filter_.IconSlot


{-| See [`M3e.Component.FilterChip.TrailingIconSlot`](M3e.Component.FilterChip#TrailingIconSlot).
-}
type alias FilterTrailingIconSlot =
    Filter_.TrailingIconSlot


{-| See [`M3e.Component.FilterChip.ChildAdmittedBy`](M3e.Component.FilterChip#ChildAdmittedBy).
-}
type alias FilterChildAdmittedBy childAdm =
    Filter_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.FilterChip.Variant`](M3e.Component.FilterChip#Variant).
-}
type alias FilterVariant =
    Filter_.Variant


{-| See [`M3e.Component.FilterChip.variant`](M3e.Component.FilterChip#variant).
-}
filterVariant : Value FilterVariant -> Attr { c | variant : Supported } msg
filterVariant =
    Filter_.variant


{-| See [`M3e.Component.FilterChip.disabled`](M3e.Component.FilterChip#disabled).
-}
filterDisabled : Bool -> Attr { c | disabled : Supported } msg
filterDisabled =
    Filter_.disabled


{-| See [`M3e.Component.FilterChip.disabledInteractive`](M3e.Component.FilterChip#disabledInteractive).
-}
filterDisabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
filterDisabledInteractive =
    Filter_.disabledInteractive


{-| See [`M3e.Component.FilterChip.selected`](M3e.Component.FilterChip#selected).
-}
filterSelected : Bool -> Attr { c | selected : Supported } msg
filterSelected =
    Filter_.selected


{-| See [`M3e.Component.FilterChip.value`](M3e.Component.FilterChip#value).
-}
filterValue : String -> Attr { c | value : Supported } msg
filterValue =
    Filter_.value


{-| See [`M3e.Component.FilterChip.defaultSelected`](M3e.Component.FilterChip#defaultSelected).
-}
filterDefaultSelected : Bool -> Attr { c | selected : Supported } msg
filterDefaultSelected =
    Filter_.defaultSelected


{-| See [`M3e.Component.FilterChip.defaultValue`](M3e.Component.FilterChip#defaultValue).
-}
filterDefaultValue : String -> Attr { c | value : Supported } msg
filterDefaultValue =
    Filter_.defaultValue


{-| See [`M3e.Component.FilterChip.onBeforeinput`](M3e.Component.FilterChip#onBeforeinput).
-}
filterOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
filterOnBeforeinput =
    Filter_.onBeforeinput


{-| See [`M3e.Component.FilterChip.onInput`](M3e.Component.FilterChip#onInput).
-}
filterOnInput : msg -> Attr { c | onInput : Supported } msg
filterOnInput =
    Filter_.onInput


{-| See [`M3e.Component.FilterChip.onChange`](M3e.Component.FilterChip#onChange).
-}
filterOnChange : msg -> Attr { c | onChange : Supported } msg
filterOnChange =
    Filter_.onChange


{-| See [`M3e.Component.FilterChip.onClick`](M3e.Component.FilterChip#onClick).
-}
filterOnClick : msg -> Attr { c | onClick : Supported } msg
filterOnClick =
    Filter_.onClick


{-| See [`M3e.Component.FilterChip.icon`](M3e.Component.FilterChip#icon).
-}
filterIcon : Element FilterIconSlot admittedBy msg -> Element free freeAdmittedBy msg
filterIcon =
    Filter_.icon


{-| See [`M3e.Component.FilterChip.trailingIcon`](M3e.Component.FilterChip#trailingIcon).
-}
filterTrailingIcon : Element FilterTrailingIconSlot admittedBy msg -> Element free freeAdmittedBy msg
filterTrailingIcon =
    Filter_.trailingIcon


{-| See [`M3e.Component.FilterChip.child`](M3e.Component.FilterChip#child).
-}
filterChild : Element FilterContent admittedBy msg -> Element free freeAdmittedBy msg
filterChild =
    Filter_.child


{-| The `input` element of this family — delegates to [`M3e.Component.InputChip.component`](M3e.Component.InputChip#component).
-}
input :
    { content : Element InputContent (InputChildAdmittedBy childAdm) msg }
    -> List (Attr InputAttrs msg)
    -> List (Element InputContent (InputChildAdmittedBy childAdm) msg)
    -> Element (InputIs s) admittedBy msg
input =
    Input_.component


{-| See [`M3e.Component.InputChip.Is`](M3e.Component.InputChip#Is).
-}
type alias InputIs s =
    Input_.Is s


{-| See [`M3e.Component.InputChip.Attrs`](M3e.Component.InputChip#Attrs).
-}
type alias InputAttrs =
    Input_.Attrs


{-| See [`M3e.Component.InputChip.Builder`](M3e.Component.InputChip#Builder).
-}
type alias InputBuilder attrCaps slotCaps msg kind =
    Input_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.InputChip.AttrCaps`](M3e.Component.InputChip#AttrCaps).
-}
type alias InputAttrCaps =
    Input_.AttrCaps


{-| See [`M3e.Component.InputChip.SlotCaps`](M3e.Component.InputChip#SlotCaps).
-}
type alias InputSlotCaps =
    Input_.SlotCaps


{-| See [`M3e.Component.InputChip.Content`](M3e.Component.InputChip#Content).
-}
type alias InputContent =
    Input_.Content


{-| See [`M3e.Component.InputChip.AvatarSlot`](M3e.Component.InputChip#AvatarSlot).
-}
type alias InputAvatarSlot =
    Input_.AvatarSlot


{-| See [`M3e.Component.InputChip.IconSlot`](M3e.Component.InputChip#IconSlot).
-}
type alias InputIconSlot =
    Input_.IconSlot


{-| See [`M3e.Component.InputChip.RemoveIconSlot`](M3e.Component.InputChip#RemoveIconSlot).
-}
type alias InputRemoveIconSlot =
    Input_.RemoveIconSlot


{-| See [`M3e.Component.InputChip.ChildAdmittedBy`](M3e.Component.InputChip#ChildAdmittedBy).
-}
type alias InputChildAdmittedBy childAdm =
    Input_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.InputChip.Variant`](M3e.Component.InputChip#Variant).
-}
type alias InputVariant =
    Input_.Variant


{-| See [`M3e.Component.InputChip.variant`](M3e.Component.InputChip#variant).
-}
inputVariant : Value InputVariant -> Attr { c | variant : Supported } msg
inputVariant =
    Input_.variant


{-| See [`M3e.Component.InputChip.disabled`](M3e.Component.InputChip#disabled).
-}
inputDisabled : Bool -> Attr { c | disabled : Supported } msg
inputDisabled =
    Input_.disabled


{-| See [`M3e.Component.InputChip.disabledInteractive`](M3e.Component.InputChip#disabledInteractive).
-}
inputDisabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
inputDisabledInteractive =
    Input_.disabledInteractive


{-| See [`M3e.Component.InputChip.removable`](M3e.Component.InputChip#removable).
-}
inputRemovable : Bool -> Attr { c | removable : Supported } msg
inputRemovable =
    Input_.removable


{-| See [`M3e.Component.InputChip.removeLabel`](M3e.Component.InputChip#removeLabel).
-}
inputRemoveLabel : String -> Attr { c | removeLabel : Supported } msg
inputRemoveLabel =
    Input_.removeLabel


{-| See [`M3e.Component.InputChip.value`](M3e.Component.InputChip#value).
-}
inputValue : String -> Attr { c | value : Supported } msg
inputValue =
    Input_.value


{-| See [`M3e.Component.InputChip.defaultValue`](M3e.Component.InputChip#defaultValue).
-}
inputDefaultValue : String -> Attr { c | value : Supported } msg
inputDefaultValue =
    Input_.defaultValue


{-| See [`M3e.Component.InputChip.onRemove`](M3e.Component.InputChip#onRemove).
-}
inputOnRemove : msg -> Attr { c | onRemove : Supported } msg
inputOnRemove =
    Input_.onRemove


{-| See [`M3e.Component.InputChip.onClick`](M3e.Component.InputChip#onClick).
-}
inputOnClick : msg -> Attr { c | onClick : Supported } msg
inputOnClick =
    Input_.onClick


{-| See [`M3e.Component.InputChip.avatar`](M3e.Component.InputChip#avatar).
-}
inputAvatar : Element InputAvatarSlot admittedBy msg -> Element free freeAdmittedBy msg
inputAvatar =
    Input_.avatar


{-| See [`M3e.Component.InputChip.icon`](M3e.Component.InputChip#icon).
-}
inputIcon : Element InputIconSlot admittedBy msg -> Element free freeAdmittedBy msg
inputIcon =
    Input_.icon


{-| See [`M3e.Component.InputChip.removeIcon`](M3e.Component.InputChip#removeIcon).
-}
inputRemoveIcon : Element InputRemoveIconSlot admittedBy msg -> Element free freeAdmittedBy msg
inputRemoveIcon =
    Input_.removeIcon


{-| See [`M3e.Component.InputChip.child`](M3e.Component.InputChip#child).
-}
inputChild : Element InputContent admittedBy msg -> Element free freeAdmittedBy msg
inputChild =
    Input_.child


{-| The `suggestion` element of this family — delegates to [`M3e.Component.SuggestionChip.component`](M3e.Component.SuggestionChip#component).
-}
suggestion :
    { content : Element SuggestionContent (SuggestionChildAdmittedBy childAdm) msg
    , action : Ac.Action SuggestionActionCaps msg
    }
    -> List (Attr SuggestionAttrs msg)
    -> List (Element SuggestionContent (SuggestionChildAdmittedBy childAdm) msg)
    -> Element (SuggestionIs s) admittedBy msg
suggestion =
    Suggestion_.component


{-| See [`M3e.Component.SuggestionChip.Is`](M3e.Component.SuggestionChip#Is).
-}
type alias SuggestionIs s =
    Suggestion_.Is s


{-| See [`M3e.Component.SuggestionChip.Attrs`](M3e.Component.SuggestionChip#Attrs).
-}
type alias SuggestionAttrs =
    Suggestion_.Attrs


{-| See [`M3e.Component.SuggestionChip.Builder`](M3e.Component.SuggestionChip#Builder).
-}
type alias SuggestionBuilder attrCaps slotCaps msg kind =
    Suggestion_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.SuggestionChip.AttrCaps`](M3e.Component.SuggestionChip#AttrCaps).
-}
type alias SuggestionAttrCaps =
    Suggestion_.AttrCaps


{-| See [`M3e.Component.SuggestionChip.SlotCaps`](M3e.Component.SuggestionChip#SlotCaps).
-}
type alias SuggestionSlotCaps =
    Suggestion_.SlotCaps


{-| See [`M3e.Component.SuggestionChip.Content`](M3e.Component.SuggestionChip#Content).
-}
type alias SuggestionContent =
    Suggestion_.Content


{-| See [`M3e.Component.SuggestionChip.IconSlot`](M3e.Component.SuggestionChip#IconSlot).
-}
type alias SuggestionIconSlot =
    Suggestion_.IconSlot


{-| See [`M3e.Component.SuggestionChip.ChildAdmittedBy`](M3e.Component.SuggestionChip#ChildAdmittedBy).
-}
type alias SuggestionChildAdmittedBy childAdm =
    Suggestion_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.SuggestionChip.ActionCaps`](M3e.Component.SuggestionChip#ActionCaps).
-}
type alias SuggestionActionCaps =
    Suggestion_.ActionCaps


{-| See [`M3e.Component.SuggestionChip.Type`](M3e.Component.SuggestionChip#Type).
-}
type alias SuggestionType =
    Suggestion_.Type


{-| See [`M3e.Component.SuggestionChip.type_`](M3e.Component.SuggestionChip#type_).
-}
suggestionType_ : Value SuggestionType -> Attr { c | type_ : Supported } msg
suggestionType_ =
    Suggestion_.type_


{-| See [`M3e.Component.SuggestionChip.Variant`](M3e.Component.SuggestionChip#Variant).
-}
type alias SuggestionVariant =
    Suggestion_.Variant


{-| See [`M3e.Component.SuggestionChip.variant`](M3e.Component.SuggestionChip#variant).
-}
suggestionVariant : Value SuggestionVariant -> Attr { c | variant : Supported } msg
suggestionVariant =
    Suggestion_.variant


{-| See [`M3e.Component.SuggestionChip.disabled`](M3e.Component.SuggestionChip#disabled).
-}
suggestionDisabled : Bool -> Attr { c | disabled : Supported } msg
suggestionDisabled =
    Suggestion_.disabled


{-| See [`M3e.Component.SuggestionChip.disabledInteractive`](M3e.Component.SuggestionChip#disabledInteractive).
-}
suggestionDisabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
suggestionDisabledInteractive =
    Suggestion_.disabledInteractive


{-| See [`M3e.Component.SuggestionChip.download`](M3e.Component.SuggestionChip#download).
-}
suggestionDownload : String -> Attr { c | download : Supported } msg
suggestionDownload =
    Suggestion_.download


{-| See [`M3e.Component.SuggestionChip.href`](M3e.Component.SuggestionChip#href).
-}
suggestionHref : String -> Attr { c | href : Supported } msg
suggestionHref =
    Suggestion_.href


{-| See [`M3e.Component.SuggestionChip.name`](M3e.Component.SuggestionChip#name).
-}
suggestionName : String -> Attr { c | name : Supported } msg
suggestionName =
    Suggestion_.name


{-| See [`M3e.Component.SuggestionChip.rel`](M3e.Component.SuggestionChip#rel).
-}
suggestionRel : String -> Attr { c | rel : Supported } msg
suggestionRel =
    Suggestion_.rel


{-| See [`M3e.Component.SuggestionChip.target`](M3e.Component.SuggestionChip#target).
-}
suggestionTarget : String -> Attr { c | target : Supported } msg
suggestionTarget =
    Suggestion_.target


{-| See [`M3e.Component.SuggestionChip.value`](M3e.Component.SuggestionChip#value).
-}
suggestionValue : String -> Attr { c | value : Supported } msg
suggestionValue =
    Suggestion_.value


{-| See [`M3e.Component.SuggestionChip.defaultValue`](M3e.Component.SuggestionChip#defaultValue).
-}
suggestionDefaultValue : String -> Attr { c | value : Supported } msg
suggestionDefaultValue =
    Suggestion_.defaultValue


{-| See [`M3e.Component.SuggestionChip.onClick`](M3e.Component.SuggestionChip#onClick).
-}
suggestionOnClick : msg -> Attr { c | onClick : Supported } msg
suggestionOnClick =
    Suggestion_.onClick


{-| See [`M3e.Component.SuggestionChip.icon`](M3e.Component.SuggestionChip#icon).
-}
suggestionIcon : Element SuggestionIconSlot admittedBy msg -> Element free freeAdmittedBy msg
suggestionIcon =
    Suggestion_.icon


{-| See [`M3e.Component.SuggestionChip.child`](M3e.Component.SuggestionChip#child).
-}
suggestionChild : Element SuggestionContent admittedBy msg -> Element free freeAdmittedBy msg
suggestionChild =
    Suggestion_.child


{-| The `set` element of this family — delegates to [`M3e.Component.ChipSet.component`](M3e.Component.ChipSet#component).
-}
set :
    List (Attr SetAttrs msg)
    -> List (Element SetContent (SetChildAdmittedBy childAdm) msg)
    -> Element (SetIs s) admittedBy msg
set =
    Set_.component


{-| See [`M3e.Component.ChipSet.Is`](M3e.Component.ChipSet#Is).
-}
type alias SetIs s =
    Set_.Is s


{-| See [`M3e.Component.ChipSet.Attrs`](M3e.Component.ChipSet#Attrs).
-}
type alias SetAttrs =
    Set_.Attrs


{-| See [`M3e.Component.ChipSet.Builder`](M3e.Component.ChipSet#Builder).
-}
type alias SetBuilder attrCaps slotCaps msg kind =
    Set_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.ChipSet.AttrCaps`](M3e.Component.ChipSet#AttrCaps).
-}
type alias SetAttrCaps =
    Set_.AttrCaps


{-| See [`M3e.Component.ChipSet.SlotCaps`](M3e.Component.ChipSet#SlotCaps).
-}
type alias SetSlotCaps =
    Set_.SlotCaps


{-| See [`M3e.Component.ChipSet.Content`](M3e.Component.ChipSet#Content).
-}
type alias SetContent =
    Set_.Content


{-| See [`M3e.Component.ChipSet.ChildAdmittedBy`](M3e.Component.ChipSet#ChildAdmittedBy).
-}
type alias SetChildAdmittedBy childAdm =
    Set_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.ChipSet.vertical`](M3e.Component.ChipSet#vertical).
-}
setVertical : Bool -> Attr { c | vertical : Supported } msg
setVertical =
    Set_.vertical


{-| See [`M3e.Component.ChipSet.child`](M3e.Component.ChipSet#child).
-}
setChild : Element SetContent admittedBy msg -> Element free freeAdmittedBy msg
setChild =
    Set_.child


{-| The `filterSet` element of this family — delegates to [`M3e.Component.FilterChipSet.component`](M3e.Component.FilterChipSet#component).
-}
filterSet :
    List (Attr FilterSetAttrs msg)
    -> List (Element FilterSetContent (FilterSetChildAdmittedBy childAdm) msg)
    -> Element (FilterSetIs s) admittedBy msg
filterSet =
    FilterSet_.component


{-| See [`M3e.Component.FilterChipSet.Is`](M3e.Component.FilterChipSet#Is).
-}
type alias FilterSetIs s =
    FilterSet_.Is s


{-| See [`M3e.Component.FilterChipSet.Attrs`](M3e.Component.FilterChipSet#Attrs).
-}
type alias FilterSetAttrs =
    FilterSet_.Attrs


{-| See [`M3e.Component.FilterChipSet.Builder`](M3e.Component.FilterChipSet#Builder).
-}
type alias FilterSetBuilder attrCaps slotCaps msg kind =
    FilterSet_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.FilterChipSet.AttrCaps`](M3e.Component.FilterChipSet#AttrCaps).
-}
type alias FilterSetAttrCaps =
    FilterSet_.AttrCaps


{-| See [`M3e.Component.FilterChipSet.SlotCaps`](M3e.Component.FilterChipSet#SlotCaps).
-}
type alias FilterSetSlotCaps =
    FilterSet_.SlotCaps


{-| See [`M3e.Component.FilterChipSet.Content`](M3e.Component.FilterChipSet#Content).
-}
type alias FilterSetContent =
    FilterSet_.Content


{-| See [`M3e.Component.FilterChipSet.ChildAdmittedBy`](M3e.Component.FilterChipSet#ChildAdmittedBy).
-}
type alias FilterSetChildAdmittedBy childAdm =
    FilterSet_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.FilterChipSet.disabled`](M3e.Component.FilterChipSet#disabled).
-}
filterSetDisabled : Bool -> Attr { c | disabled : Supported } msg
filterSetDisabled =
    FilterSet_.disabled


{-| See [`M3e.Component.FilterChipSet.hideSelectionIndicator`](M3e.Component.FilterChipSet#hideSelectionIndicator).
-}
filterSetHideSelectionIndicator : Bool -> Attr { c | hideSelectionIndicator : Supported } msg
filterSetHideSelectionIndicator =
    FilterSet_.hideSelectionIndicator


{-| See [`M3e.Component.FilterChipSet.multi`](M3e.Component.FilterChipSet#multi).
-}
filterSetMulti : Bool -> Attr { c | multi : Supported } msg
filterSetMulti =
    FilterSet_.multi


{-| See [`M3e.Component.FilterChipSet.name`](M3e.Component.FilterChipSet#name).
-}
filterSetName : String -> Attr { c | name : Supported } msg
filterSetName =
    FilterSet_.name


{-| See [`M3e.Component.FilterChipSet.vertical`](M3e.Component.FilterChipSet#vertical).
-}
filterSetVertical : Bool -> Attr { c | vertical : Supported } msg
filterSetVertical =
    FilterSet_.vertical


{-| See [`M3e.Component.FilterChipSet.onChange`](M3e.Component.FilterChipSet#onChange).
-}
filterSetOnChange : msg -> Attr { c | onChange : Supported } msg
filterSetOnChange =
    FilterSet_.onChange


{-| See [`M3e.Component.FilterChipSet.onBeforeinput`](M3e.Component.FilterChipSet#onBeforeinput).
-}
filterSetOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
filterSetOnBeforeinput =
    FilterSet_.onBeforeinput


{-| See [`M3e.Component.FilterChipSet.onInput`](M3e.Component.FilterChipSet#onInput).
-}
filterSetOnInput : msg -> Attr { c | onInput : Supported } msg
filterSetOnInput =
    FilterSet_.onInput


{-| See [`M3e.Component.FilterChipSet.child`](M3e.Component.FilterChipSet#child).
-}
filterSetChild : Element FilterSetContent admittedBy msg -> Element free freeAdmittedBy msg
filterSetChild =
    FilterSet_.child


{-| The `inputSet` element of this family — delegates to [`M3e.Component.InputChipSet.component`](M3e.Component.InputChipSet#component).
-}
inputSet :
    List (Attr InputSetAttrs msg)
    -> List (Element InputSetContent (InputSetChildAdmittedBy childAdm) msg)
    -> Element (InputSetIs s) admittedBy msg
inputSet =
    InputSet_.component


{-| See [`M3e.Component.InputChipSet.Is`](M3e.Component.InputChipSet#Is).
-}
type alias InputSetIs s =
    InputSet_.Is s


{-| See [`M3e.Component.InputChipSet.Attrs`](M3e.Component.InputChipSet#Attrs).
-}
type alias InputSetAttrs =
    InputSet_.Attrs


{-| See [`M3e.Component.InputChipSet.Builder`](M3e.Component.InputChipSet#Builder).
-}
type alias InputSetBuilder attrCaps slotCaps msg kind =
    InputSet_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Component.InputChipSet.AttrCaps`](M3e.Component.InputChipSet#AttrCaps).
-}
type alias InputSetAttrCaps =
    InputSet_.AttrCaps


{-| See [`M3e.Component.InputChipSet.SlotCaps`](M3e.Component.InputChipSet#SlotCaps).
-}
type alias InputSetSlotCaps =
    InputSet_.SlotCaps


{-| See [`M3e.Component.InputChipSet.Content`](M3e.Component.InputChipSet#Content).
-}
type alias InputSetContent =
    InputSet_.Content


{-| See [`M3e.Component.InputChipSet.ChildAdmittedBy`](M3e.Component.InputChipSet#ChildAdmittedBy).
-}
type alias InputSetChildAdmittedBy childAdm =
    InputSet_.ChildAdmittedBy childAdm


{-| See [`M3e.Component.InputChipSet.disabled`](M3e.Component.InputChipSet#disabled).
-}
inputSetDisabled : Bool -> Attr { c | disabled : Supported } msg
inputSetDisabled =
    InputSet_.disabled


{-| See [`M3e.Component.InputChipSet.name`](M3e.Component.InputChipSet#name).
-}
inputSetName : String -> Attr { c | name : Supported } msg
inputSetName =
    InputSet_.name


{-| See [`M3e.Component.InputChipSet.required`](M3e.Component.InputChipSet#required).
-}
inputSetRequired : Bool -> Attr { c | required : Supported } msg
inputSetRequired =
    InputSet_.required


{-| See [`M3e.Component.InputChipSet.validationmessages`](M3e.Component.InputChipSet#validationmessages).
-}
inputSetValidationmessages : String -> Attr { c | validationmessages : Supported } msg
inputSetValidationmessages =
    InputSet_.validationmessages


{-| See [`M3e.Component.InputChipSet.vertical`](M3e.Component.InputChipSet#vertical).
-}
inputSetVertical : Bool -> Attr { c | vertical : Supported } msg
inputSetVertical =
    InputSet_.vertical


{-| See [`M3e.Component.InputChipSet.onChange`](M3e.Component.InputChipSet#onChange).
-}
inputSetOnChange : msg -> Attr { c | onChange : Supported } msg
inputSetOnChange =
    InputSet_.onChange


{-| See [`M3e.Component.InputChipSet.input`](M3e.Component.InputChipSet#input).
-}
inputSetInput : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
inputSetInput =
    InputSet_.input


{-| See [`M3e.Component.InputChipSet.child`](M3e.Component.InputChipSet#child).
-}
inputSetChild : Element InputSetContent admittedBy msg -> Element free freeAdmittedBy msg
inputSetChild =
    InputSet_.child
