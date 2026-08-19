module TypedHtml.Aria exposing
    ( role, roleString
    , alert, alertdialog, application, banner, button, cell, checkbox, columnheader, combobox, complementary, contentinfo, definition, dialog, directory, document, feed, figure, form, generic, grid, gridcell, group, heading, img, link, list, listbox, listitem, log, main_, marquee, math, menu, menubar, menuitem, menuitemcheckbox, menuitemradio, meter, navigation, none, note, option, presentation, progressbar, radio, radiogroup, region, row, rowgroup, rowheader, scrollbar, search, searchbox, separator, slider, spinbutton, status, switch, tab, table, tablist, tabpanel, term, textbox, timer, toolbar, tooltip, tree, treegrid, treeitem
    , Autocomplete, Checked, Current, Expanded, Haspopup, Hidden, Invalid, Live, Orientation, Pressed, Relevant, Sort, autocomplete, checked, current, expanded, haspopup, hidden, invalid, live, orientation, pressed, relevant, sort
    , additions, all, ascending, assertive, both, date, descending, dialogValue, false, grammar, gridValue, horizontal, inline, listValue, listboxValue, location, menuValue, mixed, noneValue, off, other, page, polite, removals, spelling, step, text, time, treeValue, true, undefined, vertical
    , describedby, description, label, labelledby
    )

{-| The ARIA concern axis — the HYBRID design: `role` is TYPE-GATED per
element where it earns its keep (an element's `<El>Roles` alias closes the
legal set; a wrong role is a compile error), enumerated aria-\* states are
value-typed, and the universal aria-\* attributes stay open. The role×state
dependency is lint territory.

@docs role, roleString
@docs alert, alertdialog, application, banner, button, cell, checkbox, columnheader, combobox, complementary, contentinfo, definition, dialog, directory, document, feed, figure, form, generic, grid, gridcell, group, heading, img, link, list, listbox, listitem, log, main_, marquee, math, menu, menubar, menuitem, menuitemcheckbox, menuitemradio, meter, navigation, none, note, option, presentation, progressbar, radio, radiogroup, region, row, rowgroup, rowheader, scrollbar, search, searchbox, separator, slider, spinbutton, status, switch, tab, table, tablist, tabpanel, term, textbox, timer, toolbar, tooltip, tree, treegrid, treeitem
@docs Autocomplete, Checked, Current, Expanded, Haspopup, Hidden, Invalid, Live, Orientation, Pressed, Relevant, Sort, autocomplete, checked, current, expanded, haspopup, hidden, invalid, live, orientation, pressed, relevant, sort
@docs additions, all, ascending, assertive, both, date, descending, dialogValue, false, grammar, gridValue, horizontal, inline, listValue, listboxValue, location, menuValue, mixed, noneValue, off, other, page, polite, removals, spelling, step, text, time, treeValue, true, undefined, vertical
@docs describedby, description, label, labelledby

-}

import HtmlIr.Attribute exposing (Attr)
import HtmlIr.Internal as Ir
import HtmlIr.Kind exposing (Supported)
import HtmlIr.Value exposing (Value)
import TypedHtml.Kind exposing (Role)


{-| Set a TYPED role: the token's row must fit the element's closed role set.
-}
role : Value tags -> Attr { c | role : tags } msg
role value_ =
    Ir.attribute "role" (HtmlIr.Value.toString value_)


{-| Set a raw role string on a role-UNGATED element (its row has `role : Supported`).
-}
roleString : String -> Attr { c | role : Supported } msg
roleString =
    Ir.attribute "role"


{-| The `alert` role token.
-}
alert : Value { r | alert : Role }
alert =
    Ir.token "alert"


{-| The `alertdialog` role token.
-}
alertdialog : Value { r | alertdialog : Role }
alertdialog =
    Ir.token "alertdialog"


{-| The `application` role token.
-}
application : Value { r | application : Role }
application =
    Ir.token "application"


{-| The `banner` role token.
-}
banner : Value { r | banner : Role }
banner =
    Ir.token "banner"


{-| The `button` role token.
-}
button : Value { r | button : Role }
button =
    Ir.token "button"


{-| The `cell` role token.
-}
cell : Value { r | cell : Role }
cell =
    Ir.token "cell"


