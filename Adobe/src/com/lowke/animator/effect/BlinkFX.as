//
//  BlinkFX v 1.0 - animator package
//  Russell Lowke, April 29th 2009
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

package com.lowke.animator.effect
{
    import com.lowke.animator.Animator;
    
    public class BlinkFX extends AnimatorEffect implements IAnimatorEffect 
    {   
        //
        // member variables
        private var _variable:String;       // name of variable being changed
        private var _onValue:*;             // value variable set to while bliking "on"
        private var _onDuration:uint;       // duration variable blinks "on"
        private var _offValue:*;            // value variable set to while bliking "off"
        private var _offDuration:uint;      // duration variable blinks "off"
        private var _isOn:Boolean;          // if true then blink is in the "on" cycle
        private var _trigger:uint;          // time at which to switch cycles
        private var _nBliks:int;            // # times to blink before ending, 0 indicates infinite
        private var _endAsOn:Boolean;       // if true blibk ends on the "on" cycle
        
        // accessing an external static references, such as Animator, has an overhead,
        //  so, for performance sake, external vars are substituted with local references
        public static const TYPE_END:uint           = Animator.TYPE_END;
        public static const PRECEDENCE_FIRST:int    = Animator.PRECEDENCE_FIRST;
        public static const INTERVAL_NONE:uint      = Animator.INTERVAL_NONE;
        
        public function BlinkFX(variable:String,
                                onValue:*,
                                onDuration:uint,
                                offValue:*,
                                offDuration:uint,
                                nBliks:int = -1,
                                endAsOn:Boolean = false) 
        {   
            super("BlinkFX", TYPE_END, PRECEDENCE_FIRST, INTERVAL_NONE);
            
            _variable    = variable;
            _onValue     = onValue;
            _onDuration  = onDuration;
            _offValue    = offValue;
            _offDuration = offDuration;
            _nBliks      = nBliks;
            _endAsOn     = endAsOn;
        }
        
        
        public override function activate():void 
        {   
            _trigger = _startTime;
            
            // determine if "on" or "off"
            if (_target[_variable] == _onValue) 
            {
                _isOn = true;
            } 
            else 
            {
                _isOn = false;
            }
        }
        
        public override function update():Boolean 
        {   
            if (_updateTime >= _trigger) 
            {
                // switch the cycle
                _isOn = ! _isOn;
                
                // set the target variable
                _target[_variable] = _isOn ? _onValue : _offValue;
                
                // update the trigger
                _trigger += _isOn ? _onDuration : _offDuration;
                
                // check for blink count
                if (_nBliks >= 0 && (_endAsOn ? _isOn : ! _isOn)) 
                {
                    --_nBliks;
                }
                
                if (_nBliks < 0) 
                {
                    return true;
                }
            }
            return false;
        }
        
        public override function snapToEnd():void 
        {
            _nBliks = -1;
            _target[_variable] = _endAsOn ? _onValue : _offValue;
        }
        
        public override function cleanup():void 
        {   
            if (_endAsOn) 
            {
                _target[_variable] = _onValue;
            } 
            else 
            {
                _target[_variable] = _offValue;
            }
        }
    }
}