//
//  Action v 2.0 - actionQueue package
//  Russell Lowke, December 18th 2011
//
//  Copyright (c) 2010-2011 Lowke Media
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

package com.lowke.actionQueue
{
    import com.lowke.Delayer;
    import com.lowke.actionQueue.event.ActionFinishedEvent;
    import com.lowke.logger.Logger;
    
    import flash.events.EventDispatcher;
    
    /* Base class for actions, called actions to avoid confusion with Flash Events */
    public class Action extends EventDispatcher implements IAction
    {   
        public static const DEFAULT_TIME_OUT:uint = 0;  // default time in miliseconds before action declared as timed out
        private var _actionType:String;                 // optional action type, can be used to identify the action
        private var _processed:Boolean = false;         // flag indicating that this action has been processed
        private var _timeOutDelay:Delayer;                // delay used to check for unresolved actions
        
        
        public function Action(actionType:String = null, 
                               timeOut:uint = DEFAULT_TIME_OUT)
        {
            _actionType = actionType;
            if (timeOut) 
            {
                _timeOutDelay = Delayer.delay(timeOut, timeoutError);
            }
        }
        
        private function timeoutError():void
        {
            Logger.warning("Action " + this + " timed out after " + DEFAULT_TIME_OUT + " milliseconds.", ActionQueue.WARNING_ACTION_TIMED_OUT);
            finishAction();
        }
        
        // play action is intened to be extended
        public function playAction():void
        {
            throw new Error("playAction() method must be overwritten");
        }
        
        public function removeTimeOut():void
        {
            if (_timeOutDelay) 
            {
                _timeOutDelay.close();
            }
        }
        
        public function finishAction():void
        {
            removeTimeOut();
            dispatchEvent(new ActionFinishedEvent(ActionFinishedEvent.ACTION_FINISHED));
        }
        
        public function get actionType():String             { return _actionType; }
        public function get processed():Boolean             { return _processed; }
        
        public function set processed(val:Boolean):void     { _processed = val; }
        
    }
}