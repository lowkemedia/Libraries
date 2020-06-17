//
//  TextButton - Button package
//  Russell Lowke, April 27th 2020
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
using UnityEngine.UI;

public class TextButton : ClickButton
{
    public Text textField;
    public string normalTextColor;               // "up"
    public string highlightedTextColor;          // "over"
    public string pressedTextColor;              // "down"
	public string selectedTextColor;
	public string disabledTextColor;

    private Color _normalColor;
    private Color _highlightedColor;
    private Color _pressedColor;
	private Color _selectedColor;
	private Color _disabledColor;

    public override void Initialize()
    {
        base.Initialize();

        // ensure Text Color
        if (string.IsNullOrEmpty(normalTextColor)) {
            _normalColor = textField.color;
        } else {
            _normalColor = ConvertColor(normalTextColor);
        }

        if (string.IsNullOrEmpty(highlightedTextColor)) {
            _highlightedColor = _normalColor;
        } else {
            _highlightedColor = ConvertColor(highlightedTextColor);
        }

        if (string.IsNullOrEmpty(pressedTextColor)) {
            _pressedColor = _highlightedColor;
        } else {
            _pressedColor = ConvertColor(pressedTextColor);
        }

		if (string.IsNullOrEmpty(selectedTextColor)) {
			_selectedColor = _pressedColor;
		} else {
			_selectedColor = ConvertColor(selectedTextColor);
		}

		if (string.IsNullOrEmpty(disabledTextColor)) {
            // TODO: Use alpha? or Grey?
            _disabledColor = _normalColor;
        } else {
            _disabledColor = ConvertColor(disabledTextColor);
        }
    }

    public override void UpdateButton(bool showAsPressed = false)
    {
        base.UpdateButton(showAsPressed);

        // TODO: deal with clickInWhenPressed

        if (Selected) {
            //
            // selected override
            textField.color = _selectedColor;

        } else if (!Enabled) {
			//
			// button is disabled
			textField.color = _disabledColor;

		} else if (showAsPressed) {
			//
			// showAsPressed override
			textField.color = _pressedColor;

		} else if (_inside) {
			//
			// if pointer inside, buttons are pressed or highlighted
			if (_pressed) {
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

    public Color ConvertColor(string colorString)
    {
        Color returnColor;
        ColorUtility.TryParseHtmlString(colorString, out returnColor);
        return returnColor;
    }
}
