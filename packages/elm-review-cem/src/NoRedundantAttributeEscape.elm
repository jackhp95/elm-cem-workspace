module NoRedundantAttributeEscape exposing (rule)

{-| **The attribute-side escape-reflex backstop** (companion to
`NoRedundantElementEscape`).

`NoRedundantElementEscape` catches an escape wrapping an already-typed
**element**. This rule catches the same reflex one layer down, on the
**attribute** surface: a `<root>.Unsafe.Attributes` escape writing an attribute
(or wiring an event) that the typed layer **already provides a setter for**.

    Unsafe.fromHtmlAttribute (Html.Attributes.attribute "dir" "rtl")

    Unsafe.fromHtmlAttribute (Html.Events.on "change" decoder)

    Unsafe.customAttribute "inert" ""

Each of those compiles, greps as "blessed", and is a defect: `fromHtmlAttribute`
and `customAttribute` produce an `Attr` with a **FREE capability row**, so the
compiler no longer checks which elements admit the attribute. The typed setters
(`TypedHtml.Attributes.dir`, `<root>.Events.onChangeWith`,
`TypedHtml.Attributes.inert`) carry the capability the element's closed row must
list, so a misplaced attribute is a compile error instead of a silent no-op.

This is the failure mode a mechanical migration produces: rewriting an old
userland escape module onto `<root>.Unsafe.*` **preserves** every escape rather
than eliminating it, and the escapes then hide behind a blessed name.

    config =
        [ NoRedundantAttributeEscape.rule
            { setterModules = [] }
            (Lib.Review.Facts.facts ++ TypedHtml.Review.Facts.facts)
        ]


### The whole escape-discipline set, ready to paste

The four rules that police the escape surface work as one set: the import fence
keeps escapes out of feature code, and the three redundancy rules catch the
escapes that remain in the modules allowed to hold them. Substitute your brand
for `Lib` and your own adapter modules for the allow-list:

    module ReviewConfig exposing (config)

    import Lib.Review.Facts
    import NoRedundantAttributeEscape
    import NoRedundantElementEscape
    import NoRedundantElementForge
    import NoUnsafeImportOutsideAllowed
    import Review.Rule exposing (Rule)
    import TypedHtml.Review.Facts

    facts =
        Lib.Review.Facts.facts ++ TypedHtml.Review.Facts.facts

    config : List Rule
    config =
        [ -- The fence: `<brand>.Unsafe*` may only be imported by the generated
          -- namespaces and your designated escape/adapter modules.
          NoUnsafeImportOutsideAllowed.rule
            [ "Lib", "TypedHtml", "Seam", "Native", "Kit", "Layout" ]

        -- Inside those modules: an escape that a typed path already covers.
        , NoRedundantAttributeEscape.rule { setterModules = [] } facts
        , NoRedundantElementEscape.rule
            { seamEscapes = [ "Seam.fromHtml", "Seam.toElement" ] }
            facts

        -- The raw-forge twin, for adapters that reach for `HtmlIr.Internal`.
        -- Takes the typed-HTML facts only: they enumerate the covered tags.
        , NoRedundantElementForge.rule TypedHtml.Review.Facts.facts
        ]

`NoUnsafeImportOutsideAllowed`'s allow-list must include every generated
namespace (the brand's own modules import their own `Unsafe`), plus the modules
your team designates to hold escapes. Every OTHER module is then fenced, and the
three redundancy rules keep the blessed modules honest.


### The soundness gate: only element-INDEPENDENT names

The rule sees an escape, not the element the escape lands on — an attribute list
may be built in a helper, a `let`, or a `List.map`. So it only ever matches a
name whose meaning does not depend on the element:

  - `aria-*` and `role` — universal by definition (prefix-derived, not listed);
  - HTML's **global** attributes (`class`, `id`, `dir`, `hidden`, `title`, …) —
    admitted by every element, custom elements included;
  - **events** — `on "<event>"` and the `Html.Events.<setter>` spellings, because
    a typed event setter installs the same DOM listener whatever the element is.

Everything else is element-specific and stays SILENT, because **a custom
element's attribute namespace is disjoint from HTML's**:

    Unsafe.customElement "raw-html"
        [ Unsafe.customAttribute "content" html ]
        []

`content` there is `<raw-html>`'s own attribute (the HTML string to inject); it
has nothing to do with `<meta content="…">`, and a `content` setter typed for
`<meta>` would be meaningless on it. The same holds for `src`, `name`, `label`,
`value`, `size` and `type`, which merely happen to collide with HTML spellings.
`src` on `<model-viewer>` DOES mean what HTML means — and is dropped too, because
from the escape site the rule cannot tell the two cases apart. That is a
deliberate trade of true positives for the guarantee that a finding is always
actionable.


### Where the evidence comes from

Within that gate, a typed setter is only claimed to exist when the rule has
**seen its declaration**. For every namespace present in the facts (`Lib`,
`TypedHtml`, …) it derives `<root>.Attributes`, `<root>.Aria` and
`<root>.Events` and harvests each one's **exposed** top-level names — as project
modules. Add any further module with `setterModules` (checked before the derived
ones). Because the harvest reads declarations, it also learns each setter's first
argument type, which is what makes the boolean autofix below safe.

Namespaces are consulted in facts order, so a config that concatenates
`Lib … ++ TypedHtml …` reports the design-system setter in preference to the
native-HTML one, and the escape's own brand is tried first.

The facts are used for namespace derivation only. They are deliberately NOT an
evidence source for setters: a fact's `attrRewrites` / `enums` name
**per-component** setters, whose rows are CLOSED (`Lib.Button.variant` is
admitted by `button` alone), so suggesting one without knowing the element is
unsound in exactly the way the gate above prevents. Only the shared setter
modules' open producers (`Attr { c | dir : Supported } msg`) are safe to suggest.

**Limitation, stated plainly:** the harvest only sees modules that are part of
the reviewed project (a `source-directories` entry). If a brand library is
consumed as a **published package dependency**, its modules are not project
modules, the harvest finds nothing for that namespace, and the rule reports
nothing for it — it never false-positives, it just covers less. The durable fix
is for the generator to emit the setter table (and the global-attribute list)
beside `facts`; see `docs/decisions.md`.


### What it flags

Only the escapes on `<root>.Unsafe.Attributes`, resolved through the
module-name lookup table (so any alias works), and only with a **string literal**
name:

  - `customAttribute "<name>" <value>`;
  - `fromHtmlAttribute (Html.Attributes.attribute "<name>" <value>)`;
  - `fromHtmlAttribute (Html.Events.on "<event>" <decoder>)` — matched against
    `on<Event>With`, the setter with exactly that shape;
  - `fromHtmlAttribute (Html.Attributes.<setter> …)` /
    `fromHtmlAttribute (Html.Events.<setter> …)` — matched by name against a
    harvested setter.

all subject to the element-independence gate above.

Candidate setter names are derived from the attribute name, never from a name
list: `camelize` (`accept-charset` → `acceptCharset`), the reserved-word escape
the generator applies (`type` → `type_`), and, for an `aria-*` attribute, the
prefix-stripped name — which is only ever looked for in an `*.Aria` module, so
`aria-label` can never resolve to an unrelated `label` attribute setter.

**Precision — what it must NOT flag:**

  - a genuinely custom attribute (`customAttribute "active-index" "2"`) — no
    setter of that name was ever declared, so the escape is legitimate;
  - an element-SPECIFIC attribute (`content`, `src`, `href`, `type`, or a brand's
    `variant`) — the gate above; the rule cannot know the element, so it does not
    guess;
  - a dynamic name (`customAttribute name value`) — not a literal, so
    unresolvable and silent;
  - a point-free escape (`List.map Unsafe.fromHtmlAttribute attrs`) — no
    argument to inspect;
  - `Html.Events.stopPropagationOn` / `preventDefaultOn` / `custom`, and
    `Html.Attributes.property` — the typed setters do not replicate their
    semantics, so they are left alone.


### Autofix

Offered **only** for the one byte-identical rewrite: an attribute written with an
EMPTY string value (`customAttribute "inert" ""`, or the
`Html.Attributes.attribute` form of it) whose resolved setter was harvested with
a `Bool` first argument, which makes `<setter> True` render exactly the same
attribute. The fix adds `import <setter module>` when missing and uses the
module's existing alias when it is already imported.

`customAttribute "inert" "true"` is reported but deliberately NOT fixed: the
typed `Bool` setter renders `inert=""`, and a custom element that reads the raw
value would see a different string.

Everything else is **report-only** on purpose: moving to the typed setter
usually means translating the escape's `String` into the setter's argument (a
`Value` token for `dir`, a decoder for an event, a different arity for `style`),
and a fix that guessed at that would emit code that does not compile.

@docs rule

-}

import Cem.Facts exposing (Fact)
import Cem.Internal.Facts as Facts
import Dict exposing (Dict)
import Elm.Syntax.Declaration as Declaration exposing (Declaration)
import Elm.Syntax.Exposing as Exposing
import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Import exposing (Import)
import Elm.Syntax.Module as Module
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Range exposing (Range)
import Elm.Syntax.Signature exposing (Signature)
import Elm.Syntax.TypeAnnotation as TypeAnnotation
import Review.Fix as Fix
import Review.ModuleNameLookupTable as Lookup exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)
import Set exposing (Set)


