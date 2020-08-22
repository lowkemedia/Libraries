//
//  ClickButton - Button package
//  Russell Lowke, August 22nd 2020
//
//  Copyright (c) 2019-2020 Lowke Media
//  see https://github.com/lowkemedia/Libraries for more information
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//
//

using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Events;
using UnityEngine.UI;

[System.Serializable]
public class ClickButtonEvent : UnityEvent<ClickButton> { }

public class ClickButton : MonoBehaviour,
             IPointerDownHandler, IPointerUpHandler, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
{
    public delegate void Callback();

    public ClickButtonStyle style;
    public new bool enabled = true;                             // implements own enable, so disabled buttons still keep track of PointerInside, etc.
    public bool selected;

    public ClickButtonEvent onClick;

    public bool useDefaultSound = true;
    public AudioSource clickSound;
    public AudioSource rollSound;
    public bool waitForClickSound;                              // wait for click sound to end before invoking onClick

    public Image ButtonImage        { get; private set; }       // image currently shown for button
    public Sprite NormalSprite      { get; private set; }       // up
    public Sprite HighlightedSprite { get; private set; }       // over
    public Sprite PressedSprite     { get; private set; }       // down
    public Sprite SelectedSprite    { get; private set; }       // selected
    public Sprite DisabledSprite    { get; private set; }       // disabled
    public bool SkipPointerUp       { get; set; }               // skips drawing the normal ("Up") state after a click

    public bool PointerInside       { get; private set; }       // true if pointer inside button

    private bool _showAsPressed;                                // true if button override as pressed
    private bool _pressed;                                      // true if button is pressed
    public bool Pressed {                                       // true if pressed
        get {
            return _pressed || _showAsPressed;
        }
    }

    public event Callback OnUpdateButtonEvent;

    public bool Enabled {
        get { return enabled; }
        set {
            enabled = value;
            if (enabled) {
                OnEnable();
            } else {
                OnDisable();
            }
        }
    }

    // called by Unity on toggle
    private void OnEnable()
    {
        UpdateButton();
    }

    // called by Unity on toggle
    private void OnDisable()
    {
        _showAsPressed = false;
        _pressed = false;
        PointerInside = false;
        UpdateButton();
    }

    // Note: disabled buttons (Enabled == false) that are Selected == true, show as Selected.
    // This is useful for tab menus where the selected tab is not enabled
    public bool Selected {
        get { return selected; }
        set {
            _showAsPressed = false;
            selected = value;
            UpdateButton();
        }
    }

    protected virtual void Start()
    {
        ButtonImage = GetComponent<Image>();

        if (style) {
            SetStyle(style);
        }

        if (SoundHelper.IsAvalable) {
            // get default sound
            if (clickSound == default && useDefaultSound) {
                clickSound = SoundHelper.ClickSound;
            }

            if (rollSound == default && useDefaultSound) {
                rollSound = SoundHelper.RollSound;
            }
        }

        // TODO: check if pointer started inside button

        UpdateButton();
    }

	public void SetStyle(ClickButtonStyle style)
    {
        SetStyle(style.normalSprite,
                 style.highlightedSprite,
                 style.pressedSprite,
                 style.selectedSprite,
                 style.disabledSprite,
                 style.skipPointerUp);
    }

    public void SetStyle(Sprite normalSprite,
                         Sprite highlightedSprite,
                         Sprite pressedSprite,
                         Sprite selectedSprite,
                         Sprite disabledSprite,
                         bool skipPointerUp)
    {
        NormalSprite = normalSprite;
        HighlightedSprite = highlightedSprite;
        PressedSprite = pressedSprite;
        SelectedSprite = selectedSprite;
        DisabledSprite = disabledSprite;
        SkipPointerUp = skipPointerUp;

        // ensure Sprites
        if (NormalSprite == default) {
            NormalSprite = ButtonImage.sprite;
        }

        if (HighlightedSprite == default) {
            HighlightedSprite = NormalSprite;
        }

        if (PressedSprite == default) {
            PressedSprite = HighlightedSprite;
        }

        if (SelectedSprite == default) {
            SelectedSprite = PressedSprite;
        }
    }

    public virtual void OnPointerClick(PointerEventData pointerEventData)
    {
        Click();
    }

    public virtual void OnPointerUp(PointerEventData pointerEventData)
    {
        _pressed = false;
        if (!Enabled) { return; }

        UpdateButton();
    }

    public virtual void OnPointerEnter(PointerEventData pointerEventData)
    {
        PointerInside = true;
        if (!Enabled) { return; }

        UpdateButton();

        if (rollSound != null) {
            if (SystemInfo.deviceType == DeviceType.Handheld) {
                // don't play roll sound on handheld devices
                return;
            }
            rollSound.Play();
        }
    }

    public virtual void OnPointerExit(PointerEventData pointerEventData)
    {
        PointerInside = false;
        if (!Enabled) { return; }

        UpdateButton();
    }

    public virtual void OnPointerDown(PointerEventData pointerEventData)
    {
        _pressed = true;
        if (!Enabled) { return; }

        UpdateButton();
    }

    public virtual void UpdateButton()
    {
        if (!ButtonImage) {
            return;     // too early, button hasn't called Start() yet.
        }

        if (Selected) {
            ButtonImage.sprite = SelectedSprite;
        } else if (!Enabled) {
            ButtonImage.sprite = DisabledSprite;
        } else if (Pressed) {
            ButtonImage.sprite = PressedSprite;
        } else if (PointerInside) {
            ButtonImage.sprite = HighlightedSprite;
        } else {
            ButtonImage.sprite = NormalSprite;
        }

        OnUpdateButtonEvent?.Invoke();
    }

    //
    // Click for pressDuration seconds
    //
    public virtual void Click(float pressDuration = 0)      // pressDuration = 0.33f
    {
        if (! (isActiveAndEnabled && Enabled)) {
            // button must be active and enabled to click
            return;
        }

        // show button as pressed
        _showAsPressed = true;
        UpdateButton();

        void unpressCallback()
        {
            //
            // invoke and unpress button

            onClick?.Invoke(this);

            // SkipPointerUp skips returning to the normal ("Up") state after
            //  clicking, which is useful with tab menus or button toggles,
            //  otherwise you see the normal state flicker.
            _showAsPressed = SkipPointerUp;
            UpdateButton();
        }

        if (waitForClickSound) {
            if (pressDuration > 0) {
                Logger.Warning("waitForClickSound should not be used with pressDuration > 0");
            }
            SoundHelper.SoundCallback(clickSound, unpressCallback);
        } else {
            if (clickSound) {
                clickSound.Play();
            }
            Delayer.Delay(pressDuration, unpressCallback, false);
        }
    }
}
