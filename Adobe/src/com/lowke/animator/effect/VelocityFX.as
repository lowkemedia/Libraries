//
//  VelocityFX v 1.5 - animator package
//  Russell Lowke, September 8th 2011
//
//  Copyright (c) 2008-2011 Lowke Media
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

package com.lowke.animator.effect
{   
    import com.lowke.animator.Animator;
    
    public class VelocityFX extends AnimatorEffect implements IAnimatorEffect 
    {
        private var _variable:String;                   // name of variable being changed
        private var _velocity:Number;                   // velocity variable being changed at
        private var _minimum:Number;                    // minimum value of variable
        private var _maximum:Number;                    // maximum value of variable
        private var _value:Number;                      // value of variable being changed
        private var _stack:Boolean = false;             // if true effect will stack with others
        
        
        // accessing an external static references, such as Animator, has an overhead,
        //  so, for performance sake, external vars are substituted with local references
        public static const TYPE_END:int            = Animator.TYPE_END;
        public static const PRECEDENCE_SECOND:int   = Animator.PRECEDENCE_SECOND;
        public static const INTERVAL_NONE:uint      = Animator.INTERVAL_NONE;
        
        
        //
        //  Animate variable at set velocity as measured in pixels per millisecond
        public function VelocityFX(variable:String, 
                                   velocity:Number, 
                                   minimum:Number = NaN,
                                   maximum:Number = NaN,
                                   stack:Boolean = false,
                                   type:int = TYPE_END)
        {   
            super("VelocityFX", type, PRECEDENCE_SECOND, INTERVAL_NONE);
            
            _variable = variable;
            _velocity = velocity;
            _minimum = minimum;
            _maximum = maximum;
            _stack = stack;
        }
        
        public override function activate():void 
        {
            _value = _target[_variable];
        }
        
        public override function update():Boolean 
        {
            // add velocity
            var value:Number = _value + _velocity*_timePassed;
            changeValue(value);
            
            // if outside bounds return true
            if ( (! isNaN(_minimum) && _value < _minimum) ||
                (! isNaN(_maximum) && _value > _maximum)) 
            {
                return true;
            }
            
            return false;
        }
        
        public override function cycle():void 
        {
            // start over
            if (_value > _maximum) 
            {
                changeValue(_minimum);
            } 
            else if (_value < _minimum) 
            {
                changeValue(_maximum);
            }
        }
        
        public override function reverse():void 
        {
            // reverse direction
            if (_value > _maximum) 
            {
                changeValue(_maximum);
            } 
            else if (_value < _minimum) 
            {
                changeValue(_minimum);
            }
            
            _velocity = -_velocity;
        }
        
        private function changeValue(value:Number):void
        {
            if (_stack) 
            {
                valueTo(value);
            } 
            else 
            {
                _target[_variable] = value;
                _value = value;
            }
        }
        
        //
        // used for stacking
        public function valueTo(n:Number):void 
        {   
            // Change target variable only by the change in n
            // This way tween effects can stack, even though they target the same variable
            var nValue:Number = _target[_variable] + (n - _value);
            _target[_variable] = nValue;
            
            // Flash introduces a rounding error with variables such as x, y, and alpha
            // This error needs to be factored in
            var err:Number = _target[_variable] - nValue;
            _value = n + err;
        }
        
        public function get velocity():Number               { return _velocity; }
        public function get maximum():Number                { return _maximum; }
        public function get minimum():Number                { return _minimum; }
        
        public function set velocity(value:Number):void     { _velocity = value; }
        public function set maximum(value:Number):void      { _maximum = value; }
        public function set minimum(value:Number):void      { _minimum = value; }
    }
}