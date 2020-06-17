//
//  ParabolaEasing v 2.0 - animator package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2011-2019 Lowke Media
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

public class Parabola
{
    //
    // member variables
    private float _begin;                   // beginning value
    private readonly float _ctrlTimePerc;   // percentage control time for curve easing
    private readonly float _ctrlValuePerc;  // percentage control value for curve easing
    private float _ctrlTime;                // control time for curve easing
    private float _ctrlValue;               // control value for curve easing
    private float _a = float.NaN;           // precalculated constants used by curve fitting algorithm
    private float _b;
    
    // ctrlTime overrides ctrlTimePerc if used
    // ctrlValue overrides ctrlValuePerc if used
    public Parabola(float ctrlValuePerc = 0.75f,        // defaults to EaseOut
                    float ctrlTimePerc = 0.5f,    //  be 75% done at half time.
                    float ctrlValue = float.NaN,
                    float ctrlTime = float.NaN)
    {
        _ctrlValuePerc = ctrlValuePerc;
        _ctrlTimePerc = ctrlTimePerc;
        _ctrlValue = ctrlValue;
        _ctrlTime = ctrlTime;
    }

    private void Recalibrate(float begin,
                             float range,
                             float duration) 
    {
        if (float.IsNaN(_ctrlValue)) {
            _ctrlValue = begin + range * _ctrlValuePerc;
        }
        
        if (float.IsNaN(_ctrlTime)) {
            _ctrlTime = duration * _ctrlTimePerc;
        }
        
        _begin = begin;

        // precalculate constants used by curve fitting algorithm
        float m1_2 = Gradient(_ctrlValue - _begin, _ctrlTime);
        float m1_3 = Gradient((_begin + range) - _begin, duration);
        _a = (m1_2 - m1_3)/(_ctrlTime - duration);
        _b = m1_2 - _a* (_ctrlTime);
    }

    // Return gradient/slope (m) from a rise and run. m = rise/run.
    private static float Gradient(float rise,
                                  float run)
    {
        if (rise == 0.0f) {
            return 0;
        }

        if (run == 0.0f) {
            return rise;  // infinity
        }

        return rise / run;
    }

    public float Ease(float time,
                      float begin,
                      float range,
                      float duration) 
    {
        if (float.IsNaN(_a) || time == 0) {
            Recalibrate(begin, range, duration);
        }
        
        // fit a parabola using polynomial equation of the second degree,
        //    y = ax^2 + bx + c.
        //
        // Where y is the return value and x is time.
        
        return _a * time * time + _b * time + _begin;
    }



    //
    // NOTE: Don't send the same EasingFunct instance to two different tween effects
    //

    public static EasingFunct GetEasing(float ctrlValuePerc,        // percent tween value will be at,
                                        float ctrlTimePerc = 0.5f)  //  at specific time percentage (defaults at 50%)
    {
        return new Parabola(ctrlValuePerc, ctrlTimePerc).Ease;
    }

    public static EasingFunct GetEasingCtrl(float ctrlValue,        // tween will be at ctrlValue value
                                            float ctrlTime)         //  at ctrlTime specific time percentage
    {
        return new Parabola(float.NaN,float.NaN, ctrlValue, ctrlTime).Ease;
    }

    //
    // Example heper methods
    //

    public static EasingFunct EaseIn
    {
        get {
            return GetEasing(0.25f, 0.5f);     // be 25% done at half time.
        }
    }

    public static EasingFunct EaseOut
    {
        get {
            return GetEasing(0.75f, 0.5f);     // be 75% done at half time.
        }
    }
    
    public static EasingFunct EaseBounce
    {
        get {
            return GetEasing(0.35f, 0.7f);     // be 35% done at 70% time, this causes a "bounce" due to curve fitting.
        }
    }
}