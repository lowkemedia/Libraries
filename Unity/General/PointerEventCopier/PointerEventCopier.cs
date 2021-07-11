//
//  PointerEventCopier
//  Russell Lowke, July 10th 2021
//
//  Copyright (c) 2021 Lowke Media
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
using UnityEngine.EventSystems;

public class PointerEventCopier : MonoBehaviour,
    IBeginDragHandler, IDragHandler, IEndDragHandler,
    IPointerClickHandler, IPointerDownHandler, IPointerEnterHandler,
    IPointerExitHandler, IPointerUpHandler
{
    public Component target;           // target to recieve pointer events

    public void OnBeginDrag(PointerEventData pointerEventData)
    {
        if (target is IBeginDragHandler) {
            (target as IBeginDragHandler).OnBeginDrag(pointerEventData);
        }
    }

    public void OnDrag(PointerEventData pointerEventData)
    {
        if (target is IDragHandler) {
            (target as IDragHandler).OnDrag(pointerEventData);
        }
    }

    public void OnEndDrag(PointerEventData pointerEventData)
    {
        if (target is IEndDragHandler) {
            (target as IEndDragHandler).OnEndDrag(pointerEventData);
        }
    }

    public void OnPointerClick(PointerEventData pointerEventData)
    {
        if (target is IPointerClickHandler) {
            (target as IPointerClickHandler).OnPointerClick(pointerEventData);
        }
    }

    public void OnPointerDown(PointerEventData pointerEventData)
    {
        if (target is IPointerDownHandler) {
            (target as IPointerDownHandler).OnPointerDown(pointerEventData);
        }
    }

    public void OnPointerEnter(PointerEventData pointerEventData)
    {
        if (target is IPointerEnterHandler) {
            (target as IPointerEnterHandler).OnPointerEnter(pointerEventData);
        }
    }

    public void OnPointerExit(PointerEventData pointerEventData)
    {
        if (target is IPointerExitHandler) {
            (target as IPointerExitHandler).OnPointerExit(pointerEventData);
        }
    }

    public void OnPointerUp(PointerEventData pointerEventData)
    {
        if (target is IPointerUpHandler) {
            (target as IPointerUpHandler).OnPointerUp(pointerEventData);
        }
    }
}