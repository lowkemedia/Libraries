//
//  ActionFinishedEvent v 1.0 - actionQueue package
//  Russell Lowke, December 18th 2011
// 
//  Copyright (c) 2011 Lowke Media
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

//
//  ActionFinishedEvent is dispatched from an action to indicate it has finished executing

package com.lowke.actionQueue.event
{   
    import flash.events.Event;
    
    /**
     * @author Russell Lowke
     */
    public class ActionFinishedEvent extends Event 
    {   
        // event name
        public static const ACTION_FINISHED:String = "actionFinished";
        
        public function ActionFinishedEvent(type:String) 
        {
            super(type);
        }
        
        public override function clone():Event 
        {
            return new ActionFinishedEvent(type);
        }
        
        public override function toString():String 
        {
            return formatToString("ActionFinishedEvent", "type");
        }
    }
}