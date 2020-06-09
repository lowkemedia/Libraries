//
//  PlayFrames v 1.6 - playFrames package
//  Russell Lowke, June 30th 2013
//
//  Copyright (c) 2010-2013 Lowke Media
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
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
//  IN THE SOFTWARE. 
//
//

package com.lowke.playFrames
{
    import com.lowke.Delayer;
    import com.lowke.logger.Logger;
    import com.lowke.playFrames.event.FramesFinishedEvent;
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.FrameLabel;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.utils.Dictionary;
    import flash.utils.getTimer;
    
    /**
     * PlayFrames is used to play a MovieClip backwards or forwards at a specific
     * frame rate, regardless of the actual frame rate of the project.
     * 
     * Usage: 
     * 
     * <pre>
     *  PlayFrames.play(movieClipInstance, "startFrameLabel", "endFrameLabel", 24);
     * </pre>
     * 
     * Where the movieClipInstance will be played from the "startFrameLabel" to the
     * "endFrameLabel"at 24 frames per second. Frames that can't display quick enough 
     * will be dropped, unless the optional playEveryFrame flag is set to true.
     * 
     * You can trigger a function to be called when the animation finishes by listening
     * for the PLAY_FRAMES_FINISHED event on the instance, or, preferably, you can use 
     * the whenDone() convenience method that listens for the PLAY_FRAMES_FINISHED event 
     * for you, e.g.
     * 
     * <pre>
     *  PlayFrames.play(movieClipInstance, "startFrameLabel", "endFrameLabel", 24).whenDone(yourFunctionCallback);
     * </pre>
     * 
     * PlayFrames is a standalone version of the Animator effect PlayFramesFX
     * found at com.lowke.animator.effects.PlayFramesFX
     *
     * @author Russell Lowke
     * @langversion ActionScript 3.0
     * @playerversion Flash 10
     */
    public class PlayFrames
    {   
        //
        // error, warning and ifo IDs
        public static const LOG_PREFIX:String                                   = "PLF";
        public static const WARNING_RECEIVED_EMPTY_CLIP:String                  = "PLF00";
        public static const WARNING_RECEIVED_CLIP_THATS_NOT_ONSTAGE:String      = "PLF01";
		public static const WARNING_COULD_NOT_FIND_STAGE:String                 = "PLF02";
        
        // returned by getFrameNumber(), indicates no frame found with that label
        public static const NO_FRAME:int = 0;   
        
        // keywords used by getFrameNumber() method to indicate various generic frames
        public static const FIRST_FRAME:String 			= "First Frame";
        public static const CURRENT_FRAME:String 		= "Current Frame";
        public static const LAST_FRAME:String 			= "Last Frame";
        
        // constants used by type variable
        public static const TYPE_END:uint               = 1;            // close() called when endFrame reached
        public static const TYPE_DESTROY:uint           = 3;            // close() called and clip removed when endFrame reached
        public static const TYPE_CYCLE:uint             = 4;            // cycles to the beginning when endFrame reached
        public static const TYPE_REVERSE:uint           = 5;            // reverses animation when endFrame reached
        
        protected static const TWENTY_FOUR_FPS:Number = 24;             // twenty four frames per second
        protected static var _defaultFrameRate:Number = NaN;            // default frame rate used, if NaN or 0 then stage's frame rate is used
        protected static var _playFrames:Dictionary = new Dictionary(true); // hash of all PlayFrames objects
        
        protected var _clip:DisplayObject;      // usually a MovieClip or BitmapMovieClip
        protected var _updateTime:uint;         // time of last update. 
        //                                      //  An _updateTime of 0 indicates this PlayFrames instance has been closed
        protected var _currentFrame:Number;     // current frame stored as a float for fractional frame values
        protected var _startFrame:uint;         // start frame
        protected var _endFrame:uint;           // end frame
        protected var _msPerFrame:Number;       // milliseconds per frame
        protected var _playEveryFrame:Boolean;  // if true every frame is played regardless of frame rate
		protected var _stopChildren:Boolean;	// if true then child clips are stopped from playing while the clip plays.
        protected var _type:uint = TYPE_END;    // defaults to TYPE_END, can also be set to TYPE_DESTROY, TYPE_CYCLE, or TYPE_REVERSE
        
        
        //
        // static helper constructor methods for PlayFrames
        //
        
        
        /**
         *  Tells a MovieClip to play from a label to a label at a specific frame rate.
         *  If the startLabel is after the endLabel then the clip will play backwards.
         *
         *  @param  clip            MovieClip being played
         *  @param  startLabel      Label to start playing from
         *                          Use PlayFrames.FIRST_FRAME, PlayFrames.CURRENT_FRAME, 
         *                          or PlayFrames.LAST_FRAME to use a generic frame.
         *                          If null then defaults to PlayFrames.CURRENT_FRAME.
         *  @param  endLabel        Label to end playing at
         *                          Use PlayFrames.FIRST_FRAME, PlayFrames.CURRENT_FRAME, 
         *                          or PlayFrames.LAST_FRAME to use a generic frame.
         *                          If null then defaults to PlayFrames.LAST_FRAME.
         *  @param  frameRate       The frame rate at which to play the clip. 
         *                          If NaN then PlayFrames.defaultFrameRate is used.
         *                          If frameRate is negative then the clip will play backwards
         *  @param  duration        Duration in milliseconds that the animation should take.
         *                          Note: If duration is set then the frameRate parameter is ignored
         *  @param  playEveryFrame  If true then every frame of the animation will be played with
         *                          no frames being dropped. This might result in the animation 
         *                          taking longer to play than expected.
         *  @param  type            The animation type may be declared as PlayFrames.TYPE_END,
         *                          PlayFrames.TYPE_DESTROY, PlayFrames.TYPE_CYCLE, or 
         *                          PlayFrames.TYPE_REVERSE. This declared what will be done once
         *                          the animation finishes.
         *  @return PlayFrames      A reference to the PlayFrames instance is returned
         */
        public static function play(clip:MovieClip,
                                    startLabel:String = null,
                                    endLabel:String = null,
                                    frameRate:Number = NaN,
                                    duration:uint = 0,
                                    playEveryFrame:Boolean = false,
									stopChildren:Boolean = false,
                                    type:uint = TYPE_END):PlayFrames 
        {
            if (! startLabel) 
            {
                startLabel = CURRENT_FRAME;
            }
            var startFrame:uint = getFrameNumber(clip, startLabel);

            if (! endLabel) 
            {
                endLabel = LAST_FRAME;
            }
            var endFrame:uint = getFrameNumber(clip, endLabel);
            
            return playFrames(clip, startFrame, endFrame, frameRate, duration, playEveryFrame, stopChildren, type);
        }
        
        
		// returned reference intended as a throw away reference,
		//  though it might be needed if the animation is to be closed early.
		public static function playFrames(clip:DisplayObject,
									startFrame:uint = 0,
									endFrame:uint = 0,
									frameRate:Number = NaN,
									duration:uint = 0,
									playEveryFrame:Boolean = false,
									stopChildren:Boolean = false,
									type:uint = TYPE_END):PlayFrames 
		{
			return new PlayFrames(clip, startFrame, endFrame, frameRate, duration, playEveryFrame, stopChildren, type);
		}
		
        //
        // Plays clip at frameRate.
        //  a negitive frameRate will cause the clip to play backwards
        //  if startAtBeginning is false clip will start on its current frame
        public static function fps(clip:DisplayObject, 
                                   frameRate:Number,
                                   startAtBeginning:Boolean = false,
                                   playEveryFrame:Boolean = false,
								   stopChildren:Boolean = false,
                                   type:uint = TYPE_END):PlayFrames 
        {
            var startFrame:uint = startAtBeginning ? 1 : 0; // 0 denotes to use the current frame
            return playFrames(clip, startFrame, 0, frameRate, 0, playEveryFrame, stopChildren, type);
        }
        
        //
        // Plays clip in duration
        public static function playInDuration(clip:DisplayObject,
                             		duration:uint,
                               		playEveryFrame:Boolean = false,
									stopChildren:Boolean = false,
                            		type:uint = TYPE_END):PlayFrames
        {
            return playFrames(clip, 0, 0, NaN, duration, playEveryFrame, stopChildren, type);
        }
        
        public static function stop(clip:DisplayObject):void 
        {
            // stopping and removing PlayFrames are the same thing
            removePlayFrames(clip);
        }
        
        public static function removePlayFrames(clip:DisplayObject):void 
        {
            var playFrames:PlayFrames = getPlayFrames(clip);
            if (playFrames) 
            {
                playFrames.close();
            }
        }
        
        public static function snapToEnd(clip:DisplayObject):void 
        {
            var playFrames:PlayFrames = getPlayFrames(clip);
            if (playFrames) 
            {
                playFrames.end();
                playFrames.close();
            }
        }
        
        public static function getPlayFrames(clip:DisplayObject):PlayFrames 
        {
            return _playFrames[clip] as PlayFrames;
        }
        
        //
        // constructor
        public function PlayFrames(clip:DisplayObject,
                                   startFrame:uint = 0,
                                   endFrame:uint = 0,
                                   frameRate:Number = NaN,
                                   duration:uint = 0,
                                   playEveryFrame:Boolean = false,
								   stopChildren:Boolean = false,
                                   type:uint = TYPE_END) 
        {   
            super();
            
            if (! clip) 
            {
                Logger.warning("PlayFrames received an empty clip to animate.", WARNING_RECEIVED_EMPTY_CLIP, true);
                clip = new MovieClip();
            }
            
            // remove any PlayFrames already associated with _clip
            removePlayFrames(clip);
            
            _clip = clip;
            _startFrame = startFrame;
            _endFrame = endFrame;
            _type = type;
            _playEveryFrame = playEveryFrame;
			_stopChildren = stopChildren;
            
            _msPerFrame = FPStoMSPF(frameRate);
            
            if (_startFrame) 
            {
                // set the frame to the start frame
                _currentFrame = _startFrame;
            } 
            else 
            {
                // set the frame to the clips current frame
                _currentFrame = clipCurrentFrame();
                
                // and consider the start as the beginning of the clip
                _startFrame = 1;
                
                if (_msPerFrame < 0) 
                {
                    // unless playing backwards when the start is really the end of the clip
                    _startFrame = clipTotalFrames();
                }
            }
            
            if (! _endFrame) 
            {
                if (_msPerFrame < 0) 
                {
                    // playing backwards, end on 1st frame
                    _endFrame = 1;
                } 
                else 
                {
                    // playing forwards, end on last frame
                    _endFrame = clipTotalFrames();
                }
            }
            
            if (duration) 
            {
                var nFrames:uint = Math.abs(_endFrame - _startFrame);
                if (nFrames == 0) 
                {
                    // avoid divide by zero
                    nFrames = 1;
                }
                _msPerFrame = duration/nFrames;
            } 
            else if (! _msPerFrame) 
            {
                // if _msPerFrame not set then find frame rate
                if (isNaN(_defaultFrameRate) || ! _defaultFrameRate) 
                {
                    if (_clip.stage) 
                    {
                        frameRate = _clip.stage.frameRate;
                    } 
                    else 
                    {
                        // otherwise use 24;
                        frameRate = TWENTY_FOUR_FPS;
						Logger.warning("Could not find stage to detect stage frame rate. Playing MovieClip \"" + _clip.name + "\" at 24 fps.", WARNING_COULD_NOT_FIND_STAGE);
                    }
                } 
                else 
                {
                    frameRate = _defaultFrameRate;
                }
                _msPerFrame = Math.abs(FPStoMSPF(frameRate));
            }
            
            // if start > end, then play backwards
            _msPerFrame = Math.abs(_msPerFrame);
            if (_startFrame > _endFrame) 
            {
                _msPerFrame = -_msPerFrame;
            }
            
            if (_startFrame == _endFrame)
            {
                // there is no animation
                end();
                return;
            }
            
            clipGotoAndStop(_currentFrame, _stopChildren);
            
            _clip.addEventListener(Event.ENTER_FRAME, enterFrame, false, 0, true);
            _clip.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
            
            _updateTime = getTimer();
            
            // keep reference
            _playFrames[_clip] = this;
        }
        
        private function enterFrame(event:Event):void
        {   
            // An _updateTime of 0 indicates this PlayFrames instance has been closed
            if (! _updateTime) 
            {
                return;
            }
            
            var currentTime:uint = getTimer();
            var timePassed:uint = currentTime - _updateTime;
            _updateTime = currentTime;
            
            var change:Number = timePassed/_msPerFrame;
            if (_playEveryFrame) 
            {
                if (change > 1) 
                {
                    change = 1;
                } 
                else if (change < -1)
                {
                    change = -1;
                }
            }
            
            _currentFrame += change;
            var frame:int = Math.floor(_currentFrame);
            
            if ((_msPerFrame > 0 && frame >= _endFrame) || 
                (_msPerFrame < 0 && frame <= _endFrame)) 
            {
                // animation finished
                clipGotoAndStop(_endFrame, true);
                
                switch (_type) 
                {
                    case TYPE_CYCLE:        cycle();        break;
                    case TYPE_REVERSE:      reverse();      break;
                    case TYPE_DESTROY:      destroy();      break;
                    default:
                    case TYPE_END:          end();          break;
                }
            } 
            else 
            {
                // keep playing
                clipGotoAndStop(frame, _stopChildren);
            }
        }
        
        
        public function end():void 
        {
            clipGotoAndStop(_endFrame, true);
            
            close();
            
            // Note: PLAY_FRAMES_FINISHED is dispatched from the _clip being animated,
            //  not from the PlayFrames instance.
            _clip.dispatchEvent(new FramesFinishedEvent(FramesFinishedEvent.PLAY_FRAMES_FINISHED));
        }
        
        public function destroy():void 
        {
            end();
            
            if ((_clip as DisplayObject).parent) 
            {
                (_clip as DisplayObject).parent.removeChild((_clip as DisplayObject));
            }
        }
        
        public function cycle():void 
        {
            _currentFrame = _startFrame;
            clipGotoAndStop(_startFrame);
        }
        
        public function reverse():void 
        {
            var temp:uint = _endFrame;
            _endFrame = _startFrame;
            _startFrame = temp;
            _msPerFrame = -_msPerFrame;
        }
        
        private function removedFromStage(event:Event):void
		{
            close();
        }
        
        public function close():void 
        {
            _clip.removeEventListener(Event.ENTER_FRAME, enterFrame);
            _clip.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
            _playFrames[_clip] = null;
            delete _playFrames[_clip];
            
            // Note: PLAY_FRAMES_REMOVED is dispatched from the _clip being animated,
            //  not from the PlayFrames instance.
            _clip.dispatchEvent(new FramesFinishedEvent(FramesFinishedEvent.PLAY_FRAMES_REMOVED));
            
            // An _updateTime of 0 indicates this PlayFrames instance has been closed
            _updateTime = 0;
        }
        
        /**
         * <p>whenDone()</p>
         * 
         * <p>A convenience method that sets a function callback to be called 
         * when PlayFrames animation has finished. Multiple consecutive whenDone() 
         * callbacks may be set.</p>
         * 
         * <p>whenDone() listens for the FramesFinishedEvent.PLAY_FRAMES_FINISHED event 
         * to be sent from this PlayFrames instance.</p>
         * 
         * @param funct Function callback called when PlatFrames finished animating.
         */
        public function whenDone(funct:Function):void
        {
            // An _updateTime of 0 indicates PlayFrames has been closed
            if (! _updateTime) 
            {
                // use Delayer to trigger callback on the next frame
                Delayer.nextFrame(funct);
                
                return;
            }
            
            // listen for PLAY_FRAMES_FINISHED from _clip
            var listener:Function = function (event:FramesFinishedEvent):void 
            {
                _clip.removeEventListener(FramesFinishedEvent.PLAY_FRAMES_FINISHED, listener);
                funct();
            };
            _clip.addEventListener(FramesFinishedEvent.PLAY_FRAMES_FINISHED, listener);
        }
        
        //
        // methods for dealing with MovieClip or BitmapMovieClip
        
        protected function clipGotoAndStop(frame:int, 
										   recursive:Boolean = false):void
        {
            if (_clip is MovieClip) 
            {
                var movieClip:MovieClip = _clip as MovieClip;
                movieClip.gotoAndStop(frame);
				if (recursive)
				{
                	recursiveStop(movieClip);
				}
            }
            else
            {
                _clip["gotoAndStop"](_currentFrame);
            }
        }
        
        private function clipCurrentFrame():int
        {
            if (_clip is MovieClip) 
            {
                return (_clip as MovieClip).currentFrame;
            } 
            else 
            {
                return _clip["currentFrame"];
            }
        }
        
        private function clipTotalFrames():int
        {
            if (_clip is MovieClip) 
            {
                return (_clip as MovieClip).totalFrames;
            } 
            else 
            {
                return _clip["totalFrames"];
            }
        }
        
        
        //
        // accessors and mutators
        
        public function set playEveryFrame(value:Boolean):void          {  _playEveryFrame = value; }
        public function set type(value:uint):void                       { _type = value; }
		public function set stopChildren(value:Boolean):void            { _stopChildren = value; }
        public function get clip():DisplayObject                        { return _clip; }
        public function get updateTime():uint                           { return _updateTime; }
        public function get currentFrame():Number                       { return _currentFrame; }
        public function get startFrame():uint                           { return _startFrame; }
        public function get endFrame():uint                             { return _endFrame; }
        public function get playEveryFrame():Boolean                    { return _playEveryFrame; }
        public function get type():uint                                 { return _type; }
        public function get playing():Boolean                           { return ! (_playFrames[_clip] == null); }
        
        public static function set defaultFrameRate(value:Number):void  { _defaultFrameRate = value; }
        public static function get defaultFrameRate():Number            { return _defaultFrameRate; }
        
        //
        // static utility methods
        //
        
        /**
         * <p>FPStoMSPF()</p>
         * 
         * Convert frames per second to miliseconds per frame
         * 
         * @param fps The desired Frames Per Second (FPS)
         * 
         * @return Returns the fps as miliseconds per frame
         */
        private static function FPStoMSPF(fps:Number):Number 
        {
            if (fps == 0 || isNaN(fps)) 
            {
                return 0;   // avoid divide by zero
            } 
            else 
            {
                return (1000/fps);
            }
        }
        
        /**
         * <p>getFrameNumber()</p>
         * 
         * <p>Returns the frame number of a specifc label on a MovieClip.</p>
         * 
         * @param clip The MovieClip with labels.
         * @param label The label being searched for.
         * @return Returns the frame number of the label, -1 returned if no label found.
         */
        public static function getFrameNumber(clip:MovieClip, 
                                              label:String):int 
        {
            if (! clip) 
            {
                return NO_FRAME;
            }
            
            switch (label) 
            {
                case FIRST_FRAME:
                    return 1;
                case CURRENT_FRAME:
                    return clip.currentFrame;
                case LAST_FRAME:
                    return clip.totalFrames;
            }
            
            var frameLabels:Array = clip.currentLabels;
            var nLabels:uint = frameLabels.length;
            for (var i:uint = 0; i < nLabels; ++i) 
            {
                var frameLabel:FrameLabel = frameLabels[i];
                if (frameLabel.name == label) 
                {
                    return frameLabel.frame;
                }
            }
            
            return NO_FRAME;
        }
        
        
        /**
         * <p>getNextLabel()</p>
         * 
         * Returns the next FrameLabel on a MovieClip after the current frame.
         * If there is no next label then the last label is given.
         * 
         * @param clip The MovieClip with labels.
         */
        public static function getNextLabel(clip:MovieClip):FrameLabel
        {
            var frameLabels:Array = clip.currentLabels;
            if (! frameLabels.length) 
            {
                return null;    // no frame labels
            }
            
            for (var i:uint = 0; i < frameLabels.length; ++i) 
            {
                var frameLabel:FrameLabel = frameLabels[i];
                if (frameLabel.frame > clip.currentFrame) 
                {
                    return frameLabel;
                }
            }
            
            // otherwise return the last label
            return frameLabels[frameLabels.length - 1];
        }
        
        
        /**
         * Goto the next label in a MovieClip
         * 
         * @param clip The MovieClip with labels
         */
        public static function gotoNextLabel(clip:MovieClip):void
        {
            var frameLabel:FrameLabel = getNextLabel(clip);
            if (frameLabel) 
            {
                clip.gotoAndStop(frameLabel.frame);
            }
        }
        
        
        /**
         * <p>getPreviousLabel()</p>
         * 
         * Returns the previous FrameLabel on a MovieClip before the current frame.
         * If there is no previous label then the first label is given.
         * 
         * @param clip The MovieClip with labels.
         */
        public static function getPreviousLabel(clip:MovieClip):FrameLabel
        {
            var frameLabels:Array = clip.currentLabels;
            if (! frameLabels.length) 
            {
                return null;    // no frame labels
            }
            
            var index:int;
            for (var i:uint = 0; i < frameLabels.length; ++i) 
            {
                var frameLabel:FrameLabel = frameLabels[i];
                if (frameLabel.frame > clip.currentFrame) 
                {
                    return frameLabels[(i < 2) ? 0 : i - 2];
                }
            }
            
            // must be at or beyond the last label so  
            //  return the second last label
            return frameLabels[(frameLabels.length > 2) ? frameLabels.length - 2 : 0];
        }
        
        
        /**
         * Goto the previous label in a MovieClip
         * 
         * @param clip The MovieClip with labels
         */
        public static function gotoPreviousLabel(clip:MovieClip):void
        {
            var frameLabel:FrameLabel = getPreviousLabel(clip);
            if (frameLabel) 
            {
                clip.gotoAndStop(frameLabel.frame);
            }
        }
        
        /**
         * Recursively stop any MovieClip children attached to a DisplayObjectContainer
         * 
         * @param container DisplayObjectContainer being stopped
         */
        public static function recursiveStop(container:DisplayObjectContainer):void 
        {
            if (container is MovieClip)
            {
                (container as MovieClip).stop();
            }
            
            for (var i:uint = 0; i < container.numChildren; ++i) 
            {
                var child:DisplayObject = container.getChildAt(i);
                
                if (child is DisplayObjectContainer) 
                {
                    recursiveStop(child as DisplayObjectContainer);
                }
            }
        }
    }
}