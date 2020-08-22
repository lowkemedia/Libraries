//
//  PressButton - Button package
//  Russell Lowke, August 22nd 2020
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

public class PressButton : ClickButton
{
    private float _invokedTime;                         // time of last invoke
    private float _pressTime;                           // time of last press
    public float invokeInterval = 0.15f;                // interval between press invokes, in seconds

    public override void OnPointerDown(PointerEventData pointerEventData = null)
    {
        _pressTime = Time.time;
        base.OnPointerDown(pointerEventData);
    }

    public override void OnPointerUp(PointerEventData pointerEventData)
    {
        _invokedTime = 0;
        base.OnPointerUp(pointerEventData);
    }

    private void Update()
    {
        float timeNow = Time.time;
        if (Pressed && PointerInside &&
            timeNow - _pressTime >= invokeInterval) {
            Click();
        }
    }

    public override void Click(float pressDuration = 0)
    {
        float timeNow = Time.time;
        if (timeNow - _invokedTime >= invokeInterval) {
            _invokedTime = timeNow;
            base.Click(pressDuration);
        }
    }
}
