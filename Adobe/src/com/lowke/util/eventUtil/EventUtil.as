package com.lowke.util.eventUtil
{
    import flash.events.Event;
    import flash.events.IEventDispatcher;

    public class EventUtil
    {
        /**
         * Convenience method that uses a closure to bind a function callback
         * with arguments to be called whenever a particular event is dispatched
         * from an EventDispatcher object.
         *
         * Flash has an annoying bug with closures in that values passed into a
         * closure are copied by reference, not value. If you try to use multiple
         * closures in a method passing different references for a variable it won't
         * work properly as only the last reference will be used for all closures.
         * This static method sidesteps the problem as references are copied when
         * passed as parameters into the method.
         *
         * Note: The listener added is a hard listener and will only dispose
         * when the dispatcher being listened to is cleared.
         *
         * @param dispatcher EventDispatcher being listened to.
         * @param type Event type being listened for.
         * @param funct Function callback called when event dispatched.
         */
        public static function bindOnEvent(dispatcher:IEventDispatcher,
                                           type:String,
                                           funct:Function):void
        {
            var listener:Function = function (event:Event):void
            {
                funct();
            }
            dispatcher.addEventListener(type, listener);
        }


        /**
         * Convenience method that, just once, uses a closure to call a function
         * callback with arguments when a particular event is dispatched from an
         * EventDispatcher object.
         *
         * Flash has an annoying bug with closures in that values passed into a
         * closure are copied by reference, not value. If you try to use multiple
         * closures in a method passing different references for a variable it won't
         * work properly as only the last reference will be used for all closures.
         * This static method sidesteps the problem as references are copied when
         * passed as parameters into the method.
         *
         * @param dispatcher EventDispatcher being listened to.
         * @param type Event type being listened for.
         * @param funct Function callback called when event dispatched.
         */
        public static function onceOnEvent(dispatcher:IEventDispatcher,
                                           type:String,
                                           funct:Function):void
        {
            var listener:Function = function (event:Event):void
            {
                dispatcher.removeEventListener(type, listener);
                funct();
            }
            dispatcher.addEventListener(type, listener);
        }
    }
}
