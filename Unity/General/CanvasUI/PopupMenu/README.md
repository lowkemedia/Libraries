# Popup menus

Canvas-based menus built from a configured TextButton template. They use uGUI,
TextMesh Pro and pointer events, not Unity UI Toolkit. The controls own display
and selection; application code owns the meaning of each option and any settings
or persistence changes.

## Classes and files

| Class | Purpose and behavior |
| --- | --- |
| [Popup](Popup/Popup.cs) | Selected-value control. Opening hides the closed button and aligns the menu with the selected item. May reverse its internal item order to fit the available rectangle. |
| [DropDown](DropDown/DropDown.cs) | Opens below its button, leaving that button visible and highlighted. Builds rows in reverse iteration order without reversing the item array. |
| [Hamburger](Hamburger/Hamburger.cs) | Icon-triggered menu. Uses a separate `iconButton` and a text-button template positioned offscreen. |
| [LocalizedPopup](Popup/LocalizedPopup.cs), [LocalizedDropDown](DropDown/LocalizedDropDown.cs), [LocalizedHamburger](Hamburger/LocalizedHamburger.cs) | Translate labels through Localizer and apply a text style. Menu identity remains the supplied key, not its translated text. |
| [PopupMenuTypes](PopupMenuTypes.cs) | `PopupMenuEventArgs`, `PopupMenuEvent` and diagnostic IDs. |

## Scene setup

Use an existing wired control as a starting point. Supply a Canvas with UI
raycasting and an EventSystem, then assign:

- `popupTextButton`: the closed control and row template, with its ClickButton,
  TextMeshProUGUI text field and button/text styles configured.
- `popupLabel`: the separate label, if calling `LabelText` or `LabelKey`.
- `popupBgSprite`: the menu background sprite; `padding` controls spacing.
- `onMenuSelectedEvent`: an initialized UnityEvent (normally serialized with the
  component). Pass a callback to `Initialize` to install the runtime handler.
- `iconButton`: additionally required by Hamburger.

The generated rows inherit the template's dimensions, styling and sound settings.
Changing the template is the starting point for skinning. Localized controls also
need the requested keys, text style, fonts and any referenced TMP sprite assets
loaded by the application.

Dependencies include [Button](../Button/), [ClickBlocker](../ClickBlocker/),
[Utils](../../Utils/), [Logger](../../Logger/) and the button helpers' dependencies.
Localized classes additionally use [Localization](../../Localization/README.md).
See the [General dependency guidance](../../README.md) when copying these controls
into another project. Preserve source `.meta` files when moving Unity assets.

## Initialize a localized popup

Example keys and style below must exist in the application's localization/style
resources. Assign `_modePopup` in the inspector before this component starts.

```csharp
using UnityEngine;
using PopupMenuTypes;

public class ModeSelector : MonoBehaviour
{
    [SerializeField] private LocalizedPopup _modePopup;

    private void Start()
    {
        _modePopup.Initialize(
            new[] { ".manual", ".automatic" },
            ".manual", OnModeSelected, "#menu_text");
        _modePopup.LabelKey(".mode", style: "#menu_text");
    }

    private void OnModeSelected(PopupMenuEventArgs args)
    {
        bool automatic = args.MenuItem == ".automatic";
        // Apply the chosen mode to the application's model here.
    }
}
```

Plain `Popup.Initialize(items, selected, callback)` takes literal strings.
Localized `Initialize(menuKeys, selectedKey, callback, style, variables,
giveWarning)` takes localization keys/expressions. `variables` is shared by the
translated entries; `giveWarning` controls localization warnings. `LabelKey`
has its own variables/style/warning arguments.

Initialize with a nonempty array of unique strings and a valid selected item.
The array is cloned; later changes to the caller's array do not update the menu.
Reinitialize when the options themselves change. A null/empty selected string
chooses index zero in the current internal order.

## Reading and changing selection

These APIs are related but deliberately do different things:

| API | Meaning |
| --- | --- |
| `args.MenuItem` | String/key of the clicked item. Use this to identify its meaning. |
| `popup.Selected` | Current selected string/key. Assigning it updates selection and presentation without invoking the selection callback. |
| `args.Index` | Index supplied by that generated row, relative to the menu's current internal array. Not a stable index into the caller's original options. |
| `popup.SelectedIndex` | Current internal index. Assigning it updates `PreviousIndex`, the displayed text and menu position, without invoking the callback. Invalid indices fall back to zero. |
| `popup.PreviousIndex` | The index before the most recent `SelectedIndex` assignment. Useful immediately inside the selection callback; not a persistent history. |
| `popup.Select(key)` | Invokes the matching generated row's click event, including the normal selection callback and hiding the menu. Supported by Popup/LocalizedPopup; see the subclass limitation below. |

Use `Selected` for display synchronization. Use `Select` when the normal
application selection handler must run. `Select` invokes the click UnityEvent
directly, so do not treat it as enforcing pointer interaction or disabled-button
checks; enforce application eligibility in the handler.

