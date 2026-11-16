# General helpers

Small object, UI, array, color, string and numerical helpers. Many originated as
ActionScript reference methods. Their familiar calculations remain available;
source headers identify Unity/.NET alternatives and differences worth checking
before substituting an API.

## Files and dependencies

| File | Purpose | Dependencies beyond the standard library |
| --- | --- | --- |
| [Utils.cs](Utils.cs) | Object/Transform access, hierarchy, graphics and reflection-based copying. | Unity UI, Logger. |
| [UtilsRect.cs](UtilsRect.cs) | RectTransform access, UI creation, sizing and containment. | Utils, Unity UI, TextMesh Pro. |
| [UtilsArray.cs](UtilsArray.cs) | Array copies, additions, comparisons and readable dumps. | None. |
| [UtilsColor.cs](UtilsColor.cs) | HTML colors and packed numeric RGB conversion. | Unity. |
| [UtilsNumber.cs](UtilsNumber.cs) | Angles, distances, gradients, curves and number formatting. | Unity. |
| [UtilsString.cs](UtilsString.cs) | Small text transformations and function-like expressions. | Logger. |

Types live in the global namespace. Copy companion dependencies with the chosen
file; an unused method still contributes compile-time dependencies.

## Objects, coordinates and UI sizing

Utils object extensions accept a GameObject or Component. They are not general
asset helpers: `GetGameObject` rejects other Unity Object types. `GetChild(name)`
looks at direct children, not an entire subtree. `MoveToTop` and `MoveToBottom`
change sibling order. `SetParent` uses Unity's normal world-position-preserving
parent assignment; set local position/scale explicitly where needed.

With `GameObject panel` under a Canvas:

```csharp
UnityEngine.GameObject marker = panel.MakeUiObject("Marker");
marker.SetSize(80, 24);
marker.SetLocalPosition(20, -12);
marker.MoveToTop();
```

`SetX`, `SetY` and the no-argument `GetLocalPosition` use Transform.localPosition.
`GetLocalPosition(worldPosition)` converts a **world-space** point using
InverseTransformPoint; it is not a general screen-to-Canvas conversion. Use
RectTransformUtility with the appropriate event camera for screen-space input.
`SetScale(float)` sets X/Y equally and Z to 1. `GetScale` reports X and can warn
when X/Y differ; it is not a lossy/world-scale measurement.

`SetSize`, `GetWidth` and `GetHeight` use **sizeDelta**, not RectTransform.rect
or rendered screen dimensions. Stretch anchors change what those values mean.
`GetRectTransform` adds one if missing, so a getter can mutate the target.
`AttachChild` parents the child and sets sizeDelta to 1 × 1; it does not stretch
it to the parent. `GetCanvas` requires exactly one Canvas in the ancestor chain;
nested Canvases need different handling. `AinsideB` compares world corner bounds for axis-aligned UI;
do not use it as a general rotated-polygon containment test.

`RaycastGraphics` changes raycastTarget on active descendant Graphics.
`MakeInvisible` clears their colors; it does not disable interaction or objects.
`ClearChildren` destroys children using Unity's deferred Destroy.

## Copying templates

`target.CopyComponent(template)` copies public readable/writable **properties**
through reflection. It does not clone public fields, child objects, private state
or the complete serialized representation. Getters/setters run and references
are shared. Use its ignore list to exclude properties that should not be copied.
`CopyProperties` restricts copying to named properties.

