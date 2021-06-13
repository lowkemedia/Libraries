//
//  PageSwiper - PageSwiper package
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
using CallbackTypes;

[System.Serializable]
public class PageNumberEvent : UnityEvent<int> {}

public class PageSwiper : MonoBehaviour, IDragHandler, IEndDragHandler, IPointerClickHandler
{
    private const float PERCENT_THRESHOLD = 0.2f;
    private const float EASING = 0.5f;

    public Image swipeArea;
    public UnityEvent onPageClick;                      // Unity event for page clicked
    public PageNumberEvent onPageChange;                // Unity event for page change
    public bool clickAutoPagesForward = true;

    public event Callback OnSwipePastLastPage;          // C# event for swiping past the last page
    public event Callback OnSwipeBeforeFirstPage;       // C# event for swiping before the first page

    public int PageIndex { get; private set; }
    public int TotalPages { get; private set; }

    private float _pageWidth;
    private Vector3 _startLocation;
    private Vector3 _endLocation;
    private Vector3 _panelLocation;
    private bool _dragging;
    private bool _pastBounds;       // special case flag to prevent user from clicking past bounds while page animating

    public void Initialize(int totalPages, float pageWidth)
    {
        // TODO: Implement SwipeDetector class

        if (_startLocation == default) {
            _startLocation = transform.localPosition;
        }

        TotalPages = totalPages;
        _pageWidth = pageWidth;
        _endLocation = _startLocation - new Vector3((TotalPages - 1) * _pageWidth, 0, 0);
        _panelLocation = _startLocation;
        GotoPage(0, true);
    }

    public void OnPointerClick(PointerEventData pointerEventData = null)
    {
        if (_dragging == false && _pastBounds == false) {
            if (clickAutoPagesForward) {
                PageChange(+1);
            }
            onPageClick?.Invoke();
        }
    }

    public void OnDrag(PointerEventData pointerEventData)
    {
        _dragging = true;

        if (TotalPages < 2) {
            // PageSwiper doesn't swipe with only one or zero pages.
            return;
        }

        Vector3 localPressPosition = this.GetLocalPosition(pointerEventData.pressPosition);
        Vector3 localPosition = this.GetLocalPosition(pointerEventData.position);
        float difference = localPressPosition.x - localPosition.x;


        if ((PageIndex == 0 && difference < difference * PERCENT_THRESHOLD) ||
            (PageIndex == TotalPages - 1 && difference > difference * PERCENT_THRESHOLD))
        {
            // clamp swiping before page 1 and after the last page
            difference *= PERCENT_THRESHOLD;
        }
        else if (PageIndex > 0 &&                  // (difference -'ve)
                 _panelLocation.x - difference > _startLocation.x)
        {
            // clamp start location
            transform.localPosition = _startLocation;
            return;
        }
        else if (PageIndex < TotalPages - 1 &&    // (difference +'ve)
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

        int pagesMoved = 0;
        if (Mathf.Abs(percentage) >= PERCENT_THRESHOLD) {
            pagesMoved = (int) percentage / 1;
            pagesMoved += (percentage < 0) ? -1 : +1;
        }

        if (pagesMoved != 0) {
            // move forward or backward page
            PageChange(pagesMoved);
        } else {
            // bounce back to original position
            GotoPage(PageIndex);
        }
    }

    private void PageChange(int pagesMoved)
    {
        if (pagesMoved == 0) {
            return; // not actually changing page
        } else if (PageIndex == TotalPages - 1 && pagesMoved > 0) {
            _pastBounds = true;
            OnSwipePastLastPage?.Invoke();
        } else if (PageIndex == 0 && pagesMoved < 0) {
            _pastBounds = true;
            OnSwipeBeforeFirstPage?.Invoke();
        }
        GotoPage(PageIndex + pagesMoved);
    }

    public void GotoPage(int pageIndex, bool snapTo = false, Callback callback = null)
    {
        pageIndex = Utils.Clamp(pageIndex, 0, TotalPages - 1);
        Vector3 newLocation = _startLocation - new Vector3(pageIndex * _pageWidth, 0, 0);
        PageIndex = pageIndex;
        _panelLocation = newLocation;
        _dragging = false;

        onPageChange?.Invoke(PageIndex);

        if (snapTo) {
            transform.localPosition = _panelLocation;
        } else {
            Mover.SmoothMove(transform, newLocation, EASING, delegate() { FinishedAnimating(callback); });
        }
    }

    private void FinishedAnimating(Callback callback) {
        _pastBounds = false;
        callback?.Invoke();
    }
}