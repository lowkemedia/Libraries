//
//  ActionQueueFinishedEvent v 1.0 - actionQueue package
//  Russell Lowke, February 17th 2011
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


package com.lowke.actionQueue.event
{   
    import flash.events.Event;
    
    /**
     * @author Russell Lowke
     */
    public class ActionQueueFinishedEvent extends Event 
    {   
        // event name
        public static const ACTION_QUEUE_FINISHED:String = "actionQueueFinished";
        
        public function ActionQueueFinishedEvent(type:String) 
        {
            super(type);
        }
        
        public override function clone():Event 
        {
            return new ActionQueueFinishedEvent(type);
        }
        
        public override function toString():String 
        {
            return formatToString("ActionQueueFinishedEvent", "type");
        }
    }
}