//
//  ClickBlocker - ClickBlocker package
//  Russell Lowke, April 21st 2021
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

using UnityEngine.EventSystems;
using UnityEngine;
using UnityEngine.UI;
using ClickBlockerTypes;

public class ClickBlocker : MonoBehaviour, IPointerDownHandler, IPointerEnterHandler
{
    private IBlockResolver _iBlockResolver;			// whatever instance that deals with the blocker pointer events

	public static ClickBlocker MakeClickBlocker(GameObject parentGameObject, GameObject focusGameObject)
	{
		GameObject clickBlockerGameObject = parentGameObject.MakeUiObject("Click Blocker");
		ClickBlocker clickBlocker = clickBlockerGameObject.AddComponent<ClickBlocker>();
		clickBlocker.Initialize(focusGameObject);

		return clickBlocker;
	}

	private void Initialize(GameObject focusGameObject)
    {
        Image blockerImage = gameObject.AddComponent<Image>();

		// TODO: Animate blocker's black cover alpha

		// use black cover 
		blockerImage.color = UtilsColor.ConvertColor("#00000099");		// last two 99 are alpha

		// Note: Assumption that all GameObjects are scaled at 100%
		Canvas canvas = focusGameObject.GetCanvas();
		RectTransform canvasRect = canvas.GetRectTransform();
		blockerImage.SetSize(canvasRect.sizeDelta);
		Vector3 localPosition = blockerImage.GetLocalPosition(canvasRect.position);
        blockerImage.SetLocalPosition(localPosition);
        _iBlockResolver = gameObject.GetComponentInParent<IBlockResolver>();
    }

    public void OnPointerDown(PointerEventData pointerEventData)
    {
		if (GlobalState.IsDragging) { return; }
		_iBlockResolver.OnBlockerClicked();
    }

    public void OnPointerEnter(PointerEventData pointerEventData) {
        _iBlockResolver.OnBlockerRolled();
    }
}
