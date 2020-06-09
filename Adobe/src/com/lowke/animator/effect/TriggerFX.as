//
//  TriggerFX v 1.0 - animator package
//  Russell Lowke, October 20th 2010
//
//  Copyright (c) 2010 Lowke Media
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
    
    public class TriggerFX extends AnimatorEffect implements IAnimatorEffect 
    {   
        //
        // member variables
        private var _variable:String;               // variable to test for
        private var _value:Number;                  // value to be tested for against
        private var _greaterThan:Boolean = true;    // true then testing for greater than value, otherwise less than
        
        // accessing an external static references, such as Animator, has an overhead,
        //  so, for performance sake, external vars are substituted with local references
        public static const TYPE_END:uint           = Animator.TYPE_END;
        public static const PRECEDENCE_LAST:int     = Animator.PRECEDENCE_LAST;
        public static const INTERVAL_NONE:uint      = Animator.INTERVAL_NONE;
        
        public function TriggerFX(variable:String,
                                  value:Number,
                                  greaterThan:Boolean = true)
        {   
            super("TriggerFX", TYPE_END, PRECEDENCE_LAST, INTERVAL_NONE);
            
            _variable = variable;
            _value = value;
            _greaterThan = greaterThan;
        }
        
        public override function update():Boolean 
        {   
            if ( (_greaterThan && _target[_variable] > _value) ||
                (! _greaterThan && _target[_variable] < _value)) 
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