//
//  VelocityXYFX v 1.4 - animator package
//  Russell Lowke, April 11th 2011
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
    
    import flash.display.DisplayObject;
    import flash.geom.Point;
    
    public class VelocityXYFX extends AnimatorEffect implements IAnimatorEffect 
    {
        private var _dObj:DisplayObject;        // _target cast as a display object
        private var _vel:Point;
        
        private var _valueX:Number;             // keep a real version of x and y
        private var _valueY:Number;             //  as Flash will round precision
        
        
        // accessing an external static references, such as Animator, has an overhead,
        //  so, for performance sake, external vars are substituted with local references
        public static const TYPE_PERSIST:uint       = Animator.TYPE_PERSIST;
        public static const PRECEDENCE_SECOND:int   = Animator.PRECEDENCE_SECOND;
        public static const INTERVAL_NONE:uint      = Animator.INTERVAL_NONE;
        
        
        //
        //  Animate to point x,y at set velocity as measured in pixels per millisecond
        public function VelocityXYFX(velX:Number,
                                     velY:Number) 
        {   
            super("VelocityFX", TYPE_PERSIST, PRECEDENCE_SECOND, INTERVAL_NONE);
            
            _vel = new Point(velX, velY);
        }
        
        public override function activate():void 
        {
            _dObj = _target as DisplayObject;
            _valueX = _dObj.x;
            _valueY = _dObj.y;
        }
        
        public override function update():Boolean 
        {
            // add velocity
            xValueTo(_valueX + _vel.x*_timePassed);
            yValueTo(_valueY + _vel.y*_timePassed);
            
            return false;
        }
        
        //
        // used for stacking tweens
        public function xValueTo(n:Number):void 
        {   
            // Change target variable only by the change in n
            // This way tween effects can stack, even though they target the same variable
            var nValue:Number = _dObj.x + (n - _valueX);
            _dObj.x = nValue;
            
            // Flash introduces a rounding error with variables such as x, y, and alpha
            // This error needs to be factored in
            var err:Number = _dObj.x - nValue;
            _valueX = n + err;
        }
        
        public function yValueTo(n:Number):void 
        {   
            // Change target variable only by the change in n
            // This way tween effects can stack, even though they target the same variable
            var nValue:Number = _dObj.y + (n - _valueY);
            _dObj.y = nValue;
            
            // Flash introduces a rounding error with variables such as x, y, and alpha
            // This error needs to be factored in
            var err:Number = _dObj.y - nValue;
            _valueY = n + err;
        }
        
        public function get vel():Point                 { return _vel; }
        public function get velX():Number               { return _vel.x; }
        public function get velY():Number               { return _vel.y; }
        public function set vel(val:Point):void         { _vel.x = val.x;  _vel.y = val.y; }
        public function set velX(val:Number):void       { _vel.x  = val; }
        public function set velY(val:Number):void       { _vel.y  = val; }
    }
}