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
using System.Collections.Generic;

public class TweenFX : AnimatorEffect
{
    private float _start;               // start value of tween
    private float _end;                 // end value of tween
    protected float _range;             // range of the tween
    protected float _duration;          // duration of the tween
    private float _endTime;             // time tween ends
    private EasingFunct _easingFunct;   // function used for easing
    private float _value;               // value of variable being tweened

    // NOTE: set start to NaN to start at existing value of target GameObject
    //       set end to NaN to end at existing value of target GameObject
    public TweenFX(float start,
                   float end,
                   float duration,
                   EasingFunct easingFunct = null,
                   EffectType type = EffectType.END, 
                   string effectName = "TweenFX") : 
    base(effectName, type)
    {
        _start = start;
        _end = end;
        _duration = duration;
        _easingFunct = easingFunct;

        if (_easingFunct == null)
        {
            _easingFunct = NoEasing.EaseNone;
        }
    }

    protected override void Initialize()
    {
        if (float.IsNaN(_start))
        {
            // when start is NaN, start at current value of target
            _start = Value;
        }

        if (float.IsNaN(_end))
        {
            // when end is NaN, end at current value of target
            _end = Value;
        }

        Value = _start;
        _range = _end - _start;
        _endTime = _startTime + _duration;
    }

    //
    // used when changing values mid animation
    private void Recalibrate(float start,
                             float end,
                             float duration,
                             EasingFunct easingFunct) 
    {
        _startTime  = Time.time;
        _start      = start;
        _end        = end;
        _duration   = duration;
        _easingFunct = easingFunct;
        _range = _end - _start;
        _endTime    = _startTime + _duration;
        Update(_startTime);
    }

    protected override bool Update()
    {
        if (_updateTime >= _endTime)
        {
            if (_value == _end)
            {
                // Intentionally wait a cycle efore returning true, allowing 
                // tween to show as being at end, also helps multiple effects 
                // timed together to update cleanly.
                return true;
            }
            Value = _end;
        }
        else
        {
            Value = _easingFunct(_updateTime - _startTime, _start, _range, _duration);
        }

        return false;
    }

    protected override void SnapToEnd()
    {
        _endTime = _updateTime;
        Value = _end;
    }

    public override void Cycle() 
    {
        // start the tween over
        Recalibrate(_start, _end, _duration, _easingFunct);
    }

    public override void Reverse() 
    {
        // reverse the tween
        Recalibrate(_end, _start, _duration, _easingFunct);
    }

    //
    // Getters and Setters
    //

    public virtual float Value
    {
        get { return _value; }
        set { _value = value; }
    }

    public float Start
    {
        get { return _start; }
        set { Recalibrate(value, _end, _duration, _easingFunct); }
    }

    public float End
    {
        get { return _end; }
        set { Recalibrate(_start, value, _duration, _easingFunct); }
    }

    public float Duration
    {
        get { return _duration; }
        set { Recalibrate(_start, _end, value, _easingFunct); }
    }

    public float Range
    {
        get { return _range; }
    }

    public float EndTime
    {
        get { return _endTime; }
    }
}
