﻿//
//  Popup - PopupMenu package
//  Russell Lowke, August 21st 2021
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

using System;
using UnityEngine;
using UnityEngine.Events;
using TMPro;
using UnityEngine.UI;
using PopupMenuTypes;
using CallbackTypes;
using UnityEngine.EventSystems;

public class Popup : MonoBehaviour
{
	// TODO: device version needs to behave differenetly from desktop
	public delegate void PopupMenuCallback(string menuItem, int index);

	public Sprite popupBgSprite;
	public TextMeshProUGUI popupLabel;
	public TextButton popupTextButton;
	public PopupMenuEvent onMenuSelectedEvent;

	public event PopupMenuCallback OnMenuRollEvent;
	public event Callback OnPopupRolloutEvent;

	public float padding = 30;                      // padding around buttons

	protected GameObject _popupGameObject;
	protected GameObject _gameObjectMenu;
	protected int _selectedIndex;
	protected string[] _menuItems;
	protected ClickButton[] _menuButtons;

	public string LabelText {
		get { return popupLabel.text; }
		set { popupLabel.text = value; }
	}

	public string Selected {
		get { return _menuItems[_selectedIndex]; }
		set {
			int index = 0;
			if (!string.IsNullOrEmpty(value)) {
				index = Array.IndexOf(_menuItems, value);
			}
			if (index == -1) {
				Logger.Warning("Could not set Selected to \"" + value + "\" as it is not a menu item.");
				return;
			}
			SelectedIndex = index;
		}
	}

	public int SelectedIndex {
		get { return _selectedIndex; }

		set {
			PreviousIndex = _selectedIndex;
            _selectedIndex = value;

			if (_selectedIndex < 0 ||
				_selectedIndex > _menuItems.Length - 1) {
				_selectedIndex = 0;
			}

			// show correct menuItem on button
			SelectedText = Selected;

			UpdatePopupPosition();
		}
	}

	// useful for reverting to previous popup menu selection.
	public int PreviousIndex { get; private set; } = -1;

	public void Select(string value, bool giveWarning = true)
	{
		for (int i = 0; i < _menuItems.Length; ++i) {
			string menuItem = _menuItems[i];
			if (value == menuItem) {
				ClickButton clickButton = _menuButtons[i];
				ClickButtonEvent onClickEvent = clickButton.onClickEvent;
				onClickEvent?.Invoke(clickButton);
				return;
			}
		}
		if (giveWarning) {
			Logger.Warning("Could not select button \"" + value + "\" on popup.");
		}
	}

	protected virtual void UpdatePopupPosition()
    {
		// move popup according to location of selected item
		float yPos = -_selectedIndex * (popupTextButton.GetHeight() + padding);
		_gameObjectMenu.SetY(yPos);
	}

	protected virtual string SelectedText {
		set { popupTextButton.textField.text = value; }
	}

	public virtual void Start()
	{
		popupTextButton.onClickEvent.AddListener(OnClickButton);
	}

	public void Initialize(string[] menuItems,
						   string selected = default,
						   UnityAction<PopupMenuEventArgs> unityCallback = default)
	{
		_menuItems = (string[])menuItems.Clone();
		popupTextButton.Enabled = true;

		if (_popupGameObject != null) {
			Destroy(_popupGameObject);
		}
		_popupGameObject = MakePopupGameObject(popupTextButton, selected);
		if (unityCallback != null) {
			onMenuSelectedEvent.RemoveAllListeners();
			onMenuSelectedEvent.AddListener(unityCallback);
		}

		HidePopup();
	}

	protected virtual GameObject MakePopupGameObject(TextButton templateButton,
										   string selected = null)
	{
		// create popup menu
		GameObject popupGameObject = gameObject.MakeUiObject("Popup");

		// create blocker
		ClickBlocker clickBlocker = ClickBlocker.MakeClickBlocker(popupGameObject, OnBlockerClicked, OnBlockerRolled);

		// create menu
		_gameObjectMenu = popupGameObject.MakeUiObject("Menu");

		// create background
		GameObject gameObjectBackground = _gameObjectMenu.MakeUiObject("Background");
		Image backgroundImage = gameObjectBackground.AddComponent<Image>();
		backgroundImage.sprite = popupBgSprite;
		float btnWidth = popupTextButton.GetWidth() + padding * 2;
		float btnHeight = popupTextButton.GetHeight() + padding * 2;
		float bgHeight = (btnHeight - padding) * _menuItems.Length + padding;
		backgroundImage.SetSize(btnWidth, bgHeight);
		backgroundImage.SetY(backgroundImage.GetHeight() / 2 - btnHeight / 2);

		// set selected, this will move the background
		Selected = selected;

		// check if popup in within display region
		if (!UtilsRect.AinsideB(backgroundImage, clickBlocker)) {
			// if not, then reverse menuItem order
			//  causing menu to build in the opposite direction
			Array.Reverse(_menuItems);
			Selected = selected;
		}

		// create selection buttons
		float yLoc = 0;
		int counter = 0;
		_menuButtons = new ClickButton[_menuItems.Length];
		foreach (string menuItem in _menuItems) {
			int index = counter++;
			TextButton textButton = MakeTextButton(templateButton, menuItem);
			ClickButton clickButton = textButton.ClickButton;
			clickButton.SetY(yLoc);
			clickButton.onClickEvent.AddListener(delegate { MenuButtonClicked(new PopupMenuEventArgs(this, menuItem, index)); });
			clickButton.OnRolloverEvent += delegate { MenuButtonRolled(menuItem, index); };
			yLoc += clickButton.GetHeight() + padding;
			if (index == _selectedIndex) {
				clickButton.Selected = true;
				clickButton.Enabled = false;
			}
			_menuButtons[index] = clickButton;
		}

		return popupGameObject;
	}

	protected virtual TextButton MakeTextButton(TextButton templateButton, string menuItem)
	{
		TextButton textButton = _gameObjectMenu.MakeTextButton(templateButton, menuItem);
		return textButton;
	}

	protected virtual void ShowPopup()
	{
		// move popup to top of display list
		gameObject.MoveToTop();

		// TODO: Shouldn't need to reinitialize! just fix popup position, AinsideB() call.
		Initialize(_menuItems, Selected);

		// show popup
		_popupGameObject.SetActive(true);
		popupTextButton.gameObject.SetActive(false);
	}

	protected virtual void HidePopup()
	{
		_popupGameObject.SetActive(false);
		popupTextButton.gameObject.SetActive(true);
	}

	public void OnClickButton(ClickButton button)
	{
		if (_popupGameObject.activeSelf) {
			HidePopup();
		} else {
			ShowPopup();
		}
	}

	public void MenuButtonClicked(PopupMenuEventArgs popupMenuEventArgs)
	{
		Selected = popupMenuEventArgs.MenuItem;
		onMenuSelectedEvent?.Invoke(popupMenuEventArgs);
		HidePopup();
	}

	public void MenuButtonRolled(string menuItem, int index)
	{
		OnMenuRollEvent?.Invoke(menuItem, index);
	}

    public void OnBlockerClicked(PointerEventData pointerEventData)
    {
        HidePopup();
    }

	public void OnBlockerRolled(PointerEventData pointerEventData)
	{
		OnPopupRolloutEvent?.Invoke();
	}
}
