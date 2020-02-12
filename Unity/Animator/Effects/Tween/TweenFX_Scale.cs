//
//  TweenFX v 2.0 - Animator package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2009-2019 Lowke Media
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

using UnityEngine;
using AnimatorTypes;

public class TweenFX_Scale : TweenFX
{
    private RectTransform _rectTransform;

    public TweenFX_Scale(float start,
                        float end,
                        float duration,
                        EasingFunct easingFunct = null,
                        EffectType type = EffectType.END) : 
    base(start, end, duration, easingFunct, type, "TweenFX_Size") {}

    protected override void Initialize()
    {
        _rectTransform = _target.GetComponent<RectTransform>();
        base.Initialize();
    }

    public override float Value
    {
        get { return _rectTransform.sizeDelta.magnitude; }
        set
        {
            base.Value = value;

            _rectTransform.sizeDelta = new Vector2(value, value);
        }
    }
}