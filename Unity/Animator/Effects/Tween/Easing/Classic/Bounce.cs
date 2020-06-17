//
//  Bounce - Animator package
//  Russell Lowke, October 29th 2019
//
//  Copyright (c) 2006-2019 Lowke Media
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

public static class Bounce
{
    // starts the bounce motion slowly, 
    // and then accelerates motion as it executes. 
    public static float EaseIn(float time,
                               float begin,
                               float range,
                               float duration)
    {
        return range - EaseOut(duration - time, 0, range, duration) + begin;
    }

    // starts the bounce motion fast, 
    // and then decelerates motion as it executes. 
    public static float EaseOut(float time, 
                                float begin,
                                float range, 
                                float duration)
    {
        if ((time /= duration) < (1 / 2.75)) {
            return range * (7.5625f * time * time) + begin;
        }

        if (time < (2 / 2.75)) {
            return range * (7.5625f * (time -= (1.5f / 2.75f)) * time + 0.75f) + begin;
        }

        if (time < (2.5 / 2.75)) {
            return range * (7.5625f * (time -= (2.25f / 2.75f)) * time + 0.9375f) + begin;
        }

        return range * (7.5625f * (time -= (2.625f / 2.75f)) * time + 0.984375f) + begin;
    }
        
    // combines the motion of the EaseIn() and EaseOut() methods
    // to start the bounce motion slowly, accelerate motion, then decelerate. 

    public static float EaseInOut(float time, 
                                  float begin,
                                  float range, 
                                  float duration)
    {
        if (time < duration / 2.0f) {
            return (EaseIn(time * 2.0f, 0, range, duration) * 0.5f + begin);
        }

        return EaseOut(time * 2.0f - duration, 0, range, duration) * 0.5f + range * 0.5f + begin;
    }
}
