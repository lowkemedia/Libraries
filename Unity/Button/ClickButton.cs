//
//  ClickButton - Button package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2019 Lowke Media
//  see http://www.lowkemedia.com for more information
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
using System;

public class ClickButton : MonoBehaviour,
             IPointerDownHandler, IPointerUpHandler, IPointerEnterHandler, IPointerExitHandler
{
    public Sprite normal;               // "up"
    public Sprite highlighted;          // "over"
    public Sprite pressed;              // "down"
    public Sprite disabled;
    public UnityEvent onClick;
    public UnityEvent onRollover;
    public UnityEvent onRollout;

    public AudioSource click;
    public AudioSource roll;

    protected Image _buttonImage = null;
    protected bool _enabled = true;
    protected bool _pressed = false;
    protected bool _inside = false;

    public bool invokeWhilePressed = false;
    private float _invokedTime = 0f;                    // time of last invoke
    private float _pressTime = 0f;                      // time of last press
    public float invokeInterval = 0.15f;                // interval between press invokes, in seconds

    public bool clickInWhenPressed = false;             // TODO: Fix to be more subtle (or not at all)
    private Vector3 _position;
    private Vector3 _positionAdjusted;

    void Start()
    {
        UpdateButton();
        // TODO: check if pointer started inside
    }

    void OnDisable()
    {
        _pressed = false;
        _inside = false;
        UpdateButton();
    }

    public virtual void Initialize()
    {
        _buttonImage = GetComponent<Image>();

        // ensure Sprites
        if (!normal)
        {
            normal = _buttonImage.sprite;
        }

        if (!highlighted)
        {
            highlighted = normal;
        }

        if (!pressed)
        {
            pressed = highlighted;
        }

        _position = this.transform.position;
        _positionAdjusted = this.transform.position;
        _positionAdjusted.x += 0.5f;
        _positionAdjusted.y -= 0.5f;
    }

    public void OnPointerUp(PointerEventData clickEventData)
    {
        if (_pressed && _inside)
        {
            if (!invokeWhilePressed ||
                (Time.time - _pressTime < invokeInterval))
            {
                Click();
            }
        }
        _pressed = false;
        UpdateButton();
    }

    public void OnPointerEnter(PointerEventData clickEventData)
    {
        _inside = true;
        if (Enabled)
        {
            if (roll != null)
            {
                roll.Play();
            }

            if (onRollover != null)
            {
                onRollover.Invoke();
            }
        }
        UpdateButton();
    }

    public void OnPointerExit(PointerEventData clickEventData)
    {
        _inside = false;
        if (Enabled)
        {
            if (onRollout != null)
            {
                onRollout.Invoke();
            }
        }
        UpdateButton();
    }

    public void OnPointerDown(PointerEventData clickEventData = null)
    {
        _pressed = true;
        _pressTime = Time.time;
        UpdateButton();
    }

    public virtual void UpdateButton(bool showAsClicked = false)
    {
        if (!_buttonImage)
        {
            Initialize();
        }

        if (clickInWhenPressed)
        {
            transform.position = (_enabled && _pressed && _inside) ? _positionAdjusted : _position;
        }

        if (!_enabled)
        {
            // TODO: if (!disabled) then set alpha
            _buttonImage.sprite = disabled;
        }
        else if (_pressed && _inside || showAsClicked)
        {
            _buttonImage.sprite = pressed;
        }
        else if (_inside || _pressed)
        {
            _buttonImage.sprite = highlighted;
        }
        else
        {
            _buttonImage.sprite = normal;
        }
    }

    // Update is called once per frame
    private void Update()
    {
        float timeNow = Time.time;
        if (invokeWhilePressed &&
            _pressed && _inside && 
            (timeNow - _pressTime >= invokeInterval) && 
            (timeNow - _invokedTime >= invokeInterval))
        {
            Click();
        }
    }

    //
    // Click for pressDuration in seconds
    //
    public bool Click(float pressDuration = 0.33f)
    {
        if (isActiveAndEnabled && _enabled)
        {
            _invokedTime = Time.time;
            if (click != null)
            {
                click.Play();
            }

            if (!_pressed &&
                pressed != normal &&
                pressDuration > 0)
            {
                UpdateButton(true);
                Animator.Instance.AddEffect(new DelayFX(pressDuration), FinishClick);
            }
            else
            {
                FinishClick();
            }
            
            return true;
        }

        return false;
    }

    private void FinishClick()
    {
        if (onClick != null)
        {
            onClick.Invoke();
        }
    }

    public bool Enabled
    {
        get {
            return _enabled;
        }

        set {
            _enabled = value;
            UpdateButton();
        }
    }

    // TODO: public bool Selected
}
