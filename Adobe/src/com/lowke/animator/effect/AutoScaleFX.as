//
//  AutoScaleFX v 1.0.1 - animator package
//  Russell Lowke, June 1st 2011
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

// AutoScaleFX effect can be used in conjunction with ZOrder effect

package com.lowke.animator.effect
{   
    import com.lowke.animator.Animator;
    
    import flash.display.DisplayObject;
    import flash.geom.Point;
    
    public class AutoScaleFX extends AnimatorEffect implements IAnimatorEffect 
    {
        private var _dObj:DisplayObject;        // _target cast as a display object
        private var _yVanishingPt:Number;       // y value where object dissapears
        private var _yScaleTo1:Number;          // y value where object is drawn at 100%
        private var _scalePt:Point;             // point used for calculating scale
        private var _scale:Number;              // resultant scale
        private var _m:Number;                  // gradient used for scale
        private var _xIsZeroAt:int;             // optional parameter where x equates to 0, and causes x to scale
        private var _scaleModifier:Number;      // general modifier used for scale
        private var _hasZ:Boolean = false;      // true if target has an mZ (pseudo Z) axis
        
        // accessing an external static references, such as Animator, has an overhead,
        //  so, for performance sake, external vars are substituted with local references
        public static const TYPE_PERSIST:uint       = Animator.TYPE_PERSIST;
        public static const PRECEDENCE_LAST:int     = Animator.PRECEDENCE_LAST;
        public static const INTERVAL_NONE:uint      = Animator.INTERVAL_NONE;
        
        //
        //  Scale target based on y location
        public function AutoScaleFX(yVanishingPt:Number,
                                    yScaleTo1:Number,
                                    xAsZeroAt:int = -1,
                                    scaleModifier:Number = 1) 
        {   
            _yVanishingPt  = yVanishingPt;
            _yScaleTo1     = yScaleTo1;
            _scalePt       = new Point(0, yVanishingPt);
            _m             = gradientFromPts(_scalePt, new Point(1, yScaleTo1));
            _scaleModifier = scaleModifier;
            _xIsZeroAt     = xAsZeroAt;
            
            super("AutoScaleFX", TYPE_PERSIST, PRECEDENCE_LAST, INTERVAL_NONE);
        }
        
        
        public override function activate():void 
        {
            _dObj = _target as DisplayObject;
            
            try 
            {
                var testZ:Number = _target["mZ"];
                if (! isNaN(testZ)) 
                {
                    _hasZ = true;
                }
            } catch (err:Error) {}
            
            calcScale();
        }
        
        public override function update():Boolean 
        {   
            calcScale();
            
            // render mX if supplied with an _xIsZeroAt variable 
            if (_xIsZeroAt != -1) 
            {
                _dObj.x = _dObj["mX"]*_scale + _xIsZeroAt;
            }
            
            // render mY and mZ if supplied
            if (_hasZ) 
            {
                _dObj.y = _dObj["mZ"] - _dObj["mY"]*_scale;
            }
            
            // scale to vanishing point
            _dObj.scaleX = _scale;
            _dObj.scaleY = _scale;
            
            return false;
        }
        private function calcScale():void 
        {   
            if (_hasZ) 
            {
                _scale = Math.abs(xOnALine(_dObj["mZ"], _scalePt, _m))*_scaleModifier;
            } 
            else 
            {
                _scale = Math.abs(xOnALine(_dObj.y, _scalePt, _m))*_scaleModifier;
            }
        }
        
        public function get scale():Number 
        {
            return _scale;
        }
        
        //
        // return gradient (m), rise/run
        public static function gradient(rise:Number, run:Number):Number 
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
        
        //
        // returns gradient of a line joining two points
        public static function gradientFromPts(ptA:Point, ptB:Point):Number 
        {
            return gradient(ptB.y - ptA.y, ptB.x - ptA.x);
        }
        
        //
        // return x, given y through point with gradient m
        public static function xOnALine(y:Number, pt:Point, m:Number):Number 
        {
            if (m == 0) 
            {
                return 0; // avoid divide by zero
            } 
            else 
            {
                return pt.x + (y - pt.y)/m;
            }
        }
    }
}