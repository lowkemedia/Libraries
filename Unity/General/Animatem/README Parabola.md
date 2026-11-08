# Parabola: choose a point the motion must pass through

[Parabola.cs](Effects/Tween/Easing/Parabola.cs) is Russell Lowke's easing function
for shaping a tween around a chosen point in time. It fits one quadratic through
three points: the start, your intermediate point, and the end.

```csharp
Parabola.GetEasing(0.765f, 0.5f)
```

Read this as **“complete 76.5% of the change at 50% of the duration.”** The value
fraction comes first, the time fraction second. Both are fractions, not numbers
from 0 to 100. The whole curve passes through the chosen point; it is not a
Bézier handle that merely pulls the curve towards it.

This lets you tune how a movement feels with two meaningful numbers. You can
start quickly and settle, hesitate before accelerating, move backwards before
committing, or go slightly beyond the destination and return.

[Animatem guide](README.md) · [Source](Effects/Tween/Easing/Parabola.cs)

## A movement example

Inside a MonoBehaviour method, with `using UnityEngine;`:

```csharp
Animatem.Instance.Anime(gameObject).AddEffect(
    new TweenFX_X(float.NaN, 100f, 0.5f,
        Parabola.GetEasing(0.765f, 0.5f)));
```

If the object's initial X is zero, it reaches X = 76.5 after 0.25 seconds and
ends at X = 100 after 0.5 seconds. If it starts at X = 20, the same curve reaches
X = 81.2 halfway: `20 + (100 - 20) * 0.765`. Fractions describe the signed change,
so the same settings also work for movement left or a fade from 1 to 0.

For XY motion, obtain **two separate delegates**, even when their settings match:

```csharp
var move = new TweenFX_XY(100f, 50f, 0.5f,
    Parabola.GetEasing(0.765f, 0.5f),
    Parabola.GetEasing(0.765f, 0.5f));
Animatem.Instance.Anime(gameObject).AddEffect(move);
```

Matching settings give the same fractional progress on both axes, keeping the
path straight. Different settings can bend the XY path. Each axis still has its
own start, end and independently fitted curve.

## Reading the curves

![Six Parabola curves: standard ease-in and ease-out, snap-back, slight piece-movement overshoot, highlight overshoot and spotlight anticipation. Each orange dot is the requested time/value point.](parabola-curves.svg)

The horizontal axis is elapsed time as a fraction of duration. The vertical
axis is progress through the change: 0 is the start and 1 is the destination.
The orange dot is the point passed to `GetEasing(value, time)`. Grey dashed lines
show linear motion; the shaded band shows progress between 0 and 1.
These plots describe the first forward leg, before any reversal.

The piece-movement illustration uses `(0.85, 0.5)`; the app uses the subtler
`(0.765, 0.5)` setting documented below.

At half time, the presets make a useful starting point:

| Setting | Meaning | Shape |
| --- | --- | --- |
| `GetEasing(0.25f, 0.5f)` / `Parabola.EaseIn` | 25% done halfway | Starts at rest and accelerates. |
| `GetEasing(0.5f, 0.5f)` | 50% done halfway | Linear. |
| `GetEasing(0.75f, 0.5f)` / `Parabola.EaseOut` | 75% done halfway | Starts quickly and reaches the end at rest. |
| `GetEasing(0.765f, 0.5f)` | 76.5% done halfway | Slightly stronger than EaseOut; a small overshoot before settling. |
| `GetEasing(0.85f, 0.5f)` | 85% done halfway | Slight overshoot; used in the piece-movement illustration. |

`new Parabola().Ease` also defaults to `(0.75, 0.5)`.
`Parabola.EaseBounce` uses `(0.35, 0.7)`: it initially moves **behind the start**
(to about -6.67% progress) before travelling to the destination. It is one smooth
quadratic with a turn, not a sequence of impacts like the separate classic
[Bounce](Effects/Tween/Easing/Classic/Bounce.cs) easing.

For a point at time fraction `q`, setting value fraction `p = q` is linear.
Values above that diagonal front-load progress; values below it delay progress.
Stronger settings can turn the curve back on itself. One quadratic has constant
acceleration and at most one turning point; it cannot produce an arbitrary
multi-stage ease-in/ease-out profile. The [classic easing functions](Effects/Tween/Easing/Classic/)
remain available for other shapes.

## Settings used in Ages of Chess

These values come from the application's animation call sites. They are useful
tuning examples, not requirements imposed by Animatem.

