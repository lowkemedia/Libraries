//
//  ActionQueue v 2.2 - actionQueue package
//  Russell Lowke, April 4th 2012
//
//  Copyright (c) 2010-2012 Lowke Media
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
    import com.lowke.actionQueue.actionPlayer.ActionListManager;
    import com.lowke.actionQueue.actionPlayer.ActionsListPlayer;
    import com.lowke.actionQueue.event.ActionQueueFinishedEvent;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    //
    // ActionQueue is a helper class for sending queues to the ActionListManager
    // Multiple ActionQueues can be run at the same time
    //
    
    public class ActionQueue extends EventDispatcher
    {
        //
        // error, warning and ifo IDs
        public static const LOG_PREFIX:String = "QUE";
        public static const WARNING_ACTION_TIMED_OUT:String = "QUE00";
        
        // reference to the ActionListManager singleton
        private static var _actionListManager:ActionListManager = ActionListManager.instance;
        
        private var _autoPlay:Boolean;                                  // if true actions start playing as soon as added
        private var _canceled:Boolean;                                  // flag indicating that this queue has been canceled and it shouldn't dispatch ACTION_QUEUE_FINISHED
        //  adding a new action to the queue will uncancel the queue
        private var _actionsQueue:Vector.<Vector.<IAction>>;            // "array of arrays" of actions to be played
        private var _actionListPlayer:ActionsListPlayer;                // player playing the last batch of actions, will be null if idle
        
        public function ActionQueue(autoPlay:Boolean = true)
        {
            _autoPlay = autoPlay;
        }
        
        // add an action to be played sequentially
        public function addAction(action:IAction):void
        {
            // make an action list wrapper with a single action in it
            var actionList:Vector.<IAction> = new Vector.<IAction>;
            actionList.push(action);
            addSimultaneuosActions(actionList);
        }
        
        // add actions to be played simultaneously
        public function addSimultaneuosActions(actionList:Vector.<IAction>):void
        {
            if (! _actionsQueue) 
            {
                _actionsQueue = new Vector.<Vector.<IAction>>;
            }
            
            _actionsQueue.push(actionList);
            if (_autoPlay) 
            {
                play();
            }
        }
        
        
        /**
         * Note: playing clears the _actionsQueue
         */
        public function play():void
        {
            if (_actionListPlayer) 
            {
                // player already preoccupied playing
                return;
            }
            
            if (_actionsQueue) 
            {
                // send the actions to a an ActionListPlayer to start playing
                _canceled = false;
                _actionListPlayer = _actionListManager.playActions(_actionsQueue, end);
                _actionsQueue = null;
            } 
            else 
            {
                end();
            }
        }
        
        public function end():void
        {
            if (_actionListPlayer) 
            {
                _actionListPlayer.end();
                _actionListPlayer = null;
            }
            
            if (_autoPlay && _actionsQueue) 
            {
                play();
            } 
            else if (! _canceled) 
            {
                dispatchEvent(new ActionQueueFinishedEvent(ActionQueueFinishedEvent.ACTION_QUEUE_FINISHED));
            }
        }
        
        public function cancel():void
        {
            _actionsQueue = null;
            _canceled = true;
            end();
        }
        
        
        /**
         *  close() is consistent with other utilities such as ButtonController and 
         *      PlayFrames, though it's the same as calling cancel()
         */
        public function close():void 
        {
            cancel();
        }
        
        public function whenDone(funct:Function):void
        {   
            if (idle && ! _actionsQueue) 
            {
                // nothing in the queue
                //  use Delayer to trigger callback on the next frame
                Delayer.nextFrame(funct);
            } 
            else 
            {
                // listen for action list finishing
                var listener:Function = function (event:Event):void 
                {
                    removeEventListener(ActionQueueFinishedEvent.ACTION_QUEUE_FINISHED, listener);
                    funct();
                };
                addEventListener(ActionQueueFinishedEvent.ACTION_QUEUE_FINISHED, listener);
            }
        }
        
        
        public function clearActionQueue():void
        {
            _actionsQueue = null;
        }
        
        
        public function get idle():Boolean
        {
            return (_actionListPlayer) ? false : true;
        }
    }
}
