//
//  PageDots - PageSwiper package
//  Russell Lowke, April 11th 2021
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

using System;
using UnityEngine;

[RequireComponent(typeof(PageSwiper))]
public class PageDots : MonoBehaviour
{
	public int maxDots = -1;				// maximum number of dots to use when displaying pages
											//  -1 indicates that there is no maximum and dots for all pages are generated.
	public float padding = 14;				// px padding used between dots
	public PageDot pageDotTemplate;         // template dot used for creating each page dot

	// variables for use with IsLotsOfPages functionality
	private int _halfDots;                  // number of dots either side of the center dot
	private int _dotIndex;                  // dot index displayed when IsLotsOfPages
	private bool _isFloatingDot;			// true if the dot is "floating" in the middle of lots of pages
	private int _middleDotPageIndex;        // index of the page at the middle dot when not _isFloatingDot
	private int _peviousPageIndex;          // page index of previous page prior to swipe

	private PageSwiper _pageSwiper;
	public PageSwiper PageSwiper {
		get {
			if (!_pageSwiper) { _pageSwiper = GetComponent<PageSwiper>(); }
			return _pageSwiper;
		}
	}

	private bool IsLotsOfPages {
		get {
			if (maxDots == -1 ||
				maxDots >= PageSwiper.TotalPages) {
				return false;
			}

			return true;
		}
	}

	private int TotalDots
	{
		get {
			if (IsLotsOfPages) {
				return maxDots;
			} else {
				return PageSwiper.TotalPages;
			}
		}
	}

	private PageDot[] _pageDots;            // array of page dots pertaining to each page
	private PageDot FirstDot {
		get { return _pageDots[0]; }
    }
	private PageDot LastDot {
		get { return _pageDots[maxDots - 1]; }
	}

	// Update is called once per frame
	public void Start()
	{
		InitializePageDots();

		PageSwiper.onPageChange.AddListener(OnPageChange);
		UpdatePageDots();
	}
	
	private void InitializePageDots()
	{
		_peviousPageIndex = PageSwiper.PageIndex;

		if (IsLotsOfPages)
		{
			if (maxDots%2 == 0) {
				throw new Exception("maxDots must be an odd number.");
            }
			_halfDots = maxDots/2;

			if (PageSwiper.PageIndex <= _halfDots) {
				// early dot
				_dotIndex = PageSwiper.PageIndex;
				_middleDotPageIndex = _halfDots;
			} else if (PageSwiper.PageIndex >= PageSwiper.TotalPages - _halfDots) {
				// late dot
				_dotIndex = maxDots - (PageSwiper.TotalPages - PageSwiper.PageIndex);
				_middleDotPageIndex = PageSwiper.TotalPages - _halfDots - 1;
			} else {
				// middle dot
				_dotIndex = _halfDots;
				_middleDotPageIndex = PageSwiper.PageIndex;
			}
		}

		GameObject pageDots = pageDotTemplate.GetParent();
		_pageDots = new PageDot[PageSwiper.TotalPages];

		float originX = pageDotTemplate.GetX() + pageDotTemplate.GetWidth();
		float dotWidth = pageDotTemplate.GetWidth();
		float dotsWidth = (dotWidth + padding) * TotalDots;
		for (int i = 0; i < TotalDots; ++i)
		{
			PageDot pageDot = pageDots.MakeUiComponent(pageDotTemplate, "Page Dot " + (i + 1));
			pageDot.pageDot = pageDotTemplate.pageDot;
			pageDot.pageDotLight = pageDotTemplate.pageDotLight;
			pageDot.smallPageDot = pageDotTemplate.smallPageDot;
			pageDot.smallPageDotLight = pageDotTemplate.smallPageDotLight;
			pageDot.SetX(originX + (dotWidth + padding) * i - dotsWidth/2);
			_pageDots[i] = pageDot;
		}
		pageDotTemplate.GetGameObject().SetActive(false);
	}

	
	private void OnPageChange(int pageIndex)
	{
		int difference = pageIndex - _peviousPageIndex;

		if (IsLotsOfPages)
		{
			if (!_isFloatingDot) {

				// find the middle dot page index
				_middleDotPageIndex += difference;
				if (pageIndex <= _halfDots) {
					// beginning pages
					_middleDotPageIndex = _halfDots;
				} else if (pageIndex >= PageSwiper.TotalPages - _halfDots) {
					// end pages
					_middleDotPageIndex = PageSwiper.TotalPages - _halfDots - 1;
				} else {
					// floating in middle
					_middleDotPageIndex = PageSwiper.PageIndex;
					_isFloatingDot = true;
				}
			}

			if (_isFloatingDot) {

				// find dot index relative to where it was previously
				_dotIndex += difference;
				if (_dotIndex < 1) {
					_dotIndex = 1;                      // constrain to 2nd dot
				}
				if (_dotIndex > maxDots - 2) {
					_dotIndex = maxDots - 2;			// constrain to 2nd last dot
				}

            } else {

				// calculate the dot index
				_dotIndex = PageSwiper.PageIndex - _middleDotPageIndex + _halfDots;
			}
		}

		UpdatePageDots();
		_peviousPageIndex = pageIndex;
	}

	private void UpdatePageDots()
	{
		if (!IsLotsOfPages) {
			// when !IsLotsOfPages
			//  show page dot according to PageIndex
			for (int i = 0; i < TotalDots; ++i) {
				PageDot pageDot = _pageDots[i];
				pageDot.Selected = (PageSwiper.PageIndex == i);
			}
			return;
		}

		if (_isFloatingDot)
		{
			//
			// edge dots default as small
			FirstDot.Small = true;
			LastDot.Small = true;

			// check if on the first two pages
			if (PageSwiper.PageIndex < 2)
			{
				// cease floating and make the first dot big
				_isFloatingDot = false;
				FirstDot.Small = false;

				// if on the first page display as such
				if (PageSwiper.PageIndex == 0) {
					_dotIndex = 0;                  // set to 1st
				}
			}

			// check if on the last two pages
			if (PageSwiper.PageIndex >= PageSwiper.TotalPages - 2)
			{
				// cease floating and make the last dot big
				_isFloatingDot = false;
				LastDot.Small = false;

				// if on the last page display as such
				if (PageSwiper.PageIndex == PageSwiper.TotalPages - 1) {
					_dotIndex = maxDots - 1;        // set to last
				}
			}
		} else {

			//
			// edge dots calculated by position
			FirstDot.Small = _middleDotPageIndex > _halfDots;
			LastDot.Small = _middleDotPageIndex < PageSwiper.TotalPages - _halfDots - 1;
		}

		// when IsLotsOfPages
		//  show page dot according to _dotIndex
		for (int i = 0; i < TotalDots; ++i) {
			PageDot pageDot = _pageDots[i];
			pageDot.Selected = _dotIndex == i;
		}
	}
}
