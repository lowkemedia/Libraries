//
//  TextButton - Button package
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
using UnityEngine.UI;

public class TextButton : ClickButton
{
    public Text textField;
    public string normalTextColor = "";               // "up"
    public string highlightedTextColor = "";          // "over"
    public string pressedTextColor = "";              // "down"
    public string disabledTextColor = "";

    private Color _normalColor;
    private Color _highlightedColor;
    private Color _pressedColor;
    private Color _disabledColor;

    public override void Initialize()
    {
        base.Initialize();

        // ensure Text Color
        if (normalTextColor == "")
        {
            _normalColor = textField.color;
        }
        else
        {
            _normalColor = ConvertColor(normalTextColor);
        }

        if (highlightedTextColor == "")
        {
            _highlightedColor = _normalColor;
        }
        else
        {
            _highlightedColor = ConvertColor(highlightedTextColor);
        }

        if (pressedTextColor == "")
        {
            _pressedColor = _highlightedColor;
        }
        else
        {
            _pressedColor = ConvertColor(pressedTextColor);
        }

        if (disabledTextColor == "")
        {
            // TODO: Use alpha? or Grey?
            _disabledColor = _normalColor;
        }
        else
        {
            _disabledColor = ConvertColor(disabledTextColor);
        }
    }

    public override void UpdateButton(bool showAsClicked = false)
    {
        base.UpdateButton(showAsClicked);

        if (!_enabled)
        {
            // TODO: set alpha?
            textField.color = _disabledColor;
        }
        else if (_pressed && _inside || showAsClicked)
        {
            // TODO: Adjust text position (optional)
            textField.color = _pressedColor;
        }
        else if (_inside || _pressed)
        {
            textField.color = _highlightedColor;
        }
        else
        {
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
