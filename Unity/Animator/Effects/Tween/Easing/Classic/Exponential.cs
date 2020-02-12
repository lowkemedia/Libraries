//
//  Exponential - Animator package
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

public static class Exponential
{
    // starts motion slowly, and then accelerates motion as it executes. 
    public static float EaseIn(float time, 
                               float begin,
                               float range,
                               float duration)
    {
        return time == 0 ? begin : range* (float)Math.Pow(2, 10 * (time / duration - 1)) + begin;
    }

    // starts motion fast, and then decelerates motion as it executes. 
    public static float EaseOut(float time, 
                                float begin,
                                float range, 
                                float duration)
    {
        return time == duration? begin + range : range* (-(float)Math.Pow(2, -10 * time / duration) + 1) + begin;
    }
        
    // combines the motion of the EaseIn() and EaseOut() methods
    // to start the motion slowly, accelerate motion, then decelerate. 
    public static float EaseInOut(float time, 
                                  float begin,
                                  float range,
                                  float duration)
    {
        if (time == 0) {
            return begin;
        }

        if (time == duration) {
            return begin + range;
        }

        if ((time /= duration / 2) < 1) {
            return range / 2 * (float)Math.Pow(2, 10 * (time - 1)) + begin;
        }
        
        return range / 2 * (-(float)Math.Pow(2, -10 * --time) + 2) + begin;
    }
}