{-| The `checkbox` role token.
-}
checkbox : Value { r | checkbox : Role }
checkbox =
    Ir.token "checkbox"


{-| The `columnheader` role token.
-}
columnheader : Value { r | columnheader : Role }
columnheader =
    Ir.token "columnheader"


{-| The `combobox` role token.
-}
combobox : Value { r | combobox : Role }
combobox =
    Ir.token "combobox"


{-| The `complementary` role token.
-}
complementary : Value { r | complementary : Role }
complementary =
    Ir.token "complementary"


{-| The `contentinfo` role token.
-}
contentinfo : Value { r | contentinfo : Role }
contentinfo =
    Ir.token "contentinfo"


{-| The `definition` role token.
-}
definition : Value { r | definition : Role }
definition =
    Ir.token "definition"


{-| The `dialog` role token.
-}
dialog : Value { r | dialog : Role }
dialog =
    Ir.token "dialog"


{-| The `directory` role token.
-}
directory : Value { r | directory : Role }
directory =
    Ir.token "directory"


{-| The `document` role token.
-}
document : Value { r | document : Role }
document =
    Ir.token "document"


{-| The `feed` role token.
-}
feed : Value { r | feed : Role }
feed =
    Ir.token "feed"


{-| The `figure` role token.
-}
figure : Value { r | figure : Role }
figure =
    Ir.token "figure"


{-| The `form` role token.
-}
form : Value { r | form : Role }
form =
    Ir.token "form"


{-| The `generic` role token.
-}
generic : Value { r | generic : Role }
generic =
    Ir.token "generic"


{-| The `grid` role token.
-}
grid : Value { r | grid : Role }
grid =
    Ir.token "grid"


{-| The `gridcell` role token.
-}
gridcell : Value { r | gridcell : Role }
gridcell =
    Ir.token "gridcell"


{-| The `group` role token.
-}
group : Value { r | group : Role }
group =
    Ir.token "group"


{-| The `heading` role token.
-}
heading : Value { r | heading : Role }
heading =
    Ir.token "heading"


{-| The `img` role token.
-}
img : Value { r | img : Role }
img =
    Ir.token "img"


{-| The `link` role token.
-}
link : Value { r | link : Role }
link =
    Ir.token "link"


{-| The `list` role token.
-}
list : Value { r | list : Role }
list =
    Ir.token "list"


{-| The `listbox` role token.
-}
listbox : Value { r | listbox : Role }
listbox =
    Ir.token "listbox"


{-| The `listitem` role token.
-}
listitem : Value { r | listitem : Role }
listitem =
    Ir.token "listitem"


{-| The `log` role token.
-}
log : Value { r | log : Role }
log =
    Ir.token "log"


{-| The `main` role token.
-}
main_ : Value { r | main_ : Role }
main_ =
    Ir.token "main"


{-| The `marquee` role token.
-}
marquee : Value { r | marquee : Role }
marquee =
    Ir.token "marquee"


{-| The `math` role token.
-}
math : Value { r | math : Role }
math =
    Ir.token "math"


{-| The `menu` role token.
-}
menu : Value { r | menu : Role }
menu =
    Ir.token "menu"


{-| The `menubar` role token.
-}
menubar : Value { r | menubar : Role }
menubar =
    Ir.token "menubar"


{-| The `menuitem` role token.
-}
menuitem : Value { r | menuitem : Role }
menuitem =
    Ir.token "menuitem"


{-| The `menuitemcheckbox` role token.
-}
menuitemcheckbox : Value { r | menuitemcheckbox : Role }
menuitemcheckbox =
    Ir.token "menuitemcheckbox"


{-| The `menuitemradio` role token.
-}
menuitemradio : Value { r | menuitemradio : Role }
menuitemradio =
    Ir.token "menuitemradio"


{-| The `meter` role token.
-}
meter : Value { r | meter : Role }
meter =
    Ir.token "meter"


{-| The `navigation` role token.
-}
navigation : Value { r | navigation : Role }
navigation =
    Ir.token "navigation"


{-| The `none` role token.
-}
none : Value { r | none : Role }
none =
    Ir.token "none"


{-| The `note` role token.
-}
note : Value { r | note : Role }
note =
    Ir.token "note"


