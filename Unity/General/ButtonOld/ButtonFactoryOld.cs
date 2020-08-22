//
//  ButtonFactory - Button package
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
using UnityEngine.Events;
using UnityEngine.UI;

public static class ButtonFactoryOld
{
	public static ClickButtonOld MakeClickButton(this GameObject parent,
											  ClickButtonOld duplicate)
	{
		return parent.MakeButton(duplicate);
	}

	public static TextButtonOld MakeTextButton(this GameObject parent,
											TextButtonOld duplicate,
											string label = null)
	{
		TextButtonOld textButton = parent.MakeButton(duplicate);
		if (!string.IsNullOrEmpty(label)) {
			textButton.textField.text = label;
			textButton.textField.name = label;
		}
		return textButton;
	}

	private static T MakeButton<T>(this GameObject parent, T duplicate) where T : ClickButtonOld
	{
		// create gameObject holder for button
		GameObject buttonGameObject = parent.MakeGameObject("Button");

		// create button
		T button = buttonGameObject.AddComponent<T>();

		// copy ClickButton properties
		button.normalSprite = duplicate.normalSprite;
		button.highlightedSprite = duplicate.highlightedSprite;
		button.pressedSprite = duplicate.pressedSprite;
		button.selectedSprite = duplicate.selectedSprite;
		button.disabledSprite = duplicate.disabledSprite;
		button.click = duplicate.click;
		button.roll = duplicate.roll;
		button.enabled = duplicate.enabled;
		button.selected = duplicate.selected;
		button.invokeWhilePressed = duplicate.invokeWhilePressed;
		button.invokeInterval = duplicate.invokeInterval;
		button.clickInWhenPressed = duplicate.clickInWhenPressed;
		button.onClick = new UnityEvent();
		button.onRollover = new UnityEvent();
		button.onRollout = new UnityEvent();

		// add Image for ClickButton
		Image image = buttonGameObject.AddComponent<Image>();
		image.sprite = button.normalSprite;
		CopyRectTransform(image.gameObject, duplicate.gameObject);

		if (duplicate is TextButtonOld) {
			// cast as TextButton
			TextButtonOld textButton = button as TextButtonOld;
			TextButtonOld duplicateTextButton = duplicate as TextButtonOld;

			// add Text for TextButton
			GameObject textGameObject = buttonGameObject.MakeGameObject();
			Text textField = textGameObject.AddComponent<Text>();
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