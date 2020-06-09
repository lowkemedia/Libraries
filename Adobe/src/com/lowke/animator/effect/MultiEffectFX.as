//
//  MultiEffectFX v 1.3 - animator package
//  Russell Lowke, October 20th 2010
//
//  Copyright (c) 2009-2010 Lowke Media
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
    
    import flash.utils.getTimer;
    
    public class MultiEffectFX extends AnimatorEffect implements IAnimatorEffect 
    {   
        private var _effects:Vector.<IAnimatorEffect>;      // array of effects
        private var _doneFlags:Vector.<Boolean>;            // array of "done" flags indicating which effects have finished
        private var _done:Boolean = false;                  // indicates all effects finished
        
        // accessing an external static references, such as Animator, has an overhead,
        //  so, for performance sake, external vars are substituted with local references
        public static const TYPE_PERSIST:uint       = Animator.TYPE_PERSIST;
        public static const TYPE_END:uint           = Animator.TYPE_END;
        public static const PRECEDENCE_LATER:int    = Animator.PRECEDENCE_LATER;
        public static const INTERVAL_NONE:uint      = Animator.INTERVAL_NONE;
        
        public function MultiEffectFX(effects:Vector.<IAnimatorEffect>,
                                      name:String = "MultiEffectFX",
                                      type:uint = TYPE_END) 
        {   
            super(name, type, PRECEDENCE_LATER, INTERVAL_NONE);
            _effects  = effects;
        }
        
        public override function activate():void 
        {
            // initialize flags
            _doneFlags = new Vector.<Boolean>;
            
            // all effects should start at the same time!
            var startTime:uint = getTimer();
            
            // add each effect in _effects to the _anime
            var counter:uint = 0;
            for each(var effect:AnimatorEffect in _effects) 
            {
                _anime.nameEffectTS(effect, startTime, _name + "/" + effect.name).whenDone(function():void
                {
                    callFinished(counter++);
                });
                _doneFlags.push(false);
            }
        }

        // to fix issue of closure passing counter by reference
        private function callFinished(counter:int):void
        {
            finished(counter);
        }

        public override function cleanup():void 
        {
            // remove effects in _effects from _anime
            for each(var effect:AnimatorEffect in _effects) 
            {
                _anime.removeEffect(effect, false, false);
            }
        }
        
        // effect finished
        private function finished(effectN:uint):void 
        {
            // flag effect as done
            _doneFlags[effectN] = true;     
            
            // if all effects finished then set _done flag to true
            for each(var doneFlag:Boolean in _doneFlags) 
            {
                if (! doneFlag) 
                {
                    return;
                }
            }
            _done = true;
        }
        
        public override function update():Boolean 
        {
            return _done;
        }
        
        public override function snapToEnd():void 
        {
            for each(var effect:AnimatorEffect in _effects) 
            {
                effect.snapToEnd();
            }
            _done = true;
        }
        
        public override function cycle():void 
        {
            _done = false; 
            _activated = false;
            for each(var effect:AnimatorEffect in _effects) 
            {
                effect.cycle();
            }
        }
        
        public override function reverse():void 
        {
            _done = false; 
            _activated = false;
            for each(var effect:AnimatorEffect in _effects) 
            {
                effect.reverse();
            }
        }
        
        //
        // accessors and mutators
        //
        public function get effects():Vector.<IAnimatorEffect>      { return _effects; }
        public function get doneFlags():Vector.<Boolean>    { return _doneFlags; }
        public function get done():Boolean                  { return _done; }
    }
}