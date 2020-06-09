//
//  EffectQueue v 1.0 - effectQueue package
//  Russell Lowke, February 21st 2012
//
//  Copyright (c) 2012 Lowke Media
//  see http://www.lowkemedia.com for more information
//  see http://code.google.com/p/lowke/ for code repository
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

package com.lowke.animator.effectQueue
{
    import com.lowke.actionQueue.ActionQueue;
    import com.lowke.actionQueue.IAction;
    import com.lowke.animator.effect.IAnimatorEffect;
    
    import flash.events.IEventDispatcher;
    
    public class EffectQueue extends ActionQueue
    {
        public function EffectQueue(autoPlay:Boolean = true)
        {
            super(autoPlay);
        }
        
        public function addEffect(target:IEventDispatcher,
                                  effect:IAnimatorEffect):void
        {
            addAction(createActionEffect(target, effect));
        }
        
        public function addSimultaneousEffects(target:IEventDispatcher,
                                               effects:Vector.<IAnimatorEffect>,
                                               continueQueueWhenFirstEffectDone:Boolean = false):void
        {
            var nEffects:uint = effects.length;
            
            var actionEffects:Vector.<IAction> = new Vector.<IAction>;
            for (var i:uint = 0; i < nEffects; ++i) 
            {
                var effect:IAnimatorEffect = effects[i];
                var finishActionImmediately:Boolean = false;
                if (continueQueueWhenFirstEffectDone && i) 
                {
                    finishActionImmediately = true;
                }
                actionEffects.push(createActionEffect(target, effect, finishActionImmediately));
            }
            addSimultaneuosActions(actionEffects);
        }
        
        
        // factory method for creating ActionEffects
        public static function createActionEffect(target:IEventDispatcher, 
                                                  effect:IAnimatorEffect, 
                                                  masterEffect:Boolean = true):ActionEffect
        {
            return new ActionEffect(target, effect, masterEffect);
        }
        
    }
}