//
//  PageSwiper
//  Russell Lowke, May 14th 2020
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

using System.Collections;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;

[System.Serializable]
public class PageNumberEvent : UnityEvent<int> {}

public class PageSwiper : MonoBehaviour, IDragHandler, IEndDragHandler, IPointerClickHandler
{
    public float percentThreshold = 0.2f;
    public float easing = 0.5f;
    public PageNumberEvent onPageChange;
    public PageNumberEvent onAnimationFinished;

    private int _totalPages;
    private int _pageIndex;
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
        onAnimationFinished.RemoveAllListeners();
        GotoPage(0, true);
    }

    public void OnDrag(PointerEventData data)
    {
        _dragging = true;
        Vector3 localPressPosition = this.GetLocalPosition(data.pressPosition);
        Vector3 localPosition = this.GetLocalPosition(data.position);
        float difference = localPressPosition.x - localPosition.x;


        if ((_pageIndex == 0 && difference < difference * percentThreshold) ||
            (_pageIndex == _totalPages - 1 && difference > difference * percentThreshold))
        {
            // clamp swiping before page 1 and after the last page
            difference *= percentThreshold;
        }
        else if (_pageIndex > 0 &&                  // (difference -'ve)
                 _panelLocation.x - difference > _startLocation.x)
        {
            // clamp start location
            transform.localPosition = _startLocation;
            return;
        }
        else if (_pageIndex < _totalPages - 1 &&    // (difference +'ve)
                 _panelLocation.x - difference < _endLocation.x)
        {
            // clamp end location
            transform.localPosition = _endLocation;
            return;
        }

        transform.localPosition = _panelLocation - new Vector3(difference, 0, 0);
    }

    public void OnEndDrag(PointerEventData data)
    {
        Vector3 localPressPosition = this.GetLocalPosition(data.pressPosition);
        Vector3 localPosition = this.GetLocalPosition(data.position);
        float difference = localPressPosition.x - localPosition.x;
        float percentage = difference/_pageWidth;

        if (Mathf.Abs(percentage) >= percentThreshold)
        {
            // move to new page
            int pagesMoved = (int) percentage/1;
            pagesMoved += (percentage < 0) ? -1 : +1;
            GotoPage(_pageIndex + pagesMoved);
        } else {
            // bounce back to original position
            GotoPage(_pageIndex);
        }
    }

    public void OnPointerClick(PointerEventData data)
    {
        if (_dragging == false) {
            GotoPage(++_pageIndex);
        }
    }

    public void GotoPage(int pageIndex, bool snapTo = false)
    {
        pageIndex = Utils.Clamp(pageIndex, 0, _totalPages - 1);
        Vector3 newLocation = _startLocation - new Vector3(pageIndex * _pageWidth, 0, 0);
        _pageIndex = pageIndex;
        _panelLocation = newLocation;
        _dragging = false;

        onPageChange?.Invoke(_pageIndex);

        if (snapTo) {
            transform.localPosition = _panelLocation;
            onAnimationFinished?.Invoke(_pageIndex);
            return;
        }

        StartCoroutine(SmoothMove(transform.localPosition, newLocation, easing));
    }

    IEnumerator SmoothMove(Vector3 startpos, Vector3 endpos, float seconds)
    {
        float t = 0f;
        while (t <= 1.0) {
            t += Time.deltaTime/seconds;
            transform.localPosition = Vector3.Lerp(startpos, endpos, Mathf.SmoothStep(0f, 1f, t));
            yield return null;
        }

        onAnimationFinished?.Invoke(_pageIndex);
    }
}