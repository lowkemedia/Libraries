//
//  ClickBlocker - ClickBlocker package
//  Russell Lowke, November 8th 2022
//
//  Copyright (c) 2019-2022 Lowke Media
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
using CallbackTypes;

public class ClickBlocker : MonoBehaviour, IPointerDownHandler, IPointerEnterHandler
{
    private OnPointerEvent _blockerClicked;
    private OnPointerEvent _blockerRolled;

    private void Initialize(OnPointerEvent blockerClicked = default,
                            OnPointerEvent blockerRolled = default)
    {
        Image blockerImage = gameObject.AddComponent<Image>();

		// TODO: Animate blocker's black cover alpha

		// use black cover 
		blockerImage.color = UtilsColor.ConvertColor("#00000099");		// last two 99 are alpha

		// Note: Assumption that all GameObjects are scaled at 100%
		Canvas canvas = gameObject.GetCanvas();
		RectTransform canvasRect = canvas.GetRectTransform();
		blockerImage.SetSize(canvasRect.sizeDelta);
		Vector3 localPosition = blockerImage.GetLocalPosition(canvasRect.position);
        blockerImage.SetLocalPosition(localPosition);

        _blockerClicked = blockerClicked;
        _blockerRolled = blockerRolled;
    }

    public void OnPointerDown(PointerEventData pointerEventData)
    {
		if (GlobalState.IsDragging) { return; }
        _blockerClicked?.Invoke(pointerEventData);
    }

    public void OnPointerEnter(PointerEventData pointerEventData) {
        _blockerRolled?.Invoke(pointerEventData);
    }


    //
    // factory

    public static ClickBlocker MakeClickBlocker(GameObject blockerParent,
                                                OnPointerEvent blockerClicked = default,
                                                OnPointerEvent blockerRolled = default)
    {
        GameObject clickBlockerGameObject = blockerParent.MakeUiObject("Click Blocker");
        ClickBlocker clickBlocker = clickBlockerGameObject.AddComponent<ClickBlocker>();
        clickBlocker.Initialize(blockerClicked, blockerRolled);

        return clickBlocker;
    }
}
