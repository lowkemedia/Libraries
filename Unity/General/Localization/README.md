# Localization

These utilities have separate responsibilities:

- [LanguagePreference](LanguagePreference/README.md) reads ordered device language tags.
- [StartupLanguage](StartupLanguage.cs) matches those tags against locales supplied by the application.
- [Localizer](Localizer/README.md) loads strings and styles and updates localized text.

## Choosing a startup language

The application supplies both its supported locales and its default. Put the
preferred regional version of each language first in the supported list:

```csharp
using LocalizerTypes;

var supported = new[] { LanguageCode.en_GB, LanguageCode.en_US, LanguageCode.fr_FR };
var selection = StartupLanguage.Resolve(
    LanguagePreference.GetPreferredLanguages(), supported, LanguageCode.en_GB);

Localizer.Initialize(selection.Language, clearFiles: true);
// Register this application's string files and styles separately.
```

Preferences are considered in device order. For each preference, an exact
supported locale wins before looking for a supported version of the same core
language. With the example list, `en-US` selects US English, `en-AU` and `en`
select UK English, and `fr-CH` and `fr` select French. Reversing the two English
entries makes generic English select US English while an exact `en-GB` still
selects UK English. Unsupported preferences are skipped so a later supported
language can be chosen. No match, null or empty preferences select the supplied
default. Null/blank preference entries are ignored; underscores are normalized
to hyphens, and matching is case-insensitive. Supported locales are never inferred
from the LanguageCode enum or another global list.

The default must be in the supported list. A null supported list or a list without
the default is a configuration error and throws an argument exception. An empty
list therefore cannot select an unshipped fallback.

`Resolve` returns a `StartupLanguage.Result`:

- `Language`: the selected locale.
- `Match`: `Exact`, `Regional`, or `Fallback`. Selecting the configured default
  after skipping an unsupported preference is also reported as `Fallback`, so
  applications can distinguish this from a directly preferred default language.
- `FirstPreference`: the first nonblank normalized device tag, or null.
- `MatchedPreference`: the tag that matched, or null when none matched.

The resolver has no logging, alerts, branding, scene, saved-setting or font
behavior. It does not initialize Localizer. The application decides what to log
or display from the result and whether to apply it only at startup or on later
settings changes. Core-language matching does not distinguish writing scripts;
introduce a script-aware policy before relying on automatic matching between
locales that require different scripts.

## Reuse

StartupLanguage depends only on the standard C# libraries and
`LocalizerTypes.LanguageCode`. Copy its `.cs` file along with that enum definition.
See each utility's own README for its other dependencies and integration points.
Fonts remain supplied and configured by the consuming application. Set
`Stylizer.FontResolver` before applying styles; see the [Localizer README](Localizer/README.md)
for the contract and example. StartupLanguage does not select or alter font assets.
