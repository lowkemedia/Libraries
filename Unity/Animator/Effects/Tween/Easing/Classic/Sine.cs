//
//  Sine - Animator package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2006-2019 Lowke Media
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

using System;

public static class Sine
{
    private const float HALF_PI = (float)Math.PI/2;

    // starts motion from zero velocity, 
    // and then accelerates motion as it executes.
    public static float EaseIn(float time, 
                               float begin,
                               float range, 
                               float duration)
    {
        return -range * (float)Math.Cos(time / duration * HALF_PI) + range + begin;
    }

    // starts motion fast, 
    // and then decelerates motion to a zero velocity as it executes. 
    public static float EaseOut(float time, 
                                float begin,
                                float range, 
                                float duration)
    {
        return range * (float)Math.Sin(time / duration * HALF_PI) + begin;
    }

    // combines the motion of the EaseIn() and EaseOut()
    // to start the motion from a zero velocity, accelerate motion,
    // then decelerate to a zero velocity. 
    public static float EaseInOut(float time, 
                                  float begin,
                                  float range,
                                  float duration)
    {
        return -range / 2 * ((float)Math.Cos(Math.PI * time / duration) - 1) + begin;
    }
}
