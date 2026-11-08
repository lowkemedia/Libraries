# SoundHelper and synthesized sounds

[SoundHelper.cs](SoundHelper.cs) plays AudioSources supplied by the application.
For generated UI feedback without audio assets, use the separate
[Beep and Click helpers](../SystemUI/README.md#reusable-synthesized-sounds).

## Configured audio

Copy SoundHelper.cs, [Logger.cs](../Logger/Logger.cs) and
[CallbackTypes.cs](<../Event and Delegate/CallbackTypes.cs>). Attach one SoundHelper
to a scene object and assign its `click`, `roll` and `beep` AudioSource fields.
Supply the AudioClips and an AudioListener. Named convenience calls require that
component; it is not created automatically or made persistent across scenes.

```csharp
SoundHelper.PlayClick();
SoundHelper.PlayBeep(() => Logger.Detail("Beep playback finished"));
```

`SoundHelper.Play(audioSource)` plays a supplied source and returns it; a null
source does nothing. The callback overload invokes the callback immediately for
a null source, or waits for playback to finish using the SoundHelper component's
coroutine. Callbacks therefore need the host to remain alive. Configure clip,
looping, volume and other AudioSource settings in the consuming project.

## Synthesized feedback

```csharp
Click.Play();
Beep.Play();
```

These classes live in SystemUI and do not depend on SoundHelper, Logger or each
other. Each creates its own persistent host/source/clip on first use. Call on
Unity's main thread in Play Mode with an AudioListener present. Click generates
a short noise snap; Beep generates a tone and limits repeated playback. These are
Unity sounds, not native operating-system sounds. See the linked SystemUI guide
for lifetime, volume/pause behaviour and integration checks.