`MakeUiComponent(template)` creates a new object/component, applies that property
copy and copies the RectTransform. `MakeTextMesh` excludes material properties
that should not be copied this way. These helpers are not replacements for
`Object.Instantiate` when a full prefab/hierarchy copy is required. See
[ButtonFactory](../CanvasUI/Button/README.md#creating-buttons-from-a-template)
for the explicit sound/event setup layered on these primitives.

## Arrays

```csharp
int[] values = { 1, 2, 3 };
int[] copy = UtilsArray.CloneArray(values);
bool equal = UtilsArray.ArraysAreEqual(values, copy); // true
int[] extended = UtilsArray.AddTo(values, 4);         // values is unchanged
```

`CloneArray` is shallow and preserves null. `Concat` requires non-null arrays.
`AddTo(null, value)` creates a one-item array. Repeated additions allocate new
arrays; use List<T> for a growing collection. `ResetArray` writes default(T) into
each slot of an existing non-null array.

`ArraysAreEqual` compares length, order and elements using EqualityComparer<T>.
It allows null elements but rejects null arrays, like LINQ SequenceEqual.
`RemoveFrom` is a legacy helper requiring **exactly one matching element** and
non-null elements; it is not a safe general-purpose removal operation for absent
values or duplicates. Prefer List<T>.Remove or a deliberate filtering operation
when those inputs are possible. `Print` supplies bracketed diagnostic text rather
than a serialization format.

## Colors

```csharp
UnityEngine.Color shade = UtilsColor.ConvertColor("#00000099");
UnityEngine.Color accent = UtilsColor.ColorHexToRGB(0xCC8844);
uint packed = UtilsColor.RGBToColorHex(accent.r, accent.g, accent.b);
```

`ConvertColor` delegates nonempty text to ColorUtility.TryParseHtmlString but
discards its success flag; null/empty input becomes black. Use TryParseHtmlString
directly when invalid input needs an explicit response.
The numeric conversion reads/writes **0xRRGGBB**, without alpha. It uses normalized
channels; packing clamps finite channels to 0–1 and rounds byte values with ties
to even. Bits above the lowest 24 are ignored when unpacking.

## Angles, gradients and curves

Angles are degrees: zero points right and positive Y points up.
`XYToAngle`/`VectorToAngle` normalize to [0, 360), with the zero vector mapped to
zero. `AngleToVector` accepts an optional length. `Rotate` rotates around the
origin. `Distance` accepts four coordinates; `DistanceBtwnPts` accepts Vector2s.

The slope helpers deliberately retain their original conventions:

- `Gradient(rise, run)` returns zero for zero rise, and **rise** for a vertical
  line with nonzero rise. That result is not mathematical infinity.
- `GradientFromPts` uses the same convention.
- `YOnALine` evaluates a point/slope line. `XOnALine` returns zero for zero slope,
  even though a horizontal line has no unique inverse X.
- `YOnACurve` evaluates the quadratic through three points. Supply distinct X
  coordinates; there is no degeneracy validation.

Use these conventions knowingly when porting older calculations. For animation
around a selected time/value point, see [Parabola](<../Animatem/README Parabola.md>).
`WithinRange` includes both endpoints regardless of their order. `CleanAngle`
wraps finite degrees. `IncOrDec` chooses the shortest direction around a ring of
indices, with +1 on a tie; inspect its range arguments before reuse.

## Number and time formatting

```csharp
string shortValue = UtilsNumber.AbbreviateNumber(12500); // "12.5K"
string grouped = UtilsNumber.FormatNumber(1234.5, 2);    // "1,234.5"
double truncated = UtilsNumber.ToDecimalPrecision(-1.29, 1); // -1.2
```

Formatting is invariant, with a decimal point and comma grouping by default;
it is not locale-aware currency or number presentation. `FormatNumber` omits
trailing fractional zeros and accepts a custom group separator. Precision is
0–15 decimal places. Truncation is toward zero by default; `round: true` uses
midpoint rounding away from zero, subject to binary floating-point precision.
Abbreviation chooses K/M/B before rounding; `dontAbbreviateThousands` delays K
until 10,000. `PadZerosToNumber` and `AddCommasToNumber` retain their source
examples alongside native formatting alternatives.

`ConvertMillisecondsToTimeRemaining` returns `TimeRemaining.Duration` and
`DurationUnits` with English singular/plural labels. Supply finite milliseconds. Negative
input becomes zero; boundaries remain inclusive at 60 seconds, 60 minutes,
24 hours and 30 days, and months approximate 30 days. This is a display helper,
not a calendar or localization API.

## Strings

`First` and `Last` return the null character for null/empty strings.
`CheckForQuote` detects straight apostrophes and can warn; it does not implement
US/UK quotation punctuation. `CorrectForQuotes` escapes double quotes, not a
complete JSON string; use a serializer for JSON. `CorrectForTabs` expands tabs
to four spaces and `CorrectBreaks` replaces literal `<br>` with newlines.

`RemoveMarkup` and `ApplyStringedFunction` are simple legacy text operations,
not HTML parsers or general expression evaluators. Supply well-formed controlled
input. The function helper passes a parsed name and comma-separated arguments
to your delegate; the host decides what those names mean. It does not support
arbitrary nesting, quoting or escaping. `RemoveChunk` uses an exclusive end index.
Most transformations expect non-null text; check each method's contract rather
than assuming uniform null handling.
