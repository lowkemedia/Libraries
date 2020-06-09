//
//  ActionsListPlayer v 2.0 - actionQueue package
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
    import com.lowke.actionQueue.IAction;
    import com.lowke.actionQueue.event.ActionFinishedEvent;
    import com.lowke.actionQueue.event.ActionsListPlayerFinishedEvent;
    
    import flash.events.EventDispatcher;
    
    public class ActionsListPlayer extends EventDispatcher
    {   
        private var _actionLists:Vector.<Vector.<IAction>>;                     // actionlists of GameActions
        private var _listsIndex:int;                                            // index of list in _actionLists being processed
        private var _actionsDone:uint;                                          // number of actions in list at _listsIndex completed
        
        public function ActionsListPlayer(actionLists:Vector.<Vector.<IAction>>) 
        {
            _actionLists = actionLists;
            _listsIndex = -1;
            
            // Note: start() must be called to commence processing actions
        }
        
        public function start():void 
        {
            if (_listsIndex == -1) 
            {
                _listsIndex = 0;
                processActions();
            } 
            else 
            {
                throw new Error("ActionsListPlayer process already started.");
            }
        }
        
        private function processActions():void 
        {   
            if (_listsIndex == _actionLists.length) 
            {
                end();
            } 
            else if (_actionLists[_listsIndex].length == 0) 
            {
                // if we have an empty vector immediately increment _listsIndex and recurse
                ++_listsIndex;
                processActions();
            } 
            else 
            {
                _actionsDone = 0;
                for each (var gameAction:IAction in _actionLists[_listsIndex]) 
                {
                    // listen for action finished
                    var listener:Function = function (event:ActionFinishedEvent):void 
                    {
                        gameAction.removeEventListener(ActionFinishedEvent.ACTION_FINISHED, listener);
                        actionFinished(gameAction);
                    };
                    gameAction.addEventListener(ActionFinishedEvent.ACTION_FINISHED, listener);
                    gameAction.playAction();
                }
            }
        }
        
        private function actionFinished(gameAction:IAction):void 
        {
            // flag action as having been processed
            gameAction.processed = true;
            ++_actionsDone;
            if (_actionsDone == _actionLists[_listsIndex].length) 
            {
                ++_listsIndex;
                processActions();
            }
        }
        
        public function appendActions(actions:Vector.<Vector.<IAction>>):void 
        {
            for each(var list:Vector.<IAction> in actions) 
            {
                _actionLists.push(list);
            }
        }
        
        public function end():void
        {
            dispatchEvent(new ActionsListPlayerFinishedEvent(ActionsListPlayerFinishedEvent.ACTIONS_LIST_PLAYER_FINISHED));
        }
    }
}
