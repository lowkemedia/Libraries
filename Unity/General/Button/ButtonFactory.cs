//
//  ButtonFactory - Button package
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
using UnityEngine.Events;
using UnityEngine.UI;
using TMPro;

public static class ButtonFactory
{
    public static ClickButton MakeClickButton(this GameObject parent,
                                              ClickButton duplicate)
    {
        return parent.MakeButton(duplicate);
    }

    /*
	 * 
	public static TextButtonKill MakeTextButton(this GameObject parent,
											TextButtonKill duplicate,
											string label = null)
	{
		TextButtonKill textButton = parent.MakeButton(duplicate);
		if (!string.IsNullOrEmpty(label)) {
			textButton.textField.text = label;
			textButton.textField.name = label;
		}
		return textButton;
	}
	*/

    private static T MakeButton<T>(this GameObject parent, T duplicate) where T : ClickButton
    {
        // create gameObject holder for button
        GameObject buttonGameObject = parent.MakeGameObject("Button");

        // create button
        T button = buttonGameObject.AddComponent<T>();

        // copy ClickButton properties
        button.SetStyle(duplicate.NormalSprite,
                        duplicate.HighlightedSprite,
                        duplicate.PressedSprite,
                        duplicate.SelectedSprite,
                        duplicate.DisabledSprite,
                        duplicate.IsTabOrToggle);
        button.clickSound = duplicate.clickSound;
        button.rollSound = duplicate.rollSound;
        button.enabled = duplicate.enabled;
        button.selected = duplicate.selected;
        button.onClick = new ClickButtonEvent();

        // add Image for ClickButton
        Image image = buttonGameObject.AddComponent<Image>();
        image.sprite = button.NormalSprite;
        CopyRectTransform(image.gameObject, duplicate.gameObject);

        /*
		 * 
		if (duplicate is TextButtonKill) {
			// cast as TextButton
			TextButtonKill textButton = button as TextButtonKill;
			TextButtonKill duplicateTextButton = duplicate as TextButtonKill;

			// add Text for TextButton
			GameObject textGameObject = buttonGameObject.MakeGameObject();
			TextMeshProUGUI textField = textGameObject.AddComponent<TextMeshProUGUI>();
			textField.CopyComponent(duplicateTextButton.textField);
			textField.name = "Text";
			textButton.textField = textField;

			// copy TextButton properties
			textButton.normalTextColor = duplicateTextButton.normalTextColor;
			textButton.highlightedTextColor = duplicateTextButton.highlightedTextColor;
			textButton.pressedTextColor = duplicateTextButton.pressedTextColor;
			textButton.selectedTextColor = duplicateTextButton.selectedTextColor;
			textButton.disabledTextColor = duplicateTextButton.disabledTextColor;

			// copy RectTransform
			CopyRectTransform(textGameObject, duplicateTextButton.textField.gameObject);

		}
		*/

        return button;
    }

    //
    // Copy parts of RectTransform we want
    //
    public static void CopyRectTransform(GameObject target, GameObject duplicate)
    {
        // TODO: use Utils.CopyComponent() on RectTransform?
        //  try target.rectTransform.CopyComponent(duplicate.rectTransform);
        RectTransform rectTransform = target.GetComponent<RectTransform>();
        RectTransform duplicateRectTransform = duplicate.GetComponent<RectTransform>();
        rectTransform.localPosition = duplicateRectTransform.localPosition;
        rectTransform.localScale = duplicateRectTransform.localScale;
        rectTransform.localRotation = duplicateRectTransform.localRotation;
        rectTransform.sizeDelta = duplicateRectTransform.sizeDelta;
    }
}
