//
//  ButtonFactory - Button package
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
using UnityEngine.Events;
using UnityEngine.UI;

public static class ButtonFactory
{
	public static ClickButton MakeClickButton(this GameObject parent,
											  ClickButton duplicate)
	{
		return parent.MakeButton(duplicate);
	}

	public static TextButton MakeTextButton(this GameObject parent,
											TextButton duplicate,
											string label = null)
	{
		TextButton textButton = parent.MakeButton(duplicate);
		if (!string.IsNullOrEmpty(label)) {
			textButton.textField.text = label;
			textButton.textField.name = label;
		}
		return textButton;
	}

	private static T MakeButton<T>(this GameObject parent, T duplicate) where T : ClickButton
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
		button.toggleSelected = duplicate.toggleSelected;
		button.invokeWhilePressed = duplicate.invokeWhilePressed;
		button.invokeInterval = duplicate.invokeInterval;
		button.clickInWhenPressed = duplicate.clickInWhenPressed;
		button.interactive = duplicate.interactive;
		button.onClick = new UnityEvent();
		button.onRollover = new UnityEvent();
		button.onRollout = new UnityEvent();

		// add Image for ClickButton
		Image image = buttonGameObject.AddComponent<Image>();
		image.sprite = button.normalSprite;
		image.gameObject.CopyRectTransform(duplicate.gameObject);

		if (duplicate is TextButton) {
			// cast as TextButton
			TextButton textButton = button as TextButton;
			TextButton duplicateTextButton = duplicate as TextButton;

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
			textGameObject.CopyRectTransform(duplicateTextButton.textField.gameObject);

		}

		return button;
	}
}
