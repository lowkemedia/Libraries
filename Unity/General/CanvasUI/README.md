# CanvasUI

Reusable controls and interaction helpers for Unity's Canvas-based uGUI interface.
These classes use the existing Canvas, EventSystem and, where needed, TextMesh Pro
setup. They are separate from Unity UI Toolkit.

| Folder | Purpose |
| --- | --- |
| [Button](Button/) | Button behaviors, styles and factories. |
| [ClickBlocker](ClickBlocker/) | Blocking clicks behind Canvas UI. |
| [DialogManager](DialogManager/) | Gameplay dialog presentation and dialog stack. |
| [PageSwiper](PageSwiper/) | Swipeable pages, page numbers and navigation dots. |
| [PointerEventCopier](PointerEventCopier/) | Forwarding pointer events and constructing event data. |
| [PopupMenu](PopupMenu/) | Popups, dropdowns and hamburger menus, including localized controls. |
| [SwipeDetector](SwipeDetector/) | Swipe gesture detection. |

[SystemUI](../SystemUI/README.md) contains standalone alerts and synthesized Beep
and Click feedback. [Localization](../Localization/README.md) contains the shared
language and translation utilities. Logger and SoundHelper remain in
[Logger](../Logger/) and [Sound](../Sound/).

The folder grouping does not introduce new namespaces, assemblies or runtime
behavior. When moving or copying these assets within a Unity project, preserve
their `.meta` files so scene, prefab and ScriptableObject references retain their
GUIDs. General utilities can have companion dependencies; copy the dependencies
needed by the selected controls as well. The separately managed Libraries
repository is not synchronized automatically.
