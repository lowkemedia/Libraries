//
//  SoundFx v 1.0.3 - soundManager package
//  Russell Lowke, June 1st 2011
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


package com.lowke.soundManager.soundFx
{

    import com.lowke.logger.Logger;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundLoaderContext;
    import flash.media.SoundTransform;
    import flash.net.URLRequest;
    
    public class SoundFx extends Sound 
    {
        public static const DEBUG_SOUND_AT_MAX_PLAYS:String = "SND00";

        public static const MAX_PRELOAD_SND_LENGTH:Number = 3000;     // preload sounds of less than 3 seconds duration
        
        private static var _masterVolume:Number = 1;                // master volume control for all sounds
        
        private var _channels:Vector.<SoundChannel>;                // channels used for sound
        private var _defaultVolume:Number = 1;                      // default volume at which to play sound
        private var _maxConcurrent:uint = 0;                        // max number of concurrent plays for the sound, 0 being no limit.
        private var _loopByDefault:Boolean = false;                 // loop sound by deafult
        private var _position:Number = 0;                           // position sound was stopped at
        private var _id:String;                                     // identifier for sound, usually its url or cached id
        
        public function SoundFx(stream:URLRequest = null,
                                context:SoundLoaderContext = null) 
        {   
            super(stream, context);
            
            _channels = new Vector.<SoundChannel>;
            
            // preload the sound once loaded.
            onceOnEvent(this, Event.COMPLETE, preload);
        }
        
        
        public function preload():void 
        {   
            if (this.length < MAX_PRELOAD_SND_LENGTH) 
            {
                // "preload" short sounds by playing them a zero volume
                play(0, 0, new SoundTransform(0));
            }
        }
        
        // overrides the regular play method of Sound
        public override function play(position:Number = NaN, 
                                      loops:int = -1, 
                                      transform:SoundTransform = null):SoundChannel 
        {   
            if (! isNaN(position)) 
            {
                _position = position;
            } 
            else 
            {
                _position = 0;
            }
            
            if (! transform) 
            {
                transform = volumeTransform();
            }
            
            if (loops == -1) 
            {
                if (_loopByDefault) 
                {
                    loops = int.MAX_VALUE;
                } 
                else 
                {
                    loops = 0;
                }
            }
            
            return playInternal(loops, transform);
        }

        private function playInternal(loops:int, transform:SoundTransform):SoundChannel
        {
            if (! _maxConcurrent || _channels.length <= _maxConcurrent) 
            {
                var channel:SoundChannel = super.play(_position, loops, transform);
                if (channel) 
                {
                    _channels.push(channel);
                    onceOnEvent(channel, Event.SOUND_COMPLETE, function():void
                        {
                            stopChannel(channel);
                        });
                }
            } 
            else 
            {
                Logger.debug("Sound " + _id + " won't play as it has reached its maximum number of concurrent plays, which is " + _maxConcurrent, DEBUG_SOUND_AT_MAX_PLAYS);
            }
            return channel;
        }
        

        public function playSound(funct:Function = null, volume:Number = NaN):void
        {
            var channel:SoundChannel = play(NaN, 0, volumeTransform(volume));
            if (funct != null) 
            {
                onceOnEvent(channel, Event.SOUND_COMPLETE, funct);
            }
        }
        
        
        public function loop(loops:int = int.MAX_VALUE):void
        {   
            play(NaN, loops, volumeTransform());
        }
        
        
        private function volumeTransform(volume:Number = NaN):SoundTransform
        {
            if (isNaN(volume))
            {
                volume = _masterVolume*_defaultVolume;
            }

            if (volume == 1) 
            {
                return null;    // SoundTransform not needed
            } 
            else 
            {
                return new SoundTransform(volume);
            }
        }
        
        private function stopChannel(channel:SoundChannel):void 
        {
            channel.removeEventListener(Event.SOUND_COMPLETE, stopChannel);
            dispatchEvent(new Event(Event.SOUND_COMPLETE));
            _position = channel.position;
            channel.stop();
            _channels.splice(_channels.indexOf(channel), 1);
        }
        
        public function stop():void 
        {
            for each (var channel:SoundChannel in _channels) 
            {
                stopChannel(channel);
            }
        }
        
        public function resume():void 
        {
            play(_position);
        }
        
        //
        // accessors and mutators
        
        public static function set masterVolume(val:Number):void    { _masterVolume = val; }
        public function set defaultVolume(val:Number):void          { _defaultVolume = val; }
        public function set loopByDefault(val:Boolean):void         { _loopByDefault = val; }
        public function set position(val:Number):void               { _position = val; }
        public function set maxConcurrent(val:uint):void            { _maxConcurrent = val; }
        public function set id(val:String):void                     { _id = val; }
        
        public static function get masterVolume():Number            { return _masterVolume; }
        public function get defaultVolume():Number                  { return _defaultVolume; }
        public function get loopByDefault():Boolean                 { return _loopByDefault; }
        public function get position():Number                       { return _position; }
        public function get maxConcurrent():uint                    { return _maxConcurrent; }
        public function get id():String                             { return _id; }
        public function get volume():Number 
        {
            if (_channels.length > 0) 
            {
                return _channels[_channels.length - 1].soundTransform.volume;
            } 
            else 
            {
                return _masterVolume*_defaultVolume;
            }
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
        public static function onceOnEvent(dispatcher:EventDispatcher,
                                           type:String,
                                           funct:Function):void
        {
            var listener:Function = function (event:Event):void 
            {
                dispatcher.removeEventListener(type, listener);
                funct();
            };
            dispatcher.addEventListener(type, listener);
        }
    }
}
