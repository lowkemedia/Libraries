//
//  LocalizedDropDown - PopupMenu package
//  Russell Lowke, March 11th 2021
//
//  Copyright (c) 2019-2021 Lowke Media
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

using UnityEngine.Events;
using PopupMenuTypes;

public class LocalizedDropDown : DropDown
{
	private string _style;
	private string[] _variables;
	private bool _giveWarning;

	public void Initialize(string[] menuKeys,
						   string selectedKey = default,
					       UnityAction<PopupMenuEventArgs> unityCallback = default,
						   string style = default, string[] variables = default, bool giveWarning = true)
	{
		_style = style;
		_variables = variables;
		_giveWarning = giveWarning;
		base.Initialize(menuKeys, selectedKey, unityCallback);
	}

	protected override string SelectedText {
		set { popupTextButton.textField.AddKey(value, _variables, _style, _giveWarning); }
	}

	public void LabelKey(string key,
						 string[] variables = default,
						 string style = default,
						 bool giveWarning = true)
	{
		popupLabel.AddKey(key, variables, style, giveWarning);
	}

	protected override TextButton MakeTextButton(TextButton templateButton, string menuItemKey)
	{
		TextButton textButton = _gameObjectMenu.MakeTextButton(templateButton, menuItemKey);
		textButton.textField.AddKey(menuItemKey, _variables, _style, _giveWarning);
		return textButton;
	}
}