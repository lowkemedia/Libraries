//
//  ClickButton - Button package
//  Russell Lowke, September 1st 2020
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
using CallbackTypes;

[System.Serializable]
public class ClickButtonEvent : UnityEvent<ClickButton> { }

[RequireComponent(typeof(Image))]
public class ClickButton : MonoBehaviour,
             IPointerDownHandler, IPointerUpHandler, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
{
    public ClickButtonStyle style;
    public new bool enabled = true;                             // implements own enable, so disabled buttons still keep track of PointerInside, etc.
    public bool selected;

    public ClickButtonEvent onClickEvent;                       // Unity event for clicking button
    public event Callback OnUpdateEvent;                        // Regular event for update
    public event Callback OnRolloverEvent;                      // Regular event for rollover
    public event Callback OnRolloutEvent;                       // Regular event for rollout

    public bool useDefaultSound = true;
    public AudioSource clickSound;
    public AudioSource rollSound;
    public bool waitForClickSound;                              // wait for click sound to end before invoking onClick
       
    public Sprite NormalSprite { get; private set; }            // up
    public Sprite HighlightedSprite { get; private set; }       // over
    public Sprite PressedSprite { get; private set; }           // down
    public Sprite SelectedSprite { get; private set; }          // selected
    public Sprite DisabledSprite { get; private set; }          // disabled
    public bool SkipPointerUp { get; set; }               // skips drawing the normal ("Up") state after a click
    public bool PointerInside { get; private set; }       // true if pointer inside button

    private bool IsHandheld {
        get { return SystemInfo.deviceType == DeviceType.Handheld;  }
    }

    private bool _showAsPressed;                                // true if button override as pressed
    private bool _pressed;                                      // true if button is pressed
    public bool Pressed {                                       // true if pressed
        get {
            if (_showAsPressed) {
                return true;
            }
            return _pressed && (IsHandheld || PointerInside);
        }
    }

    
    private Image _image;                                       // image used for button
    private Sprite _startSprite;                                // sprite button image started with
    public Image Image {
        get {
            if (!_image) {
                _image = GetComponent<Image>();
                _startSprite = _image.sprite;
            }
            return _image;
        }
    }

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
        if (SoundHelper.IsAvalable) {
            // get default sound
            if (clickSound == default && useDefaultSound) {
                clickSound = SoundHelper.Click;
            }

            if (rollSound == default && useDefaultSound) {
                rollSound = SoundHelper.Roll;
            }
        }

        // TODO: check if pointer started inside button

        SetStyle(style);
    }

    public void SetStyle(ClickButtonStyle style)
    {
        if (style) {
            SetStyle(style.normalSprite,
                     style.highlightedSprite,
                     style.pressedSprite,
                     style.selectedSprite,
                     style.disabledSprite,
                     style.skipPointerUp);
        } else if (_startSprite) {
            SetStyle();
        }
    }

    public void SetStyle(Sprite normalSprite = default,
                         Sprite highlightedSprite = default,
                         Sprite pressedSprite = default,
                         Sprite selectedSprite = default,
                         Sprite disabledSprite = default,
                         bool skipPointerUp = false)
    {
        NormalSprite = normalSprite;
        HighlightedSprite = highlightedSprite;
        PressedSprite = pressedSprite;
        SelectedSprite = selectedSprite;
        DisabledSprite = disabledSprite;
        SkipPointerUp = skipPointerUp;

        // ensure Sprites
        if (NormalSprite == default) {
            NormalSprite = _startSprite;
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

        UpdateButton();
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
        OnRolloverEvent?.Invoke();

        if (rollSound != null) {
            if (IsHandheld) {
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
        OnRolloutEvent?.Invoke();
    }

    public virtual void OnPointerDown(PointerEventData pointerEventData)
    {
        _pressed = true;
        if (!Enabled) { return; }

        UpdateButton();
    }

    public virtual void UpdateButton()
    {
        if (Selected) {
            Image.sprite = SelectedSprite;
        } else if (!Enabled) {
            Image.sprite = DisabledSprite;
        } else if (Pressed) {
            Image.sprite = PressedSprite;
        } else if (PointerInside) {
            Image.sprite = HighlightedSprite;
        } else {
            Image.sprite = NormalSprite;
        }

        OnUpdateEvent?.Invoke();
    }

    //
    // Click for pressDuration seconds
    //  a good visual pressDuration is 0.33f
    public virtual void Click(float pressDuration = 0)
    {
        if (!(isActiveAndEnabled && Enabled)) {
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

            onClickEvent?.Invoke(this);

            // SkipPointerUp skips returning to the normal ("Up") state after
            //  clicking, which is useful with tab menus or button toggles,
            //  otherwise you see the normal state flicker.
            _showAsPressed = SkipPointerUp;
            UpdateButton();
        }

        if (waitForClickSound && pressDuration == 0) {
            SoundHelper.Play(clickSound, unpressCallback);
        } else {
            if (clickSound) {
                clickSound?.Play();
            }
            if (pressDuration > 0) {
                Delayer.Delay(pressDuration, unpressCallback);
            } else {
                unpressCallback();
            }
        }
    }
}
