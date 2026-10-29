# SystemUI

Shared system alerts and synthesized interaction sounds live here.
Canvas-based controls live in [CanvasUI](../CanvasUI/README.md);
[Logger](../Logger/Logger.cs) and [SoundHelper](../Sound/SoundHelper.cs) remain
in their own General folders.

## System alerts (CHES-51)

[Alert.cs](Alert/Alert.cs) provides an unskinned runtime alert before gameplay UI, localization, styles or sound exist. It is separate from [Dialog.ShowAlert](../CanvasUI/DialogManager/Dialogs/Dialog.cs). Its light-grey panel, black border, left-hand severity icon, wrapped text, spacing and upper-screen placement follow `Libraries/Adobe/src/com/lowke/alert/Alert.as`. Unlike the original click-anywhere dismissal, dismissal requires an explicit button choice: **OK** (or a supplied label), or the left-hand **Cancel** button for questions.

## Calling the alert

```csharp
// Force a visible request even when automatic alerts and console filtering are off.
Alert.Error(message, "Saved data recovery", onAcknowledged: onAcknowledged);

// Show a system message without logging it.
Alert.Info(message, "Information", onAcknowledged: onAcknowledged, log: false);

// Question: Cancel on the left, OK on the right; only the selected callback runs.
Alert.Question("Apply these changes?", onAcknowledged: ApplyChanges, onCancel: KeepChanges);

// Custom labels, with No on the left and Yes on the right.
Alert.Question("Start again?", buttonText: "Yes", onAcknowledged: StartAgain,
    cancelButtonText: "No", onCancel: KeepPlaying);

// Optional automatic alerts; false by default to preserve existing behaviour.
Logger.ShowAlert = true;
```

`Alert.Info`, `Alert.Warning`, `Alert.Severe` and `Alert.Error` forward the message, title, optional acknowledgement callback and button label to `Alert.Show` with the appropriate `Alert.Icon` value (`Error` uses Warning). `Show` retains its enum-based icon argument; the `*_ICON` string constants define the displayed symbols. Info/Question use blue circles (`0x6598FF`); Warning uses a yellow square (`0xFFFF99`); Error uses a red square (`0xCC6666`). Unknown icon values use a light-grey square (`0xEEEEEE`); `Icon.None` omits the icon.

Explicit helpers always queue the alert regardless of `Logger.Level` or `Logger.ShowAlert`. `Info` and `Question` default to `log: false`; `Warning`, `Severe` and `Error` default to `log: true`. Logging respects Logger's level. The single-button helper parameter order is `message, title, buttonText, onAcknowledged, log, id`: `id` is only used for logging. Set `log: true` to log an Info message, or `log: false` to suppress a warning/error diagnostic. Alert calls the assembly-internal `Logger.LogNoAlert(level, message, id)` to prevent this diagnostic from generating a duplicate automatic alert, without changing the global setting. Public severity helpers offer no suppression flag; Logger.Log remains private. The body remains the caller's exact message and the default button is `OK`. `Error` is an alias for `Warning` with the title "Error", using the yellow warning icon and warning log output; other helper titles are "Information", "Warning" and "Severe". `Severe` uses the red error icon and Unity error logging, which can pause Editor Play Mode when Error Pause is enabled and the log is not filtered. OK does not unpause the Editor; standalone players are not paused by this. Launch recovery uses `Error`, so it now logs a warning. `Show` defaults to "System Alert" and does not log. `Question` adds `cancelButtonText, onCancel` between `onAcknowledged` and `log`. It defaults to title "Question", a blue question icon, OK on the right and Cancel on the left. Null/empty button labels fall back to OK/Cancel. Both callbacks are optional; either choice dismisses the question and invokes only its matching callback, at most once. State is cleared before invoking it, preserving FIFO ordering even during re-entry or callback exceptions. Logging is optional at Info level and does not create a duplicate automatic alert. `Show(..., icon: Alert.Icon.Question)` remains a single-button alert; only `Question` adds a second button.

When `ShowAlert` is enabled, ordinary Severe/Warning/Info calls display alerts only after the existing log-level and `showOnlyOnce` checks. Detail/Print/Debug remain console-only. Existing message-based suppression and logging output are unchanged. Automatic alerts stay opt-in; do not enable them globally without considering repeated diagnostics.

## Logger integration

