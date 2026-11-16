# Coroutine helpers

Small scene-hosted helpers for delayed work and simple movement. They run on
Unity's main thread and use scaled game time, not background tasks or a wall clock.

## Setup and dependencies

Attach one instance of each helper you use to an active scene object before
calling its static methods. `Awake` registers the instance. None creates its own
host, persists itself across scenes, or supplies a cancellation handle.
Include [Logger](../Logger/README.md); Delayer and Mover also need
[CallbackTypes](<../Event and Delegate/CallbackTypes.cs>).

Keep the host alive while work is pending. Destroying/deactivating it can stop
its coroutines without invoking completion callbacks. The singleton references
are not reset on destruction; these helpers are best used with a host whose
lifetime covers the work, rather than repeatedly destroyed and recreated hosts.

## Delayer

```csharp
Delayer.DoNext(() => Logger.Detail("Deferred work"));
Delayer.Delay(0.5f, () => Logger.Detail("Half a scaled second later"));
```

- `DoNext(callback)` queues work for the host's next `Update`. If called before
  that Update, it can run in the same rendered frame. It is not an end-of-frame
  or layout-complete guarantee.
- The queue is swapped before callbacks run. Work queued from a callback waits
  for a subsequent Update. A callback exception propagates; it can interrupt the
  remaining callbacks in that batch.
- `Delay(seconds, callback, giveWarning: true)` uses `WaitForSeconds` for positive
  delays. At zero or below it invokes the callback immediately, normally with a
  warning. Use `DoNext` for deferred work rather than `Delay(0, ...)`.
- A null callback is allowed; Delay normally warns. There is no built-in cancel,
  replace, or force-complete operation. Guard against a destroyed target in a
  delayed callback when its lifetime can be shorter than the host's.

## Mover

With a valid `Transform item`, after the Mover host has initialized:

```csharp
Mover.SmoothMove(item, new UnityEngine.Vector3(120, 0, 0), 0.3f,
    () => Logger.Detail("Movement finished"));
```

The destination is **localPosition**, relative to the target's parent. It uses
SmoothStep interpolation and calls back after the movement loop finishes.
Supply a positive, finite duration. Starting another move does not cancel the
previous coroutine; avoid concurrent moves writing to the same Transform.
Time scale zero prevents a positive-duration move from advancing.

For named replacement, parallel effects, repeat/reverse options or more easing
choices, use [Animatem](../Animatem/README.md).

## Fader

`Fader.FadeTextIn(text, color, duration = 0.333f)` targets legacy
`UnityEngine.UI.Text`, not TextMesh Pro. It interpolates from `Color.clear`
toward the supplied color using scaled frame time. The current loop does not
explicitly assign the final color after it ends, so do not rely on an exact final
value. There is no callback or cancellation API. For a Graphic alpha tween with
endpoint handling, see Animatem's alpha effects.
