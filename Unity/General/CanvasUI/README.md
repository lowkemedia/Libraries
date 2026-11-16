# CanvasUI

Reusable controls and interaction helpers for Unity's Canvas-based uGUI interface.
These classes use the existing Canvas, EventSystem and, where needed, TextMesh Pro
setup. They are separate from Unity UI Toolkit.

| Folder | Purpose |
| --- | --- |
| [Button](Button/README.md) | Button behaviors, styles and factories. |
| [ClickBlocker](ClickBlocker/) | Blocking clicks behind Canvas UI. |
| [DialogManager](DialogManager/README.md) | Gameplay dialog presentation and dialog stack. |
| [PageSwiper](PageSwiper/README.md) | Swipeable pages, page numbers and navigation dots. |
| [PointerEventCopier](PointerEventCopier/) | Forwarding pointer events to another component. |
| [PopupMenu](PopupMenu/README.md) | Popups, dropdowns and hamburger menus, including localized controls. |
| [SwipeDetector](SwipeDetector/) | Swipe gesture detection. |

[SystemUI](../SystemUI/README.md) contains standalone alerts and synthesized Beep,
Click and Rollover feedback. [Localization](../Localization/README.md) contains the shared
language and translation utilities. Logger and SoundHelper remain in
[Logger](../Logger/) and [Sound](../Sound/).

Copy the companion dependencies needed by the selected controls. When updating
scripts in a Unity project, preserve their `.meta` files so scene, prefab and
ScriptableObject references retain their GUIDs.

`TextButtonStyle.pressedOffset` moves a button label while pressed, in local UI
units that scale with its Canvas. For example, `(2, -2)` moves it right and down;
`(0, 0)` leaves it stationary. The clickable area stays in place, and the offset
is removed when the pressed state ends or the button is disabled. Use a separate
child text object so moving the label does not move the button itself.

DialogManager keeps open-dialog wrappers and their click blockers beneath its own
transform. Place the manager above ordinary content in the Canvas hierarchy, and
place any controls that must remain usable over dialogs after it. Later siblings
render above the dialog layer; nested dialogs stack within that layer.

Standard `Dialog` panels measure the message after TextMesh Pro lays it out, then
apply the height in `LateUpdate`, outside Unity's graphic rebuild loop. This leaves
`messageButtonGap` UI units above the active buttons (default 32). Keep
messages top-anchored and buttons bottom-anchored. The authored dialog height is
the minimum; `EnlargeDialog` raises that minimum for the current message. Text
changes, including localization, recalculate the fit without accumulating height.
This preserves the message's authored alignment, even for a zero-height baseline
text field; no content-size fitter or scrolling is required.

## Click blockers and pointer forwarding

`ClickBlocker.MakeClickBlocker(parent, blockerClicked, blockerRolled)` creates a
Canvas-sized, translucent black raycast Image under the supplied UI parent.
Callbacks receive PointerEventData. Pointer-down is ignored while
`GlobalState.IsDragging`; entering the blocker can still invoke the rollover
callback. The helper assumes 100% object scale and a single ancestor Canvas.
Its size is measured when created, not continuously fitted on screen rotation.
The owner removes the blocker with its containing UI when it closes.

`surface.AddPointerEventCopier(target)` adds/reuses PointerEventCopier and sets
its Component target. It forwards the original pointer/drag event to each
interface that target implements. It does not clone event data, retarget a new
raycast, or search target children. Avoid forwarding cycles. Use this when a
separate raycast surface should drive an existing control.

SwipeCopier is a different, PageSwiper-specific adapter; see the
[paging guide](PageSwiper/README.md#swipe-forwarding-and-detection).

## Text backing for headings

[TextBacking](TextBacking.cs) generates a solid Canvas Image behind a
`TextMeshProUGUI` label at runtime. It follows the rendered text bounds as text,
font, alignment or wrapping changes, including changes made by localization.
It has no dependency on Localizer or LocalizedText and works with ordinary TMP
text too. The `AddTextBacking()` extension accepts a `TextMeshProUGUI`, attaches
or reuses its backing component, and returns it for optional configuration.
`color` and `padding` are simple public Inspector fields, allowing both
code configuration and Inspector editing. Values on scene/prefab components are
serialized; changes to runtime-generated components follow normal Play Mode rules.

```csharp
var backing = heading.AddTextBacking();
backing.color = Color.black;
backing.padding = new Vector2(20, 6); // Per-side padding in the label's local UI units.
```

The defaults shown above cover a divider behind a heading while leaving space
on either side. The generated Image sits immediately before the label in its
parent's draw order, ignores layout and does not intercept pointer input. Place
the divider before the label in that same draw order. No prefab or scene backing
object is needed. The component hides its Image when the label is empty, has no visible text
bounds, or is disabled, and removes the backing when destroyed.

TMP's render callback supplies measurements; `LateUpdate` applies backing size
and placement outside the graphic rebuild. Ordinary frames do not force text
mesh regeneration. Dependencies: TextMesh Pro and Unity UI.