{-| The `option` role token.
-}
option : Value { r | option : Role }
option =
    Ir.token "option"


{-| The `presentation` role token.
-}
presentation : Value { r | presentation : Role }
presentation =
    Ir.token "presentation"


{-| The `progressbar` role token.
-}
progressbar : Value { r | progressbar : Role }
progressbar =
    Ir.token "progressbar"


{-| The `radio` role token.
-}
radio : Value { r | radio : Role }
radio =
    Ir.token "radio"


{-| The `radiogroup` role token.
-}
radiogroup : Value { r | radiogroup : Role }
radiogroup =
    Ir.token "radiogroup"


{-| The `region` role token.
-}
region : Value { r | region : Role }
region =
    Ir.token "region"


{-| The `row` role token.
-}
row : Value { r | row : Role }
row =
    Ir.token "row"


{-| The `rowgroup` role token.
-}
rowgroup : Value { r | rowgroup : Role }
rowgroup =
    Ir.token "rowgroup"


{-| The `rowheader` role token.
-}
rowheader : Value { r | rowheader : Role }
rowheader =
    Ir.token "rowheader"


{-| The `scrollbar` role token.
-}
scrollbar : Value { r | scrollbar : Role }
scrollbar =
    Ir.token "scrollbar"


{-| The `search` role token.
-}
search : Value { r | search : Role }
search =
    Ir.token "search"


{-| The `searchbox` role token.
-}
searchbox : Value { r | searchbox : Role }
searchbox =
    Ir.token "searchbox"


{-| The `separator` role token.
-}
separator : Value { r | separator : Role }
separator =
    Ir.token "separator"


{-| The `slider` role token.
-}
slider : Value { r | slider : Role }
slider =
    Ir.token "slider"


{-| The `spinbutton` role token.
-}
spinbutton : Value { r | spinbutton : Role }
spinbutton =
    Ir.token "spinbutton"


{-| The `status` role token.
-}
status : Value { r | status : Role }
status =
    Ir.token "status"


{-| The `switch` role token.
-}
switch : Value { r | switch : Role }
switch =
    Ir.token "switch"


{-| The `tab` role token.
-}
tab : Value { r | tab : Role }
tab =
    Ir.token "tab"


{-| The `table` role token.
-}
table : Value { r | table : Role }
table =
    Ir.token "table"


{-| The `tablist` role token.
-}
tablist : Value { r | tablist : Role }
tablist =
    Ir.token "tablist"


{-| The `tabpanel` role token.
-}
tabpanel : Value { r | tabpanel : Role }
tabpanel =
    Ir.token "tabpanel"


{-| The `term` role token.
-}
term : Value { r | term : Role }
term =
    Ir.token "term"


{-| The `textbox` role token.
-}
textbox : Value { r | textbox : Role }
textbox =
    Ir.token "textbox"


{-| The `timer` role token.
-}
timer : Value { r | timer : Role }
timer =
    Ir.token "timer"


{-| The `toolbar` role token.
-}
toolbar : Value { r | toolbar : Role }
toolbar =
    Ir.token "toolbar"


{-| The `tooltip` role token.
-}
tooltip : Value { r | tooltip : Role }
tooltip =
    Ir.token "tooltip"


{-| The `tree` role token.
-}
tree : Value { r | tree : Role }
tree =
    Ir.token "tree"


{-| The `treegrid` role token.
-}
treegrid : Value { r | treegrid : Role }
treegrid =
    Ir.token "treegrid"


{-| The `treeitem` role token.
-}
treeitem : Value { r | treeitem : Role }
treeitem =
    Ir.token "treeitem"


{-| The values `aria-autocomplete` admits.
-}
type alias Autocomplete =
    { both : Supported
    , inline : Supported
    , list : Supported
    , none : Supported
    }


{-| Value-typed `aria-autocomplete` (universal: any element admits it).
-}
autocomplete : Value Autocomplete -> Attr c msg
autocomplete value_ =
    Ir.attribute "aria-autocomplete" (HtmlIr.Value.toString value_)


{-| The values `aria-checked` admits.
-}
type alias Checked =
    { false : Supported
    , mixed : Supported
    , true : Supported
    }


