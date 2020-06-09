//
//  Delayer v 2.4
//  Russell Lowke, August 4th 2013
//
//  Copyright (c) 2008-2013 Lowke Media
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

package com.lowke
{
    import flash.display.Shape;
    import flash.events.Event;
    import flash.utils.getTimer;
    
    /**
     * Delayer v 2.4
     * Russell Lowke, August 4th 2013
     * 
     * Call a function just once after a specified interval.
     * 
     * Usage: 
     * <pre>
     *  Delayer.delay(delay, callBackFunct);
     * </pre>
     * 
     * Where the callBackFunct is triggered after delay milliseconds.
     * 
     * A reference to the Delayer object is returned, which is useful in 
     * cases where you need to close or trigger the delay before the delay 
     * is reached, this may be done using the close() or trigger() methods.
     * 
     * Note: Delayer listens for <code>Event.ENTER_FRAME</code> events and 
     * compares time using <code>getTimer()</code>, which is *more accurate*  
     * than the Flash Timer class, but is limited to a minimum delay time   
     * governed by the frame rate of the project.
     * 
     * @see http://www.lowkemedia.com
     */
    public class Delayer 
    {    
        // a static _ticker is used to listen for ENTER_FRAME events
        private static var _ticker:Shape = new Shape();
        
        //
        // member variables
        private var _callBackFunct:Function;    // function to be called
        private var _triggerTime:uint;          // time function will trigger 
        
        /**
         * Call a function just once after a specified interval.
         * 
         * The Delayer constructor isn't intended to be called directly,
         * typically you should use the static helper methods Delayer.delay() 
         * or Delayer.doLater() when using Delayer.
         * 
         * @param delay Time waited (in milliseconds) before callback 
         * function is called.
         * @param callBackFunct Callback triggered after delay milliseconds.
         */
        public function Delayer(delay:int,
                                callBackFunct:Function):void
        {
            this.callBackFunct = callBackFunct;
            _triggerTime = getTimer() + delay;
            
            // delay must be positive
            if (delay < 1)
            {
                // Calling the callBackFunct immediately when delay 
                // is 0 is problematic in situations where code  
                // rightly assumes there will be at least some delay.
                delay = 1;
            }
            
            // Note: this listener must be a hard listener and not soft
            //  as it's typically the only reference to the Delayer instance.
            _ticker.addEventListener(Event.ENTER_FRAME, onEnterFrameEvent);
        }
        
        private function onEnterFrameEvent(event:Event):void
        {    
            if (getTimer() >= _triggerTime) 
            {
                trigger();
            }
        }
        
        /**
         * Triggers the callback and closes the Delayer object.
         */
        public function trigger():void
        {   
            // remove the hard listener
            _ticker.removeEventListener(Event.ENTER_FRAME, onEnterFrameEvent);

            if (_callBackFunct != null) 
            {
                _callBackFunct();
            }
            
            close();
        }
        
        /**
         * Closes Delayer by removing the hard event listener.
         */
        public function close():void 
        {    
            // Remove the hard event listener, typically this clears the 
            // Delayer instance at time of garbage collection.
            _ticker.removeEventListener(Event.ENTER_FRAME, onEnterFrameEvent);
            _callBackFunct = null;
        }
        
        
        //
        // accessors and mutators
        //
        
        public function set callBackFunct(value:Function):void
        {
            if (! (value is Function))
            {
                throw new Error("Delayer received an invalid callBackFunct.");
            }
            _callBackFunct = value; 
        }

        public function set triggerTime(value:uint):void
        {
            _triggerTime = value;
        }
        
        public function get callBackFunct():Function
        {
            return _callBackFunct;
        }

        public function get triggerTime():uint
        {
            return _triggerTime;
        }


        /**
         * Specifies whether the specified Array is either non-null, or contains
         * characters (i.e. length is greater than 0)
         *
         * @param array The Array which is being checked for a value
         * @return Returns true if the Array has a value
         */
        private static function arrayHasValue(array:Array):Boolean
        {
            return (array != null && array.length > 0);
        }


        /**
         * Static helper function for creating delays.
         * Triggers the callBackFunct after delay milliseconds and passes to
         * it any additional arguments.
         * 
         * @param delay Time waited (in milliseconds).
         * @param callBackFunct Callback triggered after delay.
         * @return Reference to Delayer object is returned. 
         * Intended as a throw away reference, this instance may be used to
         * trigger or close the delay early using trigger() or close().
         */
        public static function delay(delay:int,
                                     callBackFunct:Function):Delayer
        {
            return new Delayer(delay, callBackFunct);
        }
        
        
        /**
         * Often it's helpful to trigger a function on the next ENTER_FRAME event, 
         * which can be achieved by using a delay with a delay time of 1. This can  
         * be particularly useful for polling, where you wait for a condition to   
         * become true before executing the body of a function.
         * 
         * @param callBackFunct Callback to be triggered on the next ENTER_FRAME.
         */
        public static function nextFrame(callBackFunct:Function):void
        {
            new Delayer(1, callBackFunct);
        }
    }
}