{-| Build the rule from the setter-module config and the generated facts.

  - `setterModules` — fully-qualified names of any ADDITIONAL modules that
    declare typed attribute setters (e.g. a team's own
    `[ "Kit.Attributes" ]`). They are consulted before the derived
    `<root>.Attributes` / `<root>.Aria` / `<root>.Events` modules. Pass `[]` for
    the generated-library defaults.
  - the `List Fact` — the same generated facts the other facts-driven rules
    consume; concatenate several libraries' facts to cover them all, most
    preferred namespace first.

-}
rule : { setterModules : List String, globalAttributes : List String } -> List Fact -> Rule
rule config facts =
    let
        namespaces : List (List String)
        namespaces =
            Facts.namespaces facts

        setterModules : List String
        setterModules =
            config.setterModules ++ derivedSetterModules namespaces

        globals : Set String
        globals =
            globalsInForce config
    in
    Rule.newProjectRuleSchema "NoRedundantAttributeEscape" initialProjectContext
        |> Rule.withModuleVisitor moduleVisitor
        |> Rule.withModuleContextUsingContextCreator
            { fromProjectToModule = fromProjectToModule namespaces setterModules globals
            , fromModuleToProject = fromModuleToProject
            , foldProjectContexts = foldProjectContexts
            }
        |> Rule.withFinalProjectEvaluation (finalEvaluation setterModules)
        |> Rule.fromProjectRuleSchema


