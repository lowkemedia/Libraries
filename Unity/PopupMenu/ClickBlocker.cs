//
//  ClickBlocker - PopupMenu package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2019 Lowke Media
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

using UnityEngine.EventSystems;
using UnityEngine;
using UnityEngine.UI;

public class ClickBlocker : MonoBehaviour,
    IPointerDownHandler, IPointerEnterHandler
{
    private PopupMenu _popupMenu;

    public void Initialize(GameObject root, GameObject parent)
    {
        Image blockerImage = parent.AddComponent<Image>();
        blockerImage.color = Utils.ConvertColor("#FF000000");
        RectTransform canvasRect = root.GetCanvasRect();
        float blockerScale = 1 / root.GetScale();
        blockerImage.SetSize(canvasRect.sizeDelta);
        blockerImage.SetScale(blockerScale);
        blockerImage.SetPosition(root.GetPosition() * -blockerScale);

        _popupMenu = gameObject.GetComponentInParent<PopupMenu>();
    }

    public void OnPointerDown(PointerEventData clickEventData)
    {
        _popupMenu.OnPopupCancelled();
    }

    public void OnPointerEnter(PointerEventData clickEventData)
    {
        _popupMenu.OnPopupRollout();
    }

    public static ClickBlocker MakeClickBlocker(GameObject root, GameObject parent)
    {
        GameObject gameObjectBlocker = parent.MakeGameObject("Blocker");
        ClickBlocker clickBlocker = gameObjectBlocker.AddComponent<ClickBlocker>();
        clickBlocker.Initialize(root, gameObjectBlocker);

        return clickBlocker;
    }
}
