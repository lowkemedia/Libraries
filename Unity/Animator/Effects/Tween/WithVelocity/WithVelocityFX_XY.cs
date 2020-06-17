//
//  WithVelocityFX v 2.0 - Animator package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2008-2019 Lowke Media
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
using AnimatorTypes;
using System.Collections.Generic;
using System;

public class WithVelocityFX_XY : MultiEffectFX
{
    private float _endX;
    private float _endY;
    private float _velocity;
    private EasingFunct _easingFunctX;
    private EasingFunct _easingFunctY;

    public WithVelocityFX_XY(float endX,
                             float endY,
                             float velocity,
                             EasingFunct easingFunctX = null,
                             EasingFunct easingFunctY = null,
                             EffectType type = EffectType.END,
                             string effectName = "WithVelocityFX_XY") :
    base(null, effectName, type)
    {
        _endX = endX;
        _endY = endY;
        _velocity = velocity;
        _easingFunctX = easingFunctX;
        _easingFunctY = easingFunctY;
    }

    protected override void Initialize()
    {
        Transform trasform = _target.GetComponent<Transform>();
        float duration = Distance(trasform.localPosition.x, trasform.localPosition.y, _endX, _endY) / _velocity;
        AnimatorEffect tweenX = new TweenFX_X(float.NaN, _endX, duration, _easingFunctX, _type);
        AnimatorEffect tweenY = new TweenFX_Y(float.NaN, _endY, duration, _easingFunctY, _type);
        _effects = new List<AnimatorEffect> { tweenX, tweenY };
        base.Initialize();
    }

    public static float Distance(float x1,
                                 float y1,
                                 float x2,
                                 float y2)
    {
        // distance between x1, y1 and x2, y2
        return (float)Math.Sqrt(Math.Pow(x2 - x1, 2) + Math.Pow(y2 - y1, 2));
    }
}