{-| The shared setter modules a generated library emits per namespace. Derived,
so a second library's `<root>.Attributes` is picked up with no extra config.
-}
derivedSetterModules : List (List String) -> List String
derivedSetterModules namespaces =
    namespaces
        |> List.concatMap
            (\ns ->
                let
                    root =
                        String.join "." ns
                in
                [ root ++ ".Attributes", root ++ ".Aria", root ++ ".Events" ]
            )



-- CONTEXT


type alias ProjectContext =
    { setters : Dict String Bool
    , pending : List PendingModule
    }


{-| A module that holds at least one candidate escape, kept until the final
evaluation (the setter modules that prove the candidates may be visited after
it, so nothing can be decided while the module itself is being visited).
-}
type alias PendingModule =
    { key : Rule.ModuleKey
    , imports : Dict String String
    , insertionRow : Int
    , candidates : List Candidate
    }


type alias ModuleContext =
    { lookup : ModuleNameLookupTable
    , moduleKey : Rule.ModuleKey
    , moduleName : String
    , namespaces : List (List String)
    , globals : Set String
    , isSetterModule : Bool
    , exposedAll : Bool
    , exposedNames : Set String
    , harvested : Dict String Bool
    , imports : Dict String String
    , insertionRow : Int
    , candidates : List Candidate
    }


initialProjectContext : ProjectContext
initialProjectContext =
    { setters = Dict.empty
    , pending = []
    }


fromProjectToModule : List (List String) -> List String -> Set String -> Rule.ContextCreator ProjectContext ModuleContext
fromProjectToModule namespaces setterModules globals =
    Rule.initContextCreator
        (\lookup moduleKey moduleNameParts _ ->
            let
                dotted =
                    String.join "." moduleNameParts
            in
            { lookup = lookup
            , moduleKey = moduleKey
            , moduleName = dotted
            , namespaces = namespaces
            , globals = globals
            , isSetterModule = List.member dotted setterModules
            , exposedAll = False
            , exposedNames = Set.empty
            , harvested = Dict.empty
            , imports = Dict.empty
            , insertionRow = 1
            , candidates = []
            }
        )
        |> Rule.withModuleNameLookupTable
        |> Rule.withModuleKey
        |> Rule.withModuleName


