# Canvas buttons

Sprite-based pointer controls for uGUI, with optional TMP labels and icon skins.
Use a Canvas with a GraphicRaycaster and an EventSystem/input module.

## ClickButton, TextButton and IconButton

Put ClickButton on the raycastable Image that defines the hit area. Assign a
ClickButtonStyle asset or call SetStyle; style assets provide the sprites for
normal, highlighted, pressed, selected and disabled states. Normal/highlighted/
pressed/selected states have fallback sprites; supply a disabled sprite when
that state should have its own appearance.

TextButton holds a `textField` and requires ClickButton on the same GameObject.
Assign a TextButtonStyle through `textStyle`, or through the
ClickButtonStyle's `textButtonStyle`. IconButton similarly finds a parent
ClickButton and uses an IconButtonStyle on its own Image. Its icon Image does
not intercept raycasts. Both expose `OnClickEvent`, forwarding the ClickButton's
`onClickEvent`.

For an existing configured `ClickButton button`:

```csharp
button.onClickEvent.AddListener(clicked => Logger.Detail("Button clicked"));
button.Selected = true;
button.Enabled = false; // Selected styling is retained, useful for a current tab.
```

Use `Enabled` and `Selected` at runtime so their setters refresh presentation.
The camelCase fields are Inspector configuration; assigning them directly bypasses
those setter effects. ClickButton has a custom `enabled` field separate from the
inherited Behaviour flag. Do not treat it as Unity's component toggle.
`Interactable` gates click handling but is not the disabled sprite state.

`Click()` simulates a click through the control's active/interactable checks.
Invoking `onClickEvent` directly bypasses those checks and the sound/press path.
`Click(pressDuration)` uses Delayer for a positive duration. `SkipPointerUp` retains
the pressed presentation after a click to prevent a flash during tab transitions.
Selected presentation takes precedence over disabled presentation.

## Sounds and pressed labels

With SoundHelper available, Start supplies its click/roll sources when
`useDefaultSound` is true and no explicit source was assigned. Rollover sound is
suppressed on handheld devices. `waitForClickSound` delays the normal click
callback until playback finishes; this route requires SoundHelper's host.
A positive `pressDuration` uses Delayer instead. Include the helper code even
when not enabling these options because the dependencies are compiled together.

`TextButtonStyle.pressedOffset` moves the label in local UI units while pressed.
For example `(1.5, -1.5)` moves it right/down. Put the label on a separate child
so the hit area stays still. The offset is removed on release/disable. See
[CanvasUI](../README.md) for the reusable TextBacking utility.

## Creating buttons from a template

With a configured active TextButton `template` and Canvas child `parent`:

```csharp
TextButton copy = parent.MakeTextButton(template, "Preview");
copy.OnClickEvent.AddListener(clicked => Logger.Detail("Preview requested"));
```

ButtonFactory.MakeClickButton copies properties/rect geometry, explicitly copies
sound fields, and supplies a fresh click UnityEvent. It does not clone the full
GameObject hierarchy or preserve the template's Inspector click listeners.
MakeTextButton builds a label and applies `template.ClickButton.style.textButtonStyle`;
provide those style assets. It does not create an IconButton. Keep templates active
while constructing copies and configure the returned button as needed.
See [reflection-copy limits](../../Utils/README.md#copying-templates).

## Specialized controls

| Control | Current behavior and setup |
| --- | --- |
| PressButton | Repeats clicks while pressed and inside; `invokeInterval` defaults to 0.15 scaled seconds. |
| SneakyButton | Starts a delayed click on pointer-down (`holdDuration`, default 1 second). Pointer-up/exit do not cancel its timer; it is not a continuous-hold recognizer. |
| LookAroundButton | Assign `lookAroundCamera`; drag rotates its generated parent using legacy Mouse X/Y input. Large rotation deltas are ignored. |
| GyroLookAroundButton | Adds gyroscope orientation when supported; uses the LookAround camera setup. Check orientation on target hardware. |
| TintOverlayButton | Uses `tintImage` and an ancestor ScrollRectExtend to display an overlay while pressed/hovered; tracks that scroll control's drag events. |

These are pointer controls, not Unity Selectables with complete keyboard/gamepad
navigation. The host must provide other input routes if required.

## Dependencies

ClickButton needs Unity UI, GlobalState, SoundHelper, Delayer and their companions
(Logger and CallbackTypes). TextButton and ButtonFactory add TextMesh Pro, Utils,
UtilsRect and UtilsColor as used by their source. Styles are ScriptableObjects
created/assigned by the consuming project; no skins, fonts or prefabs are bundled.
