# Video controls

Two Canvas components for Unity VideoPlayer. These are small, explicitly wired
controls, not a complete streaming/error-recovery player.

## VideoController

Assign `videoPlayer`, `videoSeekSlider`, and all four ClickButtons:
`pauseButton`, `playButton`, `muteButton`, `soundButton`. Configure the VideoPlayer's
source, output and audio mode in the consuming project. The `renderTexture` field
is referenced only by commented sample code; assign the actual target texture
on the VideoPlayer and display it in your UI yourself.

The slider uses normalized 0–1 values with Whole Numbers off. In its EventTrigger,
wire Begin Drag to `OnSliderBeginDrag()` and End Drag to `OnSliderEndDrag()`.
Start wires the slider's value-change and the four click listeners automatically;
do not also add duplicate Inspector listeners for them.

- `Play(clip)` or `Play(url)` assigns content, prepares when needed, then plays.
  Configure the appropriate VideoPlayer source mode. `Play()` resumes the
  configured source; `Pause()` updates the pause/play controls.
- `Stop()` only calls VideoPlayer.Stop. It does not reset every control/state flag.
- `Mute(bool)` uses direct-audio track zero when supported. It does not implement
  AudioSource/mixer muting for other output modes.
- `VideoPreparedCallback` and `VideoFinishedCallback` are runtime properties.
  Each is cleared after invocation; assign again for a later notification.
  Preparation registrations are currently added on each prepare request, with
  no matching unsubscription. Avoid treating this as a general reusable player
  lifecycle without checking repeated content switches.
- Dragging temporarily pauses playback for seeking, then resumes unless the
  explicit paused state was already set. Frame counts/seeking depend on the
  media and platform. No buffering UI or error callback is implemented here.

Dependencies: Unity Video and UI, [ClickButton](../CanvasUI/Button/README.md),
[Logger](../Logger/README.md), [CallbackTypes](<../Event and Delegate/README.md>)
and the button dependencies. Call after Start has wired the controls.

## VideoProgressBar

Attach to a raycastable UI Image configured as Filled, horizontal, left-to-right;
assign `videoPlayer`. It displays frame/frameCount and seeks from pointer-down or
drag position across the Image rectangle. It does not supply play/pause controls.
The screen-to-local conversion passes a null camera, so the current implementation
is suited to a Screen Space Overlay Canvas. Adapt camera handling for other
Canvas modes before reuse. Include an EventSystem and GraphicRaycaster.

This component only needs Unity UI/Video. Test prepared media, seeking, end-of-media
and the target platform; neither component provides downloadable media assets.