| Use | `GetEasing(value, time)` | Timing and effect |
| --- | --- | --- |
| Piece movement — `PieceView.MovePiece` | `(0.765, 0.5)` | Independent X/Y delegates; duration grows with board distance. A parallel 0.5-second delay sets a minimum group duration. |
| Image snap-back — `PieceView.SnapImageTo` | `(0.65, 0.35)` | 65% done at 35% time; duration is supplied by the caller. |
| Piece outline — `PieceView` outline setup | `(0.75, 0.22)` | Image alpha, 0.5 seconds per reversing leg. |
| Spotlight — `PieceView.SpotlightPiece` | `(0.22, 0.75)` | Scale to 1.5 times the starting scale over 0.333 seconds, with a finite number of reversing legs. |
| Capture — `PieceView.CapturePiece` | `(0.765, 0.5)` | Image alpha from 1 to 0 over 0.8 seconds; remove the piece in the callback. |
| Sittuyin curtain — `SetupSittuyin.SetupFinished` | `(0.8, 0.5)` | Fade graphics from 1 to 0 over 2 seconds, then continue. |

The control points are inside the 0–1 square, but that does **not** guarantee the
whole curve stays inside it. Calculated from Parabola's equation for the initial
forward leg:

| Setting | Excursion outside the start/end interval |
| --- | --- |
| `(0.765, 0.5)` | Peaks at about 100.085% progress. |
| `(0.65, 0.35)` | Peaks at about 101.925%. |
| `(0.75, 0.22)` | Peaks at about 135.309%. |
| `(0.22, 0.75)` | Initially dips to about -29.511%. |
| `(0.8, 0.5)` | Peaks at about 100.833%. |

Those percentages are relative to the **change**, not the starting value.
For the spotlight's scale from 1 to 1.5, -29.511% progress means a scale of about
0.852 before the growth. For a fade from 1 to 0, progress beyond 1 means a
negative computed alpha. Parabola and the tween setters do not clamp it;
visible output also depends on the receiving component/rendering. Preview the
whole curve when tuning a property with a restricted range.

## Absolute control points

`GetEasingCtrl(ctrlValue, ctrlTime)` specifies an actual value at an actual
elapsed time, instead of fractions:

```csharp
var move = new TweenFX_X(20f, 100f, 0.6f,
    Parabola.GetEasingCtrl(80f, 0.2f));
Animatem.Instance.Anime(gameObject).AddEffect(move);
```

This moves through X = 80 at 0.2 seconds. **`ctrlTime` is in seconds**, using the
same units as the tween duration; it is not a percentage or absolute `Time.time`
timestamp. The implementation uses it directly despite the factory method's
source comment calling it a percentage.

The constructor allows mixed controls: `ctrlValue` overrides `ctrlValuePerc`,
and `ctrlTime` overrides `ctrlTimePerc`, independently. Usually the two factory
methods above are clearer.

## One easing instance per tween

A Parabola delegate carries a mutable Parabola object. Its first evaluation
converts any fractional controls into absolute value/time coordinates and caches
the fitted coefficients. It recalculates the coefficients when evaluated at
elapsed time zero, but **does not convert the percentages again** once those
absolute coordinates have been set.

Consequences for use:

- Call `GetEasing(...)` separately for each tween or axis. Do not cache one
  delegate and share it across animations with different starts or ranges.
- Each access to `Parabola.EaseIn`, `EaseOut` or `EaseBounce` returns a new delegate.
- When a scalar tween reverses, its endpoints swap but Parabola retains the
  original **absolute** control value and elapsed control time. For example,
  an initial 0→100 EaseOut reaches 75 at halfway; its reverse 100→0 also passes
  through 75 halfway. The return leg is not another 75%-complete EaseOut.
- For a time fraction other than 0.5, retaining that control time is not generally
  the same as playing the original curve backwards in time.
- When you need a new range, duration or fresh percentage-based curve, create a
  new tween with a new Parabola delegate. Changing a TweenFX property does not
  recreate its easing object.

Parabola itself depends only on the `EasingFunct` declaration in
[AnimatemTypes.cs](AnimatemTypes.cs). It can also be evaluated directly without
an Animatem component, using `easing(time, begin, range, duration)`; **range is
end minus begin**, not the endpoint.

## Valid inputs and the equation

Use a positive finite duration and a finite control time strictly between zero
and the duration (`0 < ctrlTimePerc < 1` for percentage controls). Inputs are not
validated. Endpoint control times do not define the intended three distinct
points; `ctrlTime == duration` produces a division by zero in the fit. Keep time
inside the tween interval when evaluating easing directly; Parabola extrapolates
outside it rather than clamping time.

For the first calibration with fractional controls, let `u = time / duration`,
`p = ctrlValuePerc` and `q = ctrlTimePerc`. Normalized progress is:

```text
k = (p - q) / (q * (q - 1))
progress(u) = u + k * u * (u - 1)
value(time) = begin + range * progress(time / duration)
```

This passes through `(0, 0)`, `(q, p)` and `(1, 1)`. In absolute coordinates,
Parabola fits `value(time) = a*time² + b*time + begin`. The coefficients are
calculated when calibrating; normal evaluation only evaluates the polynomial.

For monotonic progress within 0–1, choose:

```text
q² <= p <= 2q - q²     where 0 < q < 1
```

Outside that band, the quadratic reverses direction somewhere in the interval.
That can supply the desired anticipation or overshoot; the bound is a tuning
guide, not a restriction enforced by the class.
