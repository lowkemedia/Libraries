//
//  TweenXYAtFX v 1.6 - animator package
//  Russell Lowke, March 30th 2011
//
//  Copyright (c) 2009-2011 Lowke Media
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

package com.lowke.animator.effect.tween
{   
    import com.lowke.animator.Animator;
    import com.lowke.animator.effect.AnimatorEffect;
    import com.lowke.animator.effect.IAnimatorEffect;
    import com.lowke.animator.effect.MultiEffectFX;
    import com.lowke.animator.effect.tween.easing.NoEasing;
    
    public class TweenXYAtFX extends AnimatorEffect implements IAnimatorEffect 
    {   
        private var _endX:Number;                   // end value of variable 1
        private var _endY:Number;                   // end value of variable 2
        private var _velocity:Number;               // velocity to the destination
        private var _duration:uint;                 // duration of tween in milliseconds
        private var _xEasingFunct:Function;          // easing function
        private var _yEasingFunct:Function;          // easing function
        private var _stackTween:Boolean;            // true if tweens should stack with others
        private var _multiEffect:MultiEffectFX;     // the actual effect doing the work
        
        // accessing an external static references, such as Animator, has an overhead,
        //  so, for performance sake, external vars are substituted with local references
        public static const TYPE_END:uint           = Animator.TYPE_END;
        public static const PRECEDENCE_FIRST:int    = Animator.PRECEDENCE_FIRST;
        public static const INTERVAL_NONE:uint      = Animator.INTERVAL_NONE;
        
        
        //
        //  Animate to point x,y at set velocity as measured in pixels per millisecond
        public function TweenXYAtFX(endX:Number,
                                    endY:Number,
                                    velocity:Number,
                                    xEasingFunct:Function = null,
                                    yEasingFunct:Function = null,
                                    stackTween:Boolean = false,
                                    type:uint = TYPE_END) 
        {   
            super("TweenXYAtFX", type, PRECEDENCE_FIRST, INTERVAL_NONE);
            
            _endX = endX;
            _endY = endY;
            _velocity = velocity;
            _stackTween = stackTween;
            
            // default easing to NoEasing.easeNone
            if (xEasingFunct == null) 
            {
                xEasingFunct = NoEasing.easeNone;
            } 
            
            if (yEasingFunct == null) 
            {
                yEasingFunct = NoEasing.easeNone;
            } 
            
            _xEasingFunct = xEasingFunct;
            _yEasingFunct = yEasingFunct;
            
        }
        
        public override function activate():void 
        {   
            _duration = distance(_target["x"], _target["y"], _endX, _endY)/_velocity;
            var effects:Vector.<IAnimatorEffect> = new Vector.<IAnimatorEffect>;
            effects.push(new TweenFX("x", NaN, _endX, _duration, _xEasingFunct, _stackTween, type));
            effects.push(new TweenFX("y", NaN, _endY, _duration, _yEasingFunct, _stackTween, type));
            _multiEffect = new MultiEffectFX(effects, "xyAt", _type);
            _anime.addEffect(_multiEffect);
        }
        
        public override function cleanup():void 
        {
            _anime.removeEffect(_multiEffect, false, false);
        }
        
        public override function update():Boolean 
        {
            return _multiEffect.done;
        }
        
        public override function snapToEnd():void 
        {
            _multiEffect.snapToEnd();
        }
        
        // these effects supported by Tween
        public override function cycle():void       {}
        public override function reverse():void     {}
        public override function pause():void       {}
        public override function unpause():void     {}
        
        //
        // distance between x1, y1 and x2, y2
        public static function distance(x1:Number, 
                                        y1:Number, 
                                        x2:Number, 
                                        y2:Number):Number 
        {
            return Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
        }
        
        // print name of effect
        public override function toString():String 
        {
            return _name + " (x:" + _endX + ", y:" + _endY + ", vel:" + _velocity + ")"; 
        }
        
        public function get duration():uint         { return _duration; }
        public function get x():Number              { return (_multiEffect.effects[0] as TweenFX).value; }
        public function get y():Number              { return (_multiEffect.effects[1] as TweenFX).value; }
    }
}