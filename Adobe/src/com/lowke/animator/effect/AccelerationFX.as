//
//  AccelerationFX v 1.2 - animator package
//  Russell Lowke, August 7th 2008
//
//  Copyright (c) 2008 Lowke Media
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
    
    import flash.geom.Point;
    
    public class AccelerationFX extends AnimatorEffect implements IAnimatorEffect 
    {
        private var _acc:Point;                     // duration of the tween
        private var _velocityTarget:VelocityXYFX;   // target object of effect type Velocity
        
        // accessing an external static references, such as Animator, has an overhead,
        //  so, for performance sake, external vars are substituted with local references
        public static const TYPE_PERSIST:uint       = Animator.TYPE_PERSIST;
        public static const PRECEDENCE_FIRST:int    = Animator.PRECEDENCE_FIRST;
        public static const INTERVAL_NONE:uint      = Animator.INTERVAL_NONE;
        
        //
        //  Animate to point x,y at set velocity as measured in pixels per millisecond
        public function AccelerationFX(acc:Point) 
        {   
            super("AccelerationFX", TYPE_PERSIST, PRECEDENCE_FIRST, INTERVAL_NONE);
            
            _acc = acc;
        }
        
        public override function activate():void 
        {   
            if (_target is VelocityFX) 
            {
                _velocityTarget = _target as VelocityXYFX;
            } 
            else 
            {
                _velocityTarget = _anime.getEffect("Velocity") as VelocityXYFX;
                if (! _velocityTarget)
                {
                    throw new Error("Acceleration effect needs a Velocity effect as a target");
                }
            }
        }
        
        public override function update():Boolean 
        {   
            // add acceleration
            _velocityTarget.vel.x += _acc.x*_timePassed;
            _velocityTarget.vel.y += _acc.y*_timePassed;
            
            return false;
        }
        
        public function get acc():Point                 { return _acc; }
        public function get accX():Number               { return _acc.x; }
        public function get accY():Number               { return _acc.y; }
        public function set acc(val:Point):void         { _acc.x = val.x;  _acc.y = val.y; }
        public function set accX(val:Number):void       { _acc.x = val; }
        public function set accY(val:Number):void       { _acc.y = val; }
    }
}