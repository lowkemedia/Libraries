# System sounds

Synthesized UI feedback without audio files. These utilities use Unity audio,
not native operating-system sounds.

| Utility | Sound |
| --- | --- |
| [Beep](Beep.cs) | A short 880 Hz tone with fades, about 100 ms. |
| [Click](Click.cs) | A crisp, unpitched noise click, about 15 ms. |
| [Rollover](Rollover.cs) | 35 ms of silence followed by a 7.5 ms click with a softened 1 ms attack. |
| [SystemSound](SystemSound.cs) | Assigns a generated clip to an ordinary AudioSource. |

## Inspector setup

**The Audio Clip can be cleared. The Audio Source component must stay.**
SystemSound supplies the clip; Audio Source plays it and controls volume, pitch
and mixer routing. SoundHelper references the Audio Source, not the clip.

1. Select the GameObject that already has the sound's **Audio Source** component.
2. At the bottom of its Inspector, choose **Add Component → System Sound**.
3. In the new component's **Sound** dropdown, choose **Click**, **Rollover** or **Beep**.
4. Clear **Audio Source → Audio Clip** to **None**. No recorded sound file is needed.
5. Keep **Play On Awake** and **Loop** off and **Spatial Blend** at **2D**.
   Start with **Pitch 1** and **Volume 1**, then adjust by ear.
6. Enter Play Mode. SystemSound fills the Audio Clip field with the generated clip.

Keep one AudioSource per sound object. SystemSound requires an AudioSource and
adds one if the object has none. When adapting an existing sound, retain its
existing AudioSource so references to it remain intact.

Choose the sound before entering Play Mode. Assignment happens when the enabled
component runs `OnEnable` in Play Mode; re-enabling it reapplies the selection.
SystemSound does not play automatically or change the source's other settings.
An old clip left assigned will be replaced at runtime, but can simply be cleared
from the prefab instead.

## Connecting to SoundHelper

Assign the normal AudioSources to [SoundHelper](../../Sound/SoundHelper.cs):

| SoundHelper field | SystemSound selection on that source's object |
| --- | --- |
| `click` | Click |
| `roll` | Rollover |
| `beep` | Beep |

Existing assignments can stay in place when adding SystemSound to their source
objects. SoundHelper does not need to know where the clips came from. Its
playback calls and completion callbacks work as before.

Playback follows these sources' normal volume, pitch, mixer and listener-pause
settings. It does not apply the repeat guard from `Beep.Play()`. An enabled
AudioListener is required to hear either playback route.

## Calling the sounds directly

```csharp
Click.Play();
Rollover.Play();
Beep.Play();
```

Call on Unity's main thread in Play Mode; calls outside Play Mode do nothing.
Each helper creates its own persistent host, clip and playback source on demand
and reuses them across scene changes. Direct playback respects global volume
and mute, but ignores AudioListener pause. Beep has a 120 ms unscaled repeat
guard; Click and Rollover do not.

The helpers do not depend on Logger, Alert, SoundHelper or each other. To use
the SystemSound adapter, include all four C# files in this folder.

`Click.Clip`, `Rollover.Clip` and `Beep.Clip` expose the shared generated
AudioClips. Access on Unity's main thread in Play Mode; otherwise they return
null. Fetching a clip creates its persistent host and clip without playing it.
The host owns the shared clip: consumers must not modify or destroy it. Generated
clips are cleaned up with their hosts. Restart Play Mode after changing the
synthesis code so cached clips are regenerated.

## Rollover behaviour

Play rollover once when the pointer enters a control, not every frame it stays
there. Device suppression belongs to the caller: Alert and ClickButton suppress
rollover on handheld devices; `Rollover.Play()` itself has no device restriction.

The rollover clip deliberately begins with **35 ms of silence**. Repeated
`AudioSource.Play()` calls on SoundHelper's shared Roll source restart the clip,
including that silence, so sufficiently rapid crossings can restart before the
hover cue sounds. This is part of the clip, not a coroutine delay or a cooldown.
The source's pitch scales both the silence and the hover cue; these timings assume
pitch 1. Completion callbacks include the lead-in as part of playback.

Direct `Rollover.Play()` uses `PlayOneShot`: it includes the same lead-in but
plays each call independently rather than restarting pending playback.
