# Animatem

Animatem is a code-driven animation utility for Unity. Give a GameObject one or
more effects: move it, change its scale, fade its graphics, or wait before calling
the next action. Effects can run together, repeat, reverse and report completion.

A distinctive part of Animatem is **[Parabola easing](README%20Parabola.md)**,
Russell Lowke's curve-fitting easing function. Instead of choosing only a preset,
say **“be 76.5% of the way there at half time.”** Adjusting that point gives fine
control over acceleration, anticipation and overshoot. Ages of Chess uses it
throughout its piece animations.

[Quick example](#a-first-animation) · [Effects](#available-effects) ·
[Combining effects](#running-effects-together) · [Repeating](#repeating-and-reversing) ·
[Parabola guide](README%20Parabola.md) · [Integration details](#integration-details)

## Setup

Copy this Animatem folder into your Unity project with:

- [Logger.cs](../Logger/Logger.cs) for diagnostics.
- [CallbackTypes.cs](<../Event and Delegate/CallbackTypes.cs>) for completion callbacks.
- [GlobalState.cs](../GlobalState.cs) for the handheld-device check.

The supplied UI effects and CallbackTypes use Unity's uGUI package. Classes live
in the global namespace; import `AnimatemTypes` for `EffectType` and `EasingFunct`.
No Alert, SoundHelper or application-specific classes are needed.

Attach **one Animatem component** to a scene object before using
`Animatem.Instance`. It is not created automatically and is not automatically
persistent across scenes. Call it from Unity's main thread, after its `Awake`.

## A first animation

Attach this example to the object to move, with an Animatem component elsewhere
in the scene. It moves 100 local units right over half a second, easing to a stop.

```csharp
using UnityEngine;

public sealed class MoveExample : MonoBehaviour
{
    private void Start()
    {
        float endX = transform.localPosition.x + 100f;
        Animatem.Instance.Anime(gameObject).AddEffect(
            new TweenFX_X(float.NaN, endX, 0.5f, Parabola.EaseOut),
            () => Logger.Detail("Movement finished"));
    }
}
```

`float.NaN` tells this tween to read the starting X value from its target when
added. An explicit start value assigns that value immediately. Null easing means
linear motion. Positions use `Transform.localPosition`, not screen pixels or
`RectTransform.anchoredPosition`.

## How it fits together

| Class | Responsibility |
| --- | --- |
| [Animatem](Animatem.cs) | Scene component; finds/creates an Anime per target and updates them in `FixedUpdate`. |
| [Anime](Anime.cs) | Holds the effects for one GameObject; adds, finds, replaces and removes them. |
| [AnimatemEffect](Effects/AnimatemEffect.cs) | Base class for timing, completion, callbacks and repeat behaviour. |
| [TweenFX](Effects/Tween/TweenFX.cs) | Changes a numeric value from start to end; subclasses apply it to a property. |
| [MultiEffectFX](Effects/MultiEffectFX.cs) | Starts child effects together and waits for all their completion callbacks. |
| [Parabola](Effects/Tween/Easing/Parabola.cs) | Fits a quadratic through the start, your chosen intermediate point and the end. |

`Animatem.Instance.Anime(target)` returns the existing Anime or creates one.
`GetAnime(target)` looks it up without creating it. An empty Anime is normally
removed on the next update; obtain it again when starting new work. Setting
`anime.Persist = true` keeps an empty Anime registered. `Persist` defaults to
false; reading it returns the retention flag, independently of the target.

## Available effects

Scalar tweens generally take `(start, end, duration, easingFunct, type)`.
Duration is in scaled seconds, easing defaults to linear and type defaults to
`EffectType.END`. Use a new effect instance for each addition.

| Effect | What it changes |
| --- | --- |
| [TweenFX_X](Effects/Tween/TweenFX_X.cs), [TweenFX_Y](Effects/Tween/TweenFX_Y.cs) | Local X or Y, preserving the other position axes. |
| [TweenFX_XY](Effects/Tween/TweenFX_XY.cs) | Local X and Y together. Takes end X, end Y, duration and separate optional X/Y easing delegates; reads both starts from the target. |
| [TweenFX_Scale](Effects/Tween/TweenFX_Scale.cs) | Sets local X and Y scale to the same value and Z scale to **1**. Reads X when using a NaN start. |
| [TweenFX_ImageAlpha](Effects/Tween/TweenFX_ImageAlpha.cs) | Alpha of the target's `Image`; preserves its RGB. |
| [TweenFX_RawImageAlpha](Effects/Tween/TweenFX_RawImageAlpha.cs) | Alpha of the target's `RawImage`; preserves its RGB. |
| [TweenFX_Alpha](Effects/Tween/TweenFX_Alpha.cs) | Assigns the same alpha to the target and active descendants' `Graphic` components. Use explicit start/end values; there is no single group alpha to read. |
| [DelayFX](Effects/DelayFX.cs) | Waits for a duration, then completes. |
| [WithVelocityFX_XY](Effects/Tween/WithVelocity/WithVelocityFX_XY.cs) | Calculates duration as local XY distance divided by supplied velocity, then runs X/Y tweens. Use positive velocity and nonzero travel distance. Easing shapes speed within that duration. |
| [TweenFX](Effects/Tween/TweenFX.cs) | Stores a numeric `Value`; does not itself write a GameObject property. Useful as the base for a new property tween. |

Scalar `WithVelocityFX`, `WithVelocityFX_X` and `WithVelocityFX_Y` take
`(start, end, velocity, easingFunct, type)` and calculate duration from distance
and velocity. The X/Y versions accept `float.NaN` to read the current position.
Use positive, finite velocity and nonzero travel distance.

## Running effects together

`MultiEffectFX` is a **parallel group**, not a sequence. Here scale and local Y
change together, with one callback after both finish. This is the pattern used
for enlarging and lifting a chess piece during dragging.

The following snippets belong inside a method on a MonoBehaviour, with
`using System.Collections.Generic;` and `using AnimatemTypes;`.

```csharp
Anime anime = Animatem.Instance.Anime(gameObject);
anime.AddEffect(new MultiEffectFX(new List<AnimatemEffect> {
    new TweenFX_Scale(float.NaN, 1.8f, 0.06f),
    new TweenFX_Y(float.NaN, 0.8f, 0.06f)
}), () => Logger.Detail("Lift finished"));
```

A group containing a 0.3-second tween and a 0.5-second `DelayFX` takes roughly
0.5 seconds, **not 0.8 seconds**. The delay establishes a minimum total duration.
Ages of Chess uses this for movement and spotlight animations. Completion is
processed on animation ticks, so these are not exact wall-clock callback times.

An empty END group completes during `AddEffect`, including its callback. If
scheduled with `TimedEffect` for a future start, it completes when that time is
reached instead.

To perform a second action *after* the first, add it in the first callback:

```csharp
Animatem.Instance.Anime(gameObject).AddEffect(
    new TweenFX_X(float.NaN, 100f, 0.3f, Parabola.EaseOut),
    () => Animatem.Instance.Anime(gameObject).AddEffect(
        new DelayFX(0.2f),
        () => Logger.Detail("Movement and following pause finished")));
```

The manager's own `AddEffect(...)` targets its GameObject. It is convenient for
a standalone `DelayFX` when no animated target is involved.

## Repeating and reversing

Set the effect's type to choose what happens when it reaches its end:

| `EffectType` | Behaviour |
| --- | --- |
| `END` | Remove this effect. The default. |
| `PERSIST` | Keep it registered after completion; this is not a pause. |
| `REMOVE` | Remove the Anime and all its effects, retaining its GameObject. |
| `DESTROY` | Remove the Anime and destroy its GameObject. |
| `CYCLE` | Ask the effect to restart. Scalar tweens restart from their original start. |
| `REVERSE` | Ask the effect to reverse. Scalar tweens exchange start/end and run another leg. |

A zero-duration scalar tween finishes once, even with CYCLE/REVERSE or a repeat
count, reporting warning `ANI06` through Logger with `showOnlyOnce: true`.
Zero-duration END tweens retain their normal instant-movement behaviour without
this warning.

For positive-duration scalar tweens, `Cycles = 0` leaves CYCLE/REVERSE unbounded.
A positive count is the number of **completed legs**, including the first.
Two legs give one out-and-back movement:

```csharp
var pulse = new TweenFX_Scale(1f, 1.5f, 0.333f,
    Parabola.GetEasing(0.22f, 0.75f), EffectType.REVERSE);
Animatem.Instance.Anime(gameObject).CycleEffect(pulse, 2,
    () => Logger.Detail("Pulse finished"));
```

`CycleEffect` sets the count; it does **not** change an END effect into a repeating
one. Set CYCLE or REVERSE as above. A finite count calls back on the last leg;
unbounded repeating tweens call back at each completed leg. PERSIST can keep
reporting completion on later updates. These callbacks are not universally
once-only notifications.

Parabola keeps its absolute control point when reversing; see
[reuse and reversal](README%20Parabola.md#one-easing-instance-per-tween).
Group-level Cycle/Reverse resets completion flags; it does not restart children
that have completed and been removed. Attempting that reports warning `ANI04`
(Cycle) or `ANI05` (Reverse), with `showOnlyOnce: true`, without changing the
existing repetition behavior. XY wrappers keep their working cycle/reverse
behavior because their scalar children repeat themselves. For a finite pulse
inside a group, put REVERSE and the leg count on the scalar tween, as Ages of
Chess does.

## Naming, replacing and stopping

An effect's default name identifies its type. Adding another with that name
normally replaces the old one on the same Anime, without running its callback.
That makes repeated movement requests replace the pending movement.

| `AddEffect` name argument | Behaviour |
| --- | --- |
| Omitted / `EffectString.REPLACE` | Replace an existing effect with the incoming effect's name. |
| `EffectString.SNAP_REPLACE` | Snap the old effect to its end and run its callback, then replace it. |
| `EffectString.AUTO_RENAME` | Give a conflicting incoming effect a numbered suffix. |
| A custom string | Assign that name; throws if it is already present. |

For a reusable custom name with replacement, set `effect.Name` before calling
`AddEffect(effect)` with its default name argument. Unique names allow effects
to coexist; they do not blend conflicting writes to the same property.

Groups register their children on the same Anime with names such as
`MultiEffectFX/TweenFX_Scale`. Give same-type children distinct names before
adding the group. Removing a group also cleans up its children.

- `anime.GetEffect(name, false)` looks up an effect without a missing-effect warning.
- `anime.RemoveEffect(name)` stops a named effect without its completion callback.
- `anime.RemoveEffects("fragment")` removes effects whose names contain the string.
- `anime.ClearEffects()` stops all effects on that target.
- `Animatem.Instance.Remove(target)` removes the target's Anime and effects.
- `Animatem.Instance.Clear()` stops everything managed by that component.

The removal methods' `snapToEnd: true` option applies final values **and invokes
callbacks**. Do not use it as silent cancellation. Remove animations before
destroying their targets. Effects are detached before their snap callbacks run,
so callbacks can remove or clear other animations without snapping the same
effect again. Group children use the same removal path.

## Patterns used in Ages of Chess

These examples were checked against the application's call sites. The app is
not required to use the library.

| Application method | Pattern |
| --- | --- |
| `PieceView.MovePiece` | XY movement with two fresh Parabola delegates; group with a 0.5-second delay for a minimum move duration. |
| `PieceView.SnapImageTo` | Replace the current XY tween to move the piece image back into position. |
| `PieceView.SpotlightPiece` | Reversing scale tween, a finite leg count and a parallel delay; restore visual state in the group callback. |
| `PieceView.CapturePiece` | Fade an Image, then remove the piece in the callback. |
| `PieceView.ScaleImageForDrag` / `PieceDrop` | Group scale and Y movement for lift/drop feedback. |
| `LegalMoveView` | Reversing linear Image-alpha tween for a repeating highlight. |
| `SetupSittuyin.SetupFinished` | Fade a curtain's graphics before destroying it and continuing the game. |
| `TimelineGraphic` | X-position tween using `Sine.EaseOut`. |

The [Parabola guide](README%20Parabola.md#settings-used-in-ages-of-chess) records
the actual curve settings behind these behaviours.

## Integration details

- **Time:** updates use `FixedUpdate` and scaled `Time.time`. There is no built-in
  unscaled clock or per-effect pause API. A tween ordinarily writes its endpoint,
  then reports completion on a later tick so the endpoint can be displayed.
- **Scheduling:** `TimedEffect(effect, timestamp)` uses an absolute `Time.time`
  timestamp. Initialization happens immediately, even for a future start;
  tweens may read/assign their starting value before that timestamp.
- **Handheld timing:** the manager's `Start()` sets `Application.targetFrameRate`
  to 60, `Time.fixedDeltaTime` to approximately 1/60 and
  `Time.maximumDeltaTime` to 0.05 on handheld devices. These are application-wide
  settings; review them when integrating.
- **Components:** Image/RawImage tweens require that component on the target.
  Effects do not automatically stop just because a target becomes inactive.
- **Changing a tween:** setting `Start`, `End` or `Duration` recalibrates and
  restarts its timing immediately; it is not an automatic continuation from its
  current displayed value. For Parabola, prefer a fresh tween and easing instance
  when changing the trajectory.

## Adding an effect

For a new numeric property, subclass `TweenFX`, obtain the target component in
`Initialize()` **before** calling `base.Initialize()`, and override `Value` to
read/write that property. Call `base.Value = value` in the setter: the base tween
uses its stored value to detect arrival at the endpoint.
[TweenFX_ImageAlpha](Effects/Tween/TweenFX_ImageAlpha.cs) is a compact example.

For non-tween behaviour, subclass `AnimatemEffect` and implement `Initialize`,
`Update` (return true when resolved) and `SnapToEnd`. Override `Cleanup` if you
own resources, and Cycle/Reverse only if supported. The base implementations of
Cycle/Reverse log a warning. Keep callbacks under the base class's completion
handling, and use a distinct effect name.
