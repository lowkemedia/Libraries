﻿//
//  TextButton - Button package
//  Russell Lowke, July 24th 2020
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

using TMPro;
using UnityEngine;

[RequireComponent(typeof(ClickButton))]
public class TextButton : MonoBehaviour
{
	public TextMeshProUGUI textField;
	public TextButtonStyle textStyle;       // if empty, textStyle is taken from ClickButton.style.textStyle

	public string NormalColor { get; private set; }			// up          #FFFFFF7F is white with 50% alpha
	public string HighlightedColor { get; private set; }	// over
	public string PressedColor { get; private set; }		// down
	public string SelectedColor { get; private set; }		// selected 
	public string DisabledColor { get; private set; }		// disabled

	public ClickButtonEvent onClickEvent {
		get { return ClickButton.onClickEvent; }
	}

	private ClickButton _clickButton;
	public ClickButton ClickButton {
		get {
			if (!_clickButton) { _clickButton = GetComponent<ClickButton>(); }
			return _clickButton;
		}
	}

	private Color _normalColor;
	private Color _highlightedColor;
	private Color _pressedColor;
	private Color _selectedColor;
	private Color _disabledColor;

	public bool Enabled {
		get { return ClickButton.Enabled; }
		set { ClickButton.Enabled = value; }
	}

	public bool Interactable {
		get { return ClickButton.Interactable; }
		set { ClickButton.Interactable = value; }
	}

	public bool Selected {
		get { return ClickButton.Selected; }
		set { ClickButton.Selected = value; }
	}

	private void Awake()
	{
		ClickButton.OnUpdateEvent += UpdateButton;

		if (textStyle == default) {
			ClickButtonStyle clickButtonStyle = ClickButton.style;
			if (clickButtonStyle != default) {
				textStyle = clickButtonStyle.textButtonStyle;
			}
		}
		
		SetStyle(textStyle);
	}

	public void SetStyle(TextButtonStyle style)
	{
		if (style != default) {
			SetStyle(style.normalColor,
				style.highlightedColor,
				style.pressedColor,
				style.selectedColor,
				style.disabledColor);
		}
	}

	public void SetStyle(string normalColor,
						 string highlightedColor,
						 string pressedColor,
						 string selectedColor,
						 string disabledColor)
	{
		NormalColor = normalColor;
		HighlightedColor = highlightedColor;
		PressedColor = pressedColor;
		SelectedColor = selectedColor;
		DisabledColor = disabledColor;

		// ensure Text Color
		if (string.IsNullOrEmpty(NormalColor)) {
			_normalColor = textField.color;
		} else {
			_normalColor = UtilsColor.ConvertColor(NormalColor);
		}

		if (string.IsNullOrEmpty(HighlightedColor)) {
			_highlightedColor = _normalColor;
		} else {
			_highlightedColor = UtilsColor.ConvertColor(HighlightedColor);
		}

		if (string.IsNullOrEmpty(PressedColor)) {
			_pressedColor = _highlightedColor;
		} else {
			_pressedColor = UtilsColor.ConvertColor(PressedColor);
		}

		if (string.IsNullOrEmpty(SelectedColor)) {
			_selectedColor = _pressedColor;
		} else {
			_selectedColor = UtilsColor.ConvertColor(SelectedColor);
		}

		if (string.IsNullOrEmpty(DisabledColor)) {
			// TODO: Use alpha? or Grey?
			_disabledColor = _normalColor;
		} else {
			_disabledColor = UtilsColor.ConvertColor(DisabledColor);
		}

		textField.raycastTarget = false;
	}

	// Update is called once per frame
	private void UpdateButton()
	{
		if (ClickButton.Selected) {
			textField.color = _selectedColor;
		} else if (!ClickButton.Enabled) {
			textField.color = _disabledColor;
			if (textField.outlineColor != Color.black) {
				textField.outlineColor = Color.black;       // TODO: Deal with outlineColor
			}
		} else if (ClickButton.Pressed) {
			textField.color = _pressedColor;
		} else if (ClickButton.PointerInside) {
			textField.color = _highlightedColor;
		} else {
			textField.color = _normalColor;
		}
	}
}
