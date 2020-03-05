//
//  ClickButton - Button package
//  Russell Lowke, March 4th 2020
//
//  Copyright (c) 2019-2020 Lowke Media
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

public class ClickButton : MonoBehaviour,
             IPointerDownHandler, IPointerUpHandler, IPointerEnterHandler, IPointerExitHandler
{
	public Sprite normalSprite;               // "up"
	public Sprite highlightedSprite;          // "over"
	public Sprite pressedSprite;              // "down"
	public Sprite selectedSprite;
	public Sprite disabledSprite;

	public AudioSource click;
    public AudioSource roll;

	public new bool enabled = true;
	public bool selected;
	public bool interactive = true;

	public bool invokeWhilePressed;
	private float _invokedTime;							// time of last invoke
	private float _pressTime;							// time of last press
	public float invokeInterval = 0.15f;                // interval between press invokes, in seconds

	public bool clickInWhenPressed;                     // TODO: Fix to be more subtle (or not at all)
	private Vector3 _position;
	private Vector3 _positionAdjusted;

	public UnityEvent onClick;                  // TODO: pass reference of ClickButton to callback
	public UnityEvent onRollover;
	public UnityEvent onRollout;

	// flags maintained keeping track if button is pressed and if pointer inside
	protected bool _pressed;
	protected bool _inside;
	protected Image _buttonImage;	// image currently shown for button


	public bool Enabled {
		get { return enabled; }
		set {
			enabled = value;
			Interactive = enabled;
		}
	}

	public bool Selected {
		get { return selected; }
		set {
			selected = value;
			UpdateButton();
		}
	}

	public bool Interactive {
		get { return interactive; }
		set {
			// TODO: Give warning if Interactive set to true while button is !Enabled
			interactive = Enabled ? value : false;
			UpdateButton();
		}
	}

	void Start()
    {
        UpdateButton();
        // TODO: check if pointer started inside button
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
        if (!normalSprite) {
			normalSprite = _buttonImage.sprite;
        }

        if (!highlightedSprite) {
			highlightedSprite = normalSprite;
        }

        if (!pressedSprite) {
			pressedSprite = highlightedSprite;
        }

		if (!selectedSprite) {
			selectedSprite = pressedSprite;
		}

        _position = transform.position;
        _positionAdjusted = transform.position;
        _positionAdjusted.x += 0.5f;
        _positionAdjusted.y -= 0.5f;
    }

    public void OnPointerUp(PointerEventData clickEventData)
    {
		if (!Interactive) {
			_pressed = false;
			return;
		}

		// special case for invokeWhilePressed
		if (_pressed && _inside) {
            if (!invokeWhilePressed ||
                (Time.time - _pressTime < invokeInterval)) {
                Click();
            }
        }
		_pressed = false;

		UpdateButton();
    }

    public void OnPointerEnter(PointerEventData clickEventData)
    {
		_inside = true;
		if (!Interactive) { return; }

        if (roll != null) {
            roll.Play();
        }

        if (onRollover != null) {
            onRollover.Invoke();
        }
        UpdateButton();
    }

    public void OnPointerExit(PointerEventData clickEventData)
    {
		_inside = false;
		if (!Interactive) { return; }

        if (onRollout != null) {
            onRollout.Invoke();
        }
        UpdateButton();
    }

    public void OnPointerDown(PointerEventData clickEventData = null)
    {
		_pressed = true;
		if (!Interactive) { return; }

        _pressTime = Time.time;
        UpdateButton();
    }

    public virtual void UpdateButton(bool showAsClicked = false)
    {
        if (!_buttonImage) {
            Initialize();
        }

		/* TODO: deal with clickInWhenPressed
		if (clickInWhenPressed) {
            transform.position = (_enabled && _pressed && _inside) ? _positionAdjusted : _position;
        }
		*/

		if (!Enabled) {
			//
			// button is disabled
			_buttonImage.sprite = disabledSprite;

		} else if (showAsClicked) {
			//
			// showAsClicked override
			_buttonImage.sprite = pressedSprite;

		} else if (Selected) {
			//
			// selected override
			_buttonImage.sprite = selectedSprite;

		} else if (_inside && Interactive) {
			//
			// if pointer inside, buttons are pressed or highlighted
			if (_pressed) {
				_buttonImage.sprite = pressedSprite;
			} else {
				_buttonImage.sprite = highlightedSprite;
			}

		} else {
			//
			// otherwise button is normal
			_buttonImage.sprite = normalSprite;
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
        if (isActiveAndEnabled && Enabled)
        {
            _invokedTime = Time.time;
            if (click != null) {
                click.Play();
            }

            if (!_pressed &&
				pressedSprite != normalSprite &&
                pressDuration > 0)
            {
                UpdateButton(true);
                Animator.Instance.AddEffect(new DelayFX(pressDuration), FinishClick);
            } else {
                FinishClick();
            }
            
            return true;
        }

        return false;
    }

    private void FinishClick()
    {
        if (onClick != null) {
            onClick.Invoke();
        }
    }
}
