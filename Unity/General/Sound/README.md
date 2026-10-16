# Sound helpers

[Click.cs](Click.cs) and [Beep.cs](Beep.cs) synthesize small runtime feedback sounds. Each can be copied independently and needs only Unity/System APIs. Neither requires Alert, Logger, SoundHelper, a prefab or an audio asset.

```csharp
// Call on Unity's main thread during Play Mode.
Click.Play(); // Short, unpitched button snap.
Beep.Play();  // Short notification tone.
```

| Helper | Sound | Repeated calls |
| --- | --- | --- |
| `Click.Play()` | About 15 ms of decaying, deterministic noise; mono at 22,050 Hz | Every call plays a one-shot; no repeat guard |
| `Beep.Play()` | 880 Hz tone for 100 ms with short fades; mono at 22,050 Hz | Calls within 120 ms of the previous accepted call are ignored, using unscaled time |

On first use, each helper creates or reuses its own component and caches an AudioSource and generated AudioClip. Its host persists across scene changes; destroying the host cleans up its audio objects. Runtime session initialization resets static host references (and Beep's guard), including when domain reload is disabled. Calls outside Play Mode do nothing. Unexpected exceptions propagate to the caller.

Both play non-spatial audio through the scene's AudioListener. They respect listener volume/mute and set `ignoreListenerPause = true`; neither creates a listener or configures an application mixer. There are no public volume, pitch or completion-callback parameters. The source uses `RuntimeInitializeLoadType.SubsystemRegistration`; a minimum Unity version and target-device audio behaviour have not been verified in this repository.

[Alert](../Alert/README%20System%20Alerts.md) uses Click for an accepted button release before its callback, and Beep for an outside press. The sound hosts remain independent of the alert's lifetime and may be used by any runtime caller.

## Existing SoundHelper

[SoundHelper.cs](SoundHelper.cs) plays consumer-configured AudioSources. Attach one SoundHelper component to the scene and assign its public `click`, `roll` and `beep` fields for the named helpers. It depends on `CallbackTypes` and Logger, which in turn requires the [Alert dependency set](../Alert/README%20System%20Alerts.md#integration).

- `PlayClick`, `PlayRoll` and `PlayBeep` use those configured sources and accept an optional callback. They do not call the synthesized Click or Beep classes and provide no automatic fallback to them.
- `Play(AudioSource)` starts a supplied source directly and returns it; this overload needs no SoundHelper instance at runtime.
- `Play(AudioSource, Callback)` uses the attached instance's coroutine when both arguments are present. The callback runs after `isPlaying` becomes false, which is not a guarantee that the clip completed naturally. With a null source it invokes the callback immediately; with no callback it just starts playback.

SoundHelper does not install a persistent host or generate clips. Consumers own its scene lifetime, source configuration and callback lifetime. Existing buttons and DialogManager use this configured audio path; the synthesized helpers complement it without replacing it.

These behaviours are documented from source. No standalone playback or device tests were run for this documentation update.