For a localized menu, use the exact supplied key/expression, including any sprite
markup or embedded variables. Do not compare against translated display text.
When mapping to a parallel array of application values, find `args.MenuItem` in
the original key array. For a known option, a direct comparison such as
`args.MenuItem == ".automatic"` is simpler.

### Why indices can change

`Popup.MakePopupGameObject` places the menu around the selected item, then checks
its background against the ClickBlocker rectangle with `UtilsRect.AinsideB`.
If it does not fit, it calls `Array.Reverse(_menuItems)` and reapplies the selected
key before building the rows. This is why event indices must not be used as
original option indices. It is a single reversal attempt, not general overflow,
clamping or scrolling support.

`DropDown` and `Hamburger` have their own builders and do not use this fit check.
Their rows are created by iterating backward over their internal arrays.

## Callback order and cancellation

A row click calls `MenuButtonClicked` in this order:

1. Set `Selected` to the clicked item's key, recording the previous index.
2. Invoke `onMenuSelectedEvent` with the Popup, MenuItem and Index.
3. Hide the menu.

The callback therefore sees the proposed selection already displayed. To reject
it immediately without another callback:

```csharp
Popup popup = args.Popup;
popup.SelectedIndex = popup.PreviousIndex;
```

For a confirmation dialog, capture the requested key and restore the previous
selection before showing the dialog. Cancel then leaves the previous selection
intact. After approval, apply the model change and update/rebuild the popup as
needed. If calling `Select(requestedKey)` afterward, remember that it invokes
the selection handler again; the handler must now recognize the approved state.
Do not retain `PreviousIndex` across rebuilding or reordering the menu; retain a
key when a selection must survive such changes.

Passing a non-null callback to `Initialize` removes existing runtime selection
listeners and installs the supplied callback. Passing null leaves listeners alone;
it does not unsubscribe them. As with UnityEvent generally, `RemoveAllListeners`
does not remove persistent inspector listeners. Opening a menu reinitializes it
with no replacement callback, so its installed listener is retained.

## Opening, closing and rollover

`Start` wires the closed text button; Hamburger also wires its icon button.
`OnClickButton` toggles open/closed. `ShowPopup` and `HidePopup` are protected
virtual methods. Each implementation currently rebuilds its generated menu on
open and moves the relevant control above siblings.

For Popup, clicking the outside ClickBlocker closes the menu. Entering that
blocker invokes `OnPopupRolloutEvent`; this event does not itself close the menu.
`OnMenuRollEvent(menuItem, index)` reports row rollover. The blocker ignores
pointer-down dismissal while `GlobalState.IsDragging` is true.

DropDown and Hamburger create blockers without the outside-click/rollover
callbacks. They do not currently inherit Popup's outside-click dismissal through
those builders; the trigger and row selection still close their menus.

## Current limitations and extension points

These notes describe the source as it stands, not completed features or promised
behavior. The controls were inspected for this reference; these limitations have
not all been reproduced in a running scene.

- **Programmatic selection in subclasses:** DropDown and Hamburger do not fill
  `_menuButtons`, but inherited `Select` relies on it. Do not assume `Select`
  works for those subclasses until their builders populate that array.
- **Rebuild on open:** all three `ShowPopup` methods contain a TODO to reposition
  rather than recreate the menu. Rebuilding also resets index history. Keep
  callback behavior and selected-key preservation in mind when changing this.
- **Touch behavior:** Popup explicitly notes that devices need different
  behavior from desktop. Rollover is pointer-oriented; no dedicated touch
  interaction policy is implemented in these classes.
- **Hamburger template workaround:** the text template is moved offscreen rather
  than disabled because its factory depends on it being active. The source marks
  this for cleanup. Do not simply hide the template without checking the factory.
- **Localization inheritance:** LocalizedPopup contains a TODO to consider
  composition rather than subclassing. The three localized classes currently
  repeat the same label/style overrides.
- **Selection presentation:** assigning Selected/SelectedIndex updates text and
  position, but does not rebuild the generated row buttons' selected/disabled
  styling. Opening rebuilds the rows using the new selection.
- **No separate item IDs/data:** strings currently serve as both identity and
  label input. There is no public per-item payload or per-item enabled-state API.
  Stable IDs separate from localized labels would be an extension, not an
  existing feature.
- **Sizing and navigation:** rows use the template size; there is no popup-level
  scrolling, long-list virtualization or explicit keyboard/controller focus
  navigation here. ClickBlocker sizing assumes objects are at 100% scale.

The main extension seams are `MakePopupGameObject`, `MakeTextButton`,
`UpdatePopupPosition`, `SelectedText`, `ShowPopup` and `HidePopup`. If changing a
builder, preserve the selection event order and decide explicitly which dismissal,
button-array and ordering behaviors it supports.
