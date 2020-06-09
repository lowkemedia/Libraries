//
//  ParabolaEasing v 1.1.1 - animator package
//  Russell Lowke, June 1st 2011
//
//  Copyright (c) 2010-2011 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke-animator/ for code repository
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

package com.lowke.animator.effect.tween.easing
{   
    public class ParabolaEasing 
    {   
        //
        // member variables
        private var _initialized:Boolean;
        private var _begin:Number;                  // beginning value
        private var _ctrlTimePerc:Number;           // percentage control time for curve easing
        private var _ctrlValuePerc:Number;          // percentage control value for curve easing
        private var _ctrlTime:Number;               // control time for curve easing
        private var _ctrlValue:Number;              // control value for curve easing
        private var _a:Number;                      // precalculated constants used by curve fitting algorithm
        private var _b:Number;
        
        // ctrlTime overrides ctrlTimePerc if used
        // ctrlValue overrides ctrlValuePerc if used
        public function ParabolaEasing(ctrlValuePerc:Number = 0.75,     // defaults to easeOut
                                       ctrlTimePerc:Number = 0.5,       //  be 75% done at half time.
                                       ctrlValue:Number = NaN, 
                                       ctrlTime:Number = NaN)
        {
            _ctrlValuePerc = ctrlValuePerc;
            _ctrlTimePerc = ctrlTimePerc;
            _ctrlValue = ctrlValue;
            _ctrlTime = ctrlTime;
        }
        
        private function initialize(begin:Number, 
                                    range:Number, 
                                    duration:Number):void 
        {
            if (! _ctrlValue) 
            {
                _ctrlValue = begin + range*_ctrlValuePerc;
            }
            
            if (! _ctrlTime) 
            {
                _ctrlTime = duration*_ctrlTimePerc;
            }
            
            _begin = begin;
            
            // precalculate constants used by curve fitting algorithm
            var m1_2:Number = gradient(_ctrlValue - _begin, _ctrlTime);
            var m1_3:Number = gradient((_begin + range) - _begin, duration);
            _a = (m1_2 - m1_3)/(_ctrlTime - duration);
            _b = m1_2 - _a*(_ctrlTime);
            
            _initialized = true;
        }
        
        public function ease(time:Number,
                             begin:Number, 
                             range:Number, 
                             duration:Number):Number 
        {
            if (! _initialized) 
            {
                initialize(begin, range, duration);
            }
            
            // fit a parabola using polynomial equation of the second degree,
            //    y = ax^2 + bx + c.
            //
            // Where y is the return value and x is time.
            
            return _a*time*time + _b*time + _begin;
        }
        
        // NOTE: Never send the same ease instance to two different tweens!
        public static function get easeOut():Function
        {
            return ease(0.75, 0.5);     // be 75% done at half time
        }
        
        public static function get easeIn():Function
        {
            return ease(0.25, 0.5);     // be 25% done at half time
        }
        
        public static function get bounceAtStart():Function
        {
            return ease(0.35, 0.7);     // be 35% done at 70% time, this causes a "bounce" due to curve fitting.
        }
        
        public static function ease(ctrlValuePerc:Number,                   // percent done
                                    ctrlTimePerc:Number = 0.5):Function     //  at time, defaults to 50%
        {
            return new ParabolaEasing(ctrlValuePerc, ctrlTimePerc).ease;
        }
        
        
        public static function easeCtrl(ctrlValue:Number = NaN,             // be this value
                                        ctrlTime:Number = NaN):Function     //  at this time
        {
            return new ParabolaEasing(NaN, NaN, ctrlValue, ctrlTime).ease;
        }
        
        
        /**
         * @return Return gradient/slope (m) from a rise and run. m = rise/run.
         */
        private static function gradient(rise:Number, 
                                         run:Number):Number 
        {
            if (rise == 0) 
            {
                return 0;
            } 
            else if (run == 0) 
            {
                return rise;  // infinity
            } 
            else 
            {
                return rise/run;
            }
        }
    }
}