fromModuleToProject : Rule.ContextCreator ModuleContext ProjectContext
fromModuleToProject =
    Rule.initContextCreator
        (\moduleContext ->
            { setters = moduleContext.harvested
            , pending =
                case List.reverse moduleContext.candidates of
                    [] ->
                        []

                    candidates ->
                        [ { key = moduleContext.moduleKey
                          , imports = moduleContext.imports
                          , insertionRow = moduleContext.insertionRow
                          , candidates = candidates
                          }
                        ]
            }
        )


foldProjectContexts : ProjectContext -> ProjectContext -> ProjectContext
foldProjectContexts new previous =
    { setters = Dict.union new.setters previous.setters
    , pending = new.pending ++ previous.pending
    }



-- MODULE VISITORS


moduleVisitor : Rule.ModuleRuleSchema {} ModuleContext -> Rule.ModuleRuleSchema { hasAtLeastOneVisitor : () } ModuleContext
moduleVisitor schema =
    schema
        |> Rule.withModuleDefinitionVisitor moduleDefinitionVisitor
        |> Rule.withImportVisitor importVisitor
        |> Rule.withDeclarationListVisitor declarationListVisitor
        |> Rule.withExpressionEnterVisitor expressionVisitor


{-| Record what the module exposes (only exposed setters are suggestable) and
the fallback import-insertion row for a module with no imports at all.
-}
moduleDefinitionVisitor : Node Module.Module -> ModuleContext -> ( List (Error {}), ModuleContext )
moduleDefinitionVisitor node context =
    let
        withExposing =
            case Module.exposingList (Node.value node) of
                Exposing.All _ ->
                    { context | exposedAll = True }

                Exposing.Explicit list ->
                    { context | exposedNames = Set.fromList (List.filterMap exposedFunctionName list) }
    in
    ( [], { withExposing | insertionRow = (Node.range node).end.row } )


exposedFunctionName : Node Exposing.TopLevelExpose -> Maybe String
exposedFunctionName node =
    case Node.value node of
        Exposing.FunctionExpose name ->
            Just name

        _ ->
            Nothing


{-| Record each import's qualifier (its alias when it has one — Elm hides the
full name behind an alias, so a fix must use whichever the module actually has)
and keep the insertion row at the last import.
-}
importVisitor : Node Import -> ModuleContext -> ( List (Error {}), ModuleContext )
importVisitor node context =
    let
        imported =
            Node.value node

        dotted =
            String.join "." (Node.value imported.moduleName)

        qualifier =
            case imported.moduleAlias of
                Just alias ->
                    String.join "." (Node.value alias)

                Nothing ->
                    dotted
    in
    ( []
    , { context
        | imports = Dict.insert dotted qualifier context.imports
        , insertionRow = (Node.range node).end.row
      }
    )


{-| In a setter module, harvest every EXPOSED top-level function name plus
whether its first argument is a `Bool` (the evidence the boolean autofix needs).
-}
declarationListVisitor : List (Node Declaration) -> ModuleContext -> ( List (Error {}), ModuleContext )
declarationListVisitor declarations context =
    if not context.isSetterModule then
        ( [], context )

    else
        ( []
        , { context | harvested = Dict.fromList (List.filterMap (harvestSetter context) declarations) }
        )


harvestSetter : ModuleContext -> Node Declaration -> Maybe ( String, Bool )
harvestSetter context node =
    case Node.value node of
        Declaration.FunctionDeclaration function ->
            let
                name =
                    Node.value (Node.value function.declaration).name
            in
            if context.exposedAll || Set.member name context.exposedNames then
                Just ( context.moduleName ++ "." ++ name, firstArgIsBool function.signature )

            else
                Nothing

        _ ->
            Nothing


firstArgIsBool : Maybe (Node Signature) -> Bool
firstArgIsBool maybeSignature =
    case maybeSignature of
        Just signature ->
            case Node.value (Node.value signature).typeAnnotation of
                TypeAnnotation.FunctionTypeAnnotation first _ ->
                    case Node.value first of
                        TypeAnnotation.Typed name [] ->
                            Node.value name == ( [], "Bool" )

                        _ ->
                            False

                _ ->
                    False

        Nothing ->
            False



-- CANDIDATE COLLECTION


{-| What an escape writes, and which typed setter names could replace it.
-}
type alias Candidate =
    { escape : String
    , namespace : List String
    , subject : String
    , isEvent : Bool
    , wanted : List Wanted
    , range : Range
    , replaceRange : Range
    , bare : Bool
    }


