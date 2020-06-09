//
//  Callback v 1.8.1
//  Russell Lowke, June 19th 2011
// 
//  Copyright (c) 2009-2011 Lowke Media
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

package com.lowke.dragNDrop
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    /**
     * <p>Callback v 1.8</p>
     * 
     * <p>Callback is an alternative to using a closure and a convenience when 
     * dealing with events, where you want to simply call a function once and 
     * send it arguments when the event is triggered.</p>
     * 
     * <p>Note: Callback is attached to the object being listened to, when that 
     * object gets cleared from memory then so too is the Callback.</p>
     *
     * Usage:
     * <pre>
     *  Callback.one(dispatcher, Event.ENTER_FRAME, funct);
     * </pre>
     * <p>Where the function funct will be called once
     * when the EventDispatcher dispatcher next dispatches an ENTER_FRAME
     * event. Subsequent ENTER_FRAME events will not trigger the function.</p>
     * 
     * There is also a oneWithEvt() method,
     * <pre>
     *  Callback.oneWithEvt(dispatcher, Event.ENTER_FRAME, funct);
     * </pre>
     * <p>Where the callback function is passed the dispatched event as the 1st
     * argument passed to funct.</p>
     * 
     * <p>A reference to the Callback object is returned. Intended as a throw away 
     * reference, this reference is only useful if you wish to close or trigger
     * the Callback before it occurs.</p>
     *
     * <p>WARNING! if you keep the returned reference you must dispose 
     * of it as it contains a hard reference to the dispatcher being 
     * listened to, and any memory associated with your function or 
     * arguments won't dispose until the reference or the dispatcher 
     * is cleared. </p>
     * 
     * If you want the callback to keep listening for the event and trigger 
     * every time the event is dispatched use,
     * <pre>
     *  Callback.bind(dispatcher, Event.ENTER_FRAME, funct);
     * </pre>
     * <p>Where the function funct will be called
     * every time the EventDispatcher dispatches an ENTER_FRAME event.</p>
     * 
     * The method names one() and bind() have been used here so to be similar to
     * to the JQuery API for dealing with events.
     * 
     * 
     * @author Russell Lowke
     * @langversion ActionScript 3.0
     * @playerversion Flash 9
     * @see http://www.lowkemedia.com
     */
    public class Callback 
    {   
        //
        // member variables
        private var _dispatcher:EventDispatcher;            // dispatcher being listened to
        private var _evtType:String;                        // event type being listened for
        private var _passEvt:Boolean;                       // if true then the event is passed
        private var _persist:Boolean;                       // if true then the Callback is not automatically removed once called
        private var _funct:Function;                        // function to be called
        
        /**
         * The Callback constructor isn't intended to be called directly,
         * use the static helper methods Callback.one(), Callback.bind() or 
         * Callback.oneWithEvt() to create a new Callback.
         *
         * @param dispatcher The event dispatcher object being listened to.
         * @param evtType The event string type being listened for.
         * @param passEvt If true the event is passed as the 1st argument to the 
         *               callback funct.
         * @param persist If true the callback is not removed and persists until 
         *               closed using the close() method.
         * @param funct Function callback to be called when event triggers.
         */
        public function Callback(dispatcher:EventDispatcher,
                                 evtType:String,
                                 passEvt:Boolean = false,
                                 persist:Boolean = false,
                                 funct:Function = null):void
        {
            _dispatcher = dispatcher;
            _evtType    = evtType;
            _passEvt    = passEvt;
            _persist    = persist;
            _funct      = funct;
            
            if (_funct == null) 
            {
                throw new Error("funct parameter is null. Callback must have a function to callback.");
            }
            
            if (_dispatcher == null) 
            {
                throw new Error("dispatcher parameter is null. Callback must listen to an EventDispatcher object.");
            }
            
            // Note: this listener must be a hard listener and not soft
            //  as it is intended to be the only reference to the Callback instance
            _dispatcher.addEventListener(_evtType, trigger);
        }
        
        /**
         * Triggers the function callback, and closes the Callback object unless 
         * the _persist member variable flag has been set to true.
         *
         * @param event This function is usually called by an event listener
         */
        public function trigger(event:Event = null):void 
        {   
            if (! _persist) 
            {
                close();
            }
            

            _funct();
        }
        
        
        /**
         * Closes the Callback by removing the event listener from the 
         * _dispatcher, this clears the Callback object from memory.
         */
        public function close():void 
        {   
            // remove the hard event listener from the _dispatcher
            _dispatcher.removeEventListener(_evtType, trigger);
        }
        
        
        //
        // accessors and mutators
        //
        
        /** Gives the dispatcher object being listened to. */
        public function get dispatcher():EventDispatcher    { return _dispatcher; }
        
        /** Gives the event type being listened for on the dispatcher object. */
        public function get evtType():String                { return _evtType; }
        
        /** Gives the function calback to be called when the event fires. */
        public function get funct():Function                { return _funct; }
        
        
        //
        //  static helper methods
        //
        
        /**
         * <p>Listens to the <code>dispatcher</code> object for an event of type 
         * <code>evtType</code>, to be fired. When it is, the function callback 
         * <code>funct</code> is triggered and any additional arguments sent to 
         * it. This happens once, after which the Callback is closed() and its 
         * event listeners removed.</p>
         * 
         * <p>This call is styled to be similar to the JQuery one() method.</p>
         *
         * @param dispatcher The event dispatcher object being listened to.
         * @param evtType The event type being listened for.
         * @param funct Function callback to be called when event triggers.
         * 
         * @return The Callback instance is returned. Intended as a throw away 
         *         reference, it can be used to close() the callback if the 
         *         callback needs to be canceled.
         * 
         *         WARNING! if you keep the returned reference you must dispose 
         *         of it as it contains a hard reference to the dispatcher being 
         *         listened to, and any memory associated with your function or 
         *         arguments won't dispose until the reference or the dispatcher 
         *         is cleared.
         */ 
        public static function one(dispatcher:EventDispatcher, 
                                   evtType:String, 
                                   funct:Function):Callback
        {
            return new Callback(dispatcher, evtType, false, false, funct);
        }
        
        /**
         * <p>Same as Callback.one() only the event being listened to is passed as 
         * the 1st parameter to the callack function.</p>
         *
         * @param dispatcher The event dispatcher object being listened to.
         * @param evtType The event type being listened for.
         * @param funct Function callback to be called when event triggers. The 
         *              event is passed to this function as the 1st parameter.
         * 
         * @return The Callback instance is returned. Intended as a throw away 
         *         reference, it can be used to close() the callback if the 
         *         callback needs to be canceled.
         * 
         *         WARNING! if you keep the returned reference you must dispose 
         *         of it as it contains a hard reference to the dispatcher being 
         *         listened to, and any memory associated with your function or 
         *         arguments won't dispose until the reference or the dispatcher 
         *         is cleared.
         */ 
        public static function oneWithEvt(dispatcher:EventDispatcher, 
                                          evtType:String, 
                                          funct:Function):Callback
        {
            return new Callback(dispatcher, evtType, true, false, funct);
        }
        
        /**
         * <p>Listens to the <code>dispatcher</code> object for events of type 
         * <code>evtType</code>, to be fired. Each time they are, the function 
         * callback <code>funct</code> is triggered and supplied additional 
         * arguments sent to it.</p>
         * 
         * <p>This call is styled to be similar to the JQuery bind() method, for 
         * those familiar with jQuery.</p>
         *
         * @param dispatcher The event dispatcher object being listened to.
         * @param evtType The event type being listened for.
         * @param funct Function called whenever the event triggers.
         * 
         * @return The Callback instance is returned. Intended as a throw away 
         *         reference, it can be used to close() the callback if the 
         *         binding needs to be stopped.
         * 
         *         WARNING! if you keep the returned reference you must dispose 
         *         of it as it contains a hard reference to the dispatcher being 
         *         listened to, and any memory associated with your function or 
         *         arguments won't dispose until the reference or the dispatcher 
         *         is cleared.
         */ 
        public static function bind(dispatcher:EventDispatcher, 
                                    evtType:String, 
                                    funct:Function):Callback
        {
            return new Callback(dispatcher, evtType, false, true, funct);
        }
        
        
        /** 
         * Same as Callback.one() only the additional arguments are already 
         * packed into an array.
         */
        public static function oneArgs(dispatcher:EventDispatcher, 
                                       evtType:String, 
                                       funct:Function):Callback
        {
            var callback:Callback;
            if (funct != null) 
            {
                callback = new Callback(dispatcher, evtType, false, false, funct);
            }
            return callback;
        }
        
        /** 
         * Same as Callback.bind() only the additional arguments are already 
         * packed into an array.
         */
        public static function bindArgs(dispatcher:EventDispatcher, 
                                        evtType:String, 
                                        funct:Function):Callback
        {
            var callback:Callback;
            if (funct != null) 
            {
                callback = new Callback(dispatcher, evtType, false, true, funct);
            }
            return callback;
        }
    }
}