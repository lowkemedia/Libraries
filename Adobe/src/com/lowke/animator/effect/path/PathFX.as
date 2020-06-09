//
//  PathFX v 1.1 - animator package
//  Russell Lowke, March 31st 2011
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

//
//  Usage:
//

package com.lowke.animator.effect.path
{
    import com.lowke.animator.Animator;
    import com.lowke.animator.effect.AnimatorEffect;
    import com.lowke.animator.effect.IAnimatorEffect;
    import com.lowke.animator.effect.path.geometry.NaturalCubic;
    import com.lowke.animator.effect.tween.easing.NoEasing;
    
    import flash.display.DisplayObject;
    import flash.geom.Point;
    
    public class PathFX extends AnimatorEffect implements IAnimatorEffect 
    {   
        //
        // member variables
        private var _naturalCubic:NaturalCubic;     // NaturalCubic class used to calculate path
        private var _points:Vector.<Point>;         // list of points to animate through
        private var _duration:uint;                 // duration of animation
        private var _easingFunct:Function;          // easing function i.e. Sine.easeIn
        private var _closed:Boolean;                // if true then points are a closed path
        private var _steps:int;                     // number of steps calculated between each point
        private var _path:Vector.<Point>;           // resultant path
        private var _totalPoints:uint;              // total number of points (length) of _path
        private var _point:Point;                   // last displayed point
        private var _endTime:uint;                  // end time of animation
        
        
        // accessing an external static references, such as Animator, has an overhead,
        //  so, for performance sake, external vars are substituted with local references
        public static const TYPE_END:uint           = Animator.TYPE_END;
        public static const PRECEDENCE_FIRST:int    = Animator.PRECEDENCE_FIRST;
        public static const INTERVAL_NONE:uint      = Animator.INTERVAL_NONE;
        
        
        public static function bendToLoc(dObj:DisplayObject,
                                         endPt:Point,
                                         duration:uint,
                                         bendDistance:Number,
                                         interpolate:Number = 0.5,
                                         type:uint = TYPE_END):PathFX 
        {
            var startPt:Point = new Point(dObj.x, dObj.y);
            var midPt:Point = Point.interpolate(startPt, endPt, interpolate);
            
            var ctrlPt:Point = new Point(-(endPt.y-startPt.y), (endPt.x-startPt.x));    // start with perpendicular vector
            ctrlPt.normalize(bendDistance);                                             // normalize to bend distance
            ctrlPt = ctrlPt.add(midPt);                                                 // add location of mid point            
            
            var pts:Vector.<Point> = new Vector.<Point>;
            pts.push(startPt, ctrlPt, endPt);
            
            return new PathFX(pts, duration, null, false, 100, type);
        }
        
        
        public function PathFX(points:Vector.<Point>, 
                               duration:uint,
                               easingFunct:Function = null,
                               closed:Boolean = false,
                               steps:int = 100,
                               type:uint = TYPE_END)
        {   
            super("PathFX", type, PRECEDENCE_FIRST, INTERVAL_NONE);
            
            _points = points;
            _duration = duration;
            _closed = closed;
            _steps = steps;
            
            // default easing function to NoEasing.easeNone
            if (easingFunct == null) 
            {
                _easingFunct = NoEasing.easeNone;
            } 
            else 
            {
                _easingFunct = easingFunct;
            }
        }
        
        
        public override function activate():void 
        {
            _naturalCubic = new NaturalCubic(_points, _closed);
            _naturalCubic.steps = _steps;
            _path = _naturalCubic.curveAsPoints;
            _totalPoints = _path.length;
            _endTime = _startTime + _duration;
        }
        
        public override function update():Boolean 
        {   
            var range:uint = _totalPoints - 1;
            if (_updateTime >= _endTime && 
                _point == _path[range]) 
            {
                return true;
            }
            
            var index:Number = _easingFunct(_updateTime - _startTime, 0, range, _duration);
            if (index < 0) 
            {
                index = 0;
            } 
            else if (index > range) 
            {
                index = range;
            }
            
            index = Math.round(index);
            _point = _path[index];
            _target["x"] = _point.x;
            _target["y"] = _point.y;
            
            return false;
        }
        
        public override function cycle():void 
        {
        }
        
        public override function reverse():void 
        {
        }
        
        public function get x():Number { return _point.x; }
        public function get y():Number { return _point.y; }
    }
}