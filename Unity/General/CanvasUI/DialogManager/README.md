# Canvas dialogs

Reusable styled dialogs that use the application's Canvas, localization and
button assets. For an alert before that setup exists, use
[SystemUI.Alert](../../SystemUI/README.md).

## Scene setup

1. Add one DialogManager to a RectTransform below a Canvas.
2. Build your dialog panels and assign them to its `dialogs` array. Start
   initializes and hides every entry. Include the standard Dialog in this array
   and name its GameObject **Dialog** for the static Show helpers.
3. On Dialog assign the `title`, `message`, `firstButton`, `secondButton` and
   `okButton` references. Supply each TextButton's ClickButton, TMP label and styles.
4. Initialize Localizer and load your text/styles. Supply `.ok`, `.cancel`, `.yes`
   and `.no` keys used by the standard helpers, plus your titles/messages.
5. Attach/configure SoundHelper for click feedback and the outside-click beep.
   Set the dialog style keys with `DialogManager.SetStyle(titleStyle, messageStyle,
   buttonStyle)` before displaying localized content.

The manager initializes in **Start**, not Awake. Call it after that Start has run;
do not rely on the order of unrelated Start methods. The `dialog` Inspector field
is not the static helper lookup: the helpers search `dialogs` for the name above.

## Showing a standard dialog

After setup, with `.confirm_title` and `.confirm_message` in your loaded text:

```csharp
Dialog.ShowYesNo(".confirm_title", ".confirm_message",
    yesCallback: () => Logger.Detail("Confirmed"),
    noCallback: () => Logger.Detail("Canceled"));
```

`ShowAlert` has one OK button. `ShowOkayCancel` supplies Cancel and OK, with a
callback for OK. `ShowYesNo` supports both callbacks. Optional AudioSources choose
button sounds; default/null uses SoundHelper.Click. The Large alert/yes-no variants
raise the minimum height by 60 UI units.

Buttons hide the dialog **before** invoking the selected callback. The normal
ClickButton path controls whether sound completion delays that action. Clicking
the outside blocker beeps; it does not dismiss the dialog. These controls do not
pause time or unrelated game/input polling.

## Layout and stacking

Title/message stay top-anchored; buttons stay bottom-anchored. The message's TMP
rendered bounds determine required height, including wrapping and inline sprites.
The measurement is captured during TMP's render callback and applied in LateUpdate,
outside the graphic rebuild. `messageButtonGap` defaults to 32 UI units.
The authored height is the minimum and resets for each new message.

Dialog messages enable orphan prevention with **no combined-word width limit**.
Other LocalizedText fields retain their own settings; see
[orphan prevention](../../Localization/Localizer/README.md#preventing-single-word-orphan-lines).
There is no automatic scrolling/maximum-height policy for an arbitrarily long
Canvas dialog, so check long translations against the available screen height.

The manager creates an Open Dialog wrapper and ClickBlocker under its own
transform. Canvas sibling ordering determines which other controls sit above it.
It keeps a stack: close dialogs in last-opened-first-closed order. HideDialog pops
the stack; it does not search for and remove an arbitrary lower entry. Do not open
the same panel twice, and do not use the single standard Dialog instance for two
simultaneous messages.

## Custom dialogs

Subclass DialogBase and override Initialize to wire controls, calling the base
method. Populate content and call `base.SetupDialog()` for each showing, then
`ShowDialog()`. Showing consumes the setup flag. Close through `HideDialog()` so
the panel, wrapper and manager stack stay synchronized.

Include CanvasUI buttons, ClickBlocker, Utils/UtilsRect/UtilsColor, Localizer/TMP,
SoundHelper, Logger and CallbackTypes with their companion dependencies. Keep
scene/prefab references and script GUIDs when updating an existing consumer.