{-| A candidate setter name. `ariaOnly` names (the `aria-` prefix stripped) are
only looked for in an `*.Aria` module, so `aria-label` can never resolve to an
unrelated `label` attribute setter.
-}
type alias Wanted =
    { name : String
    , ariaOnly : Bool
    }


expressionVisitor : Node Expression -> ModuleContext -> ( List (Error {}), ModuleContext )
expressionVisitor node context =
    ( [], { context | candidates = collect context node ++ context.candidates } )


collect : ModuleContext -> Node Expression -> List Candidate
collect context node =
    case Node.value node of
        Expression.Application (head :: args) ->
            fromEscape context node head args

        Expression.OperatorApplication "<|" _ head arg ->
            fromEscape context node head [ arg ]

        Expression.OperatorApplication "|>" _ arg head ->
            fromEscape context node head [ arg ]

        _ ->
            []


{-| The two attribute escapes, recognised by resolved module remainder
(`["Unsafe", "Attributes"]` under any facts namespace) rather than by name.
-}
type Escape
    = CustomAttribute
    | FromHtmlAttribute


escapeAt : ModuleContext -> Node Expression -> Maybe ( Escape, List String )
escapeAt context head =
    case Node.value head of
        Expression.FunctionOrValue _ name ->
            case ( name, Facts.remainderUnder context.namespaces context.lookup head ) of
                ( "customAttribute", Just [ "Unsafe", "Attributes" ] ) ->
                    Just ( CustomAttribute, namespaceOf context head )

                ( "fromHtmlAttribute", Just [ "Unsafe", "Attributes" ] ) ->
                    Just ( FromHtmlAttribute, namespaceOf context head )

                _ ->
                    Nothing

        _ ->
            Nothing


{-| The brand namespace an escape resolved under — its module minus the
`Unsafe.Attributes` remainder.
-}
namespaceOf : ModuleContext -> Node Expression -> List String
namespaceOf context head =
    case Lookup.moduleNameFor context.lookup head of
        Just moduleName ->
            List.take (List.length moduleName - 2) moduleName

        Nothing ->
            []


fromEscape : ModuleContext -> Node Expression -> Node Expression -> List (Node Expression) -> List Candidate
fromEscape context node head args =
    case ( escapeAt context head, args ) of
        ( Just ( CustomAttribute, namespace ), nameNode :: valueNode :: _ ) ->
            case stringLiteral nameNode of
                Just attrName ->
                    attributeCandidate context node head namespace attrName (isBareValue valueNode)

                Nothing ->
                    []

        ( Just ( FromHtmlAttribute, namespace ), inner :: _ ) ->
            fromRawAttribute context node head namespace inner

        _ ->
            []


{-| Classify the raw `Html.*` attribute an escape lifts.
-}
fromRawAttribute : ModuleContext -> Node Expression -> Node Expression -> List String -> Node Expression -> List Candidate
fromRawAttribute context node head namespace inner =
    case Node.value inner of
        Expression.ParenthesizedExpression deeper ->
            fromRawAttribute context node head namespace deeper

        Expression.Application (rawHead :: rawArgs) ->
            classifyRaw context node head namespace rawHead rawArgs

        Expression.OperatorApplication "<|" _ rawHead rawArg ->
            classifyRaw context node head namespace rawHead [ rawArg ]

        _ ->
            []


classifyRaw : ModuleContext -> Node Expression -> Node Expression -> List String -> Node Expression -> List (Node Expression) -> List Candidate
classifyRaw context node head namespace rawHead rawArgs =
    case ( Node.value rawHead, Lookup.moduleNameFor context.lookup rawHead ) of
        ( Expression.FunctionOrValue _ "attribute", Just [ "Html", "Attributes" ] ) ->
            case rawArgs of
                nameNode :: valueNode :: _ ->
                    case stringLiteral nameNode of
                        Just attrName ->
                            attributeCandidate context node head namespace attrName (isBareValue valueNode)

                        Nothing ->
                            []

                _ ->
                    []

        ( Expression.FunctionOrValue _ "on", Just [ "Html", "Events" ] ) ->
            case rawArgs of
                eventNode :: _ ->
                    case stringLiteral eventNode of
                        Just event ->
                            [ eventCandidate context node head namespace event ]

                        Nothing ->
                            []

                _ ->
                    []

        ( Expression.FunctionOrValue _ name, Just [ "Html", "Attributes" ] ) ->
            if List.member name rawAttributeEscapes || not (isElementIndependent context.globals name) then
                []

            else
                [ identityCandidate context node head namespace name False ]

        ( Expression.FunctionOrValue _ name, Just [ "Html", "Events" ] ) ->
            if List.member name rawEventEscapes then
                []

            else
                -- An event setter is element-independent by construction: it
                -- installs the same DOM listener whatever the element is.
                [ identityCandidate context node head namespace name True ]

        _ ->
            []


