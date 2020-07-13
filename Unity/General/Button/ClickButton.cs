//
//  ClickButton - Button package
//  Russell Lowke, April 28th 2020
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
    public ClickButtonStyle style;
    public new bool enabled = true;
    public bool selected;

    public ClickButtonEvent onClick;

    public bool useDefaultSound = true;
    public AudioSource clickSound;
    public AudioSource rollSound;

    public Image ButtonImage        { get; private set; }       // image currently shown for button
    public Sprite NormalSprite      { get; private set; }       // up
    public Sprite HighlightedSprite { get; private set; }       // over
    public Sprite PressedSprite     { get; private set; }       // down
    public Sprite SelectedSprite    { get; private set; }       // selected
    public Sprite DisabledSprite    { get; private set; }       // disabled
    public bool IsTabOrToggle       { get; set; }               // omits drawing the Normal state after a click

    public bool Pressed             { get; private set; }       // true if pressed 
    public bool PointerInside       { get; private set; }       // true if point currenty inside
    

    public delegate void UpdateButtonEvent(bool showAsPressed);
    public event UpdateButtonEvent OnUpdateButtonEvent;

    public bool Enabled {
        get { return enabled; }
        set {
            enabled = value;
            UpdateButton();
        }
    }

    // Note: disabled buttons (Enabled == false) that are Selected == true, show as Selected.
    // This is useful for tab menus where the selected tab is not enabled
    public bool Selected {
        get { return selected; }
        set {
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
                 style.isTabOrToggle);
    }

    public void SetStyle(Sprite normalSprite,
                         Sprite highlightedSprite,
                         Sprite pressedSprite,
                         Sprite selectedSprite,
                         Sprite disabledSprite,
                         bool isTabOrToggle)
    {
        NormalSprite = normalSprite;
        HighlightedSprite = highlightedSprite;
        PressedSprite = pressedSprite;
        SelectedSprite = selectedSprite;
        DisabledSprite = disabledSprite;
        IsTabOrToggle = isTabOrToggle;

        // ensure Sprites
        if (NormalSprite == default) {
            NormalSprite = ButtonImage.sprite;
        }

        if (HighlightedSprite == default) {
            HighlightedSprite = NormalSprite;
        }

        if (PressedSprite == default) {
            PressedSprite = (SelectedSprite == default) ? HighlightedSprite : SelectedSprite;
        }

        if (SelectedSprite == default) {
            SelectedSprite = PressedSprite;
        }
    }

    void OnDisable()
    {
        Pressed = false;
        PointerInside = false;
        UpdateButton();
    }

    public virtual void OnPointerUp(PointerEventData pointerEventData)
    {
        Pressed = false;
        if (!Enabled || IsTabOrToggle) {
            // IsTabOrToggle omits showing Normal state after clicking,
            //  which is useful with tab menus or button toggles,
            //  otherwise you see a Normal state flicker.
            return;
        }

        UpdateButton();
    }

    public virtual void OnPointerEnter(PointerEventData pointerEventData)
    {
        PointerInside = true;
        if (!Enabled) { return; }

        if (rollSound != null) {
            rollSound.Play();
        }

        UpdateButton();
    }

    public virtual void OnPointerExit(PointerEventData pointerEventData)
    {
        PointerInside = false;
        if (!Enabled) { return; }

        UpdateButton();
    }

    public virtual void OnPointerDown(PointerEventData pointerEventData = null)
    {
        Pressed = true;
        if (!Enabled) { return; }

        UpdateButton();
    }

    public virtual void OnPointerClick(PointerEventData pointerEventData)
    {
        if (!Enabled) { return; }

        SoundHelper.SoundCallback(clickSound, delegate () {
            onClick?.Invoke(this);
        }, false);
    }

    public virtual void UpdateButton(bool showAsPressed = false)
    {
        if (!ButtonImage) {
            return;     // too early, button hasn't called Start() yet.
        }

        if (Selected) {
            //
            // selected override
            ButtonImage.sprite = SelectedSprite;

        } else if (!Enabled) {
            //
            // button is disabled
            ButtonImage.sprite = DisabledSprite;

        } else if (showAsPressed) {
            //
            // showAsPressed override
            ButtonImage.sprite = PressedSprite;

        } else if (PointerInside) {
            //
            // if pointer inside, buttons are pressed or highlighted
            if (Pressed) {
                ButtonImage.sprite = PressedSprite;
            } else {
                ButtonImage.sprite = HighlightedSprite;
            }

        } else {
            //
            // otherwise button is normal
            ButtonImage.sprite = NormalSprite;
        }

        OnUpdateButtonEvent?.Invoke(showAsPressed);
    }

    //
    // Click for pressDuration seconds
    //
    public void Click(float pressDuration = 0.33f)
    {
        // button must be active and enabled to click
        if (! (isActiveAndEnabled && Enabled)) {
            return;
        }

        // show button as pressed
        UpdateButton(true);
        clickSound?.Play();

        Delayer.Delay(pressDuration, delegate ()
        {
            // invoke and unpress button
            onClick?.Invoke(this);
            UpdateButton();
        });
    }
}
