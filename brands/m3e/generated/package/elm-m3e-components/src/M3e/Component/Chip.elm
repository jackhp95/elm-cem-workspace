module M3e.Component.Chip exposing (ChipIs, ChipAttrs, ChipBuilder, ChipAttrCaps, ChipSlotCaps, ChipContent, ChipIconSlot, ChipTrailingIconSlot, ChipChildAdmittedBy, ChipVariant, AssistIs, AssistAttrs, AssistBuilder, AssistAttrCaps, AssistSlotCaps, AssistContent, AssistIconSlot, AssistChildAdmittedBy, AssistType, AssistVariant, FilterIs, FilterAttrs, FilterBuilder, FilterAttrCaps, FilterSlotCaps, FilterContent, FilterIconSlot, FilterTrailingIconSlot, FilterChildAdmittedBy, FilterVariant, InputIs, InputAttrs, InputBuilder, InputAttrCaps, InputSlotCaps, InputContent, InputAvatarSlot, InputIconSlot, InputRemoveIconSlot, InputChildAdmittedBy, InputVariant, SuggestionIs, SuggestionAttrs, SuggestionBuilder, SuggestionAttrCaps, SuggestionSlotCaps, SuggestionContent, SuggestionIconSlot, SuggestionChildAdmittedBy, SuggestionActionCaps, SuggestionType, SuggestionVariant, SetIs, SetAttrs, SetBuilder, SetAttrCaps, SetSlotCaps, SetContent, SetChildAdmittedBy, FilterSetIs, FilterSetAttrs, FilterSetBuilder, FilterSetAttrCaps, FilterSetSlotCaps, FilterSetContent, FilterSetChildAdmittedBy, InputSetIs, InputSetAttrs, InputSetBuilder, InputSetAttrCaps, InputSetSlotCaps, InputSetContent, InputSetChildAdmittedBy, chip, chipVariant, chipValue, chipDefaultValue, chipIcon, chipTrailingIcon, chipChild, assist, assistType_, assistVariant, assistDisabled, assistDisabledInteractive, assistDownload, assistHref, assistName, assistRel, assistTarget, assistValue, assistDefaultValue, assistOnClick, assistIcon, assistChild, filter, filterVariant, filterDisabled, filterDisabledInteractive, filterSelected, filterValue, filterDefaultSelected, filterDefaultValue, filterOnBeforeinput, filterOnInput, filterOnChange, filterOnClick, filterIcon, filterTrailingIcon, filterChild, input, inputVariant, inputDisabled, inputDisabledInteractive, inputRemovable, inputRemoveLabel, inputValue, inputDefaultValue, inputOnRemove, inputOnClick, inputAvatar, inputIcon, inputRemoveIcon, inputChild, suggestion, suggestionType_, suggestionVariant, suggestionDisabled, suggestionDisabledInteractive, suggestionDownload, suggestionHref, suggestionName, suggestionRel, suggestionTarget, suggestionValue, suggestionDefaultValue, suggestionOnClick, suggestionIcon, suggestionChild, set, setVertical, setChild, filterSet, filterSetDisabled, filterSetHideSelectionIndicator, filterSetMulti, filterSetName, filterSetVertical, filterSetOnChange, filterSetOnBeforeinput, filterSetOnInput, filterSetChild, inputSet, inputSetDisabled, inputSetMaxChips, inputSetName, inputSetRequired, inputSetValidationmessages, inputSetVertical, inputSetOnChange, inputSetInput, inputSetChild)

