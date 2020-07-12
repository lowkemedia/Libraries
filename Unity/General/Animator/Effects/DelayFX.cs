//
//  DelayFX v 2.0 - Animator package
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

public class DelayFX : AnimatorEffect
{
    private readonly float _delay;           // duration of delay
    private float _triggerTime;              // time at which to trigger the function

    public DelayFX(float delay, EffectType type = EffectType.END) : 
    base("DelayFX", type)
    {
        _delay = delay;
    }

    protected override void Initialize()
    {
        _triggerTime = _startTime + _delay;
    }

    protected override bool Update()
    {
        if (_updateTime >= _triggerTime)
        {
            // incement _triggerTime in case effect persists or similar
            _triggerTime += _delay;
            return true;
        }

        return false;
    }

    protected override void SnapToEnd()
    {
        _triggerTime = _updateTime;
    }
}