{-| The raw `elm/html` primitives that have NO name-identical typed setter and
must not be matched by name: they are the generic escapes themselves (handled
above, for `attribute`/`on`) or carry semantics the typed layer does not model.
-}
rawAttributeEscapes : List String
rawAttributeEscapes =
    [ "attribute", "property", "map" ]


rawEventEscapes : List String
rawEventEscapes =
    [ "on", "stopPropagationOn", "preventDefaultOn", "custom" ]


{-| An attribute escape becomes a candidate ONLY when the attribute is
element-independent (see `isElementIndependent`). Everything else is silence: the
rule cannot see which element the `Attr` lands on, so a name match would be a
guess.
-}
attributeCandidate : ModuleContext -> Node Expression -> Node Expression -> List String -> String -> Bool -> List Candidate
attributeCandidate context node head namespace attrName bare =
    if not (isElementIndependent context.globals attrName) then
        []

    else
        [ { escape = qualifiedName context head
          , namespace = namespace
          , subject = attrName
          , isEvent = False
          , wanted = attributeWants attrName
          , range = Node.range head
          , replaceRange = Node.range node
          , bare = bare
          }
        ]


eventCandidate : ModuleContext -> Node Expression -> Node Expression -> List String -> String -> Candidate
eventCandidate context node head namespace event =
    { escape = qualifiedName context head
    , namespace = namespace
    , subject = event
    , isEvent = True
    , wanted = [ { name = "on" ++ Facts.capitalize (Facts.camelize event) ++ "With", ariaOnly = False } ]
    , range = Node.range head
    , replaceRange = Node.range node
    , bare = False
    }


identityCandidate : ModuleContext -> Node Expression -> Node Expression -> List String -> String -> Bool -> Candidate
identityCandidate context node head namespace name isEvent =
    { escape = qualifiedName context head
    , namespace = namespace
    , subject = name
    , isEvent = isEvent
    , wanted = [ { name = name, ariaOnly = False } ]
    , range = Node.range head
    , replaceRange = Node.range node
    , bare = False
    }


{-| **The soundness gate.** May an attribute of this name be matched against a
typed setter of the same name, WITHOUT knowing which element it lands on?

Only when the attribute means the same thing on every element:

  - `aria-*` and `role` — ARIA is universal by definition (prefix-derived, not
    listed);
  - HTML's GLOBAL attributes — `class`, `id`, `dir`, `hidden`, … — which every
    element admits, including a custom element.

Every other attribute name is **element-specific**, and a custom element's
attribute namespace is DISJOINT from HTML's: `<raw-html content="…">` carries an
HTML string to inject, and has nothing to do with `<meta content="…">`; a
`content` setter typed for `<meta>` would be meaningless there. The rule has no
way to see the enclosing element (the escape may be built in a helper, a `let`,
or a `List.map`), so for those names it stays silent — including for names it
would sometimes get right (`src` on `<model-viewer>` does mean what HTML means,
but `src` on some other custom element need not).

That costs real true positives, and it is the right trade: a wrong suggestion
teaches people to distrust the rule, and this rule's whole value is that a
finding is always actionable.

-}
isElementIndependent : Set String -> String -> Bool
isElementIndependent globals name =
    String.startsWith "aria-" name || Set.member name globals


{-| The element-independent vocabulary actually in force: the generator's
`globalAttributes` when the caller supplies it, else the built-in fallback.

Passing the generated roster is strongly preferred — it is read from the same
HTML manifest the typed setters are emitted from, so it cannot drift from them.
The fallback exists only for a brand generated before `globalAttributes` was
emitted.

-}
globalsInForce : { c | globalAttributes : List String } -> Set String
globalsInForce config =
    case config.globalAttributes of
        [] ->
            fallbackGlobalAttributes

        supplied ->
            -- `role` and the Elm-only spellings are not HTML globals, so they are
            -- never in a generated roster; union them in either way.
            Set.union (Set.fromList supplied) elmOnlyGlobals


