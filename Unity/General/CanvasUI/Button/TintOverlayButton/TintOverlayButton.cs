//
//  TintOverlayButton - Button package
//  Russell Lowke, July 24th 2020
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
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class TintOverlayButton : ClickButton, IPointerClickHandler

{
    public Sprite tintImage;

    private ScrollRectExtend _scrollRect;
    private Color _tintPressed;               // "down" tint
    private Image _tintImage;
    private bool _dragging;

    protected override void Start()
    {
        base.Start();

        _tintPressed = UtilsColor.ConvertColor("#e95525");             // e9552575         // ef805cbf

        GameObject child = gameObject.MakeUiObject("Tint");
        _tintImage = child.AddComponent<Image>();
        _tintImage.SetSize(new Vector2(Image.GetWidth(), Image.GetHeight()));
        _tintImage.sprite = tintImage;
        _tintImage.color = Color.clear;

        _scrollRect = GetComponentInParent<ScrollRectExtend>();
        _scrollRect.OnBeginDragEvent += OnBeginDrag;
        _scrollRect.OnEndDragEvent += OnEndDrag;
    }

    public override void UpdateButton()
    {
        base.UpdateButton();

        if (!_tintImage) {
            return;     // too early, button hasn't called Start() yet.
        }

        if (Pressed) {
            _tintImage.color = _tintPressed;
        } else if (PointerInside) {
            if (_dragging && SystemInfo.deviceType != DeviceType.Handheld) {
                // don't show as white while dragging on desktop app
                _tintImage.color = Color.clear;
            } else {
                _tintImage.color = Color.white;
            }
        } else {
            _tintImage.color = Color.clear;
        }
    }

    public void OnBeginDrag(PointerEventData pointerEventData)
    {
        _dragging = true;
    }

    public void OnEndDrag(PointerEventData pointerEventData)
    {
        _dragging = false;
        if(SystemInfo.deviceType != DeviceType.Handheld) {
            // update back to white after dragging on desktop app
            UpdateButton();
        }
    }
}

