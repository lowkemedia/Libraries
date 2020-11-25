//
//  PageSwiper
//  Russell Lowke, October 31st 2020
//
//  Copyright (c) 2020 Lowke Media
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
using UnityEngine.UI;

[System.Serializable]
public class PageNumberEvent : UnityEvent<int> {}

public class PageSwiper : MonoBehaviour, IDragHandler, IEndDragHandler, IPointerClickHandler
{
    public delegate void Callback();

    public Image swipeArea;
    public float percentThreshold = 0.2f;
    public float easing = 0.5f;
    public PageNumberEvent onPageChange;                // Unity event for page change
    public event Callback OnPastLastPage;               // Regular event for clicking past the last page

    public int PageIndex { get; private set; }
    private int _totalPages;
    private float _pageWidth;
    private Vector3 _startLocation;
    private Vector3 _endLocation;
    private Vector3 _panelLocation;
    private bool _dragging;

    public void Initialize(int totalPages, float pageWidth)
    {
        if (_startLocation == default) {
            _startLocation = transform.localPosition;
        }

        _totalPages = totalPages;
        _pageWidth = pageWidth;
        _endLocation = _startLocation - new Vector3((_totalPages - 1) * _pageWidth, 0, 0);
        _panelLocation = _startLocation;

        onPageChange.RemoveAllListeners();
        GotoPage(0, true);
    }

    public void OnDrag(PointerEventData pointerEventData)
    {
        if (_totalPages < 2) {
            // PageSwiper doesn't swipe with only one or zero pages.
            return;
		}

        _dragging = true;
        Vector3 localPressPosition = this.GetLocalPosition(pointerEventData.pressPosition);
        Vector3 localPosition = this.GetLocalPosition(pointerEventData.position);
        float difference = localPressPosition.x - localPosition.x;


        if ((PageIndex == 0 && difference < difference * percentThreshold) ||
            (PageIndex == _totalPages - 1 && difference > difference * percentThreshold))
        {
            // clamp swiping before page 1 and after the last page
            difference *= percentThreshold;
        }
        else if (PageIndex > 0 &&                  // (difference -'ve)
                 _panelLocation.x - difference > _startLocation.x)
        {
            // clamp start location
            transform.localPosition = _startLocation;
            return;
        }
        else if (PageIndex < _totalPages - 1 &&    // (difference +'ve)
                 _panelLocation.x - difference < _endLocation.x)
        {
            // clamp end location
            transform.localPosition = _endLocation;
            return;
        }

        transform.localPosition = _panelLocation - new Vector3(difference, 0, 0);
    }

    public void OnEndDrag(PointerEventData pointerEventData)
    {
        Vector3 localPressPosition = this.GetLocalPosition(pointerEventData.pressPosition);
        Vector3 localPosition = this.GetLocalPosition(pointerEventData.position);
        float difference = localPressPosition.x - localPosition.x;
        float percentage = difference/_pageWidth;

        if (Mathf.Abs(percentage) >= percentThreshold)
        {
            // move to new page
            int pagesMoved = (int) percentage/1;
            pagesMoved += (percentage < 0) ? -1 : +1;
            PageChange(pagesMoved);
        } else {
            // bounce back to original position
            GotoPage(PageIndex);
        }
    }

    public void OnPointerClick(PointerEventData pointerEventData = null)
    {
        if (_dragging == false) {
            PageChange(+1);
        }
    }

    private void PageChange(int pagesMoved)
    {
        if (pagesMoved == 0) {
            return; // not actually changing page
        }
        if (PageIndex == _totalPages - 1 && pagesMoved > 0) {
            OnPastLastPage?.Invoke();
        }
        GotoPage(PageIndex + pagesMoved);
    }

    public void GotoPage(int pageIndex, bool snapTo = false, Callback callback = null)
    {
        pageIndex = Utils.Clamp(pageIndex, 0, _totalPages - 1);
        Vector3 newLocation = _startLocation - new Vector3(pageIndex * _pageWidth, 0, 0);
        PageIndex = pageIndex;
        _panelLocation = newLocation;
        _dragging = false;

        onPageChange?.Invoke(PageIndex);

        if (snapTo) {
            transform.localPosition = _panelLocation;
        } else {
            Mover.SmoothMove(transform, newLocation, easing, delegate() { callback?.Invoke(); });
        }
    }
}