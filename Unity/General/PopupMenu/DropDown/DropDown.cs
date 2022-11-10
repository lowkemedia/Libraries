//
//  DropDown - PopupMenu package
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

using UnityEngine;
using UnityEngine.UI;
using PopupMenuTypes;

public class DropDown : Popup
{
    protected override void UpdatePopupPosition()
    {
		// drop down menu always drops down
		float yPos = -(_menuItems.Length) * (popupTextButton.GetHeight() + padding) - padding / 2;
		_gameObjectMenu.SetY(yPos);
	}

	protected override void ShowPopup()
	{
		// move popup to top of display list
		gameObject.MoveToTop();

		// TODO: Shouldn't need to reinitialize! just fix popup position, AinsideB() call.
		Initialize(_menuItems, Selected);

		// show popup
		_popupGameObject.SetActive(true);

		// move popup to top and highlight
		popupTextButton.gameObject.MoveToTop();
		popupTextButton.Selected = true;
	}

	protected override void HidePopup()
	{
		popupTextButton.Selected = false;
		_popupGameObject.SetActive(false);
	}

	protected override GameObject MakePopupGameObject(TextButton templateButton,
										   string selected = null)
	{
		// create popup menu
		GameObject popupGameObject = gameObject.MakeUiObject("DropDown");

		// create blocker
		ClickBlocker clickBlocker = ClickBlocker.MakeClickBlocker(popupGameObject);

		// create menu
		_gameObjectMenu = popupGameObject.MakeUiObject("Menu");

		// create background
		GameObject gameObjectBackground = _gameObjectMenu.MakeUiObject("Background");
		Image backgroundImage = gameObjectBackground.AddComponent<Image>();
		backgroundImage.sprite = popupBgSprite;
		float btnWidth = popupTextButton.GetWidth() + padding * 2;
		float btnHeight = popupTextButton.GetHeight() + padding * 2;
		float bgHeight = (btnHeight - padding) * (_menuItems.Length + 1) + padding * 1.5f;
		backgroundImage.SetSize(btnWidth, bgHeight);
		backgroundImage.SetY(backgroundImage.GetHeight() / 2 - btnHeight / 2);

		// set selected, this will move the background
		Selected = selected;

		// create selection buttons
		float yLoc = 0;
		for (int i = 0; i < _menuItems.Length; ++i) {
			int index = _menuItems.Length - i - 1;
			string menuItem = _menuItems[index];
			TextButton textButton = MakeTextButton(templateButton, menuItem);
			ClickButton clickButton = textButton.ClickButton;
			clickButton.SetY(yLoc);
			clickButton.onClickEvent.AddListener(delegate { MenuButtonClicked(new PopupMenuEventArgs(this, menuItem, index)); });
			clickButton.OnRolloverEvent += delegate { MenuButtonRolled(menuItem, index); };
			yLoc += clickButton.GetHeight() + padding;
		}

		return popupGameObject;
	}
}