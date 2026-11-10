# SoundHelper and synthesized sounds

[SoundHelper.cs](SoundHelper.cs) plays AudioSources supplied by the application.
For generated UI feedback without audio assets, use the separate
[Beep, Click and Rollover helpers](../SystemUI/README.md#reusable-synthesized-sounds).

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
Rollover.Play();
Beep.Play();
```

These classes live in SystemUI/SystemSound and do not depend on SoundHelper, Logger or each
other. Each creates its own persistent host/source/clip on first use. Call on
Unity's main thread in Play Mode with an AudioListener present. Click generates
a short noise snap; Rollover is a softer, quieter tick; Beep generates a tone
and limits repeated playback. These are
Unity sounds, not native operating-system sounds. See the linked SystemUI guide
for lifetime, volume/pause behaviour and integration checks.

## Assigning system sounds

See the [SystemSound guide](../SystemUI/SystemSound/README.md) for the complete
Inspector setup.

[SystemSound](../SystemUI/SystemSound/SystemSound.cs) supplies generated clips to ordinary
AudioSources. SoundHelper and its callers still use those AudioSources normally;
no changes to their code are required.

1. Copy SystemSound.cs with [Click.cs](../SystemUI/SystemSound/Click.cs),
   [Rollover.cs](../SystemUI/SystemSound/Rollover.cs) and [Beep.cs](../SystemUI/SystemSound/Beep.cs).
2. Add **System Sound** to each AudioSource's GameObject. Use one AudioSource per
   object. Choose **Click**, **Rollover** or **Beep** in its **Sound** dropdown.
3. Clear **Audio Source → Audio Clip** to **None** if desired. Keep the
   **Audio Source component**: it plays the generated clip and holds the
   references used by SoundHelper.
4. For UI feedback, turn **Play On Awake** and **Loop** off, set **Spatial Blend**
   to **2D**, and adjust volume as needed. Keep an AudioListener in the scene.
5. Assign those AudioSources to SoundHelper's `click`, `roll` and `beep` fields.
   If adapting sources already assigned there, keep the existing references.

Choose the sound before entering Play Mode. The enabled adapter assigns its clip
on enable, ahead of scripts with default execution order. The generated clip is
not a saved asset to drag into the Inspector; an existing assigned clip is
replaced at runtime. Re-enabling the adapter reapplies its selection.

Playback, mixer routing, volume, pause behaviour and completion callbacks remain
under the normal AudioSource/SoundHelper controls. In particular, using Beep's
clip through an AudioSource does not apply the repeat guard from `Beep.Play()`;
the adapter also leaves `ignoreListenerPause` unchanged. Shared clips survive
scene changes, while these assigned AudioSources retain their normal scene
lifetime. Do not modify or destroy the shared clips.
