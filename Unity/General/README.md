# Lowke Media Unity utilities

## Animatem

[Animatem](Animatem/README.md) is a code-driven tween and animation utility for
Unity. Compose movement, scaling, fades and delays, with easing and velocity-based
effects, to animate GameObjects and UI elements.

Attach Animatem to a scene object. Each target's [Anime](Animatem/Anime.cs) holds
its effects; extend [AnimatemEffect](Animatem/Effects/AnimatemEffect.cs) to create
your own. Browse the [effects](Animatem/Effects/) and
[effect options](Animatem/AnimatemTypes.cs) to see how they fit together.

Read the **[Animatem guide](Animatem/README.md)** for working examples, or explore
**[Parabola easing](Animatem/README%20Parabola.md)**: choose how far a tween has
travelled at a particular time, with illustrated curves and settings used in
Ages of Chess.

## Other utilities

**“Do one thing well and people will use it.”** General is a collection of focused
C# utilities that work together: animation, logging, system alerts, sound, Canvas
controls, localization and smaller helpers. Choose what you need and include its
companion dependencies. This is source code to copy into a Unity project, not a
framework to adopt or a Unity Package Manager package.

| Utility | What it provides | Setup and dependencies |
| --- | --- | --- |
| [Logger](#logger) | Severity, diagnostic IDs, filtering, optional stack traces and once-only messages. | Copy Logger.cs; no scene component or Alert required. |
| [SystemUI](SystemUI/README.md) | Runtime alerts before normal UI is ready; synthesized Beep and Click. | Alert creates its host. Include Logger and CallbackTypes; sounds need an AudioListener. |
| [Coroutine](Coroutine/) | Delayed callbacks, fades and movement. | Attach the selected component; include its helper dependencies. |
| [CanvasUI](CanvasUI/README.md) | Buttons, dialogs, popups, swiping and paging. | Supply Canvas/EventSystem, UI objects, styles and any required TextMesh Pro assets. |
| [Localization](Localization/README.md) | Device preferences, startup-language matching, strings and text styles. | Supply supported locales, translations and font resolution; Apple device preferences use the included native bridge. |
| [SoundHelper](Sound/README.md) | Playback of configured AudioSources, with optional completion callbacks. | Attach SoundHelper for its convenience methods/callbacks; include Logger and CallbackTypes. |
| [Utils](Utils/), [Json](Json/), [ImageComposite](ImageComposite/), [Video](Video/) | Data/geometry helpers, resource JSON, image composition and video controls. | Dependencies vary by file; video controls need configured player/UI references. |
| [Event and Delegate](<Event and Delegate/>) | Callback declarations and event examples. | Read the examples alongside the utility that uses the callbacks. |

## Using the utilities

For Animatem, include its effects/types, Logger, CallbackTypes and GlobalState.
On handheld devices, its `Start()` sets application frame-rate and Unity timing
values; inspect that policy when integrating it into an application.

Copy selected files under your project's `Assets` tree, retaining their source
notices. Follow referenced class names as well as `using` directives: many types
live in the global namespace. If updating an existing project, preserve its
`.meta` files and GUIDs; the Libraries repository ignores `.meta` files. General does not supply
scenes, prefabs, fonts, translations, assembly definitions or project settings.

Logger is a small starting point:

```csharp
Logger.Detail("Content loaded");       // Normally no diagnostic ID needed.
Logger.Print(">> reached this point"); // Informal development trace.
```

With SystemUI and its dependencies copied, a runtime caller can use:

```csharp
Alert.Info("Ready to begin.", "Welcome");
Alert.Question("Apply these changes?",
    onAcknowledged: () => Logger.Detail("Changes accepted"),
    onCancel: () => Logger.Detail("Changes cancelled"));
```

Alert uses IMGUI and uGUI pointer blocking. Its outside-click handling uses legacy
`UnityEngine.Input`; enable the legacy Input Manager or Both input systems in the
consumer. It works in Play Mode, not as an Editor preview or native OS dialog.
See the [SystemUI guide](SystemUI/README.md) for the exact copy list and lifecycle.

General has no declared minimum Unity version or bundled standalone test suite. Compile and exercise the chosen subset in your Unity project, including
UI and sound on the target device. TextMesh Pro, uGUI and video APIs are required
only by the utilities that use them. Retain each file's copyright, permission and attribution notices when copying it.

## Logger

Utilities that call `Logger` require [Logger.cs](Logger/Logger.cs). This includes
Animatem, coroutine helpers, JsonReader, Localizer/Stylizer, parts of CanvasUI,
SoundHelper, VideoController, Utils/UtilsString and SystemUI's Alert. Use the
existing `Logger.Debug`, `Detail`, `Info`, `Print`, `Warning` and `Severe` helpers for ordinary
diagnostics; the shared `Logger.Log` pipeline is private. Logger owns filtering,
formatting, once-only messages and stack traces. The public severity helpers
always honour `ShowAlert`; they expose no suppression flag. The assembly-internal
`Logger.LogNoAlert(level, message, id)` is reserved for explicit Alert logging to
prevent duplicate automatic alerts. It preserves console formatting and level
filtering without changing the global setting.

The helpers are static; Logger does not need to be attached to a GameObject.
`ShowAlert` defaults to false, and the logging threshold defaults to `PRINT`.
Set `Logger.Level` explicitly for a different threshold. Once-only suppression is
keyed by message text, not ID, and is recorded before level filtering; a filtered
once-only message is still remembered. Use it deliberately. Severe maps to
Unity's LogError, Warning to LogWarning, and the other helpers to Log. Editor
Error Pause can pause Play Mode on Severe; acknowledging an alert does not resume it.

This is a compile-time dependency: disabling logging or passing `log: false` to
Alert does not remove it. There is no optional Log wrapper, conditional symbol or
automatic Unity fallback when Logger is absent. Utilities without Logger references,
such as SystemUI's Beep and Click, do not need Logger themselves.

Logger itself has **no dependency on Alert or SystemUI** and can be copied alone
for Unity console logging. Its optional `AlertRequested` event lets another class
supply presentation. [LoggerAlertBridge](SystemUI/Alert/LoggerAlertBridge.cs), kept
with SystemUI, connects that event to Alert. Alert still depends
on Logger for its own logging. See [SystemUI](SystemUI/README.md#logger-integration)
for the connection and its startup behaviour.

## Unit-test log context

`Logger.TestExpected(name)` labels a sequential test or diagnostic scenario and
announces `TESTING-> name` through Print. Subsequent messages retain their severity,
ID and body, followed by `[TEST EXPECTED: name]` before any explicit stack trace.
The announcement obeys the Print threshold; automatic alerts include the label.

Call `Logger.ClearTestExpected()` on completion, including failure paths. For a
manual scenario, clear it in `finally`. A test runner can set and clear the label
for each test; runner integration is supplied by the consuming project. Helpers
should use Detail for progress messages without replacing the current test name.

The label is shared, so finish background work before clearing it and avoid
concurrent labelled scenarios. It identifies test output; it does not suppress
errors, reset once-only messages or change filtering. Keep normal log assertions
and unexpected-error checks. Direct Unity logs are not labelled.

## Named diagnostic IDs

Logger is a deliberate shared dependency: a reported diagnostic should be easy
to trace back to its source even when a debugger is impractical or unavailable.
Each General utility should keep its Severe, Warning and Info IDs, plus any
optional Detail or exceptional Debug IDs, in one block owned by that utility.
Severe, Warning and Info can appear through
`Logger.ShowAlert`; Detail is always console-only.

The level order is `SEVERE → WARNING → INFO → DETAIL → PRINT → DEBUG`.
The default `PRINT` threshold includes Detail and Print while hiding Debug.
Changing `Logger.Level` reports `DETAIL_LEVEL_CHANGED_ID` (`LOG00`) through Detail,
subject to the newly selected threshold; assigning the same level stays silent.
Use `Logger.Detail(message)` for useful lasting diagnostics that do not warrant
Info or an automatic alert. Detail normally has no ID; supply the optional `id`
only when a diagnostic benefits from a named, searchable reference.
It supports optional `showOnlyOnce` and `stackTrace`
arguments, like Info and Debug; messages repeat unless suppression is requested.

`Logger.Print` is informal development tracing, often marked with `>>`, `>>>>`
or similar arrows to stand out in the console. Its signature is
`Print(string message, bool stackTrace = false)`: **no IDs or once-only suppression**.
Every call that passes the configured log level prints, even repeated messages.
Use Debug for once-only development traces. Print statements
are usually removed when investigation is complete, or deliberately promoted to
Detail, Info, Warning or Severe if worth keeping, or kept as verbose Debug traces.
Commented-out Print calls do not need IDs either. Debug usually has no ID; an especially useful, lasting diagnostic
may warrant one, such as Animatem's `DEBUG_EFFECT_BEING_REPLACED_ID`.

The existing pattern is `AnimatemTypes.LogID` in
[AnimatemTypes.cs](Animatem/AnimatemTypes.cs):

```csharp
public static class LogID
{
    // Error, warning and info IDs.
    public const string WARNING_ANIMATOR_NOT_ATTACHED_ID = "ANI00";
    public const string WARNING_ANIMATOR_DESTROYED_WHILE_ANIMATING_ID = "ANI01";
    public const string WARNING_CANT_FIND_EFFECT_ID = "ANI02";
    public const string WARNING_CANT_REMOVE_EFFECT_ID = "ANI03";
    public const string WARNING_CYCLE_NOT_SUPPORTED_ID = "ANI04";
    public const string WARNING_REVERSE_NOT_SUPPORTED_ID = "ANI05";
    public const string WARNING_ZERO_DURATION_REPEAT_ID = "ANI06";
    public const string DEBUG_EFFECT_BEING_REPLACED_ID = "ANI07";
}
```

Pass the named constant to the matching Logger helper:

```csharp
Logger.Warning(message, AnimatemTypes.LogID.WARNING_CANT_FIND_EFFECT_ID);
```

Logger includes `#ANI02` in this warning. Search the code for `ANI02` to find
its constant, then use **Find References** on `WARNING_CANT_FIND_EFFECT_ID` to
locate its callers. Store the full ID as a string literal in the constant so
reported IDs are directly searchable; do not assemble them from a prefix constant.
The descriptive symbol is the code reference; the prefix and numeric suffix are
its displayed value.

- Keep small helpers self-contained: put their ID constants directly in the
  owning class or source file. Do not add a separate file dependency just for IDs.
  A dedicated ID class or existing types file is useful for larger utilities,
  not mandatory. `LocalizerTypes.cs` groups Localizer IDs through `LocalizerID`.
- Use a distinct utility prefix and unique numeric suffixes within its block.
  Name constants in uppercase with the severity and a meaningful condition.
- Order each block **Severe → Warning → Info → optional Detail → exceptional Debug**, assigning
  the lowest numbers to Severe and increasing through the block.
- Use constants at call sites, not hard-coded IDs such as `"ANI02"`. Keep useful
  context in the message; the ID identifies the diagnostic, not a particular object.
- Apply this convention to new or revised diagnostics. General-owned diagnostics
  at Info or higher use named ID blocks. Utilities with only ID-free Detail, Print
  or ordinary Debug traces do not need an ID block. IDs do not control Logger's level or its existing
  message-based once-only suppression.

`Logger.ShowAlert` lets diagnostics be reported from devices or environments
without a usable console/debugger. With SystemUI's bridge installed, eligible
Info/Warning/Severe messages include their IDs in the automatic alert. A host can
expose this switch through a hidden diagnostic UI so a user can report the message
and ID. The consuming application supplies that control. Respect the
global setting rather than suppressing alerts at ordinary call sites. Explicit
Alert calls have separate presentation rules documented in [SystemUI](SystemUI/README.md).

### ID block locations

Localizer's block also covers Stylizer and export diagnostics. Blocks sit with their owning utility, avoiding
a single registry that every utility would have to copy.

| Utility | Prefix | Central ID block |
| --- | --- | --- |
| Logger | LOG | Constants in [Logger.cs](Logger/Logger.cs) |
| Animatem | ANI | `AnimatemTypes.LogID` in [AnimatemTypes.cs](Animatem/AnimatemTypes.cs) |
| JSON reader | JSN | `JsonReaderID` in [JsonReader.cs](Json/JsonReader.cs) |
| Localizer, Stylizer and export | LOC | `LocalizerID` in [LocalizerTypes.cs](Localization/Localizer/LocalizerTypes.cs) |
| Language preferences | LANG | `LanguagePreferenceID` in [LanguagePreference.cs](Localization/LanguagePreference/LanguagePreference.cs) |
| System Alert | ALT | `AlertID` in [Alert.cs](SystemUI/Alert/Alert.cs) |
| Delayer | DLY | `DelayerID` in [Delayer.cs](Coroutine/Delayer.cs) |
| Fader | FDR | `FaderID` in [Fader.cs](Coroutine/Fader.cs) |
| Mover | MOV | `MoverID` in [Mover.cs](Coroutine/Mover.cs) |
| SoundHelper | SND | `SoundHelperID` in [SoundHelper.cs](Sound/SoundHelper.cs) |
| DialogManager | DLG | `DialogManagerID` in [DialogManager.cs](CanvasUI/DialogManager/DialogManager.cs) |
| Popup menu | POP | `PopupMenuID` in [PopupMenuTypes.cs](CanvasUI/PopupMenu/PopupMenuTypes.cs) |
| Utils | UTL | Constants in [Utils.cs](Utils/Utils.cs) |
| UtilsString | UTS | Constants in [UtilsString.cs](Utils/UtilsString.cs) |
| Video | VID | `VideoID` in [VideoController.cs](Video/VideoController.cs) |

Copy the ID block with its utility. Utils and UtilsString each own their
constants without an additional ID class or file dependency. Event/delegate
examples retain their ID-free Print traces. Video readiness is Info (`VID00`);
the commented buffering/not-buffering traces have lasting diagnostic value,
so they use exceptional Debug IDs (`VID01`/`VID02`). The sample remains disabled;
buffering alone is not a warning. Beep and Click emit no diagnostics.

Logger and Alert are also forwarding APIs: they accept caller-owned messages and
optional IDs. They do not invent generic IDs for callers. Logger's Unity output
calls forward the formatted message. Alert's rendering-failure exception bypasses
Logger to avoid recursive alerts, but includes its own `AlertID.SEVERE_RENDER_FAILED_ID`
(`#ALT00`) and retains the original exception as its inner exception.

These diagnostics complement unit tests, especially for UI, timing and device
problems that need observation in the running application.