Logger has no dependency on Alert or SystemUI. Its optional
`AlertRequested` event carries `(Logger.LogLevel, string)` with the same formatted
message sent to Unity's console, after filtering and once-only checks. Requests
are emitted for ordinary Info/Warning/Severe logs when `Logger.ShowAlert` is true.
Explicit Alert logging uses `LogNoAlert` and emits no automatic request. With no subscriber, console logging still works normally.

[LoggerAlertBridge](Alert/LoggerAlertBridge.cs) connects the event to Alert's
matching helpers with `log: false`, preventing another log or automatic alert.
Unity installs it at `AfterAssembliesLoaded`, after subsystem resets and before
scene startup. Installation removes its own existing subscription before adding
it, so repeated initialization with domain reload disabled cannot duplicate the
bridge or remove other subscribers. No scene component or application setup call
is needed. Logger's `ShowAlert` setting remains controlled by Ages of Chess.

Events run synchronously on the logging caller's thread. The bridge only enqueues
an Alert request; rendering stays on the main thread. Other consumers can supply
their own subscriber instead of this bridge, and must manage their subscriptions
and any required main-thread dispatch. Include Logger alone for console logging;
include this bridge with SystemUI for automatic system alerts. Alert still uses
Logger for its own optional logging; this change removes only the reverse dependency.
`Logger.cs` is required to compile Alert even when every call uses `log: false`.
Alert and Logger must compile in the same assembly to use the internal
`LogNoAlert` entry point; the current project places both in Assembly-CSharp.

## Diagnostic IDs

