//
//  ActionListManager v 2.0 - actionQueue package
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

package com.lowke.actionQueue.actionPlayer
{
    import com.lowke.Delayer;
    import com.lowke.actionQueue.IAction;
    import com.lowke.actionQueue.event.ActionListManagerFinishedEvent;
    import com.lowke.actionQueue.event.ActionsListPlayerFinishedEvent;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    public class ActionListManager extends EventDispatcher
    {   
        // static reference to ActionListManager singleton
        private static var _instance:ActionListManager;
        
        private var _actionListPlayers:Vector.<ActionsListPlayer>;      // list of ActionsListPlayers being managed
        
        public function ActionListManager() 
        {
            if (_instance != null) 
            {
                // show error to prevent new instances of ActionQueue being created.
                throw new Error("ActionListManager is a singleton, it should never be created twice.\n" +
                    "Use ActionListManager.instance to get a reference to ActionQueue.");
            }
            _instance = this;
            
            _actionListPlayers = new Vector.<ActionsListPlayer>;
        }
        
        public function playActions(actionLists:Vector.<Vector.<IAction>>,
                                    funct:Function = null):ActionsListPlayer
        {
            var actionsListPlayer:ActionsListPlayer = new ActionsListPlayer(actionLists);
            _actionListPlayers.push(actionsListPlayer);
            
            // listen for action finished
            var listener:Function = function (event:Event):void 
            {
                actionsListPlayer.removeEventListener(ActionsListPlayerFinishedEvent.ACTIONS_LIST_PLAYER_FINISHED, listener);
                funct();
                actionsFinished(actionsListPlayer);
            };
            actionsListPlayer.addEventListener(ActionsListPlayerFinishedEvent.ACTIONS_LIST_PLAYER_FINISHED, listener);
            
            // for synchronization reasons it's helpful to start 
            //  playing the list at the beginning of the next frame.
			Delayer.nextFrame(actionsListPlayer.start);
            
            return actionsListPlayer;
        }
        
        private function actionsFinished(actionsListPlayer:ActionsListPlayer):void 
        {
            var index:uint = _actionListPlayers.indexOf(actionsListPlayer);
            _actionListPlayers.splice(index, 1);
            
            if (_actionListPlayers.length == 0) 
            {
                dispatchEvent(new ActionListManagerFinishedEvent(ActionListManagerFinishedEvent.ACTION_LIST_MANAGER_FINISHED));
            }
        }
        
        public function whenDone(funct:Function):void
        {   
            if (idle) 
            {
                // no action list players playing,
                //  use Delayer to trigger callback on the next frame
                Delayer.nextFrame(funct);
            } 
            else 
            {
                // listen for action list finishing
                var listener:Function = function (event:Event):void 
                {
                    removeEventListener(ActionListManagerFinishedEvent.ACTION_LIST_MANAGER_FINISHED, listener);
                    funct();
                };
                addEventListener(ActionListManagerFinishedEvent.ACTION_LIST_MANAGER_FINISHED, listener);
            }
        }
        
        public function get idle():Boolean
        {
            return (_actionListPlayers.length == 0);
        }
        
        /** Gives a reference to the ActionListManager singleton. */
        public static function get instance():ActionListManager 
        {
            if (! _instance) 
            {
                _instance = new ActionListManager();
            }
            return _instance;
        }
    }
}