{-| Element-independent names the HTML manifest does not carry: the ARIA `role`
attribute, and the two convenience spellings the typed layer adds.
-}
elmOnlyGlobals : Set String
elmOnlyGlobals =
    Set.fromList [ "role", "classList", "styleList" ]


{-| FALLBACK: HTML's global attributes — the ones every element admits — plus `role` and
the two Elm-only convenience spellings the typed layer adds (`classList`,
`styleList`).

This is a hardcoded set, and deliberately so: it is the **platform's** fixed
vocabulary (the same category as the Elm reserved-word list in
`Cem.Internal.Facts`, or the `Html.Attributes` module name above), not any design
system's. It is NOT derivable from the facts — global attributes appear in no
component's `attrRewrites` — and deriving it by intersecting the generated
per-element `Attrs` rows is unsafe: those rows are only visible when the library
is a source directory, so a project that reviews ONE library's source would
intersect that library's rows alone and could conclude a brand-specific
attribute is "global", which is exactly the false positive this gate exists to
prevent.

The durable fix belongs in the generator, which reads the HTML manifest and
already knows: emit `globalAttributes : List String` beside `facts`, and this
set becomes a fallback for older generators.

-}
fallbackGlobalAttributes : Set String
fallbackGlobalAttributes =
    Set.fromList
        [ "accesskey"
        , "autocapitalize"
        , "autocorrect"
        , "autofocus"
        , "class"
        , "classList"
        , "contenteditable"
        , "dir"
        , "draggable"
        , "enterkeyhint"
        , "hidden"
        , "id"
        , "inert"
        , "inputmode"
        , "itemid"
        , "itemprop"
        , "itemref"
        , "itemscope"
        , "itemtype"
        , "lang"
        , "nonce"
        , "popover"
        , "role"
        , "slot"
        , "spellcheck"
        , "style"
        , "styleList"
        , "tabindex"
        , "title"
        , "translate"
        , "writingsuggestions"
        ]


{-| The setter names an HTML attribute name could be spelled as, derived — never
listed: the camelized name, the generator's reserved-word escape of it, and (for
`aria-*`) the prefix-stripped name restricted to an `*.Aria` module.
-}
attributeWants : String -> List Wanted
attributeWants attrName =
    let
        base =
            Facts.camelize attrName

        escaped =
            Facts.safeValue base

        plain =
            if escaped == base then
                [ { name = base, ariaOnly = False } ]

            else
                [ { name = base, ariaOnly = False }, { name = escaped, ariaOnly = False } ]
    in
    if String.startsWith "aria-" attrName then
        plain ++ [ { name = Facts.camelize (String.dropLeft 5 attrName), ariaOnly = True } ]

    else
        plain


stringLiteral : Node Expression -> Maybe String
stringLiteral node =
    case Node.value node of
        Expression.Literal value ->
            Just value

        Expression.ParenthesizedExpression inner ->
            stringLiteral inner

        _ ->
            Nothing


{-| Does the escape write a BARE boolean attribute — an empty string value?

Only the empty string qualifies, because a `Bool` setter renders exactly
`name=""` and the rewrite must be **byte-identical** in the DOM.
`customAttribute "inert" "true"` is still reported (the typed setter exists), but
it is NOT autofixed: it renders `inert="true"`, and a custom element that reads
the raw value (`getAttribute("open") === "true"`) would see a different string
after the rewrite. HTML boolean semantics say the two are the same; a
custom-element author's JS may not.

-}
isBareValue : Node Expression -> Bool
isBareValue node =
    stringLiteral node == Just ""


qualifiedName : ModuleContext -> Node Expression -> String
qualifiedName context node =
    case ( Node.value node, Lookup.moduleNameFor context.lookup node ) of
        ( Expression.FunctionOrValue _ name, Just moduleName ) ->
            String.join "." (moduleName ++ [ name ])

        ( Expression.FunctionOrValue _ name, Nothing ) ->
            name

        _ ->
            ""



-- RESOLUTION + REPORTING


{-| A typed setter the rule has evidence for.
-}
type alias Resolved =
    { moduleDotted : String
    , name : String
    , takesBool : Bool
    }


finalEvaluation : List String -> ProjectContext -> List (Error { useErrorForModule : () })
finalEvaluation setterModules projectContext =
    projectContext.pending
        |> List.concatMap (reportModule setterModules projectContext.setters)


