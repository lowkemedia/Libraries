//
//  Elastic - Animator package
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

using System;

public static class Elastic
{
    // starts motion slowly, and then accelerates motion as it executes. 
    public static float EaseIn(float time, 
                               float begin,
                               float range, 
                               float duration,
                               float amplitude = 0,         // amplitude of the sine wave.
                               float period = 0)            // period of the sine wave
    {
        if (time == 0) {
            return begin;
        }
    
        if ((time /= duration) == 1) {
            return begin + range;
        }
              
        if (period == 0) {
            period = duration * 0.3f;
        }
        
        float s;
        if (amplitude == 0 || amplitude<Math.Abs(range))
        {
            amplitude = range;
            s = period / 4;
        } else {
            s = period / (2 * (float)Math.PI) * (float)Math.Asin(range / amplitude);
        }
            
        return -(amplitude* (float)Math.Pow(2, 10 * (time -= 1)) *
               (float)Math.Sin((time* duration - s) * (2 * Math.PI) / period)) + begin;
    }
        
    // starts motion fast, and then decelerates motion as it executes. 
    public static float EaseOut(float time, 
                                float begin,
                                float range, 
                                float duration,
                                float amplitude = 0,        // amplitude of the sine wave.
                                float period = 0)           // period of the sine wave
    {
        if (time == 0) {
            return begin;
        }

        if ((time /= duration) == 1) { 
            return begin + range; 
        }

        if (period == 0) {
            period = duration * 0.3f;
        }
        
        float s;
        if (amplitude == 0 || amplitude<Math.Abs(range))
        {
            amplitude = range;
            s = period / 4;
        } else {
            s = period / (2 * (float)Math.PI) * (float)Math.Asin(range / amplitude);
        }
            
        return amplitude* (float)Math.Pow(2, -10 * time) *
               (float)Math.Sin((time* duration - s) * (2 * Math.PI) / period) + range + begin;
    }
        
    // combines the motion of the EaseIn() and EaseOut() methods
    // to start the motion slowly, accelerate motion, then decelerate. 
    public static float EaseInOut(float time, 
                                  float begin,
                                  float range, 
                                  float duration,
                                  float amplitude = 0, 
                                  float period = 0)
    {
        if (time == 0) {
            return begin;
        }
            
        if ((time /= duration / 2) == 2) {
            return begin + range;
        }

        if (period == 0) {
            period = duration* (0.3f * 1.5f);
        }

        float s;
        if (amplitude == 0 || amplitude<Math.Abs(range))
        {
            amplitude = range;
            s = period / 4;
        } else {
            s = period / (2 * (float)Math.PI) * (float)Math.Asin(range / amplitude);
        }
        
        if (time< 1) {
            return -0.5f * (amplitude* (float)Math.Pow(2, 10 * (time -= 1)) *
               (float)Math.Sin((time* duration - s) * (2 * Math.PI) /period)) + begin;
        }

        return amplitude* (float)Math.Pow(2, -10 * (time -= 1)) *
            (float)Math.Sin((time* duration - s) * (2 * (float)Math.PI) / period ) * 0.5f + range + begin;
    }
}
