# System alerts

[Alert.cs](Alert.cs) provides an unskinned runtime prompt without scene UI, localization, styles or configured sound assets. Its appearance follows Russell Lowke's [Adobe Alert](../../../Adobe/src/com/lowke/alert/Alert.as): a light-grey panel, black border, severity icon and wrapped text near the upper part of the screen. Dismissal requires an explicit button choice. It is separate from the scene-configured `Dialog.ShowAlert`, and is neither a native OS dialog nor an Editor dialog.

## Integration

Copy these files into your Unity project's `Assets` tree:

- [Alert.cs](Alert.cs) and [Logger.cs](../Logger/Logger.cs), which reference each other.
- [Click.cs](../Sound/Click.cs) and [Beep.cs](../Sound/Beep.cs).
- [CallbackTypes.cs](../Event%20and%20Delegate/CallbackTypes.cs).

The code uses Unity IMGUI, uGUI/EventSystems, audio and legacy `UnityEngine.Input`. Keep legacy input enabled in the consuming project (Input Manager or Both where that setting is available); the outside-press code is not implemented against the new Input System alone. TextMeshPro, Localizer, DialogManager and SoundHelper are not required. An AudioListener is needed to hear feedback, but no alert prefab or sound asset is needed. No minimum Unity version or device support matrix has been verified here; the code uses `Screen.safeArea` and `RuntimeInitializeLoadType.SubsystemRegistration`.

## Calling the alert

```csharp
Alert.Info("Export complete.");
Alert.Warning("The selected file could not be opened.", log: false);

// Cancel on the left, OK on the right. Only the selected callback runs.
// ApplyChanges and CancelChanges are methods supplied by the consumer.
Alert.Question("Apply these changes?",
    onAcknowledged: ApplyChanges, onCancel: CancelChanges);

// Optional automatic alerts for ordinary Logger calls; off by default.
Logger.ShowAlert = true;
```

| Entry point | Default title / icon | Default diagnostic |
| --- | --- | --- |
| `Info` | Information / blue information circle | None; `log: true` uses Info |
| `Question` | Question / blue question circle | None; `log: true` uses Info |
| `Warning` | Warning / yellow warning square | Warning |
| `Error` | Error / yellow warning square | Warning; an alias for `Warning` with a different title |
| `Severe` | Severe / red error square | Severe (Unity error output) |
| `Show` | System Alert / `Icon.Info` | None |

The single-button helpers (`Info`, `Warning`, `Error`, `Severe`) take `message, title, buttonText, onAcknowledged, log, id` in that order. `Question` inserts `cancelButtonText, onCancel` between `onAcknowledged` and `log`. Callbacks use the parameterless `CallbackTypes.Callback` delegate. `id` affects only logging. Use named arguments for callbacks and optional settings.

`Show` takes `message, title, icon, buttonText, onAcknowledged`. Its icon argument is the `Alert.Icon` enum; the `*_ICON` constants are display symbols. `Icon.None` omits the icon; an unknown value produces a light-grey square. `Show(..., icon: Alert.Icon.Question)` still has one button: use `Question` for two choices.

The body is the supplied message (null becomes empty), with no localization or rich-text interpretation. Default buttons are **Cancel on the left, OK on the right** for questions, and **OK** otherwise. Custom labels are supported; null/empty labels fall back to OK/Cancel. Both callbacks are optional. Either button dismisses a question and invokes only its matching callback, at most once.

Explicit alerts enqueue regardless of `Logger.Level` or `Logger.ShowAlert`. Their optional diagnostics still respect Logger's level and use `allowAlert: false` internally to avoid a duplicate automatic alert. `Show` itself does not log. When automatic alerts are enabled, ordinary Severe/Warning/Info logs produce alerts after Logger's filtering and `showOnlyOnce` suppression; Print/Debug remain console-only. Automatic alerts display Logger's formatted message, including its prefix. Consider diagnostic frequency before enabling them globally.

With logging enabled and not filtered, `Severe` can trigger Unity's Editor Error Pause. Clicking OK does not unpause the Editor. That setting does not pause standalone players.

## Startup, queue and callbacks

- Runtime initialization installs a persistent host before the first scene's `Awake`; no scene/prefab setup is required. Session reset clears queued/current requests on Play Mode entry, including when domain reload is disabled. Installation can reuse an existing host when scene reload is disabled.
- `Show` only enqueues request data under a lock, so worker threads may call it. UI work and callbacks run on Unity's main thread. Do not extend this guarantee to Logger or helpers with logging enabled: they call Logger on the calling thread before enqueueing, and Logger's shared state is not lock-protected.
- Requests are FIFO, one visible at a time. Identical messages remain separate requests with separate callbacks. `IsShowing` is true for either a current or queued request; it does not prove that rendering succeeded.
- Completion clears the current request before calling consumer code. Re-entry or callback exceptions cannot complete that request again. A callback that enqueues another alert preserves the order of already queued requests. The next request is selected in a later update, with a 200 ms unscaled button guard on presentation.
- Destruction is not acknowledgement. The host normally survives scene changes, but externally destroying it leaves requests unresolved; subsequent `Show` calls do not reinstall it. Do not destroy the host to dismiss a prompt or rely on destruction to run a continuation.
- Rendering failures are reported directly to Unity once per displayed request to avoid Logger recursion. A presentation failure is not an implicit response. Consumer callbacks should handle their own object lifetime and recovery policy.
- Calling `Show` in Edit Mode only queues data; it creates no preview host, and Play Mode session reset clears that data. Request the alert during Play Mode to inspect it.

## Presentation and input

The IMGUI panel uses safe-area positioning and scrollable long text. Its width is two-thirds of the shorter safe-area dimension; text, icons, spacing and buttons scale from a 400-unit layout, recalculated for resizing/rotation independently of CanvasScaler and DPI settings.

A transparent runtime canvas intercepts normal uGUI pointer raycasts behind the alert. The alert's own controls need no EventSystem. It does not change time scale or suspend application logic, keyboard handlers or independent input polling; consumers must gate those separately where needed.

Buttons invert to a black background and white text while pressed. A release inside accepts the choice; a release outside cancels the press. An accepted release calls `Click.Play()` before completing the request and invoking its callback. Hover and cancelled presses do not click.

An outside press does not dismiss the alert: it calls `Beep.Play()` and flashes a thicker white border with a black outer outline for 180 ms of unscaled time. Legacy touch/mouse polling checks the last rendered panel bounds; touch takes precedence over simulated mouse events. Holding or dragging does not repeat the press, and new requests or screen-size changes wait for fresh bounds. Beep's shared 120 ms guard limits repeated sound calls. The flash changes appearance, not layout/input bounds.

See [Sound helpers](../Sound/README.md) for synthesized audio ownership, lifetime and listener requirements. Alert does not own the sound hosts; dismissing it does not destroy them.

## Consumer responsibilities and verification

Recovery, storage and navigation belong to the application. Put any continuation in the chosen callback, guard references to objects that may have been destroyed, and decide whether the rest of the application should wait for a response. No Ages of Chess recovery policy is part of this API.

This document describes the checked-in implementation. No standalone library compilation, Editor, player or device test result is recorded here. Historical Ages of Chess issue closures and application checks do not establish library verification. Useful consumer checks include FIFO/re-entrant callbacks, both question choices, scene changes, domain/scene reload settings, long text, rotation/safe areas, input blocking and listener pause/mute behaviour.
