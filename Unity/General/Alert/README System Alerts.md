# System alerts (CHES-51)

`Assets/Code/General/Alert/Alert.cs` provides an unskinned runtime alert before gameplay UI, localization, styles or sound exist. It is separate from `Dialog.ShowAlert`. Its light-grey panel, black border, left-hand severity icon, wrapped text, spacing and upper-screen placement follow `Libraries/Adobe/src/com/lowke/alert/Alert.as`. Unlike the original click-anywhere dismissal, dismissal requires an explicit button choice: **OK** (or a supplied label), or the left-hand **Cancel** button for questions.

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

Explicit helpers always queue the alert regardless of `Logger.Level` or `Logger.ShowAlert`. `Info` and `Question` default to `log: false`; `Warning`, `Severe` and `Error` default to `log: true`. Logging respects Logger's level. The single-button helper parameter order is `message, title, buttonText, onAcknowledged, log, id`: `id` is only used for logging. Set `log: true` to log an Info message, or `log: false` to suppress a warning/error diagnostic. Logger's per-call `allowAlert: false` prevents this diagnostic from generating a duplicate automatic alert, without changing the global setting. The body remains the caller's exact message and the default button is `OK`. `Error` is an alias for `Warning` with the title "Error", using the yellow warning icon and warning log output; other helper titles are "Information", "Warning" and "Severe". `Severe` uses the red error icon and Unity error logging, which can pause Editor Play Mode when Error Pause is enabled and the log is not filtered. OK does not unpause the Editor; standalone players are not paused by this. Launch recovery uses `Error`, so it now logs a warning. `Show` defaults to "System Alert" and does not log. `Question` adds `cancelButtonText, onCancel` between `onAcknowledged` and `log`. It defaults to title "Question", a blue question icon, OK on the right and Cancel on the left. Null/empty button labels fall back to OK/Cancel. Both callbacks are optional; either choice dismisses the question and invokes only its matching callback, at most once. State is cleared before invoking it, preserving FIFO ordering even during re-entry or callback exceptions. Logging is optional at Info level and does not create a duplicate automatic alert. `Show(..., icon: Alert.Icon.Question)` remains a single-button alert; only `Question` adds a second button.

When `ShowAlert` is enabled, ordinary Severe/Warning/Info calls display alerts only after the existing log-level and `showOnlyOnce` checks. Print/Debug remain console-only. Existing message-based suppression and logging output are unchanged. Automatic alerts stay opt-in; do not enable them globally without considering repeated diagnostics.

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

`Assets/Code/General/Sound/Beep.cs` exposes `Beep.Play()` for any runtime caller,
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

`Assets/Code/General/Sound/Click.cs` similarly exposes `Click.Play()`. It generates
a short, roughly 15 ms decaying noise snap with no pitched tone and caches its own persistent host, AudioSource
and AudioClip on first use. It has the same main-thread, Play Mode and listener
requirements as Beep, respects volume/mute and ignores AudioListener pause.
Each call plays a click, without Beep's repeat guard. Alert calls it only when a
button release is accepted, before acknowledgement and any scene navigation;
a cancelled press or hover makes no click. Both helpers clean up their generated
audio objects when their hosts are destroyed, and neither depends on sound assets
or SoundHelper.

## Save-recovery boundary

`Launch.OnValuesLoaded` calls `Alert.Error` when `StoredGame.LoadRecoveryMessage` is non-empty. The title and recovery body are preserved; Russell requested **OK** instead of the earlier **Continue** label. Until acknowledgement, normal startup navigation does not run. The callback clears the pending message, calls `StoredGame.ContinueAfterRecovery()`, then follows the existing navigation path once. Duplicate load notifications and repeated acknowledgements are guarded; callbacks to a destroyed Launch do nothing.

CHES-51 does not change storage, recovery decisions, validation, release reset policy or Gley. The existing CHES-214 recovery test now isolates the alert queue it creates. Keep that separation when changing presentation.

The shared Libraries copies of `Unity/General/Alert/Alert.cs`, `Unity/General/Logger/Logger.cs`, `Unity/General/Sound/Beep.cs` and `Unity/General/Sound/Click.cs` match the Unity project. Other consumers need to bring in Alert, Logger, Beep and Click together; Alert uses Unity's built-in IMGUI and uGUI modules plus the existing `CallbackTypes` delegate. No new package is installed.

## Verification record

Dated compilation, isolated checks and their limits are archived in [Technical Health Resolved](<README Technical Health Resolved.md>). Jira closure was verified on 15 October 2026 for v0.2 (3). Closure does not claim the unrecorded Unity/device checks were run; retain those scenarios for future regression testing.
