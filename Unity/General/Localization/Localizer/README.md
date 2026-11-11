# Localizer

Localizer is a Unity localization utility for composing translated text and
keeping TextMesh Pro labels in sync with the selected language. Store sentences,
reusable names and phrases in JSON; bind keys to labels; choose fonts and styles
per language.

**Recursive keys are a central feature.** Pass another key as an argument and
Localizer translates it before inserting it into the surrounding sentence. You
can also pass a key with its own arguments. This keeps reusable text reusable,
without assembling translated sentences by hand or adding a second resolver.

[Setup](#setup-and-resource-files) · [Recursive keys](#recursive-keys-compose-translations) ·
[Language switching](#loading-and-changing-languages) ·
[Text and styles](#textmesh-pro-components-and-styles) ·
[Font catalogue](#creating-your-own-font-catalogue) · [Dependencies](#reusing-this-folder)

Distributed through [Lowke Media Libraries](https://github.com/lowkemedia/Libraries).
Supply your own translations and fonts, and retain the source copyright and MIT
licence notices when copying the utility.

## Setup and resource files

The API is static; basic string lookup does not require a Localizer component in
a scene. Initialize it before loading files or looking up keys:

```csharp
using LocalizerTypes;

Localizer.Root = "Localization/"; // Resources-relative; include the trailing slash
Localizer.Initialize(LanguageCode.en_GB, clearFiles: true);
Localizer.AddFile("Common");     // omit language suffix and .json
```

With this root, `Common` loads from
`Assets/Resources/Localization/English/Common_en_GB.json`. Switching to `fr_FR`
loads `Assets/Resources/Localization/French/Common_fr_FR.json`.
Regional codes follow the same lookup: `en_US` maps to
`Assets/Resources/Localization/American/Common_en_US.json`, using the existing
`LanguageType.American` enum entry. It does not alias `en_GB` or convert its text.
`GetLanguageNameString` distinguishes the English regional display names without
changing their resource paths.
`FullFileName("Common")` returns the Resources-relative path without `.json`.
An empty root omits both the root and language folder, yielding `Common_en_GB`.
Folder names and suffixes come from the aligned enums in
[LocalizerTypes.cs](LocalizerTypes.cs).

Each string file contains a `keys` array. For example, the English file:

```json
{
    "keys": [
        { "key": ".greeting", "value": "Hello, {0}!" },
        { "key": ".visitor", "value": "visitor" },
        { "key": ".item.star", "value": "Star" },
        { "key": ".item.label", "value": "{0} <sprite=\"Badge {1}\" index=0>" }
    ]
}
```

The corresponding French file:

```json
{
    "keys": [
        { "key": ".greeting", "original": "Hello, {0}!", "value": "Bonjour, {0} !" },
        { "key": ".visitor", "original": "visitor", "value": "visiteur" },
        { "key": ".item.star", "original": "Star", "value": "Étoile" },
        { "key": ".item.label", "original": "{0} <sprite=\"Badge {1}\" index=0>", "value": "{0} <sprite=\"Badge {1}\" index=0>" }
    ]
}
```

`key` and `value` supply the lookup. Optional `original`, `context`, `citation`
and `note` fields hold authoring metadata; they do not change substitution.
`FileName` and `Variables` are runtime bookkeeping, not translation inputs.
See [LocalizerValue.cs](KeyValues/LocalizerValue.cs) for the fields the runtime
actually reads. Additional JSON metadata is ignored by Unity’s deserializer;
the exporter does not preserve arbitrary extra fields.

## Recursive keys: compose translations

A reusable name should not need to be translated again in every label that uses
it. With the JSON above, `.visitor` can appear by itself or inside `.greeting`:

Keys start with `.` and are looked up after conversion to lowercase. Use
consistent lowercase key names. A non-key argument is literal text:

```csharp
Localizer.Value(".greeting|Alex");             // Hello, Alex!
Localizer.Value(".greeting|.visitor");         // Hello, visitor!
Localizer.Value(".greeting", new[] { ".visitor" }); // same recursive lookup
```

After switching to French, the second example returns `Bonjour, visiteur !`.
The implementation calls `Value` on each argument before replacing `{0}`, `{1}`,
and so on. **Pass a key when an argument needs translation.** There is no separate
argument dictionary, flag or automatic translation of English literal words.
Use one argument source per call: pipe-delimited arguments or the `variables`
array. If both are supplied, the array wins and the call can issue a warning.

### A key with its own arguments

Add this entry to each language's `keys` array (translate the surrounding wording
as needed):

```json
{ "key": ".notification", "value": "[{0}] {1}" }
```

Then pass a complete expression as an argument:

```csharp
Localizer.Value(".notification", new[] { "09:30", ".greeting|.visitor" });
// English: [09:30] Hello, visitor!
// French:  [09:30] Bonjour, visiteur !
```

The outer lookup resolves `.greeting|.visitor`; that lookup resolves `.visitor`;
then each result is inserted into its parent's template. No pre-translation call
is needed. The same expression works on a live UI label:

```csharp
messageLabel.AddKey(".notification", new[] { "09:30", ".greeting|.visitor" });
```

Unlike assigning a previously resolved string to `messageLabel.text`, this keeps
the keys and arguments available so the entire label can be translated again on
a language change. To change the timestamp or other application data, call
`AddKey` again with the new arguments; it reuses the existing component.

Use the array overload at the outer level when an argument contains its own
`|` parameters. `.notification|09:30|.greeting|.visitor` is **not** equivalent:
its pipes describe three sibling arguments, not a nested expression. The same
principle applies when passing a compound `+` expression as one argument.

### Let translators own the sentence

Placeholders can repeat or change order within a translation. Substitution uses
literal string replacement, not `string.Format`: format specifiers, plural rules
and grammatical inflection are not provided. Use separate keys for forms or
phrases that need different wording. Reuse a word only where its grammatical
form fits; a standalone menu label is not necessarily the right form inside
every sentence. Supply all required arguments; missing
arguments leave their placeholders in the result.

A `value` is a template, not another expression to evaluate automatically.
For example, a value consisting of `.visitor` is not an alias. Recursive lookup
occurs when a key is supplied as an argument.

### Keep display words separate from asset identifiers

Substitution applies everywhere in a value, including rich-text tags. If a
display word is localized but also names an asset, use separate arguments:

```csharp
Localizer.Value(".item.label|.item.star|Star");
// English: Star <sprite="Badge Star" index=0>
// French:  Étoile <sprite="Badge Star" index=0>
```

Here `{0}` is the translated word and `{1}` is the literal asset identifier.
Translate the prose; preserve exact sprite names, Unicode characters and tag
syntax. Keep intentional spaces, non-breaking spaces and line breaks in values.
Localizer does not resolve sprites, supply missing glyphs or verify layout;
those are responsibilities of the text renderer and the application’s assets.

## Compound expressions

`+` joins expressions. Localizer inserts one space between consecutive key
expressions, but no automatic space next to a literal segment:

```csharp
Localizer.Value(".visitor+.item.star");  // visitor Star
Localizer.Value(".visitor+<br>+.item.star"); // visitor<br>Star
Localizer.Value(".greeting|.visitor+<br>+.item.star");
```

Put explicit punctuation, spaces or markup in literal segments where required.
A supplied `variables` array is passed to every component of a compound lookup.

The expression syntax splits `+` first, then `|`; it has no quoting or escape
syntax for those delimiters. A leading `.` identifies a key. Do not treat
arbitrary input containing these characters as safely opaque literal text.
Keep complicated prose in JSON values and use simple arguments. Literal `+` or
`|` characters inside a loaded value are not reparsed as expression delimiters.

## Loading and changing languages

A typical setup registers common UI text once, then loads larger content files
only when needed:

```csharp
Localizer.AddFile("Menus");
Localizer.AddFile("Dialogs");
Localizer.LoadFile("ChapterOne"); // current content, not a permanent registration

// Registered files and bound labels refresh automatically:
Localizer.LanguageCode = LocalizerTypes.LanguageCode.fr_FR;
```

Supply each file in every supported language. If the chapter remains visible,
reload its file in a language-change listener **before** its labels refresh.
For a simpler application, register the chapter with `AddFile` too.

For device-language matching before initialization, see the sibling
[StartupLanguage guide](../README.md#choosing-a-startup-language). Pass the host's
supported locales and default explicitly; Localizer does not determine them.

- `AddFile(name)` loads a file and records it for subsequent language changes.
  Register each persistent file once; repeated calls add repeated registrations.
- `LoadFile(name)` loads into the current dictionary without recording the file.
  Use it for transient content and arrange for the application to reload that
  content when the language changes.
- Setting `LanguageCode`, `LanguageType` or `LanguageName` calls `Initialize`.
  It clears the key dictionary, reloads the selected style file and registered
  string files, then invokes `OnLanguageChangedEvent`.
- `Initialize(language, clearFiles: true)` also clears the registered string-file
  list. It does not clear the selected style file, event subscribers or
  `VariablesTinkerer` delegate.

All loaded files share one key namespace. A later duplicate overwrites the
earlier entry and normally warns. There is no automatic fallback language: a
missing file is not replaced by its English counterpart, and a missing key
returns the key text with a diagnostic. Load the needed files before rendering.

Custom UI code can subscribe to `OnLanguageChangedEvent`; unsubscribe when the
owner is destroyed. Register any transient-file loader before UI refresh
listeners that depend on it. Language selection persistence is the consuming
application’s responsibility.

## TextMesh Pro components and styles

For a `TextMeshProUGUI` field, use the extension in
[Stylizer.cs](Stylizer/Stylizer.cs):

```csharp
textField.AddKey(".greeting|.visitor");
// Or, after loading a style file:
Localizer.SetStyle("_Styles");
textField.AddKey(".greeting|.visitor", style: "#body");
```

`AddKey` attaches or reuses [LocalizedText](Stylizer/LocalizedText.cs). It retains
the key, arguments and style, refreshes after language changes, and unsubscribes
on destruction. `AddStyle(text, style)` applies a style to literal text through
the same component. Stylizer expects baseline alignment on the text field.
Language-change refreshes retain the `giveWarning` setting passed to `AddKey`;
`AddStyle` supplies `false` so literal numbers and other non-key text do not
produce invalid-key warnings when the language changes. This does not override
Logger's automatic-alert setting for diagnostics that are emitted.

Style files use the same locale path convention and contain a `styles` array.
Entries have `style`, `font`, `fontSize`, `lineSpacing`, `characterSpacing`,
`color` and `outlineColor` fields. Style names are looked up in lowercase;
the `#` prefix is a naming convention. Set numeric values deliberately: omitted
numeric JSON fields default to zero, which is not an “unchanged” setting.

The host supplies `Stylizer.FontResolver` before applying styles. It receives
exactly the `font` string from the style JSON and returns a `TMP_FontAsset`:

```csharp
// applicationFonts is a Dictionary<string, TMP_FontAsset> owned by your app.
Stylizer.FontResolver = name =>
    applicationFonts.TryGetValue(name, out var font) ? font : null;
Localizer.SetStyle("_Styles");
```

A catalogue method with the same signature can be assigned directly. Return null
for unknown names or missing assets; Stylizer reports the failure once through
Logger and retains the text field's existing font. A missing resolver is also
reported when a style requests a font. Both diagnostics respect Logger's global
automatic-alert setting. Styles without a font need no resolver. Do not log the
same lookup failure in the resolver as well.

Localizer owns no font catalogue, resource path or font-name mappings. The host
owns asset loading and lifetime. Font coverage, fallback chains, sprite assets
and material settings remain configured in TextMesh Pro.

`LocalizedText` also recognizes `.languageString`, `.languageName`,
`.languageType` and `.languageCode` as display shortcuts. These are component
shortcuts, not ordinary dictionary keys handled specially by `Localizer.Value`.

### Inline font styles

For a heading inside body text, use a style reference in the compound expression:

```csharp
textField.AddKey("<font=\"#title\">+.greeting+</font>+.introduction", style: "#body");
```

`LocalizedText` resolves the translated expression, then `Stylizer.ResolveInlineFonts`
replaces `<font="#title">` with the current style's `font` name on every refresh.
Use the lowercase style name and double-quoted tag syntax shown above. This
selects only the font; size and other layout tags remain explicit. Load the style
file before binding the text. Literal font names and sprite tags are unaffected.
Keep translated words in the keys and locale-specific font choices in Styles.
`Localizer.Value` itself returns text without resolving these presentation tags;
non-component consumers can call `Stylizer.ResolveInlineFonts` when needed.

## Creating your own font catalogue

[Examples/SetOfFonts.cs.txt](Examples/SetOfFonts.cs.txt) is a complete, minimal
ScriptableObject catalogue with `Title` and `Body` slots. It depends only on
Unity and TextMesh Pro. The `.txt` suffix keeps the template from compiling or
colliding with a consuming application's own `SetOfFonts` class.

1. In your application code folder, copy the template as **SetOfFonts.cs**, removing
   `.txt`. Do not add a second class if your application already has that name;
   use the example to adapt your existing catalogue instead.
2. Import your chosen font files and create their **TMP Font Assets**. In TMP 3,
   select a source font and use **Assets → Create → TextMeshPro → Font Asset**, or
   use **Window → TextMeshPro → Font Asset Creator** to generate an atlas with
   a chosen character set. The catalogue slots take `TMP_FontAsset` assets,
   not the original `.ttf` or `.otf` files.
3. Create an `Assets/Resources` folder if needed. Inside it, use
   **Create → Localization → Set of Fonts**, name the asset **My Fonts**, and
   drag your TMP assets into its **Title** and **Body** Inspector slots. Both
   slots may use the same font for an initial test.
4. Save this style file as
   `Assets/Resources/Localization/English/_Styles_en_GB.json`:

```json
{
    "styles": [
        { "style": "#title", "font": "Title", "fontSize": 48,
          "lineSpacing": 0, "characterSpacing": 0 },
        { "style": "#body", "font": "Body", "fontSize": 32,
          "lineSpacing": 0, "characterSpacing": 0 }
    ]
}
```

5. In your application's initialization, before localized UI applies styles:

```csharp
var fonts = UnityEngine.Resources.Load<SetOfFonts>("My Fonts");
if (fonts == null) {
    throw new System.InvalidOperationException("Missing Resources/My Fonts asset.");
}
Stylizer.FontResolver = fonts.GetFont;
Localizer.Root = "Localization/";
Localizer.Initialize(LocalizerTypes.LanguageCode.en_GB, clearFiles: true);
Localizer.SetStyle("_Styles");

// textField is an existing TextMeshProUGUI component in your scene.
textField.alignment = TMPro.TextAlignmentOptions.Baseline;
textField.AddStyle("Hello", "#body");
```

This initial check uses literal text so it needs no translation file. For
translated text, load your string file and use `AddKey` as described above.
Run this setup once, before UI components call `AddKey`/`AddStyle`; do not rely
on the order of unrelated components' `Awake` methods. In an existing application,
add the resolver assignment to its established localization initialization.

`Title` and `Body` are case-sensitive lookup names, not required font filenames.
To add another font, add a slot and a matching `GetFont` case, assign its asset,
and use that name in the relevant locale's style JSON. For example, a `BodyJapanese`
slot can select a different font for a Japanese `#body` style. Supply the style
file for each locale you enable. A serialized reference to the catalogue can
replace `Resources.Load`; the resource path is only this example's loading choice.

### Rebuilding the catalogue or a font

The catalogue stores references; it contains no glyphs or atlas generation logic.
To recreate it in another project, copy the example script, import or generate
that project's TMP fonts, create the catalogue asset, and assign the slots again.
No fonts or mappings from the original application are required. When moving an
existing catalogue and fonts together, preserve their `.meta` files so Unity's
references survive. Keep a populated catalogue in place when only updating fonts.

Regenerating a TMP font is separate: use its source font and the Font Asset Creator
(or its supported atlas-update workflow), preserve needed characters and material
settings, then check the catalogue reference still points to the intended asset.
Static atlases need the required characters baked in. Dynamic assets need a valid
source font and suitable atlas settings. Configure additional script coverage in
TMP's fallback font assets and test representative text; assigning a font to the
catalogue does not add missing characters. Check both glyphs and inline sprites
visually after atlas or fallback changes. Sprite asset names are independent of
these font aliases and must remain unchanged.

## Application hooks and diagnostics

`VariablesTinkerer` is an optional `string[] -> string[]` delegate invoked before
argument substitution. Applications may use it to resolve dynamic data or their
own function syntax. The core Localizer does not interpret function names.
Keep such application rules in the host rather than adding them to key lookup.

`Testing = true` returns `*` in place of resolved values to help find UI text
that bypasses localization. `LocalizerValue(key)` returns the loaded entry;
`Citation(key)` retrieves its citation and requires the key to exist.
`FindKey(value)` searches for an exact stored value and returns the first match;
it is not a reverse translation service.

## Reusing this folder

The current source uses Unity, TextMesh Pro and companion utilities:
`JsonReader`, `Logger`, `UtilsArray`, `UtilsString`, `UtilsColor` and
`CallbackTypes`. The consuming application owns its language-selection UI and
supported-locale list. Its controls set `Localizer.LanguageCode`; no scene-button
controller or application locale list is included in this reusable folder.
Keep the three language enums aligned when adding a language.

[LocalizerExport](LocalizerExport.cs) writes into a `JsonKeys` directory relative
to the working directory; create that directory before exporting. Its JSON
exports resolve placeholders to values, so they are not a lossless backup of
parameterized templates or metadata. The page-text exporter currently contains
a fixed product/copyright footer; adapt that host-specific output when reusing
it. Preserve source JSON separately.

Font resolution is supplied through the delegate above. The export footer remains
an integration point in this copy, not a requirement of the reusable Localizer.
