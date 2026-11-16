# Page swiping and indicators

Horizontal paging for a prebuilt row of equally spaced pages. PageSwiper moves
its own Transform; it does not load pages, generate their contents or virtualize
long lists.

## Setup

Put PageSwiper on the moving panel. Arrange pages at a fixed local-space width,
under a clipped viewport if required, and supply a Canvas/EventSystem/raycastable
Graphic for input. Attach a Mover host before animated navigation is used.
The `swipeArea` field alone does not forward input; put SwipeCopier on child
Graphics that should send their drag/click events to the panel.

Call `Initialize(totalPages, pageWidth)` with at least one page and positive
width after arranging the panel. It records the starting local position and
snaps to page zero. Initialize before PageDots/PageNumber Start builds their
indicators; establish initialization order explicitly in the host.
The coordinate helpers convert world points rather than performing a general
screen-to-Canvas conversion, so validate camera/Canvas mode and scaling for your
layout; do not assume all Canvas configurations work unchanged.

## Navigation and events

Indices are zero-based. For a configured `PageSwiper swiper`:

```csharp
swiper.onPageChange.AddListener(index => Logger.Detail("Page index: " + index));
swiper.GotoPage(2); // Clamped to the available range; animates with Mover.
```

| API | Meaning |
| --- | --- |
| `PageIndex`, `TotalPages` | Current logical index and configured page count. |
| `GotoPage(index, snapTo, callback)` | Clamps the index; updates PageIndex and invokes onPageChange immediately, before animation completes. |
| `PageChange(delta)` | Relative navigation; may signal attempts beyond the first/last page before clamping. |
| `onDragPageChange` | Provisional drag index, potentially outside the valid range. |
| `onPageClick` | Click notification; clicks also advance by default. Set `clickAutoPagesForward = false` to disable that advance. |
| `OnSwipeBeforeFirstPage`, `OnSwipePastLastPage` | C# events when a relative navigation attempt starts at an end and moves beyond it. |

The GotoPage callback runs after an animated move; the current `snapTo: true`
branch does **not** invoke it. onPageChange can fire even when the resulting
index has not changed. The drag threshold is 20% of page width; animation uses
0.5 scaled seconds. Repeated navigation starts independent Mover coroutines;
there is no cancellation/serialization of overlapping moves in this component.

## Dots and page numbers

PageDots sits beside PageSwiper on the same object. Assign an active PageDot
template with its four normal/selected/small sprites; it creates copies and hides
the template. `maxDots = -1` shows one per page. For capped displays, use an odd
count of at least three; a smaller cap uses small edge dots and a moving selection.
The implementation rejects even caps when fewer dots than pages are shown.
`padding` is local UI spacing between dots.

Dots are indicators, not clickable page-navigation buttons. They are generated
in Start and are not rebuilt automatically when page count or width changes.
Test first/last pages, large jumps and capped lists when integrating.

PageNumber uses a TextMeshProUGUI `pageNumText`, an optional style key and Localizer's
`.of` key to display a one-based number and total. Supply that translation and
initialize localization before the indicator refreshes.

## Swipe forwarding and detection

SwipeCopier forwards begin/drag/end interaction to its assigned PageSwiper.
If its `onClickEvent` has **persistent Inspector listeners**, a click invokes that
event instead of forwarding to PageSwiper. Runtime listeners alone do not select
that alternate click route; initialize the UnityEvent for runtime-created controls.

The separate [SwipeDetector](../SwipeDetector/SwipeDetector.cs) reports horizontal
local displacement through `onSwipe`. It does not apply PageSwiper's page threshold
or navigation policy. `ignoreClicks` suppresses click reports; a click otherwise
normally reports zero displacement. It is not used internally by PageSwiper.

Dependencies: Mover, Utils/UtilsRect, Unity UI, CallbackTypes and their companions.
PageDots adds its template/Image dependencies; PageNumber adds TMP and Localizer.