{-| The **Chip** family — flat module re-exporting its member elements.

This is the **flat family module** for this family: one module carrying every
member element as an element-named constructor (delegating to that component's
`component` ctor), with element-prefixed type aliases and element-prefixed
typed helpers so members never collide. It re-exports:

[`M3e.Element.Chip`](M3e.Element.Chip) as `chip`, [`M3e.Element.AssistChip`](M3e.Element.AssistChip) as `assist`, [`M3e.Element.FilterChip`](M3e.Element.FilterChip) as `filter`, [`M3e.Element.InputChip`](M3e.Element.InputChip) as `input`, [`M3e.Element.SuggestionChip`](M3e.Element.SuggestionChip) as `suggestion`, [`M3e.Element.ChipSet`](M3e.Element.ChipSet) as `set`, [`M3e.Element.FilterChipSet`](M3e.Element.FilterChipSet) as `filterSet`, [`M3e.Element.InputChipSet`](M3e.Element.InputChipSet) as `inputSet`.

Prefer whichever import reads best — the flat `M3e.Element.*` modules and
this family module are the same elements, same types.

@docs ChipIs, ChipAttrs, ChipBuilder, ChipAttrCaps, ChipSlotCaps, ChipContent, ChipIconSlot, ChipTrailingIconSlot, ChipChildAdmittedBy, ChipVariant, AssistIs, AssistAttrs, AssistBuilder, AssistAttrCaps, AssistSlotCaps, AssistContent, AssistIconSlot, AssistChildAdmittedBy, AssistType, AssistVariant, FilterIs, FilterAttrs, FilterBuilder, FilterAttrCaps, FilterSlotCaps, FilterContent, FilterIconSlot, FilterTrailingIconSlot, FilterChildAdmittedBy, FilterVariant, InputIs, InputAttrs, InputBuilder, InputAttrCaps, InputSlotCaps, InputContent, InputAvatarSlot, InputIconSlot, InputRemoveIconSlot, InputChildAdmittedBy, InputVariant, SuggestionIs, SuggestionAttrs, SuggestionBuilder, SuggestionAttrCaps, SuggestionSlotCaps, SuggestionContent, SuggestionIconSlot, SuggestionChildAdmittedBy, SuggestionActionCaps, SuggestionType, SuggestionVariant, SetIs, SetAttrs, SetBuilder, SetAttrCaps, SetSlotCaps, SetContent, SetChildAdmittedBy, FilterSetIs, FilterSetAttrs, FilterSetBuilder, FilterSetAttrCaps, FilterSetSlotCaps, FilterSetContent, FilterSetChildAdmittedBy, InputSetIs, InputSetAttrs, InputSetBuilder, InputSetAttrCaps, InputSetSlotCaps, InputSetContent, InputSetChildAdmittedBy, chip, chipVariant, chipValue, chipDefaultValue, chipIcon, chipTrailingIcon, chipChild, assist, assistType_, assistVariant, assistDisabled, assistDisabledInteractive, assistDownload, assistHref, assistName, assistRel, assistTarget, assistValue, assistDefaultValue, assistOnClick, assistIcon, assistChild, filter, filterVariant, filterDisabled, filterDisabledInteractive, filterSelected, filterValue, filterDefaultSelected, filterDefaultValue, filterOnBeforeinput, filterOnInput, filterOnChange, filterOnClick, filterIcon, filterTrailingIcon, filterChild, input, inputVariant, inputDisabled, inputDisabledInteractive, inputRemovable, inputRemoveLabel, inputValue, inputDefaultValue, inputOnRemove, inputOnClick, inputAvatar, inputIcon, inputRemoveIcon, inputChild, suggestion, suggestionType_, suggestionVariant, suggestionDisabled, suggestionDisabledInteractive, suggestionDownload, suggestionHref, suggestionName, suggestionRel, suggestionTarget, suggestionValue, suggestionDefaultValue, suggestionOnClick, suggestionIcon, suggestionChild, set, setVertical, setChild, filterSet, filterSetDisabled, filterSetHideSelectionIndicator, filterSetMulti, filterSetName, filterSetVertical, filterSetOnChange, filterSetOnBeforeinput, filterSetOnInput, filterSetChild, inputSet, inputSetDisabled, inputSetMaxChips, inputSetName, inputSetRequired, inputSetValidationmessages, inputSetVertical, inputSetOnChange, inputSetInput, inputSetChild

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Element exposing (Element)
import HtmlIr.Kind exposing (Shared, Supported)
import HtmlIr.Value exposing (Value)
import M3e.Action as Ac
import M3e.Element.AssistChip as Assist_
import M3e.Element.Chip as Chip_
import M3e.Element.ChipSet as Set_
import M3e.Element.FilterChip as Filter_
import M3e.Element.FilterChipSet as FilterSet_
import M3e.Element.InputChip as Input_
import M3e.Element.InputChipSet as InputSet_
import M3e.Element.SuggestionChip as Suggestion_


{-| The `chip` element of this family — delegates to [`M3e.Element.Chip.component`](M3e.Element.Chip#component).
-}
chip :
    { content : Element ChipContent (ChipChildAdmittedBy childAdm) msg }
    -> List (Attr ChipAttrs msg)
    -> List (Element ChipContent (ChipChildAdmittedBy childAdm) msg)
    -> Element (ChipIs s) admittedBy msg
chip =
    Chip_.component


{-| See [`M3e.Element.Chip.Is`](M3e.Element.Chip#Is).
-}
type alias ChipIs s =
    Chip_.Is s


{-| See [`M3e.Element.Chip.Attrs`](M3e.Element.Chip#Attrs).
-}
type alias ChipAttrs =
    Chip_.Attrs


{-| See [`M3e.Element.Chip.Builder`](M3e.Element.Chip#Builder).
-}
type alias ChipBuilder attrCaps slotCaps msg kind =
    Chip_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.Chip.AttrCaps`](M3e.Element.Chip#AttrCaps).
-}
type alias ChipAttrCaps =
    Chip_.AttrCaps


{-| See [`M3e.Element.Chip.SlotCaps`](M3e.Element.Chip#SlotCaps).
-}
type alias ChipSlotCaps =
    Chip_.SlotCaps


{-| See [`M3e.Element.Chip.Content`](M3e.Element.Chip#Content).
-}
type alias ChipContent =
    Chip_.Content


{-| See [`M3e.Element.Chip.IconSlot`](M3e.Element.Chip#IconSlot).
-}
type alias ChipIconSlot =
    Chip_.IconSlot


{-| See [`M3e.Element.Chip.TrailingIconSlot`](M3e.Element.Chip#TrailingIconSlot).
-}
type alias ChipTrailingIconSlot =
    Chip_.TrailingIconSlot


{-| See [`M3e.Element.Chip.ChildAdmittedBy`](M3e.Element.Chip#ChildAdmittedBy).
-}
type alias ChipChildAdmittedBy childAdm =
    Chip_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.Chip.Variant`](M3e.Element.Chip#Variant).
-}
type alias ChipVariant =
    Chip_.Variant


{-| See [`M3e.Element.Chip.variant`](M3e.Element.Chip#variant).
-}
chipVariant : Value ChipVariant -> Attr { c | variant : Supported } msg
chipVariant =
    Chip_.variant


{-| See [`M3e.Element.Chip.value`](M3e.Element.Chip#value).
-}
chipValue : String -> Attr { c | value : Supported } msg
chipValue =
    Chip_.value


{-| See [`M3e.Element.Chip.defaultValue`](M3e.Element.Chip#defaultValue).
-}
chipDefaultValue : String -> Attr { c | value : Supported } msg
chipDefaultValue =
    Chip_.defaultValue


{-| See [`M3e.Element.Chip.icon`](M3e.Element.Chip#icon).
-}
chipIcon : Element ChipIconSlot admittedBy msg -> Element free freeAdmittedBy msg
chipIcon =
    Chip_.icon


{-| See [`M3e.Element.Chip.trailingIcon`](M3e.Element.Chip#trailingIcon).
-}
chipTrailingIcon : Element ChipTrailingIconSlot admittedBy msg -> Element free freeAdmittedBy msg
chipTrailingIcon =
    Chip_.trailingIcon


{-| See [`M3e.Element.Chip.child`](M3e.Element.Chip#child).
-}
chipChild : Element ChipContent admittedBy msg -> Element free freeAdmittedBy msg
chipChild =
    Chip_.child


{-| The `assist` element of this family — delegates to [`M3e.Element.AssistChip.component`](M3e.Element.AssistChip#component).
-}
assist :
    { content : Element AssistContent (AssistChildAdmittedBy childAdm) msg }
    -> List (Attr AssistAttrs msg)
    -> List (Element AssistContent (AssistChildAdmittedBy childAdm) msg)
    -> Element (AssistIs s) admittedBy msg
assist =
    Assist_.component


{-| See [`M3e.Element.AssistChip.Is`](M3e.Element.AssistChip#Is).
-}
type alias AssistIs s =
    Assist_.Is s


{-| See [`M3e.Element.AssistChip.Attrs`](M3e.Element.AssistChip#Attrs).
-}
type alias AssistAttrs =
    Assist_.Attrs


{-| See [`M3e.Element.AssistChip.Builder`](M3e.Element.AssistChip#Builder).
-}
type alias AssistBuilder attrCaps slotCaps msg kind =
    Assist_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.AssistChip.AttrCaps`](M3e.Element.AssistChip#AttrCaps).
-}
type alias AssistAttrCaps =
    Assist_.AttrCaps


{-| See [`M3e.Element.AssistChip.SlotCaps`](M3e.Element.AssistChip#SlotCaps).
-}
type alias AssistSlotCaps =
    Assist_.SlotCaps


{-| See [`M3e.Element.AssistChip.Content`](M3e.Element.AssistChip#Content).
-}
type alias AssistContent =
    Assist_.Content


{-| See [`M3e.Element.AssistChip.IconSlot`](M3e.Element.AssistChip#IconSlot).
-}
type alias AssistIconSlot =
    Assist_.IconSlot


{-| See [`M3e.Element.AssistChip.ChildAdmittedBy`](M3e.Element.AssistChip#ChildAdmittedBy).
-}
type alias AssistChildAdmittedBy childAdm =
    Assist_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.AssistChip.Type`](M3e.Element.AssistChip#Type).
-}
type alias AssistType =
    Assist_.Type


{-| See [`M3e.Element.AssistChip.type_`](M3e.Element.AssistChip#type_).
-}
assistType_ : Value AssistType -> Attr { c | type_ : Supported } msg
assistType_ =
    Assist_.type_


{-| See [`M3e.Element.AssistChip.Variant`](M3e.Element.AssistChip#Variant).
-}
type alias AssistVariant =
    Assist_.Variant


{-| See [`M3e.Element.AssistChip.variant`](M3e.Element.AssistChip#variant).
-}
assistVariant : Value AssistVariant -> Attr { c | variant : Supported } msg
assistVariant =
    Assist_.variant


{-| See [`M3e.Element.AssistChip.disabled`](M3e.Element.AssistChip#disabled).
-}
assistDisabled : Bool -> Attr { c | disabled : Supported } msg
assistDisabled =
    Assist_.disabled


{-| See [`M3e.Element.AssistChip.disabledInteractive`](M3e.Element.AssistChip#disabledInteractive).
-}
assistDisabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
assistDisabledInteractive =
    Assist_.disabledInteractive


{-| See [`M3e.Element.AssistChip.download`](M3e.Element.AssistChip#download).
-}
assistDownload : String -> Attr { c | download : Supported } msg
assistDownload =
    Assist_.download


{-| See [`M3e.Element.AssistChip.href`](M3e.Element.AssistChip#href).
-}
assistHref : String -> Attr { c | href : Supported } msg
assistHref =
    Assist_.href


{-| See [`M3e.Element.AssistChip.name`](M3e.Element.AssistChip#name).
-}
assistName : String -> Attr { c | name : Supported } msg
assistName =
    Assist_.name


{-| See [`M3e.Element.AssistChip.rel`](M3e.Element.AssistChip#rel).
-}
assistRel : String -> Attr { c | rel : Supported } msg
assistRel =
    Assist_.rel


{-| See [`M3e.Element.AssistChip.target`](M3e.Element.AssistChip#target).
-}
assistTarget : String -> Attr { c | target : Supported } msg
assistTarget =
    Assist_.target


{-| See [`M3e.Element.AssistChip.value`](M3e.Element.AssistChip#value).
-}
assistValue : String -> Attr { c | value : Supported } msg
assistValue =
    Assist_.value


{-| See [`M3e.Element.AssistChip.defaultValue`](M3e.Element.AssistChip#defaultValue).
-}
assistDefaultValue : String -> Attr { c | value : Supported } msg
assistDefaultValue =
    Assist_.defaultValue


{-| See [`M3e.Element.AssistChip.onClick`](M3e.Element.AssistChip#onClick).
-}
assistOnClick : msg -> Attr { c | onClick : Supported } msg
assistOnClick =
    Assist_.onClick


{-| See [`M3e.Element.AssistChip.icon`](M3e.Element.AssistChip#icon).
-}
assistIcon : Element AssistIconSlot admittedBy msg -> Element free freeAdmittedBy msg
assistIcon =
    Assist_.icon


{-| See [`M3e.Element.AssistChip.child`](M3e.Element.AssistChip#child).
-}
assistChild : Element AssistContent admittedBy msg -> Element free freeAdmittedBy msg
assistChild =
    Assist_.child


{-| The `filter` element of this family — delegates to [`M3e.Element.FilterChip.component`](M3e.Element.FilterChip#component).
-}
filter :
    { content : Element FilterContent (FilterChildAdmittedBy childAdm) msg }
    -> List (Attr FilterAttrs msg)
    -> List (Element FilterContent (FilterChildAdmittedBy childAdm) msg)
    -> Element (FilterIs s) admittedBy msg
filter =
    Filter_.component


{-| See [`M3e.Element.FilterChip.Is`](M3e.Element.FilterChip#Is).
-}
type alias FilterIs s =
    Filter_.Is s


{-| See [`M3e.Element.FilterChip.Attrs`](M3e.Element.FilterChip#Attrs).
-}
type alias FilterAttrs =
    Filter_.Attrs


{-| See [`M3e.Element.FilterChip.Builder`](M3e.Element.FilterChip#Builder).
-}
type alias FilterBuilder attrCaps slotCaps msg kind =
    Filter_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.FilterChip.AttrCaps`](M3e.Element.FilterChip#AttrCaps).
-}
type alias FilterAttrCaps =
    Filter_.AttrCaps


{-| See [`M3e.Element.FilterChip.SlotCaps`](M3e.Element.FilterChip#SlotCaps).
-}
type alias FilterSlotCaps =
    Filter_.SlotCaps


{-| See [`M3e.Element.FilterChip.Content`](M3e.Element.FilterChip#Content).
-}
type alias FilterContent =
    Filter_.Content


{-| See [`M3e.Element.FilterChip.IconSlot`](M3e.Element.FilterChip#IconSlot).
-}
type alias FilterIconSlot =
    Filter_.IconSlot


{-| See [`M3e.Element.FilterChip.TrailingIconSlot`](M3e.Element.FilterChip#TrailingIconSlot).
-}
type alias FilterTrailingIconSlot =
    Filter_.TrailingIconSlot


{-| See [`M3e.Element.FilterChip.ChildAdmittedBy`](M3e.Element.FilterChip#ChildAdmittedBy).
-}
type alias FilterChildAdmittedBy childAdm =
    Filter_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.FilterChip.Variant`](M3e.Element.FilterChip#Variant).
-}
type alias FilterVariant =
    Filter_.Variant


{-| See [`M3e.Element.FilterChip.variant`](M3e.Element.FilterChip#variant).
-}
filterVariant : Value FilterVariant -> Attr { c | variant : Supported } msg
filterVariant =
    Filter_.variant


{-| See [`M3e.Element.FilterChip.disabled`](M3e.Element.FilterChip#disabled).
-}
filterDisabled : Bool -> Attr { c | disabled : Supported } msg
filterDisabled =
    Filter_.disabled


{-| See [`M3e.Element.FilterChip.disabledInteractive`](M3e.Element.FilterChip#disabledInteractive).
-}
filterDisabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
filterDisabledInteractive =
    Filter_.disabledInteractive


{-| See [`M3e.Element.FilterChip.selected`](M3e.Element.FilterChip#selected).
-}
filterSelected : Bool -> Attr { c | selected : Supported } msg
filterSelected =
    Filter_.selected


{-| See [`M3e.Element.FilterChip.value`](M3e.Element.FilterChip#value).
-}
filterValue : String -> Attr { c | value : Supported } msg
filterValue =
    Filter_.value


{-| See [`M3e.Element.FilterChip.defaultSelected`](M3e.Element.FilterChip#defaultSelected).
-}
filterDefaultSelected : Bool -> Attr { c | selected : Supported } msg
filterDefaultSelected =
    Filter_.defaultSelected


{-| See [`M3e.Element.FilterChip.defaultValue`](M3e.Element.FilterChip#defaultValue).
-}
filterDefaultValue : String -> Attr { c | value : Supported } msg
filterDefaultValue =
    Filter_.defaultValue


{-| See [`M3e.Element.FilterChip.onBeforeinput`](M3e.Element.FilterChip#onBeforeinput).
-}
filterOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
filterOnBeforeinput =
    Filter_.onBeforeinput


{-| See [`M3e.Element.FilterChip.onInput`](M3e.Element.FilterChip#onInput).
-}
filterOnInput : msg -> Attr { c | onInput : Supported } msg
filterOnInput =
    Filter_.onInput


{-| See [`M3e.Element.FilterChip.onChange`](M3e.Element.FilterChip#onChange).
-}
filterOnChange : msg -> Attr { c | onChange : Supported } msg
filterOnChange =
    Filter_.onChange


{-| See [`M3e.Element.FilterChip.onClick`](M3e.Element.FilterChip#onClick).
-}
filterOnClick : msg -> Attr { c | onClick : Supported } msg
filterOnClick =
    Filter_.onClick


{-| See [`M3e.Element.FilterChip.icon`](M3e.Element.FilterChip#icon).
-}
filterIcon : Element FilterIconSlot admittedBy msg -> Element free freeAdmittedBy msg
filterIcon =
    Filter_.icon


{-| See [`M3e.Element.FilterChip.trailingIcon`](M3e.Element.FilterChip#trailingIcon).
-}
filterTrailingIcon : Element FilterTrailingIconSlot admittedBy msg -> Element free freeAdmittedBy msg
filterTrailingIcon =
    Filter_.trailingIcon


{-| See [`M3e.Element.FilterChip.child`](M3e.Element.FilterChip#child).
-}
filterChild : Element FilterContent admittedBy msg -> Element free freeAdmittedBy msg
filterChild =
    Filter_.child


{-| The `input` element of this family — delegates to [`M3e.Element.InputChip.component`](M3e.Element.InputChip#component).
-}
input :
    { content : Element InputContent (InputChildAdmittedBy childAdm) msg }
    -> List (Attr InputAttrs msg)
    -> List (Element InputContent (InputChildAdmittedBy childAdm) msg)
    -> Element (InputIs s) admittedBy msg
input =
    Input_.component


{-| See [`M3e.Element.InputChip.Is`](M3e.Element.InputChip#Is).
-}
type alias InputIs s =
    Input_.Is s


{-| See [`M3e.Element.InputChip.Attrs`](M3e.Element.InputChip#Attrs).
-}
type alias InputAttrs =
    Input_.Attrs


{-| See [`M3e.Element.InputChip.Builder`](M3e.Element.InputChip#Builder).
-}
type alias InputBuilder attrCaps slotCaps msg kind =
    Input_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.InputChip.AttrCaps`](M3e.Element.InputChip#AttrCaps).
-}
type alias InputAttrCaps =
    Input_.AttrCaps


{-| See [`M3e.Element.InputChip.SlotCaps`](M3e.Element.InputChip#SlotCaps).
-}
type alias InputSlotCaps =
    Input_.SlotCaps


{-| See [`M3e.Element.InputChip.Content`](M3e.Element.InputChip#Content).
-}
type alias InputContent =
    Input_.Content


{-| See [`M3e.Element.InputChip.AvatarSlot`](M3e.Element.InputChip#AvatarSlot).
-}
type alias InputAvatarSlot =
    Input_.AvatarSlot


{-| See [`M3e.Element.InputChip.IconSlot`](M3e.Element.InputChip#IconSlot).
-}
type alias InputIconSlot =
    Input_.IconSlot


{-| See [`M3e.Element.InputChip.RemoveIconSlot`](M3e.Element.InputChip#RemoveIconSlot).
-}
type alias InputRemoveIconSlot =
    Input_.RemoveIconSlot


{-| See [`M3e.Element.InputChip.ChildAdmittedBy`](M3e.Element.InputChip#ChildAdmittedBy).
-}
type alias InputChildAdmittedBy childAdm =
    Input_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.InputChip.Variant`](M3e.Element.InputChip#Variant).
-}
type alias InputVariant =
    Input_.Variant


{-| See [`M3e.Element.InputChip.variant`](M3e.Element.InputChip#variant).
-}
inputVariant : Value InputVariant -> Attr { c | variant : Supported } msg
inputVariant =
    Input_.variant


{-| See [`M3e.Element.InputChip.disabled`](M3e.Element.InputChip#disabled).
-}
inputDisabled : Bool -> Attr { c | disabled : Supported } msg
inputDisabled =
    Input_.disabled


{-| See [`M3e.Element.InputChip.disabledInteractive`](M3e.Element.InputChip#disabledInteractive).
-}
inputDisabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
inputDisabledInteractive =
    Input_.disabledInteractive


{-| See [`M3e.Element.InputChip.removable`](M3e.Element.InputChip#removable).
-}
inputRemovable : Bool -> Attr { c | removable : Supported } msg
inputRemovable =
    Input_.removable


{-| See [`M3e.Element.InputChip.removeLabel`](M3e.Element.InputChip#removeLabel).
-}
inputRemoveLabel : String -> Attr { c | removeLabel : Supported } msg
inputRemoveLabel =
    Input_.removeLabel


{-| See [`M3e.Element.InputChip.value`](M3e.Element.InputChip#value).
-}
inputValue : String -> Attr { c | value : Supported } msg
inputValue =
    Input_.value


{-| See [`M3e.Element.InputChip.defaultValue`](M3e.Element.InputChip#defaultValue).
-}
inputDefaultValue : String -> Attr { c | value : Supported } msg
inputDefaultValue =
    Input_.defaultValue


{-| See [`M3e.Element.InputChip.onRemove`](M3e.Element.InputChip#onRemove).
-}
inputOnRemove : msg -> Attr { c | onRemove : Supported } msg
inputOnRemove =
    Input_.onRemove


{-| See [`M3e.Element.InputChip.onClick`](M3e.Element.InputChip#onClick).
-}
inputOnClick : msg -> Attr { c | onClick : Supported } msg
inputOnClick =
    Input_.onClick


{-| See [`M3e.Element.InputChip.avatar`](M3e.Element.InputChip#avatar).
-}
inputAvatar : Element InputAvatarSlot admittedBy msg -> Element free freeAdmittedBy msg
inputAvatar =
    Input_.avatar


{-| See [`M3e.Element.InputChip.icon`](M3e.Element.InputChip#icon).
-}
inputIcon : Element InputIconSlot admittedBy msg -> Element free freeAdmittedBy msg
inputIcon =
    Input_.icon


{-| See [`M3e.Element.InputChip.removeIcon`](M3e.Element.InputChip#removeIcon).
-}
inputRemoveIcon : Element InputRemoveIconSlot admittedBy msg -> Element free freeAdmittedBy msg
inputRemoveIcon =
    Input_.removeIcon


{-| See [`M3e.Element.InputChip.child`](M3e.Element.InputChip#child).
-}
inputChild : Element InputContent admittedBy msg -> Element free freeAdmittedBy msg
inputChild =
    Input_.child


{-| The `suggestion` element of this family — delegates to [`M3e.Element.SuggestionChip.component`](M3e.Element.SuggestionChip#component).
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


{-| See [`M3e.Element.SuggestionChip.Is`](M3e.Element.SuggestionChip#Is).
-}
type alias SuggestionIs s =
    Suggestion_.Is s


{-| See [`M3e.Element.SuggestionChip.Attrs`](M3e.Element.SuggestionChip#Attrs).
-}
type alias SuggestionAttrs =
    Suggestion_.Attrs


{-| See [`M3e.Element.SuggestionChip.Builder`](M3e.Element.SuggestionChip#Builder).
-}
type alias SuggestionBuilder attrCaps slotCaps msg kind =
    Suggestion_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.SuggestionChip.AttrCaps`](M3e.Element.SuggestionChip#AttrCaps).
-}
type alias SuggestionAttrCaps =
    Suggestion_.AttrCaps


{-| See [`M3e.Element.SuggestionChip.SlotCaps`](M3e.Element.SuggestionChip#SlotCaps).
-}
type alias SuggestionSlotCaps =
    Suggestion_.SlotCaps


{-| See [`M3e.Element.SuggestionChip.Content`](M3e.Element.SuggestionChip#Content).
-}
type alias SuggestionContent =
    Suggestion_.Content


{-| See [`M3e.Element.SuggestionChip.IconSlot`](M3e.Element.SuggestionChip#IconSlot).
-}
type alias SuggestionIconSlot =
    Suggestion_.IconSlot


{-| See [`M3e.Element.SuggestionChip.ChildAdmittedBy`](M3e.Element.SuggestionChip#ChildAdmittedBy).
-}
type alias SuggestionChildAdmittedBy childAdm =
    Suggestion_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.SuggestionChip.ActionCaps`](M3e.Element.SuggestionChip#ActionCaps).
-}
type alias SuggestionActionCaps =
    Suggestion_.ActionCaps


{-| See [`M3e.Element.SuggestionChip.Type`](M3e.Element.SuggestionChip#Type).
-}
type alias SuggestionType =
    Suggestion_.Type


{-| See [`M3e.Element.SuggestionChip.type_`](M3e.Element.SuggestionChip#type_).
-}
suggestionType_ : Value SuggestionType -> Attr { c | type_ : Supported } msg
suggestionType_ =
    Suggestion_.type_


{-| See [`M3e.Element.SuggestionChip.Variant`](M3e.Element.SuggestionChip#Variant).
-}
type alias SuggestionVariant =
    Suggestion_.Variant


{-| See [`M3e.Element.SuggestionChip.variant`](M3e.Element.SuggestionChip#variant).
-}
suggestionVariant : Value SuggestionVariant -> Attr { c | variant : Supported } msg
suggestionVariant =
    Suggestion_.variant


{-| See [`M3e.Element.SuggestionChip.disabled`](M3e.Element.SuggestionChip#disabled).
-}
suggestionDisabled : Bool -> Attr { c | disabled : Supported } msg
suggestionDisabled =
    Suggestion_.disabled


{-| See [`M3e.Element.SuggestionChip.disabledInteractive`](M3e.Element.SuggestionChip#disabledInteractive).
-}
suggestionDisabledInteractive : Bool -> Attr { c | disabledInteractive : Supported } msg
suggestionDisabledInteractive =
    Suggestion_.disabledInteractive


{-| See [`M3e.Element.SuggestionChip.download`](M3e.Element.SuggestionChip#download).
-}
suggestionDownload : String -> Attr { c | download : Supported } msg
suggestionDownload =
    Suggestion_.download


{-| See [`M3e.Element.SuggestionChip.href`](M3e.Element.SuggestionChip#href).
-}
suggestionHref : String -> Attr { c | href : Supported } msg
suggestionHref =
    Suggestion_.href


{-| See [`M3e.Element.SuggestionChip.name`](M3e.Element.SuggestionChip#name).
-}
suggestionName : String -> Attr { c | name : Supported } msg
suggestionName =
    Suggestion_.name


{-| See [`M3e.Element.SuggestionChip.rel`](M3e.Element.SuggestionChip#rel).
-}
suggestionRel : String -> Attr { c | rel : Supported } msg
suggestionRel =
    Suggestion_.rel


{-| See [`M3e.Element.SuggestionChip.target`](M3e.Element.SuggestionChip#target).
-}
suggestionTarget : String -> Attr { c | target : Supported } msg
suggestionTarget =
    Suggestion_.target


{-| See [`M3e.Element.SuggestionChip.value`](M3e.Element.SuggestionChip#value).
-}
suggestionValue : String -> Attr { c | value : Supported } msg
suggestionValue =
    Suggestion_.value


{-| See [`M3e.Element.SuggestionChip.defaultValue`](M3e.Element.SuggestionChip#defaultValue).
-}
suggestionDefaultValue : String -> Attr { c | value : Supported } msg
suggestionDefaultValue =
    Suggestion_.defaultValue


{-| See [`M3e.Element.SuggestionChip.onClick`](M3e.Element.SuggestionChip#onClick).
-}
suggestionOnClick : msg -> Attr { c | onClick : Supported } msg
suggestionOnClick =
    Suggestion_.onClick


{-| See [`M3e.Element.SuggestionChip.icon`](M3e.Element.SuggestionChip#icon).
-}
suggestionIcon : Element SuggestionIconSlot admittedBy msg -> Element free freeAdmittedBy msg
suggestionIcon =
    Suggestion_.icon


{-| See [`M3e.Element.SuggestionChip.child`](M3e.Element.SuggestionChip#child).
-}
suggestionChild : Element SuggestionContent admittedBy msg -> Element free freeAdmittedBy msg
suggestionChild =
    Suggestion_.child


{-| The `set` element of this family — delegates to [`M3e.Element.ChipSet.component`](M3e.Element.ChipSet#component).
-}
set :
    List (Attr SetAttrs msg)
    -> List (Element SetContent (SetChildAdmittedBy childAdm) msg)
    -> Element (SetIs s) admittedBy msg
set =
    Set_.component


{-| See [`M3e.Element.ChipSet.Is`](M3e.Element.ChipSet#Is).
-}
type alias SetIs s =
    Set_.Is s


{-| See [`M3e.Element.ChipSet.Attrs`](M3e.Element.ChipSet#Attrs).
-}
type alias SetAttrs =
    Set_.Attrs


{-| See [`M3e.Element.ChipSet.Builder`](M3e.Element.ChipSet#Builder).
-}
type alias SetBuilder attrCaps slotCaps msg kind =
    Set_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.ChipSet.AttrCaps`](M3e.Element.ChipSet#AttrCaps).
-}
type alias SetAttrCaps =
    Set_.AttrCaps


{-| See [`M3e.Element.ChipSet.SlotCaps`](M3e.Element.ChipSet#SlotCaps).
-}
type alias SetSlotCaps =
    Set_.SlotCaps


{-| See [`M3e.Element.ChipSet.Content`](M3e.Element.ChipSet#Content).
-}
type alias SetContent =
    Set_.Content


{-| See [`M3e.Element.ChipSet.ChildAdmittedBy`](M3e.Element.ChipSet#ChildAdmittedBy).
-}
type alias SetChildAdmittedBy childAdm =
    Set_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.ChipSet.vertical`](M3e.Element.ChipSet#vertical).
-}
setVertical : Bool -> Attr { c | vertical : Supported } msg
setVertical =
    Set_.vertical


{-| See [`M3e.Element.ChipSet.child`](M3e.Element.ChipSet#child).
-}
setChild : Element SetContent admittedBy msg -> Element free freeAdmittedBy msg
setChild =
    Set_.child


{-| The `filterSet` element of this family — delegates to [`M3e.Element.FilterChipSet.component`](M3e.Element.FilterChipSet#component).
-}
filterSet :
    List (Attr FilterSetAttrs msg)
    -> List (Element FilterSetContent (FilterSetChildAdmittedBy childAdm) msg)
    -> Element (FilterSetIs s) admittedBy msg
filterSet =
    FilterSet_.component


{-| See [`M3e.Element.FilterChipSet.Is`](M3e.Element.FilterChipSet#Is).
-}
type alias FilterSetIs s =
    FilterSet_.Is s


{-| See [`M3e.Element.FilterChipSet.Attrs`](M3e.Element.FilterChipSet#Attrs).
-}
type alias FilterSetAttrs =
    FilterSet_.Attrs


{-| See [`M3e.Element.FilterChipSet.Builder`](M3e.Element.FilterChipSet#Builder).
-}
type alias FilterSetBuilder attrCaps slotCaps msg kind =
    FilterSet_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.FilterChipSet.AttrCaps`](M3e.Element.FilterChipSet#AttrCaps).
-}
type alias FilterSetAttrCaps =
    FilterSet_.AttrCaps


{-| See [`M3e.Element.FilterChipSet.SlotCaps`](M3e.Element.FilterChipSet#SlotCaps).
-}
type alias FilterSetSlotCaps =
    FilterSet_.SlotCaps


{-| See [`M3e.Element.FilterChipSet.Content`](M3e.Element.FilterChipSet#Content).
-}
type alias FilterSetContent =
    FilterSet_.Content


{-| See [`M3e.Element.FilterChipSet.ChildAdmittedBy`](M3e.Element.FilterChipSet#ChildAdmittedBy).
-}
type alias FilterSetChildAdmittedBy childAdm =
    FilterSet_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.FilterChipSet.disabled`](M3e.Element.FilterChipSet#disabled).
-}
filterSetDisabled : Bool -> Attr { c | disabled : Supported } msg
filterSetDisabled =
    FilterSet_.disabled


{-| See [`M3e.Element.FilterChipSet.hideSelectionIndicator`](M3e.Element.FilterChipSet#hideSelectionIndicator).
-}
filterSetHideSelectionIndicator : Bool -> Attr { c | hideSelectionIndicator : Supported } msg
filterSetHideSelectionIndicator =
    FilterSet_.hideSelectionIndicator


{-| See [`M3e.Element.FilterChipSet.multi`](M3e.Element.FilterChipSet#multi).
-}
filterSetMulti : Bool -> Attr { c | multi : Supported } msg
filterSetMulti =
    FilterSet_.multi


{-| See [`M3e.Element.FilterChipSet.name`](M3e.Element.FilterChipSet#name).
-}
filterSetName : String -> Attr { c | name : Supported } msg
filterSetName =
    FilterSet_.name


{-| See [`M3e.Element.FilterChipSet.vertical`](M3e.Element.FilterChipSet#vertical).
-}
filterSetVertical : Bool -> Attr { c | vertical : Supported } msg
filterSetVertical =
    FilterSet_.vertical


{-| See [`M3e.Element.FilterChipSet.onChange`](M3e.Element.FilterChipSet#onChange).
-}
filterSetOnChange : msg -> Attr { c | onChange : Supported } msg
filterSetOnChange =
    FilterSet_.onChange


{-| See [`M3e.Element.FilterChipSet.onBeforeinput`](M3e.Element.FilterChipSet#onBeforeinput).
-}
filterSetOnBeforeinput : msg -> Attr { c | onBeforeinput : Supported } msg
filterSetOnBeforeinput =
    FilterSet_.onBeforeinput


{-| See [`M3e.Element.FilterChipSet.onInput`](M3e.Element.FilterChipSet#onInput).
-}
filterSetOnInput : msg -> Attr { c | onInput : Supported } msg
filterSetOnInput =
    FilterSet_.onInput


{-| See [`M3e.Element.FilterChipSet.child`](M3e.Element.FilterChipSet#child).
-}
filterSetChild : Element FilterSetContent admittedBy msg -> Element free freeAdmittedBy msg
filterSetChild =
    FilterSet_.child


{-| The `inputSet` element of this family — delegates to [`M3e.Element.InputChipSet.component`](M3e.Element.InputChipSet#component).
-}
inputSet :
    List (Attr InputSetAttrs msg)
    -> List (Element InputSetContent (InputSetChildAdmittedBy childAdm) msg)
    -> Element (InputSetIs s) admittedBy msg
inputSet =
    InputSet_.component


{-| See [`M3e.Element.InputChipSet.Is`](M3e.Element.InputChipSet#Is).
-}
type alias InputSetIs s =
    InputSet_.Is s


{-| See [`M3e.Element.InputChipSet.Attrs`](M3e.Element.InputChipSet#Attrs).
-}
type alias InputSetAttrs =
    InputSet_.Attrs


{-| See [`M3e.Element.InputChipSet.Builder`](M3e.Element.InputChipSet#Builder).
-}
type alias InputSetBuilder attrCaps slotCaps msg kind =
    InputSet_.Builder attrCaps slotCaps msg kind


{-| See [`M3e.Element.InputChipSet.AttrCaps`](M3e.Element.InputChipSet#AttrCaps).
-}
type alias InputSetAttrCaps =
    InputSet_.AttrCaps


{-| See [`M3e.Element.InputChipSet.SlotCaps`](M3e.Element.InputChipSet#SlotCaps).
-}
type alias InputSetSlotCaps =
    InputSet_.SlotCaps


{-| See [`M3e.Element.InputChipSet.Content`](M3e.Element.InputChipSet#Content).
-}
type alias InputSetContent =
    InputSet_.Content


{-| See [`M3e.Element.InputChipSet.ChildAdmittedBy`](M3e.Element.InputChipSet#ChildAdmittedBy).
-}
type alias InputSetChildAdmittedBy childAdm =
    InputSet_.ChildAdmittedBy childAdm


{-| See [`M3e.Element.InputChipSet.disabled`](M3e.Element.InputChipSet#disabled).
-}
inputSetDisabled : Bool -> Attr { c | disabled : Supported } msg
inputSetDisabled =
    InputSet_.disabled


{-| See [`M3e.Element.InputChipSet.maxChips`](M3e.Element.InputChipSet#maxChips).
-}
inputSetMaxChips : Float -> Attr { c | maxChips : Supported } msg
inputSetMaxChips =
    InputSet_.maxChips


{-| See [`M3e.Element.InputChipSet.name`](M3e.Element.InputChipSet#name).
-}
inputSetName : String -> Attr { c | name : Supported } msg
inputSetName =
    InputSet_.name


{-| See [`M3e.Element.InputChipSet.required`](M3e.Element.InputChipSet#required).
-}
inputSetRequired : Bool -> Attr { c | required : Supported } msg
inputSetRequired =
    InputSet_.required


{-| See [`M3e.Element.InputChipSet.validationmessages`](M3e.Element.InputChipSet#validationmessages).
-}
inputSetValidationmessages : String -> Attr { c | validationmessages : Supported } msg
inputSetValidationmessages =
    InputSet_.validationmessages


{-| See [`M3e.Element.InputChipSet.vertical`](M3e.Element.InputChipSet#vertical).
-}
inputSetVertical : Bool -> Attr { c | vertical : Supported } msg
inputSetVertical =
    InputSet_.vertical


{-| See [`M3e.Element.InputChipSet.onChange`](M3e.Element.InputChipSet#onChange).
-}
inputSetOnChange : msg -> Attr { c | onChange : Supported } msg
inputSetOnChange =
    InputSet_.onChange


{-| See [`M3e.Element.InputChipSet.input`](M3e.Element.InputChipSet#input).
-}
inputSetInput : Element childAccepts admittedBy msg -> Element free freeAdmittedBy msg
inputSetInput =
    InputSet_.input


{-| See [`M3e.Element.InputChipSet.child`](M3e.Element.InputChipSet#child).
-}
inputSetChild : Element InputSetContent admittedBy msg -> Element free freeAdmittedBy msg
inputSetChild =
    InputSet_.child