{-| Value-typed `aria-checked` (universal: any element admits it).
-}
checked : Value Checked -> Attr c msg
checked value_ =
    Ir.attribute "aria-checked" (HtmlIr.Value.toString value_)


{-| The values `aria-current` admits.
-}
type alias Current =
    { date : Supported
    , false : Supported
    , location : Supported
    , page : Supported
    , step : Supported
    , time : Supported
    , true : Supported
    }


{-| Value-typed `aria-current` (universal: any element admits it).
-}
current : Value Current -> Attr c msg
current value_ =
    Ir.attribute "aria-current" (HtmlIr.Value.toString value_)


{-| The values `aria-expanded` admits.
-}
type alias Expanded =
    { false : Supported
    , true : Supported
    }


{-| Value-typed `aria-expanded` (universal: any element admits it).
-}
expanded : Value Expanded -> Attr c msg
expanded value_ =
    Ir.attribute "aria-expanded" (HtmlIr.Value.toString value_)


{-| The values `aria-haspopup` admits.
-}
type alias Haspopup =
    { dialog : Supported
    , false : Supported
    , grid : Supported
    , listbox : Supported
    , menu : Supported
    , tree : Supported
    , true : Supported
    }


{-| Value-typed `aria-haspopup` (universal: any element admits it).
-}
haspopup : Value Haspopup -> Attr c msg
haspopup value_ =
    Ir.attribute "aria-haspopup" (HtmlIr.Value.toString value_)


{-| The values `aria-hidden` admits.
-}
type alias Hidden =
    { false : Supported
    , true : Supported
    , undefined : Supported
    }


{-| Value-typed `aria-hidden` (universal: any element admits it).
-}
hidden : Value Hidden -> Attr c msg
hidden value_ =
    Ir.attribute "aria-hidden" (HtmlIr.Value.toString value_)


{-| The values `aria-invalid` admits.
-}
type alias Invalid =
    { false : Supported
    , grammar : Supported
    , spelling : Supported
    , true : Supported
    }


{-| Value-typed `aria-invalid` (universal: any element admits it).
-}
invalid : Value Invalid -> Attr c msg
invalid value_ =
    Ir.attribute "aria-invalid" (HtmlIr.Value.toString value_)


{-| The values `aria-live` admits.
-}
type alias Live =
    { assertive : Supported
    , off : Supported
    , polite : Supported
    }


{-| Value-typed `aria-live` (universal: any element admits it).
-}
live : Value Live -> Attr c msg
live value_ =
    Ir.attribute "aria-live" (HtmlIr.Value.toString value_)


{-| The values `aria-orientation` admits.
-}
type alias Orientation =
    { horizontal : Supported
    , undefined : Supported
    , vertical : Supported
    }


{-| Value-typed `aria-orientation` (universal: any element admits it).
-}
orientation : Value Orientation -> Attr c msg
orientation value_ =
    Ir.attribute "aria-orientation" (HtmlIr.Value.toString value_)


{-| The values `aria-pressed` admits.
-}
type alias Pressed =
    { false : Supported
    , mixed : Supported
    , true : Supported
    }


{-| Value-typed `aria-pressed` (universal: any element admits it).
-}
pressed : Value Pressed -> Attr c msg
pressed value_ =
    Ir.attribute "aria-pressed" (HtmlIr.Value.toString value_)


{-| The values `aria-relevant` admits.
-}
type alias Relevant =
    { additions : Supported
    , all : Supported
    , removals : Supported
    , text : Supported
    }


{-| Value-typed `aria-relevant` (universal: any element admits it).
-}
relevant : Value Relevant -> Attr c msg
relevant value_ =
    Ir.attribute "aria-relevant" (HtmlIr.Value.toString value_)


{-| The values `aria-sort` admits.
-}
type alias Sort =
    { ascending : Supported
    , descending : Supported
    , none : Supported
    , other : Supported
    }


{-| Value-typed `aria-sort` (universal: any element admits it).
-}
sort : Value Sort -> Attr c msg
sort value_ =
    Ir.attribute "aria-sort" (HtmlIr.Value.toString value_)


{-| The `additions` state token.
-}
additions : Value { v | additions : Supported }
additions =
    Ir.token "additions"


