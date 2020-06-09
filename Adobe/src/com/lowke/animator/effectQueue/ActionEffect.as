//
//  ActionEffect v 1.0 - effectQueue package
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
    import com.lowke.actionQueue.Action;
    import com.lowke.actionQueue.IAction;
    import com.lowke.animator.Animator;
    import com.lowke.animator.effect.IAnimatorEffect;
    
    import flash.events.IEventDispatcher;
    
    public class ActionEffect extends Action implements IAction
    {
        private static const DEFAULT_TIME_OUT:uint = 0; // ActionEffects default as having no timeout
        public static const ANIMATOR_EFFECT_ACTION:String = "animatorEffectAction";
        
        private static var _animator:Animator = Animator.instance;
        
        private var _target:IEventDispatcher;
        private var _effect:IAnimatorEffect;
        private var _markAsFinishedWhenActionStarts:Boolean;
        
        public function ActionEffect(target:IEventDispatcher,
                                     effect:IAnimatorEffect,
                                     markAsFinishedWhenActionStarts:Boolean = false, 
                                     timeOut:uint = DEFAULT_TIME_OUT)       
        {
            super(ANIMATOR_EFFECT_ACTION, timeOut);
            
            _target = target;
            _effect = effect;
            _markAsFinishedWhenActionStarts = markAsFinishedWhenActionStarts;
        }
        
        public override function playAction():void
        {
            var effect:IAnimatorEffect = _animator.anime(_target).addEffect(_effect);
            if (_markAsFinishedWhenActionStarts) 
            {
                finishAction();
            } 
            else 
            {
                effect.whenDone(finishAction);
            }
        }
    }
}