//
//  SwipeDetector - Button package
//  Russell Lowke, March 15th 2021
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
using UnityEngine.Events;
using UnityEngine.EventSystems;

[System.Serializable]
public class SwipeEvent : UnityEvent<float> { }

public class SwipeDetector : MonoBehaviour, IPointerClickHandler, IDragHandler, IBeginDragHandler, IEndDragHandler
{
    public SwipeEvent onSwipe;              // Unity event for swipe
    public bool ignoreClicks = false;       // if true any clicks are ignored

    private bool _dragging;

    public void OnPointerClick(PointerEventData pointerEventData)
    {
        _dragging = false;
        
        if (!ignoreClicks) {
            HandleSwipe(pointerEventData);
        }
    }

    public void OnDrag(PointerEventData pointerEventData)
    {
        // user dragging
        //  Must have OnDrag() method for OnBeginDrag() and OnEndDrag() to work
    }

    public void OnBeginDrag(PointerEventData pointerEventData)
    {
        _dragging = true;
    }

    public void OnEndDrag(PointerEventData pointerEventData)
    {
        if (_dragging) {
            HandleSwipe(pointerEventData);
        }

        _dragging = false;
    }

    private void HandleSwipe(PointerEventData pointerEventData)
    {
        Vector3 localPressPosition = this.GetLocalPosition(pointerEventData.pressPosition);
        Vector3 localPosition = this.GetLocalPosition(pointerEventData.position);
        float direction = localPosition.x - localPressPosition.x;

        onSwipe?.Invoke(direction);
    }
}