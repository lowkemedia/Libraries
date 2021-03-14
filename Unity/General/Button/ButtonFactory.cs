//
//  ButtonFactory - Button package
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
using TMPro;

public static class ButtonFactory
{
    public static ClickButton MakeClickButton(this GameObject parent,
                                              ClickButton template)
    {
        ClickButton clickButton = parent.MakeUiComponent(template, "Button");
        // TODO: Check this. CopyComponent() in MakeUiComponent() should copy these?
        clickButton.useDefaultSound = template.useDefaultSound;
        clickButton.clickSound = template.clickSound;
        clickButton.rollSound = template.rollSound;
        clickButton.waitForClickSound = template.waitForClickSound;
        // clickButton.SetStyle(template.style);

        clickButton.onClickEvent = new ClickButtonEvent();

        return clickButton;
    }

	public static TextButton MakeTextButton(this GameObject parent,
                                            TextButton template,
											string label)
	{
        // create ClickButton
        ClickButton clickButton = parent.MakeClickButton(template.ClickButton);
        GameObject gameObject = clickButton.gameObject;

        // create text label
        TextMeshProUGUI textField = gameObject.MakeTextMesh(template.textField, label);
        textField.text = label;

        // create TextButton
        TextButton textButton = gameObject.AddComponent<TextButton>();
        textButton.textField = textField;
        textButton.SetStyle(template.ClickButton.style);

        return textButton;
    }
}
