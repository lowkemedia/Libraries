﻿//
//  TextButton - Button package
//  Russell Lowke, July 12th 2020
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
    public string NormalColor       { get; private set; }   // up,         #FFFFFF7F is white with 50% alpha
    public string HighlightedColor  { get; private set; }   // over
    public string PressedColor      { get; private set; }   // down
    public string SelectedColor     { get; private set; }   // selected    
    public string DisabledColor     { get; private set; }   // disabled

    private ClickButton _clickButton;
    private Color _normalColor;
    private Color _highlightedColor;
    private Color _pressedColor;
    private Color _selectedColor;
    private Color _disabledColor;

    // Start is called before the first frame update
    private void Start()
    {
        _clickButton = GetComponent<ClickButton>();
        _clickButton.OnUpdateButtonEvent += UpdateButton;

        if (_clickButton.style) {
            SetStyle(_clickButton.style);
        }
    }

    public void SetStyle(ClickButtonStyle style)
    {
        SetStyle(style.normalColor,
                 style.highlightedColor,
                 style.pressedColor,
                 style.selectedColor,
                 style.disabledColor);
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
            if (string.IsNullOrEmpty(SelectedColor)) {              // TODO: Messy, clean up
                _pressedColor = _highlightedColor;
            } else {
                _pressedColor = UtilsColor.ConvertColor(SelectedColor);
            }
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
    }

    // Update is called once per frame
    private void UpdateButton(bool showAsPressed)
    {
        // TODO: deal with clickInWhenPressed

        if (_clickButton.Selected) {
            //
            // selected override
            textField.color = _selectedColor;

        } else if (!_clickButton.Enabled) {
            //
            // button is disabled
            textField.color = _disabledColor;

        } else if (showAsPressed) {
            //
            // showAsClicked override
            textField.color = _pressedColor;

        } else if (_clickButton.PointerInside) {
            //
            // if pointer inside, buttons are pressed or highlighted
            if (_clickButton.Pressed) {
                textField.color = _pressedColor;
            } else {
                textField.color = _highlightedColor;
            }

        } else {
            //
            // otherwise button is normal
            textField.color = _normalColor;
        }
    }
}
