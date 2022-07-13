//
//  IconButton - Button package
//  Russell Lowke, July 11th 2021
//
//  Copyright (c) 2021 Lowke Media
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
using UnityEngine.UI;

[RequireComponent(typeof(Image))]
public class IconButton : MonoBehaviour
{
	public IconButtonStyle style;

	private Image _image;                                       // image used for button
	private Sprite _startSprite;                                // sprite button image started with
	public Image Image {
		get {
			if (!_image) {
				_image = GetComponent<Image>();
				_startSprite = _image.sprite;
				Image.raycastTarget = false;
			}
			return _image;
		}
	}

	private ClickButton _clickButton;
	public ClickButton ClickButton {
		get {
			if (!_clickButton) { _clickButton = GetComponentInParent<ClickButton>(); }
			return _clickButton;
		}
	}

	public Sprite NormalIcon { get; private set; }				// up
	public Sprite HighlightedIcon { get; private set; }			// over
	public Sprite PressedIcon { get; private set; }				// down
	public Sprite SelectedIcon { get; private set; }			// selected    
	public Sprite DisabledIcon { get; private set; }            // disabled

	public ClickButtonEvent onClickEvent {
		get { return ClickButton.onClickEvent; }
	}

	public bool Enabled {
		get { return ClickButton.Enabled; }
		set { ClickButton.Enabled = value; }
	}

	public bool Selected {
		get { return ClickButton.Selected; }
		set { ClickButton.Selected = value; }
	}

	private void Awake()
	{
		_startSprite = Image.sprite;
		ClickButton.OnUpdateEvent += UpdateButton;

		if (style) {
			SetStyle(style);
		}
	}

	public void SetStyle(IconButtonStyle style)
	{
		SetStyle(style.normalIcon,
				 style.highlightedIcon,
				 style.pressedIcon,
				 style.selectedIcon,
				 style.disabledIcon);
	}

	public void SetStyle(Sprite normalIcon,
						 Sprite highlightedIcon,
						 Sprite pressedIcon,
						 Sprite selectedIcon,
						 Sprite disabledIcon)
	{
		NormalIcon = normalIcon;
		HighlightedIcon = highlightedIcon;
		PressedIcon = pressedIcon;
		SelectedIcon = selectedIcon;
		DisabledIcon = disabledIcon;

		// ensure Sprites
		if (NormalIcon == default) {
			NormalIcon = _startSprite;
		}

		if (HighlightedIcon == default) {
			HighlightedIcon = NormalIcon;
		}

		if (PressedIcon == default) {
			PressedIcon = HighlightedIcon;
		}

		if (SelectedIcon == default) {
			SelectedIcon = PressedIcon;
		}
	}

	// Update is called once per frame
	private void UpdateButton()
	{
		if (ClickButton.Selected) {
			Image.sprite = SelectedIcon;
		} else if (!ClickButton.Enabled) {
			Image.sprite = DisabledIcon;
		} else if (ClickButton.Pressed) {
			Image.sprite = PressedIcon;
		} else if (ClickButton.PointerInside) {
			Image.sprite = HighlightedIcon;
		} else {
			Image.sprite = NormalIcon;
		}
	}
}
