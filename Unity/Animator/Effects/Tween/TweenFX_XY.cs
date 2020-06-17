//
//  TweenFX v 2.0 - Animator package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2009-2019 Lowke Media
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

using AnimatorTypes;
using System.Collections.Generic;

public class TweenFX_XY : MultiEffectFX
{
    private float _endX;
    private float _endY;
    private float _duration;
    private EasingFunct _easingFunctX;
    private EasingFunct _easingFunctY;

    public TweenFX_XY(float endX,
                      float endY,
                      float duration,
                      EasingFunct easingFunctX = null,
                      EasingFunct easingFunctY = null,
                      EffectType type = EffectType.END,
                      string effectName = "TweenFX_XY") :
    base(null, effectName, type)
    {
        _endX = endX;
        _endY = endY;
        _duration = duration;
        _easingFunctX = easingFunctX;
        _easingFunctY = easingFunctY;
    }

    protected override void Initialize()
    {
        AnimatorEffect tweenX = new TweenFX_X(float.NaN, _endX, _duration, _easingFunctX, _type);
        AnimatorEffect tweenY = new TweenFX_Y(float.NaN, _endY, _duration, _easingFunctY, _type);
        _effects = new List<AnimatorEffect> { tweenX, tweenY };
        base.Initialize();
    }
}
