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
             IPointerDownHandler, IPointerUpHandler, IPointerEnterHandler, IPointerExitHandler
{
    public ClickButtonStyle style;
    public new bool enabled = true;
    public bool selected;

    // TODO: Move invokeWhilePressed into an extending class
    public bool invokeWhilePressed;
    private float _invokedTime;                         // time of last invoke
    private float _pressTime;                           // time of last press
    public float invokeInterval = 0.15f;                // interval between press invokes, in seconds

    public bool clickInWhenPressed;                     // TODO: Fix to be more subtle (or remove)
    private Vector3 _position;  
    private Vector3 _positionAdjusted;

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
    public bool Pressed             { get; private set; }
    public bool PointerInside       { get; private set; }

    public delegate void UpdateButtonEvent(bool showAsPressed);
    public event UpdateButtonEvent OnUpdateButtonEvent;

    public bool Enabled {
        get { return enabled; }
        set {
            enabled = value;
            UpdateButton();
        }
    }

    // TODO: Include Interactable flag?
    // TODO: Add a "toggle selected" option for use with check boxes and radio buttons

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

        _position = transform.position;
        _positionAdjusted = transform.position;
        _positionAdjusted.x += 0.5f;
        _positionAdjusted.y -= 0.5f;

        // TODO: check if pointer started inside button

        UpdateButton();
    }

    public void SetStyle(ClickButtonStyle style)
    {
        SetStyle(style.normalSprite,
                 style.highlightedSprite,
                 style.pressedSprite,
                 style.selectedSprite,
                 style.disabledSprite);
    }

    public void SetStyle(Sprite normalSprite,
                         Sprite highlightedSprite,
                         Sprite pressedSprite,
                         Sprite selectedSprite,
                         Sprite disabledSprite)
    {
        NormalSprite = normalSprite;
        HighlightedSprite = highlightedSprite;
        PressedSprite = pressedSprite;
        SelectedSprite = selectedSprite;
        DisabledSprite = disabledSprite;

        // ensure Sprites
        if (NormalSprite == default) {
            NormalSprite = ButtonImage.sprite;
        }

        if (HighlightedSprite == default) {
            HighlightedSprite = NormalSprite;
        }

        if (PressedSprite == default) {
            PressedSprite = (!SelectedSprite) ? HighlightedSprite : SelectedSprite;
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

    public virtual void OnPointerUp(PointerEventData clickEventData)
    {
        if (!Enabled) {
            Pressed = false;
            return;
        }

        // TODO: Move invokeWhilePressed into an extending class
        //  special case issues due to invokeWhilePressed
        if (Pressed && PointerInside) {
            if (!invokeWhilePressed ||
                (Time.time - _pressTime < invokeInterval)) {
                Click();
            }
        }
        Pressed = false;

        UpdateButton();
    }

    public virtual void OnPointerEnter(PointerEventData clickEventData)
    {
        PointerInside = true;
        if (!Enabled) { return; }

        if (rollSound != null) {
            rollSound.Play();
        }

        UpdateButton();
    }

    public virtual void OnPointerExit(PointerEventData clickEventData)
    {
        PointerInside = false;
        if (!Enabled) { return; }

        UpdateButton();
    }

    public virtual void OnPointerDown(PointerEventData clickEventData = null)
    {
        Pressed = true;
        if (!Enabled) { return; }

        _pressTime = Time.time;
        UpdateButton();
    }

    public virtual void UpdateButton(bool showAsPressed = false)
    {
        if (!ButtonImage) {
            return;     // too early, button hasn't started yet.
        }

        /* TODO: deal with clickInWhenPressed
		if (clickInWhenPressed) {
            transform.position = (_enabled && _pressed && _inside) ? _positionAdjusted : _position;
        }
		*/

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

    // Update is called once per frame
    private void Update()
    {
        float timeNow = Time.time;
        if (invokeWhilePressed &&
            Pressed && PointerInside &&
            (timeNow - _pressTime >= invokeInterval) &&
            (timeNow - _invokedTime >= invokeInterval)) {
            Click();
        }
    }

    //
    // Click for pressDuration in seconds
    //
    public bool Click(float pressDuration = 0.33f)
    {
        if (isActiveAndEnabled && Enabled) {
            _invokedTime = Time.time;

            if (!Pressed &&
                PressedSprite != NormalSprite &&
                pressDuration > 0) {
                UpdateButton(true);
                Delayer.Delay(pressDuration, DoClick);
            } else {
                DoClick();
            }
            return true;
        }
        return false;
    }

    private void DoClick()
    {
        // shouldn't wait for click sound to finish
        //  when invokeWhilePressed is used
        if (invokeWhilePressed) {
            clickSound.Play();
            onClick?.Invoke(this);
            return;
        }

        // TODO: onClick option not to wait for sound to end before triggering callback
        SoundHelper.SoundCallback(clickSound, delegate () {
            onClick?.Invoke(this);
        }, false);
    }
}
