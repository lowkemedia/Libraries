# General utilities and dependencies

General contains reusable utilities, each with its own dependencies. Copy the
utility together with the companion classes it uses; these classes are not all
independent single-file components.

## Animatem

[Animatem](Animatem/Animatem.cs) is the custom tween/animation coordinator,
formerly named Animator. It is distinct from UnityEngine.Animator. Its class,
script and folder use the Animatem name, alongside the `AnimatemEffect` base class
and `AnimatemTypes` namespace. Anime retains its name. The renames preserve Unity
GUIDs and scene bindings, with no animation behaviour changes.

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

This is a compile-time dependency: disabling logging or passing `log: false` to
Alert does not remove it. There is no optional Log wrapper, conditional symbol or
automatic Unity fallback when Logger is absent. Utilities without Logger references,
such as SystemUI's Beep and Click, do not need Logger themselves.

Logger itself has **no dependency on Alert or SystemUI** and can be copied alone
for Unity console logging. Its optional `AlertRequested` event lets another class
supply presentation. [LoggerAlertBridge](SystemUI/Alert/LoggerAlertBridge.cs), kept
with SystemUI, connects that event to Alert in Ages of Chess. Alert still depends
on Logger for its own logging. See [SystemUI](SystemUI/README.md#logger-integration)
for the connection and its startup behaviour.

## Named diagnostic IDs

Logger is a deliberate shared dependency: a reported diagnostic should be easy
to trace back to its source even when a debugger is impractical or unavailable.
Each General utility should keep its Severe, Warning, Info and Detail IDs together
in one block owned by that utility. Severe, Warning and Info can appear through
`Logger.ShowAlert`; Detail is always console-only.

The level order is `SEVERE → WARNING → INFO → DETAIL → PRINT → DEBUG`.
The default `PRINT` threshold includes Detail and Print while hiding Debug.
Use `Logger.Detail(message, id)` for useful lasting diagnostics that do not warrant
Info or an automatic alert. It supports optional `showOnlyOnce` and `stackTrace`
arguments, like Info and Debug; messages repeat unless suppression is requested.

`Logger.Print` is informal development tracing, often marked with `>>`, `>>>>`
or similar arrows to stand out in the console. Its signature is
`Print(string message, bool stackTrace = false)`: **no IDs or once-only suppression**.
Every call that passes the configured log level prints, even repeated messages.
Use Debug for once-only development traces. Print statements
are usually removed when investigation is complete, or deliberately promoted to
Detail, Info, Warning or Severe if worth keeping, or kept as verbose Debug traces.
Commented-out Print calls do not need IDs either. Debug usually has no ID; an especially useful, lasting diagnostic
may warrant one, such as Animatem's `DEBUG_EFFECT_BEING_REPLACED`.

The existing pattern is `AnimatemTypes.LogID` in
[AnimatemTypes.cs](Animatem/AnimatemTypes.cs):

```csharp
public static class LogID
{
    // Error, warning and info IDs.
    public const string WARNING_ANIMATOR_NOT_ATTACHED = "ANI00";
    public const string WARNING_ANIMATOR_DESTROYED_WHILE_ANIMATING = "ANI01";
    public const string WARNING_CANT_FIND_EFFECT = "ANI02";
    public const string WARNING_CANT_REMOVE_EFFECT = "ANI03";
    public const string WARNING_CYCLE_NOT_SUPPORTED = "ANI04";
    public const string WARNING_REVERSE_NOT_SUPPORTED = "ANI05";
    public const string DEBUG_EFFECT_BEING_REPLACED = "ANI06";
}
```

Pass the named constant to the matching Logger helper:

```csharp
Logger.Warning(message, AnimatemTypes.LogID.WARNING_CANT_FIND_EFFECT);
```

Logger includes `#ANI02` in this warning. Search the code for `ANI02` to find
its constant, then use **Find References** on `WARNING_CANT_FIND_EFFECT` to
locate its callers. Store the full ID as a string literal in the constant so
reported IDs are directly searchable; do not assemble them from a prefix constant.
The descriptive symbol is the code reference; the prefix and numeric suffix are
its displayed value. A utility can change its prefix, reorder its numbers or move
a diagnostic to another utility without scattering literal IDs through callers.
Keep the meaningful symbol where possible and update its ownership/references
when moving it. Older reports must be interpreted against the reporting build.

- Keep small helpers self-contained: put their ID constants directly in the
  owning class or source file. Do not add a separate file dependency just for IDs.
  A dedicated ID class or existing types file is useful for larger utilities,
  not mandatory. `LocalizerTypes.cs` groups Localizer IDs through `LocalizerID`.
- Use a distinct utility prefix and unique numeric suffixes within its block.
  Name constants in uppercase with the severity and a meaningful condition.
- Order each block **Severe → Warning → Info → Detail → exceptional Debug**, assigning
  the lowest numbers to Severe and increasing through the block.
- Use constants at call sites, not hard-coded IDs such as `"ANI02"`. Keep useful
  context in the message; the ID identifies the diagnostic, not a particular object.
- Apply this convention to new or revised diagnostics. General-owned diagnostics
  at Detail or higher use named ID blocks. Utilities with only Print
  or ordinary Debug traces do not need an ID block. IDs do not control Logger's level or its existing
  message-based once-only suppression.

`Logger.ShowAlert` lets diagnostics be reported from devices or environments
without a usable console/debugger. With SystemUI's bridge installed, eligible
Info/Warning/Severe messages include their IDs in the automatic alert. A host can
expose this switch through a hidden diagnostic UI so a user can report the message
and ID. This describes the intended use, not an existing hidden Ages of Chess
control; its current startup switch is `AgesOfChess.SHOW_LOG_ALERTS`. Respect the
global setting rather than suppressing alerts at ordinary call sites. Explicit
Alert calls have separate presentation rules documented in [SystemUI](SystemUI/README.md).

### ID block locations

ANI and LANG values are retained. JSN, LOC and DLG are numbered in severity
order; interpret older reports using their reporting build. Localizer's block also
covers Stylizer and export diagnostics. Blocks sit with their owning utility, avoiding
a single registry that every utility would have to copy.

| Utility | Prefix | Central ID block |
| --- | --- | --- |
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
buffering alone is not a warning. No diagnostic was added to Beep or Click.

Logger and Alert are also forwarding APIs: they accept caller-owned messages and
optional IDs. They do not invent generic IDs for callers. Logger's Unity output
calls forward the formatted message. Alert's rendering-failure exception bypasses
Logger to avoid recursive alerts, but includes its own `AlertID.SEVERE_RENDER_FAILED`
(`#ALT00`) and retains the original exception as its inner exception.

These diagnostics complement unit tests, especially for UI, timing and device
problems that need observation in the running application.

The external Libraries repository is managed separately by LowkeMediaLibraries.
These local copies are not automatically synchronized; transfers require an
explicit request and comparison of the current copies.
