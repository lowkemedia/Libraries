//
//  PopupMenu - PopupMenu package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2019 Lowke Media
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
using UnityEngine.EventSystems;
using UnityEngine.UI;

[System.Serializable]
public class IndexedUnityEvent : UnityEvent<string> { }

public class PopupMenu : MonoBehaviour
{
	// TODO: device version needs to behave differenetly from desktop
	// TODO: Add accessor to any additional labal textfield

	public Sprite popupBgSprite;                    // TODO: use sliced sprite (9-slice scaling)
	public TextButtonOld popupTextButton;
	public IndexedUnityEvent onMenuSelected;
	public IndexedUnityEvent onMenuRoll;
	public UnityEvent onPopupRollout;
	public UnityEvent onPopupCanceled;

	public float padding = 30;                      // padding around buttons

	private GameObject _popupGameObject;
	private GameObject _gameObjectMenu;
	private int _selectedIndex;
	private string[] _labels;

	public void Initialize(string[] labels,
						   string selected = null)
	{
		_labels = (string[])labels.Clone();

		//TODO: initialize the popupTextButton to defaults? initial values?
		//  Is Enabled = true enough?
		popupTextButton.Enabled = true;

		if (_popupGameObject != null) {
			Destroy(_popupGameObject);
		}
		_popupGameObject = MakePopupGameObject(popupTextButton, selected);

		HidePopup();
	}

	private GameObject MakePopupGameObject(TextButtonOld templateButton,
										   string selected = null)
	{
		// create popup menu
		GameObject popupGameObject = gameObject.MakeGameObject("Popup");

		// create blocker
		ClickBlocker clickBlocker = ClickBlocker.MakeClickBlocker(gameObject, popupGameObject);

		// create menu
		_gameObjectMenu = popupGameObject.MakeGameObject("Menu");

		// create background
		GameObject gameObjectBackground = _gameObjectMenu.MakeGameObject("Background");
		Image backgroundImage = gameObjectBackground.AddComponent<Image>();
		backgroundImage.sprite = popupBgSprite;
		float btnWidth = popupTextButton.GetWidth() + padding * 2;
		float btnHeight = popupTextButton.GetHeight() + padding * 2;
		float bgHeight = (btnHeight - padding) * _labels.Length + padding;
		backgroundImage.SetSize(btnWidth, bgHeight);
		backgroundImage.SetY(backgroundImage.GetHeight() / 2 - btnHeight / 2);

		// set selected, this will move the background
		Selected = selected;

		// check if popup in within display region
		if (!UtilsRect.AinsideB(backgroundImage, clickBlocker)) {
			// if not, then reverse label order
			//  causing menu to build in the opposite direction
			Array.Reverse(_labels);
			Selected = selected;
		}

		// create selection buttons
		float yLoc = 0;
		int counter = 0;
		foreach (string label in _labels) {
			int index = counter++;
			TextButtonOld textButton = _gameObjectMenu.MakeTextButton(templateButton, label);
			textButton.SetY(yLoc);
			textButton.onClick.AddListener(delegate { MenuButtonClicked(label); });
			textButton.onRollover.AddListener(delegate { MenuButtonRolled(label); });
			yLoc += textButton.GetHeight() + padding;
		}

		return popupGameObject;
	}

	public string Selected {
		get {
			return _labels[_selectedIndex];
		}

		set {
			SelectedIndex = Array.IndexOf(_labels, value);
		}
	}

	public int SelectedIndex {
		get { return _selectedIndex; }

		set {
			_selectedIndex = value;

			if (_selectedIndex < 0 ||
				_selectedIndex > _labels.Length - 1) {
				_selectedIndex = 0;
			}

			// show correct label on button
			popupTextButton.textField.text = Selected;

			// move popup according to location of selected item
			float yPos = -_selectedIndex * (popupTextButton.GetHeight() + padding);
			_gameObjectMenu.SetY(yPos);
		}
	}

	private void ShowPopup()
	{
		// move popup to top of display list
		gameObject.MoveToTop();

		// TODO: Shouldn't need to reinitialize! just fix popup position, AinsideB() call.
		Initialize(_labels, Selected);

		// show popup
		_popupGameObject.SetActive(true);
		popupTextButton.gameObject.SetActive(false);
	}

	private void HidePopup()
	{
		_popupGameObject.SetActive(false);
		popupTextButton.gameObject.SetActive(true);
	}

	public void OnClickButton()
	{
		if (_popupGameObject.activeSelf) {
			HidePopup();
		} else {
			ShowPopup();
		}
	}

	public void MenuButtonClicked(string label = null)
	{
		Selected = label;
		if (onMenuSelected != null) {
			onMenuSelected.Invoke(Selected);
		}
		HidePopup();
	}

	public void MenuButtonRolled(string label)
	{
		if (onMenuRoll != null) {
			onMenuRoll.Invoke(label);
		}
	}

	public void OnPopupCancelled()
	{
		HidePopup();

		if (onMenuSelected != null) {
			onPopupCanceled.Invoke();
		}
	}

	public void OnPopupRollout()
	{
		if (onPopupRollout != null) {
			onPopupRollout.Invoke();
		}
	}
}