{-| The `all` state token.
-}
all : Value { v | all : Supported }
all =
    Ir.token "all"


{-| The `ascending` state token.
-}
ascending : Value { v | ascending : Supported }
ascending =
    Ir.token "ascending"


{-| The `assertive` state token.
-}
assertive : Value { v | assertive : Supported }
assertive =
    Ir.token "assertive"


{-| The `both` state token.
-}
both : Value { v | both : Supported }
both =
    Ir.token "both"


{-| The `date` state token.
-}
date : Value { v | date : Supported }
date =
    Ir.token "date"


{-| The `descending` state token.
-}
descending : Value { v | descending : Supported }
descending =
    Ir.token "descending"


{-| The `dialog` state token.
-}
dialogValue : Value { v | dialog : Supported }
dialogValue =
    Ir.token "dialog"


{-| The `false` state token.
-}
false : Value { v | false : Supported }
false =
    Ir.token "false"


{-| The `grammar` state token.
-}
grammar : Value { v | grammar : Supported }
grammar =
    Ir.token "grammar"


{-| The `grid` state token.
-}
gridValue : Value { v | grid : Supported }
gridValue =
    Ir.token "grid"


{-| The `horizontal` state token.
-}
horizontal : Value { v | horizontal : Supported }
horizontal =
    Ir.token "horizontal"


{-| The `inline` state token.
-}
inline : Value { v | inline : Supported }
inline =
    Ir.token "inline"


{-| The `list` state token.
-}
listValue : Value { v | list : Supported }
listValue =
    Ir.token "list"


{-| The `listbox` state token.
-}
listboxValue : Value { v | listbox : Supported }
listboxValue =
    Ir.token "listbox"


{-| The `location` state token.
-}
location : Value { v | location : Supported }
location =
    Ir.token "location"


{-| The `menu` state token.
-}
menuValue : Value { v | menu : Supported }
menuValue =
    Ir.token "menu"


{-| The `mixed` state token.
-}
mixed : Value { v | mixed : Supported }
mixed =
    Ir.token "mixed"


{-| The `none` state token.
-}
noneValue : Value { v | none : Supported }
noneValue =
    Ir.token "none"


{-| The `off` state token.
-}
off : Value { v | off : Supported }
off =
    Ir.token "off"


{-| The `other` state token.
-}
other : Value { v | other : Supported }
other =
    Ir.token "other"


{-| The `page` state token.
-}
page : Value { v | page : Supported }
page =
    Ir.token "page"


{-| The `polite` state token.
-}
polite : Value { v | polite : Supported }
polite =
    Ir.token "polite"


{-| The `removals` state token.
-}
removals : Value { v | removals : Supported }
removals =
    Ir.token "removals"


{-| The `spelling` state token.
-}
spelling : Value { v | spelling : Supported }
spelling =
    Ir.token "spelling"


{-| The `step` state token.
-}
step : Value { v | step : Supported }
step =
    Ir.token "step"


{-| The `text` state token.
-}
text : Value { v | text : Supported }
text =
    Ir.token "text"


{-| The `time` state token.
-}
time : Value { v | time : Supported }
time =
    Ir.token "time"


{-| The `tree` state token.
-}
treeValue : Value { v | tree : Supported }
treeValue =
    Ir.token "tree"


{-| The `true` state token.
-}
true : Value { v | true : Supported }
true =
    Ir.token "true"


{-| The `undefined` state token.
-}
undefined : Value { v | undefined : Supported }
undefined =
    Ir.token "undefined"


{-| The `vertical` state token.
-}
vertical : Value { v | vertical : Supported }
vertical =
    Ir.token "vertical"


{-| The open `aria-describedby` attribute (universal).
-}
describedby : String -> Attr c msg
describedby =
    Ir.attribute "aria-describedby"


{-| The open `aria-description` attribute (universal).
-}
description : String -> Attr c msg
description =
    Ir.attribute "aria-description"


{-| The open `aria-label` attribute (universal).
-}
label : String -> Attr c msg
label =
    Ir.attribute "aria-label"


{-| The open `aria-labelledby` attribute (universal).
-}
labelledby : String -> Attr c msg
labelledby =
    Ir.attribute "aria-labelledby"
