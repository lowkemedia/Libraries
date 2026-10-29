# LanguagePreference

Reports the user's operating-system language preferences in preference order.
This General utility is independent of Localizer, scenes and saved application
settings. A missing native bridge is reported through Alert and its Logger dependency.

```csharp
string[] languages = LanguagePreference.GetPreferredLanguages();
// For example: ["fr-CH", "de-CH", "en-GB"]

string first = LanguagePreference.GetPreferredLanguage();
// "fr-CH", or null if preferences could not be obtained.
```

Call on Unity's main thread. Each call reads a new snapshot; no preference is
cached by this utility. Query again on app resume if appropriate. Apple may
restart the app, or require a restart, when language settings change.

## Contract and boundaries

- An empty array (or null for the singular method) means unavailable. It never
  silently substitutes English or another default.
- Entries use hyphen-separated language tags. Underscores are replaced, surrounding
  whitespace is trimmed, and case-insensitive duplicates are removed while retaining
  the first occurrence. Original casing, preference order, regions, scripts and
  extensions are preserved. Blank, malformed and `und` (undetermined) entries are
  skipped. The shape check is not a complete BCP 47 registry validator.
- The array belongs to the caller. Modifying it cannot affect subsequent reads.
- Tags describe preferences, not residence. `fr-CH` is Swiss French;
  `de-CH` is Swiss German; `zh-Hant` and `zh-Hans` retain their script distinction.
  Tags are not restricted to translations shipped by an application.
- No network, geolocation, permission request or settings write occurs. Missing
  native bindings show a System Alert through `Alert.Warning`, once per runtime
  session, including the exception type and message. The alert remains visible
  even when automatic Logger alerts or console logging are disabled. The helper
  also logs the diagnostic (`LanguagePreferenceID.WARNING_NATIVE_BINDING_UNAVAILABLE`,
  still `LANG00`) when warning logging is enabled, without a
  duplicate alert. Detection still returns an empty array for the caller to handle.
  Unsupported platforms and ordinary language fallback do not trigger this alert.

The application decides how to honor its own saved override, match preferences to
available translations and choose a final fallback. For example, it might map
`fr-CH` to `LocalizerTypes.LanguageCode.fr_FR`; this utility deliberately does not
make that decision or initialize Localizer. Keep an unsupported first preference
in the list so a caller can consider later preferences in their original order.

## Platform support

| Platform | Behavior |
| --- | --- |
| iOS / iPadOS | Native `NSLocale.preferredLanguages`, as exposed to the app process. |
| tvOS / Apple TV | The same Foundation bridge as iOS. |
| Unity Editor on macOS | Reads the Mac user's ordered preferences with `CFLocaleCopyPreferredLanguages`, regardless of the selected build target. |
| Android | Placeholder returns unavailable. Extend `GetAndroidLanguages` to read the app's effective locale list, including OS per-app preferences. |
| WebGL | Placeholder returns unavailable. Extend `GetWebGLLanguages` with a `.jslib` adapter for `navigator.languages`. |
| Other Editors / other platforms | Returns unavailable. |

The macOS Editor calls the built-in CoreFoundation framework directly; no
compiled Editor plug-in or external command is needed. It reports the host Mac's
preferences, not an attached device's. After changing macOS language settings,
restart Unity if it still reports cached OS preferences. Applications that select
their language only at startup also need a fresh localization initialization.

## Apple integration and reuse

Copy this whole folder into a Unity project's `Assets` tree, along with Alert,
Logger and their dependencies. Keep the native source with the managed class. In the
Plugin Inspector for `Native/LanguagePreferenceApple.mm`, disable **Any Platform**
and **Editor**, enable **iOS** and **tvOS**, and leave CPU as **AnyCPU**. Unity
includes this Objective-C++ source in the exported Xcode project; Foundation is
already part of Unity's Apple players. There are no third-party packages.

The consuming Unity project supplies these importer settings in its `.meta` file.
Libraries does not distribute `.meta` files: check the Plugin Inspector when
copying from Libraries into another project. Preserve an existing consumer's GUIDs.

Apple's per-app language UI depends on the languages declared by the application.
For translations stored outside `.lproj` folders, the app's build process should
declare its supported languages in `CFBundleLocalizations`. That list belongs to
the application, not this utility. This folder does not edit `Info.plist` or claim
that a particular application already exposes the per-app language selector.
It reads the preferences Apple makes visible to the process, including a per-app
choice where configured; it does not use `NSBundle.preferredLocalizations`, which
would filter the answer through the bundle's supported languages.

See [Apple's language-selection guidance](https://developer.apple.com/library/archive/qa/qa1828/_index.html),
[NSLocale.preferredLanguages](https://developer.apple.com/documentation/foundation/nslocale/preferredlanguages)
and [Unity's native plug-in guidance](https://docs.unity3d.com/2022.3/Documentation/Manual/PluginsForIOS.html).

## Verification when integrating

In an iOS player, inspect the returned array with French/Switzerland and
German/Switzerland preferences, reverse their order, and include an unsupported
language ahead of a supported one. Test an explicit per-app language after
declaring the app's supported languages. Restart after changing settings if needed.
On Apple TV, repeat with its preferred-language list. Test script-bearing tags
such as `zh-Hant-TW` and `zh-Hans-CN` without collapsing them to `zh`.

Editor tests verify normalization and read the actual host preferences on macOS;
they cannot establish mobile-device preferences or per-app Settings behavior. Compile the
native source for both Apple targets and verify its importer configuration as
well as doing device checks. No changes to the game's Settings UI are needed to
test this utility.