Follow the [General named diagnostic ID convention](../README.md#named-diagnostic-ids):
keep SystemUI-owned diagnostics in a centralized ID block and pass named constants
to logging calls. Caller-owned messages retain the caller's diagnostic ID rather
than being reassigned a generic SystemUI ID. Automatic alerts receive Logger's
formatted message, including `#ID`; explicit Alert helpers currently use the ID
only for logging and keep the displayed body as the caller's exact message.

`AlertID` at the end of [Alert.cs](Alert/Alert.cs) owns System Alert's diagnostic
block: `SEVERE_RENDER_FAILED = "ALT00"`. The full ID is directly searchable.
Rendering failures include `#ALT00` in a wrapper exception, retaining the original
exception and its stack as the inner exception. They still go directly to Unity's
exception output once per displayed request, bypassing Logger to prevent recursive
alerts, and never acknowledge the pending request. Ordinary caller messages keep
their supplied IDs (or null); there is no generic replacement ID for all warnings.
Beep and Click currently emit no diagnostics and need no ID blocks.

## Localization follow-up

User-facing system titles, messages and button labels currently remain English.
[CHES-247](https://chessorigins.atlassian.net/browse/CHES-247) tracks localization,
including alerts shown before normal localization initialization, safe English
fallback, and font/layout checks in portrait and landscape. Keep the generic
Alert utility independent of application-specific localization resources.

## Startup and lifetime

- Unity runtime initialization installs a persistent host before the first scene's `Awake`. No scene/prefab changes are needed. Session initialization clears prior requests when entering Play Mode, including when domain reload is disabled.
- `Alert.Show` only enqueues immutable request data under a lock, so workers can request alerts. The host builds UI and invokes acknowledgement callbacks on Unity's main thread.
- Alerts are FIFO, one visible at a time. Identical text does not merge requests or lose callbacks. Acknowledgement removes the active request before invoking its callback; stale clicks, re-entry and exceptions cannot invoke it again. The next request is presented on a subsequent update, with a short unscaled input guard against accidental double clicks.
- Rendering uses built-in IMGUI (separate from the gameplay Canvas), with screen-safe-area positioning and scrollable long text. The panel width is two-thirds of the shorter safe-area dimension in portrait or landscape. Text, icons, spacing and buttons scale together from the 400-unit layout; sizing is recalculated on each draw for rotation and window resizing, independently of DPI and CanvasScaler settings. A transparent, topmost runtime canvas blocks normal uGUI pointer raycasts behind the alert. It needs no EventSystem for its own controls and does not alter time scale or pause unrelated polling/game logic.
- The acknowledgement button uses a black background with white text while pressed, starting on mouse-down. Standard `GUI.Button` handling acknowledges on release inside the button; releasing outside cancels the press. Alert explicitly clears its button capture after mouse-up, including releases filtered by the modal window, so later hover cannot retain a pressed highlight.
- Clicking/tapping outside the panel beeps and flashes a thicker white border with a thin black outer outline for 180 ms without dismissing the alert. The black outline extends two layout units beyond each edge, scaled with the alert, preserving the full white border and making the panel appear to grow. Layout and input bounds stay unchanged. The flash uses unscaled time, restarts on each outside press, and resets for the next alert; text and button colours stay unchanged. Alert calls the reusable `Beep.Play()` helper described below; it owns no audio objects. Press detection uses the project's legacy Input API (Both input systems are enabled) against the last rendered panel bounds, independently of IMGUI modal event filtering. Touch takes precedence over simulated mouse events. Holding/dragging/releasing does not repeat it; a 120 ms unscaled guard prevents overlap. A new alert or screen-size change waits for fresh rendered bounds. Beep playback does not acknowledge or dismiss the alert.
- Destroying a host is never acknowledgement. The persistent host normally survives navigation; external destruction/presentation failure must not be used to skip a required response. Rendering failures are reported directly to Unity, once per displayed request, avoiding Logger recursion. A lost host requires restoration before its pending request can be displayed; it does not automatically resume startup.
- Direct `Alert.Show` in Edit Mode queues data but does not install a preview host. Use Play Mode to inspect presentation. This is runtime UI, not `UnityEditor.EditorUtility.DisplayDialog` or a native OS dialog.

## Reusable synthesized sounds

[Beep.cs](Beep.cs) exposes `Beep.Play()` for any runtime caller,
including during Launch. Call it on Unity's main thread in Play Mode. Its static
entry point lazily creates a persistent component that owns and cleans up its
AudioSource and generated AudioClip; no prefab, sound asset or SoundHelper setup
is required. Calls outside Play Mode do nothing. The host, source and clip are
created on first use and retained across scene changes until the app closes
(or Play Mode ends); they are not destroyed when an alert is dismissed.

The tone remains 880 Hz for 100 ms, with short fades and the original volume.
It requires the scene's AudioListener, respects global volume/mute, and ignores
AudioListener pause. A shared 120 ms unscaled guard prevents overlapping calls.
Session initialization resets the host reference and playback guard, including
when domain reload is disabled. Unexpected exceptions propagate to the caller;
Beep does not catch them or permanently disable playback. This is synthesized
Unity audio, not the operating system's alert sound.

[Click.cs](Click.cs) similarly exposes `Click.Play()`. It generates
a short, roughly 15 ms decaying noise snap with no pitched tone and caches its own persistent host, AudioSource
and AudioClip on first use. It has the same main-thread, Play Mode and listener
requirements as Beep, respects volume/mute and ignores AudioListener pause.
Each call plays a click, without Beep's repeat guard. Alert calls it only when a
button release is accepted, before acknowledgement and any scene navigation;
a cancelled press or hover makes no click. Both helpers clean up their generated
audio objects when their hosts are destroyed, and neither depends on sound assets
or SoundHelper.

## Save-recovery boundary

`Launch.OnValuesLoaded` calls `Alert.Error` when `StoredGame.LoadRecoveryMessage` is non-empty. The application supplies an outcome-specific title through `StoredGame.LoadRecoveryTitle`: recovered games, unrecoverable saves, saving unavailable, or progress that may not be saved. The English body explains what happened and what selecting **OK** will do; it does not claim the recovered copy is necessarily older. Until acknowledgement, normal startup navigation does not run. The callback clears the pending message, calls `StoredGame.ContinueAfterRecovery()`, then follows the existing navigation path once. Duplicate load notifications and repeated acknowledgements are guarded; callbacks to a destroyed Launch do nothing.

CHES-51 does not change storage, recovery decisions, validation, release reset policy or Gley. The existing CHES-214 recovery test now isolates the alert queue it creates. Keep that separation when changing presentation.

For reuse, bring this SystemUI folder together with [Logger](../Logger/Logger.cs) and [CallbackTypes](<../Event and Delegate/CallbackTypes.cs>). Alert uses Unity's built-in IMGUI and uGUI modules. No new package is required. The public `/Volumes/GitHub/GitHub/Libraries` repository and its documentation are managed separately by **LowkeMediaLibraries**. These paths describe the live Unity workspace, not a synchronized external copy. Do not mirror SystemUI changes or documentation into Libraries as part of ordinary Ages of Chess work; transfers require an explicit request and comparison of the current copies.

## Verification record

Dated compilation, isolated checks and their limits are archived in [Technical Health Resolved](<../../../../README Technical Health Resolved.md>). Jira closure was verified on 15 October 2026 for v0.2 (3). Closure does not claim the unrecorded Unity/device checks were run; retain those scenarios for future regression testing.