reportModule : List String -> Dict String Bool -> PendingModule -> List (Error { useErrorForModule : () })
reportModule setterModules harvested pending =
    pending.candidates
        |> List.filterMap
            (\candidate ->
                -- Preference order is per ESCAPE: the brand the escape itself
                -- came from is tried first, so a module holding two brands'
                -- escapes gets each one's own library suggested.
                resolve (brandFirst candidate.namespace setterModules) harvested candidate
                    |> Maybe.map (escapeError pending candidate)
            )


{-| Try the escape's own brand's setters before another library's: a stable
partition on "is this suggestion under the escape's namespace".
-}
brandFirst : List String -> List String -> List String
brandFirst namespace items =
    let
        prefix =
            String.join "." namespace ++ "."

        ( own, others ) =
            List.partition (String.startsWith prefix) items
    in
    own ++ others


{-| The first setter, in preference order, that the rule has EVIDENCE for:
each candidate name is looked for in the setter modules (in order) and then in
the facts. No evidence → `Nothing` → silence.
-}
resolve : List String -> Dict String Bool -> Candidate -> Maybe Resolved
resolve setterModules harvested candidate =
    candidate.wanted
        |> List.filterMap (fromSetterModules setterModules harvested)
        |> List.head


fromSetterModules : List String -> Dict String Bool -> Wanted -> Maybe Resolved
fromSetterModules setterModules harvested wanted =
    setterModules
        |> List.filterMap
            (\moduleDotted ->
                if wanted.ariaOnly && not (String.endsWith ".Aria" moduleDotted) then
                    Nothing

                else
                    Dict.get (moduleDotted ++ "." ++ wanted.name) harvested
                        |> Maybe.map
                            (\takesBool ->
                                { moduleDotted = moduleDotted, name = wanted.name, takesBool = takesBool }
                            )
            )
        |> List.head



-- ERROR


escapeError : PendingModule -> Candidate -> Resolved -> Error { useErrorForModule : () }
escapeError pending candidate resolved =
    let
        setter =
            resolved.moduleDotted ++ "." ++ resolved.name

        fixes =
            boolFix pending candidate resolved
    in
    Rule.errorForModuleWithFix pending.key
        { message = escapeMessage candidate setter
        , details = escapeDetails candidate setter (not (List.isEmpty fixes))
        }
        candidate.range
        fixes


escapeMessage : Candidate -> String -> String
escapeMessage candidate setter =
    if candidate.isEvent then
        "Redundant escape: `" ++ candidate.escape ++ "` wires the `" ++ candidate.subject ++ "` event, which `" ++ setter ++ "` already provides"

    else
        "Redundant escape: `" ++ candidate.escape ++ "` writes the `" ++ candidate.subject ++ "` attribute, which `" ++ setter ++ "` already provides"


escapeDetails : Candidate -> String -> Bool -> List String
escapeDetails candidate setter fixable =
    [ "`"
        ++ candidate.escape
        ++ "` produces an `Attr` with a FREE capability row, so the compiler no longer checks which elements admit `"
        ++ candidate.subject
        ++ "`. `"
        ++ setter
        ++ "` is the typed setter for it: it carries the capability the element's closed row must list, so a misplaced attribute is a compile error instead of a silent no-op."
    , "Use `"
        ++ setter
        ++ "` and reserve `"
        ++ candidate.escape
        ++ "` for what the typed layer genuinely cannot express — a custom-element attribute with no generated setter."
    ]
        ++ (if fixable then
                []

            else
                [ "No autofix here: the escape's value has to be translated into `" ++ setter ++ "`'s argument (a value token, a decoder, or a different arity), which is a human decision." ]
           )


{-| The one unambiguous rewrite: a bare boolean attribute whose resolved setter
was HARVESTED with a `Bool` first argument. Uses the module's existing alias
when it has one, and inserts the import when it is missing.
-}
boolFix : PendingModule -> Candidate -> Resolved -> List Fix.Fix
boolFix pending candidate resolved =
    if not (candidate.bare && resolved.takesBool) then
        []

    else
        case Dict.get resolved.moduleDotted pending.imports of
            Just qualifier ->
                [ Fix.replaceRangeBy candidate.replaceRange (qualifier ++ "." ++ resolved.name ++ " True") ]

            Nothing ->
                [ Fix.replaceRangeBy candidate.replaceRange (resolved.moduleDotted ++ "." ++ resolved.name ++ " True")
                , Fix.insertAt
                    { row = pending.insertionRow + 1, column = 1 }
                    ("import " ++ resolved.moduleDotted ++ "\n")
                ]
