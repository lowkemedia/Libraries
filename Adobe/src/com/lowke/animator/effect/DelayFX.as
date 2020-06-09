//
//  DelayFX v 1.5 - animator package
//  Russell Lowke, August 17th 2009
//
//  Copyright (c) 2009 Lowke Media
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
//  DelayFX can be used as a generic effect and does not need a specific target 
//  DisplayObject.
//
//      Animator.instance.generic.addEffect(new DelayFX(delay), funct);
//
//  If used as a generic effect it's wise to set the AUTO_RENAME flag, so it 
//  doesn't conflict with other DelayFX effects.
//
//      Animator.instance.generic.nameEffect(new DelayFX(delay), Animator.AUTO_RENAME, funct);
//
//  Sometimes it's wiser to have DelayFX attached to a DisplayObject, often 
//  making the AUTO_RENAME unnecessary.
//
//

package com.lowke.animator.effect
{
    import com.lowke.animator.Animator;
    
    public class DelayFX extends AnimatorEffect implements IAnimatorEffect 
    {   
        //
        // member variables
        private var _delay:uint;                // duration of delay in milliseconds
        private var _trigger:uint;              // time at which to trigger the function
        
        // accessing an external static references, such as Animator, has an overhead,
        //  so, for performance sake, external vars are substituted with local references
        public static const TYPE_END:uint           = Animator.TYPE_END;
        public static const PRECEDENCE_FIRST:int    = Animator.PRECEDENCE_FIRST;
        public static const INTERVAL_NONE:uint      = Animator.INTERVAL_NONE;
        
        
        public function DelayFX(delay:uint) 
        {   
            super("DelayFX", TYPE_END, PRECEDENCE_FIRST, INTERVAL_NONE);
            
            _delay = delay;
        }
        
        
        public override function activate():void 
        {
            _trigger = _startTime + _delay;
        }
        
        public override function update():Boolean 
        {   
            if (_updateTime >= _trigger) 
            {
                return true;
            } 
            else 
            {
                return false;
            }
        }
    }
}