//
//  PageDot - PageSwiper package
//  Russell Lowke, April 6th 2021
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
using UnityEngine.UI;

[RequireComponent(typeof(Image))]
public class PageDot : MonoBehaviour
{
	public Sprite pageDot;
	public Sprite pageDotLight;
	public Sprite smallPageDot;
	public Sprite smallPageDotLight;

	bool _small;
	public bool Small {
		get { return _small; }
		set { _small = value; UpdatePageDot(); }
	}

	bool _selected;
	public bool Selected {
		get { return _selected; }
		set { _selected = value; UpdatePageDot(); }
	}

	private Image _image;
	public Image Image {
		get {
			if (!_image) { _image = GetComponent<Image>(); }
			return _image;
		}
	}

	public void Start()
	{
		UpdatePageDot();
	}

	private void UpdatePageDot()
	{
		if (Small) {
			Image.sprite = Selected ? smallPageDot : smallPageDotLight;
		} else {
			Image.sprite = Selected ? pageDot : pageDotLight;
		}
	}
}
